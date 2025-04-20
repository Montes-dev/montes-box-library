MB.Library.Errors = MB.Library.Errors or {}
MB.Library.Errors.Handlers = MB.Library.Errors.Handlers or {}
MB.Library.Errors.LastError = nil

function MB.Library.Errors.RegisterHandler(name, callback)
    MB.Library.Errors.Handlers[name] = callback
end

function MB.Library.Errors.Handle(err, stack)
    MB.Library.LastError = {
        message = err,
        stack = stack,
        time = os.time()
    }
    
    MB.Library.Log("Error: " .. err)
    
    if stack then
        MB.Library.Log("Stack: " .. stack)
    end
    
    MB.Library.Logs.Add("error", err .. (stack and " - " .. stack or ""))
    
    for name, handler in pairs(MB.Library.Errors.Handlers) do
        local success, result = pcall(handler, err, stack)
        
        if not success then
            MB.Library.Log("Error handler '" .. name .. "' failed: " .. result)
        end
    end
    
    return err
end

function MB.Library.Errors.Wrap(func, errorHandler)
    return function(...)
        local success, result = pcall(func, ...)
        
        if not success then
            if errorHandler then
                errorHandler(result)
            else
                MB.Library.Errors.Handle(result, debug.traceback())
            end
            return nil
        end
        
        return result
    end
end

function MB.Library.Errors.Try(func, errorHandler)
    local success, result = pcall(func)
    
    if not success then
        if errorHandler then
            errorHandler(result)
        else
            MB.Library.Errors.Handle(result, debug.traceback())
        end
        return nil
    end
    
    return result
end

MB.Library.Errors.RegisterHandler("Notify", function(err, stack)
    for _, ply in ipairs(player.GetAll()) do
        if ply:IsAdmin() then
            MB.Library.Networking.SendToPlayer("Notification", ply, {
                title = "Server Error",
                text = err,
                type = NOTIFY_ERROR
            })
        end
    end
end)

hook.Add("Initialize", "MB.Library.Errors.Setup", function()
    local oldHookAdd = hook.Add
    
    hook.Add = function(event, name, callback)
        if type(callback) == "function" then
            local wrappedCallback = MB.Library.Errors.Wrap(callback, function(err)
                MB.Library.Errors.Handle("Error in hook '" .. event .. ":" .. name .. "': " .. err, debug.traceback())
            end)
            
            return oldHookAdd(event, name, wrappedCallback)
        else
            return oldHookAdd(event, name, callback)
        end
    end
    
    local oldNetReceive = net.Receive
    
    net.Receive = function(name, callback)
        if type(callback) == "function" then
            local wrappedCallback = MB.Library.Errors.Wrap(callback, function(err)
                MB.Library.Errors.Handle("Error in net receive '" .. name .. "': " .. err, debug.traceback())
            end)
            
            return oldNetReceive(name, wrappedCallback)
        else
            return oldNetReceive(name, callback)
        end
    end
end) 