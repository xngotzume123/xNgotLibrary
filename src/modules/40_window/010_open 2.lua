--[[ xngot-studio · src/modules/40_window/010_open.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.open
     role   : local Windows + LIB:CreateWindow + opts mặc định + dọn bản UI cũ
     source : main 2.txt L11081-11152 · 72 dòng · delta +1
--]]
		local Windows = {}
		local WindowByTitle = {}
		-- Dấu nhận chủ: mỗi lần nạp thư viện sinh một table riêng, gắn vào Window
		-- để phân biệt cửa sổ của bản này với cửa sổ của bản nạp trước.
		local OwnerToken = {}

		-- XN-SINGLETON: trước khi dựng cửa sổ, dọn mọi bản UI khác của thư viện
		-- (bản cũ còn trong executor, hoặc thư viện bị nạp 2 lần) để không bao
		-- giờ tồn tại 2 bộ UI cùng lúc. Cửa sổ cũ được Destroy() trước để các
		-- connection của nó được gỡ, rồi mới quét GUI còn sót.
		local function WindowIsOurs(win)
			return type(win) == "table" and win.__NgotOwner == OwnerToken
		end

		-- Cửa sổ do chính thư viện mở lúc khởi động (hub demo). Nếu sau đó script
		-- của bạn gọi CreateWindow cho hub riêng thì đóng bản demo đi, tránh 2 UI.
		local SelfWindow = nil

		local function CleanupOtherInstances()
			pcall(function()
				local prev = _G.xNgotStudio
				if type(prev) == "table" and not WindowIsOurs(prev.Window) then
					if type(prev.Window) == "table" and type(prev.Window.Destroy) == "function" then
						pcall(function() prev.Window:Destroy() end)
					end
				end
				local prevWindow = _G.Window
				if type(prevWindow) == "table" and not WindowIsOurs(prevWindow)
					and type(prevWindow.Destroy) == "function" then
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
							local foreign = child:FindFirstChild("NotificationList") ~= nil
								or child:FindFirstChild("3e") ~= nil
								or tostring(child.Name) == "NgotStudio"
								or tostring(child.Name):find("xNgotStudio_Full", 1, true) ~= nil
							if not foreign then
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
			local isSelfWindow = data.__xNgotSelf == true
			if not isSelfWindow and SelfWindow ~= nil then
				local demo = SelfWindow
				SelfWindow = nil
				pcall(function() demo:Destroy() end)
				-- Đừng để biến toàn cục trỏ vào cửa sổ đã bị huỷ.
				pcall(function()
					local boot = _G.xNgotStudio
					if type(boot) == "table" and boot.Window == demo then boot.Window = nil end
					if _G.Window == demo then _G.Window = nil end
				end)
			end
			-- Một Title = một cửa sổ: tạo lại cùng Title thì dọn bản cũ trước khi dựng,
			-- nếu không sẽ có 2 bộ UI chồng nhau (nút nổi + cửa sổ + bảng nổi).
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

