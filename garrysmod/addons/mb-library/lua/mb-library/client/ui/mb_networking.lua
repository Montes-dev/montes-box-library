MB.Library.Networking = MB.Library.Networking or {}
MB.Library.Networking.Channels = MB.Library.Networking.Channels or {}

function MB.Library.Networking.RegisterChannel(name)
    if MB.Library.Networking.Channels[name] then
        return MB.Library.Networking.Channels[name]
    end
    
    MB.Library.Networking.Channels[name] = {
        name = name,
        netName = "MB.Net." .. name,
        callbacks = {}
    }
    
    return MB.Library.Networking.Channels[name]
end

function MB.Library.Networking.Send(channelName, data, compression)
    local channel = MB.Library.Networking.Channels[channelName]
    
    if not channel then
        channel = MB.Library.Networking.RegisterChannel(channelName)
    end
    
    net.Start(channel.netName)
    
    if compression then
        local jsonData = util.TableToJSON(data)
        local compressed = util.Compress(jsonData)
        local len = #compressed
        
        net.WriteUInt(len, 32)
        net.WriteData(compressed, len)
    else
        net.WriteTable(data)
    end
    
    net.SendToServer()
end

function MB.Library.Networking.Listen(channelName, callback)
    local channel = MB.Library.Networking.Channels[channelName]
    
    if not channel then
        channel = MB.Library.Networking.RegisterChannel(channelName)
    end
    
    if not channel.initialized then
        net.Receive(channel.netName, function(len)
            local data
            
            if len > 32 then
                local compressedLen = net.ReadUInt(32)
                local compressed = net.ReadData(compressedLen)
                local decompressed = util.Decompress(compressed)
                
                if not decompressed then
                    MB.Library.Log("Failed to decompress data from server")
                    return
                end
                
                data = util.JSONToTable(decompressed)
            else
                data = net.ReadTable()
            end
            
            for _, cb in ipairs(channel.callbacks) do
                cb(data)
            end
        end)
        
        channel.initialized = true
    end
    
    table.insert(channel.callbacks, callback)
end

MB.Library.Networking.RegisterChannel("AdminAction")
MB.Library.Networking.RegisterChannel("UserAction")
MB.Library.Networking.RegisterChannel("Notification")
MB.Library.Networking.RegisterChannel("LogUpdate")
MB.Library.Networking.RegisterChannel("ServerStatus")

MB.Library.Networking.Listen("Notification", function(data)
    if data.text then
        notification.AddLegacy(data.text, data.type or NOTIFY_GENERIC, data.length or 5)
        
        if data.sound then
            surface.PlaySound(data.sound)
        end
    end
end)

MB.Library.Networking.Listen("ServerStatus", function(data)
    MB.Library.ServerStatus = data
    hook.Run("MB.ServerStatusUpdated", data)
end) 