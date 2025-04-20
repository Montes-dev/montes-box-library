MB.Library.Recovery = MB.Library.Recovery or {}
MB.Library.Recovery.CrashLogs = MB.Library.Recovery.CrashLogs or {}
MB.Library.Recovery.AutoBackupEnabled = true
MB.Library.Recovery.MaxCrashLogs = 10
MB.Library.Recovery.LastCrashTime = 0

function MB.Library.Recovery.Initialize()
    file.CreateDir("mb_library")
    file.CreateDir("mb_library/crash_logs")
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_crash_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            error TEXT,
            stack_trace TEXT,
            server_state TEXT,
            recovered BOOLEAN DEFAULT FALSE
        )
    ]])
    
    MB.Library.Recovery.DetectPreviousCrash()
    MB.Library.Recovery.SetupErrorCatching()
    
    MB.Library.Log("Recovery system initialized")
end

function MB.Library.Recovery.DetectPreviousCrash()
    if file.Exists("mb_library/server_running.txt", "DATA") then
        local lastRunTime = tonumber(file.Read("mb_library/server_running.txt", "DATA") or "0") or 0
        local currentTime = os.time()
        
        if lastRunTime > 0 and (currentTime - lastRunTime) < 300 then
            MB.Library.Recovery.LastCrashTime = lastRunTime
            MB.Library.Log("Detected potential crash at " .. os.date("%Y-%m-%d %H:%M:%S", lastRunTime))
            
            MB.Library.Recovery.RecordCrash("Server crash detected", nil, false)
            MB.Library.Recovery.PerformRecovery()
        end
    end
    
    file.Write("mb_library/server_running.txt", tostring(os.time()))
    
    timer.Create("MB.Library.Recovery.UpdateRunningFile", 60, 0, function()
        file.Write("mb_library/server_running.txt", tostring(os.time()))
    end)
end

function MB.Library.Recovery.SetupErrorCatching()
    hook.Add("OnLuaError", "MB.Library.Recovery.CatchError", function(errorStr, realm, stackTrace, addOn, errorType)
        if realm == "server" and errorType == 0 then
            MB.Library.Recovery.RecordCrash(errorStr, stackTrace, true)
        end
    end)
end

function MB.Library.Recovery.RecordCrash(errorMessage, stackTrace, isLuaError)
    local crashTime = os.time()
    local crashId = "crash_" .. crashTime
    
    local serverState = {
        time = crashTime,
        players = {},
        entities = #ents.GetAll(),
        luaMemory = collectgarbage("count"),
        isLuaError = isLuaError
    }
    
    for _, ply in ipairs(player.GetAll()) do
        table.insert(serverState.players, {
            steamId = ply:SteamID(),
            name = ply:Nick(),
            ping = ply:Ping(),
            pos = tostring(ply:GetPos())
        })
    end
    
    local serverStateJson = util.TableToJSON(serverState, true)
    
    MB.Library.Database.Prepare(
        "INSERT INTO mb_crash_logs (timestamp, error, stack_trace, server_state) VALUES (FROM_UNIXTIME(?), ?, ?, ?)",
        {crashTime, errorMessage or "Unknown error", stackTrace or "", serverStateJson},
        function()
            MB.Library.Log("Crash log recorded: " .. crashId)
        end
    )
    
    file.Write("mb_library/crash_logs/" .. crashId .. ".json", util.TableToJSON({
        timestamp = crashTime,
        error = errorMessage or "Unknown error",
        stackTrace = stackTrace or "",
        serverState = serverState
    }, true))
    
    table.insert(MB.Library.Recovery.CrashLogs, {
        id = crashId,
        timestamp = crashTime,
        error = errorMessage or "Unknown error",
        recovered = false
    })
    
    if MB.Library.Recovery.AutoBackupEnabled and not isLuaError then
        MB.Library.Recovery.CreateEmergencyBackup()
    end
    
    MB.Library.Recovery.CleanupOldCrashLogs()
    
    MB.Library.Events.Trigger("ServerCrash", {
        id = crashId,
        timestamp = crashTime,
        error = errorMessage,
        stackTrace = stackTrace,
        isLuaError = isLuaError
    })
    
    return crashId
end

function MB.Library.Recovery.CreateEmergencyBackup()
    MB.Library.Log("Creating emergency backup after crash")
    
    MB.Library.Backup.Create("emergency_" .. os.date("%Y%m%d_%H%M%S"), "Emergency backup after crash", function(success)
        if not success then
            MB.Library.Log("Failed to create emergency backup")
        end
    end)
end

function MB.Library.Recovery.PerformRecovery()
    MB.Library.Log("Performing recovery after crash")
    
    MB.Library.Database.Query("SELECT COUNT(*) AS error_count FROM mb_crash_logs WHERE timestamp > DATE_SUB(NOW(), INTERVAL 1 HOUR)", function(data)
        if data and data[1] and data[1].error_count > 3 then
            MB.Library.Log("Multiple crashes detected in the last hour, entering safe mode")
            MB.Library.Recovery.EnterSafeMode()
        end
    end)
    
    MB.Library.Optimization.RunGarbageCollection()
    
    for _, entClass in ipairs({"prop_physics", "prop_ragdoll"}) do
        for _, ent in ipairs(ents.FindByClass(entClass)) do
            if IsValid(ent) and not ent:IsPlayer() then
                ent:Remove()
            end
        end
    end
    
    MB.Library.Log("Recovery completed")
    
    MB.Library.Database.Prepare(
        "UPDATE mb_crash_logs SET recovered = 1 WHERE id = (SELECT id FROM mb_crash_logs ORDER BY timestamp DESC LIMIT 1)",
        {},
        function()
            MB.Library.Log("Crash log marked as recovered")
        end
    )
end

function MB.Library.Recovery.EnterSafeMode()
    MB.Library.Log("Entering safe mode")
    
    for _, hookName in ipairs({"Think", "Tick", "PlayerTick"}) do
        local hooksToRemove = {}
        
        for hookId, _ in pairs(hook.GetTable()[hookName] or {}) do
            if not string.find(hookId, "^MB%.") then
                table.insert(hooksToRemove, hookId)
            end
        end
        
        for _, hookId in ipairs(hooksToRemove) do
            hook.Remove(hookName, hookId)
            MB.Library.Log("Removed hook: " .. hookName .. "." .. hookId)
        end
    end
    
    local timersToRemove = {}
    
    for timerName, _ in pairs(timer.GetTable()) do
        if not string.find(timerName, "^MB%.") then
            table.insert(timersToRemove, timerName)
        end
    end
    
    for _, timerName in ipairs(timersToRemove) do
        timer.Remove(timerName)
        MB.Library.Log("Removed timer: " .. timerName)
    end
    
    for _, ply in ipairs(player.GetAll()) do
        if ply:IsAdmin() then
            ply:ChatPrint("[MB-Library] Server entered safe mode due to multiple crashes")
        end
    end
end

function MB.Library.Recovery.GetCrashLogs(callback)
    MB.Library.Database.Query("SELECT * FROM mb_crash_logs ORDER BY timestamp DESC", function(data)
        local logs = {}
        
        if data then
            for _, log in ipairs(data) do
                table.insert(logs, {
                    id = log.id,
                    timestamp = log.timestamp,
                    error = log.error,
                    stackTrace = log.stack_trace,
                    serverState = util.JSONToTable(log.server_state or "{}") or {},
                    recovered = log.recovered
                })
            end
        end
        
        if callback then callback(logs) end
    end)
end

function MB.Library.Recovery.CleanupOldCrashLogs()
    local files = file.Find("mb_library/crash_logs/*.json", "DATA")
    
    if #files > MB.Library.Recovery.MaxCrashLogs then
        table.sort(files, function(a, b)
            local timeA = tonumber(string.match(a, "crash_(%d+)")) or 0
            local timeB = tonumber(string.match(b, "crash_(%d+)")) or 0
            return timeA < timeB
        end)
        
        for i = 1, #files - MB.Library.Recovery.MaxCrashLogs do
            file.Delete("mb_library/crash_logs/" .. files[i])
        end
    end
    
    MB.Library.Database.Query("DELETE FROM mb_crash_logs WHERE timestamp < DATE_SUB(NOW(), INTERVAL 30 DAY)")
end

hook.Add("ShutDown", "MB.Library.Recovery.CleanShutdown", function()
    file.Delete("mb_library/server_running.txt")
    MB.Library.Log("Server shutting down cleanly")
end)

hook.Add("DatabaseInitialized", "MB.Library.Recovery.Initialize", MB.Library.Recovery.Initialize) 