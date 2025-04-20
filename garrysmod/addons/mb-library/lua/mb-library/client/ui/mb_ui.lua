MB.Library.UI = MB.Library.UI or {}
MB.Library.UI.Panels = MB.Library.UI.Panels or {}
MB.Library.UI.Registered = MB.Library.UI.Registered or {}
MB.Library.UI.ActiveMenu = nil

function MB.Library.UI.Initialize()
    MB.Library.UI.RegisterElements()
    
    hook.Add("MB.Library.ThemeChanged", "MB.Library.UI.UpdateTheme", function(theme)
        MB.Library.UI.UpdateAllPanels()
    end)
    
    MB.Library.Log("UI module initialized")
end

function MB.Library.UI.RegisterPanel(panel, id)
    if not IsValid(panel) then return end
    
    id = id or "panel_" .. math.random(1000000, 9999999)
    
    MB.Library.UI.Panels[id] = panel
    
    if panel.CallOnRemove then
        panel:CallOnRemove("MB.Library.UI.UnregisterPanel", function()
            MB.Library.UI.Panels[id] = nil
        end)
    else
        hook.Add("Think", "MB.Library.UI.CheckPanel_" .. id, function()
            if not IsValid(panel) then
                MB.Library.UI.Panels[id] = nil
                hook.Remove("Think", "MB.Library.UI.CheckPanel_" .. id)
            end
        end)
    end
    
    return id
end

function MB.Library.UI.UpdateAllPanels()
    for id, panel in pairs(MB.Library.UI.Panels) do
        if IsValid(panel) then
            if panel.ApplyTheme then
                panel:ApplyTheme()
            else
                MB.Library.Themes.ApplyThemeToPanel(panel)
            end
        else
            MB.Library.UI.Panels[id] = nil
        end
    end
end

function MB.Library.UI.CreateFrame(title, width, height, parent)
    local frame = vgui.Create("DFrame", parent)
    frame:SetTitle(title or "")
    frame:SetSize(width or 800, height or 600)
    frame:SetDraggable(true)
    frame:SetSizable(true)
    frame:Center()
    frame:MakePopup()
    
    local theme = MB.Library.Themes.GetTheme()
    
    frame.lblTitle:SetFont("MB.Font.Medium")
    frame.lblTitle:SetColor(theme.colors.text)
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.background)
        surface.SetDrawColor(theme.colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        draw.RoundedBoxEx(theme.borderRadius, 0, 0, w, 30, theme.colors.backgroundDark, true, true, false, false)
    end
    
    MB.Library.UI.RegisterPanel(frame)
    
    frame.btnClose.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, theme.colors.danger)
        else
            draw.RoundedBox(4, 0, 0, w, h, theme.colors.accent)
        end
        
        draw.SimpleText("×", "MB.Font.Medium", w/2, h/2, theme.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return true
    end
    
    if frame.btnMaxim then frame.btnMaxim:SetVisible(false) end
    if frame.btnMinim then frame.btnMinim:SetVisible(false) end
    
    return frame
end

function MB.Library.UI.CreateButton(text, parent, x, y, width, height)
    local button = vgui.Create("DButton", parent)
    button:SetText(text or "")
    button:SetPos(x or 0, y or 0)
    button:SetSize(width or 100, height or 30)
    button:SetTextColor(MB.Library.Themes.GetColor("button").text)
    button:SetFont("MB.Font.Normal")
    
    local theme = MB.Library.Themes.GetTheme()
    
    button.Paint = function(self, w, h)
        local color
        
        if not IsValid(self) then
            color = theme.colors.button.bg
        elseif self.IsDisabled and self:IsDisabled() then
            color = theme.colors.states.disabled
        elseif self.IsDown and self:IsDown() then
            color = theme.colors.button.active
        elseif self.IsHovered and self:IsHovered() then
            color = theme.colors.button.hover
        else
            color = theme.colors.button.bg
        end
        
        draw.RoundedBox(theme.borderRadius, 0, 0, w, h, color)
    end
    
    MB.Library.UI.RegisterPanel(button)
    
    return button
end

function MB.Library.UI.CreatePanel(parent, x, y, width, height)
    local panel = vgui.Create("DPanel", parent)
    panel:SetPos(x or 0, y or 0)
    panel:SetSize(width or 100, height or 100)
    
    local theme = MB.Library.Themes.GetTheme()
    
    panel.Paint = function(self, w, h)
        draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.card)
    end
    
    MB.Library.UI.RegisterPanel(panel)
    
    return panel
end

function MB.Library.UI.CreateScrollPanel(parent, x, y, width, height)
    local scrollPanel = vgui.Create("DScrollPanel", parent)
    scrollPanel:SetPos(x or 0, y or 0)
    scrollPanel:SetSize(width or 100, height or 100)
    
    local scrollBar = scrollPanel:GetVBar()
    scrollBar:SetHideButtons(true)
    
    local theme = MB.Library.Themes.GetTheme()
    
    function scrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, theme.colors.scrollbar.bg)
    end
    
    function scrollBar.btnGrip:Paint(w, h)
        if self:IsHovered() or self.Depressed then
            draw.RoundedBox(4, 0, 0, w, h, theme.colors.scrollbar.thumbHover)
        else
            draw.RoundedBox(4, 0, 0, w, h, theme.colors.scrollbar.thumb)
        end
    end
    
    scrollPanel.Paint = function(self, w, h)
        draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.backgroundLight)
    end
    
    MB.Library.UI.RegisterPanel(scrollPanel)
    
    return scrollPanel
end

function MB.Library.UI.CreateLabel(text, parent, x, y, width, height, align)
    local label = vgui.Create("DLabel", parent)
    label:SetText(text or "")
    label:SetPos(x or 0, y or 0)
    label:SetSize(width or 100, height or 20)
    label:SetTextColor(MB.Library.Themes.GetColor("text"))
    label:SetFont("MB.Font.Normal")
    
    if align then
        label:SetContentAlignment(align)
    end
    
    MB.Library.UI.RegisterPanel(label)
    
    function label:ApplyTheme()
        self:SetTextColor(MB.Library.Themes.GetColor("text"))
    end
    
    return label
end

function MB.Library.UI.CreateCheckbox(text, parent, x, y, width, height)
    local checkbox = vgui.Create("DCheckBoxLabel", parent)
    checkbox:SetText(text or "")
    checkbox:SetPos(x or 0, y or 0)
    checkbox:SetSize(width or 200, height or 20)
    checkbox:SetTextColor(MB.Library.Themes.GetColor("text"))
    checkbox:SetFont("MB.Font.Normal")
    
    local theme = MB.Library.Themes.GetTheme()
    
    function checkbox.Button:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, theme.colors.input.bg)
        
        surface.SetDrawColor(theme.colors.input.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        if self:GetChecked() then
            draw.RoundedBox(2, 3, 3, w-6, h-6, theme.colors.accent)
        end
    end
    
    MB.Library.UI.RegisterPanel(checkbox)
    
    function checkbox:ApplyTheme()
        self:SetTextColor(MB.Library.Themes.GetColor("text"))
    end
    
    return checkbox
end

function MB.Library.UI.CreateTextEntry(defaultText, parent, x, y, width, height, placeholder)
    local textEntry = vgui.Create("DTextEntry", parent)
    textEntry:SetPos(x or 0, y or 0)
    textEntry:SetSize(width or 200, height or 30)
    textEntry:SetText(defaultText or "")
    textEntry:SetPlaceholderText(placeholder or "")
    textEntry:SetFont("MB.Font.Normal")
    
    local theme = MB.Library.Themes.GetTheme()
    
    textEntry.Paint = function(self, w, h)
        draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.input.bg)
        
        if self:HasFocus() then
            surface.SetDrawColor(theme.colors.input.borderFocus)
        else
            surface.SetDrawColor(theme.colors.input.border)
        end
        
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        self:DrawTextEntryText(
            theme.colors.input.text,
            theme.colors.accent,
            theme.colors.input.text
        )
        
        if self:GetText() == "" and self:GetPlaceholderText() ~= "" and not self:HasFocus() then
            draw.SimpleText(
                self:GetPlaceholderText(),
                self:GetFont(),
                5,
                h/2,
                theme.colors.input.placeholder,
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
            )
        end
    end
    
    MB.Library.UI.RegisterPanel(textEntry)
    
    return textEntry
end

function MB.Library.UI.CreateComboBox(parent, x, y, width, height)
    local comboBox = vgui.Create("DComboBox", parent)
    comboBox:SetPos(x or 0, y or 0)
    comboBox:SetSize(width or 200, height or 30)
    comboBox:SetValue("")
    comboBox:SetFont("MB.Font.Normal")
    comboBox:SetTextColor(MB.Library.Themes.GetColor("text"))
    
    local theme = MB.Library.Themes.GetTheme()
    
    function comboBox:Paint(w, h)
        draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.input.bg)
        surface.SetDrawColor(theme.colors.input.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        surface.SetDrawColor(theme.colors.input.text)
        surface.SetMaterial(Material("icon16/bullet_arrow_down.png"))
        surface.DrawTexturedRect(w - 20, h/2 - 8, 16, 16)
    end
    
    function comboBox:OpenMenu()
        if IsValid(self.Menu) then
            self.Menu:Remove()
            self.Menu = nil
        end
        
        self.Menu = DermaMenu(false, self)
        self.Menu:SetDrawBackground(false)
        
        for k, v in pairs(self.Choices) do
            local option = self.Menu:AddOption(v, function() self:ChooseOption(v, k) end)
            option:SetFont("MB.Font.Normal")
            option:SetTextColor(theme.colors.text)
            
            function option:Paint(w, h)
                if self:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, theme.colors.accent)
                else
                    draw.RoundedBox(0, 0, 0, w, h, theme.colors.card)
                end
            end
        end
        
        local x, y = self:LocalToScreen(0, self:GetTall())
        self.Menu:SetMinimumWidth(self:GetWide())
        self.Menu:Open(x, y, false, self)
        
        self.Menu.Paint = function(pnl, w, h)
            draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.card)
            surface.SetDrawColor(theme.colors.border)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
    end
    
    MB.Library.UI.RegisterPanel(comboBox)
    
    return comboBox
end

function MB.Library.UI.CreateSlider(text, parent, x, y, width, height, min, max, decimals)
    local slider = vgui.Create("DNumSlider", parent)
    slider:SetPos(x or 0, y or 0)
    slider:SetSize(width or 200, height or 40)
    slider:SetText(text or "")
    slider:SetMin(min or 0)
    slider:SetMax(max or 100)
    slider:SetDecimals(decimals or 0)
    
    local theme = MB.Library.Themes.GetTheme()
    
    slider.Label:SetTextColor(theme.colors.text)
    slider.Label:SetFont("MB.Font.Normal")
    
    slider.TextArea:SetTextColor(theme.colors.text)
    slider.TextArea:SetFont("MB.Font.Normal")
    
    function slider.Slider.Knob:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, theme.colors.accent)
    end
    
    function slider.Slider:Paint(w, h)
        draw.RoundedBox(0, 8, h/2 - 1, w - 16, 2, theme.colors.border)
        draw.RoundedBox(0, 8, h/2 - 1, (self:GetSlideX() / self:GetWide()) * (w - 16), 2, theme.colors.accent)
    end
    
    MB.Library.UI.RegisterPanel(slider)
    
    return slider
end

function MB.Library.UI.CreateTabPanel(parent, x, y, width, height)
    local tabPanel = vgui.Create("DPropertySheet", parent)
    tabPanel:SetPos(x or 0, y or 0)
    tabPanel:SetSize(width or 400, height or 300)
    
    local theme = MB.Library.Themes.GetTheme()
    
    function tabPanel:Paint(w, h)
        draw.RoundedBoxEx(theme.borderRadius, 0, 24, w, h - 24, theme.colors.card, false, false, true, true)
    end
    
    function tabPanel.tabScroller:Paint(w, h)
        draw.RoundedBoxEx(theme.borderRadius, 0, 0, w, h, theme.colors.backgroundDark, true, true, false, false)
    end
    
    local oldAddSheet = tabPanel.AddSheet
    function tabPanel:AddSheet(label, panel, material, noStretchX, noStretchY, tooltip)
        local sheet = oldAddSheet(self, label, panel, material, noStretchX, noStretchY, tooltip)
        
        sheet.Tab:SetFont("MB.Font.Normal")
        sheet.Tab:SetTextColor(theme.colors.text)
        
        function sheet.Tab:Paint(w, h)
            if self:IsActive() then
                draw.RoundedBox(0, 0, 0, w, h, theme.colors.accent)
            elseif self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, theme.colors.states.hover)
            end
        end
        
        return sheet
    end
    
    MB.Library.UI.RegisterPanel(tabPanel)
    
    return tabPanel
end

function MB.Library.UI.CreateListView(parent, x, y, width, height, multiSelect)
    local listView = vgui.Create("DListView", parent)
    listView:SetPos(x or 0, y or 0)
    listView:SetSize(width or 400, height or 300)
    listView:SetMultiSelect(multiSelect or false)
    
    local theme = MB.Library.Themes.GetTheme()
    
    function listView:Paint(w, h)
        draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.backgroundLight)
        surface.SetDrawColor(theme.colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    local oldAddColumn = listView.AddColumn
    listView.AddColumn = function(self, columnName, ...)
        local column = oldAddColumn(self, columnName, ...)
        
        if IsValid(column) and IsValid(column.Header) then
            column.Header:SetTextColor(theme.colors.text)
            column.Header:SetFont("MB.Font.Normal")
            
            function column.Header:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, theme.colors.backgroundDark)
            end
        end
        
        return column
    end
    
    local scrollBar = listView.VBar
    scrollBar:SetHideButtons(true)
    
    function scrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, theme.colors.scrollbar.bg)
    end
    
    function scrollBar.btnGrip:Paint(w, h)
        if self:IsHovered() or self.Depressed then
            draw.RoundedBox(4, 0, 0, w, h, theme.colors.scrollbar.thumbHover)
        else
            draw.RoundedBox(4, 0, 0, w, h, theme.colors.scrollbar.thumb)
        end
    end
    
    function listView:OnRowSelected(rowIndex, row)
        for _, line in pairs(self.Lines) do
            if line == row then
                line.m_bAlt = true
                line.Paint = function(self, w, h)
                    if self:IsLineSelected() then
                        draw.RoundedBox(0, 0, 0, w, h, theme.colors.accent)
                    elseif self:IsHovered() then
                        draw.RoundedBox(0, 0, 0, w, h, theme.colors.states.hover)
                    elseif self.m_bAlt then
                        draw.RoundedBox(0, 0, 0, w, h, theme.colors.backgroundDark)
                    end
                end
            end
        end
    end
    
    MB.Library.UI.RegisterPanel(listView)
    
    return listView
end

function MB.Library.UI.CreateColorPicker(parent, x, y, width, height, defaultColor)
    local colorPicker = vgui.Create("DColorMixer", parent)
    colorPicker:SetPos(x or 0, y or 0)
    colorPicker:SetSize(width or 250, height or 200)
    colorPicker:SetAlphaBar(true)
    colorPicker:SetPalette(false)
    
    if defaultColor then
        colorPicker:SetColor(defaultColor)
    end
    
    local theme = MB.Library.Themes.GetTheme()
    
    MB.Library.UI.RegisterPanel(colorPicker)
    
    return colorPicker
end

function MB.Library.UI.CreateNotice(title, text, duration)
    duration = duration or 5
    
    MB.Library.Notifications.Add(title, text, NOTIFY_GENERIC, duration)
end

function MB.Library.UI.CreateDialog(title, text, options)
    options = options or {}
    
    local frame = MB.Library.UI.CreateFrame(title, 400, 180)
    
    local label = MB.Library.UI.CreateLabel(text, frame, 20, 40, 360, 60)
    label:SetWrap(true)
    
    local buttonCount = 0
    local buttonWidth = 100
    local buttonSpacing = 10
    local totalWidth = 0
    
    for _, __ in pairs(options) do
        buttonCount = buttonCount + 1
    end
    
    if buttonCount == 0 then
        options = {
            ["OK"] = function() frame:Close() end
        }
        buttonCount = 1
    end
    
    totalWidth = (buttonWidth * buttonCount) + (buttonSpacing * (buttonCount - 1))
    local startX = (frame:GetWide() - totalWidth) / 2
    local buttonY = frame:GetTall() - 60
    
    local i = 0
    for text, func in pairs(options) do
        local button = MB.Library.UI.CreateButton(text, frame, 
            startX + (i * (buttonWidth + buttonSpacing)), 
            buttonY, 
            buttonWidth, 
            30)
        
        button.DoClick = function()
            if func then
                func()
            end
        end
        
        i = i + 1
    end
    
    return frame
end

function MB.Library.UI.CreateProgressBar(parent, x, y, width, height, progress, color)
    local progressBar = vgui.Create("DPanel", parent)
    progressBar:SetPos(x or 0, y or 0)
    progressBar:SetSize(width or 200, height or 20)
    
    local theme = MB.Library.Themes.GetTheme()
    local barColor = color or theme.colors.accent
    
    progressBar.progress = progress or 0
    
    progressBar.SetProgress = function(self, value)
        self.progress = math.Clamp(value, 0, 1)
    end
    
    progressBar.GetProgress = function(self)
        return self.progress
    end
    
    progressBar.SetColor = function(self, col)
        barColor = col
    end
    
    progressBar.Paint = function(self, w, h)
        draw.RoundedBox(theme.borderRadius, 0, 0, w, h, theme.colors.input.bg)
        
        local progressWidth = w * self.progress
        if progressWidth > 0 then
            draw.RoundedBox(theme.borderRadius, 0, 0, progressWidth, h, barColor)
        end
        
        surface.SetDrawColor(theme.colors.input.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    MB.Library.UI.RegisterPanel(progressBar)
    
    return progressBar
end

function MB.Library.UI.CreateIconButton(icon, parent, x, y, size, tooltip)
    local button = vgui.Create("DButton", parent)
    button:SetPos(x or 0, y or 0)
    button:SetSize(size or 32, size or 32)
    button:SetText("")
    button:SetTooltip(tooltip or "")
    
    local theme = MB.Library.Themes.GetTheme()
    
    button.Paint = function(self, w, h)
        local color
        
        if not IsValid(self) then
            color = theme.colors.button.bg
        elseif self.IsDisabled and self:IsDisabled() then
            color = theme.colors.states.disabled
        elseif self.IsDown and self:IsDown() then
            color = theme.colors.button.active
        elseif self.IsHovered and self:IsHovered() then
            color = theme.colors.button.hover
        else
            color = theme.colors.button.bg
        end
        
        draw.RoundedBox(theme.borderRadius, 0, 0, w, h, color)
        
        if icon then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material(icon))
            surface.DrawTexturedRect(w/2 - 8, h/2 - 8, 16, 16)
        end
    end
    
    MB.Library.UI.RegisterPanel(button)
    
    return button
end

function MB.Library.UI.RegisterElements()
    hook.Add("Initialize", "MB.Library.UI.RegisterFonts", function()
        for i = 8, 48, 2 do
            surface.CreateFont("MB.UI." .. i, {
                font = "Roboto",
                size = i,
                weight = 500,
                antialias = true,
                extended = true
            })
            
            surface.CreateFont("MB.UI.Bold." .. i, {
                font = "Roboto Bold",
                size = i,
                weight = 700,
                antialias = true,
                extended = true
            })
        end
        
        surface.CreateFont("MB.UI.Tiny", { font = "Roboto", size = 10, weight = 500, antialias = true, extended = true })
        surface.CreateFont("MB.UI.Small", { font = "Roboto", size = 14, weight = 500, antialias = true, extended = true })
        surface.CreateFont("MB.UI.Normal", { font = "Roboto", size = 16, weight = 500, antialias = true, extended = true })
        surface.CreateFont("MB.UI.Medium", { font = "Roboto", size = 18, weight = 500, antialias = true, extended = true })
        surface.CreateFont("MB.UI.Large", { font = "Roboto", size = 22, weight = 500, antialias = true, extended = true })
        surface.CreateFont("MB.UI.Title", { font = "Roboto", size = 24, weight = 500, antialias = true, extended = true })
        surface.CreateFont("MB.UI.Button", { font = "Roboto", size = 16, weight = 500, antialias = true, extended = true })
        
        MB.Library.Log("UI fonts created")
    end)
end

hook.Add("MB.Library.Initialize", "MB.Library.UI.Init", function()
    MB.Library.UI.Initialize()
end) 