MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Settings = MB.Library.Settings or {}

MB.Library.Settings.Values = {}
MB.Library.Settings.Defaults = {}
MB.Library.Settings.Metadata = {}
MB.Library.Settings.Categories = {}

function MB.Library.Settings.Initialize()
    MB.Library.Settings.Load()
    MB.Library.Log("Settings module initialized")
end

function MB.Library.Settings.RegisterCategory(categoryId, categoryData)
    if not categoryId or not categoryData then return false end
    
    MB.Library.Settings.Categories[categoryId] = categoryData
    return true
end

function MB.Library.Settings.Register(key, defaultValue, metadata)
    if not key then return false end
    
    metadata = metadata or {}
    metadata.type = metadata.type or type(defaultValue)
    metadata.name = metadata.name or key
    metadata.description = metadata.description or ""
    metadata.category = metadata.category or "general"
    metadata.order = metadata.order or 100
    metadata.min = metadata.min
    metadata.max = metadata.max
    metadata.options = metadata.options
    metadata.onChange = metadata.onChange
    
    MB.Library.Settings.Defaults[key] = defaultValue
    MB.Library.Settings.Metadata[key] = metadata
    
    if MB.Library.Settings.Values[key] == nil then
        MB.Library.Settings.Values[key] = defaultValue
    end
    
    return true
end

function MB.Library.Settings.Get(key, defaultOverride)
    if MB.Library.Settings.Values[key] ~= nil then
        return MB.Library.Settings.Values[key]
    end
    
    return defaultOverride or MB.Library.Settings.Defaults[key]
end

function MB.Library.Settings.Set(key, value)
    local oldValue = MB.Library.Settings.Values[key]
    local metadata = MB.Library.Settings.Metadata[key]
    
    if metadata then
        if metadata.type == "number" and type(value) == "number" then
            if metadata.min ~= nil then
                value = math.max(metadata.min, value)
            end
            
            if metadata.max ~= nil then
                value = math.min(metadata.max, value)
            end
        elseif metadata.type == "string" and metadata.options and not table.HasValue(metadata.options, value) then
            MB.Library.Log("Invalid option value for setting '" .. key .. "'", "warning")
            return false
        end
    end
    
    MB.Library.Settings.Values[key] = value
    
    if oldValue ~= value and metadata and metadata.onChange then
        metadata.onChange(value, oldValue)
    end
    
    hook.Run("MB.Library.Settings.Changed", key, value, oldValue)
    
    MB.Library.Settings.Save()
    return true
end

function MB.Library.Settings.Reset(key)
    if key then
        MB.Library.Settings.Set(key, MB.Library.Settings.Defaults[key])
    else
        for k, v in pairs(MB.Library.Settings.Defaults) do
            MB.Library.Settings.Set(k, v)
        end
    end
    
    MB.Library.Settings.Save()
    return true
end

function MB.Library.Settings.Save()
    if not file.IsDir("montesbox", "DATA") then
        file.CreateDir("montesbox")
    end
    
    file.Write("montesbox/settings.txt", util.TableToJSON(MB.Library.Settings.Values, true))
    MB.Library.Log("Settings saved")
    
    hook.Run("MB.Library.Settings.Saved")
    return true
end

function MB.Library.Settings.Load()
    if not file.Exists("montesbox/settings.txt", "DATA") then
        MB.Library.Log("No settings file found, using defaults")
        MB.Library.Settings.Reset()
        return false
    end
    
    local content = file.Read("montesbox/settings.txt", "DATA")
    if not content then
        MB.Library.Log("Failed to read settings file", "error")
        return false
    end
    
    local data = util.JSONToTable(content)
    if not data then
        MB.Library.Log("Invalid settings file format", "error")
        return false
    end
    
    for k, v in pairs(data) do
        MB.Library.Settings.Values[k] = v
    end
    
    hook.Run("MB.Library.Settings.Loaded")
    MB.Library.Log("Settings loaded")
    
    return true
end

function MB.Library.Settings.GetMetadata(key)
    return MB.Library.Settings.Metadata[key]
end

function MB.Library.Settings.GetAllMetadata()
    return MB.Library.Settings.Metadata
end

function MB.Library.Settings.GetCategories()
    return MB.Library.Settings.Categories
end

function MB.Library.Settings.GetCategory(categoryId)
    return MB.Library.Settings.Categories[categoryId]
end

function MB.Library.Settings.GetSettingsByCategory(categoryId)
    local result = {}
    
    for key, metadata in pairs(MB.Library.Settings.Metadata) do
        if metadata.category == categoryId then
            table.insert(result, {
                key = key,
                value = MB.Library.Settings.Get(key),
                default = MB.Library.Settings.Defaults[key],
                metadata = metadata
            })
        end
    end
    
    table.sort(result, function(a, b)
        return a.metadata.order < b.metadata.order
    end)
    
    return result
end

hook.Add("Initialize", "MB.Library.Settings.Initialize", MB.Library.Settings.Initialize) 