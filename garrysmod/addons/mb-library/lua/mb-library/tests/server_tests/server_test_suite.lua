MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Tests = MB.Library.Tests or {}
MB.Library.Tests.Server = MB.Library.Tests.Server or {}

function MB.Library.Tests.Server.RunAll()
    MB.Library.Log("Running all server tests...")
    
    MB.Library.Tests.Server.TestDatabase()
    MB.Library.Tests.Server.TestNetworking()
    MB.Library.Tests.Server.TestLogging()
end

function MB.Library.Tests.Server.TestDatabase()
    MB.Library.Log("Testing database functionality...")
    
    MB.Library.Tests.Assert("Database module exists", 
        MB.Library.Database ~= nil,
        "Database module not found")
    
    if not MB.Library.Database then return end
        
    MB.Library.Tests.AssertType("Database module is table", 
        "table", 
        MB.Library.Database)
end

function MB.Library.Tests.Server.TestNetworking()
    MB.Library.Log("Testing networking functionality...")
    
    MB.Library.Tests.Assert("Networking module exists", 
        MB.Library.Networking ~= nil,
        "Networking module not found")
    
    if not MB.Library.Networking then return end
        
    MB.Library.Tests.AssertType("Networking module is table", 
        "table", 
        MB.Library.Networking)
end

function MB.Library.Tests.Server.TestLogging()
    MB.Library.Log("Testing logging functionality...")
    
    MB.Library.Tests.Assert("Logging module exists", 
        MB.Library.Logs ~= nil,
        "Logging module not found")
    
    if not MB.Library.Logs then return end
        
    MB.Library.Tests.AssertType("Logging module is table", 
        "table", 
        MB.Library.Logs)
end

MB.Library.Tests.Server.RunAll() 