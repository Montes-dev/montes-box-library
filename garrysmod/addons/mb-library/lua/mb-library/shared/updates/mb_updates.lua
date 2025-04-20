MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Updates = MB.Library.Updates or {}
MB.Library.Updates.CurrentVersion = "1.0.0"
MB.Library.Updates.LatestVersion = nil
MB.Library.Updates.UpdateAvailable = false
MB.Library.Updates.UpdateURL = "https://api.github.com/repos/montesbox/mb-library/releases/latest"

function MB.Library.Updates.Initialize()
    MB.Library.Updates.CheckForUpdates()
    
    timer.Create("MB.Library.Updates.AutoCheck", 3600, 0, function()
        MB.Library.Updates.CheckForUpdates()
    end)
    
    MB.Library.Log("Updates system initialized")
end

function MB.Library.Updates.CheckForUpdates(callback)
    
    timer.Simple(1, function()
        MB.Library.Updates.LatestVersion = "1.0.1"
        MB.Library.Updates.UpdateAvailable = MB.Library.Updates.LatestVersion ~= MB.Library.Updates.CurrentVersion
        
        if MB.Library.Updates.UpdateAvailable then
            MB.Library.Log("Update available: v" .. MB.Library.Updates.LatestVersion)
        end
        
        if callback and type(callback) == "function" then
            callback(MB.Library.Updates.UpdateAvailable, MB.Library.Updates.LatestVersion)
        end
    end)
end

function MB.Library.Updates.DownloadUpdate(callback)
    
    timer.Simple(3, function()
        MB.Library.Log("Update installed successfully")
        MB.Library.Updates.CurrentVersion = MB.Library.Updates.LatestVersion
        MB.Library.Updates.UpdateAvailable = false
        
        if callback and type(callback) == "function" then
            callback(true)
        end
    end)
end

hook.Add("MB.Library.Initialize", "MB.Library.Updates.Init", function()
    MB.Library.Updates.Initialize()
end) 