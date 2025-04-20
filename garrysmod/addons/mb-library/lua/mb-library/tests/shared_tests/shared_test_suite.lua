MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Tests = MB.Library.Tests or {}
MB.Library.Tests.Shared = MB.Library.Tests.Shared or {}

function MB.Library.Tests.Shared.RunAll()
    MB.Library.Log("Running all shared tests...")
    
    MB.Library.Tests.Shared.TestConfiguration()
    MB.Library.Tests.Shared.TestUtilities()
    MB.Library.Tests.Shared.TestValidation()
end

function MB.Library.Tests.Shared.TestConfiguration()
    MB.Library.Log("Testing configuration functionality...")
    
    MB.Library.Tests.Assert("Config module exists", 
        MB.Library.Config ~= nil,
        "Config module not found")
    
    if not MB.Library.Config then return end
        
    MB.Library.Tests.AssertType("Config module is table", 
        "table", 
        MB.Library.Config)
end

function MB.Library.Tests.Shared.TestUtilities()
    MB.Library.Log("Testing utilities functionality...")
    
    MB.Library.Tests.Assert("Colors utility exists", 
        MB.Library.Colors ~= nil,
        "Colors utility not found")
    
    if MB.Library.Colors then
        MB.Library.Tests.AssertType("Colors utility is table", 
            "table", 
            MB.Library.Colors)
            
        if MB.Library.Colors.HexToColor then
            local color = MB.Library.Colors.HexToColor("#FF0000")
            MB.Library.Tests.Assert("HexToColor returns Color object", 
                IsColor(color),
                "HexToColor did not return Color object")
                
            if IsColor(color) then
                MB.Library.Tests.AssertEqual("Red channel correct", 255, color.r)
                MB.Library.Tests.AssertEqual("Green channel correct", 0, color.g)
                MB.Library.Tests.AssertEqual("Blue channel correct", 0, color.b)
            end
        end
    end
end

function MB.Library.Tests.Shared.TestValidation()
    MB.Library.Log("Testing validation functionality...")
    
    MB.Library.Tests.Assert("Validation module exists", 
        MB.Library.Validation ~= nil,
        "Validation module not found")
    
    if not MB.Library.Validation then
        MB.Library.Tests.Skip("Validation module tests", "Module not found")
        return
    end
        
    MB.Library.Tests.AssertType("Validation module is table", 
        "table", 
        MB.Library.Validation)
end

MB.Library.Tests.Shared.RunAll() 