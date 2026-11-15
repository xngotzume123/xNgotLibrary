--[[ xngot-studio · src/modules/40_window/010_open.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.open
     role   : local Windows + LIB:CreateWindow + opts mặc định + dọn bản UI cũ
     source : main 2.txt L11081-11152 · 72 dòng · delta +1
--]]
		local Windows = {}
		local WindowByTitle = {}
		 
		 
		local OwnerToken = {}

		 
		 
		 
		 
		local function WindowIsOurs(win)
			return type(win) == "table" and win.__NgotOwner == OwnerToken
		end

		local function CleanupOtherInstances()
			pcall(function()
				local prev = _G.xNgotStudio
				if type(prev) == "table" and not WindowIsOurs(prev.Window) then
					if type(prev.Window) == "table" and type(prev.Window.Destroy) == "function" then
						pcall(function() prev.Window:Destroy() end)
					end
				end
				local prevWindow = _G.__xNgotActiveWindow
				if type(prevWindow) == "table" and type(prevWindow.Destroy) == "function" then
					pcall(function() prevWindow:Destroy() end)
				end
			end)
			local parents = {}
			pcall(function() if gethui then parents[#parents + 1] = gethui() end end)
			pcall(function() parents[#parents + 1] = game:GetService("CoreGui") end)
			pcall(function()
				local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
				if pg then parents[#parents + 1] = pg end
			end)
			for _, parent in ipairs(parents) do
				pcall(function()
					for _, child in ipairs(parent:GetChildren()) do
						if child ~= Gui and child:IsA("ScreenGui") then
							local foreign = child:GetAttribute("xNgotStudioOwned") == true
								or (child:FindFirstChild("NotificationList") ~= nil and child:FindFirstChild("3e") ~= nil)
								or tostring(child.Name) == "NgotStudio"
								or tostring(child.Name):find("xNgotStudio_Full", 1, true) ~= nil
							if not foreign and child:FindFirstChild("NotificationList") then
								for _, sub in ipairs(child:GetChildren()) do
									if sub:IsA("Folder") then
										for _, win in ipairs(sub:GetChildren()) do
											if win:FindFirstChild("TopFrame") and win:FindFirstChild("TabButtons") then
												foreign = true
												break
											end
										end
									end
									if foreign then break end
								end
							end
							if foreign then child:Destroy() end
						end
					end
				end)
			end
		end

		function LIB:CreateWindow(data)
			data = data or {}
			CleanupOtherInstances()
			 
			 
			local titleKey = tostring(data.Title or "NgotStudio")
			local previousWindow = WindowByTitle[titleKey]
			if previousWindow and type(previousWindow.Destroy) == "function" then
				pcall(function() previousWindow:Destroy() end)
			end
			WindowByTitle[titleKey] = nil
			local Window = {
				__NgotOwner = OwnerToken,
				Title = data.Title or "NgotStudio",
				Icon = data.Icon or "layout-dashboard",
				Version = data.Author or data.Version or "v1.0",
				Folder = data.Folder,
				Size = data.Size or UDim2.fromOffset(580, 420),
				ToggleKey = data.ToggleKey or Enum.KeyCode.RightShift,
				ToggleButtonPlatform = data.ToggleButtonPlatform or "Both",
				LiveSearchDropdown = data.LiveSearchDropdown == true,
				AutoSave = data.AutoSave ~= false,
				FileSaveName = data.FileSaveName or "NgotStudio_Config.json",
				SettingsUI = data.SettingsUI ~= false,
				SettingsTitle = tostring(data.SettingsTitle or "Settings Ui"),
				SettingsIcon = tostring(data.SettingsIcon or "settings"),
				Loading = data.Loading,
				KeySystem = data.KeySystem,
				KeyUnlocked = false,
				KeyAttempts = 0,
				AdminInfo = data.AdminInfo ~= false and (type(data.AdminInfo) == "table" and data.AdminInfo or {
					Name = "Nguyễn Minh Nhật",
					Badges = { "Owner", "Developer" },
					Bio = "Tuy Tôi Không Giỏi Mọi Thứ, Nhưng Đủ Khiến Người Khác Nể!",
					AvatarURL = "https://github.com/xngotzume123.png",
				}) or false,
			}

			local CONFIG = {}
			local CONFIGLOADED = false
			local canReadConfig = type(isfile) == "function" and type(readfile) == "function"
			local canWriteConfig = type(writefile) == "function"

			Window.ConfigPath = Window.FileSaveName
			if type(Window.Folder) == "string" and Window.Folder ~= "" then
				local folder = Window.Folder:gsub("\\", "/"):gsub("/+$", "")
				local folderReady = false
				if type(isfolder) == "function" then
					local ok, exists = pcall(isfolder, folder)
					folderReady = ok and exists == true
				end
				if not folderReady and type(makefolder) == "function" then
					local ok = pcall(makefolder, folder)
					if ok then
						if type(isfolder) == "function" then
							local checkOk, exists = pcall(isfolder, folder)
							folderReady = checkOk and exists == true
						else
							folderReady = true
						end
					end
				end
				if folderReady then
					Window.ConfigPath = folder .. "/" .. Window.FileSaveName
				else
					warn("Config Folder is unavailable in this environment; using '" .. Window.FileSaveName .. "' instead.")
				end
			end

			if canReadConfig and isfile(Window.ConfigPath) then
				local success, result = pcall(function()
					return HttpService:JSONDecode(readfile(Window.ConfigPath))
				end)
				if success and type(result) == "table" then
					CONFIG = result
					CONFIGLOADED = true
				elseif not success then
					warn("Failed to load config '" .. Window.ConfigPath .. "': " .. tostring(result))
				end
			end

