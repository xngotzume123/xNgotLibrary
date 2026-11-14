--[[ xngot-studio · src/modules/60_runtime/080_debug_panel.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/60_runtime · log, DevTools, bridge debug
     module : runtime.debug_panel
     role   : Debug: panel log, export, toggle/open/close
     source : main 2.txt L25835-26019 · 185 dòng · delta +0
--]]
local Debug = {}
Debug.Version = "v9.4.0"
Debug.isOpen = false
Debug.Iris = nil
Debug.fps = 0
Debug.frames = 0
Debug.lastTick = os.clock()
Debug.hotkey = Enum.KeyCode.RightShift
Debug.tab = 1
Debug.error = nil
Debug.snapshot = { counts = {}, hub = {}, island = {}, mem = 0 }

local function liteGlobal(name)
	local ok, env = pcall(function() return getgenv and getgenv() or _G end)
	if not ok or type(env) ~= "table" then env = _G end
	if env and env ~= _G and env[name] ~= nil then return env[name] end
	return _G[name]
end

local function liteLog()
	return liteGlobal("xNgotLog")
end

local function liteWrite(level, message)
	local logApi = liteLog()
	if logApi then logApi[level]("debug", message) end
end

local function liteCopy(text)
	text = tostring(text or "")
	if text == "" then return false end
	local clipboard = setclipboard or toclipboard
	if type(clipboard) ~= "function" then return false end
	return (pcall(clipboard, text))
end

function Debug.exportLog(options)
	options = options or {}
	local logApi = liteLog()
	if not logApi then return nil end
	local entries = logApi.entries or {}
	local lines = {}
	lines[#lines + 1] = "===== xNgot Library · GET LOG THẬT ====="
	lines[#lines + 1] = string.format("thời điểm: %s · %d dòng · build %s · bản %s",
		os.date("%Y-%m-%d %H:%M:%S"), #entries, tostring(Debug.Version), tostring(Debug.Build))
	lines[#lines + 1] = string.format("iris=%s · mode=%s · visible=%s · cycles=%s · stackFixed=%s",
		tostring(Debug.Iris ~= nil), tostring(Debug.mode), tostring(Debug.visible),
		tostring(Debug.cycles or 0), tostring(Debug.stackFixed))
	lines[#lines + 1] = string.format("counts: trace=%s debug=%s info=%s warn=%s error=%s · suppressed=%s",
		tostring(logApi.counts.trace), tostring(logApi.counts.debug), tostring(logApi.counts.info),
		tostring(logApi.counts.warn), tostring(logApi.counts.error), tostring(logApi.suppressed or 0))
	lines[#lines + 1] = "-------------------------------------------"
	for _, entry in ipairs(entries) do
		lines[#lines + 1] = string.format("%s [%s] %s: %s", tostring(entry.time),
			string.upper(tostring(entry.level)), tostring(entry.tag), tostring(entry.message))
		if entry.data ~= nil then
			lines[#lines + 1] = "    data: " .. tostring(entry.data)
		end
		if entry.trace then
			lines[#lines + 1] = "    stack: " .. tostring(entry.trace):gsub("\n", "\n    ")
		end
	end
	local text = table.concat(lines, "\n")
	Debug.lastExport = text
	Debug.lastExportAt = os.clock()
	liteWrite("debug", string.format("GET LOG: %d dòng · %d ký tự", #entries, #text))
	if options.copy ~= false then
		Debug.copyExport = liteCopy(text)
	end
	return text
end

function Debug.getLogPanel()
	local logApi = liteLog()
	if not logApi then return false end
	local text = Debug.exportLog({ copy = true })
	local okClip = type(setclipboard) == "function" or type(toclipboard) == "function"
	liteWrite(okClip and "info" or "warn", okClip
		and "đã copy toàn bộ log vào clipboard (Ctrl+V để dán)"
		or "executor không có setclipboard — log vẫn in ra F9")
	if text then
		if logApi._hooked and type(logApi.realPrint) == "function" then
			pcall(logApi.realPrint, text)
		else
			pcall(function() print(text) end)
		end
	end
	return true
end

Debug.Build = "release"

function Debug.mode()
	return "release"
end

function Debug.report()
	local text = Debug.exportLog({ copy = true })
	if text then
		local logApi = liteLog()
		if logApi and logApi._hooked and type(logApi.realPrint) == "function" then
			pcall(logApi.realPrint, text)
		else
			pcall(function() print(text) end)
		end
	end
	return text
end

local S = {}

local function envTable()
	local ok, env = pcall(function() return getgenv and getgenv() or _G end)
	if ok and type(env) == "table" then return env end
	return _G
end

local function global(name)
	local env = envTable()
	if env and env ~= _G and env[name] ~= nil then return env[name] end
	return _G[name]
end

local function log()
	return global("xNgotLog")
end

local function write(level, message)
	local logApi = log()
	if logApi then logApi[level]("debug", message) end
end

local function copy(text)
	text = tostring(text or "")
	if text == "" then return false end
	local clipboard = setclipboard or toclipboard
	if type(clipboard) ~= "function" then return false end
	return (pcall(clipboard, text))
end

local function safe(value)
	local ok, text = pcall(tostring, value)
	return ok and text or "?"
end

function Debug.toggle()
	liteWrite("info", "bản phát hành không có panel Iris — dùng _G.xNgotDebug.getLogPanel() để lấy log")
	return false
end

function Debug.open()
	return Debug.toggle()
end

function Debug.openPanel() return Debug.toggle() end
function Debug.closePanel() return false end
function Debug.setTab(index) return math.clamp(tonumber(index) or 1, 1, 4) end
function Debug.attach() return Debug end
function Debug.place() return false end
function Debug.watchdog() return "release" end
function Debug.resetPlacement() return false end
function Debug.setHotkey(keyCode) if keyCode then Debug.hotkey = keyCode end return Debug.hotkey end
function Debug.diagnostics() return Debug.panel() end

function Debug.panel()
	return {
		open = false,
		iris = false,
		mode = "release",
		build = "release",
		version = Debug.Version,
		cycles = 0,
		error = nil,
		hotkey = tostring(Debug.hotkey),
		tabs = 0,
		lastExport = type(Debug.lastExport) == "string" and #Debug.lastExport or 0,
	}
end

local env = type(getgenv) == "function" and getgenv() or _G
env.xNgotDebug = Debug
if _G ~= env then
	pcall(function() _G.xNgotDebug = Debug end)
end

