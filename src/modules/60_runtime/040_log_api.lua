--[[ xngot-studio · src/modules/60_runtime/040_log_api.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/60_runtime · log, DevTools, bridge debug
     module : runtime.log_api
     role   : Log: add/fromPrint/filter/export/hookConsole + mức log
     source : main 2.txt L25261-25469 · 209 dòng · delta +0
--]]
function Log.level(name)
	return Log.levels[name] or 3
end

function Log.format(entry)
	return trimText(string.format("%s [%s] %s: %s", tostring(entry.time), string.upper(tostring(entry.level)),
		tostring(entry.tag), tostring(entry.message)), MAX_TEXT + MAX_TAG + 40)
end

local function trimMessage(text)
	return trimText(text, MAX_TEXT)
end

function Log.add(level, tag, message, data)
	level = Log.levels[level] and level or "info"
	Log.counts[level] = (Log.counts[level] or 0) + 1
	if Log.levels[level] < Log.minLevel then return nil end
	if (Log.depth or 0) > 2 then
		Log.suppressed = (Log.suppressed or 0) + 1
		return nil
	end
	if type(tag) == "table" then
		tag, message = message, data
		if type(tag) == "table" then tag = "log" end
		Log.misuse = (Log.misuse or 0) + 1
	end
	Log.depth = (Log.depth or 0) + 1
	Log.seq = Log.seq + 1
	local now = os.clock()
	local entry = {
		level = level,
		tag = trimText(safe(tag), MAX_TAG),
		message = trimMessage(safe(message)),
		data = data,
		at = now,
		stamp = now,
		time = string.format("%6.2fs", now),
		count = Log.seq,
		id = Log.seq,
	}
	Log.entries[#Log.entries + 1] = entry
	if #Log.entries > Log.maxEntries then
		table.remove(Log.entries, 1)
		Log.dropped = Log.dropped + 1
	end
	if level == "error" and Log.traceErrors ~= false and debug and type(debug.traceback) == "function" then
		local okTrace, stack = pcall(debug.traceback, "", 3)
		if okTrace and type(stack) == "string" then
			entry.trace = stack:sub(1, 1500)
		end
	end
	if (level == "error" or level == "warn") and (Log.depth or 0) <= 1 then
		pcall(print, "[xNgot " .. string.upper(level) .. "] " .. tostring(entry.tag) .. " · "
			.. tostring(entry.message):sub(1, 400))
	end
	pcall(function()
		for _, listener in ipairs(Log.listeners) do pcall(listener, entry) end
	end)
	Log.depth = (Log.depth or 1) - 1
	if Log.depth < 0 then Log.depth = 0 end
	return entry
end

for name in pairs(Log.levels) do
	Log[name] = function(tag, message, data)
		if type(tag) == "table" then

			tag, message, data = message, data, nil
		end
		local ok, entry = pcall(Log.add, name, tag, message, data)
		if not ok then
			Log.depth = 0
			Log.failures = (Log.failures or 0) + 1
			return nil
		end
		return entry
	end
end

Log.trimMessage = trimMessage
Log.trimText = trimText
Log.MAX_TEXT = MAX_TEXT
Log.MAX_TAG = MAX_TAG

function Log.fromPrint(...)
	local pieces = {}
	for index = 1, select("#", ...) do pieces[#pieces + 1] = safe((select(index, ...))) end
	return Log.add("info", "print", table.concat(pieces, " "))
end

function Log.onEntry(callback)
	Log.listeners[#Log.listeners + 1] = callback
	return function()
		for index = #Log.listeners, 1, -1 do
			if Log.listeners[index] == callback then table.remove(Log.listeners, index) end
		end
	end
end

function Log.clear()
	Log.entries = {}
	Log.counts = { trace = 0, debug = 0, info = 0, warn = 0, error = 0 }
	Log.dropped = 0
end

function Log.filter(level, tag, search)
	local wanted = level and Log.levels[level] or 0
	local needle = search and string.lower(safe(search)) or nil
	local out = {}
	for index = #Log.entries, 1, -1 do
		local entry = Log.entries[index]
		local ok = Log.levels[entry.level] >= wanted
		if ok and tag and tag ~= "" and tag ~= "all" then ok = entry.tag == tag end
		if ok and needle and needle ~= "" then
			ok = string.lower(entry.message):find(needle, 1, true) ~= nil
				or string.lower(entry.tag):find(needle, 1, true) ~= nil
		end
		if ok then out[#out + 1] = entry end
	end
	return out
end

function Log.tags()
	local seen, list = {}, {}
	for _, entry in ipairs(Log.entries) do
		if not seen[entry.tag] then
			seen[entry.tag] = true
			list[#list + 1] = entry.tag
		end
	end
	table.sort(list)
	return list
end

function Log.export()
	local lines = {}
	for _, entry in ipairs(Log.entries) do lines[#lines + 1] = Log.format(entry) end
	return table.concat(lines, "\n")
end

function Log.download()
	local clipboard = setclipboard or toclipboard
	if type(clipboard) == "function" then
		local ok = pcall(clipboard, Log.export())
		return ok
	end
	return false
end

function Log.apiCall(fields)
	fields = fields or {}
	local message = string.format("%s %s -> %s · %sms · %s",
		tostring(fields.method or "GET"), tostring(fields.url or "?"),
		tostring(fields.status or "?"), tostring(fields.ms or "?"),
		tostring(fields.bytes and (fields.bytes .. "B") or (fields.note or "")))
	local level = "info"
	if fields.ok == false then level = "error"
	elseif fields.status and tonumber(fields.status) and tonumber(fields.status) >= 400 then level = "warn" end
	local entry = Log.add(level, "api", message, fields)
	Log.api[#Log.api + 1] = fields
	if #Log.api > 300 then table.remove(Log.api, 1) end
	return entry
end

function Log.measure(label)
	local started = os.clock()
	return function(extra)
		local ms = (os.clock() - started) * 1000
		local entry = Log.add(ms > 1500 and "warn" or "debug", "perf",
			string.format("%s · %.1f ms%s", tostring(label), ms, extra and (" · " .. tostring(extra)) or ""))
		return ms, entry
	end
end

function Log.countsByTag()
	local out = {}
	for _, entry in ipairs(Log.entries) do
		out[entry.tag] = (out[entry.tag] or 0) + 1
	end
	return out
end

function Log.stats()
	local stats = { total = #Log.entries, dropped = Log.dropped, api = #Log.api, tags = 0 }
	for _ in pairs(Log.countsByTag()) do stats.tags = stats.tags + 1 end
	for level, count in pairs(Log.counts) do stats[level] = count end
	stats.minLevel = Log.minLevel
	return stats
end

function Log.hookConsole()
	if Log._hooked then return end
	Log._hooked = true
	local realPrint, realWarn = print, warn
	Log.realPrint, Log.realWarn = realPrint, realWarn
	print = function(...)
		Log.fromPrint(...)
		if realPrint then realPrint(...) end
	end
	warn = function(...)
		local pieces = {}
		for index = 1, select("#", ...) do pieces[#pieces + 1] = safe((select(index, ...))) end
		Log.add("warn", "warn", table.concat(pieces, " "))
		if realWarn and (Log.depth or 0) <= 1 then realWarn(...) end
	end
end

Log.COLORS = COLORS

