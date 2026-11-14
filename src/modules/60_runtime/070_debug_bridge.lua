--[[ xngot-studio · src/modules/60_runtime/070_debug_bridge.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/60_runtime · log, DevTools, bridge debug
     module : runtime.debug_bridge
     role   : __xNgotDebugBridge: open/close/show/notify/playMusic/state/report
     source : main 2.txt L25668-25834 · 167 dòng · delta +0
--]]
local __xNgotDebugBridge = function()
	local logApi = _G.xNgotLog
	if not (logApi and type(logApi.add) == "function") then return end
	local env = type(getgenv) == "function" and getgenv() or _G

	if type(env.Window) ~= "table" then env.Window = _G.Window end
	local window = env.Window or _G.Window
	local function islandAPI()
		local w = env.Window
		if type(w) ~= "table" then w = _G.Window end
		if type(w) == "table" and type(w.DynamicIsland) == "table" then return w.DynamicIsland end
		return nil
	end
	local islandApi = islandAPI()
	local Bridge = { Version = "1.0.1", api = islandApi, log = logApi }
	Bridge.tabs = { "Tổng quan", "Âm nhạc", "Cross", "Cài đặt" }

	function Bridge.open(tabIndex)
		Bridge.tabRequest = tonumber(tabIndex)
		local api = islandAPI()
		Bridge.api = api
		if type(api) ~= "table" then
			logApi.error("debug", "island chưa sẵn sàng (Window.DynamicIsland = nil)")
			return false
		end
		local ok, expanded = pcall(function() return api:Expand("Home") end)
		if not ok then
			logApi.error("debug", "mở island lỗi: " .. tostring(expanded))
			return false
		end
		logApi.info("debug", "đã mở Dynamic Island" .. (Bridge.tabRequest and (" (tab " .. Bridge.tabRequest .. ")") or ""))
		return true
	end

	function Bridge.close()
		local api = islandAPI()
		if type(api) ~= "table" then return false end
		local ok = pcall(function() return api:Collapse() end)
		if ok then logApi.info("debug", "đã đóng Dynamic Island") end
		return ok
	end

	function Bridge.show()
		local api = islandAPI()
		if type(api) ~= "table" then return false end
		local ok = pcall(function() return api:Enable(true) end)
		return ok
	end

	function Bridge.notify(title, message, kind, duration)
		local api = islandAPI()
		if type(api) ~= "table" then return false end
		local ok, res = pcall(function()
			return api:Notify(title or "xNgot Library", message or "test", kind or "info", duration or 3)
		end)
		logApi.add(ok and "info" or "error", "debug",
			"notify thử: " .. tostring(title) .. " · " .. tostring(ok and res or "lỗi"))
		return ok
	end

	function Bridge.playMusic()
		local api = islandAPI()
		if type(api) ~= "table" then return false end
		local ok = pcall(function() return api:PlayMusic() end)
		logApi.add(ok and "info" or "error", "debug", "thử phát nhạc qua island: " .. tostring(ok))
		return ok
	end

	function Bridge.timer(seconds)
		local api = islandAPI()
		if type(api) ~= "table" then return false end
		local ok = pcall(function() return api:Timer(tonumber(seconds) or 60) end)
		logApi.add(ok and "info" or "error", "debug", "thử hẹn giờ " .. tostring(seconds or 60) .. "s: " .. tostring(ok))
		return ok
	end

	function Bridge.state()
		local snapshot = {
			window = type(window) == "table",
			island = type(islandAPI()) == "table",
			music = type(env.CrossAIMusic) == "table",
			config = type(env.xNgotMusicConfig) == "table",
			devtools = type(_G.xNgotDevTools) == "table",
			iris = type(_G.xNgotIris) == "table",
			logs = #logApi.entries,
			player = (function()
				local ok, name = pcall(function()
					return game:GetService("Players").LocalPlayer.Name
				end)
				return ok and name or "?"
			end)(),
		}
		return snapshot
	end

	function Bridge.report()
		local st = Bridge.state()
		local parts = {}
		for key, value in pairs(st) do
			parts[#parts + 1] = tostring(key) .. "=" .. tostring(value)
		end
		table.sort(parts)
		local text = "trạng thái: " .. table.concat(parts, " · ")
		logApi.info("debug", text)
		return text
	end

	function Bridge.copyLog()
		local clipboard = setclipboard or toclipboard
		if type(clipboard) ~= "function" then return false end
		return (pcall(clipboard, logApi.export()))
	end

	function Bridge.copyReport()
		local lines = { Bridge.report(), "", logApi.export() }
		local clipboard = setclipboard or toclipboard
		if type(clipboard) ~= "function" then return false end
		return (pcall(clipboard, table.concat(lines, "\n")))
	end

	local function wrapTable(target, prefix, skip)
		if type(target) ~= "table" or target.__xNgotLogged then return end
		target.__xNgotLogged = true
		local names = {}
		for name in pairs(target) do
			if type(target[name]) == "function" and not (skip and skip[name]) then names[#names + 1] = name end
		end
		for _, name in ipairs(names) do
			local base = target[name]
			target[name] = function(...)
				local started = os.clock()
				local results = table.pack(pcall(base, ...))
				local ms = math.floor((os.clock() - started) * 1000)
				if logApi.minLevel <= 2 then
					local args = {}
					for index = 1, math.min(select("#", ...), 2) do
						local value = select(index, ...)
						args[#args + 1] = type(value) == "string" and (value:sub(1, 24)) or tostring(value)
					end
					logApi.add(results[1] and "debug" or "error", prefix,
						string.format("%s(%s) · %dms", name, table.concat(args, ", "), ms))
				end
				if not results[1] then error(results[2], 0) end
				return table.unpack(results, 2, results.n)
			end
		end
	end

	Bridge.api = islandApi
	wrapTable(islandApi, "island", { Destroy = true, Get = true })
	if type(env.CrossAIMusic) == "table" then
		wrapTable(env.CrossAIMusic, "music", { request = true })
	end

	local debugApi = _G.xNgotDebug
	if type(debugApi) == "table" then
		debugApi.bridge = Bridge
		debugApi.open = function(tabIndex) return Bridge.open(tabIndex) end
		debugApi.close = function() return Bridge.close() end
	end
	env.xNgotDebugBridge = Bridge
	if _G ~= env then _G.xNgotDebugBridge = Bridge end
	logApi.debug("debug", "bridge sẵn sàng: _G.xNgotDebug.open(tab) mở Dynamic Island, _G.xNgotDebugBridge.report() xem trạng thái")
	return Bridge
end
__xNgotDebugBridge()

