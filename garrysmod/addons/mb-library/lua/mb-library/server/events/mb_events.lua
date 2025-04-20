MB.Library.Events = MB.Library.Events or {}
MB.Library.Events.Handlers = MB.Library.Events.Handlers or {}
MB.Library.Events.Queue = MB.Library.Events.Queue or {}
MB.Library.Events.ProcessingQueue = false

function MB.Library.Events.Register(eventName, handlerID, callback, priority)
    priority = priority or 10
    
    MB.Library.Events.Handlers[eventName] = MB.Library.Events.Handlers[eventName] or {}
    
    MB.Library.Events.Handlers[eventName][handlerID] = {
        callback = callback,
        priority = priority
    }
    
    return true
end

function MB.Library.Events.Unregister(eventName, handlerID)
    if not MB.Library.Events.Handlers[eventName] then return false end
    
    if MB.Library.Events.Handlers[eventName][handlerID] then
        MB.Library.Events.Handlers[eventName][handlerID] = nil
        
        if table.Count(MB.Library.Events.Handlers[eventName]) == 0 then
            MB.Library.Events.Handlers[eventName] = nil
        end
        
        return true
    end
    
    return false
end

function MB.Library.Events.Trigger(eventName, data, callback)
    if not MB.Library.Events.Handlers[eventName] then
        if callback then callback(data) end
        return false
    end
    
    local eventItem = {
        name = eventName,
        data = data,
        callback = callback,
        handlers = {}
    }
    
    for handlerID, handler in pairs(MB.Library.Events.Handlers[eventName]) do
        table.insert(eventItem.handlers, {
            id = handlerID,
            callback = handler.callback,
            priority = handler.priority
        })
    end
    
    table.SortByMember(eventItem.handlers, "priority", true)
    
    table.insert(MB.Library.Events.Queue, eventItem)
    
    if not MB.Library.Events.ProcessingQueue then
        MB.Library.Events.ProcessQueue()
    end
    
    return true
end

function MB.Library.Events.ProcessQueue()
    if #MB.Library.Events.Queue == 0 then
        MB.Library.Events.ProcessingQueue = false
        return
    end
    
    MB.Library.Events.ProcessingQueue = true
    
    local event = table.remove(MB.Library.Events.Queue, 1)
    local handlerIndex = 1
    
    local function nextHandler(modifiedData)
        if modifiedData then
            event.data = modifiedData
        end
        
        if handlerIndex > #event.handlers then
            if event.callback then
                event.callback(event.data)
            end
            
            MB.Library.Events.ProcessQueue()
            return
        end
        
        local handler = event.handlers[handlerIndex]
        handlerIndex = handlerIndex + 1
        
        local success, result = pcall(handler.callback, event.data, nextHandler)
        
        if not success then
            MB.Library.Log("Error in event handler '" .. handler.id .. "' for event '" .. event.name .. "': " .. result)
            nextHandler()
        end
    end
    
    nextHandler()
end

function MB.Library.Events.TriggerSync(eventName, data)
    if not MB.Library.Events.Handlers[eventName] then
        return data
    end
    
    local handlers = {}
    
    for handlerID, handler in pairs(MB.Library.Events.Handlers[eventName]) do
        table.insert(handlers, {
            id = handlerID,
            callback = handler.callback,
            priority = handler.priority
        })
    end
    
    table.SortByMember(handlers, "priority", true)
    
    for _, handler in ipairs(handlers) do
        local success, result = pcall(handler.callback, data)
        
        if not success then
            MB.Library.Log("Error in event handler '" .. handler.id .. "' for event '" .. eventName .. "': " .. result)
        elseif result ~= nil then
            data = result
        end
    end
    
    return data
end

hook.Add("PlayerInitialSpawn", "MB.Library.Events.PlayerJoin", function(ply)
    MB.Library.Events.Trigger("PlayerJoin", {
        player = ply,
        steamID = ply:SteamID(),
        steamID64 = ply:SteamID64(),
        name = ply:Nick(),
        ip = ply:IPAddress()
    })
end)

hook.Add("PlayerDisconnected", "MB.Library.Events.PlayerLeave", function(ply)
    MB.Library.Events.Trigger("PlayerLeave", {
        player = ply,
        steamID = ply:SteamID(),
        steamID64 = ply:SteamID64(),
        name = ply:Nick(),
        reason = ply.LastDisconnectReason or "Unknown"
    })
end)

hook.Add("PlayerSay", "MB.Library.Events.PlayerChat", function(ply, text, teamChat)
    local eventData = {
        player = ply,
        steamID = ply:SteamID(),
        steamID64 = ply:SteamID64(),
        name = ply:Nick(),
        message = text,
        teamChat = teamChat,
        canceled = false
    }
    
    eventData = MB.Library.Events.TriggerSync("PlayerChat", eventData)
    
    if eventData.canceled then
        return ""
    end
end)

MB.Library.Events.Register("PlayerJoin", "LogJoin", function(data)
    MB.Library.Logs.Add("player", "Player joined: " .. data.name .. " (" .. data.steamID .. ")")
end)

MB.Library.Events.Register("PlayerLeave", "LogLeave", function(data)
    MB.Library.Logs.Add("player", "Player left: " .. data.name .. " (" .. data.steamID .. "), reason: " .. data.reason)
end)

MB.Library.Events.Register("PlayerChat", "LogChat", function(data)
    if MB.Library.Config.Get("LogChatMessages", true) then
        MB.Library.Logs.Add("chat", (data.teamChat and "(TEAM) " or "") .. data.name .. ": " .. data.message, data.player)
    end
    
    return data
end)