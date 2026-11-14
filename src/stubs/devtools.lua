--[[ xngot-studio · src/stubs/devtools.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/stubs · thay thế cho module khi build --release
     module : stub.devtools
     role   : DevTools rỗng — giữ đúng tên/API để boot không lỗi
     source : viết tay (không có trong bản gốc)
--]]
local env = type(getgenv) == "function" and getgenv() or _G

if _G ~= env then _G.xNgotLog = Log end

local DevTools = {}
DevTools.Version = "3.0.0-stub"
DevTools.suite = {}
DevTools.results = {}
DevTools.notes = {}

function DevTools.note() return DevTools.notes end
function DevTools.vars() return {} end
function DevTools.executors() return {} end
function DevTools.run(code) return loadstring and loadstring(tostring(code or "")) ~= nil end
function DevTools.add() return nil end
function DevTools.check() return true end
function DevTools.selftest() return { results = {}, fails = 0, passed = 0, skipped = true } end
function DevTools.report() return { fails = 0, warns = 0, results = {}, skipped = true } end

env.xNgotDevTools = DevTools
if _G ~= env then _G.xNgotDevTools = DevTools end
