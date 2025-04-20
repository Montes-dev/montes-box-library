MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Fonts = MB.Library.Fonts or {}

local function CreateFonts()
    local fontFamilies = {
        ["MB.Font"] = "Roboto",
        ["MB.Font.Bold"] = "Roboto Bold",
        ["MB.Font.Light"] = "Roboto Light",
        ["MB.Font.Thin"] = "Roboto Thin",
        ["MB.Font.Black"] = "Roboto Black",
        ["MB.Font.Medium"] = "Roboto Medium",
        ["MB.Font.Mono"] = "Roboto Mono"
    }
    
    local sizes = {
        ["Tiny"] = 10,
        ["Small"] = 14,
        ["Normal"] = 16,
        ["Medium"] = 18,
        ["Large"] = 20,
        ["Title"] = 24,
        ["Header"] = 28,
        ["Display"] = 32,
        ["Huge"] = 40,
        ["Giant"] = 48
    }
    
    for fontBase, fontFamily in pairs(fontFamilies) do
        for sizeName, fontSize in pairs(sizes) do
            local fontName = fontBase .. "." .. sizeName
            
            surface.CreateFont(fontName, {
                font = fontFamily,
                size = fontSize,
                weight = 500,
                antialias = true,
                extended = true
            })
            
            surface.CreateFont(fontName .. ".Shadow", {
                font = fontFamily,
                size = fontSize,
                weight = 500,
                antialias = true,
                extended = true,
                blursize = 2
            })
            
            surface.CreateFont(fontName .. ".Outline", {
                font = fontFamily,
                size = fontSize,
                weight = 500,
                antialias = true,
                extended = true,
                outline = true
            })
        end
    end
    
    -- Override default Garry's Mod fonts
    surface.CreateFont("DermaDefault", {
        font = "Roboto",
        size = 16,
        weight = 500,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("DermaDefaultBold", {
        font = "Roboto Bold",
        size = 16,
        weight = 700,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("DermaLarge", {
        font = "Roboto Bold",
        size = 24,
        weight = 700,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("Trebuchet18", {
        font = "Roboto Medium",
        size = 18,
        weight = 500,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("Trebuchet24", {
        font = "Roboto Medium",
        size = 24,
        weight = 500,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("HudHintTextLarge", {
        font = "Roboto",
        size = 22,
        weight = 500,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("HudHintTextSmall", {
        font = "Roboto",
        size = 16,
        weight = 500,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("ChatFont", {
        font = "Roboto Medium",
        size = 18,
        weight = 500,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("TargetID", {
        font = "Roboto",
        size = 18,
        weight = 500,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("TargetIDSmall", {
        font = "Roboto",
        size = 14,
        weight = 500,
        antialias = true,
        extended = true
    })
    
    MB.Library.Log("Fonts registered and default fonts overridden")
end

function MB.Library.Fonts.Initialize()
    CreateFonts()
    
    -- Recreate fonts when the screen resolution changes
    hook.Add("OnScreenSizeChanged", "MB.Library.Fonts.Recreate", function()
        CreateFonts()
    end)
    
    MB.Library.Log("Font module initialized")
end

hook.Add("InitPostEntity", "MB.Library.Fonts.Init", function()
    MB.Library.Fonts.Initialize()
end) 