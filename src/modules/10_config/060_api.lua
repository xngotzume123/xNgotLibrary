--[[ xngot-studio · src/modules/10_config/060_api.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/10_config · cấu hình nhạc toàn cục _G.xNgotMusicConfig
     module : config.api
     role   : Api: Get/Set/Schema/OnChange/Apply/Preset/Presets + xuất _G
     source : main 2.txt L132-200 · 69 dòng · delta +0
--]]
local Api = {}
function Api:Get(key)
	if key then return Config[key] end
	local copy = {}
	for k, v in pairs(Config) do
		if type(v) == "table" then
			local t = {}
			for i, x in ipairs(v) do t[i] = x end
			copy[k] = t
		else
			copy[k] = v
		end
	end
	return copy
end
function Api:Set(key, value)
	local ok, err = set(key, value)
	if ok then
		log("config", key, "=", tostring(value))
		local engine = _G.CrossAIMusic
		if engine then applyToEngine(engine) end
	end
	return ok, err
end
function Api:Schema() return ConfigSchema end
function Api:OnChange(fn)
	if type(fn) ~= "function" then return function() end end
	listeners[#listeners + 1] = fn
	return function()
		for i = #listeners, 1, -1 do
			if listeners[i] == fn then table.remove(listeners, i) end
		end
	end
end
function Api:Apply() return applyToEngine(_G.CrossAIMusic) end

local Presets = {
	fast = { raceTracks = 2, topN = 8, searchTimeout = 8, preferShort = 480,
		sources = { "youtube", "audius" } },
	["quality"] = { raceTracks = 1, topN = 20, searchTimeout = 20, preferShort = 900,
		sources = { "youtube", "soundcloud", "audius" } },
	["lowdata"] = { raceTracks = 1, topN = 6, searchTimeout = 8, coverArt = false,
		sources = { "youtube" } },
	["vietnamese"] = { sources = { "soundcloud", "youtube" }, topN = 15,
		preferShort = 420 },
}
function Api:Preset(name)
	local p = Presets[tostring(name or ""):lower()]
	if not p then return false, "không có preset: " .. tostring(name) end
	for k, v in pairs(p) do Api:Set(k, v) end
	return true
end
function Api:Presets()
	local names = {}
	for k in pairs(Presets) do names[#names + 1] = k end
	table.sort(names)
	return names
end

do
	local gv = type(getgenv) == "function" and getgenv() or _G
	local preset = gv.xNgotMusicPreset
	if type(preset) == "string" and preset ~= "" and Api.Preset then
		pcall(Api.Preset, Api, preset)
	end
end

_G.xNgotMusicConfig = Api

