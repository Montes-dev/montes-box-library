MB.Library.Server = MB.Library.Server or {}

include("database/mb_database_config.lua")
include("database/mb_database.lua")
include("control/mb_control.lua")
include("logs/mb_logs.lua")
include("errors/mb_errors.lua")
include("cache/mb_cache.lua")
include("networking/mb_networking.lua")
include("messages/mb_messages.lua")
include("backup/mb_backup.lua")
include("admin/mb_admin.lua")
include("events/mb_events.lua")
include("updates/mb_updates.lua")
include("save_restore/mb_save_restore.lua")
include("optimization/mb_optimization.lua")
include("recovery/mb_recovery.lua")

MB.Library.Log("Server module loaded") 