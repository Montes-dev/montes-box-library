MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Themes = MB.Library.Themes or {}

MB.Library.Themes.Current = "dark_modern"

MB.Library.Themes.Available = {
    light = {
        name = "Light",
        colors = {
            primary = Color(25, 118, 210),
            secondary = Color(156, 39, 176),
            success = Color(76, 175, 80),
            warning = Color(255, 152, 0),
            danger = Color(244, 67, 54),
            info = Color(3, 169, 244),
            
            background = Color(255, 255, 255),
            card = Color(250, 250, 250),
            border = Color(230, 230, 230),
            overlay = Color(0, 0, 0, 100),
            shadow = Color(0, 0, 0, 30),
            
            text = {
                primary = Color(33, 33, 33),
                secondary = Color(97, 97, 97),
                disabled = Color(189, 189, 189),
                hint = Color(158, 158, 158)
            },
            
            states = {
                hover = Color(0, 0, 0, 15),
                active = Color(0, 0, 0, 30),
                selected = Color(25, 118, 210, 20),
                disabled = Color(0, 0, 0, 10)
            }
        },
        
        borderRadius = 4,
        shadowSize = 5,
        shadowOffset = 2,
        
        spacing = {
            xs = 4,
            sm = 8,
            md = 16,
            lg = 24,
            xl = 32
        },
        
        typography = {
            fontFamily = "Roboto",
            sizes = {
                h1 = 24,
                h2 = 20,
                h3 = 18,
                h4 = 16,
                body = 14,
                small = 12,
                xs = 10
            },
            weights = {
                light = 300,
                regular = 400,
                medium = 500,
                bold = 700
            }
        }
    },
    
    dark = {
        name = "Dark",
        colors = {
            primary = Color(33, 150, 243),
            secondary = Color(156, 39, 176),
            success = Color(76, 175, 80),
            warning = Color(255, 152, 0),
            danger = Color(244, 67, 54),
            info = Color(3, 169, 244),
            
            background = Color(33, 33, 33),
            card = Color(45, 45, 45),
            border = Color(55, 55, 55),
            overlay = Color(0, 0, 0, 150),
            shadow = Color(0, 0, 0, 80),
            
            text = {
                primary = Color(255, 255, 255),
                secondary = Color(200, 200, 200),
                disabled = Color(150, 150, 150),
                hint = Color(170, 170, 170)
            },
            
            states = {
                hover = Color(255, 255, 255, 15),
                active = Color(255, 255, 255, 30),
                selected = Color(33, 150, 243, 20),
                disabled = Color(255, 255, 255, 10)
            }
        },
        
        borderRadius = 4,
        shadowSize = 5,
        shadowOffset = 2,
        
        spacing = {
            xs = 4,
            sm = 8,
            md = 16,
            lg = 24,
            xl = 32
        },
        
        typography = {
            fontFamily = "Roboto",
            sizes = {
                h1 = 24,
                h2 = 20,
                h3 = 18,
                h4 = 16,
                body = 14,
                small = 12,
                xs = 10
            },
            weights = {
                light = 300,
                regular = 400,
                medium = 500,
                bold = 700
            }
        }
    },
    
    midnight = {
        name = "Midnight",
        colors = {
            primary = Color(100, 180, 255),
            secondary = Color(149, 117, 205),
            success = Color(130, 209, 130),
            warning = Color(255, 183, 77),
            danger = Color(229, 115, 115),
            info = Color(86, 182, 228),
            
            background = Color(18, 18, 30),
            card = Color(30, 30, 40),
            border = Color(40, 40, 50),
            overlay = Color(0, 0, 0, 170),
            shadow = Color(0, 0, 0, 100),
            
            text = {
                primary = Color(230, 230, 250),
                secondary = Color(190, 190, 210),
                disabled = Color(140, 140, 160),
                hint = Color(160, 160, 180)
            },
            
            states = {
                hover = Color(255, 255, 255, 10),
                active = Color(255, 255, 255, 20),
                selected = Color(100, 180, 255, 20),
                disabled = Color(255, 255, 255, 5)
            }
        },
        
        borderRadius = 4,
        shadowSize = 5,
        shadowOffset = 2,
        
        spacing = {
            xs = 4,
            sm = 8,
            md = 16,
            lg = 24,
            xl = 32
        },
        
        typography = {
            fontFamily = "Roboto",
            sizes = {
                h1 = 24,
                h2 = 20,
                h3 = 18,
                h4 = 16,
                body = 14,
                small = 12,
                xs = 10
            },
            weights = {
                light = 300,
                regular = 400,
                medium = 500,
                bold = 700
            }
        }
    },
    
    dark_modern = {
        name = "Dark Modern",
        colors = {
            primary = Color(180, 30, 30),
            secondary = Color(120, 20, 20),
            success = Color(46, 204, 113),
            warning = Color(241, 196, 15),
            danger = Color(231, 76, 60),
            info = Color(52, 152, 219),
            
            background = Color(25, 25, 30),
            backgroundAlt = Color(30, 30, 35),
            backgroundDark = Color(20, 20, 25),
            backgroundLight = Color(35, 35, 40),
            card = Color(35, 35, 40),
            border = Color(45, 45, 50),
            overlay = Color(0, 0, 0, 180),
            shadow = Color(0, 0, 0, 100),
            
            accent = Color(180, 30, 30),
            accentHover = Color(200, 40, 40),
            accentPress = Color(160, 20, 20),
            
            text = Color(230, 230, 230),
            textSecondary = Color(200, 200, 200),
            textMuted = Color(150, 150, 150),
            textDisabled = Color(120, 120, 120),
            
            button = {
                bg = Color(180, 30, 30),
                hover = Color(200, 40, 40),
                active = Color(160, 20, 20),
                text = Color(255, 255, 255)
            },
            
            input = {
                bg = Color(40, 40, 45),
                border = Color(60, 60, 65),
                borderFocus = Color(180, 30, 30),
                text = Color(230, 230, 230),
                placeholder = Color(150, 150, 150)
            },
            
            scrollbar = {
                bg = Color(40, 40, 45),
                thumb = Color(70, 70, 75),
                thumbHover = Color(90, 90, 95)
            },
            
            states = {
                hover = Color(255, 255, 255, 15),
                active = Color(255, 255, 255, 20),
                selected = Color(180, 30, 30, 30),
                disabled = Color(255, 255, 255, 5)
            }
        },
        
        borderRadius = 6,
        shadowSize = 6,
        shadowOffset = 2,
        
        spacing = {
            xs = 4,
            sm = 8,
            md = 16,
            lg = 24,
            xl = 32
        },
        
        typography = {
            fontFamily = "MB.Font",
            sizes = {
                h1 = 28,
                h2 = 24,
                h3 = 20,
                h4 = 18,
                body = 16,
                small = 14,
                xs = 12
            },
            weights = {
                light = 300,
                regular = 400,
                medium = 500,
                bold = 700
            }
        }
    }
}

MB.Library.Themes.Subscribers = {}

function MB.Library.Themes.Set(themeName)
    if not MB.Library.Themes.Available[themeName] then
        MB.Library.Log("Theme '" .. themeName .. "' not found, using default")
        themeName = "dark_modern"
    end
    
    MB.Library.Themes.Current = themeName
    
    hook.Run("MB.Library.ThemeChanged", themeName)
    
    for _, subscriber in ipairs(MB.Library.Themes.Subscribers) do
        if isfunction(subscriber) then
            subscriber(themeName)
        end
    end
    
    return true
end

function MB.Library.Themes.Subscribe(callback)
    if not isfunction(callback) then return false end
    
    table.insert(MB.Library.Themes.Subscribers, callback)
    
    return true
end

function MB.Library.Themes.Unsubscribe(callback)
    for k, v in ipairs(MB.Library.Themes.Subscribers) do
        if v == callback then
            table.remove(MB.Library.Themes.Subscribers, k)
            return true
        end
    end
    
    return false
end

function MB.Library.Themes.GetCurrent()
    return MB.Library.Themes.Current
end

function MB.Library.Themes.GetTheme(themeName)
    themeName = themeName or MB.Library.Themes.Current
    
    return MB.Library.Themes.Available[themeName]
end

function MB.Library.Themes.GetValue(key, themeName)
    local theme = MB.Library.Themes.GetTheme(themeName)
    
    if not theme then
        return nil
    end
    
    local parts = string.Split(key, ".")
    local value = theme
    
    for _, part in ipairs(parts) do
        if not value[part] then
            return nil
        end
        
        value = value[part]
    end
    
    return value
end

function MB.Library.Themes.GetColor(key, themeName)
    local color = MB.Library.Themes.GetValue("colors." .. key, themeName)
    
    if not color then
        MB.Library.Log("Color '" .. key .. "' not found in theme")
        return Color(255, 255, 255)
    end
    
    return color
end

function MB.Library.Themes.ApplyThemeToPanel(panel, themeName)
    if not IsValid(panel) then return end
    
    local theme = MB.Library.Themes.GetTheme(themeName)
    
    if not theme then
        MB.Library.Log("Theme '" .. (themeName or "nil") .. "' not found")
        return
    end
    
    if panel.ApplyCustomTheme then
        panel:ApplyCustomTheme(theme)
        return
    end
    
    local panelClass = panel:GetClassName()
    
    if panelClass == "DFrame" then
        panel.Paint = function(self, w, h)
            draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.background)
            surface.SetDrawColor(theme.colors.border)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
        
        if panel.lblTitle then
            panel.lblTitle:SetTextColor(theme.colors.text)
            panel.lblTitle:SetFont("MB.Font.Title")
        end
        
        if panel.btnClose then
            panel.btnClose.Paint = function(self, w, h)
                if self:IsHovered() then
                    draw.RoundedBox(4, 0, 0, w, h, theme.colors.danger)
                else
                    draw.RoundedBox(4, 0, 0, w, h, theme.colors.accent)
                end
                
                draw.SimpleText("×", "MB.Font.Title", w/2, h/2, theme.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                return true
            end
        end
        
        if panel.btnMaxim then
            panel.btnMaxim:SetVisible(false)
        end
        
        if panel.btnMinim then
            panel.btnMinim:SetVisible(false)
        end
    elseif panelClass == "DButton" then
        panel:SetTextColor(theme.colors.button.text)
        
        panel.Paint = function(self, w, h)
            if self:IsDisabled() then
                draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.states.disabled)
            elseif self:IsDown() then
                draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.button.active)
            elseif self:IsHovered() then
                draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.button.hover)
            else
                draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.button.bg)
            end
        end
    elseif panelClass == "DPanel" then
        panel.Paint = function(self, w, h)
            draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.card)
        end
    elseif panelClass == "DTextEntry" then
        panel:SetTextColor(theme.colors.input.text)
        panel:SetFont("MB.Font.Normal")
        
        panel:SetPlaceholderColor(theme.colors.input.placeholder)
        
        panel.Paint = function(self, w, h)
            draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.input.bg)
            
            if self:HasFocus() then
                surface.SetDrawColor(theme.colors.input.borderFocus)
            else
                surface.SetDrawColor(theme.colors.input.border)
            end
            
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            self:DrawTextEntryText(self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor())
        end
    elseif panelClass == "DComboBox" then
        panel:SetTextColor(theme.colors.text)
        
        panel.Paint = function(self, w, h)
            draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.input.bg)
            surface.SetDrawColor(theme.colors.input.border)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
    end
end

function MB.Library.Themes.Initialize()
    MB.Library.Log("Initializing themes system")
    
    hook.Add("Think", "MB.Library.Themes.Override", function()
        local isHookActive = hook.GetTable()["ApplyThemeColors"] or false
        
        if isHookActive then
            hook.Remove("ApplyThemeColors", "Apply Theme Colors")
        end
    end)
end

hook.Add("MB.Library.Initialize", "MB.Library.Themes.Init", function()
    MB.Library.Themes.Initialize()
end)