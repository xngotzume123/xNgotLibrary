--[[ xngot-studio · src/stubs/http_log.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/stubs · thay thế cho module khi build --release
     module : stub.http_log
     role   : Tắt hook http_request — không ghi log request/response
     source : viết tay (không có trong bản gốc)
--]]
local __xNgotHttpLog = function()
	return false
end

__xNgotHttpLog()
