MB.Library.AdminPanel = MB.Library.AdminPanel or {}
MB.Library.AdminPanel.Settings = MB.Library.AdminPanel.Settings or {}

local PANEL = {}

function PANEL:Init()
    self:SetSize(800, 600)
    self:SetHeaderText("MB-Library Admin Panel")
    self:Center()
    self:SetTitle("")
    self:SetDraggable(true)
    self:ShowCloseButton(false)
    self:DockPadding(0, 40, 0, 0)
    
    local theme = MB.Library.Themes.GetTheme()
    
    self.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, theme.colors.backgroundDark)
        draw.RoundedBox(8, 1, 1, w-2, h-2, theme.colors.background)
        
        draw.RoundedBoxEx(8, 1, 1, w-2, 38, theme.colors.accent, true, true, false, false)
        
        draw.SimpleText(self.headerText or "", "MB.Font.Medium", 15, 20, theme.colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    self.closeButton = vgui.Create("DButton", self)
    self.closeButton:SetSize(30, 30)
    self.closeButton:SetPos(self:GetWide() - 40, 5)
    self.closeButton:SetText("")
    self.closeButton:SetCursor("hand")
    
    self.closeButton.Paint = function(s, w, h)
        if s:IsHovered() then
            draw.RoundedBox(6, 0, 0, w, h, theme.colors.danger)
        end
        
        draw.SimpleText("×", "MB.Font.Medium", w/2, h/2, theme.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    self.closeButton.DoClick = function()
        self:Close()
    end
    
    self.tabPanel = vgui.Create("DPropertySheet", self)
    self.tabPanel:Dock(FILL)
    self.tabPanel:DockMargin(10, 5, 10, 10)
    self.tabPanel:SetPadding(0)
    
    self.tabPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 24, w, h-24, theme.colors.backgroundDark)
    end
    
    local oldCreateTab = self.tabPanel.CreateTab
    self.tabPanel.CreateTab = function(...)
        local tab = oldCreateTab(...)
        tab.Paint = function(s, w, h)
            if s:IsActive() then
                draw.RoundedBoxEx(6, 0, 0, w, h, theme.colors.accent, true, true, false, false)
            else
                draw.RoundedBoxEx(6, 0, 0, w, h, theme.colors.backgroundDark, true, true, false, false)
            end
        end
        return tab
    end
    
    self:AddTabs()
    
    net.Receive("MB.Net.AdminResponse", function(len)
        local response = net.ReadTable()
        
        if response and response.message then
            local notifyType = response.success and NOTIFY_GENERIC or NOTIFY_ERROR
            MB.Library.Notifications.Add("Admin Action", response.message, notifyType, 3)
        end
    end)
    
    net.Receive("MB.Net.SendData", function(len)
        local data = net.ReadTable()
        
        if data and data.type then
            if data.type == "config" and data.data then
                MB.Library.AdminPanel.Settings = data.data
                
                timer.Simple(0.1, function()
                    if IsValid(MB.Library.AdminPanel.Frame) then
                        local oldFrame = MB.Library.AdminPanel.Frame
                        MB.Library.AdminPanel.Open()
                        oldFrame:Remove()
                    end
                end)
            end
        end
    end)
end

function PANEL:AddTabs()
    self:AddPlayersTab()
    self:AddLogsTab()
    self:AddSettingsTab()
end

function PANEL:AddPlayersTab()
    local theme = MB.Library.Themes.GetTheme()
    
    local playersPanel = MB.Library.UI.CreatePanel(self.tabPanel)
    playersPanel:Dock(FILL)
    playersPanel:DockPadding(10, 10, 10, 10)
    playersPanel.Paint = function() end
    
    local playerList = MB.Library.UI.CreateListView(playersPanel, 5, 35, 390, playersPanel:GetTall() - 40)
    playerList:Dock(LEFT)
    playerList:SetWidth(400)
    playerList:DockMargin(0, 5, 5, 0)
    playerList:SetMultiSelect(false)
    playerList:AddColumn("Name")
    playerList:AddColumn("SteamID")
    playerList:AddColumn("Ping")
    
    local actionPanel = MB.Library.UI.CreatePanel(playersPanel)
    actionPanel:Dock(FILL)
    actionPanel:DockMargin(5, 5, 0, 0)
    actionPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, theme.colors.backgroundDark)
    end
    
    local selectedPlayer = nil
    
    playerList.OnRowSelected = function(_, _, row)
        selectedPlayer = row:GetValue(2)
        
        if IsValid(actionPanel.actionContainer) then
            actionPanel.actionContainer:Remove()
        end
        
        actionPanel.actionContainer = vgui.Create("DPanel", actionPanel)
        actionPanel.actionContainer:Dock(FILL)
        actionPanel.actionContainer:DockMargin(10, 10, 10, 10)
        actionPanel.actionContainer.Paint = function() end
        
        local actions = {
            {
                name = "Kick Player",
                icon = "icon16/door_out.png",
                action = function()
                    MB.Library.UI.CreateDialog("Kick Player", "Kick player: " .. row:GetValue(1), {
                        ["Without Reason"] = function()
                            net.Start("MB.Net.AdminAction")
                            net.WriteTable({
                                action = "kick",
                                target = selectedPlayer
                            })
                            net.SendToServer()
                        end,
                        ["With Reason"] = function()
                            local frame = MB.Library.UI.CreateFrame("Kick Player", 300, 150)
                            
                            local reasonEntry = MB.Library.UI.CreateTextEntry("", frame, 20, 50, 260, 30, "Reason for kick")
                            
                            local kickBtn = MB.Library.UI.CreateButton("Kick", frame, 20, 90, 260, 30)
                            kickBtn.DoClick = function()
                                net.Start("MB.Net.AdminAction")
                                net.WriteTable({
                                    action = "kick",
                                    target = selectedPlayer,
                                    reason = reasonEntry:GetValue()
                                })
                                net.SendToServer()
                                frame:Close()
                            end
                        end,
                        ["Cancel"] = function() end
                    })
                end
            },
            {
                name = "Ban Player",
                icon = "icon16/cancel.png",
                action = function()
                    local frame = MB.Library.UI.CreateFrame("Ban Player", 300, 220)
                    
                    local durationLabel = MB.Library.UI.CreateLabel("Duration (minutes, 0 = permanent):", frame, 20, 40, 260, 20)
                    
                    local durationEntry = MB.Library.UI.CreateTextEntry("0", frame, 20, 65, 260, 30, "Duration")
                    
                    local reasonLabel = MB.Library.UI.CreateLabel("Reason:", frame, 20, 105, 260, 20)
                    
                    local reasonEntry = MB.Library.UI.CreateTextEntry("", frame, 20, 130, 260, 30, "Reason for ban")
                    
                    local banBtn = MB.Library.UI.CreateButton("Ban", frame, 20, 170, 260, 30)
                    banBtn.DoClick = function()
                        net.Start("MB.Net.AdminAction")
                        net.WriteTable({
                            action = "ban",
                            target = selectedPlayer,
                            duration = tonumber(durationEntry:GetValue()) or 0,
                            reason = reasonEntry:GetValue()
                        })
                        net.SendToServer()
                        frame:Close()
                    end
                end
            },
            {
                name = "Message Player",
                icon = "icon16/comment.png",
                action = function()
                    local frame = MB.Library.UI.CreateFrame("Send Message", 400, 200)
                    
                    local msgLabel = MB.Library.UI.CreateLabel("Message to " .. row:GetValue(1) .. ":", frame, 20, 40, 360, 20)
                    
                    local msgEntry = MB.Library.UI.CreateTextEntry("", frame, 20, 65, 360, 80, "Message content")
                    msgEntry:SetMultiline(true)
                    
                    local sendBtn = MB.Library.UI.CreateButton("Send", frame, 20, 150, 360, 30)
                    sendBtn.DoClick = function()
                        net.Start("MB.Net.AdminAction")
                        net.WriteTable({
                            action = "message",
                            target = selectedPlayer,
                            message = msgEntry:GetValue()
                        })
                        net.SendToServer()
                        frame:Close()
                    end
                end
            },
            {
                name = "Teleport To",
                icon = "icon16/arrow_right.png",
                action = function()
                    net.Start("MB.Net.AdminAction")
                    net.WriteTable({
                        action = "goto",
                        target = selectedPlayer
                    })
                    net.SendToServer()
                end
            },
            {
                name = "Teleport Here",
                icon = "icon16/arrow_left.png",
                action = function()
                    net.Start("MB.Net.AdminAction")
                    net.WriteTable({
                        action = "bring",
                        target = selectedPlayer
                    })
                    net.SendToServer()
                end
            },
            {
                name = "Freeze/Unfreeze",
                icon = "icon16/lock.png",
                action = function()
                    net.Start("MB.Net.AdminAction")
                    net.WriteTable({
                        action = "freeze",
                        target = selectedPlayer
                    })
                    net.SendToServer()
                end
            }
        }
        
        local titleLabel = MB.Library.UI.CreateLabel("Actions for: " .. row:GetValue(1), actionPanel.actionContainer, 0, 0, 200, 30)
        titleLabel:SetFont("MB.Font.Medium")
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(0, 0, 0, 10)
        
        local buttonsContainer = vgui.Create("DScrollPanel", actionPanel.actionContainer)
        buttonsContainer:Dock(FILL)
        
        for i, action in ipairs(actions) do
            local actionBtn = MB.Library.UI.CreateButton(action.name, buttonsContainer, 0, 0, 0, 40)
            actionBtn:Dock(TOP)
            actionBtn:DockMargin(0, 0, 0, 5)
            actionBtn.DoClick = action.action
            
            if action.icon then
                actionBtn.PerformLayout = function(s, w, h)
                    s:SetTextInset(24, 0)
                end
                
                actionBtn.PaintOver = function(s, w, h)
                    if action.icon then
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(Material(action.icon))
                        surface.DrawTexturedRect(8, h/2 - 8, 16, 16)
                    end
                end
            end
        end
    end
    
    local function refreshPlayerList()
        playerList:Clear()
        
        for _, ply in ipairs(player.GetAll()) do
            playerList:AddLine(ply:Nick(), ply:SteamID64(), ply:Ping())
        end
    end
    
    local controlsContainer = vgui.Create("DPanel", playersPanel)
    controlsContainer:Dock(TOP)
    controlsContainer:SetHeight(30)
    controlsContainer:DockMargin(0, 0, 0, 5)
    controlsContainer.Paint = function() end
    
    local refreshButton = MB.Library.UI.CreateButton("Refresh", controlsContainer, 0, 0, 100, 30)
    refreshButton:Dock(LEFT)
    refreshButton:DockMargin(0, 0, 5, 0)
    refreshButton:SetIcon("icon16/arrow_refresh.png")
    refreshButton.DoClick = function()
        refreshPlayerList()
        
        net.Start("MB.Net.RequestData")
        net.WriteTable({ type = "players" })
        net.SendToServer()
    end
    
    timer.Create("MB.AdminPanel.PlayerListRefresh", MB.Library.AdminPanel.GetSetting("mb_refresh_rate", 5), 0, refreshPlayerList)
    
    refreshPlayerList()
    
    self.tabPanel:AddSheet("Players", playersPanel, "icon16/user.png")
    
    net.Start("MB.Net.RequestData")
    net.WriteTable({ type = "players" })
    net.SendToServer()
end

function PANEL:AddLogsTab()
    local theme = MB.Library.Themes.GetTheme()
    
    local logsPanel = MB.Library.UI.CreatePanel(self.tabPanel)
    logsPanel:Dock(FILL)
    logsPanel:DockPadding(10, 10, 10, 10)
    logsPanel.Paint = function() end
    
    local filterPanel = vgui.Create("DPanel", logsPanel)
    filterPanel:Dock(TOP)
    filterPanel:SetHeight(40)
    filterPanel:DockMargin(0, 0, 0, 5)
    filterPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, theme.colors.backgroundDark)
    end
    
    local filterLabel = MB.Library.UI.CreateLabel("Filter:", filterPanel, 10, 10, 50, 20)
    filterLabel:SetContentAlignment(4)
    filterLabel:SetTextColor(theme.colors.text)
    
    local filterTypes = MB.Library.UI.CreateComboBox(filterPanel, 70, 5, 150, 30)
    filterTypes:Dock(LEFT)
    filterTypes:DockMargin(60, 5, 5, 5)
    filterTypes:SetValue("All Logs")
    filterTypes:AddChoice("All Logs")
    filterTypes:AddChoice("Admin Actions")
    filterTypes:AddChoice("Player Activity")
    filterTypes:AddChoice("Server Events")
    filterTypes:AddChoice("System Messages")
    
    local searchEntry = MB.Library.UI.CreateTextEntry("", filterPanel, 230, 5, 200, 30, "Search...")
    searchEntry:Dock(LEFT)
    searchEntry:DockMargin(5, 5, 5, 5)
    
    local searchButton = MB.Library.UI.CreateButton("Search", filterPanel, 440, 5, 80, 30)
    searchButton:Dock(LEFT)
    searchButton:DockMargin(5, 5, 5, 5)
    
    local clearButton = MB.Library.UI.CreateButton("Clear", filterPanel, 530, 5, 80, 30)
    clearButton:Dock(LEFT)
    clearButton:DockMargin(5, 5, 5, 5)
    
    local logsListView = MB.Library.UI.CreateListView(logsPanel, 5, 50, logsPanel:GetWide() - 10, logsPanel:GetTall() - 55)
    logsListView:Dock(FILL)
    logsListView:DockMargin(0, 5, 0, 0)
    logsListView:AddColumn("Time"):SetWidth(150)
    logsListView:AddColumn("Type"):SetWidth(100)
    logsListView:AddColumn("Message")
    
    local function refreshLogs()
        logsListView:Clear()
        
        net.Start("MB.Net.RequestData")
        net.WriteTable({ 
            type = "logs",
            filter = filterTypes:GetValue(),
            search = searchEntry:GetValue()
        })
        net.SendToServer()
    end
    
    searchButton.DoClick = refreshLogs
    clearButton.DoClick = function()
        filterTypes:SetValue("All Logs")
        searchEntry:SetValue("")
        refreshLogs()
    end
    
    net.Receive("MB.Net.SendData", function(len)
        local data = net.ReadTable()
        
        if data and data.type == "logs" and data.data then
            logsListView:Clear()
            
            for _, log in ipairs(data.data) do
                logsListView:AddLine(log.time, log.type, log.message)
            end
        end
    end)
    
    refreshLogs()
    
    self.tabPanel:AddSheet("Logs", logsPanel, "icon16/table.png")
end

function PANEL:AddSettingsTab()
    local theme = MB.Library.Themes.GetTheme()
    
    local settingsPanel = MB.Library.UI.CreatePanel(self.tabPanel)
    settingsPanel:Dock(FILL)
    settingsPanel:DockPadding(10, 10, 10, 10)
    settingsPanel.Paint = function() end
    
    local settingsScroll = vgui.Create("DScrollPanel", settingsPanel)
    settingsScroll:Dock(FILL)
    
    local sections = {
        {
            title = "General Settings",
            settings = {
                {type = "checkbox", name = "Enable Admin Notifications", var = "mb_admin_notifications", default = true},
                {type = "checkbox", name = "Log Admin Actions", var = "mb_log_admin_actions", default = true},
                {type = "slider", name = "Player List Refresh Rate", var = "mb_refresh_rate", min = 1, max = 30, default = 5, decimals = 0},
                {type = "checkbox", name = "Enable Advanced Logging", var = "mb_advanced_logging", default = false}
            }
        },
        {
            title = "UI Settings",
            settings = {
                {type = "combobox", name = "Theme", var = "mb_admin_theme", options = {"Dark Modern", "Light", "Dark", "Midnight"}, default = "Dark Modern"},
                {type = "slider", name = "UI Scale", var = "mb_ui_scale", min = 0.5, max = 2, default = 1, decimals = 1},
                {type = "checkbox", name = "Show Admin Icons on Players", var = "mb_show_admin_icons", default = true},
                {type = "color", name = "Accent Color", var = "mb_accent_color", default = theme.colors.accent}
            }
        },
        {
            title = "Permission Settings",
            settings = {
                {type = "checkbox", name = "Allow SuperAdmins to Ban", var = "mb_superadmin_ban", default = true},
                {type = "checkbox", name = "Allow Admins to Ban", var = "mb_admin_ban", default = true},
                {type = "checkbox", name = "Allow SuperAdmins to Use Teleport", var = "mb_superadmin_teleport", default = true},
                {type = "checkbox", name = "Allow Admins to Use Teleport", var = "mb_admin_teleport", default = false}
            }
        }
    }
    
    local sectionPanels = {}
    
    for i, section in ipairs(sections) do
        local categoryContainer = vgui.Create("DPanel", settingsScroll)
        categoryContainer:Dock(TOP)
        categoryContainer:DockMargin(0, 0, 0, 10)
        categoryContainer:DockPadding(10, 35, 10, 10)
        categoryContainer:SetTall(50 + (#section.settings * 40))
        categoryContainer.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, theme.colors.backgroundDark)
            draw.SimpleText(section.title, "MB.Font.Medium", 15, 17, theme.colors.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        for j, setting in ipairs(section.settings) do
            local settingContainer = vgui.Create("DPanel", categoryContainer)
            settingContainer:Dock(TOP)
            settingContainer:SetHeight(40)
            settingContainer:DockMargin(0, 0, 0, 5)
            settingContainer.Paint = function() end
            
            local settingLabel = MB.Library.UI.CreateLabel(setting.name, settingContainer, 10, 10, 200, 20)
            settingLabel:Dock(LEFT)
            settingLabel:SetWidth(200)
            settingLabel:SetTextColor(theme.colors.text)
            
            if setting.type == "checkbox" then
                local checkbox = vgui.Create("DCheckBox", settingContainer)
                checkbox:Dock(LEFT)
                checkbox:DockMargin(10, 10, 0, 10)
                checkbox:SetValue(MB.Library.AdminPanel.GetSetting(setting.var, setting.default))
                checkbox.OnChange = function(_, val)
                    MB.Library.AdminPanel.SetSetting(setting.var, val)
                end
            elseif setting.type == "slider" then
                local slider = vgui.Create("DNumSlider", settingContainer)
                slider:Dock(FILL)
                slider:DockMargin(10, 0, 0, 0)
                slider:SetMin(setting.min)
                slider:SetMax(setting.max)
                slider:SetDecimals(setting.decimals)
                slider:SetValue(MB.Library.AdminPanel.GetSetting(setting.var, setting.default))
                slider.OnValueChanged = function(_, val)
                    MB.Library.AdminPanel.SetSetting(setting.var, val)
                end
                
                slider.Label:SetTextColor(theme.colors.text)
                slider.TextArea:SetTextColor(theme.colors.text)
            elseif setting.type == "combobox" then
                local combobox = MB.Library.UI.CreateComboBox(settingContainer, 0, 0, 0, 0)
                combobox:Dock(LEFT)
                combobox:DockMargin(10, 5, 0, 5)
                combobox:SetWidth(200)
                combobox:SetValue(MB.Library.AdminPanel.GetSetting(setting.var, setting.default))
                
                for _, option in ipairs(setting.options) do
                    combobox:AddChoice(option)
                end
                
                combobox.OnSelect = function(_, _, val)
                    MB.Library.AdminPanel.SetSetting(setting.var, val)
                    
                    if setting.var == "mb_admin_theme" then
                        MB.Library.Themes.SetTheme(val:lower():gsub(" ", "_"))
                        
                        timer.Simple(0.1, function()
                            if IsValid(MB.Library.AdminPanel.Frame) then
                                local oldFrame = MB.Library.AdminPanel.Frame
                                MB.Library.AdminPanel.Open()
                                oldFrame:Remove()
                            end
                        end)
                    end
                end
            elseif setting.type == "color" then
                local savedColor = MB.Library.AdminPanel.GetSetting(setting.var, setting.default)
                if type(savedColor) == "table" then
                    savedColor = Color(savedColor.r, savedColor.g, savedColor.b, savedColor.a or 255)
                end
                
                local colorBtn = MB.Library.UI.CreateButton("", settingContainer, 0, 0, 30, 30)
                colorBtn:Dock(LEFT)
                colorBtn:DockMargin(10, 5, 0, 5)
                colorBtn:SetWidth(30)
                colorBtn.Paint = function(s, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, savedColor)
                    
                    if s:IsHovered() then
                        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 30))
                    end
                    
                    surface.SetDrawColor(theme.colors.border)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                end
                
                colorBtn.DoClick = function()
                    local colorPicker = vgui.Create("DColorMixer")
                    colorPicker:SetSize(400, 200)
                    colorPicker:SetColor(savedColor)
                    
                    local frame = MB.Library.UI.CreateFrame("Choose Color", 420, 270)
                    frame:Center()
                    
                    colorPicker:SetParent(frame)
                    colorPicker:SetPos(10, 40)
                    
                    local applyBtn = MB.Library.UI.CreateButton("Apply", frame, 10, 245, 190, 30)
                    applyBtn.DoClick = function()
                        local newColor = colorPicker:GetColor()
                        savedColor = newColor
                        MB.Library.AdminPanel.SetSetting(setting.var, {
                            r = newColor.r, 
                            g = newColor.g, 
                            b = newColor.b, 
                            a = newColor.a
                        })
                        frame:Close()
                    end
                    
                    local cancelBtn = MB.Library.UI.CreateButton("Cancel", frame, 210, 245, 190, 30)
                    cancelBtn.DoClick = function()
                        frame:Close()
                    end
                end
            end
        end
        
        table.insert(sectionPanels, categoryContainer)
    end
    
    local saveButton = MB.Library.UI.CreateButton("Save Settings", settingsScroll, 0, 0, 0, 40)
    saveButton:Dock(TOP)
    saveButton:DockMargin(0, 5, 0, 10)
    saveButton.DoClick = function()
        net.Start("MB.Net.Config")
        net.WriteTable(MB.Library.AdminPanel.Settings)
        net.SendToServer()
        
        MB.Library.Notifications.Add("Settings", "Settings saved successfully", NOTIFY_SUCCESS, 3)
    end
    
    self.tabPanel:AddSheet("Settings", settingsPanel, "icon16/cog.png")
    
    net.Start("MB.Net.RequestData")
    net.WriteTable({ type = "config" })
    net.SendToServer()
end

function PANEL:SetHeaderText(text)
    self.headerText = text
end

vgui.Register("MB.AdminPanel", PANEL, "DFrame")

function MB.Library.AdminPanel.Open()
    if IsValid(MB.Library.AdminPanel.Frame) then
        MB.Library.AdminPanel.Frame:Remove()
    end
    
    MB.Library.AdminPanel.Frame = vgui.Create("MB.AdminPanel")
    MB.Library.AdminPanel.Frame:MakePopup()
    
    return MB.Library.AdminPanel.Frame
end

function MB.Library.AdminPanel.GetSetting(key, default)
    if MB.Library.AdminPanel.Settings[key] ~= nil then
        return MB.Library.AdminPanel.Settings[key]
    end
    return default
end

function MB.Library.AdminPanel.SetSetting(key, value)
    MB.Library.AdminPanel.Settings[key] = value
    
    if key == "mb_refresh_rate" and value ~= nil and tonumber(value) then
        if timer.Exists("MB.AdminPanel.PlayerListRefresh") then
            timer.Adjust("MB.AdminPanel.PlayerListRefresh", tonumber(value), 0)
        end
    end
end

concommand.Add("mb_admin", function(ply)
    if not IsValid(ply) or ply:IsAdmin() then
        MB.Library.AdminPanel.Open()
    end
end) 