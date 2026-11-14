--[[ xngot-studio · src/modules/20_lib/130_clipboard.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.clipboard
     role   : CopyText(): clipboard + thông báo 'Copied'
     source : main 2.txt L2664-2702 · 39 dòng · delta +0
--]]
		local function CopyText(text)
			local clipboard = type(setclipboard) == "function" and setclipboard
				or (type(toclipboard) == "function" and toclipboard)
			if not clipboard then return false end
			return pcall(clipboard, tostring(text or ""))
		end

		local function ShowCopiedTip(target)
			local tip = Instance.new("TextLabel")
			tip.Text = "Copied!"
			tip.FontFace = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			tip.TextSize = 12
			tip.TextColor3 = Color3.fromRGB(255, 255, 255)
			tip.BackgroundColor3 = Color3.fromRGB(10, 135, 213)
			tip.AutomaticSize = Enum.AutomaticSize.XY
			tip.AnchorPoint = Vector2.new(0.5, 1)
			tip.Position = UDim2.new(0.5, 0, 0, -4)
			tip.ZIndex = 20
			tip.BackgroundTransparency = 1
			tip.TextTransparency = 1
			tip.Parent = target

			local pad = Instance.new("UIPadding", tip)
			pad.PaddingLeft = UDim.new(0, 6)
			pad.PaddingRight = UDim.new(0, 6)
			pad.PaddingTop = UDim.new(0, 3)
			pad.PaddingBottom = UDim.new(0, 3)
			Instance.new("UICorner", tip).CornerRadius = UDim.new(0, 4)

			Tween(tip, { BackgroundTransparency = 0, TextTransparency = 0 }, TweenConfigs.Global)
			task.delay(1, function()
				if tip and tip.Parent then
					local tw = Tween(tip, { BackgroundTransparency = 1, TextTransparency = 1 }, TweenConfigs.Global)
					tw.Completed:Wait()
					tip:Destroy()
				end
			end)
		end

