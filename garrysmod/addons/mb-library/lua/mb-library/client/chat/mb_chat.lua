MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Chat = MB.Library.Chat or {}

MB.Library.Chat.Commands = {}
MB.Library.Chat.Filters = {}
MB.Library.Chat.Tags = {}
MB.Library.Chat.Emotes = {}
MB.Library.Chat.History = {}
MB.Library.Chat.HistoryLimit = 100

function MB.Library.Chat.Initialize()
    hook.Add("OnPlayerChat", "MB.Library.Chat.Process", MB.Library.Chat.Process)
    hook.Add("ChatTextChanged", "MB.Library.Chat.TextChanged", MB.Library.Chat.TextChanged)
    
    MB.Library.Chat.RegisterDefaultEmotes()
    MB.Library.Chat.RegisterDefaultTags()
    
    MB.Library.Log("Chat module initialized")
end

function MB.Library.Chat.Process(player, text, teamChat, isDead)
    local shouldShow = true
    local finalText = text
    
    if string.sub(text, 1, 1) == "!" then
        local commandSuccess = MB.Library.Chat.HandleCommand(player, text)
        if commandSuccess then
            shouldShow = false
        end
    end
    
    finalText = MB.Library.Chat.ApplyFilters(player, finalText)
    finalText = MB.Library.Chat.ReplaceEmotes(finalText)
    
    if shouldShow then
        local entry = {
            player = player,
            text = finalText,
            originalText = text,
            teamChat = teamChat,
            isDead = isDead,
            timestamp = os.time()
        }
        
        table.insert(MB.Library.Chat.History, entry)
        
        if #MB.Library.Chat.History > MB.Library.Chat.HistoryLimit then
            table.remove(MB.Library.Chat.History, 1)
        end
        
        hook.Run("MB.Library.Chat.MessageProcessed", entry)
    end
    
    return shouldShow
end

function MB.Library.Chat.TextChanged(text)
    if string.sub(text, 1, 1) == "!" then
        local command = string.Explode(" ", text)[1]
        command = string.sub(command, 2)
        
        if MB.Library.Chat.Commands[command] then
            local usage = MB.Library.Chat.Commands[command].usage or ""
            local info = MB.Library.Chat.Commands[command].info or "No information available"
            
            hook.Run("MB.Library.Chat.CommandInfo", command, usage, info)
        end
    end
end

function MB.Library.Chat.RegisterCommand(command, callback, info)
    if not command or not callback then return false end
    
    MB.Library.Chat.Commands[command] = {
        callback = callback,
        usage = info and info.usage or nil,
        description = info and info.description or nil,
        permission = info and info.permission or nil,
        info = info
    }
    
    return true
end

function MB.Library.Chat.HandleCommand(player, text)
    local parts = string.Explode(" ", text)
    local command = string.sub(parts[1], 2)
    table.remove(parts, 1)
    local args = parts
    
    if MB.Library.Chat.Commands[command] then
        local cmd = MB.Library.Chat.Commands[command]
        
        if cmd.permission and not MB.Library.Permissions.Check(player, cmd.permission) then
            MB.Library.Chat.SendSystemMessage("You don't have permission to use this command.", player, "error")
            return true
        end
        
        local success, result = pcall(cmd.callback, player, args)
        
        if not success then
            MB.Library.Log("Error executing chat command '" .. command .. "': " .. tostring(result), "error")
            MB.Library.Chat.SendSystemMessage("An error occurred while executing this command.", player, "error")
        end
        
        return true
    end
    
    return false
end

function MB.Library.Chat.RegisterFilter(id, filter)
    if not id or not filter or type(filter) ~= "function" then return false end
    
    MB.Library.Chat.Filters[id] = filter
    return true
end

function MB.Library.Chat.RemoveFilter(id)
    if not id or not MB.Library.Chat.Filters[id] then return false end
    
    MB.Library.Chat.Filters[id] = nil
    return true
end

function MB.Library.Chat.ApplyFilters(player, text)
    local result = text
    
    for id, filter in pairs(MB.Library.Chat.Filters) do
        local success, filtered = pcall(filter, player, result)
        
        if success and filtered then
            result = filtered
        end
    end
    
    return result
end

function MB.Library.Chat.RegisterTag(tag, color, icon, permission)
    MB.Library.Chat.Tags[tag] = {
        color = color or Color(255, 255, 255),
        icon = icon,
        permission = permission
    }
    
    return true
end

function MB.Library.Chat.RegisterDefaultTags()
    MB.Library.Chat.RegisterTag("admin", Color(255, 0, 0), "icon16/shield.png", "admin")
    MB.Library.Chat.RegisterTag("mod", Color(0, 150, 255), "icon16/wand.png", "moderator")
    MB.Library.Chat.RegisterTag("vip", Color(255, 215, 0), "icon16/star.png", "vip")
    MB.Library.Chat.RegisterTag("dev", Color(150, 50, 250), "icon16/wrench.png", "developer")
end

function MB.Library.Chat.GetPlayerTags(player)
    local tags = {}
    
    for tag, data in pairs(MB.Library.Chat.Tags) do
        if not data.permission or MB.Library.Permissions.Check(player, data.permission) then
            table.insert(tags, {
                name = tag,
                color = data.color,
                icon = data.icon
            })
        end
    end
    
    hook.Run("MB.Library.Chat.GetPlayerTags", player, tags)
    
    return tags
end

function MB.Library.Chat.RegisterEmote(code, replacement, image)
    MB.Library.Chat.Emotes[code] = {
        replacement = replacement,
        image = image
    }
    
    return true
end

function MB.Library.Chat.RegisterDefaultEmotes()
    MB.Library.Chat.RegisterEmote(":)", "😊", "emotes/smile.png")
    MB.Library.Chat.RegisterEmote(":(", "😢", "emotes/sad.png")
    MB.Library.Chat.RegisterEmote(":D", "😃", "emotes/grin.png")
    MB.Library.Chat.RegisterEmote(":P", "😛", "emotes/tongue.png")
    MB.Library.Chat.RegisterEmote(";)", "😉", "emotes/wink.png")
    MB.Library.Chat.RegisterEmote(":O", "😮", "emotes/surprised.png")
    MB.Library.Chat.RegisterEmote("<3", "❤️", "emotes/heart.png")
end

function MB.Library.Chat.ReplaceEmotes(text)
    local result = text
    
    for code, data in pairs(MB.Library.Chat.Emotes) do
        local escapedCode = string.gsub(code, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
        
        if data.image then
            result = string.gsub(result, escapedCode, '<img src="' .. data.image .. '" />')
        else
            result = string.gsub(result, escapedCode, data.replacement)
        end
    end
    
    return result
end

function MB.Library.Chat.SendSystemMessage(message, recipient, type)
    if not message then return false end
    
    type = type or "info"
    
    local color
    if type == "error" then
        color = Color(255, 50, 50)
    elseif type == "warning" then
        color = Color(255, 200, 0)
    elseif type == "success" then
        color = Color(50, 200, 50)
    else
        color = Color(100, 150, 255)
    end
    
    if recipient then
        chat.AddText(color, "[System] ", color_white, message)
    else
        for _, ply in ipairs(player.GetAll()) do
            chat.AddText(ply, color, "[System] ", color_white, message)
        end
    end
    
    return true
end

function MB.Library.Chat.GetHistory(limit)
    limit = limit or MB.Library.Chat.HistoryLimit
    
    local result = {}
    local count = math.min(#MB.Library.Chat.History, limit)
    
    for i = #MB.Library.Chat.History - count + 1, #MB.Library.Chat.History do
        table.insert(result, MB.Library.Chat.History[i])
    end
    
    return result
end

hook.Add("Initialize", "MB.Library.Chat.Initialize", MB.Library.Chat.Initialize)