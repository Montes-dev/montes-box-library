if SERVER then
    AddCSLuaFile("mb-library/shared/mb_library_shared.lua")
    AddCSLuaFile("mb-library/client/mb_library_client.lua")
    
    AddCSLuaFile("mb-library/client/ui/mb_ui.lua")
    AddCSLuaFile("mb-library/client/themes/mb_themes.lua")
    AddCSLuaFile("mb-library/client/ui/mb_networking.lua")
    AddCSLuaFile("mb-library/client/ui/mb_admin_panel.lua")
    AddCSLuaFile("mb-library/client/server_info/mb_server_info.lua")
    AddCSLuaFile("mb-library/client/graphics/mb_graphics.lua")
    AddCSLuaFile("mb-library/client/interactive/mb_interactive.lua")
    AddCSLuaFile("mb-library/client/notifications/mb_notifications.lua")
    AddCSLuaFile("mb-library/client/animations/mb_animations.lua")
    AddCSLuaFile("mb-library/client/localization/mb_localization.lua")
    AddCSLuaFile("mb-library/client/settings/mb_settings.lua")
    AddCSLuaFile("mb-library/client/addons/mb_addons.lua")
    AddCSLuaFile("mb-library/client/status/mb_status.lua")
    AddCSLuaFile("mb-library/client/achievements/mb_achievements.lua")
    AddCSLuaFile("mb-library/client/cross_platform/mb_cross_platform.lua")
    AddCSLuaFile("mb-library/client/performance/mb_performance.lua")
    AddCSLuaFile("mb-library/client/chat/mb_chat.lua")
    AddCSLuaFile("mb-library/client/fonts/mb_fonts.lua")
    AddCSLuaFile("mb-library/client/utilities/mb_colors.lua")
    AddCSLuaFile("mb-library/client/demo/mb_demo.lua")
    
    include("mb-library/shared/mb_library_shared.lua")
    include("mb-library/server/mb_library_server.lua")
else
    include("mb-library/shared/mb_library_shared.lua")
    include("mb-library/client/mb_library_client.lua")
end

MsgC(Color(255, 0, 0), "[MB-Library] ", Color(255, 255, 255), "Initialized\n") 