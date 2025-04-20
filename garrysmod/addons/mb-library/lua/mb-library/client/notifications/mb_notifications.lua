MB.Library.Notifications = MB.Library.Notifications or {}
MB.Library.Notifications.Queue = MB.Library.Notifications.Queue or {}
MB.Library.Notifications.Active = MB.Library.Notifications.Active or {}
MB.Library.Notifications.MaxActive = 5
MB.Library.Notifications.LifeTime = 5
MB.Library.Notifications.FadeTime = 0.5

local NOTIFICATION = {}

function NOTIFICATION:Init()
    self.backgroundColor = MB.Library.Themes.GetColor("background")
    self.borderColor = MB.Library.Themes.GetColor("accent")
    self.textColor = MB.Library.Themes.GetColor("text")
    self.titleColor = MB.Library.Themes.GetColor("button").text
    
    self.title = ""
    self.text = ""
    self.icon = nil
    self.startTime = CurTime()
    self.endTime = CurTime() + MB.Library.Notifications.LifeTime
    self.alpha = 0
    self.progress = 0
    
    self:SetSize(300, 80)
    self:SetPos(ScrW() - 320, -100)
    self:SetZPos(9999)
    self:SetMouseInputEnabled(true)
    
    self.closeBtn = vgui.Create("DButton", self)
    self.closeBtn:SetSize(20, 20)
    self.closeBtn:SetPos(self:GetWide() - 25, 5)
    self.closeBtn:SetText("")
    self.closeBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(MB.Library.Themes.GetColor("danger"), self.alpha))
        draw.SimpleText("×", "MB.Font.Normal", w/2, h/2, ColorAlpha(Color(255, 255, 255), self.alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    self.closeBtn.DoClick = function()
        self:Close()
    end
    
    self.anim = Derma_Anim("NotificationAnim", self, function(pnl, anim, delta, data)
        if anim == "FadeIn" then
            self.alpha = math.Clamp(delta * 255, 0, 255)
            self:SetPos(ScrW() - 320, data.y)
        elseif anim == "FadeOut" then
            self.alpha = math.Clamp((1 - delta) * 255, 0, 255)
            self:SetPos(ScrW() - 320 + (delta * 50), data.y)
        end
    end)
    
    self.sound = "buttons/button15.wav"
    
    surface.PlaySound(self.sound)
end

function NOTIFICATION:SetTitle(title)
    self.title = title
end

function NOTIFICATION:SetText(text)
    self.text = text
end

function NOTIFICATION:SetIcon(icon)
    self.icon = icon
end

function NOTIFICATION:SetType(type)
    if type == NOTIFY_GENERIC then
        self.icon = "icon16/information.png"
        self.borderColor = MB.Library.Themes.GetColor("primary")
    elseif type == NOTIFY_ERROR then
        self.icon = "icon16/cancel.png"
        self.borderColor = MB.Library.Themes.GetColor("danger")
    elseif type == NOTIFY_HINT then
        self.icon = "icon16/lightbulb.png"
        self.borderColor = MB.Library.Themes.GetColor("info")
    elseif type == NOTIFY_CLEANUP then
        self.icon = "icon16/cross.png"
        self.borderColor = MB.Library.Themes.GetColor("warning")
    elseif type == NOTIFY_UNDO then
        self.icon = "icon16/arrow_undo.png"
        self.borderColor = MB.Library.Themes.GetColor("secondary")
    elseif type == NOTIFY_SUCCESS then
        self.icon = "icon16/accept.png"
        self.borderColor = MB.Library.Themes.GetColor("success")
    end
end

function NOTIFICATION:SetLifeTime(time)
    self.endTime = self.startTime + time
end

function NOTIFICATION:Think()
    if not self.anim then return end
    
    self.anim:Run()
    
    local curTime = CurTime()
    local timeLeft = self.endTime - curTime
    local totalTime = self.endTime - self.startTime
    
    self.progress = 1 - (timeLeft / totalTime)
    
    if timeLeft <= 0 and not self.closing then
        self.closing = true
        self:FadeOut()
    end
end

function NOTIFICATION:Paint(w, h)
    local cornerRadius = 6
    
    draw.RoundedBox(cornerRadius, 0, 0, w, h, ColorAlpha(self.backgroundColor, self.alpha))
    
    surface.SetDrawColor(ColorAlpha(self.borderColor, self.alpha))
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    
    draw.RoundedBoxEx(4, 0, 0, w, 4, ColorAlpha(self.borderColor, self.alpha), true, true, false, false)
    
    draw.RoundedBox(0, 0, h - 4, w * self.progress, 4, ColorAlpha(self.borderColor, self.alpha))
    
    if self.icon then
        surface.SetDrawColor(255, 255, 255, self.alpha)
        surface.SetMaterial(Material(self.icon))
        surface.DrawTexturedRect(10, h/2 - 8, 16, 16)
    end
    
    local textX = self.icon and 36 or 10
    
    draw.SimpleText(self.title, "MB.Font.Medium", textX, 12, ColorAlpha(self.titleColor, self.alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    
    local text = self.text
    local textBoxHeight = h - 40
    local textBoxY = 35
    local font = "MB.Font.Small"
    
    surface.SetFont(font)
    local textWidth = w - textX - 10
    
    local _, wrappedText = draw.TextShadow({
        text = text,
        font = font,
        pos = {textX, textBoxY},
        color = ColorAlpha(self.textColor, self.alpha),
        xalign = TEXT_ALIGN_LEFT,
        yalign = TEXT_ALIGN_TOP
    }, 1, 200)
    
    return true
end

function NOTIFICATION:FadeIn(yPos)
    local animData = {y = yPos}
    
    self.anim:Start(0.3, {
        anim = "FadeIn",
        data = animData
    })
end

function NOTIFICATION:FadeOut()
    local _, y = self:GetPos()
    local animData = {y = y}
    
    self.anim:Start(0.3, {
        anim = "FadeOut",
        data = animData,
        callback = function()
            self:Remove()
            
            for k, v in ipairs(MB.Library.Notifications.Active) do
                if v == self then
                    table.remove(MB.Library.Notifications.Active, k)
                    break
                end
            end
            
            MB.Library.Notifications.UpdatePositions()
            MB.Library.Notifications.ProcessQueue()
        end
    })
end

function NOTIFICATION:Close()
    if not self.closing then
        self.closing = true
        self:FadeOut()
    end
end

vgui.Register("MB.Notification", NOTIFICATION, "DPanel")

function MB.Library.Notifications.Add(title, text, type, lifetime)
    local notification = {
        title = title,
        text = text,
        type = type or NOTIFY_GENERIC,
        lifetime = lifetime or MB.Library.Notifications.LifeTime
    }
    
    table.insert(MB.Library.Notifications.Queue, notification)
    MB.Library.Notifications.ProcessQueue()
end

function MB.Library.Notifications.ProcessQueue()
    if #MB.Library.Notifications.Active >= MB.Library.Notifications.MaxActive then
        return
    end
    
    if #MB.Library.Notifications.Queue == 0 then
        return
    end
    
    local data = table.remove(MB.Library.Notifications.Queue, 1)
    
    local notif = vgui.Create("MB.Notification")
    notif:SetTitle(data.title)
    notif:SetText(data.text)
    notif:SetType(data.type)
    notif:SetLifeTime(data.lifetime)
    
    table.insert(MB.Library.Notifications.Active, notif)
    MB.Library.Notifications.UpdatePositions()
end

function MB.Library.Notifications.UpdatePositions()
    for i, notif in ipairs(MB.Library.Notifications.Active) do
        local yPos = ScrH() - 100 - ((i-1) * 90)
        
        if notif.anim and not notif.anim:Active() and not notif.closing then
            notif:FadeIn(yPos)
        end
    end
end

function MB.Library.Notifications.Override()
    local oldNotify = notification and notification.AddLegacy
    
    if oldNotify then
        notification.AddLegacy = function(text, type, time)
            MB.Library.Notifications.Add("Notification", text, type, time)
        end
        
        notification.AddProgress = function(id, text)
            MB.Library.Notifications.Add("Progress", text, NOTIFY_HINT, 5)
            return id
        end
        
        notification.Kill = function(id)
            local notif = MB.Library.Notifications.GetByID(id)
            if notif then
                notif:Close()
            end
        end
    end
    
    chat.AddText = function(...)
        local args = {...}
        local text = ""
        local lastColor = Color(255, 255, 255)
        
        for i, arg in ipairs(args) do
            if type(arg) == "table" and arg.r and arg.g and arg.b then
                lastColor = arg
            elseif type(arg) == "string" then
                text = text .. arg
            elseif type(arg) == "Player" and IsValid(arg) then
                text = text .. arg:Nick()
            end
        end
        
        if text and text ~= "" then
            MB.Library.Notifications.Add("Chat", text, NOTIFY_GENERIC, 5)
        end
        
        return oldAddText and oldAddText(...)
    end
end

hook.Add("InitPostEntity", "MB.Library.Notifications.Initialize", function()
    MB.Library.Notifications.Override()
    MB.Library.Notifications.ProcessQueue()
end)

net.Receive("MB.Net.Notification", function()
    local data = net.ReadTable()
    MB.Library.Notifications.Add(data.title or "Notification", data.text, data.type, data.lifetime)
end)

NOTIFY_SUCCESS = 7 