MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Localization = MB.Library.Localization or {}

MB.Library.Localization.Languages = {
    ["en"] = {
        name = "English",
        native = "English",
        author = "MontesBox Team",
        strings = {}
    },
    ["ru"] = {
        name = "Russian",
        native = "Русский",
        author = "MontesBox Team",
        strings = {}
    }
}

MB.Library.Localization.CurrentLanguage = "en"
MB.Library.Localization.FallbackLanguage = "en"

function MB.Library.Localization.Initialize()
    MB.Library.Localization.DetectLanguage()
    MB.Library.Log("Localization module initialized")
end

function MB.Library.Localization.DetectLanguage()
    local gmodLang = GetConVar("gmod_language"):GetString() or "en"
    
    if MB.Library.Localization.Languages[gmodLang] then
        MB.Library.Localization.SetLanguage(gmodLang)
    else
        MB.Library.Localization.SetLanguage(MB.Library.Localization.FallbackLanguage)
    end
end

function MB.Library.Localization.SetLanguage(lang)
    if not MB.Library.Localization.Languages[lang] then
        MB.Library.Log("Language '" .. lang .. "' not available, using fallback", "warning")
        lang = MB.Library.Localization.FallbackLanguage
    end
    
    local oldLang = MB.Library.Localization.CurrentLanguage
    MB.Library.Localization.CurrentLanguage = lang
    
    MB.Library.Log("Language changed from '" .. oldLang .. "' to '" .. lang .. "'")
    hook.Run("MB.Library.Localization.LanguageChanged", oldLang, lang)
    
    return true
end

function MB.Library.Localization.GetLanguage()
    return MB.Library.Localization.CurrentLanguage
end

function MB.Library.Localization.RegisterLanguage(langCode, langData)
    if not langCode or not langData then return false end
    
    if not langData.name then
        MB.Library.Log("Invalid language data for '" .. langCode .. "'", "error")
        return false
    end
    
    MB.Library.Localization.Languages[langCode] = langData
    MB.Library.Log("Registered language: " .. langData.name .. " (" .. langCode .. ")")
    
    return true
end

function MB.Library.Localization.AddStrings(langCode, strings)
    if not langCode or not strings or type(strings) ~= "table" then return false end
    
    local language = MB.Library.Localization.Languages[langCode]
    if not language then
        MB.Library.Log("Language '" .. langCode .. "' not found", "error")
        return false
    end
    
    for key, value in pairs(strings) do
        language.strings[key] = value
    end
    
    return true
end

function MB.Library.Localization.LoadFromFile(filePath)
    if not file.Exists(filePath, "DATA") then
        MB.Library.Log("Language file not found: " .. filePath, "error")
        return false
    end
    
    local content = file.Read(filePath, "DATA")
    if not content then
        MB.Library.Log("Failed to read language file: " .. filePath, "error")
        return false
    end
    
    local data = util.JSONToTable(content)
    if not data or not data.langCode or not data.strings then
        MB.Library.Log("Invalid language file format: " .. filePath, "error")
        return false
    end
    
    return MB.Library.Localization.AddStrings(data.langCode, data.strings)
end

function MB.Library.Localization.Get(key, ...)
    local args = {...}
    
    local language = MB.Library.Localization.Languages[MB.Library.Localization.CurrentLanguage]
    local fallback = MB.Library.Localization.Languages[MB.Library.Localization.FallbackLanguage]
    
    local str = language.strings[key]
    
    if not str and fallback then
        str = fallback.strings[key]
    end
    
    if not str then
        return key
    end
    
    if #args > 0 then
        local success, result = pcall(string.format, str, unpack(args))
        if success then
            return result
        else
            MB.Library.Log("Format error for string '" .. key .. "': " .. result, "warning")
            return str
        end
    end
    
    return str
end

MB.Library.L = MB.Library.Localization.Get

function MB.Library.Localization.GetAvailableLanguages()
    local result = {}
    
    for code, data in pairs(MB.Library.Localization.Languages) do
        table.insert(result, {
            code = code,
            name = data.name,
            native = data.native
        })
    end
    
    return result
end

function MB.Library.Localization.GetLanguageInfo(langCode)
    return MB.Library.Localization.Languages[langCode]
end

hook.Add("Initialize", "MB.Library.Localization.Initialize", MB.Library.Localization.Initialize) 