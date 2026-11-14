--[[ xngot-studio · src/modules/30_overlay/010_bootstrap.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.bootstrap
     role   : Mở hàm createIntegratedDynamicIsland + service + guard
     source : main 2.txt L2769-2809 · 41 dòng · delta +1
--]]
		local function createIntegratedDynamicIsland(__hostGui, __hostWindow)

		    local Players = game:GetService("Players")
		    local TweenService = game:GetService("TweenService")
		    local UserInputService = game:GetService("UserInputService")
		    local RunService = game:GetService("RunService")
		    local Lighting = game:GetService("Lighting")
		    local TextService = game:GetService("TextService")
		    local Stats = game:GetService("Stats")
		    local SoundService = game:GetService("SoundService")
		    local Debris = game:GetService("Debris")

		    local player = Players.LocalPlayer
		    local playerGui = player:WaitForChild("PlayerGui")
		    local camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")

		    do

		        local parents = { playerGui }
		        local okHui, hui = pcall(function() return gethui and gethui() end)
		        if okHui and hui then parents[#parents + 1] = hui end
		        local okCore, core = pcall(function() return game:GetService("CoreGui") end)
		        if okCore and core then parents[#parents + 1] = core end
		        for _, parent in ipairs(parents) do
		            pcall(function()
		                for _, child in ipairs(parent:GetChildren()) do
		                    local childName = tostring(child.Name)
		                    if childName == "xNgotStudio_FullDynamicIsland" or childName == "xNgotStudio_FullIsland" then
		                        child:Destroy()
		                    end
		                end
		            end)
		        end
		        pcall(function()
		            local existingBlur = Lighting:FindFirstChild("xNgotStudio_FullIslandBlur")
		            if existingBlur then
		                existingBlur:Destroy()
		            end
		        end)
		    end

