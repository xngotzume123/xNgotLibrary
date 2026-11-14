--[[ xngot-studio · src/modules/40_window/260_destroy_gate.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.destroy_gate
     role   : Window:Destroy + cổng khoá key (KeySystem) + ForgetSavedKey
     source : main 2.txt L14598-15113 · 516 dòng · delta +0
--]]
			function Window:Destroy()
				if windowDestroyed then return end
				windowDestroyed = true
				if self.DynamicIsland then
					pcall(self.DynamicIsland.Destroy, self.DynamicIsland)
					if LIB.ActiveDynamicIsland == self.DynamicIsland then LIB.ActiveDynamicIsland = nil end
					self.DynamicIsland = nil
				end
				themeDestroyed = true
				timeout = true
				if themeDescendantConnection then themeDescendantConnection:Disconnect(); themeDescendantConnection = nil end
				if themeVisibilityConnection then themeVisibilityConnection:Disconnect(); themeVisibilityConnection = nil end
				if liquidBlur and liquidBlur.Parent then liquidBlur:Destroy() end
				if keybindConnection then keybindConnection:Disconnect(); keybindConnection = nil end
				if windowDraggable then windowDraggable:Destroy() end
				if floatingDraggable then floatingDraggable:Destroy() end
				if windowResizable then windowResizable:Destroy() end
				local index = table.find(Windows, newWindow)
				if index then table.remove(Windows, index) end
				if WindowByTitle[Window.Title] == Window then WindowByTitle[Window.Title] = nil end
				if windowFolder and windowFolder.Parent then windowFolder:Destroy() end
			end

			newWindow.TopFrame.Hide.MouseButton1Click:Connect(function()
				if not timeout then
					timeout = true
					ToggleWindow(false)
					task.delay(TweenConfigs.Global.Duration, function()
						timeout = false
					end)
				end
			end)

			newFloatingIcon.Open.MouseButton1Click:Connect(function()
				if not timeout then
					timeout = true
					ToggleWindow(true)
					task.delay(TweenConfigs.Global.Duration, function()
						timeout = false
					end)
				end
			end)

			newWindow.TopFrame.Close.MouseButton1Click:Connect(function()

				Window:Dialog({
					Icon = "triangle-alert",
					Title = "Close Window",
					Content = "Do you want to close this window? You will not able to open it again.",
					Buttons = {
						{
							Title = "Cancel"
						},
						{
							Title = "Close Window",
							Callback = function()
								Window:Destroy()
							end,
						}
					}
				})
			end)

			newWindow.TopFrame.Maximize.MouseButton1Click:Connect(function()
				if not maximizedWindow then

					windowDraggable:SetAllowDragging(false)
					windowResizable:SetAllowResizing(false)
					resizeHandle.Visible = false
					oldWindowSizeMaximize = newWindow.Size
					oldWindowPositionMaximize = newWindow.Position
					Tween(newWindow, {Size = UDim2.new(1,0,1,0)}, TweenConfigs.Global)
					Tween(newWindow, {Position = UDim2.new(0.5,0,0.5,0)}, TweenConfigs.Global)

					Tween(newWindow.UICorner, {CornerRadius = UDim.new(0,0)}, TweenConfigs.Global)

					maximizedWindow = true
				else

					windowDraggable:SetAllowDragging(true)
					windowResizable:SetAllowResizing(true)
					resizeHandle.Visible = true
					Tween(newWindow, {Size = oldWindowSizeMaximize}, TweenConfigs.Global)
					Tween(newWindow, {Position = oldWindowPositionMaximize}, TweenConfigs.Global)

					if UISettings.Enabled then
						Tween(newWindow.UICorner, {CornerRadius = UDim.new(0, UISettings.CornerRadius)}, TweenConfigs.Global)
					else
						local originalCorner = themeBase[newWindow.UICorner] and themeBase[newWindow.UICorner].CornerRadius
						Tween(newWindow.UICorner, {CornerRadius = originalCorner or UDim.new(0, 10)}, TweenConfigs.Global)
					end

					maximizedWindow = false
				end
			end)

			-- ============================================================
			-- XNGOT STARTUP GATE: loader + key system chay bang ENGINE CUA XNGOT STUDIO
			-- (theme UISettings, font/icon/Tween cua cua so) - day du tinh nang nhu engine
			-- loader cua Airflow (_showLoader/_playIntro): the CanvasGroup, icon nay Back,
			-- progress + shimmer, status theo step, morph the -> cua so. Khac ban goc:
			-- progress chay theo ASSET TAI THAT (PreloadAsync), hien menu xNgot Studio,
			-- kem Key System (nho key vinh vien, sai rung the, Get Key) dung chung the.
			-- ============================================================
			local startupGateLoading = Window.Loading
			local startupGateKey = type(Window.KeySystem) == "table" and Window.KeySystem or nil
			local startupGateEnabled = startupGateLoading ~= false or (startupGateKey ~= nil and startupGateKey.Enabled == true)
			if startupGateEnabled then
				startupGatePassed = false
				newWindow.Visible = false
				windowstate = false
				task.spawn(function()
					local function gateMain()
						local GateTS = game:GetService("TweenService")
						local ContentProvider = game:GetService("ContentProvider")
						local function gTween(inst, props, dur, style, dir)
							local tw = GateTS:Create(inst, TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
							tw:Play()
							return tw
						end
						local function mk(class, props)
							local obj = Instance.new(class)
							for key, value in pairs(props or {}) do
								if key ~= "Parent" then obj[key] = value end
							end
							if props and props.Parent then obj.Parent = props.Parent end
							return obj
						end
						-- Bang mau lay tu theme cua cua so (UISettings): doi preset la gate doi theo
						local G_BG = UISettings.BackgroundColor or Color3.fromRGB(24, 27, 33)
						local G_SURFACE = UISettings.SurfaceColor or Color3.fromRGB(32, 35, 41)
						local G_S2 = G_SURFACE:Lerp(Color3.fromRGB(255, 255, 255), 0.07)
						local G_S3 = G_SURFACE:Lerp(Color3.fromRGB(255, 255, 255), 0.14)
						local G_TEXT = UISettings.TextColor or Color3.fromRGB(240, 242, 245)
						local G_MUTED = UISettings.MutedTextColor or Color3.fromRGB(150, 155, 165)
						local G_ACCENT = UISettings.AccentColor or Color3.fromRGB(10, 135, 213)
						local G_STROKE = G_SURFACE:Lerp(G_TEXT, 0.22)
						local G_ERROR = Color3.fromRGB(240, 120, 120)
						local G_SUCCESS = Color3.fromRGB(150, 220, 170)
						local G_RADIUS = math.clamp(tonumber(UISettings.CornerRadius) or 12, 8, 28)
						local G_FONT = "rbxassetid://11702779517" -- font cua UI xNgot Studio
						-- Dong bo font theo nhan tieu de cua cua so goc (TopFrame.TextLabel)
						pcall(function()
							local menuLabel = TopFrame and TopFrame:FindFirstChild("TextLabel")
							if menuLabel and menuLabel.FontFace and menuLabel.FontFace.Family and menuLabel.FontFace.Family ~= "" then G_FONT = menuLabel.FontFace.Family end
						end)
						local function gCorner(parent, radius) return mk("UICorner", { CornerRadius = UDim.new(0, radius or G_RADIUS), Parent = parent }) end
						local function gStroke(parent, color, transparency)
							return mk("UIStroke", { Color = color or G_STROKE, Transparency = transparency or 0, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent })
						end
						local function gText(props)
							local merged = { BackgroundTransparency = 1, TextColor3 = G_TEXT, TextSize = 14, FontFace = Font.new(G_FONT, Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd }
							for key, value in pairs(props or {}) do merged[key] = value end
							return mk("TextLabel", merged)
						end

						-- ===== Cau hinh loader / key (Window.Loading + Window.KeySystem) =====
						local loadCfg = type(startupGateLoading) == "table" and startupGateLoading or {}
						local loadTitle = tostring(loadCfg.Title or Window.Title or "xNgot Studio")
						local loadText = tostring(loadCfg.Text or "Loading")
						local loadSteps = type(loadCfg.Steps) == "table" and loadCfg.Steps or { "Preparing interface", "Loading icons", "Almost there" }
						local loadDuration = math.clamp(tonumber(loadCfg.Duration) or 1.6, 0.6, 8)
						local keyCfg = startupGateKey or {}
						-- Dong bo tieu de: the key dung chung tieu de cua so (nhu loader + menu),
						-- "Key System" xuong dong phu. Van ghi de duoc bang KeySystem.Title.
						local keyHeader = tostring(keyCfg.Title or loadTitle)
						local keySubtitle = tostring(keyCfg.Subtitle or "Enter your key to continue")
						if keyCfg.Title == nil then keySubtitle = "Key System \u{00B7} " .. keySubtitle end
						local keyNote = tostring(keyCfg.Note or "Your key is saved on this device for next time.")
						local keyGetUrl = tostring(keyCfg.GetKeyUrl or keyCfg.GetKey or "")
						local keyCaseSensitive = keyCfg.CaseSensitive == true
						local keyFilePath = tostring(keyCfg.KeyFile or "xNgotLibrary/Keys/key.txt")
						Window.KeyFilePath = keyFilePath
						local function keyNorm(val)
							val = tostring(val or ""):gsub("^%s+", ""):gsub("%s+$", "")
							if not keyCaseSensitive then val = val:lower() end
							return val
						end
						local keyList = {}
						if type(keyCfg.Key) == "string" then keyList[#keyList + 1] = keyCfg.Key end
						if type(keyCfg.Keys) == "table" then
							for _, kk in ipairs(keyCfg.Keys) do
								if type(kk) == "string" then keyList[#keyList + 1] = kk
								elseif type(kk) == "table" then keyList[#keyList + 1] = tostring(kk.Key or kk.key or kk.Value or "") end
							end
						end
						local function keyMatches(input)
							local nn = keyNorm(input)
							if nn == "" then return false end
							for _, kk in ipairs(keyList) do if keyNorm(kk) == nn then return true end end
							return false
						end
						local savedKeyOk = false
						if type(isfile) == "function" and type(readfile) == "function" then
							local okSaved, saved = pcall(function() if isfile(keyFilePath) then return readfile(keyFilePath) end return nil end)
							if okSaved and type(saved) == "string" and keyMatches(saved) then savedKeyOk = true end
						end
						local needKey = startupGateKey ~= nil and keyCfg.Enabled == true and not savedKeyOk
						if savedKeyOk then Window.KeyUnlocked = true end
						function Window:ForgetSavedKey()
							if type(delfile) == "function" and type(isfile) == "function" then
								return pcall(function() if isfile(keyFilePath) then delfile(keyFilePath) end end)
							end
							return false
						end

						-- ===== The loader (engine morph nhu Airflow, chay bang theme cua xNgot) =====
						local card = mk("CanvasGroup", { Name = "xNgotStartupGate", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 16), Size = UDim2.fromOffset(300, 132), BackgroundColor3 = G_BG, BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 100, Parent = windowFolder })
						Window.__startupGateCard = card
						local cardCorner = gCorner(card, G_RADIUS)
						local cardStroke = gStroke(card, G_STROKE, 0)
						mk("Frame", { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.93, BorderSizePixel = 0, ZIndex = 1, Parent = card })
						local function addGlow(size, pos, transparency, rotation)
							local glow = mk("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = size, BackgroundTransparency = 1, Image = "rbxassetid://8992230677", ImageColor3 = G_ACCENT:Lerp(Color3.new(1, 1, 1), 0.45), ImageTransparency = transparency, ZIndex = 0, Parent = card })
							mk("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), G_ACCENT), Rotation = rotation or 90, Parent = glow })
							return glow
						end
						addGlow(UDim2.fromOffset(320, 140), UDim2.new(1, -20, 0, -20), 0.85, 90)
						addGlow(UDim2.fromOffset(240, 100), UDim2.new(0, 10, 1, 10), 0.9, 270)
						local cardScale = mk("UIScale", { Scale = 0.92, Parent = card })
						local shadow = mk("ImageLabel", { Position = UDim2.fromOffset(-25, -25), Size = UDim2.new(1, 50, 1, 50), BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 1, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 0, Parent = card })
						-- Bong do dong bo cua so goc: copy DropShadow cua chinh cua so
						pcall(function()
							local winShadow = newWindow and newWindow:FindFirstChild("DropShadow")
							if winShadow and winShadow:IsA("ImageLabel") and winShadow.Image and winShadow.Image ~= "" then
								shadow.Image = winShadow.Image
								shadow.ScaleType = winShadow.ScaleType
								shadow.SliceCenter = winShadow.SliceCenter
								shadow.ImageColor3 = winShadow.ImageColor3
							end
						end)
						local iconHolder = mk("Frame", { Position = UDim2.fromOffset(24, 26), Size = UDim2.fromOffset(40, 40), BackgroundTransparency = 1, ZIndex = 3, Parent = card })
						local iconImg = mk("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.5, 0.5), Rotation = -14, BackgroundTransparency = 1, ImageColor3 = G_ACCENT, ImageTransparency = 1, ScaleType = Enum.ScaleType.Fit, ZIndex = 3, Parent = iconHolder })
						-- Icon gate phai trung khit icon menu: copy thang tu TopFrame.Icon cua cua so
						local menuIconSource = TopFrame and TopFrame:FindFirstChild("Icon")
						if menuIconSource then
							iconImg.Image = menuIconSource.Image
							iconImg.ImageRectOffset = menuIconSource.ImageRectOffset
							iconImg.ImageRectSize = menuIconSource.ImageRectSize
							iconImg.ImageColor3 = menuIconSource.ImageColor3
						else
							ApplyIcon(iconImg, Window.Icon)
						end
						local loaderGroup = mk("CanvasGroup", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 0, ZIndex = 4, Parent = card })
						gText({ Position = UDim2.fromOffset(78, 30), Size = UDim2.new(1, -100, 0, 22), Text = loadTitle, TextSize = 20, FontFace = Font.new(G_FONT, Enum.FontWeight.SemiBold), Parent = loaderGroup })
						local loadStatus = gText({ Position = UDim2.fromOffset(78, 52), Size = UDim2.new(1, -100, 0, 16), Text = savedKeyOk and "Saved key found" or loadText, TextSize = 13, FontFace = Font.new(G_FONT, Enum.FontWeight.Regular), TextColor3 = G_MUTED, Parent = loaderGroup })
						local track = mk("Frame", { Position = UDim2.new(0, 24, 1, -30), Size = UDim2.new(1, -48, 0, 4), BackgroundColor3 = G_S3, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 4, Parent = loaderGroup })
						gCorner(track, 999)
						local fill = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = G_ACCENT, BorderSizePixel = 0, ZIndex = 4, Parent = track })
						gCorner(fill, 999)
						local shimmer = mk("Frame", { Position = UDim2.fromScale(-0.4, 0), Size = UDim2.fromScale(0.4, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 5, Parent = track })
						mk("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = shimmer })

						-- ===== The key (cung the, morph tu loader) =====
						local keyGroup = mk("CanvasGroup", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1, Visible = false, ZIndex = 4, Parent = card })
						gText({ Position = UDim2.fromOffset(78, 24), Size = UDim2.new(1, -102, 0, 22), Text = keyHeader, TextSize = 18, FontFace = Font.new(G_FONT, Enum.FontWeight.SemiBold), Parent = keyGroup })
						local keyStatus = gText({ Position = UDim2.fromOffset(78, 47), Size = UDim2.new(1, -102, 0, 16), Text = keySubtitle, TextSize = 12, FontFace = Font.new(G_FONT, Enum.FontWeight.Regular), TextColor3 = G_MUTED, Parent = keyGroup })
						local inputBox = mk("Frame", { Position = UDim2.fromOffset(24, 86), Size = UDim2.new(1, -48, 0, 42), BackgroundColor3 = G_S2, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 4, Parent = keyGroup })
						gCorner(inputBox, math.max(4, G_RADIUS - 4))
						local inputStroke = gStroke(inputBox, G_STROKE, 0)
						local keyInput = mk("TextBox", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, PlaceholderText = "Enter your key...", PlaceholderColor3 = G_MUTED, Text = "", TextColor3 = G_TEXT, TextSize = 14, FontFace = Font.new(G_FONT, Enum.FontWeight.Regular), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ClipsDescendants = true, ZIndex = 4, Parent = inputBox })
						local hasGetKey = keyGetUrl ~= ""
						local enterBtn = mk("TextButton", { Position = UDim2.fromOffset(24, 140), Size = hasGetKey and UDim2.new(1, -168, 0, 38) or UDim2.new(1, -48, 0, 38), BackgroundColor3 = G_ACCENT, BackgroundTransparency = 0.12, BorderSizePixel = 0, AutoButtonColor = false, FontFace = Font.new(G_FONT, Enum.FontWeight.SemiBold), Text = "Enter", TextSize = 13, TextColor3 = G_BG, ZIndex = 4, Parent = keyGroup })
						gCorner(enterBtn, math.max(4, G_RADIUS - 4))
						local enterStroke = gStroke(enterBtn, G_ACCENT, 0.4)
						enterBtn.MouseEnter:Connect(function() gTween(enterBtn, { BackgroundTransparency = 0 }, 0.12) gTween(enterStroke, { Transparency = 0 }, 0.12) end)
						enterBtn.MouseLeave:Connect(function() gTween(enterBtn, { BackgroundTransparency = 0.12 }, 0.25) gTween(enterStroke, { Transparency = 0.4 }, 0.25) end)
						local getBtn = nil
						if hasGetKey then
							getBtn = mk("TextButton", { Position = UDim2.new(1, -128, 0, 140), Size = UDim2.fromOffset(104, 38), BackgroundColor3 = G_S3, BorderSizePixel = 0, AutoButtonColor = false, FontFace = Font.new(G_FONT, Enum.FontWeight.Medium), Text = "Get Key", TextSize = 12, TextColor3 = G_TEXT, ZIndex = 4, Parent = keyGroup })
							gCorner(getBtn, math.max(4, G_RADIUS - 4))
							gStroke(getBtn, G_STROKE, 0)
						end
						gText({ Position = UDim2.fromOffset(24, 192), Size = UDim2.new(1, -48, 0, 16), Text = keyNote, TextSize = 11, FontFace = Font.new(G_FONT, Enum.FontWeight.Regular), TextColor3 = G_MUTED, Parent = keyGroup })

						local gateDone, gateBusy = false, false
						local function shakeCard()
							task.spawn(function()
								for _, dx in ipairs({ -10, 10, -6, 6, 0 }) do
									if not card.Parent then return end
									gTween(card, { Position = UDim2.new(0.5, dx, 0.5, 0) }, 0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Wait()
								end
								gTween(card, { Position = UDim2.fromScale(0.5, 0.5) }, 0.05)
							end)
						end
						local function submitKey()
							if gateBusy or gateDone then return end
							gateBusy = true
							if keyMatches(keyInput.Text) then
								Window.KeyUnlocked = true
								if type(writefile) == "function" then pcall(writefile, keyFilePath, keyNorm(keyInput.Text)) end
								inputStroke.Color = G_SUCCESS
								keyStatus.TextColor3 = G_SUCCESS
								keyStatus.Text = "Key accepted - welcome!"
								enterBtn.Text = "Success"
								gateDone = true
							else
								Window.KeyAttempts = (Window.KeyAttempts or 0) + 1
								inputStroke.Color = G_ERROR
								keyStatus.TextColor3 = G_ERROR
								keyStatus.Text = string.format("Invalid key - try again (%d attempt%s)", Window.KeyAttempts, Window.KeyAttempts == 1 and "" or "s")
								keyInput.Text = ""
								shakeCard()
								task.delay(1.2, function() if not gateDone and inputStroke.Parent then inputStroke.Color = G_STROKE end end)
							end
							gateBusy = false
						end
						enterBtn.MouseButton1Click:Connect(submitKey)
						keyInput.FocusLost:Connect(function(enterPressed) if enterPressed then submitKey() end end)
						keyInput.Focused:Connect(function() if not gateDone then gTween(inputStroke, { Color = G_ACCENT }, 0.15) end end)
						if getBtn then
							getBtn.MouseButton1Click:Connect(function()
								local copied = false
								if type(setclipboard) == "function" then copied = pcall(setclipboard, keyGetUrl) end
								keyStatus.TextColor3 = G_MUTED
								keyStatus.Text = copied and "Key link copied to clipboard" or keyGetUrl
							end)
						end

						-- ===== Chay loader: vao the + tai asset that =====
						gTween(card, { GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5) }, 0.4, Enum.EasingStyle.Quint)
						gTween(cardScale, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
						gTween(shadow, { ImageTransparency = 0.6 }, 0.4)
						task.delay(0.15, function()
							if not card.Parent then return end
							gTween(iconImg, { Size = UDim2.fromScale(0.85, 0.85), Rotation = 0 }, 0.6, Enum.EasingStyle.Back)
							gTween(iconImg, { ImageTransparency = 0 }, 0.4)
						end)
						local shimmerTween = GateTS:Create(shimmer, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1), { Position = UDim2.fromScale(1, 0) })
						shimmerTween:Play()
						-- ===== Tai TAT CA tai nguyen, ap dung that (khong con progress ao) =====
						-- (1) Tinh: 16 spritesheet Lucide + anh template GUI + bong/glow + font + SFX.
						-- (2) Dong: avatar nguoi choi + icon game. (3) Trong luc cho, quet GUI truc
						-- tiep de bat moi asset vua duoc gan (icon tab, avatar admin, bia nhac...)
						-- roi PreloadAsync tiep. Progress = asset da tai xong / tong asset that.
						local assetList, seenAssets = {}, {}
						local totalAssets, loadedAssets, pendingBatches = 0, 0, 0
						local function queueAssets(list)
							local batch = {}
							for _, id in ipairs(list or {}) do
								if type(id) == "string" and id ~= "" and id ~= "rbxassetid://0" and not seenAssets[id] then
									seenAssets[id] = true
									batch[#batch + 1] = id
								end
							end
							if #batch == 0 then return end
							totalAssets = totalAssets + #batch
							pendingBatches = pendingBatches + 1
							task.spawn(function()
								pcall(function() ContentProvider:PreloadAsync(batch, function() loadedAssets = loadedAssets + 1 end) end)
								pendingBatches = pendingBatches - 1
							end)
						end
						local function addAsset(id) assetList[#assetList + 1] = id end
						-- 16 spritesheets Lucide (dong bo voi module Lucide trong chinh file nay)
						for _, sheet in ipairs({
							"rbxassetid://131526378523863", "rbxassetid://98656588890340", "rbxassetid://122516128999742",
							"rbxassetid://136045238860745", "rbxassetid://138056954680929", "rbxassetid://139241675471365",
							"rbxassetid://120281540002144", "rbxassetid://122481504913348", "rbxassetid://125136326597802",
							"rbxassetid://132619645919851", "rbxassetid://124546836680911", "rbxassetid://138714413596023",
							"rbxassetid://95318701976229", "rbxassetid://87465848394141", "rbxassetid://77771201330939",
							"rbxassetid://126006375824005",
						}) do addAsset(sheet) end
						-- Anh template cua GUI + anh gate + font UI + am thanh SFX
						for _, asset in ipairs({
							"rbxassetid://113216930555884", "rbxassetid://132453323679056", "rbxassetid://108285848026510",
							"rbxassetid://120292618616139", "rbxassetid://122219713887461", "rbxassetid://128209591224511",
							"rbxassetid://77563793724007", "rbxassetid://86928976705683", "rbxassetid://91877599529856",
							"rbxassetid://92049322344253", "rbxassetid://91415671397056",
							"rbxassetid://6014261993", "rbxassetid://8992230677", "rbxassetid://11702779517",
							"rbxasset://sounds/button.wav", "rbxasset://sounds/switch.wav", "rbxasset://sounds/electronicpingshort.wav",
							"rbxasset://sounds/clickfast.wav", "rbxasset://sounds/snap.wav",
						}) do addAsset(asset) end
						pcall(function()
							local iconData = IconModule.Icon(Window.Icon)
							if type(iconData) == "table" and iconData[1] then addAsset(tostring(iconData[1])) end
						end)
						pcall(function()
							local plrs = game:GetService("Players")
							local lp = plrs.LocalPlayer
							if lp then addAsset(plrs:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420)) end
						end)
						pcall(function()
							if game.GameId and game.GameId ~= 0 then addAsset("rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150") end
						end)
						queueAssets(assetList)
						-- Quet GUI truc tiep: bat asset moi duoc gan trong luc loader dang cho
						local function scanGuiAssets()
							local found = {}
							pcall(function()
								for _, inst in ipairs(Gui:GetDescendants()) do
									if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
										found[#found + 1] = inst.Image
										if inst:IsA("ImageButton") then
											found[#found + 1] = inst.HoverImage
											found[#found + 1] = inst.PressedImage
										end
									elseif inst:IsA("Sound") then
										found[#found + 1] = inst.SoundId
									end
									if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
										local ff = inst.FontFace
										if ff and type(ff.Family) == "string" and ff.Family ~= "" then found[#found + 1] = ff.Family end
									end
								end
							end)
							queueAssets(found)
						end
						scanGuiAssets()
						local steps = savedKeyOk and { "Preparing interface", "Saved key found", "Welcome back" } or loadSteps
						local loadStart = os.clock()
						local lastScan = 0
						local minLoadTime = math.max(loadDuration, 2.2)
						while true do
							if windowDestroyed or not card.Parent then return end
							local frac = math.clamp(loadedAssets / math.max(totalAssets, 1), 0, 1)
							gTween(fill, { Size = UDim2.fromScale(0.85 * math.max(frac, 0.08), 1) }, 0.25, Enum.EasingStyle.Quart)
							local stepText = steps[math.clamp(math.floor(frac * #steps) + 1, 1, #steps)]
							if loadStatus.Text ~= stepText then loadStatus.Text = stepText end
							local elapsed = os.clock() - loadStart
							if elapsed - lastScan >= 0.45 then lastScan = elapsed scanGuiAssets() end
							if (pendingBatches <= 0 and elapsed >= minLoadTime) or elapsed >= 9 then break end
							task.wait(0.12)
						end
						gTween(fill, { Size = UDim2.fromScale(1, 1) }, 0.25, Enum.EasingStyle.Quint)
						task.wait(0.25)
						if windowDestroyed or not card.Parent then return end
						shimmerTween:Cancel()
						gTween(loaderGroup, { GroupTransparency = 1 }, 0.15)
						task.wait(0.15)
						if windowDestroyed or not card.Parent then return end

						if needKey then
							loaderGroup.Visible = false
							keyGroup.Visible = true
							local keyWidth = 340
							pcall(function() local abs = Gui.AbsoluteSize if abs and abs.X > 40 then keyWidth = math.min(340, abs.X - 24) end end)
							gTween(card, { Size = UDim2.fromOffset(keyWidth, 232) }, 0.5, Enum.EasingStyle.Quint)
							gTween(cardCorner, { CornerRadius = UDim.new(0, G_RADIUS) }, 0.5, Enum.EasingStyle.Quint)
							task.wait(0.3)
							if windowDestroyed or not card.Parent then return end
							gTween(keyGroup, { GroupTransparency = 0 }, 0.25)
							pcall(function() keyInput:CaptureFocus() end)
							while not gateDone do
								if windowDestroyed or not card.Parent then return end
								task.wait(0.1)
							end
							task.wait(0.5)
							if windowDestroyed or not card.Parent then return end
							gTween(keyGroup, { GroupTransparency = 1 }, 0.2)
						end

						-- ===== Morph the -> cua so, hien menu (tuong duong _playIntro(true)) =====
						task.wait(0.15)
						if windowDestroyed or not card.Parent then return end
						gTween(card, { Size = UDim2.fromOffset(oldWindowSize.X.Offset, oldWindowSize.Y.Offset), Position = UDim2.fromScale(0.5, 0.5) }, 0.5, Enum.EasingStyle.Quint)
						gTween(cardCorner, { CornerRadius = UDim.new(0, G_RADIUS) }, 0.5, Enum.EasingStyle.Quint)
						gTween(cardScale, { Scale = 1 }, 0.5, Enum.EasingStyle.Quint)
						task.wait(0.28)
						if windowDestroyed or not card.Parent then return end
						startupGatePassed = true
						newWindow.Size = oldWindowSize
						newWindow.Visible = true
						do local dropShadow = newWindow:FindFirstChild("DropShadow") if dropShadow then pcall(function() dropShadow.Visible = true end) end end
						if newWindow:FindFirstChild("Tabs") then newWindow.Tabs.Visible = true end
						if newWindow:FindFirstChild("TabButtons") then newWindow.TabButtons.Visible = true end
						newFloatingIcon.Visible = false
						windowstate = true
						if startupGateIslandHeld then
							startupGateIslandHeld = false
							local islandApi = Window.DynamicIsland
							if islandApi and type(islandApi.Enable) == "function" then pcall(islandApi.Enable, islandApi, true) end
						end
						if type(Window.RefreshAdminAvatar) == "function" then pcall(function() Window:RefreshAdminAvatar() end) end
						gTween(card, { GroupTransparency = 1 }, 0.25)
						gTween(cardStroke, { Transparency = 1 }, 0.2)
						gTween(shadow, { ImageTransparency = 1 }, 0.2)
						task.wait(0.6)
						if card.Parent then card:Destroy() end
					end
					local gateOk, gateErr = xpcall(gateMain, function(err)
						if debug and type(debug.traceback) == "function" then return debug.traceback(tostring(err), 2) end
						return tostring(err)
					end)
					if not gateOk then
						warn("[xNgotStudio] Startup gate error (da tu mo cua so): " .. tostring(gateErr))
						startupGatePassed = true
						Window.KeyUnlocked = true
						if Window.__startupGateCard and Window.__startupGateCard.Parent then Window.__startupGateCard:Destroy() end
						if startupGateIslandHeld then
							startupGateIslandHeld = false
							local islandApi = Window.DynamicIsland
							if islandApi and type(islandApi.Enable) == "function" then pcall(islandApi.Enable, islandApi, true) end
						end
						newWindow.Size = oldWindowSize
						newWindow.Visible = true
						windowstate = true
					end
				end)
			else
				Tween(newWindow, {Size = oldWindowSize}, TweenConfigs.Global)
			end

			keybindConnection = UIS.InputBegan:Connect(function(input, gpe)
				if windowDestroyed then return end
				if not timeout and not gpe and startupGatePassed and input.KeyCode == Window.ToggleKey then
					timeout = true
					ToggleWindow()
					task.delay(TweenConfigs.Global.Duration, function()
						timeout = false
					end)
				end
			end)

