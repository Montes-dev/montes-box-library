MB.Library.ServerInfo = MB.Library.ServerInfo or {}
MB.Library.ServerInfo.Data = MB.Library.ServerInfo.Data or {}
MB.Library.ServerInfo.UpdateInterval = 5

function MB.Library.ServerInfo.Initialize()
    MB.Library.ServerInfo.Data = {
        name = GetHostName(),
        address = game.GetIPAddress(),
        map = game.GetMap(),
        gamemode = engine.ActiveGamemode(),
        maxPlayers = game.MaxPlayers(),
        playerCount = player.GetCount(),
        fps = 0,
        tickRate = 0,
        uptime = 0,
        networkUsage = {
            up = 0,
            down = 0
        },
        players = {}
    }
    
    timer.Create("MB.Library.ServerInfo.Update", MB.Library.ServerInfo.UpdateInterval, 0, MB.Library.ServerInfo.Update)
    
    MB.Library.Networking.Listen("ServerStatus", function(data)
        MB.Library.ServerInfo.Data = table.Merge(MB.Library.ServerInfo.Data, data)
        hook.Run("MB.ServerInfoUpdated", MB.Library.ServerInfo.Data)
    end)
    
    MB.Library.Log("Server info module initialized")
end

function MB.Library.ServerInfo.Update()
    MB.Library.ServerInfo.Data.name = GetHostName()
    MB.Library.ServerInfo.Data.map = game.GetMap()
    MB.Library.ServerInfo.Data.maxPlayers = game.MaxPlayers()
    MB.Library.ServerInfo.Data.playerCount = player.GetCount()
    MB.Library.ServerInfo.Data.fps = math.Round(1 / (RealFrameTime() or 0.001))
    MB.Library.ServerInfo.Data.tickRate = math.Round(1 / (engine.TickInterval() or 0.001))
    MB.Library.ServerInfo.Data.players = {}
    
    for _, ply in ipairs(player.GetAll()) do
        table.insert(MB.Library.ServerInfo.Data.players, {
            name = ply:Nick(),
            steamId = ply:SteamID(),
            ping = ply:Ping(),
            isAdmin = ply:IsAdmin()
        })
    end
    
    hook.Run("MB.ServerInfoUpdated", MB.Library.ServerInfo.Data)
end

function MB.Library.ServerInfo.Get()
    return table.Copy(MB.Library.ServerInfo.Data)
end

function MB.Library.ServerInfo.CreateServerInfoPanel(parent)
    local panel = vgui.Create("DPanel", parent)
    panel:SetSize(350, 300)
    panel:SetBackgroundColor(MB.Library.Themes.GetColor("background"))
    
    local titleLabel = vgui.Create("DLabel", panel)
    titleLabel:SetFont("MB.UI.Title")
    titleLabel:SetTextColor(MB.Library.Themes.GetColor("text"))
    titleLabel:SetText("Server Information")
    titleLabel:SizeToContents()
    titleLabel:SetPos(10, 10)
    
    local infoList = vgui.Create("DScrollPanel", panel)
    infoList:SetPos(10, 40)
    infoList:SetSize(330, 240)
    
    local function AddInfoRow(name, value, parent)
        local row = vgui.Create("DPanel", parent)
        row:SetSize(310, 30)
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 5)
        row.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, MB.Library.Themes.GetColor("foreground"))
        end
        
        local nameLabel = vgui.Create("DLabel", row)
        nameLabel:SetFont("MB.UI.Normal")
        nameLabel:SetTextColor(MB.Library.Themes.GetColor("text"))
        nameLabel:SetText(name)
        nameLabel:SizeToContents()
        nameLabel:SetPos(10, 15 - nameLabel:GetTall() / 2)
        
        local valueLabel = vgui.Create("DLabel", row)
        valueLabel:SetFont("MB.UI.Normal")
        valueLabel:SetTextColor(MB.Library.Themes.GetColor("textDark"))
        valueLabel:SetText(value or "N/A")
        valueLabel:SizeToContents()
        valueLabel:SetPos(310 - valueLabel:GetWide() - 10, 15 - valueLabel:GetTall() / 2)
        
        return valueLabel
    end
    
    local nameValue = AddInfoRow("Server Name:", MB.Library.ServerInfo.Data.name, infoList)
    local addressValue = AddInfoRow("Address:", MB.Library.ServerInfo.Data.address, infoList)
    local mapValue = AddInfoRow("Current Map:", MB.Library.ServerInfo.Data.map, infoList)
    local gamemodeValue = AddInfoRow("Gamemode:", MB.Library.ServerInfo.Data.gamemode, infoList)
    local playerCountValue = AddInfoRow("Players:", MB.Library.ServerInfo.Data.playerCount .. "/" .. MB.Library.ServerInfo.Data.maxPlayers, infoList)
    local fpsValue = AddInfoRow("Server FPS:", MB.Library.ServerInfo.Data.fps, infoList)
    local tickRateValue = AddInfoRow("Tickrate:", MB.Library.ServerInfo.Data.tickRate, infoList)
    local uptimeValue = AddInfoRow("Uptime:", string.FormattedTime(MB.Library.ServerInfo.Data.uptime or 0, "%02ih %02im %02is"), infoList)
    
    hook.Add("MB.ServerInfoUpdated", panel, function(_, data)
        nameValue:SetText(data.name or "N/A")
        nameValue:SizeToContents()
        nameValue:SetPos(310 - nameValue:GetWide() - 10, 15 - nameValue:GetTall() / 2)
        
        mapValue:SetText(data.map or "N/A")
        mapValue:SizeToContents()
        mapValue:SetPos(310 - mapValue:GetWide() - 10, 15 - mapValue:GetTall() / 2)
        
        playerCountValue:SetText((data.playerCount or 0) .. "/" .. (data.maxPlayers or 0))
        playerCountValue:SizeToContents()
        playerCountValue:SetPos(310 - playerCountValue:GetWide() - 10, 15 - playerCountValue:GetTall() / 2)
        
        fpsValue:SetText(data.fps or "N/A")
        fpsValue:SizeToContents()
        fpsValue:SetPos(310 - fpsValue:GetWide() - 10, 15 - fpsValue:GetTall() / 2)
        
        tickRateValue:SetText(data.tickRate or "N/A")
        tickRateValue:SizeToContents()
        tickRateValue:SetPos(310 - tickRateValue:GetWide() - 10, 15 - tickRateValue:GetTall() / 2)
        
        local formattedUptime = string.FormattedTime(data.uptime or 0, "%02ih %02im %02is")
        uptimeValue:SetText(formattedUptime)
        uptimeValue:SizeToContents()
        uptimeValue:SetPos(310 - uptimeValue:GetWide() - 10, 15 - uptimeValue:GetTall() / 2)
    end)
    
    panel.OnRemove = function()
        hook.Remove("MB.ServerInfoUpdated", panel)
    end
    
    return panel
end

hook.Add("Initialize", "MB.Library.ServerInfo.Initialize", MB.Library.ServerInfo.Initialize) 