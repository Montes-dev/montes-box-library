MB.Library = MB.Library or {}
MB.Library.Panel = MB.Library.Panel or {}

local PANEL = {}

function PANEL:Init()
    self:SetSize(500, 400)
    self:Center()
    self:MakePopup()
    self:SetTitle("MB Panel")
    self:SetDraggable(true)
    self:SetSizable(true)
    
    self.headerHeight = 35
    self.footerHeight = 40
    self.theme = MB.Library.Themes.GetTheme()
    
    self.closeButton = vgui.Create("DButton", self)
    self.closeButton:SetSize(20, 20)
    self.closeButton:SetText("")
    
    self.closeButton.Paint = function(s, w, h)
        if s:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, self.theme.colors.danger)
        else
            draw.RoundedBox(4, 0, 0, w, h, self.theme.colors.accent)
        end
        
        draw.SimpleText("×", "MB.Font.Medium", w/2, h/2, self.theme.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    self.closeButton.DoClick = function()
        self:Close()
    end
    
    self.content = vgui.Create("DPanel", self)
    self.content.Paint = function(s, w, h)
    end
    
    self.footer = vgui.Create("DPanel", self)
    self.footer.Paint = function(s, w, h) 
        draw.RoundedBoxEx(self.theme.borderRadius, 0, 0, w, h, self.theme.colors.backgroundDark, false, false, true, true)
    end
    
    self:PerformLayout()
    self:ApplyTheme()
end

function PANEL:PerformLayout()
    local w, h = self:GetSize()
    
    self.closeButton:SetPos(w - 30, 8)
    
    self.content:SetSize(w, h - self.headerHeight - self.footerHeight)
    self.content:SetPos(0, self.headerHeight)
    
    self.footer:SetSize(w, self.footerHeight)
    self.footer:SetPos(0, h - self.footerHeight)
end

function PANEL:ApplyTheme()
    self.lblTitle:SetFont("MB.Font.Medium")
    self.lblTitle:SetColor(self.theme.colors.text)
    
    if self.btnClose then
        self.btnClose:SetVisible(false)
    end
    
    if self.btnMaxim then
        self.btnMaxim:SetVisible(false)
    end
    
    if self.btnMinim then
        self.btnMinim:SetVisible(false)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(self.theme.borderRadius, 0, 0, w, h, self.theme.colors.background)
    surface.SetDrawColor(self.theme.colors.border)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    
    draw.RoundedBoxEx(self.theme.borderRadius, 0, 0, w, self.headerHeight, self.theme.colors.backgroundDark, true, true, false, false)
    
    draw.SimpleText(self.headerText or self:GetTitle(), "MB.Font.Medium", 10, self.headerHeight/2, self.theme.colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:SetHeaderText(text)
    self.headerText = text
end

function PANEL:AddCloseButton()
end

function PANEL:AddActionButton(text, icon, callback, tooltip)
    local button = vgui.Create("DButton", self.footer)
    button:SetText(text or "")
    button:SetTextColor(self.theme.colors.button.text)
    button:SetFont("MB.Font.Normal")
    button:SetTooltip(tooltip or "")
    
    local paddingX = 10
    
    if not icon then
        button:SetSize(100, 30)
    else
        button:SetSize(icon and 120 or 100, 30)
        button.icon = icon
        button.PerformLayout = function(s, w, h)
            s:SetTextInset(24, 0)
        end
    end
    
    local numButtons = #self.footer:GetChildren() - 1 
    local totalButtonWidth = numButtons * (button:GetWide() + paddingX) + button:GetWide()
    local startX = (self.footer:GetWide() - totalButtonWidth) / 2
    
    button:SetPos(startX + (numButtons * (button:GetWide() + paddingX)), (self.footer:GetTall() - button:GetTall()) / 2)
    
    button.Paint = function(s, w, h)
        local color
        
        if s:IsDisabled() then
            color = self.theme.colors.states.disabled
        elseif s:IsDown() then
            color = self.theme.colors.button.active
        elseif s:IsHovered() then
            color = self.theme.colors.button.hover
        else
            color = self.theme.colors.button.bg
        end
        
        draw.RoundedBox(self.theme.borderRadius, 0, 0, w, h, color)
        
        if icon then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material(icon))
            surface.DrawTexturedRect(8, h/2 - 8, 16, 16)
        end
    end
    
    if callback and type(callback) == "function" then
        button.DoClick = callback
    end
    
    return button
end

function PANEL:AddContent(panel, x, y, width, height)
    if not IsValid(panel) then return end
    
    if not self.content then return end
    
    panel:SetParent(self.content)
    
    if x and y then
        panel:SetPos(x, y)
    end
    
    if width and height then
        panel:SetSize(width, height)
    end
    
    return panel
end

function PANEL:CreateTabPanel()
    local tabPanel = MB.Library.UI.CreateTabPanel(self.content, 5, 5, self.content:GetWide() - 10, self.content:GetTall() - 10)
    tabPanel:Dock(FILL)
    tabPanel:DockMargin(5, 5, 5, 5)
    
    return tabPanel
end

function PANEL:SetFooterVisible(visible)
    self.footer:SetVisible(visible)
    
    if visible then
        self.content:SetTall(self:GetTall() - self.headerHeight - self.footerHeight)
    else
        self.content:SetTall(self:GetTall() - self.headerHeight)
    end
end

function PANEL:GetContentPanel()
    return self.content
end

function PANEL:SetContentBgColor(color)
    self.content.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, color)
    end
end

function PANEL:ShowNotification(title, text, type, duration)
    MB.Library.Notifications.Add(title, text, type or NOTIFY_GENERIC, duration or 5)
end

function PANEL:ShowConfirmation(text, yesCallback, noCallback, yesText, noText)
    return MB.Library.UI.CreateDialog(self:GetTitle() .. " - Confirmation", text, {
        [yesText or "Yes"] = yesCallback or function() end,
        [noText or "No"] = noCallback or function() end
    })
end

vgui.Register("MB.Panel", PANEL, "DFrame")

function MB.Library.Panel.Create(title, width, height)
    local panel = vgui.Create("MB.Panel")
    
    if title then
        panel:SetTitle(title)
    end
    
    if width and height then
        panel:SetSize(width, height)
        panel:Center()
    end
    
    return panel
end 