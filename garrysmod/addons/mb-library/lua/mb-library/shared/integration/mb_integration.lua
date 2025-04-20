MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Integration = MB.Library.Integration or {}
MB.Library.Integration.RegisteredSystems = MB.Library.Integration.RegisteredSystems or {}

function MB.Library.Integration.Initialize()
    MB.Library.Integration.AutoDetect()
    
    MB.Library.Log("Integration module initialized")
end

function MB.Library.Integration.AutoDetect()
    if ULib then
        MB.Library.Integration.IntegrateWithULX()
    end
    
    if DarkRP then
        MB.Library.Integration.IntegrateWithDarkRP()
    end
    
    if FAdmin then
        MB.Library.Integration.IntegrateWithFAdmin()
    end
end

function MB.Library.Integration.RegisterSystem(name, systemTable)
    if not name or not systemTable then
        MB.Library.Log("Failed to register external system: Invalid parameters", "error")
        return false
    end
    
    if MB.Library.Integration.RegisteredSystems[name] then
        MB.Library.Log("External system already registered: " .. name, "warning")
        return false
    end
    
    MB.Library.Integration.RegisteredSystems[name] = systemTable
    
    MB.Library.Log("Registered external system: " .. name)
    return true
end

function MB.Library.Integration.IntegrateWithULX()
    MB.Library.Log("Integrated with ULX")
end

function MB.Library.Integration.IntegrateWithDarkRP()
    MB.Library.Log("Integrated with DarkRP")
end

function MB.Library.Integration.IntegrateWithFAdmin()
    MB.Library.Log("Integrated with FAdmin")
end

hook.Add("MB.Library.Initialize", "MB.Library.Integration.Init", function()
    MB.Library.Integration.Initialize()
end) 