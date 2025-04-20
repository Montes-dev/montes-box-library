MB.Library.Colors = MB.Library.Colors or {}

function MB.Library.Colors.HexToColor(hex)
    if not hex or type(hex) ~= "string" then return Color(255, 255, 255) end
    
    hex = hex:gsub("#", "")
    
    if #hex == 3 then
        hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
    end
    
    local r, g, b, a = 255, 255, 255, 255
    
    if #hex >= 6 then
        r = tonumber(hex:sub(1, 2), 16) or 255
        g = tonumber(hex:sub(3, 4), 16) or 255
        b = tonumber(hex:sub(5, 6), 16) or 255
        
        if #hex == 8 then
            a = tonumber(hex:sub(7, 8), 16) or 255
        end
    end
    
    return Color(r, g, b, a)
end

function MB.Library.Colors.ColorToHex(color, includeAlpha)
    if not color or not IsColor(color) then return "#FFFFFF" end
    
    if includeAlpha then
        return string.format("#%02X%02X%02X%02X", color.r, color.g, color.b, color.a)
    else
        return string.format("#%02X%02X%02X", color.r, color.g, color.b)
    end
end

function MB.Library.Colors.HSVToColor(h, s, v, a)
    h = h % 360
    s = math.Clamp(s, 0, 1)
    v = math.Clamp(v, 0, 1)
    a = a or 255
    
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    
    local r, g, b = 0, 0, 0
    
    if h >= 0 and h < 60 then
        r, g, b = c, x, 0
    elseif h >= 60 and h < 120 then
        r, g, b = x, c, 0
    elseif h >= 120 and h < 180 then
        r, g, b = 0, c, x
    elseif h >= 180 and h < 240 then
        r, g, b = 0, x, c
    elseif h >= 240 and h < 300 then
        r, g, b = x, 0, c
    elseif h >= 300 and h < 360 then
        r, g, b = c, 0, x
    end
    
    r = math.floor((r + m) * 255)
    g = math.floor((g + m) * 255)
    b = math.floor((b + m) * 255)
    
    return Color(r, g, b, a)
end

function MB.Library.Colors.ColorToHSV(color)
    if not color or not IsColor(color) then return 0, 0, 0, 255 end
    
    local r, g, b = color.r / 255, color.g / 255, color.b / 255
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    
    local h, s, v = 0, 0, max
    
    if max > 0 then
        s = delta / max
        
        if max == r then
            h = (g - b) / delta
            if g < b then h = h + 6 end
        elseif max == g then
            h = 2 + (b - r) / delta
        else
            h = 4 + (r - g) / delta
        end
        h = h * 60
    end
    
    return h, s, v, color.a
end

function MB.Library.Colors.Lighten(color, amount)
    if not color or not IsColor(color) then return Color(255, 255, 255) end
    
    amount = math.Clamp(amount or 0.2, 0, 1)
    local h, s, v, a = MB.Library.Colors.ColorToHSV(color)
    
    return MB.Library.Colors.HSVToColor(h, s, math.min(v + amount, 1), a)
end

function MB.Library.Colors.Darken(color, amount)
    if not color or not IsColor(color) then return Color(0, 0, 0) end
    
    amount = math.Clamp(amount or 0.2, 0, 1)
    local h, s, v, a = MB.Library.Colors.ColorToHSV(color)
    
    return MB.Library.Colors.HSVToColor(h, s, math.max(v - amount, 0), a)
end

function MB.Library.Colors.SetAlpha(color, alpha)
    if not color or not IsColor(color) then return Color(255, 255, 255, alpha) end
    
    alpha = math.Clamp(alpha or 255, 0, 255)
    
    return Color(color.r, color.g, color.b, alpha)
end

function MB.Library.Colors.Saturate(color, amount)
    if not color or not IsColor(color) then return Color(255, 255, 255) end
    
    amount = math.Clamp(amount or 0.2, 0, 1)
    local h, s, v, a = MB.Library.Colors.ColorToHSV(color)
    
    return MB.Library.Colors.HSVToColor(h, math.min(s + amount, 1), v, a)
end

function MB.Library.Colors.Desaturate(color, amount)
    if not color or not IsColor(color) then return Color(255, 255, 255) end
    
    amount = math.Clamp(amount or 0.2, 0, 1)
    local h, s, v, a = MB.Library.Colors.ColorToHSV(color)
    
    return MB.Library.Colors.HSVToColor(h, math.max(s - amount, 0), v, a)
end

function MB.Library.Colors.Invert(color)
    if not color or not IsColor(color) then return Color(255, 255, 255) end
    
    return Color(255 - color.r, 255 - color.g, 255 - color.b, color.a)
end

function MB.Library.Colors.Mix(color1, color2, weight)
    if not color1 or not IsColor(color1) then color1 = Color(255, 255, 255) end
    if not color2 or not IsColor(color2) then color2 = Color(0, 0, 0) end
    
    weight = math.Clamp(weight or 0.5, 0, 1)
    
    local r = Lerp(weight, color1.r, color2.r)
    local g = Lerp(weight, color1.g, color2.g)
    local b = Lerp(weight, color1.b, color2.b)
    local a = Lerp(weight, color1.a, color2.a)
    
    return Color(r, g, b, a)
end

function MB.Library.Colors.Grayscale(color)
    if not color or not IsColor(color) then return Color(255, 255, 255) end
    
    local value = (color.r * 0.299 + color.g * 0.587 + color.b * 0.114) / 255
    local gray = math.floor(value * 255)
    
    return Color(gray, gray, gray, color.a)
end

function MB.Library.Colors.GetContrastColor(color)
    if not color or not IsColor(color) then return Color(0, 0, 0) end
    
    local r = color.r / 255
    local g = color.g / 255
    local b = color.b / 255
    
    r = (r <= 0.03928) and (r / 12.92) or math.pow((r + 0.055) / 1.055, 2.4)
    g = (g <= 0.03928) and (g / 12.92) or math.pow((g + 0.055) / 1.055, 2.4)
    b = (b <= 0.03928) and (b / 12.92) or math.pow((b + 0.055) / 1.055, 2.4)
    
    local luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    
    return (luminance > 0.5) and Color(0, 0, 0) or Color(255, 255, 255)
end

function MB.Library.Colors.GenerateMonochromaticPalette(baseColor, steps)
    if not baseColor or not IsColor(baseColor) then baseColor = Color(255, 0, 0) end
    steps = steps or 5
    
    local palette = {}
    local h, s, v, a = MB.Library.Colors.ColorToHSV(baseColor)
    local stepSize = 1 / (steps - 1)
    
    for i = 1, steps do
        local newV = math.Clamp((i - 1) * stepSize, 0, 1)
        table.insert(palette, MB.Library.Colors.HSVToColor(h, s, newV, a))
    end
    
    return palette
end

function MB.Library.Colors.GenerateAnalogousPalette(baseColor, angle, count)
    if not baseColor or not IsColor(baseColor) then baseColor = Color(255, 0, 0) end
    angle = angle or 30
    count = count or 3
    
    local palette = {}
    local h, s, v, a = MB.Library.Colors.ColorToHSV(baseColor)
    local startAngle = h - math.floor(count / 2) * angle
    
    for i = 1, count do
        local newH = (startAngle + (i - 1) * angle) % 360
        table.insert(palette, MB.Library.Colors.HSVToColor(newH, s, v, a))
    end
    
    return palette
end

function MB.Library.Colors.GenerateComplementaryPalette(baseColor)
    if not baseColor or not IsColor(baseColor) then baseColor = Color(255, 0, 0) end
    
    local h, s, v, a = MB.Library.Colors.ColorToHSV(baseColor)
    local complementH = (h + 180) % 360
    
    return {
        baseColor,
        MB.Library.Colors.HSVToColor(complementH, s, v, a)
    }
end

function MB.Library.Colors.GenerateTriadicPalette(baseColor)
    if not baseColor or not IsColor(baseColor) then baseColor = Color(255, 0, 0) end
    
    local h, s, v, a = MB.Library.Colors.ColorToHSV(baseColor)
    
    return {
        baseColor,
        MB.Library.Colors.HSVToColor((h + 120) % 360, s, v, a),
        MB.Library.Colors.HSVToColor((h + 240) % 360, s, v, a)
    }
end

function MB.Library.Colors.MakeGradient(colorStart, colorEnd, steps)
    if not colorStart or not IsColor(colorStart) then colorStart = Color(255, 255, 255) end
    if not colorEnd or not IsColor(colorEnd) then colorEnd = Color(0, 0, 0) end
    steps = steps or 10
    
    local gradient = {}
    
    for i = 1, steps do
        local t = (i - 1) / (steps - 1)
        table.insert(gradient, MB.Library.Colors.Mix(colorStart, colorEnd, t))
    end
    
    return gradient
end

MB.Library.Log("Colors utility module loaded!")