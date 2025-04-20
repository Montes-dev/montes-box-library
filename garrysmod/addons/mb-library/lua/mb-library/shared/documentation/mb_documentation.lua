MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Documentation = MB.Library.Documentation or {}

function MB.Library.Documentation.Initialize()
    MB.Library.Log("Documentation module initialized")
end

function MB.Library.Documentation.GenerateForModule(moduleName, moduleTable)
end

hook.Add("MB.Library.Initialize", "MB.Library.Documentation.Init", function()
    MB.Library.Documentation.Initialize()
end) 