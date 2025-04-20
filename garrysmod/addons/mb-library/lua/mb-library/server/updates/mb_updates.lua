MB.Library.Updates = MB.Library.Updates or {}
MB.Library.Updates.Tasks = MB.Library.Updates.Tasks or {}
MB.Library.Updates.CurrentVersion = MB.Library.Version or "1.0.0"
MB.Library.Updates.LatestVersion = MB.Library.Updates.CurrentVersion
MB.Library.Updates.CheckInterval = 86400 -- 24 hours
MB.Library.Updates.UpdateCheckURL = "https://example.com/mb-library/version.json"

function MB.Library.Updates.Initialize()
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_updates (
            id INT AUTO_INCREMENT PRIMARY KEY,
            version VARCHAR(32) NOT NULL,
            description TEXT,
            installed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            is_successful BOOLEAN DEFAULT TRUE
        )
    ]])
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_update_tasks (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL UNIQUE,
            schedule VARCHAR(64) NOT NULL,
            last_run TIMESTAMP NULL,
            is_enabled BOOLEAN DEFAULT TRUE,
            task_data TEXT
        )
    ]])
    
    timer.Create("MB.Library.Updates.Check", MB.Library.Updates.CheckInterval, 0, MB.Library.Updates.CheckForUpdates)
    timer.Create("MB.Library.Updates.RunTasks", 60, 0, MB.Library.Updates.ProcessScheduledTasks)
    
    MB.Library.Updates.LoadTasks()
end

function MB.Library.Updates.LoadTasks()
    MB.Library.Database.Query("SELECT * FROM mb_update_tasks", function(data)
        if data then
            for _, task in ipairs(data) do
                local taskData = util.JSONToTable(task.task_data or "{}") or {}
                
                MB.Library.Updates.Tasks[task.name] = {
                    id = task.id,
                    name = task.name,
                    schedule = task.schedule,
                    lastRun = task.last_run,
                    isEnabled = task.is_enabled,
                    data = taskData
                }
            end
        end
    end)
end

function MB.Library.Updates.CheckForUpdates()
    http.Fetch(MB.Library.Updates.UpdateCheckURL, 
        function(body, size, headers, code)
            if code != 200 then
                MB.Library.Log("Failed to check for updates: HTTP " .. code)
                return
            end
            
            local data = util.JSONToTable(body)
            
            if not data or not data.version then
                MB.Library.Log("Invalid update data received")
                return
            end
            
            MB.Library.Updates.LatestVersion = data.version
            
            if MB.Library.Updates.IsNewerVersion(data.version, MB.Library.Updates.CurrentVersion) then
                MB.Library.Log("New version available: " .. data.version)
                
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        MB.Library.Networking.SendToPlayer("Notification", ply, {
                            title = "Update Available",
                            text = "A new version of MB-Library is available: " .. data.version,
                            type = NOTIFY_HINT
                        })
                    end
                end
            end
        end,
        function(error)
            MB.Library.Log("Failed to check for updates: " .. error)
        end
    )
end

function MB.Library.Updates.IsNewerVersion(version1, version2)
    local v1parts = string.Explode(".", version1)
    local v2parts = string.Explode(".", version2)
    
    for i = 1, math.max(#v1parts, #v2parts) do
        local v1 = tonumber(v1parts[i] or 0) or 0
        local v2 = tonumber(v2parts[i] or 0) or 0
        
        if v1 > v2 then
            return true
        elseif v1 < v2 then
            return false
        end
    end
    
    return false
end

function MB.Library.Updates.RegisterTask(name, schedule, taskFunc, data, isEnabled)
    if not name or name == "" then
        MB.Library.Log("Task name cannot be empty")
        return false
    end
    
    if not schedule or schedule == "" then
        MB.Library.Log("Task schedule cannot be empty")
        return false
    end
    
    if not taskFunc or type(taskFunc) != "function" then
        MB.Library.Log("Task function must be provided")
        return false
    end
    
    data = data or {}
    isEnabled = isEnabled != false
    
    local dataJson = util.TableToJSON(data)
    
    if MB.Library.Updates.Tasks[name] then
        MB.Library.Database.Prepare(
            "UPDATE mb_update_tasks SET schedule = ?, is_enabled = ?, task_data = ? WHERE name = ?",
            {schedule, isEnabled, dataJson, name},
            function()
                MB.Library.Updates.Tasks[name] = {
                    id = MB.Library.Updates.Tasks[name].id,
                    name = name,
                    schedule = schedule,
                    lastRun = MB.Library.Updates.Tasks[name].lastRun,
                    isEnabled = isEnabled,
                    data = data,
                    func = taskFunc
                }
                
                MB.Library.Log("Task updated: " .. name)
            end
        )
    else
        MB.Library.Database.Prepare(
            "INSERT INTO mb_update_tasks (name, schedule, is_enabled, task_data) VALUES (?, ?, ?, ?)",
            {name, schedule, isEnabled, dataJson},
            function()
                MB.Library.Database.Query("SELECT id FROM mb_update_tasks WHERE name = '" .. MB.Library.Database.Escape(name) .. "'", function(result)
                    if result and result[1] then
                        MB.Library.Updates.Tasks[name] = {
                            id = result[1].id,
                            name = name,
                            schedule = schedule,
                            lastRun = nil,
                            isEnabled = isEnabled,
                            data = data,
                            func = taskFunc
                        }
                        
                        MB.Library.Log("Task registered: " .. name)
                    end
                end)
            end
        )
    end
    
    MB.Library.Updates.Tasks[name] = MB.Library.Updates.Tasks[name] or {
        name = name,
        schedule = schedule,
        lastRun = nil,
        isEnabled = isEnabled,
        data = data,
        func = taskFunc
    }
    
    return true
end

function MB.Library.Updates.UnregisterTask(name)
    if not MB.Library.Updates.Tasks[name] then
        return false
    end
    
    MB.Library.Database.Prepare(
        "DELETE FROM mb_update_tasks WHERE name = ?",
        {name},
        function()
            MB.Library.Updates.Tasks[name] = nil
            MB.Library.Log("Task unregistered: " .. name)
        end
    )
    
    return true
end

function MB.Library.Updates.EnableTask(name, enable)
    if not MB.Library.Updates.Tasks[name] then
        return false
    end
    
    enable = enable != false
    
    MB.Library.Database.Prepare(
        "UPDATE mb_update_tasks SET is_enabled = ? WHERE name = ?",
        {enable, name},
        function()
            MB.Library.Updates.Tasks[name].isEnabled = enable
            MB.Library.Log("Task " .. (enable and "enabled" or "disabled") .. ": " .. name)
        end
    )
    
    return true
end

function MB.Library.Updates.RunTask(name, forceRun)
    local task = MB.Library.Updates.Tasks[name]
    
    if not task then
        MB.Library.Log("Task not found: " .. name)
        return false
    end
    
    if not task.isEnabled and not forceRun then
        MB.Library.Log("Task is disabled: " .. name)
        return false
    end
    
    local success, result = pcall(function()
        if task.func then
            return task.func(task.data)
        else
            return false
        end
    end)
    
    if not success then
        MB.Library.Log("Task failed: " .. name .. " - " .. tostring(result))
        return false
    end
    
    MB.Library.Database.Prepare(
        "UPDATE mb_update_tasks SET last_run = CURRENT_TIMESTAMP WHERE name = ?",
        {name},
        function()
            task.lastRun = os.time()
            MB.Library.Log("Task executed: " .. name)
        end
    )
    
    return true
end

function MB.Library.Updates.ShouldRunTask(task)
    if not task or not task.schedule or not task.isEnabled then
        return false
    end
    
    local schedule = task.schedule
    local lastRun = task.lastRun
    local currentTime = os.time()
    
    if not lastRun then
        return true
    end
    
    if string.find(schedule, "^every%s+(%d+)%s+seconds?$") then
        local seconds = tonumber(string.match(schedule, "^every%s+(%d+)%s+seconds?$"))
        return (currentTime - lastRun) >= seconds
    end
    
    if string.find(schedule, "^every%s+(%d+)%s+minutes?$") then
        local minutes = tonumber(string.match(schedule, "^every%s+(%d+)%s+minutes?$"))
        return (currentTime - lastRun) >= (minutes * 60)
    end
    
    if string.find(schedule, "^every%s+(%d+)%s+hours?$") then
        local hours = tonumber(string.match(schedule, "^every%s+(%d+)%s+hours?$"))
        return (currentTime - lastRun) >= (hours * 3600)
    end
    
    if string.find(schedule, "^every%s+(%d+)%s+days?$") then
        local days = tonumber(string.match(schedule, "^every%s+(%d+)%s+days?$"))
        return (currentTime - lastRun) >= (days * 86400)
    end
    
    if schedule == "hourly" then
        return (currentTime - lastRun) >= 3600
    end
    
    if schedule == "daily" then
        return (currentTime - lastRun) >= 86400
    end
    
    if schedule == "weekly" then
        return (currentTime - lastRun) >= 604800
    end
    
    if schedule == "monthly" then
        return (currentTime - lastRun) >= 2592000 -- 30 days
    end
    
    return false
end

function MB.Library.Updates.ProcessScheduledTasks()
    for name, task in pairs(MB.Library.Updates.Tasks) do
        if MB.Library.Updates.ShouldRunTask(task) then
            MB.Library.Updates.RunTask(name)
        end
    end
end

function MB.Library.Updates.RecordUpdate(version, description, successful)
    successful = successful != false
    
    MB.Library.Database.Prepare(
        "INSERT INTO mb_updates (version, description, is_successful) VALUES (?, ?, ?)",
        {version, description or "", successful},
        function()
            MB.Library.Log("Update recorded: " .. version .. (successful and " (successful)" or " (failed)"))
        end
    )
end

hook.Add("DatabaseInitialized", "MB.Library.Updates.Initialize", MB.Library.Updates.Initialize)

MB.Library.Updates.RegisterTask("database_backup", "daily", function()
    MB.Library.Backup.Create("scheduled_" .. os.date("%Y%m%d"))
    return true
end, {}, true)

MB.Library.Updates.RegisterTask("prune_logs", "weekly", function()
    MB.Library.Database.Query("DELETE FROM mb_logs WHERE timestamp < DATE_SUB(NOW(), INTERVAL 30 DAY)")
    return true
end, {
    days_to_keep = 30
}, true) 