MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Compatibility = MB.Library.Compatibility or {}
MB.Library.Compatibility.DetectedGModVersion = nil
MB.Library.Compatibility.LowEndMode = false

function MB.Library.Compatibility.Initialize()
    MB.Library.Compatibility.DetectGModVersion()
    
    MB.Library.Compatibility.DetectLowEndSystem()
    
    MB.Library.Log("Compatibility module initialized")
end

function MB.Library.Compatibility.DetectGModVersion()
    local version = VERSION or 0
    MB.Library.Compatibility.DetectedGModVersion = version
    MB.Library.Log("Detected Garry's Mod version: " .. tostring(version))
    return version
end

function MB.Library.Compatibility.DetectLowEndSystem()
    local fps = 1 / FrameTime()
    local lowEnd = fps < 30
    
    if lowEnd then
        MB.Library.Log("Low-end system detected, enabling optimizations")
        MB.Library.Compatibility.EnableLowEndMode()
    end
    
    return lowEnd
end

function MB.Library.Compatibility.EnableLowEndMode()
    MB.Library.Compatibility.LowEndMode = true
    
    hook.Run("MB.Library.LowEndModeEnabled")
end

function MB.Library.Compatibility.DisableLowEndMode()
    MB.Library.Compatibility.LowEndMode = false
    
    hook.Run("MB.Library.LowEndModeDisabled")
end

function MB.Library.Compatibility.IsLowEndMode()
    return MB.Library.Compatibility.LowEndMode
end

hook.Add("MB.Library.Initialize", "MB.Library.Compatibility.Init", function()
    MB.Library.Compatibility.Initialize()
end) 