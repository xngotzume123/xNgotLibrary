--[[ xngot-studio · src/modules/70_boot/090_library_mode.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/70_boot · khởi động, loader, chọn nguồn thư viện
     module : boot.library_mode
     role   : LIB.Version, OpenXNgotHub, cờ xNgotLibraryOnly
     source : main 2.txt L26504-26514 · 11 dòng · delta +0
--]]

-- LIBRARY MODE (kieu Orion/Rayfield): dat getgenv().xNgotLibraryOnly = true truoc khi
-- loadstring de chi lay LIB lam UI cho hub rieng (khong tu mo hub xNgot Library).
-- Chay truc tiep file nay thi hub xNgot Library van tu mo nhu cu. Xem HUONG_DAN_LIBRARY.md.
LIB.Version = __xNgotBoot.Version
LIB.OpenXNgotHub = function() return __xNgotBoot.start() end
local __xngotEnv = (type(getgenv) == "function" and getgenv()) or _G
if __xngotEnv.xNgotLibraryOnly ~= true and not __xNgotBoot.Open then
	__xNgotBoot.Open = true
	__xNgotBoot.start()
end
