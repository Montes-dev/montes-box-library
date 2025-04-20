MB = MB or {}
MB.Library = MB.Library or {}
MB.Library.Version = "1.0.0"
MB.Library.Name = "MB-Library"

function MB.Library.Log(msg)
    MsgC(Color(255, 0, 0), "[MB-Library] ", Color(255, 255, 255), msg.."\n")
end

MB.Library.Log("Shared module loaded") 