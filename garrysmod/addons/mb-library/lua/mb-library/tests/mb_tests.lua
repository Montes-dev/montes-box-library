MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Tests = MB.Library.Tests or {}

MB.Library.Tests.Results = {
    total = 0,
    passed = 0,
    failed = 0,
    skipped = 0
}

function MB.Library.Tests.Run(filter)
    MB.Library.Log("Starting test suite...")
    
    MB.Library.Tests.Results = {
        total = 0,
        passed = 0,
        failed = 0,
        skipped = 0
    }
    
    filter = filter or {}
    
    local startTime = SysTime()
    
    if (SERVER or filter.runServer) and not filter.skipServer then
        MB.Library.Tests.RunServerTests()
    end
    
    if (CLIENT or filter.runClient) and not filter.skipClient then
        MB.Library.Tests.RunClientTests()
    end
    
    if not filter.skipShared then
        MB.Library.Tests.RunSharedTests()
    end
    
    local endTime = SysTime()
    local duration = endTime - startTime
    
    MB.Library.Log("Test suite completed in " .. string.format("%.3f", duration) .. " seconds")
    MB.Library.Log("Results: " .. MB.Library.Tests.Results.passed .. " passed, " .. 
                  MB.Library.Tests.Results.failed .. " failed, " .. 
                  MB.Library.Tests.Results.skipped .. " skipped (total: " .. 
                  MB.Library.Tests.Results.total .. ")")
                  
    return MB.Library.Tests.Results
end

function MB.Library.Tests.RunServerTests()
    if SERVER then
        MB.Library.Log("Running server tests...")
        include("mb-library/tests/server_tests/server_test_suite.lua")
    end
end

function MB.Library.Tests.RunClientTests()
    if CLIENT then
        MB.Library.Log("Running client tests...")
        include("mb-library/tests/client_tests/client_test_suite.lua")
    end
end

function MB.Library.Tests.RunSharedTests()
    MB.Library.Log("Running shared tests...")
    include("mb-library/tests/shared_tests/shared_test_suite.lua")
end

function MB.Library.Tests.Assert(name, condition, message)
    MB.Library.Tests.Results.total = MB.Library.Tests.Results.total + 1
    
    if condition then
        MB.Library.Tests.Results.passed = MB.Library.Tests.Results.passed + 1
        MB.Library.Log("[PASS] " .. name)
        return true
    else
        MB.Library.Tests.Results.failed = MB.Library.Tests.Results.failed + 1
        MB.Library.Log("[FAIL] " .. name .. ": " .. (message or "Test failed"))
        return false
    end
end

function MB.Library.Tests.AssertEqual(name, expected, actual, message)
    return MB.Library.Tests.Assert(
        name,
        expected == actual,
        message or ("Expected: " .. tostring(expected) .. ", Got: " .. tostring(actual))
    )
end

function MB.Library.Tests.AssertNotEqual(name, expected, actual, message)
    return MB.Library.Tests.Assert(
        name,
        expected ~= actual,
        message or ("Expected value to differ from: " .. tostring(expected))
    )
end

function MB.Library.Tests.AssertTrue(name, value, message)
    return MB.Library.Tests.Assert(
        name,
        value == true,
        message or "Expected true, got " .. tostring(value)
    )
end

function MB.Library.Tests.AssertFalse(name, value, message)
    return MB.Library.Tests.Assert(
        name,
        value == false,
        message or "Expected false, got " .. tostring(value)
    )
end

function MB.Library.Tests.AssertNil(name, value, message)
    return MB.Library.Tests.Assert(
        name,
        value == nil,
        message or "Expected nil, got " .. tostring(value)
    )
end

function MB.Library.Tests.AssertNotNil(name, value, message)
    return MB.Library.Tests.Assert(
        name,
        value ~= nil,
        message or "Expected not nil, got nil"
    )
end

function MB.Library.Tests.AssertType(name, expectedType, value, message)
    return MB.Library.Tests.Assert(
        name,
        type(value) == expectedType,
        message or ("Expected type " .. expectedType .. ", got " .. type(value))
    )
end

function MB.Library.Tests.Skip(name, reason)
    MB.Library.Tests.Results.total = MB.Library.Tests.Results.total + 1
    MB.Library.Tests.Results.skipped = MB.Library.Tests.Results.skipped + 1
    MB.Library.Log("[SKIP] " .. name .. ": " .. (reason or "Test skipped"))
end

MB.Library.Log("Test framework initialized") 