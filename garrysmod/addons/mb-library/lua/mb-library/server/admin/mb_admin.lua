MB.Library.Admin = MB.Library.Admin or {}
MB.Library.Admin.Commands = MB.Library.Admin.Commands or {}

function MB.Library.Admin.RegisterCommand(name, callback, adminOnly)
    MB.Library.Admin.Commands[name] = {
        callback = callback,
        adminOnly = adminOnly or false
    }
end

function MB.Library.Admin.ExecuteCommand(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local command = MB.Library.Admin.Commands[cmd]
    
    if not command then
        MB.Library.Networking.SendToPlayer("Notification", ply, {
            title = "Error",
            text = "Unknown command: " .. cmd,
            type = NOTIFY_ERROR
        })
        return
    end
    
    if command.adminOnly and not ply:IsAdmin() then
        MB.Library.Networking.SendToPlayer("Notification", ply, {
            title = "Error",
            text = "You don't have permission to use this command.",
            type = NOTIFY_ERROR
        })
        return
    end
    
    command.callback(ply, args)
end

function MB.Library.Admin.BroadcastMessage(message, color)
    color = color or Color(255, 0, 0)
    
    for _, ply in ipairs(player.GetAll()) do
        ply:ChatPrint(message)
    end
    
    MB.Library.Logs.Add("broadcast", message)
end

function MB.Library.Admin.KickPlayer(target, reason, admin)
    if not IsValid(target) then return false end
    
    reason = reason or "Kicked by admin"
    
    if admin then
        MB.Library.Logs.Add("admin", admin:Nick() .. " kicked " .. target:Nick() .. " (" .. reason .. ")", admin)
    else
        MB.Library.Logs.Add("admin", "Console kicked " .. target:Nick() .. " (" .. reason .. ")")
    end
    
    target:Kick(reason)
    return true
end

function MB.Library.Admin.BanPlayer(target, duration, reason, admin)
    if not IsValid(target) then return false end
    
    reason = reason or "Banned by admin"
    duration = duration or 0 
    
    if admin then
        MB.Library.Logs.Add("admin", admin:Nick() .. " banned " .. target:Nick() .. " for " .. (duration == 0 and "permanent" or duration .. " minutes") .. " (" .. reason .. ")", admin)
    else
        MB.Library.Logs.Add("admin", "Console banned " .. target:Nick() .. " for " .. (duration == 0 and "permanent" or duration .. " minutes") .. " (" .. reason .. ")")
    end
    
    game.ConsoleCommand("banid " .. duration .. " " .. target:SteamID() .. "\n")
    game.ConsoleCommand("kickid " .. target:UserID() .. " " .. reason .. "\n")
    return true
end

function MB.Library.Admin.SendPrivateMessage(sender, target, message)
    if not IsValid(target) then return false end
    
    MB.Library.Networking.SendToPlayer("Notification", target, {
        title = "PM from " .. (IsValid(sender) and sender:Nick() or "Console"),
        text = message,
        type = NOTIFY_GENERIC
    })
    
    if IsValid(sender) then
        MB.Library.Networking.SendToPlayer("Notification", sender, {
            title = "PM to " .. target:Nick(),
            text = message,
            type = NOTIFY_GENERIC
        })
    end
    
    MB.Library.Logs.Add("pm", (IsValid(sender) and sender:Nick() or "Console") .. " to " .. target:Nick() .. ": " .. message, sender)
    return true
end

MB.Library.Admin.RegisterCommand("kick", function(ply, args)
    if not args[1] then
        MB.Library.Networking.SendToPlayer("Notification", ply, {
            title = "Error",
            text = "Usage: !kick <player> [reason]",
            type = NOTIFY_ERROR
        })
        return
    end
    
    local target = nil
    
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Nick()), string.lower(args[1]), 1, true) then
            target = p
            break
        end
    end
    
    if not target then
        MB.Library.Networking.SendToPlayer("Notification", ply, {
            title = "Error",
            text = "Player not found: " .. args[1],
            type = NOTIFY_ERROR
        })
        return
    end
    
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    
    if reason == "" then
        reason = "Kicked by " .. ply:Nick()
    end
    
    if MB.Library.Admin.KickPlayer(target, reason, ply) then
        MB.Library.Networking.SendToPlayer("Notification", ply, {
            title = "Success",
            text = "Kicked " .. target:Nick(),
            type = NOTIFY_GENERIC
        })
    end
end, true)

MB.Library.Admin.RegisterCommand("ban", function(ply, args)
    if not args[1] or not args[2] then
        MB.Library.Networking.SendToPlayer("Notification", ply, {
            title = "Error",
            text = "Usage: !ban <player> <duration in minutes, 0 for permanent> [reason]",
            type = NOTIFY_ERROR
        })
        return
    end
    
    local target = nil
    
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Nick()), string.lower(args[1]), 1, true) then
            target = p
            break
        end
    end
    
    if not target then
        MB.Library.Networking.SendToPlayer("Notification", ply, {
            title = "Error",
            text = "Player not found: " .. args[1],
            type = NOTIFY_ERROR
        })
        return
    end
    
    local duration = tonumber(args[2]) or 0
    
    table.remove(args, 1)
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    
    if reason == "" then
        reason = "Banned by " .. ply:Nick()
    end
    
    if MB.Library.Admin.BanPlayer(target, duration, reason, ply) then
        MB.Library.Networking.SendToPlayer("Notification", ply, {
            title = "Success",
            text = "Banned " .. target:Nick() .. " for " .. (duration == 0 and "permanent" or duration .. " minutes"),
            type = NOTIFY_GENERIC
        })
    end
end, true)

MB.Library.Admin.RegisterCommand("pm", function(ply, args)
    if not args[1] or not args[2] then
        MB.Library.Networking.SendToPlayer("Notification", ply, {
            title = "Error",
            text = "Usage: !pm <player> <message>",
            type = NOTIFY_ERROR
        })
        return
    end
    
    local target = nil
    
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Nick()), string.lower(args[1]), 1, true) then
            target = p
            break
        end
    end
    
    if not target then
        MB.Library.Networking.SendToPlayer("Notification", ply, {
            title = "Error",
            text = "Player not found: " .. args[1],
            type = NOTIFY_ERROR
        })
        return
    end
    
    table.remove(args, 1)
    local message = table.concat(args, " ")
    
    if MB.Library.Admin.SendPrivateMessage(ply, target, message) then
        MB.Library.Logs.Add("pm", ply:Nick() .. " to " .. target:Nick() .. ": " .. message, ply)
    end
end, false)

local function processCommand(ply, text)
    if string.sub(text, 1, 1) ~= "!" then return end
    
    local args = string.Explode(" ", text)
    local cmd = string.sub(args[1], 2)
    table.remove(args, 1)
    
    MB.Library.Admin.ExecuteCommand(ply, cmd, args)
    
    return ""
end

hook.Add("PlayerSay", "MB.Library.Admin.CommandHandler", processCommand) 