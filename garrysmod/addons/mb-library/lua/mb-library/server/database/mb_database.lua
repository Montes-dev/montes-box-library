MB.Library.Database = MB.Library.Database or {}

require("mysqloo")

local db = nil

function MB.Library.Database.Initialize()
    if not DBConfig.EnableMySQL then
        MB.Library.Log("MySQL is disabled in configuration. Using SQLite instead.")
        return false
    end

    if not mysqloo then
        MB.Library.Log("MySQL module not found!")
        return false
    end
    
    if mysqloo.VERSION != "9" then
        MB.Library.Log("Outdated MySQL version detected. Please update to version 9.")
        return false
    end
    
    if not DBConfig then
        MB.Library.Log("Database configuration not found!")
        return false
    end
    
    db = mysqloo.connect(
        DBConfig.Host,
        DBConfig.Username,
        DBConfig.Password,
        DBConfig.Database_name,
        DBConfig.Database_port
    )
    
    db.onConnectionFailed = function(_, err)
        MB.Library.Log("Database connection failed: " .. err)
        timer.Simple(5, MB.Library.Database.Initialize)
    end
    
    db.onConnected = function()
        MB.Library.Log("Database connection established")
        MB.Library.Database.Setup()
        hook.Run("MB.DatabaseInitialized")
    end
    
    db:connect()
    return true
end

function MB.Library.Database.Query(query, callback, errorCallback)
    if not db then
        MB.Library.Log("Database not initialized")
        return
    end
    
    local q = db:query(query)
    
    q.onSuccess = function(_, data)
        if callback then
            callback(data, q)
        end
    end
    
    q.onError = function(_, err, sql)
        if errorCallback then
            errorCallback(err, sql)
        else
            MB.Library.Log("MySQL Error: " .. err .. " (Query: " .. query .. ")")
        end
    end
    
    q:start()
    return q
end

function MB.Library.Database.Prepare(query, parameters, callback, errorCallback)
    if not db then
        MB.Library.Log("Database not initialized")
        return
    end
    
    local q = db:prepare(query)
    
    q.onSuccess = function(_, data)
        if callback then
            callback(data, q)
        end
    end
    
    q.onError = function(_, err, sql)
        if errorCallback then
            errorCallback(err, sql)
        else
            MB.Library.Log("MySQL Error: " .. err .. " (Query: " .. query .. ")")
        end
    end
    
    for k, v in pairs(parameters) do
        local paramType = type(v)
        if paramType == "string" then
            q:setString(k, v)
        elseif paramType == "number" then
            q:setNumber(k, v)
        elseif paramType == "boolean" then
            q:setBoolean(k, v)
        else
            q:setString(k, tostring(v))
        end
    end
    
    q:start()
    return q
end

function MB.Library.Database.Escape(str)
    if not db then
        MB.Library.Log("Database not initialized")
        return sql.SQLStr(str)
    end
    
    return db:escape(str)
end

function MB.Library.Database.SQLStr(str)
    return "'" .. MB.Library.Database.Escape(str) .. "'"
end

function MB.Library.Database.LastInsertID()
    if not db then
        MB.Library.Log("Database not initialized")
        return 0
    end
    
    local q = db:query("SELECT LAST_INSERT_ID() as id")
    
    local id = 0
    q.onSuccess = function(_, data)
        if data and data[1] then
            id = tonumber(data[1].id) or 0
        end
    end
    
    q:start()
    q:wait()
    
    return id
end

function MB.Library.Database.Setup()
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            steam_id VARCHAR(32) NOT NULL UNIQUE,
            name VARCHAR(64) NOT NULL,
            first_join TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_join TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            type VARCHAR(32) NOT NULL,
            message TEXT NOT NULL,
            user_id INT,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES mb_users(id) ON DELETE SET NULL
        )
    ]])
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_update_tasks (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL,
            schedule VARCHAR(128) NOT NULL,
            is_enabled BOOLEAN DEFAULT TRUE,
            task_data TEXT,
            last_run TIMESTAMP NULL DEFAULT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_updates (
            id INT AUTO_INCREMENT PRIMARY KEY,
            version VARCHAR(32) NOT NULL,
            description TEXT,
            is_successful BOOLEAN DEFAULT TRUE,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_save_states (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL UNIQUE,
            description TEXT,
            data LONGTEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_crash_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            timestamp TIMESTAMP NOT NULL,
            error TEXT NOT NULL,
            stack_trace TEXT,
            server_state LONGTEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_message_templates (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL UNIQUE,
            template TEXT NOT NULL,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_user_groups (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL UNIQUE,
            permissions TEXT NOT NULL,
            color VARCHAR(32),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
end

function MB.Library.Database.Transaction()
    if not db then
        MB.Library.Log("Database not initialized")
        return nil
    end
    
    local transaction = {}
    local dbTransaction = db:createTransaction()
    
    function transaction:Query(query)
        local q = db:query(query)
        dbTransaction:addQuery(q)
        return q
    end
    
    function transaction:Prepare(query, parameters)
        local q = db:prepare(query)
        
        for k, v in pairs(parameters) do
            local paramType = type(v)
            if paramType == "string" then
                q:setString(k, v)
            elseif paramType == "number" then
                q:setNumber(k, v)
            elseif paramType == "boolean" then
                q:setBoolean(k, v)
            else
                q:setString(k, tostring(v))
            end
        end
        
        dbTransaction:addQuery(q)
        return q
    end
    
    function transaction:Start(callback, errorCallback)
        dbTransaction.onSuccess = function()
            if callback then
                callback()
            end
        end
        
        dbTransaction.onError = function(_, err)
            if errorCallback then
                errorCallback(err)
            else
                MB.Library.Log("Transaction Error: " .. err)
            end
        end
        
        dbTransaction:start()
    end
    
    return transaction
end

MB.Library.Database.Initialize() 