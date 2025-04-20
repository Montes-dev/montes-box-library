MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Status = MB.Library.Status or {}

MB.Library.Status.PlayerStatuses = {}
MB.Library.Status.Icons = {}
MB.Library.Status.Colors = {}

function MB.Library.Status.Initialize()
    MB.Library.Status.RegisterDefaultStatusIcons()
    MB.Library.Status.RegisterDefaultStatusColors()
    
    hook.Add("Think", "MB.Library.Status.Think", MB.Library.Status.Think)
    
    MB.Library.Log("Status module initialized")
end

function MB.Library.Status.RegisterStatusIcon(statusType, icon)
    MB.Library.Status.Icons[statusType] = icon
    return true
end

function MB.Library.Status.RegisterStatusColor(statusType, color)
    MB.Library.Status.Colors[statusType] = color
    return true
end

function MB.Library.Status.RegisterDefaultStatusIcons()
    MB.Library.Status.RegisterStatusIcon("afk", "icon16/clock.png")
    MB.Library.Status.RegisterStatusIcon("typing", "icon16/comment.png")
    MB.Library.Status.RegisterStatusIcon("building", "icon16/brick.png")
    MB.Library.Status.RegisterStatusIcon("speaking", "icon16/sound.png")
    MB.Library.Status.RegisterStatusIcon("driving", "icon16/car.png")
    MB.Library.Status.RegisterStatusIcon("shooting", "icon16/gun.png")
    MB.Library.Status.RegisterStatusIcon("admin", "icon16/shield.png")
    MB.Library.Status.RegisterStatusIcon("bot", "icon16/computer.png")
    MB.Library.Status.RegisterStatusIcon("loading", "icon16/hourglass.png")
    MB.Library.Status.RegisterStatusIcon("spectating", "icon16/eye.png")
end

function MB.Library.Status.RegisterDefaultStatusColors()
    MB.Library.Status.RegisterStatusColor("afk", Color(150, 150, 150))
    MB.Library.Status.RegisterStatusColor("typing", Color(64, 150, 238))
    MB.Library.Status.RegisterStatusColor("building", Color(76, 175, 80))
    MB.Library.Status.RegisterStatusColor("speaking", Color(76, 175, 255))
    MB.Library.Status.RegisterStatusColor("driving", Color(255, 152, 0))
    MB.Library.Status.RegisterStatusColor("shooting", Color(244, 67, 54))
    MB.Library.Status.RegisterStatusColor("admin", Color(156, 39, 176))
    MB.Library.Status.RegisterStatusColor("bot", Color(96, 125, 139))
    MB.Library.Status.RegisterStatusColor("loading", Color(255, 193, 7))
    MB.Library.Status.RegisterStatusColor("spectating", Color(0, 188, 212))
end

function MB.Library.Status.GetStatusIcon(statusType)
    return MB.Library.Status.Icons[statusType]
end

function MB.Library.Status.GetStatusColor(statusType)
    return MB.Library.Status.Colors[statusType]
end

function MB.Library.Status.SetPlayerStatus(player, statusType, duration)
    if not IsValid(player) then return false end
    
    local steamID = player:SteamID()
    
    MB.Library.Status.PlayerStatuses[steamID] = {
        type = statusType,
        player = player,
        startTime = CurTime(),
        duration = duration,
        temporary = duration ~= nil
    }
    
    hook.Run("MB.Library.Status.Changed", player, statusType)
    return true
end

function MB.Library.Status.ClearPlayerStatus(player)
    if not IsValid(player) then return false end
    
    local steamID = player:SteamID()
    local oldStatus = MB.Library.Status.PlayerStatuses[steamID]
    
    if oldStatus then
        MB.Library.Status.PlayerStatuses[steamID] = nil
        hook.Run("MB.Library.Status.Cleared", player, oldStatus.type)
        return true
    end
    
    return false
end

function MB.Library.Status.GetPlayerStatus(player)
    if not IsValid(player) then return nil end
    
    local steamID = player:SteamID()
    return MB.Library.Status.PlayerStatuses[steamID]
end

function MB.Library.Status.Think()
    local curTime = CurTime()
    
    for steamID, statusData in pairs(MB.Library.Status.PlayerStatuses) do
        if statusData.temporary and statusData.startTime + statusData.duration < curTime then
            local player = statusData.player
            if IsValid(player) then
                MB.Library.Status.ClearPlayerStatus(player)
            else
                MB.Library.Status.PlayerStatuses[steamID] = nil
            end
        end
    end
end

function MB.Library.Status.DetectPlayerTyping(player, isTyping)
    if not IsValid(player) then return end
    
    if isTyping then
        MB.Library.Status.SetPlayerStatus(player, "typing")
    else
        local status = MB.Library.Status.GetPlayerStatus(player)
        if status and status.type == "typing" then
            MB.Library.Status.ClearPlayerStatus(player)
        end
    end
end

function MB.Library.Status.DetectPlayerAFK(player, isAFK)
    if not IsValid(player) then return end
    
    if isAFK then
        MB.Library.Status.SetPlayerStatus(player, "afk")
    else
        local status = MB.Library.Status.GetPlayerStatus(player)
        if status and status.type == "afk" then
            MB.Library.Status.ClearPlayerStatus(player)
        end
    end
end

function MB.Library.Status.RenderPlayerStatus(player, x, y, size)
    if not IsValid(player) then return end
    
    local status = MB.Library.Status.GetPlayerStatus(player)
    if not status then return end
    
    size = size or 16
    
    local icon = MB.Library.Status.GetStatusIcon(status.type)
    local color = MB.Library.Status.GetStatusColor(status.type)
    
    if icon then
        surface.SetDrawColor(color or color_white)
        surface.SetMaterial(icon)
        surface.DrawTexturedRect(x, y, size, size)
    end
end

hook.Add("Initialize", "MB.Library.Status.Initialize", MB.Library.Status.Initialize) 