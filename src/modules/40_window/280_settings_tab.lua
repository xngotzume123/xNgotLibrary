--[[ xngot-studio · src/modules/40_window/280_settings_tab.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.settings_tab
     role   : Settings tab: giao diện, theme, preset, slider, profile
     source : main 2.txt L15150-16103 · 954 dòng · delta +0
--]]
				do
					local homePlayers = game:GetService("Players")
					local homePlayer = homePlayers and homePlayers.LocalPlayer
					if homePlayer then
						local homeRunService = game:GetService("RunService")
						local homeTeleport = game:GetService("TeleportService")
						local homeMarketplace = game:GetService("MarketplaceService")
						local homeHttp = game:GetService("HttpService")
						local homeHttpGet -- dinh nghia o duoi; avatar/icon dung chung

						-- Bang mau lay thang tu theme cua cua so (UISettings) de dashboard khop UI/UX
						-- va tu doi theo preset (Default / Rose / Midnight...) thay vi mau den co dinh.
						local HOME_SURFACE = UISettings.SurfaceColor or Color3.fromRGB(32, 35, 41)
						local HOME_CARD = HOME_SURFACE:Lerp(Color3.fromRGB(255, 255, 255), 0.05)
						local HOME_CARD2 = HOME_SURFACE:Lerp(Color3.fromRGB(255, 255, 255), 0.11)
						local HOME_TEXT = UISettings.TextColor or Color3.fromRGB(243, 243, 238)
						local HOME_MUTED = UISettings.MutedTextColor or Color3.fromRGB(150, 155, 165)
						local HOME_ACCENT = UISettings.AccentColor or Color3.fromRGB(10, 135, 213)
						local HOME_STROKE = HOME_SURFACE:Lerp(HOME_TEXT, 0.22)
						local HOME_BAR = HOME_ACCENT
						local HOME_BAR2 = HOME_ACCENT:Lerp(Color3.fromRGB(255, 255, 255), 0.35)
						local HOME_RADIUS = math.clamp(tonumber(UISettings.CornerRadius) or 10, 6, 28)

						local function homeCorner(parent, radius)
							local c = Instance.new("UICorner")
							c.CornerRadius = UDim.new(0, radius or 12)
							c.Parent = parent
							return c
						end
						local function homeStroke(parent)
							local st = Instance.new("UIStroke")
							st.Color = HOME_STROKE
							st.Thickness = 1
							st.Parent = parent
							return st
						end
						local function homeLabel(parent, text, size, color, bold)
							local label = Instance.new("TextLabel")
							label.BackgroundTransparency = 1
							label.FontFace = Font.new("rbxassetid://11702779517", bold and Enum.FontWeight.Bold or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
							label.Text = tostring(text or "")
							label.TextSize = size or 13
							label.TextColor3 = color or HOME_TEXT
							label.TextTransparency = (color ~= nil and color == HOME_MUTED) and 0.3 or 0
							label.TextXAlignment = Enum.TextXAlignment.Left
							label.TextYAlignment = Enum.TextYAlignment.Center
							label.Parent = parent
							return label
						end
						local function homeFrame(parent, bg)
							local f = Instance.new("Frame")
							f.BackgroundColor3 = bg or HOME_CARD
							f.BorderSizePixel = 0
							f.Parent = parent
							return f
						end
						local function homeCard(parent, height, order)
							local card = homeFrame(parent, HOME_CARD)
							card.Size = UDim2.new(1, 0, 0, height)
							card.LayoutOrder = order or 1
							card.Name = "HomeCard"
							homeCorner(card, HOME_RADIUS + 4)
							homeStroke(card)
							return card
						end
						local function homeButton(parent, text, order)
							local b = Instance.new("TextButton")
							b.AutoButtonColor = false
							b.BackgroundColor3 = HOME_CARD2
							b.BorderSizePixel = 0
							b.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
							b.Text = tostring(text or "")
							b.TextSize = 12
							b.TextColor3 = HOME_TEXT
							b.LayoutOrder = order or 1
							b.Name = "HomeButton"
							homeCorner(b, math.max(4, HOME_RADIUS - 2))
							homeStroke(b)
							local homeBtnBg = b.BackgroundColor3
							b.MouseEnter:Connect(function() Tween(b, { BackgroundColor3 = homeBtnBg:Lerp(HOME_ACCENT, 0.22) }, TweenConfigs.Global) end)
							b.MouseLeave:Connect(function() Tween(b, { BackgroundColor3 = homeBtnBg }, TweenConfigs.Global) end)
							b.Parent = parent
							return b
						end

						local homeRoot = Instance.new("Frame")
						homeRoot.Name = "ExampleHomeDashboard"
						homeRoot.BackgroundTransparency = 1
						homeRoot.Size = UDim2.new(1, 0, 0, 0)
						homeRoot.AutomaticSize = Enum.AutomaticSize.Y
						homeRoot.LayoutOrder = -100
						homeRoot.Parent = SettingsTab._Container
						local homeRootLayout = Instance.new("UIListLayout")
						homeRootLayout.Padding = UDim.new(0, 10)
						homeRootLayout.SortOrder = Enum.SortOrder.LayoutOrder
						homeRootLayout.Parent = homeRoot
						Window.HomeDashboard = homeRoot

						-- Header: Welcome + Refresh
						local homeHeader = homeFrame(homeRoot, HOME_CARD)
						homeHeader.BackgroundTransparency = 1
						homeHeader.Size = UDim2.new(1, 0, 0, 32)
						homeHeader.LayoutOrder = 1
						local homeTitle = homeLabel(homeHeader, "Welcome to " .. tostring(Window.Title) .. "!", 19, HOME_TEXT, true)
						homeTitle.Size = UDim2.new(1, -112, 1, 0)
						homeTitle.TextTruncate = Enum.TextTruncate.AtEnd
						local homeRefreshBtn = homeButton(homeHeader, "Refresh", 1)
						homeRefreshBtn.AnchorPoint = Vector2.new(1, 0.5)
						homeRefreshBtn.Position = UDim2.new(1, 0, 0.5, 0)
						homeRefreshBtn.Size = UDim2.new(0, 100, 0, 28)

						-- The Profile / Welcome back
						local profileCard = homeCard(homeRoot, 114, 2)
						local profileText = homeFrame(profileCard, HOME_CARD)
						profileText.BackgroundTransparency = 1
						profileText.Position = UDim2.new(0, 14, 0, 10)
						profileText.Size = UDim2.new(1, -122, 1, -20)
						local welcomeLabel = homeLabel(profileText, "WELCOME BACK", 11, HOME_MUTED, true)
						welcomeLabel.Size = UDim2.new(1, 0, 0, 14)
						local playerNameLabel = homeLabel(profileText, homePlayer.DisplayName, 20, HOME_TEXT, true)
						playerNameLabel.Position = UDim2.new(0, 0, 0, 15)
						playerNameLabel.Size = UDim2.new(1, 0, 0, 26)
						playerNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
						local playerUserLabel = homeLabel(profileText, "@" .. homePlayer.Name, 13, HOME_MUTED, false)
						playerUserLabel.Position = UDim2.new(0, 0, 0, 43)
						playerUserLabel.Size = UDim2.new(1, 0, 0, 18)
						playerUserLabel.TextTruncate = Enum.TextTruncate.AtEnd
						local chipRow = homeFrame(profileText, HOME_CARD)
						chipRow.BackgroundTransparency = 1
						chipRow.Position = UDim2.new(0, 0, 0, 76)
						chipRow.Size = UDim2.new(1, 0, 0, 26)
						local chipLayout = Instance.new("UIListLayout")
						chipLayout.FillDirection = Enum.FillDirection.Horizontal
						chipLayout.Padding = UDim.new(0, 6)
						chipLayout.SortOrder = Enum.SortOrder.LayoutOrder
						chipLayout.Parent = chipRow
						local function homeChip(text, order, isButton)
							local chip = Instance.new(isButton and "TextButton" or "TextLabel")
							chip.BackgroundColor3 = HOME_CARD2
							chip.BorderSizePixel = 0
							chip.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
							chip.Text = tostring(text or "")
							chip.TextSize = 11
							chip.TextColor3 = HOME_TEXT
							chip.AutomaticSize = Enum.AutomaticSize.X
							chip.Size = UDim2.new(0, 0, 0, 24)
							chip.LayoutOrder = order or 1
							chip.Name = "HomeChip"
							if isButton then chip.AutoButtonColor = false end
							homeCorner(chip, math.max(4, HOME_RADIUS - 4))
							local cp = Instance.new("UIPadding")
							cp.PaddingLeft = UDim.new(0, 9)
							cp.PaddingRight = UDim.new(0, 9)
							cp.Parent = chip
							chip.Parent = chipRow
							return chip
						end
						local versionText = tostring(Window.Version or "")
						if #versionText > 18 then versionText = versionText:sub(1, 18) .. "..." end
						homeChip(versionText ~= "" and versionText or "Release", 1, false)
						local nameChip = homeChip("Name", 2, true)
						local avatarChip = homeChip("Avatar", 3, true)
						local homeAvatar = Instance.new("ImageLabel")
						homeAvatar.Name = "PlayerAvatar"
						homeAvatar.AnchorPoint = Vector2.new(1, 0)
						homeAvatar.Position = UDim2.new(1, -10, 0, 11)
						homeAvatar.Size = UDim2.new(0, 92, 0, 92)
						homeAvatar.BackgroundColor3 = HOME_CARD2
						homeAvatar.ScaleType = Enum.ScaleType.Fit
						homeCorner(homeAvatar, HOME_RADIUS)
						homeStroke(homeAvatar)
						homeAvatar.Parent = profileCard
						local avatarMode = "Avatar"
						local function homeAvatarUrl(mode)
							return "rbxthumb://type=" .. mode .. "&id=" .. tostring(homePlayer.UserId) .. "&w=420&h=420"
						end
						local function homeSetAvatar(mode)
							avatarMode = mode
							-- Duong 1 (chuan Roblox): GetUserThumbnailAsync tra ContentId dung ngay duoc.
							local okThumb, content = pcall(function()
								return homePlayers:GetUserThumbnailAsync(homePlayer.UserId, mode == "AvatarHeadShot" and Enum.ThumbnailType.HeadShot or Enum.ThumbnailType.Avatar, Enum.ThumbnailSize.Size420x420)
							end)
							if okThumb and type(content) == "string" and content ~= "" then
								homeAvatar.Image = content
							else
								homeAvatar.Image = homeAvatarUrl(mode)
							end
							-- Duong 2: sau 3s anh van chua tai duoc thi tai bytes tu thumbnails.roblox.com roi dung getcustomasset.
							local wantedMode = mode
							task.spawn(function()
								local deadline = os.clock() + 3
								while os.clock() < deadline and avatarMode == wantedMode and not homeAvatar.IsLoaded and homeAvatar.Parent do task.wait(0.1) end
								if avatarMode ~= wantedMode or homeAvatar.IsLoaded or not homeAvatar.Parent then return end
								if type(homeHttpGet) ~= "function" or type(writefile) ~= "function" then return end
								local customAsset = getcustomasset or getsynasset
								if type(customAsset) ~= "function" then return end
								local apiUrl = wantedMode == "AvatarHeadShot"
									and ("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. tostring(homePlayer.UserId) .. "&size=420x420&format=Png&isCircular=false")
									or ("https://thumbnails.roblox.com/v1/users/avatar?userIds=" .. tostring(homePlayer.UserId) .. "&size=420x420&format=Png&isCircular=false")
								local apiBody = homeHttpGet(apiUrl)
								local imageUrl = type(apiBody) == "string" and apiBody:match('"imageUrl"%s*:%s*"(https://[^"]+)"') or nil
								if not imageUrl then return end
								imageUrl = imageUrl:gsub("\\/", "/")
								local bytes = homeHttpGet(imageUrl)
								if type(bytes) ~= "string" or #bytes < 64 then return end
								local ext = nil
								if bytes:sub(1, 8) == "\137PNG\r\n\26\n" then ext = "png" elseif bytes:sub(1, 3) == "\255\216\255" then ext = "jpg" end
								if not ext then return end
								local path = "xNgotLibrary/Avatars/PlayerAvatar_" .. wantedMode .. "." .. ext
								if not pcall(writefile, path, bytes) then return end
								local okAsset, asset = pcall(customAsset, path)
								if okAsset and type(asset) == "string" and asset ~= "" and avatarMode == wantedMode and homeAvatar.Parent then
									homeAvatar.Image = asset
								end
							end)
						end
						homeSetAvatar(avatarMode)
						nameChip.MouseButton1Click:Connect(function()
							playerUserLabel.Visible = not playerUserLabel.Visible
						end)
						avatarChip.MouseButton1Click:Connect(function()
							homeSetAvatar(avatarMode == "Avatar" and "AvatarHeadShot" or "Avatar")
						end)

						-- The thong ke: FPS / Ping / Players / Session
						local statsCard = homeCard(homeRoot, 150, 3)
						local statsRow = homeFrame(statsCard, HOME_CARD)
						statsRow.BackgroundTransparency = 1
						statsRow.Position = UDim2.new(0, 12, 0, 10)
						statsRow.Size = UDim2.new(1, -24, 0, 80)
						local statsLayout = Instance.new("UIListLayout")
						statsLayout.FillDirection = Enum.FillDirection.Horizontal
						statsLayout.Padding = UDim.new(0, 14)
						statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
						statsLayout.Parent = statsRow
						local function homeStatCell(order, title)
							local cell = homeFrame(statsRow, HOME_CARD)
							cell.BackgroundTransparency = 1
							cell.Size = UDim2.new(0.5, -7, 1, 0)
							cell.LayoutOrder = order
							local head = homeLabel(cell, title, 11, HOME_MUTED, true)
							head.Size = UDim2.new(0.3, 0, 0, 14)
							local meta = homeLabel(cell, "", 10, HOME_MUTED, false)
							meta.AnchorPoint = Vector2.new(1, 0)
							meta.Position = UDim2.new(1, 0, 0, 0)
							meta.Size = UDim2.new(0.85, 0, 0, 14)
							meta.TextXAlignment = Enum.TextXAlignment.Right
							local value = homeLabel(cell, "--", 22, HOME_TEXT, true)
							value.Position = UDim2.new(0, 0, 0, 15)
							value.Size = UDim2.new(1, 0, 0, 28)
							local graph = homeFrame(cell, HOME_CARD)
							graph.BackgroundTransparency = 1
							graph.Position = UDim2.new(0, 0, 1, -32)
							graph.Size = UDim2.new(1, 0, 0, 32)
							graph.ClipsDescendants = true
							local bars = {}
							for i = 1, 24 do
								local bar = homeFrame(graph, HOME_BAR)
								bar.AnchorPoint = Vector2.new(0, 1)
								bar.Position = UDim2.new((i - 1) / 24, 1, 1, 0)
								bar.Size = UDim2.new(1 / 24, -2, 0, 5)
								bar.Name = "HomeBar"
								bar.BackgroundTransparency = 0.85
								bars[i] = bar
							end
							return value, meta, bars
						end
						local fpsValue, fpsMeta, fpsBars = homeStatCell(1, "FPS")
						local pingValue, pingMeta, pingBars = homeStatCell(2, "Ping")
						for _, bar in ipairs(pingBars) do bar.BackgroundColor3 = HOME_BAR2; bar.Name = "HomeBarPing" end
						local statsRow2 = homeFrame(statsCard, HOME_CARD)
						statsRow2.BackgroundTransparency = 1
						statsRow2.Position = UDim2.new(0, 12, 1, -46)
						statsRow2.Size = UDim2.new(1, -24, 0, 38)
						local statsLayout2 = Instance.new("UIListLayout")
						statsLayout2.FillDirection = Enum.FillDirection.Horizontal
						statsLayout2.Padding = UDim.new(0, 14)
						statsLayout2.SortOrder = Enum.SortOrder.LayoutOrder
						statsLayout2.Parent = statsRow2
						local function homeInfoCell(order)
							local cell = homeFrame(statsRow2, HOME_CARD)
							cell.BackgroundTransparency = 1
							cell.Size = UDim2.new(0.5, -7, 1, 0)
							cell.LayoutOrder = order
							local value = homeLabel(cell, "--", 15, HOME_TEXT, true)
							value.Size = UDim2.new(1, 0, 0, 19)
							local caption = homeLabel(cell, "", 11, HOME_MUTED, false)
							caption.Position = UDim2.new(0, 0, 0, 20)
							caption.Size = UDim2.new(1, 0, 0, 15)
							return value, caption
						end
						local playersValue, playersCaption = homeInfoCell(1)
						playersCaption.Text = "Players"
						local sessionValue, sessionCaption = homeInfoCell(2)
						sessionCaption.Text = "Session"

						-- The game dang choi + server buttons
						local gameCard = homeCard(homeRoot, 128, 4)
						local gameIcon = Instance.new("ImageLabel")
						gameIcon.Name = "GameIcon"
						gameIcon.Position = UDim2.new(0, 14, 0, 14)
						gameIcon.Size = UDim2.new(0, 44, 0, 44)
						gameIcon.BackgroundColor3 = HOME_CARD2
						gameIcon.ScaleType = Enum.ScaleType.Crop
						gameIcon.Image = ""
						homeCorner(gameIcon, math.max(4, HOME_RADIUS - 2))
						gameIcon.Parent = gameCard
						local gameNameLabel = homeLabel(gameCard, "Loading game info...", 14, HOME_TEXT, true)
						gameNameLabel.Position = UDim2.new(0, 68, 0, 15)
						gameNameLabel.Size = UDim2.new(1, -82, 0, 20)
						gameNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
						local gameMetaLabel = homeLabel(gameCard, "", 11, HOME_MUTED, false)
						gameMetaLabel.Position = UDim2.new(0, 68, 0, 37)
						gameMetaLabel.Size = UDim2.new(1, -82, 0, 16)
						gameMetaLabel.TextTruncate = Enum.TextTruncate.AtEnd
						local serverRow = homeFrame(gameCard, HOME_CARD)
						serverRow.BackgroundTransparency = 1
						serverRow.Position = UDim2.new(0, 12, 0, 62)
						serverRow.Size = UDim2.new(1, -24, 0, 36)
						local serverLayout = Instance.new("UIListLayout")
						serverLayout.FillDirection = Enum.FillDirection.Horizontal
						serverLayout.Padding = UDim.new(0, 8)
						serverLayout.SortOrder = Enum.SortOrder.LayoutOrder
						serverLayout.Parent = serverRow
						local rejoinBtn = homeButton(serverRow, "Rejoin", 1)
						local hopBtn = homeButton(serverRow, "Hop", 2)
						local lowestBtn = homeButton(serverRow, "Lowest", 3)
						local jobBtn = homeButton(serverRow, "Job ID", 4)
						for _, b in ipairs({ rejoinBtn, hopBtn, lowestBtn, jobBtn }) do b.Size = UDim2.new(0.25, -6, 1, 0) end
						local jobText = game.JobId ~= "" and (game.JobId:sub(1, 8) .. "..." .. game.JobId:sub(-4)) or "--"
						local jobLabel = homeLabel(gameCard, "Job " .. jobText .. "  ·  Place " .. tostring(game.PlaceId), 10, HOME_MUTED, false)
						jobLabel.Position = UDim2.new(0, 12, 0, 106)
						jobLabel.Size = UDim2.new(1, -28, 0, 14)
						jobLabel.TextTruncate = Enum.TextTruncate.AtEnd

						local homeCreator = ""
						local function homeLoadGameInfo()
							task.spawn(function()
								local ok, info = pcall(function() return homeMarketplace:GetProductInfo(game.PlaceId) end)
								if ok and type(info) == "table" and homeRoot.Parent then
									if type(info.Name) == "string" and info.Name ~= "" then gameNameLabel.Text = info.Name end
									if type(info.Creator) == "table" and info.Creator.Name then homeCreator = tostring(info.Creator.Name) end
									gameMetaLabel.Text = (homeCreator ~= "" and ("by " .. homeCreator .. "  ·  ") or "") .. tostring(#homePlayers:GetPlayers()) .. "/" .. tostring(homePlayers.MaxPlayers) .. " players"
								end
							if gameNameLabel.Text == "Loading game info..." then gameNameLabel.Text = "Place " .. tostring(game.PlaceId) end
							end)
						end

						homeHttpGet = function(url)
							local reqFn = nil
							if type(request) == "function" then reqFn = request
							elseif type(http_request) == "function" then reqFn = http_request
							elseif type(syn_request) == "function" then reqFn = syn_request
							elseif type(syn) == "table" and type(syn.request) == "function" then reqFn = syn.request
							elseif type(http) == "table" and type(http.request) == "function" then reqFn = http.request
							elseif type(fluxus) == "table" and type(fluxus.request) == "function" then reqFn = fluxus.request end
							if reqFn then
								local ok, res = pcall(reqFn, { Url = url, Method = "GET", Headers = { ["Accept"] = "application/json" } })
								if ok and type(res) == "table" and type(res.Body) == "string" and #res.Body > 2 then return res.Body end
							end
							local ok, body = pcall(function() return game:HttpGet(url) end)
							if ok and type(body) == "string" and #body > 2 then return body end
							local ok2, body2 = pcall(function() return homeHttp:GetAsync(url) end)
							if ok2 and type(body2) == "string" and #body2 > 2 then return body2 end
							return nil
						end

						local function homeLoadGameIcon()
							task.spawn(function()
								-- Cach 1: rbxthumb GameIcon can UniverseId (khong phai PlaceId nhu ban truoc).
								local universeId = nil
								local universeBody = homeHttpGet("https://apis.roblox.com/universes/v1/places/" .. tostring(game.PlaceId) .. "/universe")
								if type(universeBody) == "string" then
									local okDec, decoded = pcall(function() return homeHttp:JSONDecode(universeBody) end)
									if okDec and type(decoded) == "table" and decoded.universeId then universeId = decoded.universeId end
								end
								if universeId and gameIcon.Parent then
									gameIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(universeId) .. "&w=150&h=150"
									local deadline = os.clock() + 3
									while os.clock() < deadline and not gameIcon.IsLoaded and gameIcon.Parent do task.wait(0.1) end
									if gameIcon.IsLoaded then return end
								end
								-- Cach 2: tai anh thumbnail that ve file roi dung getcustomasset (giong anh bia nhac).
								if type(writefile) ~= "function" then return end
								local customAsset = getcustomasset or getsynasset
								if type(customAsset) ~= "function" then return end
								local apiBody = homeHttpGet("https://thumbnails.roblox.com/v1/places/gameicons?placeIds=" .. tostring(game.PlaceId) .. "&size=150x150&format=Png&isCircular=false")
								local imageUrl = type(apiBody) == "string" and apiBody:match('"imageUrl"%s*:%s*"(https://[^"]+)"') or nil
								if not imageUrl then return end
								imageUrl = imageUrl:gsub("\\/", "/")
								local bytes = homeHttpGet(imageUrl)
								if type(bytes) ~= "string" or #bytes < 64 then return end
								local ext = nil
								if bytes:sub(1, 8) == "\137PNG\r\n\26\n" then ext = "png" elseif bytes:sub(1, 3) == "\255\216\255" then ext = "jpg" end
								if not ext then return end
								local path = "xNgotLibrary/Avatars/GameIcon_" .. tostring(game.PlaceId) .. "." .. ext
								if not pcall(writefile, path, bytes) then return end
								local okAsset, asset = pcall(customAsset, path)
								if okAsset and type(asset) == "string" and asset ~= "" and gameIcon.Parent then gameIcon.Image = asset end
							end)
						end
						homeLoadGameIcon()
						local function homeHop(lowest)
							LIB:Notify({ Title = "Home", Content = lowest and "Finding the lowest-ping server..." or "Finding another server...", Duration = 3 })
							task.spawn(function()
								local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Desc&limit=100"
								local body = homeHttpGet(url)
								local servers = nil
								if body then
									local okDecode, decoded = pcall(function() return homeHttp:JSONDecode(body) end)
									if okDecode and type(decoded) == "table" and type(decoded.data) == "table" then servers = decoded.data end
								end
								if not servers then
									LIB:Notify({ Title = "Home", Content = "Could not load the server list in this executor.", Icon = "triangle-alert", Duration = 4 })
									return
								end
								local candidates = {}
								for _, entry in ipairs(servers) do
									if type(entry) == "table" and type(entry.id) == "string" and entry.id ~= game.JobId then
										local playing = tonumber(entry.playing) or 0
										local maxPlayers = tonumber(entry.maxPlayers) or homePlayers.MaxPlayers
										if playing < maxPlayers then candidates[#candidates + 1] = entry end
									end
								end
								if #candidates == 0 then
									LIB:Notify({ Title = "Home", Content = "No other server with free slots was found.", Icon = "triangle-alert", Duration = 4 })
									return
								end
								local chosen
								if lowest then
									table.sort(candidates, function(x, y) return (tonumber(x.ping) or 9999) < (tonumber(y.ping) or 9999) end)
									chosen = candidates[1]
								else
									chosen = candidates[math.random(1, #candidates)]
								end
								local okTp, errTp = pcall(function() homeTeleport:TeleportToPlaceInstance(game.PlaceId, chosen.id, homePlayer) end)
								if not okTp then LIB:Notify({ Title = "Home", Content = "Teleport failed: " .. tostring(errTp), Icon = "triangle-alert", Duration = 4 }) end
							end)
						end

						rejoinBtn.MouseButton1Click:Connect(function()
							local okTp, errTp = pcall(function() homeTeleport:Teleport(game.PlaceId, homePlayer) end)
							if not okTp then LIB:Notify({ Title = "Home", Content = "Rejoin failed: " .. tostring(errTp), Icon = "triangle-alert", Duration = 4 }) end
						end)
						hopBtn.MouseButton1Click:Connect(function() homeHop(false) end)
						lowestBtn.MouseButton1Click:Connect(function() homeHop(true) end)
						jobBtn.MouseButton1Click:Connect(function()
							if game.JobId == "" then
								LIB:Notify({ Title = "Home", Content = "This session has no Job ID.", Icon = "triangle-alert", Duration = 3 })
							elseif CopyText(game.JobId) then
								LIB:Notify({ Title = "Home", Content = "Job ID copied.", Icon = "copy", Duration = 2.5 })
							end
						end)

						-- Ap lai bang mau tu UISettings (goi khi Refresh hoac khi theme/preset thay doi)
						local function homeRecolor()
							HOME_SURFACE = UISettings.SurfaceColor or HOME_SURFACE
							HOME_CARD = HOME_SURFACE:Lerp(Color3.fromRGB(255, 255, 255), 0.05)
							HOME_CARD2 = HOME_SURFACE:Lerp(Color3.fromRGB(255, 255, 255), 0.11)
							HOME_TEXT = UISettings.TextColor or HOME_TEXT
							HOME_MUTED = UISettings.MutedTextColor or HOME_MUTED
							HOME_ACCENT = UISettings.AccentColor or HOME_ACCENT
							HOME_STROKE = HOME_SURFACE:Lerp(HOME_TEXT, 0.22)
							HOME_BAR = HOME_ACCENT
							HOME_BAR2 = HOME_ACCENT:Lerp(Color3.fromRGB(255, 255, 255), 0.35)
							for _, obj in ipairs(homeRoot:GetDescendants()) do
								if obj:IsA("UIStroke") then
									obj.Color = HOME_STROKE
								elseif obj.Name == "HomeCard" then
									obj.BackgroundColor3 = HOME_CARD
								elseif obj.Name == "HomeButton" or obj.Name == "HomeChip" then
									obj.BackgroundColor3 = HOME_CARD2
									obj.TextColor3 = HOME_TEXT
								elseif obj.Name == "HomeBar" then
									obj.BackgroundColor3 = HOME_BAR
								elseif obj.Name == "HomeBarPing" then
									obj.BackgroundColor3 = HOME_BAR2
								elseif obj.Name == "PlayerAvatar" or obj.Name == "GameIcon" then
									obj.BackgroundColor3 = HOME_CARD2
								elseif obj:IsA("TextLabel") then
									obj.TextColor3 = (obj.TextTransparency or 0) >= 0.28 and HOME_MUTED or HOME_TEXT
								end
							end
						end
						-- Cap nhat FPS / Ping / Players / Session theo thoi gian that
						local homeSessionStart = os.time()
						local fpsSamples, pingSamples = {}, {}
						local homeFrames = 0
						local homeRsConn = homeRunService.RenderStepped:Connect(function() homeFrames += 1 end)
						local function homeStats(samples)
							local minV, maxV, sum = math.huge, 0, 0
							for _, v in ipairs(samples) do
								if v < minV then minV = v end
								if v > maxV then maxV = v end
								sum += v
							end
							if #samples == 0 then minV = 0 end
							return samples[#samples] or 0, minV, (#samples > 0 and math.floor(sum / #samples + 0.5) or 0), maxV
						end
						local function homeBars(bars, samples)
							local maxV = 1
							for _, v in ipairs(samples) do if v > maxV then maxV = v end end
							local scale = maxV * 1.2
							for i, bar in ipairs(bars) do
								local idx = #samples - (#bars - i)
								local v = idx >= 1 and samples[idx] or 0
								bar.Size = UDim2.new(1 / #bars, -2, 0, math.clamp(4 + (v / scale) * 24, 4, 28))
								bar.BackgroundTransparency = v > 0 and 0.05 or 0.85
							end
						end
						local function homePing()
							local ok, value = pcall(function() return homePlayer:GetNetworkPing() end)
							if ok and type(value) == "number" then return math.floor(value * 1000 + 0.5) end
							local ok2, value2 = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
							if ok2 and type(value2) == "number" then return math.floor(value2 + 0.5) end
							return 0
						end
						local function homeSessionText()
							local elapsed = math.max(os.time() - homeSessionStart, 0)
							if elapsed < 60 then return tostring(elapsed) .. "s" end
							if elapsed < 3600 then return string.format("%dm %02ds", math.floor(elapsed / 60), elapsed % 60) end
							return string.format("%dh %02dm", math.floor(elapsed / 3600), math.floor(elapsed % 3600 / 60))
						end
						homeRefreshBtn.MouseButton1Click:Connect(function()
							fpsSamples, pingSamples = {}, {}
							homeRecolor()
							homeLoadGameInfo()
							homeLoadGameIcon()
						end)
						Window.RefreshHomeDashboard = function()
							fpsSamples, pingSamples = {}, {}
							homeRecolor()
							homeLoadGameInfo()
							homeLoadGameIcon()
						end
						homeLoadGameInfo()
						task.spawn(function()
							local lastSample = os.clock()
							while not windowDestroyed and not themeDestroyed and homeRoot.Parent do
								task.wait(0.5)
								if windowDestroyed or themeDestroyed or not homeRoot.Parent then break end
								local now = os.clock()
								local elapsed = math.max(now - lastSample, 0.001)
								local fps = math.floor(homeFrames / elapsed + 0.5)
								homeFrames = 0
								lastSample = now
								fpsSamples[#fpsSamples + 1] = fps
								if #fpsSamples > 24 then table.remove(fpsSamples, 1) end
								pingSamples[#pingSamples + 1] = homePing()
								if #pingSamples > 24 then table.remove(pingSamples, 1) end
								local fpsNow, fpsMin, fpsAvg, fpsMax = homeStats(fpsSamples)
								fpsValue.Text = tostring(fpsNow) .. " fps"
								fpsMeta.Text = string.format("min %d  avg %d  max %d", fpsMin, fpsAvg, fpsMax)
								homeBars(fpsBars, fpsSamples)
								local pingNow, pingMin, pingAvg, pingMax = homeStats(pingSamples)
								pingValue.Text = tostring(pingNow) .. " ms"
								pingMeta.Text = string.format("min %d  avg %d  max %d", pingMin, pingAvg, pingMax)
								homeBars(pingBars, pingSamples)
								playersValue.Text = tostring(#homePlayers:GetPlayers()) .. "/" .. tostring(homePlayers.MaxPlayers)
						gameMetaLabel.Text = (homeCreator ~= "" and ("by " .. homeCreator .. "  ·  ") or "") .. tostring(#homePlayers:GetPlayers()) .. "/" .. tostring(homePlayers.MaxPlayers) .. " players"
								sessionValue.Text = homeSessionText()
						if UISettings.SurfaceColor ~= HOME_SURFACE or UISettings.AccentColor ~= HOME_ACCENT or UISettings.TextColor ~= HOME_TEXT then homeRecolor() end
							end
							if homeRsConn then homeRsConn:Disconnect() end
						end)
					end
				end

				if type(Window.AdminInfo) == "table" then
					local admin = Window.AdminInfo
					SettingsTab:Paragraph({
						Title = "Administrator",
						Desc = "xNgọt Studio · Developer information",
					})
					local adminCard = SettingsTab:InfoNguyenNhat({
						Avatar = tostring(admin.Avatar or "rbxassetid://0"),
						Name = tostring(admin.Name or "Nguyễn Minh Nhật"),
						Badges = type(admin.Badges) == "table" and admin.Badges or { "Owner", "Developer" },
						Bio = tostring(admin.Bio or ""),
					})
					Window.AdminInfoCard = adminCard

					local avatarURL = admin.AvatarURL
					Window.AdminAvatarURL = avatarURL
					local avatarManifest = "xNgotLibrary/Avatars/AdminAvatarCache.txt"
					local avatarLegacyPath = "xNgotStudio_AdminAvatar.png"
					local avatarRefreshSerial = 0
					local avatarHttpService = game:GetService("HttpService")

					-- EMBEDDED-AVATAR: snapshot avatar GitHub cua admin (JPEG 256px, base64) nhung san trong file.
					-- Dung lam du phong tuyet doi: ke ca khi executor chan moi duong tai mang thi avatar van hien,
					-- khong bao gio roi vao placeholder "xN". Tai duoc ban moi tu GitHub thi tu thay the sau.
					local ADMIN_AVATAR_EMBEDDED_B64 = [[
/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAUDBAQEAwUEBAQFBQUGBwwIBwcHBw8LCwkMEQ8SEhEPERETFhwXExQaFRERGCEYGh0dHx8fExciJCIeJBweHx7/
2wBDAQUFBQcGBw4ICA4eFBEUHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh7/wAARCAEAAQADASIAAhEBAxEB/8QA
HwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkK
FhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXG
x8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAEC
AxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOE
hYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDWJGccDjrS
kEjP86gU5HIHHHWpo2bbzXCn0PSaIBu6c1InTB70p+Unkc0m4Y6c9qGhDgMMD0zTmxjHrTM7gCDT85ANIaIADnA6U5FAOW4HrTyh6ipQNyYoS1NOYQAAY+nN
C53HIpdpCjn8aD7UMSdwbgZ9qReDmnAdiaXAApFjxjIpQw2nFJ/D6UzaeRQx2Jl9afngUyPhcdqcAWHpSAcFB5FSLwabF0705+mfWkMlUhs4PSpE6ZqBDtU1
KpOKCh+Dn60pP97oOlIGyKMn170tgFI4FIuQ3tQSSPxqZF4GapEsc3A49KrXAJxn61cGM9KrTZ3jPpUvczb0GKc1JGvJ4piD86kUkVqjNksdTxA5HpUEZ3dq
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
Zcn8654+9HUdOKd7CTsf/9k=

					]]
					local B64_REV = {}
					do
						local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
						for i = 1, #chars do B64_REV[chars:sub(i, i)] = i - 1 end
					end
					local function avatarB64Decode(data)
						data = tostring(data or ""):gsub("[^A-Za-z0-9%+%/%=]", "")
						local out = {}
						for i = 1, #data, 4 do
							local ca, cb, cc, cd = data:sub(i, i), data:sub(i + 1, i + 1), data:sub(i + 2, i + 2), data:sub(i + 3, i + 3)
							local va, vb = B64_REV[ca] or 0, B64_REV[cb] or 0
							local vc = (cc ~= "=" and cc ~= "") and (B64_REV[cc] or 0) or 0
							local vd = (cd ~= "=" and cd ~= "") and (B64_REV[cd] or 0) or 0
							local n = va * 262144 + vb * 4096 + vc * 64 + vd
							out[#out + 1] = string.char(math.floor(n / 65536) % 256)
							if cc ~= "=" and cc ~= "" then out[#out + 1] = string.char(math.floor(n / 256) % 256) end
							if cd ~= "=" and cd ~= "" then out[#out + 1] = string.char(n % 256) end
						end
						return table.concat(out)
					end
					local function avatarEmbeddedAsset(customAsset)
						if type(writefile) ~= "function" or type(customAsset) ~= "function" then return nil, "writefile/getcustomasset unavailable" end
						local ok, bytes = pcall(avatarB64Decode, ADMIN_AVATAR_EMBEDDED_B64)
						if not ok or type(bytes) ~= "string" or #bytes < 64 then return nil, "embedded decode failed" end
						if bytes:sub(1, 3) ~= "\255\216\255" then return nil, "embedded bytes invalid" end
						local path = "xNgotLibrary/Avatars/AdminAvatar_embed.jpg"
						if not pcall(writefile, path, bytes) then return nil, "writefile embedded failed" end
						local okAsset, asset = pcall(customAsset, path)
						if okAsset and type(asset) == "string" and asset ~= "" then return asset, path end
						return nil, "getcustomasset embedded failed"
					end

					local function deleteAvatarFile(path)
						if type(delfile) ~= "function" or type(path) ~= "string" then return end
						local allowed = path == avatarLegacyPath
							or path:match("^xNgotStudio_AdminAvatar_[%w]+%.png$")
							or path:match("^xNgotStudio_AdminAvatar_[%w]+%.jpg$")
							or path:match("^xNgotStudio_AdminAvatar_[%w]+%.webp$")
							or path:match("^xNgotLibrary/Avatars/AdminAvatar_[%w]+%.png$")
							or path:match("^xNgotLibrary/Avatars/AdminAvatar_[%w]+%.jpg$")
							or path:match("^xNgotLibrary/Avatars/AdminAvatar_[%w]+%.webp$")
						if not allowed then return end
						local exists = true
						if type(isfile) == "function" then
							local ok, result = pcall(isfile, path)
							if ok then exists = result == true end
						end
						if exists then pcall(delfile, path) end
					end

					-- AVATAR-FIX: bo tai avatar (nhieu duong tai + tu thu lai + dung cache cu truoc).
					local function avatarFetchRaw(url)
						-- Duong 1: request cua executor (theo duoc redirect 302 cua GitHub, tra Headers/Body day du).
						local reqFn = nil
						if type(request) == "function" then reqFn = request
						elseif type(http_request) == "function" then reqFn = http_request
						elseif type(syn_request) == "function" then reqFn = syn_request
						elseif type(syn) == "table" and type(syn.request) == "function" then reqFn = syn.request
						elseif type(http) == "table" and type(http.request) == "function" then reqFn = http.request
						elseif type(fluxus) == "table" and type(fluxus.request) == "function" then reqFn = fluxus.request end
						if reqFn then
							local current = url
							for _ = 1, 4 do
								local ok, res = pcall(reqFn, {
									Url = current, Method = "GET",
									Headers = { ["Accept"] = "image/*,*/*", ["User-Agent"] = "Mozilla/5.0 (xNgotStudio)" },
								})
								if not ok or type(res) ~= "table" then break end
								local status = tonumber(res.StatusCode or res.Status or res.status_code or res.status or 0) or 0
								local body = res.Body or res.body
								if status >= 300 and status < 400 then
									local location = nil
									for key, value in pairs(type(res.Headers) == "table" and res.Headers or {}) do
										if tostring(key):lower() == "location" then location = tostring(value) end
									end
									if location and location ~= "" then current = location else break end
								elseif type(body) == "string" and #body > 0 and (status == 200 or status == 0) then
									return body
								else break end
							end
						end
						-- Duong 2 + 3: game:HttpGet / HttpService:GetAsync.
						local ok, data = pcall(function() return game:HttpGet(url) end)
						if ok and type(data) == "string" and #data > 0 then return data end
						local okN, dataN = pcall(function() return game:HttpGet(url, true) end)
						if okN and type(dataN) == "string" and #dataN > 0 then return dataN end
						local ok2, data2 = pcall(function() return avatarHttpService:GetAsync(url) end)
						if ok2 and type(data2) == "string" and #data2 > 0 then return data2 end
						return nil
					end

					local function avatarDownloadBytes(url)
						local nonce = avatarHttpService:GenerateGUID(false):gsub("%-", "")
						local separator = url:find("?", 1, true) and "&" or "?"
						-- Chi chap nhan body dung la anh (PNG/JPG/WEBP); trang HTML loi/redirect khong duoc tinh.
						local function isImage(body)
							if type(body) ~= "string" or #body < 64 then return false end
							return body:sub(1, 8) == "\137PNG\r\n\26\n"
								or body:sub(1, 3) == "\255\216\255"
								or (body:sub(1, 4) == "RIFF" and body:sub(9, 12) == "WEBP")
						end
						local candidates = {}
						candidates[#candidates + 1] = url .. separator .. "xngot_refresh=" .. nonce
						candidates[#candidates + 1] = url
						-- github.com/<user>.png redirect 302 sang avatars.githubusercontent.com;
						-- hoi GitHub API lay avatar_url truc tiep neu cac duong tren khong qua duoc redirect.
						local user = url:match("^https://github%.com/([%w%-]+)%.png")
						local directUrl = nil
						if user then
							local apiBody = avatarFetchRaw("https://api.github.com/users/" .. user)
							if type(apiBody) == "string" then
								directUrl = apiBody:match('"avatar_url"%s*:%s*"(https://[^"]+)"')
								if directUrl then
									directUrl = directUrl:gsub("\\/", "/")
									candidates[#candidates + 1] = directUrl
								end
							end
						end
						-- Du phong cuoi: proxy anh weserv tra ve anh truc tiep (HTTP 200, khong redirect)
						-- cho cac executor khong theo duoc redirect cua GitHub.
						if user then candidates[#candidates + 1] = "https://images.weserv.nl/?url=github.com/" .. user .. ".png" end
						if directUrl then candidates[#candidates + 1] = "https://images.weserv.nl/?url=" .. directUrl:gsub("^https://", "") end
						for _, candidate in ipairs(candidates) do
							local body = avatarFetchRaw(candidate)
							if isImage(body) then return body end
						end
						return nil
					end
					function Window:RefreshAdminAvatar()
						if self.AdminInfoCard ~= adminCard then return false end
						avatarURL = Window.AdminAvatarURL or avatarURL
						if type(avatarURL) ~= "string" or not avatarURL:match("^https://") then return false end
						local customAsset = getcustomasset or getsynasset
						if type(customAsset) ~= "function" then return false end
						avatarRefreshSerial = avatarRefreshSerial + 1
						local currentSerial = avatarRefreshSerial
						task.spawn(function()
							-- Buoc 1: co avatar cache tu lan chay truoc thi AP DUNG NGAY (khong cho mang).
							local cachedPath = nil
							if type(readfile) == "function" then
								local ok, previous = pcall(readfile, avatarManifest)
								if ok and type(previous) == "string" then cachedPath = previous:gsub("%s+$", ""):gsub("^%s+", "") end
							end
							local cachedApplied = false
							local function keepAvatarApplied(asset) -- ap lai vai lan: cua so con an (man hinh key) anh van len
								task.spawn(function()
									for _, delayTime in ipairs({ 4, 5, 6 }) do
										task.wait(delayTime)
										if currentSerial ~= avatarRefreshSerial or self.AdminInfoCard ~= adminCard then return end
										pcall(adminCard.SetAvatar, adminCard, asset)
									end
								end)
							end
							for _, candidate in ipairs({ cachedPath, avatarLegacyPath }) do
								if not cachedApplied and type(candidate) == "string" and candidate ~= ""
									and (type(isfile) ~= "function" or isfile(candidate)) then
									local okAsset, asset = pcall(customAsset, candidate)
									if okAsset and type(asset) == "string" and asset ~= "" then
										pcall(adminCard.SetAvatar, adminCard, asset)
										cachedApplied = true
										cachedPath = candidate
										keepAvatarApplied(asset)
									end
								end
							end
							-- Buoc 1.5: chua co cache thi dung ngay avatar nhung san trong file -> khong bao gio thay "xN"
							-- trong luc cho tai ban moi tu GitHub (ke ca khi executor chan mang hoan toan).
							if not cachedApplied then
								local embeddedAsset, embeddedPath = avatarEmbeddedAsset(customAsset)
								if embeddedAsset then
									pcall(adminCard.SetAvatar, adminCard, embeddedAsset)
									cachedApplied = true
									cachedPath = embeddedPath
									pcall(writefile, avatarManifest, embeddedPath)
									keepAvatarApplied(embeddedAsset)
								end
								if not embeddedAsset then warn("[xNgotStudio] Admin avatar: embedded fallback failed - " .. tostring(embeddedPath)) end
							end
							if type(writefile) ~= "function" then return end
							-- Buoc 2: tai avatar moi, tu thu lai toi da 4 lan (cho 1.5s / 3s / 4.5s).
							local lastError = "khong tai duoc avatar"
							for attempt = 1, 4 do
								if currentSerial ~= avatarRefreshSerial or self.AdminInfoCard ~= adminCard then return end
								local ok, result = pcall(function()
									local response = avatarDownloadBytes(avatarURL)
									if type(response) ~= "string" or #response < 64 then
										error("Avatar response is empty or too short")
									end
									local ext
									if response:sub(1, 8) == "\137PNG\r\n\26\n" then ext = "png"
									elseif response:sub(1, 3) == "\255\216\255" then ext = "jpg"
									elseif response:sub(1, 4) == "RIFF" and response:sub(9, 12) == "WEBP" then ext = "webp"
									else error("Avatar URL did not return a supported image") end
									local nonce = avatarHttpService:GenerateGUID(false):gsub("%-", "")
									local path = "xNgotLibrary/Avatars/AdminAvatar_" .. nonce .. "." .. ext
									if not pcall(writefile, path, response) then error("writefile avatar failed") end
									local asset = customAsset(path)
									if type(asset) ~= "string" or asset == "" then error("Local avatar asset is unavailable") end
									-- AVATAR-FIX: dung NGUYEN asset getcustomasset tra ve.
									-- Ban cu cong them "?xngotv=<hash>" lam ContentId hong -> o avatar den tron du da co asset.
									return { Asset = asset, Path = path }
								end)
								if ok and currentSerial == avatarRefreshSerial and self.AdminInfoCard == adminCard then
									pcall(adminCard.SetAvatar, adminCard, result.Asset)
									keepAvatarApplied(result.Asset)
									pcall(writefile, avatarManifest, result.Path)
									if cachedPath and cachedPath ~= result.Path then deleteAvatarFile(cachedPath) end
									if avatarLegacyPath ~= result.Path then deleteAvatarFile(avatarLegacyPath) end
									return
								elseif not ok then
									lastError = tostring(result)
								end
								if attempt < 4 then task.wait(attempt * 1.5) end
							end
							warn("[xNgotStudio] Admin avatar auto-load failed (da thu lai 4 lan): " .. lastError .. (cachedApplied and " - dang dung avatar cache/nhung san" or ""))
						end)
						return true
					end

					-- AVATAR: chi tu dong tai ve va ap dung khi load (khong con Paragraph + nut "Ap dung avatar ngay" thu cong trong Settings).
					Window:RefreshAdminAvatar()
				end

				SettingsTab:Paragraph({
					Title = "UI / UX Customization",
					Desc = "Customize only what you choose. The original NgotStudio layout, cards, spacing and controls stay unchanged.",
				})

				-- UI language: English only (da go tinh nang doi ngon ngu). Cross AI van hieu Anh + Viet theo cau hoi.
