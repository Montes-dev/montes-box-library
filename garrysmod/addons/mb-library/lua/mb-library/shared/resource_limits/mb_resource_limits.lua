MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.ResourceLimits = MB.Library.ResourceLimits or {}
MB.Library.ResourceLimits.Limits = MB.Library.ResourceLimits.Limits or {}
MB.Library.ResourceLimits.Usage = MB.Library.ResourceLimits.Usage or {}

local DEFAULT_LIMITS = {
    net_messages_per_second = 100,
    hooks_per_entity = 20,
    timers_per_addon = 50,
    ui_panels_per_player = 30,
    file_operations_per_second = 10,
    sql_queries_per_second = 20,
    render_targets = 10,
    http_requests_per_minute = 30
}

function MB.Library.ResourceLimits.Initialize()
    for resource, limit in pairs(DEFAULT_LIMITS) do
        MB.Library.ResourceLimits.SetLimit(resource, limit)
    end
    
    for resource, _ in pairs(MB.Library.ResourceLimits.Limits) do
        MB.Library.ResourceLimits.Usage[resource] = 0
    end
    
    timer.Create("MB.Library.ResourceLimits.ResetUsage", 1, 0, function()
        MB.Library.ResourceLimits.ResetUsage()
    end)
    
    MB.Library.Log("Resource limits module initialized")
end

function MB.Library.ResourceLimits.SetLimit(resource, limit)
    if not resource or not limit then
        MB.Library.Log("Failed to set resource limit: Invalid parameters", "error")
        return false
    end
    
    MB.Library.ResourceLimits.Limits[resource] = limit
    MB.Library.Log("Set resource limit: " .. resource .. " = " .. limit)
    return true
end

function MB.Library.ResourceLimits.GetLimit(resource)
    if not resource then
        MB.Library.Log("Failed to get resource limit: Invalid parameters", "error")
        return nil
    end
    
    return MB.Library.ResourceLimits.Limits[resource]
end

function MB.Library.ResourceLimits.TrackUsage(resource, amount)
    if not resource then
        MB.Library.Log("Failed to track resource usage: Invalid parameters", "error")
        return false
    end
    
    amount = amount or 1
    
    MB.Library.ResourceLimits.Usage[resource] = MB.Library.ResourceLimits.Usage[resource] or 0
    
    MB.Library.ResourceLimits.Usage[resource] = MB.Library.ResourceLimits.Usage[resource] + amount
    
    return true
end

function MB.Library.ResourceLimits.IsOverLimit(resource)
    if not resource then
        MB.Library.Log("Failed to check resource limit: Invalid parameters", "error")
        return false
    end
    
    local usage = MB.Library.ResourceLimits.Usage[resource] or 0
    local limit = MB.Library.ResourceLimits.GetLimit(resource)
    
    if not limit then
        return false
    end
    
    return usage >= limit
end

function MB.Library.ResourceLimits.ResetUsage()
    for resource, _ in pairs(MB.Library.ResourceLimits.Limits) do
        MB.Library.ResourceLimits.Usage[resource] = 0
    end
end

hook.Add("MB.Library.Initialize", "MB.Library.ResourceLimits.Init", function()
    MB.Library.ResourceLimits.Initialize()
end) 