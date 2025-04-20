MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Achievements = MB.Library.Achievements or {}

MB.Library.Achievements.Registered = {}
MB.Library.Achievements.Unlocked = {}
MB.Library.Achievements.Progress = {}

function MB.Library.Achievements.Initialize()
    MB.Library.Achievements.Load()
    hook.Add("MB.Library.Events.Trigger", "MB.Library.Achievements.CheckEvent", MB.Library.Achievements.CheckEvent)
    
    MB.Library.Log("Achievements module initialized")
end

function MB.Library.Achievements.Register(id, data)
    if not id or not data then return false end
    
    if not data.name then data.name = id end
    if not data.description then data.description = "" end
    if not data.icon then data.icon = "icon16/star.png" end
    if not data.color then data.color = Color(255, 215, 0) end
    if not data.points then data.points = 10 end
    
    data.id = id
    MB.Library.Achievements.Registered[id] = data
    
    if not MB.Library.Achievements.Progress[id] then
        MB.Library.Achievements.Progress[id] = 0
    end
    
    MB.Library.Log("Registered achievement: " .. data.name)
    return true
end

function MB.Library.Achievements.CheckEvent(eventName, eventData)
    for id, achievement in pairs(MB.Library.Achievements.Registered) do
        if MB.Library.Achievements.IsUnlocked(id) then continue end
        
        if achievement.event == eventName then
            if achievement.condition then
                local success, result = pcall(achievement.condition, eventData)
                
                if success and result then
                    if achievement.progressRequired then
                        MB.Library.Achievements.IncrementProgress(id, result)
                    else
                        MB.Library.Achievements.Unlock(id)
                    end
                end
            else
                MB.Library.Achievements.Unlock(id)
            end
        end
    end
end

function MB.Library.Achievements.Unlock(id)
    if MB.Library.Achievements.IsUnlocked(id) then return false end
    
    local achievement = MB.Library.Achievements.Registered[id]
    if not achievement then 
        MB.Library.Log("Cannot unlock unknown achievement: " .. id, "error")
        return false 
    end
    
    MB.Library.Achievements.Unlocked[id] = os.time()
    MB.Library.Achievements.Progress[id] = achievement.progressRequired or 1
    
    MB.Library.Log("Achievement unlocked: " .. achievement.name)
    
    local notification = {
        title = "Achievement Unlocked!",
        text = achievement.name,
        icon = achievement.icon,
        color = achievement.color,
        duration = 5
    }
    
    if MB.Library.Notifications then
        MB.Library.Notifications.Show(notification)
    end
    
    hook.Run("MB.Library.Achievements.Unlocked", id, achievement)
    
    MB.Library.Achievements.Save()
    return true
end

function MB.Library.Achievements.IsUnlocked(id)
    return MB.Library.Achievements.Unlocked[id] ~= nil
end

function MB.Library.Achievements.GetProgress(id)
    return MB.Library.Achievements.Progress[id] or 0
end

function MB.Library.Achievements.SetProgress(id, progress)
    local achievement = MB.Library.Achievements.Registered[id]
    if not achievement then return false end
    
    if not achievement.progressRequired then
        MB.Library.Log("Cannot set progress for non-progressive achievement: " .. id, "warning")
        return false
    end
    
    local oldProgress = MB.Library.Achievements.Progress[id] or 0
    progress = math.max(0, math.min(progress, achievement.progressRequired))
    
    MB.Library.Achievements.Progress[id] = progress
    
    if oldProgress ~= progress then
        hook.Run("MB.Library.Achievements.ProgressChanged", id, progress, oldProgress)
        
        if progress >= achievement.progressRequired then
            MB.Library.Achievements.Unlock(id)
        end
        
        MB.Library.Achievements.Save()
    end
    
    return true
end

function MB.Library.Achievements.IncrementProgress(id, amount)
    amount = amount or 1
    local currentProgress = MB.Library.Achievements.GetProgress(id)
    return MB.Library.Achievements.SetProgress(id, currentProgress + amount)
end

function MB.Library.Achievements.GetPoints()
    local points = 0
    
    for id, timestamp in pairs(MB.Library.Achievements.Unlocked) do
        local achievement = MB.Library.Achievements.Registered[id]
        if achievement and achievement.points then
            points = points + achievement.points
        end
    end
    
    return points
end

function MB.Library.Achievements.GetUnlockTime(id)
    return MB.Library.Achievements.Unlocked[id]
end

function MB.Library.Achievements.Save()
    if not file.IsDir("montesbox", "DATA") then
        file.CreateDir("montesbox")
    end
    
    local data = {
        unlocked = MB.Library.Achievements.Unlocked,
        progress = MB.Library.Achievements.Progress
    }
    
    file.Write("montesbox/achievements.txt", util.TableToJSON(data, true))
    MB.Library.Log("Achievements saved")
    return true
end

function MB.Library.Achievements.Load()
    if not file.Exists("montesbox/achievements.txt", "DATA") then
        MB.Library.Log("No achievements file found")
        return false
    end
    
    local content = file.Read("montesbox/achievements.txt", "DATA")
    if not content then
        MB.Library.Log("Failed to read achievements file", "error")
        return false
    end
    
    local data = util.JSONToTable(content)
    if not data then
        MB.Library.Log("Invalid achievements file format", "error")
        return false
    end
    
    MB.Library.Achievements.Unlocked = data.unlocked or {}
    MB.Library.Achievements.Progress = data.progress or {}
    
    MB.Library.Log("Achievements loaded")
    return true
end

function MB.Library.Achievements.Reset()
    MB.Library.Achievements.Unlocked = {}
    MB.Library.Achievements.Progress = {}
    
    MB.Library.Achievements.Save()
    hook.Run("MB.Library.Achievements.Reset")
    
    MB.Library.Log("Achievements reset")
    return true
end

hook.Add("Initialize", "MB.Library.Achievements.Initialize", MB.Library.Achievements.Initialize) 