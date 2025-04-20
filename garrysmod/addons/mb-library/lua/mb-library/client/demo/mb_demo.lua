MB.Library.Demo = MB.Library.Demo or {}

function MB.Library.Demo.Initialize()
    concommand.Add("mb_demo", MB.Library.Demo.OpenDemo)
    
    MB.Library.Log("Demo module initialized")
end

function MB.Library.Demo.OpenDemo()
    if IsValid(MB.Library.Demo.Window) then
        MB.Library.Demo.Window:Remove()
    end
    
    local window = MB.Library.UI.CreateFrame("MontesBox Library Demo", 800, 600)
    MB.Library.Demo.Window = window
    
    local tabs = MB.Library.UI.CreateTabs(window, 10, 30, 780, 560)
    
    local basicPanel = MB.Library.UI.CreatePanel(nil, 0, 0, 780, 560)
    tabs:AddSheet("Basic UI", basicPanel, "icon16/application.png")
    
    MB.Library.UI.CreateLabel("This demo showcases various UI components from the MontesBox Library.", basicPanel, 20, 20, 740, 30)
    
    MB.Library.UI.CreateLabel("Buttons:", basicPanel, 20, 60, 100, 20)
    
    local normalBtn = MB.Library.UI.CreateButton("Normal Button", basicPanel, 20, 90, 150, 30)
    normalBtn.DoClick = function()
        MB.Library.UI.CreateNotice("Button Clicked", "You clicked the normal button!", 3)
    end
    
    local wideBtn = MB.Library.UI.CreateButton("Wide Button", basicPanel, 180, 90, 250, 30)
    wideBtn.DoClick = function()
        MB.Library.UI.CreateNotice("Button Clicked", "You clicked the wide button!", 3)
    end
    
    local tallBtn = MB.Library.UI.CreateButton("Tall\nButton", basicPanel, 440, 90, 100, 60)
    tallBtn.DoClick = function()
        MB.Library.UI.CreateNotice("Button Clicked", "You clicked the tall button!", 3)
    end
    
    MB.Library.UI.CreateLabel("Text Entries:", basicPanel, 20, 160, 100, 20)
    
    local textEntry1 = MB.Library.UI.CreateTextEntry("Editable text", basicPanel, 20, 190, 200, 30, "Enter text here")
    local textEntry2 = MB.Library.UI.CreateTextEntry("", basicPanel, 230, 190, 200, 30, "Placeholder text")
    
    local showTextBtn = MB.Library.UI.CreateButton("Show Text", basicPanel, 440, 190, 100, 30)
    showTextBtn.DoClick = function()
        MB.Library.UI.CreateNotice("Text Entry Content", "Text 1: " .. textEntry1:GetValue() .. "\nText 2: " .. textEntry2:GetValue(), 3)
    end
    
    MB.Library.UI.CreateLabel("Checkboxes:", basicPanel, 20, 230, 100, 20)
    
    local checkbox1 = MB.Library.UI.CreateCheckbox("Option 1", basicPanel, 20, 260, 200, 20)
    local checkbox2 = MB.Library.UI.CreateCheckbox("Option 2", basicPanel, 20, 290, 200, 20)
    local checkbox3 = MB.Library.UI.CreateCheckbox("Option 3", basicPanel, 20, 320, 200, 20)
    
    local checkBtn = MB.Library.UI.CreateButton("Check Status", basicPanel, 230, 290, 100, 30)
    checkBtn.DoClick = function()
        local status = "Option 1: " .. (checkbox1:GetChecked() and "Checked" or "Unchecked") .. 
                      "\nOption 2: " .. (checkbox2:GetChecked() and "Checked" or "Unchecked") .. 
                      "\nOption 3: " .. (checkbox3:GetChecked() and "Checked" or "Unchecked")
        MB.Library.UI.CreateNotice("Checkbox Status", status, 3)
    end
    
    MB.Library.UI.CreateLabel("ComboBox:", basicPanel, 20, 360, 100, 20)
    
    local comboBox = MB.Library.UI.CreateComboBox(basicPanel, 20, 390, 200, 30)
    comboBox:AddChoice("Option 1")
    comboBox:AddChoice("Option 2")
    comboBox:AddChoice("Option 3")
    comboBox:AddChoice("Option 4")
    
    MB.Library.UI.CreateLabel("Sliders:", basicPanel, 350, 260, 100, 20)
    
    local slider1 = MB.Library.UI.CreateSlider("Value", 0, 100, 0, basicPanel, 350, 290, 400, 30)
    local slider2 = MB.Library.UI.CreateSlider("Decimal", 0, 1, 2, basicPanel, 350, 320, 400, 30)
    
    local sliderBtn = MB.Library.UI.CreateButton("Get Values", basicPanel, 350, 360, 100, 30)
    sliderBtn.DoClick = function()
        local status = "Value: " .. slider1:GetValue() .. 
                      "\nDecimal: " .. slider2:GetValue()
        MB.Library.UI.CreateNotice("Slider Values", status, 3)
    end
    
    local dialogBtn = MB.Library.UI.CreateButton("Show Dialog", basicPanel, 20, 430, 150, 30)
    dialogBtn.DoClick = function()
        MB.Library.UI.CreateDialog("Example Dialog", "This is an example dialog with multiple button options.", {
            ["OK"] = function() MB.Library.UI.CreateNotice("Dialog", "OK pressed", 2) end,
            ["Cancel"] = function() MB.Library.UI.CreateNotice("Dialog", "Cancel pressed", 2) end,
            ["Help"] = function() MB.Library.UI.CreateNotice("Dialog", "Help pressed", 2) end
        })
    end
    
    local noticeBtn = MB.Library.UI.CreateButton("Show Notice", basicPanel, 180, 430, 150, 30)
    noticeBtn.DoClick = function()
        MB.Library.UI.CreateNotice("Example Notice", "This is an example notification that will automatically close after a few seconds.", 5)
    end
    
    local listsPanel = MB.Library.UI.CreatePanel(nil, 0, 0, 780, 560)
    tabs:AddSheet("Lists & Panels", listsPanel, "icon16/table.png")
    
    MB.Library.UI.CreateLabel("Scroll Panel:", listsPanel, 20, 20, 150, 20)
    
    local scrollPanel = MB.Library.UI.CreateScrollPanel(listsPanel, 20, 50, 350, 200)
    
    for i = 1, 20 do
        local panel = MB.Library.UI.CreatePanel(scrollPanel, 5, (i-1) * 40 + 5, 320, 35)
        MB.Library.UI.CreateLabel("Scroll Item " .. i, panel, 10, 8, 300, 20)
    end
    
    MB.Library.UI.CreateLabel("List View:", listsPanel, 400, 20, 150, 20)
    
    local listView = MB.Library.UI.CreateListView(listsPanel, 400, 50, 350, 200)
    
    listView:AddColumn("ID")
    listView:AddColumn("Name")
    listView:AddColumn("Value")
    
    for i = 1, 10 do
        listView:AddLine(i, "Item " .. i, math.random(1, 100))
    end
    
    MB.Library.UI.CreateLabel("Nested Panels:", listsPanel, 20, 270, 150, 20)
    
    local containerPanel = MB.Library.UI.CreatePanel(listsPanel, 20, 300, 730, 200)
    
    local nestedPanel1 = MB.Library.UI.CreatePanel(containerPanel, 10, 10, 230, 180)
    MB.Library.UI.CreateLabel("Panel 1", nestedPanel1, 10, 10, 210, 20)
    
    local button1 = MB.Library.UI.CreateButton("Button in Panel 1", nestedPanel1, 10, 40, 210, 30)
    button1.DoClick = function()
        MB.Library.UI.CreateNotice("Panel Button", "Button in Panel 1 clicked", 2)
    end
    
    local nestedPanel2 = MB.Library.UI.CreatePanel(containerPanel, 250, 10, 230, 180)
    MB.Library.UI.CreateLabel("Panel 2", nestedPanel2, 10, 10, 210, 20)
    
    local colorPicker = MB.Library.UI.CreateColorPicker(nestedPanel2, 10, 40, 210, 130)
    
    local nestedPanel3 = MB.Library.UI.CreatePanel(containerPanel, 490, 10, 230, 180)
    MB.Library.UI.CreateLabel("Panel 3", nestedPanel3, 10, 10, 210, 20)
    
    local getColorBtn = MB.Library.UI.CreateButton("Get Color", nestedPanel3, 10, 40, 210, 30)
    getColorBtn.DoClick = function()
        local color = colorPicker:GetColor()
        local hexColor = MB.Library.Colors.ColorToHex(color)
        MB.Library.UI.CreateNotice("Selected Color", "RGB: " .. color.r .. ", " .. color.g .. ", " .. color.b .. "\nHex: " .. hexColor, 3)
    end
    
    local themingPanel = MB.Library.UI.CreatePanel(nil, 0, 0, 780, 560)
    tabs:AddSheet("Theming", themingPanel, "icon16/color_wheel.png")
    
    MB.Library.UI.CreateLabel("Select Theme:", themingPanel, 20, 20, 150, 20)
    
    local themeCombo = MB.Library.UI.CreateComboBox(themingPanel, 20, 50, 200, 30)
    
    local themes = MB.Library.Themes.GetThemeNames()
    for _, themeName in ipairs(themes) do
        themeCombo:AddChoice(themeName)
    end
    
    themeCombo:SetValue(MB.Library.Themes.GetCurrentTheme())
    
    local applyThemeBtn = MB.Library.UI.CreateButton("Apply Theme", themingPanel, 230, 50, 120, 30)
    applyThemeBtn.DoClick = function()
        local selectedTheme = themeCombo:GetValue()
        MB.Library.Themes.SetTheme(selectedTheme)
        MB.Library.UI.CreateNotice("Theme Changed", "Applied theme: " .. selectedTheme, 2)
    end
    
    MB.Library.UI.CreateLabel("Theme Preview:", themingPanel, 20, 100, 150, 20)
    
    local function CreateColorSwatches()
        if IsValid(MB.Library.Demo.SwatchPanel) then
            MB.Library.Demo.SwatchPanel:Remove()
        end
        
        local swatchPanel = MB.Library.UI.CreatePanel(themingPanel, 20, 130, 730, 410)
        MB.Library.Demo.SwatchPanel = swatchPanel
        
        local colorKeys = {
            "primary", "secondary", "accent", "success", "warning", "danger",
            "background", "backgroundLight", "backgroundAlt", "text", "textAlt", "textMuted",
            "border"
        }
        
        local swatchSize = 100
        local padding = 10
        local columns = 6
        
        for i, colorKey in ipairs(colorKeys) do
            local color = MB.Library.Themes.GetColor(colorKey)
            
            local col = (i - 1) % columns
            local row = math.floor((i - 1) / columns)
            
            local x = col * (swatchSize + padding) + padding
            local y = row * (swatchSize + padding) + padding
            
            local swatch = MB.Library.UI.CreatePanel(swatchPanel, x, y, swatchSize, swatchSize)
            
            function swatch:Paint(w, h)
                surface.SetDrawColor(color)
                surface.DrawRect(0, 0, w, h)
                
                surface.SetDrawColor(255, 255, 255, 50)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                
                draw.SimpleText(colorKey, "MB.Font.Small", w/2, h - 15, MB.Library.Colors.GetContrastColor(color), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                local hexColor = MB.Library.Colors.ColorToHex(color)
                draw.SimpleText(hexColor, "MB.Font.Small", w/2, 15, MB.Library.Colors.GetContrastColor(color), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        
        return swatchPanel
    end
    
    CreateColorSwatches()
    
    hook.Add("MB.Library.ThemeChanged", "MB.Library.Demo.UpdateSwatches", function()
        CreateColorSwatches()
        themeCombo:SetValue(MB.Library.Themes.GetCurrentTheme())
    end)
    
    local aboutPanel = MB.Library.UI.CreatePanel(nil, 0, 0, 780, 560)
    tabs:AddSheet("About", aboutPanel, "icon16/information.png")
    
    MB.Library.UI.CreateLabel("MontesBox Library", aboutPanel, 20, 20, 740, 30, 5)
    
    local version = MB.Library.Version or "Unknown"
    MB.Library.UI.CreateLabel("Version: " .. version, aboutPanel, 20, 60, 740, 20)
    
    MB.Library.UI.CreateLabel("Description:", aboutPanel, 20, 90, 740, 20)
    MB.Library.UI.CreateLabel("MontesBox Library is a comprehensive utility library for Garry's Mod, providing UI elements, theme management, graphics utilities, and more.", aboutPanel, 20, 110, 740, 40)
    
    MB.Library.UI.CreateLabel("Loaded Modules:", aboutPanel, 20, 160, 740, 20)
    
    local modules = {
        "UI Components",
        "Theme Management",
        "Graphics Utilities",
        "Color Management",
        "Configuration System"
    }
    
    for i, module in ipairs(modules) do
        MB.Library.UI.CreateLabel("• " .. module, aboutPanel, 40, 160 + i * 25, 740, 20)
    end
    
    MB.Library.UI.CreateLabel("Credits:", aboutPanel, 20, 320, 740, 20)
    MB.Library.UI.CreateLabel("Created by MontesBox Team", aboutPanel, 40, 340, 740, 20)
    MB.Library.UI.CreateLabel("Special thanks to the Garry's Mod community", aboutPanel, 40, 360, 740, 20)
    
    MB.Library.UI.CreateLabel("Visit our GitHub repository for documentation and updates:", aboutPanel, 20, 400, 740, 20)
    
    local githubLink = MB.Library.UI.CreateTextEntry("https://github.com/MontesBox/mb-library", aboutPanel, 20, 420, 400, 30)
    githubLink:SetEditable(false)
    
    window.OnRemove = function()
        hook.Remove("MB.Library.ThemeChanged", "MB.Library.Demo.UpdateSwatches")
        MB.Library.Demo.Window = nil
    end
end

hook.Add("Initialize", "MB.Library.Demo.Initialize", MB.Library.Demo.Initialize) 