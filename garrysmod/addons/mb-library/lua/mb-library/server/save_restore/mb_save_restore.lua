MB.Library.SaveRestore = MB.Library.SaveRestore or {}
MB.Library.SaveRestore.SavedData = MB.Library.SaveRestore.SavedData or {}
MB.Library.SaveRestore.SavePath = "mb_library/saves/"

function MB.Library.SaveRestore.Initialize()
    file.CreateDir("mb_library")
    file.CreateDir("mb_library/saves")
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_save_states (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL UNIQUE,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            data TEXT
        )
    ]])
    
    MB.Library.Log("Save/Restore system initialized")
end

function MB.Library.SaveRestore.RegisterData(category, identifier, getData, setData)
    if not category or not identifier then
        MB.Library.Log("Category and identifier are required for registering saveable data")
        return false
    end
    
    if not getData or type(getData) != "function" then
        MB.Library.Log("getData function is required for registering saveable data")
        return false
    end
    
    local key = category .. "." .. identifier
    
    MB.Library.SaveRestore.SavedData[key] = {
        category = category,
        identifier = identifier,
        getData = getData,
        setData = setData
    }
    
    return true
end

function MB.Library.SaveRestore.UnregisterData(category, identifier)
    local key = category .. "." .. identifier
    
    if MB.Library.SaveRestore.SavedData[key] then
        MB.Library.SaveRestore.SavedData[key] = nil
        return true
    end
    
    return false
end

function MB.Library.SaveRestore.GetRegisteredData()
    local categories = {}
    
    for key, data in pairs(MB.Library.SaveRestore.SavedData) do
        if not categories[data.category] then
            categories[data.category] = {}
        end
        
        table.insert(categories[data.category], data.identifier)
    end
    
    return categories
end

function MB.Library.SaveRestore.CreateSnapshot(name, description, callback)
    if not name or name == "" then
        if callback then callback(false, "Save name cannot be empty") end
        return false
    end
    
    local saveData = {}
    
    for key, data in pairs(MB.Library.SaveRestore.SavedData) do
        local success, result = pcall(data.getData)
        
        if success and result != nil then
            saveData[key] = result
        end
    end
    
    local saveJson = util.TableToJSON(saveData)
    
    MB.Library.Database.Prepare(
        "INSERT INTO mb_save_states (name, description, data) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE description = VALUES(description), data = VALUES(data), created_at = CURRENT_TIMESTAMP",
        {name, description or "", saveJson},
        function(data)
            if not data then
                if callback then callback(false, "Failed to save state to database") end
                return
            end
            
            file.Write(MB.Library.SaveRestore.SavePath .. name .. ".json", saveJson)
            
            if callback then callback(true) end
            MB.Library.Log("State saved: " .. name)
        end,
        function(err)
            if callback then callback(false, err) end
            MB.Library.Log("Error saving state: " .. err)
        end
    )
    
    return true
end

function MB.Library.SaveRestore.RestoreSnapshot(name, callback)
    MB.Library.Database.Prepare(
        "SELECT data FROM mb_save_states WHERE name = ?",
        {name},
        function(data)
            if not data or not data[1] or not data[1].data then
                if file.Exists(MB.Library.SaveRestore.SavePath .. name .. ".json", "DATA") then
                    local fileData = file.Read(MB.Library.SaveRestore.SavePath .. name .. ".json", "DATA")
                    
                    if fileData then
                        MB.Library.SaveRestore.ApplySnapshot(fileData, callback)
                        return
                    end
                end
                
                if callback then callback(false, "Save state not found") end
                return
            end
            
            MB.Library.SaveRestore.ApplySnapshot(data[1].data, callback)
        end,
        function(err)
            if callback then callback(false, err) end
            MB.Library.Log("Error loading state: " .. err)
        end
    )
    
    return true
end

function MB.Library.SaveRestore.ApplySnapshot(jsonData, callback)
    local success, saveData = pcall(util.JSONToTable, jsonData)
    
    if not success or not saveData then
        if callback then callback(false, "Invalid save data") end
        MB.Library.Log("Error applying state: Invalid save data")
        return false
    end
    
    local appliedCount = 0
    local errorCount = 0
    
    for key, value in pairs(saveData) do
        if MB.Library.SaveRestore.SavedData[key] and MB.Library.SaveRestore.SavedData[key].setData then
            local success = pcall(MB.Library.SaveRestore.SavedData[key].setData, value)
            
            if success then
                appliedCount = appliedCount + 1
            else
                errorCount = errorCount + 1
            end
        end
    end
    
    if callback then
        callback(errorCount == 0, "Restored " .. appliedCount .. " items" .. (errorCount > 0 and ", " .. errorCount .. " errors" or ""))
    end
    
    MB.Library.Log("State restored: " .. appliedCount .. " items applied, " .. errorCount .. " errors")
    
    return true
end

function MB.Library.SaveRestore.DeleteSnapshot(name, callback)
    MB.Library.Database.Prepare(
        "DELETE FROM mb_save_states WHERE name = ?",
        {name},
        function(data)
            if file.Exists(MB.Library.SaveRestore.SavePath .. name .. ".json", "DATA") then
                file.Delete(MB.Library.SaveRestore.SavePath .. name .. ".json")
            end
            
            if callback then callback(true) end
            MB.Library.Log("State deleted: " .. name)
        end,
        function(err)
            if callback then callback(false, err) end
            MB.Library.Log("Error deleting state: " .. err)
        end
    )
    
    return true
end

function MB.Library.SaveRestore.GetAllSnapshots(callback)
    MB.Library.Database.Query(
        "SELECT id, name, description, created_at FROM mb_save_states ORDER BY created_at DESC",
        function(data)
            local snapshots = {}
            
            if data then
                for _, snapshot in ipairs(data) do
                    table.insert(snapshots, {
                        id = snapshot.id,
                        name = snapshot.name,
                        description = snapshot.description,
                        createdAt = snapshot.created_at
                    })
                end
            end
            
            local files = file.Find(MB.Library.SaveRestore.SavePath .. "*.json", "DATA")
            
            for _, fileName in ipairs(files) do
                local name = string.StripExtension(fileName)
                local found = false
                
                for _, snapshot in ipairs(snapshots) do
                    if snapshot.name == name then
                        found = true
                        break
                    end
                end
                
                if not found then
                    table.insert(snapshots, {
                        id = nil,
                        name = name,
                        description = "File-only save",
                        createdAt = "Unknown"
                    })
                end
            end
            
            if callback then callback(snapshots) end
        end,
        function(err)
            if callback then callback({}) end
            MB.Library.Log("Error getting snapshots: " .. err)
        end
    )
end

hook.Add("DatabaseInitialized", "MB.Library.SaveRestore.Initialize", MB.Library.SaveRestore.Initialize)

MB.Library.SaveRestore.RegisterData("server", "settings", function()
    return {
        serverName = GetHostName(),
        maxPlayers = game.MaxPlayers(),
        mapCycle = string.Explode(",", game.GetMapCycle())
    }
end) 