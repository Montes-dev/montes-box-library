MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Examples = MB.Library.Examples or {}

function MB.Library.Examples.Initialize()
    MB.Library.Log("Examples module initialized")
end

MB.Library.Examples.UI = {
    CreateBasicMenu = function()
        local frame = MB.Library.UI.CreateFrame("Example Menu", 500, 400)
        local button = MB.Library.UI.CreateButton("Click Me", frame, 10, 40, 120, 30)
        
        button.DoClick = function()
            MB.Library.UI.CreateNotification("You clicked the button!", "info")
        end
        
        return frame
    end,
    
    CreateTabMenu = function()
    end
}

MB.Library.Examples.Data = {
    SaveExample = function()
    end,
    
    LoadExample = function()
    end
}

hook.Add("MB.Library.Initialize", "MB.Library.Examples.Init", function()
    MB.Library.Examples.Initialize()
end) 