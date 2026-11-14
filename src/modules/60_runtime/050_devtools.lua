--[[ xngot-studio · src/modules/60_runtime/050_devtools.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/60_runtime · log, DevTools, bridge debug
     module : runtime.devtools
     role   : DevTools: note/vars/executors/run/selftest/report
     source : main 2.txt L25470-25636 · 167 dòng · delta +0
--]]
local env = type(getgenv) == "function" and getgenv() or _G
env.xNgotLog = Log
if _G ~= env then _G.xNgotLog = Log end

local DevTools = {}
DevTools.Version = "1.0.0"
DevTools.suite = {}
DevTools.results = {}
DevTools.notes = {}

local function now()
	return os.clock()
end

local function safe(value)
	local ok, text = pcall(tostring, value)
	return ok and text or "<không đọc được>"
end
DevTools.safe = safe

local function trace(err)
	if debug and type(debug.traceback) == "function" then
		return debug.traceback(safe(err), 2)
	end
	return safe(err)
end
DevTools.trace = trace

function DevTools.note(message)
	DevTools.notes[#DevTools.notes + 1] = { at = os.time(), text = safe(message) }
	if #DevTools.notes > 100 then table.remove(DevTools.notes, 1) end
	return true
end

function DevTools.vars()
	local env = type(getgenv) == "function" and getgenv() or _G
	local out = {}
	local function put(name, value)
		out[#out + 1] = { name = name, value = value, kind = type(value) }
	end
	put("_G.xNgotMusicConfig", env.xNgotMusicConfig or _G.xNgotMusicConfig)
	put("_G.CrossAIMusic", env.CrossAIMusic or _G.CrossAIMusic)
	put("_G.Window", env.Window or _G.Window)
	put("Island", (env.Window or _G.Window) and (env.Window or _G.Window).DynamicIsland)
	put("Music", (env.Window or _G.Window) and (env.Window or _G.Window).DynamicIsland and (env.Window or _G.Window).DynamicIsland.MusicState
		and "available" or nil)
	put("lastStartupError", env.xNgotStudioLastStartupError or _G.xNgotStudioLastStartupError)
	put("loaderStage", env.xNgotStudioLastStage or _G.xNgotStudioLastStage)
	return out
end

function DevTools.executors()
	local names = {
		"writefile", "readfile", "isfile", "makefolder", "listfiles", "delfile",
		"getcustomasset", "getsynasset", "request", "http_request", "syn_request",
		"loadstring", "setclipboard", "identifyexecutor", "queue_on_teleport", "getgenv",
	}
	local out = {}
	for _, name in ipairs(names) do
		local ok, value = pcall(function()
			return (type(getgenv) == "function" and getgenv() or _G)[name]
		end)
		out[#out + 1] = { name = name, ok = ok and value ~= nil, kind = ok and type(value) or "?" }
	end
	return out
end

function DevTools.run(code, name)
	code = safe(code)
	local captured = {}
	local realPrint = print
	local function capture(...)
		local parts = {}
		for index = 1, select("#", ...) do parts[index] = safe((select(index, ...))) end
		captured[#captured + 1] = table.concat(parts, " ")
	end
	local loaderFn = loadstring or load
	if type(loaderFn) ~= "function" then
		return { ok = false, error = "executor không có loadstring/load", prints = captured, ms = 0 }
	end
	local started = now()
	print = capture
	local chunk, compileError = loaderFn(code, "=devtools:" .. safe(name or "code"))
	if not chunk then
		print = realPrint
		return { ok = false, error = "lỗi biên dịch: " .. safe(compileError), prints = captured, ms = (now() - started) * 1000 }
	end
	local ok, err = xpcall(chunk, trace)
	print = realPrint
	local ms = (now() - started) * 1000
	DevTools.note(string.format("%s → %s (%.1f ms)", safe(name or "code"), ok and "OK" or "LỖI", ms))
	return { ok = ok, error = ok and nil or safe(err), prints = captured, ms = ms }
end

function DevTools.add(name, fn)
	DevTools.suite[#DevTools.suite + 1] = { name = name, fn = fn }
end

function DevTools.check(name, condition, detail)
	if condition then
		return { name = name, ok = true, detail = detail }
	end
	return { name = name, ok = false, detail = detail or "điều kiện sai" }
end

function DevTools.selftest()
	local results = {}
	local started = now()
	for _, case in ipairs(DevTools.suite) do
		local ok, err = xpcall(case.fn, trace)
		results[#results + 1] = { name = case.name, ok = ok, error = ok and nil or safe(err) }
	end
	local env = type(getgenv) == "function" and getgenv() or _G
	local cfg = env.xNgotMusicConfig or _G.xNgotMusicConfig
	if cfg and type(cfg.Get) == "function" then
		local okGet, value = pcall(cfg.Get, cfg, "topN")
		results[#results + 1] = { name = "config:Get('topN')", ok = okGet and type(value) == "number", error = okGet and nil or safe(value) }
	end
	local engine = env.CrossAIMusic or _G.CrossAIMusic
	if engine and type(engine.parse) == "function" then
		local okParse, plan = pcall(engine.parse, "nhạc lofi buổi tối")
		results[#results + 1] = {
			name = "engine.parse",
			ok = okParse and type(plan) == "table" and type(plan.query) == "string",
			error = okParse and nil or safe(plan),
		}
	end
	local hub = nil
	if hub and type(hub.detectGame) == "function" then
		local okGame, info = pcall(hub.detectGame, true)
		results[#results + 1] = {
			name = "script hub: nhận game",
			ok = okGame and type(info) == "table",
			error = okGame and nil or safe(info),
		}
	end
	local island = (env.Window or _G.Window) and (env.Window or _G.Window).DynamicIsland
	results[#results + 1] = { name = "Island API", ok = type(island) == "table", error = type(island) == "table" and nil or "chưa tạo" }
	DevTools.results = results
	local fails = 0
	for _, item in ipairs(results) do
		if not item.ok then fails = fails + 1 end
	end
	return { results = results, fails = fails, ms = (now() - started) * 1000 }
end

function DevTools.report()
	local lines = { "===== xNgot DevTools · TỰ KIỂM TRA =====" }
	for _, item in ipairs(DevTools.executors()) do
		lines[#lines + 1] = string.format("%s %-18s %s", item.ok and "[ OK ]" or "[ !! ]", item.name, item.kind)
	end
	lines[#lines + 1] = ""
	local report = DevTools.selftest()
	for _, item in ipairs(report.results) do
		lines[#lines + 1] = string.format("%s %-24s %s", item.ok and "[ OK ]" or "[FAIL]", item.name, item.error or "")
	end
	lines[#lines + 1] = string.format("---- %d lỗi · %.1f ms ----", report.fails, report.ms)
	local text = table.concat(lines, "\n")
	pcall(print, text)
	DevTools.lastReport = text
	return text
end

local env = type(getgenv) == "function" and getgenv() or _G
env.xNgotDevTools = DevTools
if _G ~= env then _G.xNgotDevTools = DevTools end

