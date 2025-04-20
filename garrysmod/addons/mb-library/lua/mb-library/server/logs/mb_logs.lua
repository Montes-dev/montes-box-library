MB.Library.Logs = MB.Library.Logs or {}

function MB.Library.Logs.Add(type, message, ply)
    local userId = nil
    
    if ply and IsValid(ply) and ply:IsPlayer() then
        local steamId = ply:SteamID64()
        
        MB.Library.Database.Prepare(
            "SELECT id FROM mb_users WHERE steam_id = ?",
            {steamId},
            function(data)
                if data and data[1] then
                    userId = data[1].id
                else
                    MB.Library.Database.Prepare(
                        "INSERT INTO mb_users (steam_id, name) VALUES (?, ?)",
                        {steamId, ply:Nick()},
                        function(data)
                            if data then
                                userId = db:lastInsert()
                            end
                            
                            MB.Library.Logs.InsertLog(type, message, userId)
                        end
                    )
                    return
                end
                
                MB.Library.Logs.InsertLog(type, message, userId)
            end
        )
    else
        MB.Library.Logs.InsertLog(type, message, nil)
    end
end

function MB.Library.Logs.InsertLog(type, message, userId)
    local query = "INSERT INTO mb_logs (type, message, user_id) VALUES (?, ?, ?)"
    MB.Library.Database.Prepare(query, {type, message, userId})
end

function MB.Library.Logs.GetByType(type, limit, callback)
    limit = limit or 100
    
    local query = [[
        SELECT l.*, u.steam_id, u.name
        FROM mb_logs l
        LEFT JOIN mb_users u ON l.user_id = u.id
        WHERE l.type = ?
        ORDER BY l.timestamp DESC
        LIMIT ?
    ]]
    
    MB.Library.Database.Prepare(query, {type, limit}, callback)
end

function MB.Library.Logs.GetByPlayer(steamId, limit, callback)
    limit = limit or 100
    
    local query = [[
        SELECT l.*, u.steam_id, u.name
        FROM mb_logs l
        JOIN mb_users u ON l.user_id = u.id
        WHERE u.steam_id = ?
        ORDER BY l.timestamp DESC
        LIMIT ?
    ]]
    
    MB.Library.Database.Prepare(query, {steamId, limit}, callback)
end

function MB.Library.Logs.GetRecent(limit, callback)
    limit = limit or 100
    
    local query = [[
        SELECT l.*, u.steam_id, u.name
        FROM mb_logs l
        LEFT JOIN mb_users u ON l.user_id = u.id
        ORDER BY l.timestamp DESC
        LIMIT ?
    ]]
    
    MB.Library.Database.Prepare(query, {limit}, callback)
end 