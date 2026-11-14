--[[ xngot-studio · src/modules/60_runtime/020_create_window_guard.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/60_runtime · log, DevTools, bridge debug
     module : runtime.create_window_guard
     role   : Bọc LIB:CreateWindow bằng xpcall + LIB.ShowStartupError
     source : main 2.txt L25173-25191 · 19 dòng · delta +0
--]]
if type(LIB) == "table" and type(LIB.CreateWindow) == "function" then
    local originalCreateWindow = LIB.CreateWindow
    function LIB:CreateWindow(data)
        local ok, result = xpcall(function()
            return originalCreateWindow(self, data)
        end, function(err)
            if debug and type(debug.traceback) == "function" then
                return debug.traceback(tostring(err), 2)
            end
            return tostring(err)
        end)
        if not ok then
            __xNgotShowStartupError(result)
            error(result, 0)
        end
        return result
    end
    LIB.ShowStartupError = __xNgotShowStartupError
end
