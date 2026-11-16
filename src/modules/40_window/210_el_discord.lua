--[[ xngot-studio · src/modules/40_window/210_el_discord.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_discord
     role   : Tab:Discord
     source : main 2.txt L14131-14283 · 153 dòng · delta -1
--]]
				function Tab:Discord(data)
					data = data or {}
					local Discord = {
						Avatar = tostring(data.Avatar or "rbxassetid://0"),
						Name = tostring(data.Name or "Discord Server"),
						Desc = tostring(data.Desc or ""),
						InviteLink = tostring(data.InviteLink or "discord.gg/xxxxxxx"),
						InviteCode = data.InviteCode ~= nil and tostring(data.InviteCode) or nil,
					}

					local card = Instance.new("Frame")
					card.Name = "DiscordCard"
					card.BackgroundColor3 = Color3.fromRGB(43, 46, 53)
					card.AutomaticSize = Enum.AutomaticSize.Y
					card.Size = UDim2.new(1, 0, 0, 90)
					card.Parent = parentElement

					Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
					local cardStroke2 = Instance.new("UIStroke", card)
					cardStroke2.Color = Color3.fromRGB(61, 61, 75)
					cardStroke2.Thickness = 1.5

					local pad2 = Instance.new("UIPadding", card)
					pad2.PaddingTop = UDim.new(0, 12)
					pad2.PaddingBottom = UDim.new(0, 12)
					pad2.PaddingLeft = UDim.new(0, 12)
					pad2.PaddingRight = UDim.new(0, 12)

					local layout2 = Instance.new("UIListLayout", card)
					layout2.FillDirection = Enum.FillDirection.Horizontal
					layout2.VerticalAlignment = Enum.VerticalAlignment.Center
					layout2.Padding = UDim.new(0, 12)
					layout2.SortOrder = Enum.SortOrder.LayoutOrder

					local avatarFrame2 = Instance.new("ImageLabel")
					avatarFrame2.Size = UDim2.new(0, 54, 0, 54)
					avatarFrame2.Image = Discord.Avatar
					avatarFrame2.BackgroundColor3 = Color3.fromRGB(32, 35, 41)
					avatarFrame2.LayoutOrder = 1
					avatarFrame2.Parent = card
					Instance.new("UICorner", avatarFrame2).CornerRadius = UDim.new(1, 0)

					local textCol2 = Instance.new("Frame")
					textCol2.BackgroundTransparency = 1
					textCol2.AutomaticSize = Enum.AutomaticSize.Y
					textCol2.Size = UDim2.new(1, -180, 0, 0)
					textCol2.LayoutOrder = 2
					textCol2.Parent = card

					local textLayout2 = Instance.new("UIListLayout", textCol2)
					textLayout2.Padding = UDim.new(0, 2)
					textLayout2.SortOrder = Enum.SortOrder.LayoutOrder

					local nameLabel2 = Instance.new("TextLabel")
					nameLabel2.Text = Discord.Name
					nameLabel2.FontFace = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal)
					nameLabel2.TextSize = 16
					nameLabel2.TextColor3 = UISettings.TextColor
					nameLabel2.TextXAlignment = Enum.TextXAlignment.Left
					nameLabel2.BackgroundTransparency = 1
					nameLabel2.AutomaticSize = Enum.AutomaticSize.Y
					nameLabel2.Size = UDim2.new(1, 0, 0, 18)
					nameLabel2.LayoutOrder = 1
					nameLabel2.Parent = textCol2

					local descLabel = Instance.new("TextLabel")
					descLabel.Text = Discord.Desc
					descLabel.FontFace = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					descLabel.TextSize = 12
					descLabel.TextColor3 = UISettings.MutedTextColor
					descLabel.TextXAlignment = Enum.TextXAlignment.Left
					descLabel.TextWrapped = true
					descLabel.BackgroundTransparency = 1
					descLabel.AutomaticSize = Enum.AutomaticSize.Y
					descLabel.Size = UDim2.new(1, 0, 0, 14)
					descLabel.Visible = Discord.Desc ~= ""
					descLabel.LayoutOrder = 2
					descLabel.Parent = textCol2

					local statusLabel = Instance.new("TextLabel")
					statusLabel.Text = ""
					statusLabel.FontFace = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					statusLabel.TextSize = 11
					statusLabel.TextColor3 = Color3.fromRGB(87, 242, 135)
					statusLabel.TextXAlignment = Enum.TextXAlignment.Left
					statusLabel.BackgroundTransparency = 1
					statusLabel.AutomaticSize = Enum.AutomaticSize.Y
					statusLabel.Size = UDim2.new(1, 0, 0, 12)
					statusLabel.Visible = false
					statusLabel.LayoutOrder = 3
					statusLabel.Parent = textCol2

					local joinBtn = Instance.new("TextButton")
					joinBtn.Text = "Join Discord"
					joinBtn.FontFace = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal)
					joinBtn.TextSize = 13
					joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					joinBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
					joinBtn.AutoButtonColor = false
					joinBtn.Size = UDim2.new(0, 110, 0, 32)
					joinBtn.LayoutOrder = 3
					joinBtn.Parent = card
					Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 6)

					joinBtn.MouseEnter:Connect(function()
						Tween(joinBtn, { BackgroundColor3 = Color3.fromRGB(71, 82, 196) }, TweenConfigs.Global)
					end)
					joinBtn.MouseLeave:Connect(function()
						Tween(joinBtn, { BackgroundColor3 = Color3.fromRGB(88, 101, 242) }, TweenConfigs.Global)
					end)
					joinBtn.MouseButton1Click:Connect(function()
						if CopyText(Discord.InviteLink) then
							ShowCopiedTip(joinBtn)
						end
					end)

					local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request
					if httpRequest and Discord.InviteCode then
						task.spawn(function()
							local ok, result = pcall(function()
								return httpRequest({
									Url = "https://discord.com/api/v9/invites/" .. Discord.InviteCode .. "?with_counts=true",
									Method = "GET",
								})
							end)
							if ok and result and result.StatusCode == 200 then
								local success, decoded = pcall(function()
									return HttpService:JSONDecode(result.Body)
								end)
								if success and decoded then
									local online = decoded.approximate_presence_count
									local total = decoded.approximate_member_count
									if online and total then
										statusLabel.Text = ("● %d online / %d thành viên"):format(online, total)
										statusLabel.Visible = true
									end
								end
							end
						end)
					end

					function Discord:SetInvite(link, code)
						Discord.InviteLink = tostring(link or "")
						if code ~= nil then Discord.InviteCode = tostring(code) end
					end
					function Discord:Destroy() card:Destroy() end

					Discord._AIInstance = card
					return Discord
				end

				-- Register the library's own controls; do not inspect or execute foreign UI.
				do
					Window._AIControls = Window._AIControls or {}
					for _, kind in ipairs({"Section", "Button", "Toggle", "Slider", "Input", "Dropdown", "Colorpicker", "Paragraph", "Code", "InfoNguyenNhat", "Discord"}) do
						local original = Tab[kind]
						Tab[kind] = function(self, data)
							local object = original(self, data)
							if type(data) == "table" and data.AIControl == false then return object end
							if type(object) ~= "table" or not object._AIInstance then return object end
							local title = (type(data) == "table" and (data.Title or data.Name)) or object.Title or object.Name or kind
							local entry = {Kind = kind, Title = tostring(title), Tab = NAMETAB, Object = object, Root = newWindow}
							if kind == "Slider" then
								local v = type(data) == "table" and type(data.Value) == "table" and data.Value or {}
								local lo, hi = tonumber(v.Min) or 0, tonumber(v.Max) or 100
								entry.Min, entry.Max = math.min(lo, hi), math.max(lo, hi)
								entry.Step = tonumber(type(data) == "table" and data.Step) or 1
								if entry.Step <= 0 then entry.Step = 1 end
							end
							if type(object.SetTitle) == "function" then
								local setTitle = object.SetTitle
								object.SetTitle = function(o, value, ...)
									local result = setTitle(o, value, ...)
									entry.Title = tostring(o.Title or value or kind)
									return result
								end
							end
							if kind == "InfoNguyenNhat" and type(object.SetName) == "function" then
								local setName = object.SetName
								object.SetName = function(o, value, ...)
									local result = setName(o, value, ...)
									entry.Title = tostring(value or "")
									return result
								end
							end
							table.insert(Window._AIControls, entry)
							return object
						end
					end
				end

				return Tab
			end

