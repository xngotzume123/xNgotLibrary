--[[ xngot-studio · src/modules/10_config/020_coerce.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/10_config · cấu hình nhạc toàn cục _G.xNgotMusicConfig
     module : config.coerce
     role   : Chuẩn hoá giá trị theo schema + bảng Config + listeners
     source : main 2.txt L60-82 · 23 dòng · delta +0
--]]
local listeners = {}

local function coerce(key, value)
	local spec = ConfigSchema[key]
	if not spec then return nil, "unknown key" end
	local okType = true
	if spec.type == "number" then
		local n = tonumber(value)
		if not n then return nil, "cần số" end
		if spec.min and n < spec.min then n = spec.min end
		if spec.max and n > spec.max then n = spec.max end
		return math.floor(n)
	elseif spec.type == "boolean" then
		return value == true
	elseif spec.type == "string" then
		return tostring(value or "")
	elseif spec.type == "table" then
		if type(value) ~= "table" then return nil, "cần bảng" end
		return value
	end
	return okType and value or nil
end

