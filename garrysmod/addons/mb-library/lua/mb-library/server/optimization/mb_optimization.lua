MB.Library.Optimization = MB.Library.Optimization or {}
MB.Library.Optimization.PerformanceStats = MB.Library.Optimization.PerformanceStats or {}
MB.Library.Optimization.MemoryUsage = MB.Library.Optimization.MemoryUsage or {}
MB.Library.Optimization.Timers = MB.Library.Optimization.Timers or {}

function MB.Library.Optimization.Initialize()
    timer.Create("MB.Library.Optimization.CollectStats", 60, 0, MB.Library.Optimization.CollectStats)
    
    hook.Add("Think", "MB.Library.Optimization.FrameTime", function()
        MB.Library.Optimization.PerformanceStats.CurrentFrameTime = FrameTime()
        MB.Library.Optimization.PerformanceStats.AverageFrameTime = (MB.Library.Optimization.PerformanceStats.AverageFrameTime or FrameTime() * 10) * 0.9 + FrameTime() * 0.1
    end)
    
    MB.Library.Log("Optimization system initialized")
end

function MB.Library.Optimization.CollectStats()
    MB.Library.Optimization.PerformanceStats.ServerTime = SysTime()
    MB.Library.Optimization.PerformanceStats.CurrentTickrate = 1 / engine.TickInterval()
    MB.Library.Optimization.PerformanceStats.PlayerCount = #player.GetAll()
    MB.Library.Optimization.PerformanceStats.EntityCount = #ents.GetAll()
    
    MB.Library.Optimization.CollectMemoryStats()
    
    if MB.Library.Optimization.PerformanceStats.AverageFrameTime > 0.05 then
        MB.Library.Log("Warning: Server frame time is high (" .. string.format("%.2f", MB.Library.Optimization.PerformanceStats.AverageFrameTime * 1000) .. "ms)")
    end
    
    if MB.Library.Optimization.MemoryUsage.Current > 1024 * 1024 * 500 then
        MB.Library.Log("Warning: Server memory usage is high (" .. string.format("%.2f", MB.Library.Optimization.MemoryUsage.Current / (1024 * 1024)) .. " MB)")
    end
    
    MB.Library.Events.Trigger("PerformanceStatsCollected", MB.Library.Optimization.GetStats())
end

function MB.Library.Optimization.CollectMemoryStats()
    if collectgarbage and collectgarbage("count") then
        MB.Library.Optimization.MemoryUsage.Previous = MB.Library.Optimization.MemoryUsage.Current or collectgarbage("count") * 1024
        MB.Library.Optimization.MemoryUsage.Current = collectgarbage("count") * 1024
        MB.Library.Optimization.MemoryUsage.Delta = MB.Library.Optimization.MemoryUsage.Current - MB.Library.Optimization.MemoryUsage.Previous
    end
end

function MB.Library.Optimization.GetStats()
    return {
        performance = table.Copy(MB.Library.Optimization.PerformanceStats),
        memory = table.Copy(MB.Library.Optimization.MemoryUsage),
        timers = table.Copy(MB.Library.Optimization.Timers)
    }
end

function MB.Library.Optimization.OptimizeTimers()
    local timerList = {}
    
    for name, data in pairs(timer.GetTable()) do
        table.insert(timerList, {
            name = name,
            delay = data.Delay,
            repetitions = data.Repetitions,
            nextCall = data.NextCall,
            isRunning = timer.Exists(name)
        })
    end
    
    MB.Library.Optimization.Timers = timerList
    
    return timerList
end

function MB.Library.Optimization.OptimizeEntities()
    local entities = ents.GetAll()
    local farEntities = {}
    local players = player.GetAll()
    
    for _, ent in ipairs(entities) do
        if not IsValid(ent) or ent:IsPlayer() then continue end
        
        local pos = ent:GetPos()
        local isNearPlayer = false
        
        for _, ply in ipairs(players) do
            if pos:DistToSqr(ply:GetPos()) < 1000000 then
                isNearPlayer = true
                break
            end
        end
        
        if not isNearPlayer then
            table.insert(farEntities, ent)
        end
    end
    
    return farEntities
end

function MB.Library.Optimization.ReduceNetworkTraffic(enabled)
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then continue end
        
        ply:SetNWFloat("MB.PerformanceMode", enabled and 1 or 0)
    end
    
    MB.Library.Optimization.PerformanceStats.ReducedNetworkTraffic = enabled
    
    MB.Library.Log("Network traffic optimization " .. (enabled and "enabled" or "disabled"))
end

function MB.Library.Optimization.RunGarbageCollection()
    local startTime = SysTime()
    local startMemory = collectgarbage("count") * 1024
    
    collectgarbage("collect")
    
    local endTime = SysTime()
    local endMemory = collectgarbage("count") * 1024
    local timeTaken = endTime - startTime
    local memoryFreed = startMemory - endMemory
    
    MB.Library.Log("Garbage collection completed in " .. string.format("%.2f", timeTaken * 1000) .. "ms, freed " .. string.format("%.2f", memoryFreed / 1024) .. " KB")
    
    return {
        timeTaken = timeTaken,
        memoryBefore = startMemory,
        memoryAfter = endMemory,
        memoryFreed = memoryFreed
    }
end

function MB.Library.Optimization.OptimizeDatabase()
    MB.Library.Database.Query("ANALYZE TABLE mb_users, mb_logs", function()
        MB.Library.Log("Database tables analyzed")
    end)
    
    MB.Library.Database.Query("OPTIMIZE TABLE mb_users, mb_logs", function()
        MB.Library.Log("Database tables optimized")
    end)
end

function MB.Library.Optimization.TimerWrapper(name, callback, delay, repetitions)
    local wrappedCallback = function(...)
        local startTime = SysTime()
        local success, result = pcall(callback, ...)
        local endTime = SysTime()
        
        if not success then
            MB.Library.Log("Timer error in '" .. name .. "': " .. tostring(result))
        else
            local timeTaken = endTime - startTime
            
            if timeTaken > 0.1 then
                MB.Library.Log("Timer '" .. name .. "' took " .. string.format("%.2f", timeTaken * 1000) .. "ms to execute")
            end
        end
        
        return result
    end
    
    return timer.Create(name, delay, repetitions, wrappedCallback)
end

function MB.Library.Optimization.HookWrapper(eventName, identifier, callback)
    local wrappedCallback = function(...)
        local startTime = SysTime()
        local result = {callback(...)}
        local endTime = SysTime()
        
        local timeTaken = endTime - startTime
        
        if timeTaken > 0.01 then
            MB.Library.Log("Hook '" .. eventName .. "." .. identifier .. "' took " .. string.format("%.2f", timeTaken * 1000) .. "ms to execute")
        end
        
        return unpack(result)
    end
    
    return hook.Add(eventName, identifier, wrappedCallback)
end

hook.Add("Initialize", "MB.Library.Optimization.Initialize", MB.Library.Optimization.Initialize)

MB.Library.Optimization.TimerWrapper("MB.Library.Optimization.PeriodicGC", function()
    MB.Library.Optimization.RunGarbageCollection()
end, 3600, 0) 