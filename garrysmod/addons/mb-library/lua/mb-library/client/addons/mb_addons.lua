MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Addons = MB.Library.Addons or {}

MB.Library.Addons.Registered = {}
MB.Library.Addons.Enabled = {}
MB.Library.Addons.Hooks = {}

function MB.Library.Addons.Initialize()
    MB.Library.Addons.LoadEnabledAddons()
    MB.Library.Log("Addons module initialized")
end

function MB.Library.Addons.Register(id, data)
    if not id or not data then return false end
    
    if not data.name then data.name = id end
    if not data.author then data.author = "Unknown" end
    if not data.version then data.version = "1.0.0" end
    if not data.description then data.description = "" end
    
    data.id = id
    MB.Library.Addons.Registered[id] = data
    
    MB.Library.Log("Registered addon: " .. data.name .. " " .. data.version .. " by " .. data.author)
    return true
end

function MB.Library.Addons.IsRegistered(id)
    return MB.Library.Addons.Registered[id] ~= nil
end

function MB.Library.Addons.Get(id)
    return MB.Library.Addons.Registered[id]
end

function MB.Library.Addons.GetAll()
    return MB.Library.Addons.Registered
end

function MB.Library.Addons.Enable(id)
    if not MB.Library.Addons.IsRegistered(id) then
        MB.Library.Log("Cannot enable unregistered addon: " .. id, "error")
        return false
    end
    
    if MB.Library.Addons.IsEnabled(id) then
        MB.Library.Log("Addon already enabled: " .. id, "warning")
        return true
    end
    
    local addon = MB.Library.Addons.Get(id)
    
    MB.Library.Addons.Enabled[id] = true
    
    if addon.onEnable then
        local success, result = pcall(addon.onEnable)
        
        if not success then
            MB.Library.Log("Error enabling addon " .. id .. ": " .. tostring(result), "error")
            MB.Library.Addons.Enabled[id] = nil
            return false
        end
    end
    
    MB.Library.Log("Enabled addon: " .. addon.name)
    hook.Run("MB.Library.Addons.Enabled", id, addon)
    
    MB.Library.Addons.SaveEnabledAddons()
    return true
end

function MB.Library.Addons.Disable(id)
    if not MB.Library.Addons.IsRegistered(id) then
        MB.Library.Log("Cannot disable unregistered addon: " .. id, "error")
        return false
    end
    
    if not MB.Library.Addons.IsEnabled(id) then
        MB.Library.Log("Addon already disabled: " .. id, "warning")
        return true
    end
    
    local addon = MB.Library.Addons.Get(id)
    
    if addon.onDisable then
        pcall(addon.onDisable)
    end
    
    MB.Library.Addons.Enabled[id] = nil
    MB.Library.Addons.UnregisterHooks(id)
    
    MB.Library.Log("Disabled addon: " .. addon.name)
    hook.Run("MB.Library.Addons.Disabled", id, addon)
    
    MB.Library.Addons.SaveEnabledAddons()
    return true
end

function MB.Library.Addons.IsEnabled(id)
    return MB.Library.Addons.Enabled[id] == true
end

function MB.Library.Addons.RegisterHook(id, hookName, callback)
    if not MB.Library.Addons.IsRegistered(id) then
        MB.Library.Log("Cannot register hook for unregistered addon: " .. id, "error")
        return false
    end
    
    if not MB.Library.Addons.IsEnabled(id) then
        MB.Library.Log("Cannot register hook for disabled addon: " .. id, "warning")
        return false
    end
    
    if not hookName or not callback or type(callback) ~= "function" then
        MB.Library.Log("Invalid hook registration for addon " .. id, "error")
        return false
    end
    
    if not MB.Library.Addons.Hooks[id] then
        MB.Library.Addons.Hooks[id] = {}
    end
    
    local uniqueId = "MB.Library.Addons." .. id .. "." .. hookName
    hook.Add(hookName, uniqueId, callback)
    
    MB.Library.Addons.Hooks[id][hookName] = uniqueId
    return true
end

function MB.Library.Addons.UnregisterHook(id, hookName)
    if not MB.Library.Addons.Hooks[id] or not MB.Library.Addons.Hooks[id][hookName] then
        return false
    end
    
    local uniqueId = MB.Library.Addons.Hooks[id][hookName]
    hook.Remove(hookName, uniqueId)
    
    MB.Library.Addons.Hooks[id][hookName] = nil
    return true
end

function MB.Library.Addons.UnregisterHooks(id)
    if not MB.Library.Addons.Hooks[id] then return end
    
    for hookName, uniqueId in pairs(MB.Library.Addons.Hooks[id]) do
        hook.Remove(hookName, uniqueId)
    end
    
    MB.Library.Addons.Hooks[id] = nil
end

function MB.Library.Addons.SaveEnabledAddons()
    if not file.IsDir("montesbox", "DATA") then
        file.CreateDir("montesbox")
    end
    
    local enabled = {}
    for id, _ in pairs(MB.Library.Addons.Enabled) do
        table.insert(enabled, id)
    end
    
    file.Write("montesbox/enabled_addons.txt", util.TableToJSON(enabled, true))
    MB.Library.Log("Saved enabled addons list")
    
    return true
end

function MB.Library.Addons.LoadEnabledAddons()
    if not file.Exists("montesbox/enabled_addons.txt", "DATA") then
        MB.Library.Log("No enabled addons file found")
        return false
    end
    
    local content = file.Read("montesbox/enabled_addons.txt", "DATA")
    if not content then
        MB.Library.Log("Failed to read enabled addons file", "error")
        return false
    end
    
    local enabled = util.JSONToTable(content)
    if not enabled or type(enabled) ~= "table" then
        MB.Library.Log("Invalid enabled addons file format", "error")
        return false
    end
    
    for _, id in ipairs(enabled) do
        if MB.Library.Addons.IsRegistered(id) then
            MB.Library.Addons.Enable(id)
        end
    end
    
    MB.Library.Log("Loaded enabled addons")
    return true
end

hook.Add("Initialize", "MB.Library.Addons.Initialize", MB.Library.Addons.Initialize) 