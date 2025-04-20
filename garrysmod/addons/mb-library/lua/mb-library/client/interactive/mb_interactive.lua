MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Interactive = MB.Library.Interactive or {}

MB.Library.Interactive.Elements = {}

function MB.Library.Interactive.Initialize()
    MB.Library.Log("Interactive module initialized")
end

function MB.Library.Interactive.RegisterElement(id, elementData)
    if not id or not elementData then return false end
    
    MB.Library.Interactive.Elements[id] = elementData
    return true
end

function MB.Library.Interactive.GetElement(id)
    return MB.Library.Interactive.Elements[id]
end

function MB.Library.Interactive.CreateDraggable(panel, options)
    if not IsValid(panel) then return end
    
    options = options or {}
    local dragThreshold = options.threshold or 5
    local restrictToScreen = options.restrictToScreen or true
    local startPos
    local dragging = false
    local mouseDownPos
    
    panel.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            startPos = self:GetPos()
            mouseDownPos = {gui.MouseX(), gui.MouseY()}
            dragging = true
            self:MouseCapture(true)
        end
    end
    
    panel.OnMouseReleased = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            dragging = false
            self:MouseCapture(false)
        end
    end
    
    panel.Think = function(self)
        if not dragging then return end
        
        local mouseX, mouseY = gui.MouseX(), gui.MouseY()
        local deltaX = mouseX - mouseDownPos[1]
        local deltaY = mouseY - mouseDownPos[2]
        
        if deltaX^2 + deltaY^2 < dragThreshold^2 then return end
        
        local newX = startPos.x + deltaX
        local newY = startPos.y + deltaY
        
        if restrictToScreen then
            local w, h = self:GetSize()
            newX = math.Clamp(newX, 0, ScrW() - w)
            newY = math.Clamp(newY, 0, ScrH() - h)
        end
        
        self:SetPos(newX, newY)
    end
    
    return panel
end

function MB.Library.Interactive.CreateResizable(panel, options)
    if not IsValid(panel) then return end
    
    options = options or {}
    local minWidth = options.minWidth or 100
    local minHeight = options.minHeight or 100
    local maxWidth = options.maxWidth or ScrW()
    local maxHeight = options.maxHeight or ScrH()
    local resizeHandleSize = options.handleSize or 10
    
    local resizePanel = vgui.Create("DPanel", panel)
    resizePanel:SetSize(resizeHandleSize, resizeHandleSize)
    resizePanel:SetPos(panel:GetWide() - resizeHandleSize, panel:GetTall() - resizeHandleSize)
    resizePanel:SetCursor("sizenwse")
    resizePanel:SetZPos(999)
    resizePanel:SetBackgroundColor(Color(0, 0, 0, 0))
    
    local startSize
    local startPos
    local mouseStartPos
    local resizing = false
    
    resizePanel.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            startSize = {panel:GetSize()}
            startPos = {panel:GetPos()}
            mouseStartPos = {gui.MouseX(), gui.MouseY()}
            resizing = true
            self:MouseCapture(true)
        end
    end
    
    resizePanel.OnMouseReleased = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            resizing = false
            self:MouseCapture(false)
        end
    end
    
    resizePanel.Think = function(self)
        if not resizing then return end
        
        local mouseX, mouseY = gui.MouseX(), gui.MouseY()
        local deltaX = mouseX - mouseStartPos[1]
        local deltaY = mouseY - mouseStartPos[2]
        
        local newWidth = math.Clamp(startSize[1] + deltaX, minWidth, maxWidth)
        local newHeight = math.Clamp(startSize[2] + deltaY, minHeight, maxHeight)
        
        panel:SetSize(newWidth, newHeight)
        self:SetPos(newWidth - resizeHandleSize, newHeight - resizeHandleSize)
    end
    
    panel.OnSizeChanged = function(self, w, h)
        resizePanel:SetPos(w - resizeHandleSize, h - resizeHandleSize)
    end
    
    return panel
end

function MB.Library.Interactive.MakeInteractive(panel, options)
    options = options or {}
    
    if options.draggable then
        MB.Library.Interactive.CreateDraggable(panel, options.dragOptions)
    end
    
    if options.resizable then
        MB.Library.Interactive.CreateResizable(panel, options.resizeOptions)
    end
    
    return panel
end

hook.Add("Initialize", "MB.Library.Interactive.Initialize", MB.Library.Interactive.Initialize) 