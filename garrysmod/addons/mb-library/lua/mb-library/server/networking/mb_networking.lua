MB.Library = MB.Library or {}
MB.Library.Networking = MB.Library.Networking or {}

MB.Library.Networking.Active = MB.Library.Networking.Active or {}

function MB.Library.Networking.Register(name)
    if not name or name == "" then return false end
    
    util.AddNetworkString("MB.Net." .. name)
    table.insert(MB.Library.Networking.Active, name)
    
    MB.Library.Log("Registered network string: MB.Net." .. name)
    
    return true
end

function MB.Library.Networking.Send(name, ply, data)
    if not name or not IsValid(ply) then return false end
    
    net.Start("MB.Net." .. name)
    
    if data then
        if type(data) == "table" then
            net.WriteTable(data)
        elseif type(data) == "string" then
            net.WriteString(data)
        elseif type(data) == "number" then
            net.WriteFloat(data)
        elseif type(data) == "boolean" then
            net.WriteBool(data)
        elseif type(data) == "Entity" or type(data) == "Player" then
            net.WriteEntity(data)
        else
            net.WriteTable({ data = data })
        end
    end
    
    net.Send(ply)
    
    return true
end

function MB.Library.Networking.Broadcast(name, data)
    if not name then return false end
    
    net.Start("MB.Net." .. name)
    
    if data then
        if type(data) == "table" then
            net.WriteTable(data)
        elseif type(data) == "string" then
            net.WriteString(data)
        elseif type(data) == "number" then
            net.WriteFloat(data)
        elseif type(data) == "boolean" then
            net.WriteBool(data)
        elseif type(data) == "Entity" or type(data) == "Player" then
            net.WriteEntity(data)
        else
            net.WriteTable({ data = data })
        end
    end
    
    net.Broadcast()
    
    return true
end

function MB.Library.Networking.Initialize()
    MB.Library.Networking.Register("Notification")
    MB.Library.Networking.Register("AdminAction")
    MB.Library.Networking.Register("AdminResponse")
    MB.Library.Networking.Register("RequestData")
    MB.Library.Networking.Register("SendData")
    MB.Library.Networking.Register("Config")
    MB.Library.Networking.Register("Event")
    
    MB.Library.Networking.SetupHandlers()
    
    MB.Library.Log("Networking module initialized")
end

function MB.Library.Networking.SetupHandlers()
    net.Receive("MB.Net.AdminAction", function(len, ply)
        if not IsValid(ply) or not (ply:IsAdmin() or ply:IsSuperAdmin()) then
            MB.Library.Networking.Send("AdminResponse", ply, {
                success = false,
                message = "You don't have permission to perform this action."
            })
            return
        end
        
        local data = net.ReadTable()
        
        if not data or not data.action then 
            MB.Library.Networking.Send("AdminResponse", ply, {
                success = false,
                message = "Invalid action data."
            })
            return
        end
        
        local success, message = MB.Library.Networking.HandleAdminAction(ply, data)
        
        MB.Library.Networking.Send("AdminResponse", ply, {
            success = success,
            message = message
        })
    end)
    
    net.Receive("MB.Net.RequestData", function(len, ply)
        if not IsValid(ply) then return end
        
        local data = net.ReadTable()
        
        if not data or not data.type then return end
        
        MB.Library.Networking.HandleDataRequest(ply, data)
    end)
end

function MB.Library.Networking.HandleAdminAction(ply, data)
    if not IsValid(ply) or not data or not data.action then
        return false, "Invalid action data"
    end
    
    local action = data.action
    
    if action == "kick" then
        local target = player.GetBySteamID64(data.target)
        
        if not IsValid(target) then
            return false, "Player not found"
        end
        
        local reason = data.reason or "No reason provided"
        
        MB.Library.Log("Admin " .. ply:Nick() .. " kicked player " .. target:Nick() .. ". Reason: " .. reason)
        
        for _, admin in ipairs(player.GetAll()) do
            if admin:IsAdmin() or admin:IsSuperAdmin() then
                MB.Library.Networking.Send("Notification", admin, {
                    title = "Admin Action",
                    text = ply:Nick() .. " kicked " .. target:Nick() .. ". Reason: " .. reason,
                    type = NOTIFY_GENERIC,
                    lifetime = 5
                })
            end
        end
        
        target:Kick(reason)
        
        return true, "Player kicked successfully"
    elseif action == "ban" then
        local target = player.GetBySteamID64(data.target)
        local duration = tonumber(data.duration) or 0
        local reason = data.reason or "No reason provided"
        
        if not IsValid(target) then
            return false, "Player not found"
        end
        
        if ULib and ULib.bans then
            ULib.ban(target, duration, reason, ply)
            return true, "Player banned successfully (using ULX)"
        end
        
        if duration <= 0 then
            game.ConsoleCommand("banid " .. duration .. " " .. target:SteamID() .. "\n")
            game.ConsoleCommand("kickid " .. target:UserID() .. " " .. reason .. "\n")
        else
            game.ConsoleCommand("banid " .. duration .. " " .. target:SteamID() .. "\n")
            game.ConsoleCommand("kickid " .. target:UserID() .. " " .. reason .. "\n")
        end
        
        MB.Library.Log("Admin " .. ply:Nick() .. " banned player " .. target:Nick() .. " for " .. (duration > 0 and duration .. " minutes" or "permanently") .. ". Reason: " .. reason)
        
        for _, admin in ipairs(player.GetAll()) do
            if admin:IsAdmin() or admin:IsSuperAdmin() then
                MB.Library.Networking.Send("Notification", admin, {
                    title = "Admin Action",
                    text = ply:Nick() .. " banned " .. target:Nick() .. " for " .. (duration > 0 and duration .. " minutes" or "permanently") .. ". Reason: " .. reason,
                    type = NOTIFY_GENERIC,
                    lifetime = 5
                })
            end
        end
        
        return true, "Player banned successfully"
    elseif action == "message" then
        local target = player.GetBySteamID64(data.target)
        local message = data.message or ""
        
        if not IsValid(target) then
            return false, "Player not found"
        end
        
        if message == "" then
            return false, "Cannot send empty message"
        end
        
        MB.Library.Networking.Send("Notification", target, {
            title = "Message from " .. ply:Nick(),
            text = message,
            type = NOTIFY_GENERIC,
            lifetime = 10
        })
        
        MB.Library.Log("Admin " .. ply:Nick() .. " sent message to " .. target:Nick() .. ": " .. message)
        
        return true, "Message sent to player"
    elseif action == "goto" then
        local target = player.GetBySteamID64(data.target)
        
        if not IsValid(target) then
            return false, "Player not found"
        end
        
        local targetPos = target:GetPos()
        ply:SetPos(targetPos + Vector(0, 0, 10))
        
        MB.Library.Log("Admin " .. ply:Nick() .. " teleported to " .. target:Nick())
        
        return true, "Teleported to player"
    elseif action == "bring" then
        local target = player.GetBySteamID64(data.target)
        
        if not IsValid(target) then
            return false, "Player not found"
        end
        
        local adminPos = ply:GetPos()
        target:SetPos(adminPos + Vector(0, 0, 10))
        
        MB.Library.Log("Admin " .. ply:Nick() .. " brought " .. target:Nick() .. " to them")
        
        MB.Library.Networking.Send("Notification", target, {
            title = "Admin Action",
            text = "You have been teleported to " .. ply:Nick(),
            type = NOTIFY_GENERIC,
            lifetime = 5
        })
        
        return true, "Player teleported to you"
    elseif action == "freeze" then
        local target = player.GetBySteamID64(data.target)
        
        if not IsValid(target) then
            return false, "Player not found"
        end
        
        if target:IsFlagSet(FL_FROZEN) then
            target:UnLock()
            
            MB.Library.Log("Admin " .. ply:Nick() .. " unfroze player " .. target:Nick())
            
            MB.Library.Networking.Send("Notification", target, {
                title = "Admin Action",
                text = "You have been unfrozen by " .. ply:Nick(),
                type = NOTIFY_GENERIC,
                lifetime = 5
            })
            
            return true, "Player unfrozen"
        else
            target:Lock()
            
            MB.Library.Log("Admin " .. ply:Nick() .. " froze player " .. target:Nick())
            
            MB.Library.Networking.Send("Notification", target, {
                title = "Admin Action",
                text = "You have been frozen by " .. ply:Nick(),
                type = NOTIFY_GENERIC,
                lifetime = 5
            })
            
            return true, "Player frozen"
        end
    else
        return false, "Unknown action"
    end
end

function MB.Library.Networking.HandleDataRequest(ply, data)
    if not IsValid(ply) then return end
    
    local dataType = data.type
    
    if dataType == "players" then
        local playerData = {}
        
        for _, player in ipairs(player.GetAll()) do
            table.insert(playerData, {
                name = player:Nick(),
                steamid = player:SteamID64(),
                ping = player:Ping(),
                team = player:Team(),
                health = player:Health(),
                armor = player:Armor(),
                isAdmin = player:IsAdmin(),
                isSuperAdmin = player:IsSuperAdmin()
            })
        end
        
        MB.Library.Networking.Send("SendData", ply, {
            type = "players",
            data = playerData
        })
    elseif dataType == "logs" then
        local logData = {
            {
                time = os.date("%Y-%m-%d %H:%M:%S", os.time() - 300),
                type = "Admin Action",
                message = "Admin 'Example' kicked player 'TestUser' (Reason: Breaking rules)"
            },
            {
                time = os.date("%Y-%m-%d %H:%M:%S", os.time() - 600),
                type = "Player Activity",
                message = "Player 'ExampleUser' connected to the server"
            },
            {
                time = os.date("%Y-%m-%d %H:%M:%S", os.time() - 900),
                type = "Server Event",
                message = "Map changed to '" .. game.GetMap() .. "'"
            }
        }
        
        MB.Library.Networking.Send("SendData", ply, {
            type = "logs",
            data = logData
        })
    elseif dataType == "config" then
        local configData = {
            mb_admin_notifications = true,
            mb_log_admin_actions = true,
            mb_refresh_rate = 5,
            mb_advanced_logging = false,
            
            mb_admin_theme = "Dark Modern",
            mb_ui_scale = 1,
            mb_show_admin_icons = true,
            
            mb_superadmin_ban = true,
            mb_admin_ban = true,
            mb_superadmin_teleport = true,
            mb_admin_teleport = false
        }
        
        MB.Library.Networking.Send("SendData", ply, {
            type = "config",
            data = configData
        })
    end
end

hook.Add("Initialize", "MB.Library.Networking.Init", function()
    MB.Library.Networking.Initialize()
end) 