--[[ xngot-studio · src/modules/20_lib/140_social_icons.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.social
     role   : Icon mạng xã hội (Discord/GitHub) + tip copy link
     source : main 2.txt L2703-2744 · 42 dòng · delta +0
--]]
		local function CreateSocialIcon(parent, iconId, copyValue, order)
			local btn = Instance.new("ImageButton")
			btn.Name = "SocialIcon"
			btn.BackgroundColor3 = Color3.fromRGB(53, 56, 62)
			btn.Size = UDim2.new(0, 32, 0, 32)
			btn.AutoButtonColor = false
			btn.LayoutOrder = order or 0
			btn.Parent = parent

			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
			local stroke = Instance.new("UIStroke", btn)
			stroke.Color = Color3.fromRGB(61, 61, 75)
			stroke.Thickness = 1.5

			local icon = Instance.new("ImageLabel", btn)
			icon.BackgroundTransparency = 1
			icon.Image = iconId
			icon.ImageColor3 = Color3.fromRGB(197, 204, 219)
			icon.ScaleType = Enum.ScaleType.Fit
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.new(0.5, 0, 0.5, 0)
			icon.Size = UDim2.new(1, -14, 1, -14)

			btn.MouseEnter:Connect(function()
				Tween(stroke, { Color = Color3.fromRGB(10, 135, 213) }, TweenConfigs.Global)
			end)
			btn.MouseLeave:Connect(function()
				Tween(stroke, { Color = Color3.fromRGB(61, 61, 75) }, TweenConfigs.Global)
			end)
			btn.MouseButton1Click:Connect(function()
				if copyValue and copyValue ~= "" and CopyText(copyValue) then
					Tween(btn, { BackgroundColor3 = Color3.fromRGB(10, 135, 213) }, TweenConfigs.Global)
					task.delay(0.2, function()
						if btn.Parent then Tween(btn, { BackgroundColor3 = Color3.fromRGB(53, 56, 62) }, TweenConfigs.Global) end
					end)
					ShowCopiedTip(btn)
				end
			end)

			return btn
		end

