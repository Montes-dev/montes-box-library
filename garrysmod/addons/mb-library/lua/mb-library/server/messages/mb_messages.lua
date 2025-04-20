MB.Library.Messages = MB.Library.Messages or {}
MB.Library.Messages.Templates = MB.Library.Messages.Templates or {}
MB.Library.Messages.Variables = MB.Library.Messages.Variables or {}

function MB.Library.Messages.Initialize()
    MB.Library.Database.Query([[
        CREATE TABLE IF NOT EXISTS mb_message_templates (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(64) NOT NULL UNIQUE,
            template TEXT NOT NULL,
            description TEXT
        )
    ]])
    
    MB.Library.Messages.LoadTemplates()
end

function MB.Library.Messages.LoadTemplates()
    MB.Library.Database.Query("SELECT * FROM mb_message_templates", function(data)
        if data then
            for _, template in ipairs(data) do
                MB.Library.Messages.Templates[template.name] = {
                    id = template.id,
                    name = template.name,
                    template = template.template,
                    description = template.description
                }
            end
        end
    end)
end

function MB.Library.Messages.AddTemplate(name, template, description, callback)
    if not name or name == "" then
        if callback then callback(false, "Template name cannot be empty") end
        return
    end
    
    if not template or template == "" then
        if callback then callback(false, "Template content cannot be empty") end
        return
    end
    
    description = description or ""
    
    MB.Library.Database.Prepare(
        "INSERT INTO mb_message_templates (name, template, description) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE template = VALUES(template), description = VALUES(description)",
        {name, template, description},
        function(data, query)
            if not data then
                if callback then callback(false, "Failed to save template") end
                return
            end
            
            local templateId
            if query and query.lastInsert then
                templateId = query.lastInsert
            else
                templateId = MB.Library.Database.LastInsertID()
            end
            
            if not templateId or templateId == 0 then
                MB.Library.Database.Prepare(
                    "SELECT id FROM mb_message_templates WHERE name = ?",
                    {name},
                    function(idData)
                        if idData and idData[1] then
                            templateId = idData[1].id
                            
                            MB.Library.Messages.Templates[name] = {
                                id = templateId,
                                name = name,
                                template = template,
                                description = description
                            }
                            
                            if callback then callback(true, templateId) end
                        else
                            if callback then callback(false, "Failed to get template ID") end
                        end
                    end
                )
                return
            end
            
            MB.Library.Messages.Templates[name] = {
                id = templateId,
                name = name,
                template = template,
                description = description
            }
            
            if callback then callback(true, templateId) end
        end,
        function(err)
            if callback then callback(false, err) end
        end
    )
end

function MB.Library.Messages.DeleteTemplate(name, callback)
    if not MB.Library.Messages.Templates[name] then
        if callback then callback(false, "Template not found") end
        return
    end
    
    MB.Library.Database.Prepare(
        "DELETE FROM mb_message_templates WHERE name = ?",
        {name},
        function(data)
            MB.Library.Messages.Templates[name] = nil
            
            if callback then callback(true) end
        end,
        function(err)
            if callback then callback(false, err) end
        end
    )
end

function MB.Library.Messages.GetTemplate(name)
    return MB.Library.Messages.Templates[name]
end

function MB.Library.Messages.GetAllTemplates()
    local templates = {}
    
    for name, template in pairs(MB.Library.Messages.Templates) do
        table.insert(templates, table.Copy(template))
    end
    
    return templates
end

function MB.Library.Messages.RegisterVariable(name, getter)
    MB.Library.Messages.Variables[name] = getter
end

function MB.Library.Messages.GetVariableValue(name, context)
    local getter = MB.Library.Messages.Variables[name]
    
    if getter and type(getter) == "function" then
        return getter(context)
    end
    
    return nil
end

function MB.Library.Messages.Format(templateName, context, fallback)
    local template = MB.Library.Messages.GetTemplate(templateName)
    
    if not template then
        return fallback or templateName
    end
    
    local result = template.template
    
    result = string.gsub(result, "{([%w_]+)}", function(variableName)
        local value = MB.Library.Messages.GetVariableValue(variableName, context)
        
        if value ~= nil then
            return tostring(value)
        end
        
        if context and context[variableName] ~= nil then
            return tostring(context[variableName])
        end
        
        return "{" .. variableName .. "}"
    end)
    
    return result
end

function MB.Library.Messages.Send(players, templateName, context)
    local message = MB.Library.Messages.Format(templateName, context)
    
    if not players then
        for _, ply in ipairs(player.GetAll()) do
            ply:ChatPrint(message)
        end
    elseif type(players) == "table" then
        for _, ply in ipairs(players) do
            if IsValid(ply) and ply:IsPlayer() then
                ply:ChatPrint(message)
            end
        end
    elseif IsValid(players) and players:IsPlayer() then
        players:ChatPrint(message)
    end
end

MB.Library.Messages.RegisterVariable("server_name", function()
    return GetHostName()
end)

MB.Library.Messages.RegisterVariable("current_time", function()
    return os.date("%H:%M:%S")
end)

MB.Library.Messages.RegisterVariable("current_date", function()
    return os.date("%d/%m/%Y")
end)

MB.Library.Messages.RegisterVariable("player_count", function()
    return #player.GetAll()
end)

MB.Library.Messages.RegisterVariable("max_players", function()
    return game.MaxPlayers()
end)

hook.Add("DatabaseInitialized", "MB.Library.Messages.Initialize", MB.Library.Messages.Initialize)

MB.Library.Messages.AddTemplate("welcome", "Welcome to {server_name}! There are currently {player_count}/{max_players} players online.", "Welcome message shown to new players") 