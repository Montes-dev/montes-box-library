MB.Library.Graphics = MB.Library.Graphics or {}
MB.Library.Graphics.Fonts = MB.Library.Graphics.Fonts or {}
MB.Library.Graphics.Materials = MB.Library.Graphics.Materials or {}
MB.Library.Graphics.Icons = MB.Library.Graphics.Icons or {}
MB.Library.Graphics.DefaultFonts = {"Roboto", "Arial", "Tahoma"}

function MB.Library.Graphics.Initialize()
    MB.Library.Graphics.RegisterDefaultMaterials()
    MB.Library.Graphics.RegisterDefaultFonts()
    
    MB.Library.Log("Graphics module initialized")
end

function MB.Library.Graphics.RegisterDefaultMaterials()
    MB.Library.Graphics.RegisterMaterial("gradient_up", "gui/gradient_up")
    MB.Library.Graphics.RegisterMaterial("gradient_down", "gui/gradient_down")
    MB.Library.Graphics.RegisterMaterial("gradient", "gui/gradient")
    MB.Library.Graphics.RegisterMaterial("white", "vgui/white")
    MB.Library.Graphics.RegisterMaterial("black", "vgui/black")
    MB.Library.Graphics.RegisterMaterial("close", "icon16/cross.png")
    MB.Library.Graphics.RegisterMaterial("accept", "icon16/accept.png")
    MB.Library.Graphics.RegisterMaterial("error", "icon16/exclamation.png")
    MB.Library.Graphics.RegisterMaterial("warning", "icon16/error.png")
    MB.Library.Graphics.RegisterMaterial("info", "icon16/information.png")
end

function MB.Library.Graphics.RegisterDefaultFonts()
    MB.Library.Graphics.RegisterFont("Title", {
        font = "Roboto",
        size = 24,
        weight = 600,
        antialias = true
    })
    
    MB.Library.Graphics.RegisterFont("Header", {
        font = "Roboto",
        size = 20,
        weight = 600,
        antialias = true
    })
    
    MB.Library.Graphics.RegisterFont("SubHeader", {
        font = "Roboto",
        size = 18,
        weight = 500,
        antialias = true
    })
    
    MB.Library.Graphics.RegisterFont("Normal", {
        font = "Roboto",
        size = 16,
        weight = 400,
        antialias = true
    })
    
    MB.Library.Graphics.RegisterFont("Small", {
        font = "Roboto",
        size = 14,
        weight = 400,
        antialias = true
    })
    
    MB.Library.Graphics.RegisterFont("Tiny", {
        font = "Roboto",
        size = 12,
        weight = 400,
        antialias = true
    })
    
    MB.Library.Graphics.RegisterFont("Button", {
        font = "Roboto",
        size = 16,
        weight = 500,
        antialias = true
    })
    
    MB.Library.Graphics.RegisterFont("IconSmall", {
        font = "FontAwesome",
        size = 16,
        weight = 400,
        antialias = true
    })
    
    MB.Library.Graphics.RegisterFont("IconMedium", {
        font = "FontAwesome",
        size = 24,
        weight = 400,
        antialias = true
    })
    
    MB.Library.Graphics.RegisterFont("IconLarge", {
        font = "FontAwesome",
        size = 32,
        weight = 400,
        antialias = true
    })
end

function MB.Library.Graphics.RegisterMaterial(name, path)
    if MB.Library.Graphics.Materials[name] then
        return MB.Library.Graphics.Materials[name]
    end
    
    local mat = Material(path)
    
    if not mat or mat:IsError() then
        MB.Library.Log("Failed to load material: " .. path)
        return nil
    end
    
    MB.Library.Graphics.Materials[name] = mat
    
    return mat
end

function MB.Library.Graphics.GetMaterial(name)
    if not MB.Library.Graphics.Materials[name] then
        return nil
    end
    
    return MB.Library.Graphics.Materials[name]
end

function MB.Library.Graphics.RegisterFont(name, data)
    local fontName = "MB.Font." .. name
    
    if MB.Library.Graphics.Fonts[name] then
        return fontName
    end
    
    surface.CreateFont(fontName, data)
    
    MB.Library.Graphics.Fonts[name] = {
        name = fontName,
        data = data
    }
    
    return fontName
end

function MB.Library.Graphics.GetFont(name)
    if not MB.Library.Graphics.Fonts[name] then
        return "MB.Font.Normal"
    end
    
    return MB.Library.Graphics.Fonts[name].name
end

function MB.Library.Graphics.IsValidFont(fontName)
    for _, defaultFont in ipairs(MB.Library.Graphics.DefaultFonts) do
        if string.find(string.lower(fontName), string.lower(defaultFont)) then
            return true
        end
    end
    
    return false
end

function MB.Library.Graphics.DrawOutlinedBox(x, y, w, h, thickness, color)
    surface.SetDrawColor(color)
    
    for i = 0, thickness - 1 do
        surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
    end
end

function MB.Library.Graphics.DrawRoundedOutlinedBox(x, y, w, h, radius, thickness, color)
    surface.SetDrawColor(color)
    
    draw.RoundedBox(radius, x, y, w, h, color)
    draw.RoundedBox(radius, x + thickness, y + thickness, w - thickness * 2, h - thickness * 2, MB.Library.Themes.GetColor("background"))
end

function MB.Library.Graphics.DrawGradientBox(x, y, w, h, colorFrom, colorTo, isHorizontal)
    local vertices = {}
    
    if isHorizontal then
        vertices = {
            {x = x, y = y, u = 0, v = 0, color = colorFrom},
            {x = x + w, y = y, u = 1, v = 0, color = colorTo},
            {x = x + w, y = y + h, u = 1, v = 1, color = colorTo},
            {x = x, y = y + h, u = 0, v = 1, color = colorFrom}
        }
    else
        vertices = {
            {x = x, y = y, u = 0, v = 0, color = colorFrom},
            {x = x + w, y = y, u = 1, v = 0, color = colorFrom},
            {x = x + w, y = y + h, u = 1, v = 1, color = colorTo},
            {x = x, y = y + h, u = 0, v = 1, color = colorTo}
        }
    end
    
    surface.DrawPoly(vertices)
end

function MB.Library.Graphics.DrawCircle(x, y, radius, color, segments)
    segments = segments or 32
    
    local vertices = {}
    
    for i = 0, segments do
        local angle = math.rad((i / segments) * 360)
        local vertX = x + math.sin(angle) * radius
        local vertY = y + math.cos(angle) * radius
        
        table.insert(vertices, {x = vertX, y = vertY})
    end
    
    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(vertices)
end

function MB.Library.Graphics.DrawAvatar(steamid64, x, y, size, borderSize, borderColor)
    if not steamid64 or steamid64 == "" then return end
    
    size = size or 64
    borderSize = borderSize or 0
    borderColor = borderColor or Color(0, 0, 0, 0)
    
    local avatarImage = vgui.Create("AvatarImage")
    avatarImage:SetPos(x, y)
    avatarImage:SetSize(size, size)
    avatarImage:SetSteamID(steamid64, size)
    
    if borderSize > 0 then
        avatarImage.Paint = function(self, w, h)
            MB.Library.Graphics.DrawOutlinedBox(0, 0, w, h, borderSize, borderColor)
        end
    end
    
    return avatarImage
end

function MB.Library.Graphics.RegisterIcon(name, text)
    MB.Library.Graphics.Icons[name] = text
end

function MB.Library.Graphics.GetIcon(name)
    return MB.Library.Graphics.Icons[name] or ""
end

hook.Add("Initialize", "MB.Library.Graphics.Initialize", MB.Library.Graphics.Initialize) 