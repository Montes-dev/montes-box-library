MB.Library.Animations = MB.Library.Animations or {}
MB.Library.Animations.Active = MB.Library.Animations.Active or {}
MB.Library.Animations.Defaults = {
    duration = 0.3,
    easing = "outCubic"
}

function MB.Library.Animations.Initialize()
    MB.Library.Animations.RegisterEasings()
    MB.Library.Log("Animations module initialized")
end

function MB.Library.Animations.RegisterEasings()
    MB.Library.Animations.Easings = {
        linear = function(t) return t end,
        
        inQuad = function(t) return t * t end,
        outQuad = function(t) return t * (2 - t) end,
        inOutQuad = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end,
        
        inCubic = function(t) return t * t * t end,
        outCubic = function(t) return (t - 1) * (t - 1) * (t - 1) + 1 end,
        inOutCubic = function(t) return t < 0.5 and 4 * t * t * t or (t - 1) * (2 * t - 2) * (2 * t - 2) + 1 end,
        
        inQuart = function(t) return t * t * t * t end,
        outQuart = function(t) return 1 - (t - 1) * (t - 1) * (t - 1) * (t - 1) end,
        inOutQuart = function(t) return t < 0.5 and 8 * t * t * t * t or 1 - 8 * (t - 1) * (t - 1) * (t - 1) * (t - 1) end,
        
        inQuint = function(t) return t * t * t * t * t end,
        outQuint = function(t) return 1 + (t - 1) * (t - 1) * (t - 1) * (t - 1) * (t - 1) end,
        inOutQuint = function(t) return t < 0.5 and 16 * t * t * t * t * t or 1 + 16 * (t - 1) * (t - 1) * (t - 1) * (t - 1) * (t - 1) end,
        
        inSine = function(t) return 1 - math.cos(t * math.pi / 2) end,
        outSine = function(t) return math.sin(t * math.pi / 2) end,
        inOutSine = function(t) return 0.5 * (1 - math.cos(math.pi * t)) end,
        
        inExpo = function(t) return t == 0 and 0 or math.pow(2, 10 * (t - 1)) end,
        outExpo = function(t) return t == 1 and 1 or 1 - math.pow(2, -10 * t) end,
        inOutExpo = function(t)
            if t == 0 then return 0 end
            if t == 1 then return 1 end
            if t < 0.5 then return 0.5 * math.pow(2, 20 * t - 10) end
            return 0.5 * (2 - math.pow(2, -20 * t + 10))
        end,
        
        inCirc = function(t) return 1 - math.sqrt(1 - t * t) end,
        outCirc = function(t) return math.sqrt(1 - (t - 1) * (t - 1)) end,
        inOutCirc = function(t)
            if t < 0.5 then return 0.5 * (1 - math.sqrt(1 - 4 * t * t)) end
            return 0.5 * (math.sqrt(1 - (2 * t - 2) * (2 * t - 2)) + 1)
        end,
        
        inElastic = function(t)
            if t == 0 then return 0 end
            if t == 1 then return 1 end
            return -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * ((2 * math.pi) / 3))
        end,
        outElastic = function(t)
            if t == 0 then return 0 end
            if t == 1 then return 1 end
            return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * ((2 * math.pi) / 3)) + 1
        end,
        inOutElastic = function(t)
            if t == 0 then return 0 end
            if t == 1 then return 1 end
            if t < 0.5 then return -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * ((2 * math.pi) / 4.5))) / 2 end
            return (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * ((2 * math.pi) / 4.5))) / 2 + 1
        end,
        
        inBack = function(t)
            local s = 1.70158
            return t * t * ((s + 1) * t - s)
        end,
        outBack = function(t)
            local s = 1.70158
            t = t - 1
            return t * t * ((s + 1) * t + s) + 1
        end,
        inOutBack = function(t)
            local s = 1.70158 * 1.525
            if t < 0.5 then return (2 * t) * (2 * t) * ((s + 1) * 2 * t - s) / 2 end
            return ((2 * t - 2) * (2 * t - 2) * ((s + 1) * (2 * t - 2) + s) + 2) / 2
        end,
        
        inBounce = function(t) return 1 - MB.Library.Animations.Easings.outBounce(1 - t) end,
        outBounce = function(t)
            if t < 1 / 2.75 then return 7.5625 * t * t end
            if t < 2 / 2.75 then
                t = t - 1.5 / 2.75
                return 7.5625 * t * t + 0.75
            end
            if t < 2.5 / 2.75 then
                t = t - 2.25 / 2.75
                return 7.5625 * t * t + 0.9375
            end
            t = t - 2.625 / 2.75
            return 7.5625 * t * t + 0.984375
        end,
        inOutBounce = function(t)
            if t < 0.5 then return MB.Library.Animations.Easings.inBounce(t * 2) / 2 end
            return MB.Library.Animations.Easings.outBounce(t * 2 - 1) / 2 + 0.5
        end
    }
end

function MB.Library.Animations.Create(object, propertyAccessor, from, to, duration, easing, callback)
    if not IsValid(object) then return nil end
    
    local id = "anim_" .. tostring(object) .. "_" .. math.random(1000000, 9999999)
    
    local easingFunc = MB.Library.Animations.GetEasing(easing) 
    duration = duration or MB.Library.Animations.Defaults.duration
    
    local animation = {
        id = id,
        object = object,
        propertyAccessor = propertyAccessor,
        from = from,
        to = to,
        duration = duration,
        easing = easingFunc,
        startTime = SysTime(),
        progress = 0,
        complete = false,
        callback = callback
    }
    
    MB.Library.Animations.Active[id] = animation
    
    hook.Add("Think", id, function()
        MB.Library.Animations.Update(id)
    end)
    
    return id
end

function MB.Library.Animations.Update(id)
    local animation = MB.Library.Animations.Active[id]
    
    if not animation or animation.complete then
        MB.Library.Animations.Cancel(id)
        return
    end
    
    if not IsValid(animation.object) then
        MB.Library.Animations.Cancel(id)
        return
    end
    
    local elapsed = SysTime() - animation.startTime
    animation.progress = math.Clamp(elapsed / animation.duration, 0, 1)
    
    local easedProgress = animation.easing(animation.progress)
    
    if type(animation.from) == "number" then
        local value = Lerp(easedProgress, animation.from, animation.to)
        animation.propertyAccessor(animation.object, value)
    elseif IsColor(animation.from) then
        local r = Lerp(easedProgress, animation.from.r, animation.to.r)
        local g = Lerp(easedProgress, animation.from.g, animation.to.g)
        local b = Lerp(easedProgress, animation.from.b, animation.to.b)
        local a = Lerp(easedProgress, animation.from.a, animation.to.a)
        animation.propertyAccessor(animation.object, Color(r, g, b, a))
    elseif type(animation.from) == "table" and animation.from.x and animation.from.y then
        local x = Lerp(easedProgress, animation.from.x, animation.to.x)
        local y = Lerp(easedProgress, animation.from.y, animation.to.y)
        animation.propertyAccessor(animation.object, {x = x, y = y})
    end
    
    if animation.progress >= 1 then
        animation.complete = true
        
        if animation.callback then
            animation.callback(animation.object)
        end
        
        MB.Library.Animations.Cancel(id)
    end
end

function MB.Library.Animations.Cancel(id)
    if MB.Library.Animations.Active[id] then
        hook.Remove("Think", id)
        MB.Library.Animations.Active[id] = nil
    end
end

function MB.Library.Animations.GetEasing(name)
    name = name or MB.Library.Animations.Defaults.easing
    
    if MB.Library.Animations.Easings[name] then
        return MB.Library.Animations.Easings[name]
    end
    
    return MB.Library.Animations.Easings.linear
end

function MB.Library.Animations.FadeIn(object, duration, easing, callback)
    local startAlpha = object:GetAlpha()
    
    return MB.Library.Animations.Create(
        object,
        function(obj, value) obj:SetAlpha(value) end,
        startAlpha,
        255,
        duration,
        easing,
        callback
    )
end

function MB.Library.Animations.FadeOut(object, duration, easing, callback)
    local startAlpha = object:GetAlpha()
    
    return MB.Library.Animations.Create(
        object,
        function(obj, value) obj:SetAlpha(value) end,
        startAlpha,
        0,
        duration,
        easing,
        callback
    )
end

function MB.Library.Animations.Size(object, targetW, targetH, duration, easing, callback)
    local startW, startH = object:GetSize()
    
    return MB.Library.Animations.Create(
        object,
        function(obj, size) obj:SetSize(size.x, size.y) end,
        {x = startW, y = startH},
        {x = targetW, y = targetH},
        duration,
        easing,
        callback
    )
end

function MB.Library.Animations.MoveTo(object, targetX, targetY, duration, easing, callback)
    local startX, startY = object:GetPos()
    
    return MB.Library.Animations.Create(
        object,
        function(obj, pos) obj:SetPos(pos.x, pos.y) end,
        {x = startX, y = startY},
        {x = targetX, y = targetY},
        duration,
        easing,
        callback
    )
end

function MB.Library.Animations.Color(object, targetColor, duration, easing, callback)
    local startColor = object.GetColor and object:GetColor() or Color(255, 255, 255)
    
    return MB.Library.Animations.Create(
        object,
        function(obj, color) 
            if obj.SetColor then obj:SetColor(color) end 
        end,
        startColor,
        targetColor,
        duration,
        easing,
        callback
    )
end

function MB.Library.Animations.SlideIn(object, direction, duration, easing, callback)
    local w, h = object:GetSize()
    local screenW, screenH = ScrW(), ScrH()
    local targetX, targetY = object:GetPos()
    local startX, startY = targetX, targetY
    
    if direction == "left" then
        startX = -w
    elseif direction == "right" then
        startX = screenW
    elseif direction == "up" then
        startY = -h
    elseif direction == "down" then
        startY = screenH
    end
    
    object:SetPos(startX, startY)
    object:SetAlpha(255)
    
    return MB.Library.Animations.MoveTo(object, targetX, targetY, duration, easing, callback)
end

function MB.Library.Animations.SlideOut(object, direction, duration, easing, callback)
    local w, h = object:GetSize()
    local screenW, screenH = ScrW(), ScrH()
    local startX, startY = object:GetPos()
    local targetX, targetY = startX, startY
    
    if direction == "left" then
        targetX = -w
    elseif direction == "right" then
        targetX = screenW
    elseif direction == "up" then
        targetY = -h
    elseif direction == "down" then
        targetY = screenH
    end
    
    return MB.Library.Animations.MoveTo(object, targetX, targetY, duration, easing, callback)
end

hook.Add("Initialize", "MB.Library.Animations.Initialize", MB.Library.Animations.Initialize) 