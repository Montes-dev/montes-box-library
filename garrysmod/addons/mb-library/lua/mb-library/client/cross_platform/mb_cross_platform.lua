MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.CrossPlatform = MB.Library.CrossPlatform or {}

MB.Library.CrossPlatform.Platforms = {
    WINDOWS = 1,
    MAC = 2,
    LINUX = 3
}

MB.Library.CrossPlatform.CurrentPlatform = nil

function MB.Library.CrossPlatform.Initialize()
    MB.Library.CrossPlatform.DetectPlatform()
    MB.Library.Log("Cross Platform module initialized")
end

function MB.Library.CrossPlatform.DetectPlatform()
    local osName = system.IsWindows() and "Windows" or (system.IsOSX() and "macOS" or "Linux")
    
    if system.IsWindows() then
        MB.Library.CrossPlatform.CurrentPlatform = MB.Library.CrossPlatform.Platforms.WINDOWS
    elseif system.IsOSX() then
        MB.Library.CrossPlatform.CurrentPlatform = MB.Library.CrossPlatform.Platforms.MAC
    else
        MB.Library.CrossPlatform.CurrentPlatform = MB.Library.CrossPlatform.Platforms.LINUX
    end
    
    MB.Library.Log("Detected platform: " .. osName)
    return MB.Library.CrossPlatform.CurrentPlatform
end

function MB.Library.CrossPlatform.IsWindows()
    return MB.Library.CrossPlatform.CurrentPlatform == MB.Library.CrossPlatform.Platforms.WINDOWS
end

function MB.Library.CrossPlatform.IsMac()
    return MB.Library.CrossPlatform.CurrentPlatform == MB.Library.CrossPlatform.Platforms.MAC
end

function MB.Library.CrossPlatform.IsLinux()
    return MB.Library.CrossPlatform.CurrentPlatform == MB.Library.CrossPlatform.Platforms.LINUX
end

function MB.Library.CrossPlatform.GetPlatformName()
    if MB.Library.CrossPlatform.IsWindows() then
        return "Windows"
    elseif MB.Library.CrossPlatform.IsMac() then
        return "macOS"
    elseif MB.Library.CrossPlatform.IsLinux() then
        return "Linux"
    else
        return "Unknown"
    end
end

function MB.Library.CrossPlatform.GetUserDataPath()
    if MB.Library.CrossPlatform.IsWindows() then
        return "C:/Users/" .. MB.Library.CrossPlatform.GetUsername() .. "/AppData/Local/MontesBox"
    elseif MB.Library.CrossPlatform.IsMac() then
        return "/Users/" .. MB.Library.CrossPlatform.GetUsername() .. "/Library/Application Support/MontesBox"
    elseif MB.Library.CrossPlatform.IsLinux() then
        return "/home/" .. MB.Library.CrossPlatform.GetUsername() .. "/.montesbox"
    else
        return "montesbox"
    end
end

function MB.Library.CrossPlatform.GetUsername()
    return system.GetUserName() or "unknown"
end

function MB.Library.CrossPlatform.GetKeyboardLayout()
    if MB.Library.CrossPlatform.IsWindows() then
        return "windows"
    elseif MB.Library.CrossPlatform.IsMac() then
        return "mac"
    else
        return "linux"
    end
end

function MB.Library.CrossPlatform.GetSystemLanguage()
    return system.GetCountry() or "en"
end

function MB.Library.CrossPlatform.GetFilePathSeparator()
    if MB.Library.CrossPlatform.IsWindows() then
        return "\\"
    else
        return "/"
    end
end

function MB.Library.CrossPlatform.NormalizePath(path)
    if MB.Library.CrossPlatform.IsWindows() then
        return string.gsub(path, "/", "\\")
    else
        return string.gsub(path, "\\", "/")
    end
end

function MB.Library.CrossPlatform.GetScreenScaling()
    return ScrW() / 1920 
end

function MB.Library.CrossPlatform.GetPerformanceLevel()
    local averageFPS = 1 / RealFrameTime()
    
    if averageFPS >= 120 then
        return "high"
    elseif averageFPS >= 60 then
        return "medium"
    else
        return "low"
    end
end

function MB.Library.CrossPlatform.AdaptInputToDevice(defaultKeys, customBindings)
    local bindings = customBindings or {}
    
    if MB.Library.CrossPlatform.IsMac() then
        if defaultKeys.ctrl then
            bindings.cmd = defaultKeys.ctrl
        end
    end
    
    return bindings
end

function MB.Library.CrossPlatform.AdaptInterfaceToDevice()
    local scaling = MB.Library.CrossPlatform.GetScreenScaling()
    local deviceType = "desktop"
    
    local isMobile = MB.Library.CrossPlatform.IsMobileDevice()
    if isMobile then
        deviceType = "mobile"
    end
    
    return {
        scale = scaling,
        deviceType = deviceType
    }
end

function MB.Library.CrossPlatform.IsMobileDevice()
    return false
end

hook.Add("Initialize", "MB.Library.CrossPlatform.Initialize", MB.Library.CrossPlatform.Initialize) 