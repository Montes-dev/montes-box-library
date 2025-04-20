MB.Library.Control = MB.Library.Control or {}
MB.Library.Control.Users = MB.Library.Control.Users or {}
MB.Library.Control.Groups = MB.Library.Control.Groups or {}

function MB.Library.Control.Initialize()
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_user_groups (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL UNIQUE,
            permissions TEXT,
            color VARCHAR(32)
        )
    ]])
    
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_user_group_members (
            user_id INT NOT NULL,
            group_id INT NOT NULL,
            PRIMARY KEY (user_id, group_id),
            FOREIGN KEY (user_id) REFERENCES mb_users(id) ON DELETE CASCADE,
            FOREIGN KEY (group_id) REFERENCES mb_user_groups(id) ON DELETE CASCADE
        )
    ]])
    
    MB.Library.Control.LoadGroups()
end

function MB.Library.Control.LoadGroups()
    MB.Library.Database.Query("SELECT * FROM mb_user_groups", function(data)
        if data then
            for _, group in ipairs(data) do
                local permissions = {}
                
                if group.permissions and group.permissions ~= "" then
                    permissions = util.JSONToTable(group.permissions) or {}
                end
                
                MB.Library.Control.Groups[group.id] = {
                    id = group.id,
                    name = group.name,
                    permissions = permissions,
                    color = group.color and string.ToColor(group.color) or Color(255, 255, 255)
                }
            end
        end
    end)
end

function MB.Library.Control.CreateGroup(name, permissions, color, callback)
    if not name or name == "" then
        if callback then callback(false, "Group name cannot be empty") end
        return
    end
    
    permissions = permissions or {}
    color = color or Color(255, 255, 255)
    
    local permissionsJson = util.TableToJSON(permissions)
    local colorStr = string.FromColor(color)
    
    MB.Library.Database.Prepare(
        "INSERT INTO mb_user_groups (name, permissions, color) VALUES (?, ?, ?)",
        {name, permissionsJson, colorStr},
        function(data)
            if not data then
                if callback then callback(false, "Failed to create group") end
                return
            end
            
            local groupId = MB.Library.Database.LastInsertID()
            
            MB.Library.Control.Groups[groupId] = {
                id = groupId,
                name = name,
                permissions = permissions,
                color = color
            }
            
            if callback then callback(true, groupId) end
        end,
        function(err)
            if callback then callback(false, err) end
        end
    )
end

function MB.Library.Control.DeleteGroup(groupId, callback)
    if not MB.Library.Control.Groups[groupId] then
        if callback then callback(false, "Group not found") end
        return
    end
    
    MB.Library.Database.Prepare(
        "DELETE FROM mb_user_groups WHERE id = ?",
        {groupId},
        function(data)
            MB.Library.Control.Groups[groupId] = nil
            
            if callback then callback(true) end
        end,
        function(err)
            if callback then callback(false, err) end
        end
    )
end

function MB.Library.Control.UpdateGroup(groupId, name, permissions, color, callback)
    if not MB.Library.Control.Groups[groupId] then
        if callback then callback(false, "Group not found") end
        return
    end
    
    local group = MB.Library.Control.Groups[groupId]
    
    name = name or group.name
    permissions = permissions or group.permissions
    color = color or group.color
    
    local permissionsJson = util.TableToJSON(permissions)
    local colorStr = string.FromColor(color)
    
    MB.Library.Database.Prepare(
        "UPDATE mb_user_groups SET name = ?, permissions = ?, color = ? WHERE id = ?",
        {name, permissionsJson, colorStr, groupId},
        function(data)
            MB.Library.Control.Groups[groupId] = {
                id = groupId,
                name = name,
                permissions = permissions,
                color = color
            }
            
            if callback then callback(true) end
        end,
        function(err)
            if callback then callback(false, err) end
        end
    )
end

function MB.Library.Control.AddUserToGroup(userId, groupId, callback)
    if not MB.Library.Control.Groups[groupId] then
        if callback then callback(false, "Group not found") end
        return
    end
    
    MB.Library.Database.Prepare(
        "INSERT IGNORE INTO mb_user_group_members (user_id, group_id) VALUES (?, ?)",
        {userId, groupId},
        function(data)
            if callback then callback(true) end
        end,
        function(err)
            if callback then callback(false, err) end
        end
    )
end

function MB.Library.Control.RemoveUserFromGroup(userId, groupId, callback)
    MB.Library.Database.Prepare(
        "DELETE FROM mb_user_group_members WHERE user_id = ? AND group_id = ?",
        {userId, groupId},
        function(data)
            if callback then callback(true) end
        end,
        function(err)
            if callback then callback(false, err) end
        end
    )
end

function MB.Library.Control.GetUserGroups(userId, callback)
    MB.Library.Database.Prepare(
        [[
            SELECT g.* 
            FROM mb_user_groups g
            JOIN mb_user_group_members m ON g.id = m.group_id
            WHERE m.user_id = ?
        ]],
        {userId},
        function(data)
            local groups = {}
            
            if data then
                for _, group in ipairs(data) do
                    local permissions = {}
                    
                    if group.permissions and group.permissions ~= "" then
                        permissions = util.JSONToTable(group.permissions) or {}
                    end
                    
                    table.insert(groups, {
                        id = group.id,
                        name = group.name,
                        permissions = permissions,
                        color = group.color and string.ToColor(group.color) or Color(255, 255, 255)
                    })
                end
            end
            
            if callback then callback(groups) end
        end,
        function(err)
            if callback then callback({}) end
        end
    )
end

function MB.Library.Control.HasPermission(userId, permission, callback)
    MB.Library.Control.GetUserGroups(userId, function(groups)
        local hasPermission = false
        
        for _, group in ipairs(groups) do
            if table.HasValue(group.permissions, permission) or table.HasValue(group.permissions, "*") then
                hasPermission = true
                break
            end
        end
        
        if callback then callback(hasPermission) end
    end)
end

function MB.Library.Control.GetAllGroups(callback)
    local groups = {}
    
    for groupId, group in pairs(MB.Library.Control.Groups) do
        table.insert(groups, table.Copy(group))
    end
    
    if callback then callback(groups) end
end

hook.Add("DatabaseInitialized", "MB.Library.Control.Initialize", MB.Library.Control.Initialize) 