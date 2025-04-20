MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Validation = MB.Library.Validation or {}

function MB.Library.Validation.Initialize()
    MB.Library.Log("Validation module initialized")
end

function MB.Library.Validation.IsString(value)
    return type(value) == "string"
end

function MB.Library.Validation.IsNumber(value)
    return type(value) == "number"
end

function MB.Library.Validation.IsBoolean(value)
    return type(value) == "boolean"
end

function MB.Library.Validation.IsTable(value)
    return type(value) == "table"
end

function MB.Library.Validation.IsFunction(value)
    return type(value) == "function"
end

function MB.Library.Validation.IsNil(value)
    return value == nil
end

function MB.Library.Validation.IsStringEmpty(value)
    return not MB.Library.Validation.IsString(value) or value == ""
end

function MB.Library.Validation.IsValidEmail(email)
    if not MB.Library.Validation.IsString(email) then return false end
    
    return string.match(email, "^[%w%.]+@[%w%.]+%.%w+$") ~= nil
end

hook.Add("MB.Library.Initialize", "MB.Library.Validation.Init", function()
    MB.Library.Validation.Initialize()
end) 