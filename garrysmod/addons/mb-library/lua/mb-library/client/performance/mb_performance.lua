MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Performance = MB.Library.Performance or {}

MB.Library.Performance.Metrics = {
    fps = {},
    memory = {},
    renderTime = {},
    thinkTime = {}
}

MB.Library.Performance.Settings = {
    autoOptimize = true,
    targetFPS = 60,
    maxSamples = 100,
    lod = 2,  -- Level of detail: 1 = low, 2 = medium, 3 = high
    maxParticles = 1000,
    maxEffects = 100,
    optimizeNetworking = true,
    optimizeRendering = true,
    optimizeCalculations = true
}

function MB.Library.Performance.Initialize()
    MB.Library.Performance.StartMonitoring()
    
    if MB.Library.Settings then
        MB.Library.Performance.RegisterSettings()
    end
    
    MB.Library.Log("Performance module initialized")
end

function MB.Library.Performance.RegisterSettings()
    MB.Library.Settings.RegisterCategory("performance", {
        name = "Performance",
        icon = "icon16/chart_bar.png",
        order = 500
    })
    
    MB.Library.Settings.Register("performance.autoOptimize", true, {
        name = "Auto Optimize",
        description = "Automatically adjust graphics settings for best performance",
        category = "performance",
        type = "boolean"
    })
    
    MB.Library.Settings.Register("performance.targetFPS", 60, {
        name = "Target FPS",
        description = "Target frames per second to maintain",
        category = "performance",
        type = "number",
        min = 30,
        max = 300
    })
    
    MB.Library.Settings.Register("performance.lod", 2, {
        name = "Level of Detail",
        description = "Visual quality level (lower = better performance)",
        category = "performance",
        type = "number",
        min = 1,
        max = 3
    })
    
    MB.Library.Settings.Register("performance.maxParticles", 1000, {
        name = "Maximum Particles",
        description = "Maximum number of particles to render",
        category = "performance",
        type = "number",
        min = 0,
        max = 5000
    })
end

function MB.Library.Performance.StartMonitoring()
    hook.Add("Think", "MB.Library.Performance.Monitor", MB.Library.Performance.Monitor)
    MB.Library.Log("Performance monitoring started")
end

function MB.Library.Performance.StopMonitoring()
    hook.Remove("Think", "MB.Library.Performance.Monitor")
    MB.Library.Log("Performance monitoring stopped")
end

function MB.Library.Performance.Monitor()
    local currentTime = SysTime()
    
    if not MB.Library.Performance.LastThinkTime then
        MB.Library.Performance.LastThinkTime = currentTime
        return
    end
    
    local frameTime = 1 / math.max(0.001, RealFrameTime())
    local memoryUsed = collectgarbage("count")
    local thinkTime = currentTime - MB.Library.Performance.LastThinkTime
    
    MB.Library.Performance.LastThinkTime = currentTime
    
    table.insert(MB.Library.Performance.Metrics.fps, frameTime)
    table.insert(MB.Library.Performance.Metrics.memory, memoryUsed)
    table.insert(MB.Library.Performance.Metrics.thinkTime, thinkTime * 1000)  -- Convert to ms
    
    if #MB.Library.Performance.Metrics.fps > MB.Library.Performance.Settings.maxSamples then
        table.remove(MB.Library.Performance.Metrics.fps, 1)
        table.remove(MB.Library.Performance.Metrics.memory, 1)
        table.remove(MB.Library.Performance.Metrics.thinkTime, 1)
    end
    
    if MB.Library.Performance.Settings.autoOptimize and (#MB.Library.Performance.Metrics.fps % 30 == 0) then
        MB.Library.Performance.OptimizeIfNeeded()
    end
end

function MB.Library.Performance.GetAverageFPS()
    local sum = 0
    local count = #MB.Library.Performance.Metrics.fps
    
    if count == 0 then return 0 end
    
    for _, fps in ipairs(MB.Library.Performance.Metrics.fps) do
        sum = sum + fps
    end
    
    return sum / count
end

function MB.Library.Performance.GetAverageMemory()
    local sum = 0
    local count = #MB.Library.Performance.Metrics.memory
    
    if count == 0 then return 0 end
    
    for _, memory in ipairs(MB.Library.Performance.Metrics.memory) do
        sum = sum + memory
    end
    
    return sum / count
end

function MB.Library.Performance.GetAverageThinkTime()
    local sum = 0
    local count = #MB.Library.Performance.Metrics.thinkTime
    
    if count == 0 then return 0 end
    
    for _, time in ipairs(MB.Library.Performance.Metrics.thinkTime) do
        sum = sum + time
    end
    
    return sum / count
end

function MB.Library.Performance.GetPerformanceStatus()
    local avgFPS = MB.Library.Performance.GetAverageFPS()
    
    if avgFPS >= MB.Library.Performance.Settings.targetFPS * 1.2 then
        return "excellent"
    elseif avgFPS >= MB.Library.Performance.Settings.targetFPS then
        return "good"
    elseif avgFPS >= MB.Library.Performance.Settings.targetFPS * 0.8 then
        return "average"
    else
        return "poor"
    end
end

function MB.Library.Performance.OptimizeIfNeeded()
    local avgFPS = MB.Library.Performance.GetAverageFPS()
    local targetFPS = MB.Library.Performance.Settings.targetFPS
    
    if avgFPS < targetFPS * 0.8 then
        MB.Library.Performance.OptimizeForPerformance()
    elseif avgFPS > targetFPS * 1.2 and MB.Library.Performance.Settings.lod < 3 then
        MB.Library.Performance.OptimizeForQuality()
    end
end

function MB.Library.Performance.OptimizeForPerformance()
    local currentLOD = MB.Library.Performance.Settings.lod
    
    if currentLOD > 1 then
        MB.Library.Performance.Settings.lod = currentLOD - 1
        MB.Library.Performance.ApplyLODSettings(MB.Library.Performance.Settings.lod)
        MB.Library.Log("Optimizing for performance: Reducing graphics quality to level " .. MB.Library.Performance.Settings.lod)
    end
    
    collectgarbage("collect")
end

function MB.Library.Performance.OptimizeForQuality()
    local currentLOD = MB.Library.Performance.Settings.lod
    
    if currentLOD < 3 then
        MB.Library.Performance.Settings.lod = currentLOD + 1
        MB.Library.Performance.ApplyLODSettings(MB.Library.Performance.Settings.lod)
        MB.Library.Log("Optimizing for quality: Increasing graphics quality to level " .. MB.Library.Performance.Settings.lod)
    end
end

function MB.Library.Performance.ApplyLODSettings(level)
    if level == 1 then  -- Low quality
        MB.Library.Performance.Settings.maxParticles = 200
        MB.Library.Performance.Settings.maxEffects = 20
        RunConsoleCommand("gmod_mcore_test", "1")
        RunConsoleCommand("mat_picmip", "2")
        RunConsoleCommand("r_shadows", "0")
        RunConsoleCommand("cl_detaildist", "1200")
        RunConsoleCommand("cl_particlefile", "particles_low.pcf")
    elseif level == 2 then  -- Medium quality
        MB.Library.Performance.Settings.maxParticles = 1000
        MB.Library.Performance.Settings.maxEffects = 100
        RunConsoleCommand("gmod_mcore_test", "1")
        RunConsoleCommand("mat_picmip", "1")
        RunConsoleCommand("r_shadows", "1")
        RunConsoleCommand("cl_detaildist", "1600")
        RunConsoleCommand("cl_particlefile", "particles_medium.pcf")
    else  -- High quality
        MB.Library.Performance.Settings.maxParticles = 5000
        MB.Library.Performance.Settings.maxEffects = 500
        RunConsoleCommand("gmod_mcore_test", "0")
        RunConsoleCommand("mat_picmip", "0")
        RunConsoleCommand("r_shadows", "1")
        RunConsoleCommand("cl_detaildist", "2000")
        RunConsoleCommand("cl_particlefile", "particles_high.pcf")
    end
    
    if MB.Library.Settings then
        MB.Library.Settings.Set("performance.lod", level)
        MB.Library.Settings.Set("performance.maxParticles", MB.Library.Performance.Settings.maxParticles)
    end
    
    hook.Run("MB.Library.Performance.LODChanged", level)
end

function MB.Library.Performance.GetMetrics()
    return {
        fps = MB.Library.Performance.GetAverageFPS(),
        memory = MB.Library.Performance.GetAverageMemory(),
        thinkTime = MB.Library.Performance.GetAverageThinkTime(),
        status = MB.Library.Performance.GetPerformanceStatus(),
        lod = MB.Library.Performance.Settings.lod
    }
end

hook.Add("Initialize", "MB.Library.Performance.Initialize", MB.Library.Performance.Initialize) 