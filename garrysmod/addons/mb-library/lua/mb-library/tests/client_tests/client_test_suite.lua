MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Tests = MB.Library.Tests or {}
MB.Library.Tests.Client = MB.Library.Tests.Client or {}

function MB.Library.Tests.Client.RunAll()
    MB.Library.Log("Running all client tests...")
    
    MB.Library.Tests.Client.TestUI()
    MB.Library.Tests.Client.TestThemes()
    MB.Library.Tests.Client.TestAnimations()
end

function MB.Library.Tests.Client.TestUI()
    MB.Library.Log("Testing UI functionality...")
    
    MB.Library.Tests.Assert("UI module exists", 
        MB.Library.UI ~= nil,
        "UI module not found")
    
    if not MB.Library.UI then return end
        
    MB.Library.Tests.AssertType("UI module is table", 
        "table", 
        MB.Library.UI)
end

function MB.Library.Tests.Client.TestThemes()
    MB.Library.Log("Testing themes functionality...")
    
    MB.Library.Tests.Assert("Themes module exists", 
        MB.Library.Themes ~= nil,
        "Themes module not found")
    
    if not MB.Library.Themes then return end
        
    MB.Library.Tests.AssertType("Themes module is table", 
        "table", 
        MB.Library.Themes)
    
    MB.Library.Tests.AssertNotNil("Current theme exists",
        MB.Library.Themes.Current)
        
    MB.Library.Tests.AssertNotNil("Available themes exists",
        MB.Library.Themes.Available)
end

function MB.Library.Tests.Client.TestAnimations()
    MB.Library.Log("Testing animations functionality...")
    
    MB.Library.Tests.Assert("Animations module exists", 
        MB.Library.Animations ~= nil,
        "Animations module not found")
    
    if not MB.Library.Animations then return end
        
    MB.Library.Tests.AssertType("Animations module is table", 
        "table", 
        MB.Library.Animations)
    
    if MB.Library.Animations.Easings then
        MB.Library.Tests.AssertNotNil("Linear easing exists",
            MB.Library.Animations.Easings.linear)
    end
end

MB.Library.Tests.Client.RunAll() 