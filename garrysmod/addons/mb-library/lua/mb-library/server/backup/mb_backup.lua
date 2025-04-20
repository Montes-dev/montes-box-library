MB.Library.Backup = MB.Library.Backup or {}
MB.Library.Backup.Settings = MB.Library.Backup.Settings or {
    Enabled = true,
    AutoBackup = true,
    BackupInterval = 86400, 
    MaxBackups = 7,
    BackupPath = "mb_library/backups/"
}

function MB.Library.Backup.Initialize()
    file.CreateDir("mb_library")
    file.CreateDir("mb_library/backups")
    
    if MB.Library.Backup.Settings.AutoBackup then
        timer.Create("MB.Library.Backup.Auto", MB.Library.Backup.Settings.BackupInterval, 0, function()
            MB.Library.Backup.Create("auto_" .. os.date("%Y%m%d_%H%M%S"))
        end)
    end
    
    MB.Library.Log("Backup system initialized")
end

function MB.Library.Backup.Create(name)
    if not MB.Library.Backup.Settings.Enabled then
        MB.Library.Log("Backup system is disabled")
        return false
    end
    
    local timestamp = os.time()
    name = name or "backup_" .. timestamp
    
    local backupData = {
        timestamp = timestamp,
        name = name,
        database = {}
    }
    
    local path = MB.Library.Backup.Settings.BackupPath .. name .. ".json"
    
    MB.Library.Log("Creating backup: " .. name)
    
    MB.Library.Database.Query("SHOW TABLES", function(tables)
        if not tables then
            MB.Library.Log("No tables found for backup")
            return
        end
        
        local tablesProcessed = 0
        local totalTables = #tables
        
        for _, tableData in ipairs(tables) do
            local tableName = tableData.Tables_in_mblib
            
            if tableName then
                MB.Library.Database.Query("SELECT * FROM " .. tableName, function(data)
                    tablesProcessed = tablesProcessed + 1
                    
                    if data then
                        backupData.database[tableName] = data
                    end
                    
                    if tablesProcessed >= totalTables then
                        file.Write(path, util.TableToJSON(backupData, true))
                        MB.Library.Log("Backup completed: " .. name)
                        MB.Library.Backup.CleanOldBackups()
                    end
                end)
            else
                tablesProcessed = tablesProcessed + 1
            end
        end
    end)
    
    return true
end

function MB.Library.Backup.CleanOldBackups()
    local backups = MB.Library.Backup.GetBackups()
    
    if #backups > MB.Library.Backup.Settings.MaxBackups then
        table.SortByMember(backups, "timestamp", true)
        
        local toRemove = {}
        for i = MB.Library.Backup.Settings.MaxBackups + 1, #backups do
            table.insert(toRemove, backups[i].name)
        end
        
        for _, name in ipairs(toRemove) do
            MB.Library.Backup.Delete(name)
        end
    end
end

function MB.Library.Backup.GetBackups()
    local backups = {}
    local files = file.Find(MB.Library.Backup.Settings.BackupPath .. "*.json", "DATA")
    
    for _, fileName in ipairs(files) do
        local content = file.Read(MB.Library.Backup.Settings.BackupPath .. fileName, "DATA")
        
        if content then
            local data = util.JSONToTable(content)
            
            if data and data.timestamp and data.name then
                table.insert(backups, {
                    name = data.name,
                    timestamp = data.timestamp,
                    size = #content,
                    fileName = fileName
                })
            end
        end
    end
    
    return backups
end

function MB.Library.Backup.Delete(name)
    local path = MB.Library.Backup.Settings.BackupPath .. name .. ".json"
    
    if file.Exists(path, "DATA") then
        file.Delete(path)
        MB.Library.Log("Deleted backup: " .. name)
        return true
    end
    
    return false
end

function MB.Library.Backup.Restore(name)
    local path = MB.Library.Backup.Settings.BackupPath .. name .. ".json"
    
    if not file.Exists(path, "DATA") then
        MB.Library.Log("Backup not found: " .. name)
        return false
    end
    
    local content = file.Read(path, "DATA")
    
    if not content then
        MB.Library.Log("Failed to read backup: " .. name)
        return false
    end
    
    local data = util.JSONToTable(content)
    
    if not data or not data.database then
        MB.Library.Log("Invalid backup data: " .. name)
        return false
    end
    
    MB.Library.Log("Restoring backup: " .. name)
    
    for tableName, tableData in pairs(data.database) do
        MB.Library.Database.Query("TRUNCATE TABLE " .. tableName, function()
            if #tableData > 0 then
                for _, row in ipairs(tableData) do
                    local columns = {}
                    local values = {}
                    local placeholders = {}
                    
                    for column, value in pairs(row) do
                        table.insert(columns, column)
                        table.insert(values, value)
                        table.insert(placeholders, "?")
                    end
                    
                    local query = "INSERT INTO " .. tableName .. " (" .. table.concat(columns, ", ") .. ") VALUES (" .. table.concat(placeholders, ", ") .. ")"
                    MB.Library.Database.Prepare(query, values)
                end
            end
        end)
    end
    
    MB.Library.Log("Backup restoration completed: " .. name)
    return true
end

hook.Add("Initialize", "MB.Library.Backup.Init", MB.Library.Backup.Initialize) 