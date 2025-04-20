MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Storage = MB.Library.Storage or {}
MB.Library.Storage.Data = MB.Library.Storage.Data or {}

function MB.Library.Storage.Initialize()
    if not file.Exists("mb_library/data", "DATA") then
        file.CreateDir("mb_library/data")
    end
    
    MB.Library.Log("Storage module initialized")
end

function MB.Library.Storage.SaveToFile(fileName, data)
    if not fileName or not data then
        MB.Library.Log("Failed to save data: Invalid parameters", "error")
        return false
    end
    
    if not string.EndsWith(fileName, ".json") then
        fileName = fileName .. ".json"
    end
    
    local directory = "mb_library/data/"
    if not file.Exists(directory, "DATA") then
        file.CreateDir(directory)
    end
    
    local jsonData
    if type(data) == "table" then
        jsonData = util.TableToJSON(data, true)
    else
        jsonData = tostring(data)
    end
    
    file.Write(directory .. fileName, jsonData)
    
    MB.Library.Log("Saved data to file: " .. fileName)
    return true
end

function MB.Library.Storage.LoadFromFile(fileName)
    if not fileName then
        MB.Library.Log("Failed to load data: Invalid parameters", "error")
        return nil
    end
    
    if not string.EndsWith(fileName, ".json") then
        fileName = fileName .. ".json"
    end
    
    local directory = "mb_library/data/"
    local fullPath = directory .. fileName
    
    if not file.Exists(fullPath, "DATA") then
        MB.Library.Log("File does not exist: " .. fileName, "warning")
        return nil
    end
    
    local jsonData = file.Read(fullPath, "DATA")
    if not jsonData then
        MB.Library.Log("Failed to read file: " .. fileName, "error")
        return nil
    end
    
    local data = util.JSONToTable(jsonData)
    if not data then
        MB.Library.Log("Failed to parse JSON data from file: " .. fileName, "error")
        return nil
    end
    
    MB.Library.Log("Loaded data from file: " .. fileName)
    return data
end

function MB.Library.Storage.DeleteFile(fileName)
    if not fileName then
        MB.Library.Log("Failed to delete file: Invalid parameters", "error")
        return false
    end
    
    if not string.EndsWith(fileName, ".json") then
        fileName = fileName .. ".json"
    end
    
    local directory = "mb_library/data/"
    local fullPath = directory .. fileName
    
    if not file.Exists(fullPath, "DATA") then
        MB.Library.Log("File does not exist: " .. fileName, "warning")
        return false
    end
    
    file.Delete(fullPath)
    
    MB.Library.Log("Deleted file: " .. fileName)
    return true
end

hook.Add("MB.Library.Initialize", "MB.Library.Storage.Init", function()
    MB.Library.Storage.Initialize()
end) 