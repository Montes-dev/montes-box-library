MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.RealTimeNotifications = MB.Library.RealTimeNotifications or {}
MB.Library.RealTimeNotifications.Queue = MB.Library.RealTimeNotifications.Queue or {}

function MB.Library.RealTimeNotifications.Initialize()
    if SERVER then
        util.AddNetworkString("MB.Library.RealTimeNotification")
    end
    
    if CLIENT then
        net.Receive("MB.Library.RealTimeNotification", function()
            local notifData = net.ReadTable()
            MB.Library.RealTimeNotifications.DisplayNotification(notifData)
        end)
    end
    
    MB.Library.Log("Real-time notifications module initialized")
end

function MB.Library.RealTimeNotifications.SendToPlayers(players, title, message, type, duration)
    if not SERVER then return end
    if not players or not title or not message then return end
    
    type = type or "info"
    duration = duration or 5
    
    local notifData = {
        title = title,
        message = message,
        type = type,
        duration = duration,
        timestamp = os.time()
    }
    
    for _, ply in ipairs(players) do
        if IsValid(ply) and ply:IsPlayer() then
            net.Start("MB.Library.RealTimeNotification")
            net.WriteTable(notifData)
            net.Send(ply)
        end
    end
end

function MB.Library.RealTimeNotifications.SendToAll(title, message, type, duration)
    if not SERVER then return end
    
    MB.Library.RealTimeNotifications.SendToPlayers(player.GetAll(), title, message, type, duration)
end

function MB.Library.RealTimeNotifications.SendToPlayer(player, title, message, type, duration)
    if not SERVER then return end
    if not IsValid(player) or not player:IsPlayer() then return end
    
    MB.Library.RealTimeNotifications.SendToPlayers({player}, title, message, type, duration)
end

function MB.Library.RealTimeNotifications.DisplayNotification(notifData)
    if not CLIENT then return end
    
    if MB.Library.UI and MB.Library.UI.CreateNotification then
        MB.Library.UI.CreateNotification(notifData.title, notifData.message, notifData.type, notifData.duration)
    else
        notification.AddLegacy(notifData.title .. ": " .. notifData.message, 
            notifData.type == "error" and NOTIFY_ERROR or 
            notifData.type == "warning" and NOTIFY_UNDO or NOTIFY_GENERIC, 
            notifData.duration)
        surface.PlaySound("buttons/button15.wav")
    end
end

hook.Add("MB.Library.Initialize", "MB.Library.RealTimeNotifications.Init", function()
    MB.Library.RealTimeNotifications.Initialize()
end) 