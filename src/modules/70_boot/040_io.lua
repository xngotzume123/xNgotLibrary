--[[ xngot-studio · src/modules/70_boot/040_io.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/70_boot · khởi động, loader, chọn nguồn thư viện
     module : boot.io
     role   : bootUserGui / bootRead / bootFetch
     source : main 2.txt L26102-26130 · 29 dòng · delta +0
--]]
local function bootUserGui()
	local ok, parent = pcall(function()
		local players = game:GetService("Players")
		local user = players.LocalPlayer
		return user:FindFirstChildOfClass("PlayerGui") or user:WaitForChild("PlayerGui", 8)
	end)
	return ok and parent or nil
end

local function bootRead(path)
	if type(isfile) ~= "function" or type(readfile) ~= "function" then return nil end
	local okFile, exists = pcall(isfile, path)
	if not okFile or not exists then return nil end
	local okRead, data = pcall(readfile, path)
	if okRead and type(data) == "string" and #data > 10 then return data end
	return nil
end

local function bootFetch(url)
	local ok, data = pcall(function() return game:HttpGet(url, true) end)
	if ok and type(data) == "string" and #data > 100 then return data end
	local okSvc, svc = pcall(function() return game:GetService("HttpService") end)
	if okSvc and svc then
		ok, data = pcall(function() return svc:GetAsync(url) end)
		if ok and type(data) == "string" and #data > 100 then return data end
	end
	return nil
end

