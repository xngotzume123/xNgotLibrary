--[[ xngot-studio · src/modules/10_config/030_set.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/10_config · cấu hình nhạc toàn cục _G.xNgotMusicConfig
     module : config.set
     role   : Hàm set(): ghi giá trị, phát listener, lưu vào engine
     source : main 2.txt L83-104 · 22 dòng · delta +0
--]]
local function set(key, value, silent)
	local v, err = coerce(key, value)
	if v == nil then return false, err end
	Config[key] = v
	if not silent then
		for _, fn in ipairs(listeners) do pcall(fn, key, v) end
	end
	return true
end

for key, spec in pairs(ConfigSchema) do
	Config[key] = spec.default
end
do
	local ext = type(getgenv) == "function" and getgenv().xNgotMusic or _G.xNgotMusic
	if type(ext) == "table" then
		for key, value in pairs(ext) do
			if ConfigSchema[key] then set(key, value, true) end
		end
	end
end

