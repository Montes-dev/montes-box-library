MB.Library.Config = MB.Library.Config or {}
MB.Library.Config.Defaults = MB.Library.Config.Defaults or {}
MB.Library.Config.Values = MB.Library.Config.Values or {}

function MB.Library.Config.SetDefault(key, value)
    MB.Library.Config.Defaults[key] = value
    
    if MB.Library.Config.Values[key] == nil then
        MB.Library.Config.Values[key] = value
    end
end

function MB.Library.Config.Get(key, default)
    if MB.Library.Config.Values[key] != nil then
        return MB.Library.Config.Values[key]
    end
    
    if default != nil then
        return default
    end
    
    return MB.Library.Config.Defaults[key]
end

function MB.Library.Config.Set(key, value)
    MB.Library.Config.Values[key] = value
    
    hook.Run("MB.ConfigChanged", key, value)
    
    if SERVER then
        MB.Library.Config.SaveToFile()
    end
end

if SERVER then
    function MB.Library.Config.SaveToFile()
        file.CreateDir("mb_library")
        file.Write("mb_library/config.json", util.TableToJSON(MB.Library.Config.Values, true))
    end

    function MB.Library.Config.LoadFromFile()
        if file.Exists("mb_library/config.json", "DATA") then
            local content = file.Read("mb_library/config.json", "DATA")
            
            if content then
                local data = util.JSONToTable(content)
                
                if data then
                    for k, v in pairs(data) do
                        MB.Library.Config.Values[k] = v
                    end
                end
            end
        end
    end
    
    function MB.Library.Config.SyncWithClients()
        net.Start("MB.Net.ConfigSync")
        net.WriteTable(MB.Library.Config.Values)
        net.Broadcast()
    end
    
    hook.Add("PlayerInitialSpawn", "MB.Library.Config.SyncWithPlayer", function(ply)
        net.Start("MB.Net.ConfigSync")
        net.WriteTable(MB.Library.Config.Values)
        net.Send(ply)
    end)
    
    util.AddNetworkString("MB.Net.ConfigSync")
    util.AddNetworkString("MB.Net.ConfigUpdate")
    
    net.Receive("MB.Net.ConfigUpdate", function(len, ply)
        if not IsValid(ply) or not ply:IsAdmin() then return end
        
        local key = net.ReadString()
        local valueType = net.ReadString()
        local value
        
        if valueType == "string" then
            value = net.ReadString()
        elseif valueType == "number" then
            value = net.ReadFloat()
        elseif valueType == "boolean" then
            value = net.ReadBool()
        elseif valueType == "table" then
            value = net.ReadTable()
        else
            return
        end
        
        MB.Library.Config.Set(key, value)
        MB.Library.Config.SyncWithClients()
    end)
    
    hook.Add("Initialize", "MB.Library.Config.LoadAndSync", function()
        MB.Library.Config.LoadFromFile()
        timer.Simple(1, MB.Library.Config.SyncWithClients)
    end)
else
    net.Receive("MB.Net.ConfigSync", function()
        local values = net.ReadTable()
        
        for k, v in pairs(values) do
            MB.Library.Config.Values[k] = v
            hook.Run("MB.ConfigChanged", k, v)
        end
    end)
    
    function MB.Library.Config.UpdateServerConfig(key, value)
        if not LocalPlayer():IsAdmin() then return end
        
        net.Start("MB.Net.ConfigUpdate")
        net.WriteString(key)
        
        local valueType = type(value)
        net.WriteString(valueType)
        
        if valueType == "string" then
            net.WriteString(value)
        elseif valueType == "number" then
            net.WriteFloat(value)
        elseif valueType == "boolean" then
            net.WriteBool(value)
        elseif valueType == "table" then
            net.WriteTable(value)
        else
            net.WriteString(tostring(value))
        end
        
        net.SendToServer()
    end
end

MB.Library.Config.SetDefault("UIScale", 1.0)
MB.Library.Config.SetDefault("EnableNotifications", true)
MB.Library.Config.SetDefault("NotificationSound", "buttons/button14.wav")
MB.Library.Config.SetDefault("MaxNotifications", 5)
MB.Library.Config.SetDefault("NotificationLifetime", 5)
MB.Library.Config.SetDefault("Theme", "DarkModern")
MB.Library.Config.SetDefault("LogChatMessages", true)
MB.Library.Config.SetDefault("EnableErrorReporting", true) 