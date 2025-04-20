MB.Library.Cache = MB.Library.Cache or {}
MB.Library.Cache.Data = MB.Library.Cache.Data or {}
MB.Library.Cache.Expiry = MB.Library.Cache.Expiry or {}
MB.Library.Cache.Callbacks = MB.Library.Cache.Callbacks or {}

function MB.Library.Cache.Set(key, value, expiryTime)
    if not key then return false end
    
    MB.Library.Cache.Data[key] = value
    
    if expiryTime then
        MB.Library.Cache.Expiry[key] = CurTime() + expiryTime
    else
        MB.Library.Cache.Expiry[key] = nil
    end
    
    if MB.Library.Cache.Callbacks[key] then
        for _, callback in ipairs(MB.Library.Cache.Callbacks[key]) do
            callback(value)
        end
    end
    
    return true
end

function MB.Library.Cache.Get(key, default)
    if not key then return default end
    
    if MB.Library.Cache.Expiry[key] and CurTime() > MB.Library.Cache.Expiry[key] then
        MB.Library.Cache.Data[key] = nil
        MB.Library.Cache.Expiry[key] = nil
        return default
    end
    
    return MB.Library.Cache.Data[key] or default
end

function MB.Library.Cache.Exists(key)
    if not key then return false end
    
    if MB.Library.Cache.Expiry[key] and CurTime() > MB.Library.Cache.Expiry[key] then
        MB.Library.Cache.Data[key] = nil
        MB.Library.Cache.Expiry[key] = nil
        return false
    end
    
    return MB.Library.Cache.Data[key] != nil
end

function MB.Library.Cache.Delete(key)
    if not key then return false end
    
    MB.Library.Cache.Data[key] = nil
    MB.Library.Cache.Expiry[key] = nil
    
    return true
end

function MB.Library.Cache.Clear()
    MB.Library.Cache.Data = {}
    MB.Library.Cache.Expiry = {}
    
    return true
end

function MB.Library.Cache.GetOrFetch(key, fetchFunc, expiryTime)
    if MB.Library.Cache.Exists(key) then
        return MB.Library.Cache.Get(key)
    end
    
    local value = fetchFunc()
    MB.Library.Cache.Set(key, value, expiryTime)
    
    return value
end

function MB.Library.Cache.AsyncGetOrFetch(key, fetchFunc, callback, expiryTime)
    if MB.Library.Cache.Exists(key) then
        callback(MB.Library.Cache.Get(key))
        return
    end
    
    fetchFunc(function(value)
        MB.Library.Cache.Set(key, value, expiryTime)
        callback(value)
    end)
end

function MB.Library.Cache.Subscribe(key, callback)
    if not key or not callback then return false end
    
    MB.Library.Cache.Callbacks[key] = MB.Library.Cache.Callbacks[key] or {}
    table.insert(MB.Library.Cache.Callbacks[key], callback)
    
    if MB.Library.Cache.Exists(key) then
        callback(MB.Library.Cache.Get(key))
    end
    
    return true
end

function MB.Library.Cache.Unsubscribe(key, callback)
    if not key or not callback or not MB.Library.Cache.Callbacks[key] then return false end
    
    for i, cb in ipairs(MB.Library.Cache.Callbacks[key]) do
        if cb == callback then
            table.remove(MB.Library.Cache.Callbacks[key], i)
            
            if #MB.Library.Cache.Callbacks[key] == 0 then
                MB.Library.Cache.Callbacks[key] = nil
            end
            
            return true
        end
    end
    
    return false
end

hook.Add("Think", "MB.Library.Cache.CleanupExpired", function()
    local curTime = CurTime()
    
    for key, expiryTime in pairs(MB.Library.Cache.Expiry) do
        if curTime > expiryTime then
            MB.Library.Cache.Data[key] = nil
            MB.Library.Cache.Expiry[key] = nil
        end
    end
end)