--[[ xngot-studio · src/modules/60_runtime/030_log_core.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/60_runtime · log, DevTools, bridge debug
     module : runtime.log_core
     role   : Bảng Log + trimText/looksLikeSelf/safe
     source : main 2.txt L25192-25260 · 69 dòng · delta +0
--]]
local Log = {}
Log.Version = "1.0.0"
Log.entries = {}
Log.levels = { trace = 1, debug = 2, info = 3, warn = 4, error = 5 }
Log.minLevel = 2
Log.maxEntries = 1200
Log.listeners = {}
Log.counts = { trace = 0, debug = 0, info = 0, warn = 0, error = 0 }
Log.dropped = 0
Log.api = {}
Log.seq = 0

local COLORS = {
	trace = Color3.fromRGB(140, 150, 170),
	debug = Color3.fromRGB(120, 170, 230),
	info = Color3.fromRGB(150, 220, 170),
	warn = Color3.fromRGB(240, 200, 110),
	error = Color3.fromRGB(255, 140, 130),
}

local MAX_TEXT = 800
local MAX_TAG = 120
local MAX_TABLE = 40

local function trimText(text, limit)
	text = tostring(text or "")
	if #text <= limit then return text end
	return text:sub(1, limit) .. string.format(" …(+%d ký tự)", #text - limit)
end

local function looksLikeSelf(text)
	if #text < 400 then return false end
	return text:find('"maxEntries"', 1, true) ~= nil
		or text:find('"minLevel"', 1, true) ~= nil
		or text:find('"_hooked"', 1, true) ~= nil
end

local function safe(value)
	if type(value) == "table" then
		local keys = 0
		local huge = rawget(value, "entries") ~= nil
		for _ in pairs(value) do
			keys = keys + 1
			if keys > MAX_TABLE then break end
		end
		if huge or keys > MAX_TABLE then
			return string.format("<bảng %d+ khoá>", keys)
		end
		local okJson, text = pcall(function()
			return game:GetService("HttpService"):JSONEncode(value)
		end)
		if okJson and type(text) == "string" then
			if looksLikeSelf(text) then return "<bảng Log — đã lọc>" end
			return trimText(text, MAX_TEXT * 2)
		end
		local pieces = {}
		for key, item in pairs(value) do
			pieces[#pieces + 1] = tostring(key) .. "=" .. tostring(item)
			if #pieces > MAX_TABLE then break end
		end
		return trimText("{" .. table.concat(pieces, ", ") .. "}", MAX_TEXT * 2)
	end
	local ok, text = pcall(tostring, value)
	text = ok and text or "<không đọc được>"
	if looksLikeSelf(text) then return "<bảng Log — đã lọc>" end
	return text
end
Log.safe = safe

