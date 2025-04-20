MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Modular = MB.Library.Modular or {}
MB.Library.Modular.Modules = MB.Library.Modular.Modules or {}

function MB.Library.Modular.Initialize()
    MB.Library.Log("Modular system initialized")
end

function MB.Library.Modular.RegisterModule(name, moduleTable)
    if not name or not moduleTable then
        MB.Library.Log("Failed to register module: Invalid parameters", "error")
        return false
    end
    
    if MB.Library.Modular.Modules[name] then
        MB.Library.Log("Module already registered: " .. name, "warning")
        return false
    end
    
    MB.Library.Modular.Modules[name] = moduleTable
    
    if moduleTable.Initialize and type(moduleTable.Initialize) == "function" then
        moduleTable.Initialize()
    end
    
    MB.Library.Log("Registered module: " .. name)
    return true
end

function MB.Library.Modular.GetModule(name)
    return MB.Library.Modular.Modules[name]
end

function MB.Library.Modular.IsModuleRegistered(name)
    return MB.Library.Modular.Modules[name] ~= nil
end

function MB.Library.Modular.LoadModuleFromFile(path)
    return false
end

hook.Add("MB.Library.Initialize", "MB.Library.Modular.Init", function()
    MB.Library.Modular.Initialize()
end) 