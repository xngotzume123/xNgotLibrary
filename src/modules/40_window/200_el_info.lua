--[[ xngot-studio · src/modules/40_window/200_el_info.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_info
     role   : Tab:InfoNguyenNhat
     source : main 2.txt L13961-14130 · 170 dòng · delta +0
--]]
				function Tab:InfoNguyenNhat(data)
					data = data or {}
					local Info = {
						Avatar = tostring(data.Avatar or "rbxassetid://0"),
						Name = tostring(data.Name or "Nguyen Nhat"),
						Badges = type(data.Badges) == "table" and data.Badges or {},
						Bio = tostring(data.Bio or ""),
					}

					local card = Instance.new("Frame")
					card.Name = "InfoNguyenNhat"
					card.BackgroundColor3 = Color3.fromRGB(43, 46, 53)
					card.AutomaticSize = Enum.AutomaticSize.Y
					card.Size = UDim2.new(1, 0, 0, 90)
					card.Parent = parentElement

					Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
					local cardStroke = Instance.new("UIStroke", card)
					cardStroke.Color = Color3.fromRGB(61, 61, 75)
					cardStroke.Thickness = 1.5

					local pad = Instance.new("UIPadding", card)
					pad.PaddingTop = UDim.new(0, 12)
					pad.PaddingBottom = UDim.new(0, 12)
					pad.PaddingLeft = UDim.new(0, 12)
					pad.PaddingRight = UDim.new(0, 12)

					local layout = Instance.new("UIListLayout", card)
					layout.FillDirection = Enum.FillDirection.Horizontal
					layout.VerticalAlignment = Enum.VerticalAlignment.Center
					layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
					layout.Padding = UDim.new(0, 14)
					layout.SortOrder = Enum.SortOrder.LayoutOrder

					local socialCol = Instance.new("Frame")
					socialCol.Name = "Socials"
					socialCol.BackgroundTransparency = 1
					socialCol.AutomaticSize = Enum.AutomaticSize.XY
					socialCol.LayoutOrder = 3
					socialCol.Parent = card

					local socialLayout = Instance.new("UIListLayout", socialCol)
					socialLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					socialLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					socialLayout.Padding = UDim.new(0, 8)
					socialLayout.SortOrder = Enum.SortOrder.LayoutOrder

					local textCol = Instance.new("Frame")
					textCol.Name = "Info"
					textCol.BackgroundTransparency = 1
					textCol.AutomaticSize = Enum.AutomaticSize.Y
					textCol.Size = UDim2.new(1, -110, 0, 0)
					textCol.LayoutOrder = 2
					textCol.Parent = card

					local textLayout = Instance.new("UIListLayout", textCol)
					textLayout.Padding = UDim.new(0, 4)
					textLayout.SortOrder = Enum.SortOrder.LayoutOrder

					local nameRow = Instance.new("Frame")
					nameRow.BackgroundTransparency = 1
					nameRow.AutomaticSize = Enum.AutomaticSize.XY
					nameRow.Size = UDim2.new(0, 0, 0, 18)
					nameRow.LayoutOrder = 1
					nameRow.Parent = textCol

					local nameRowLayout = Instance.new("UIListLayout", nameRow)
					nameRowLayout.FillDirection = Enum.FillDirection.Horizontal
					nameRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					nameRowLayout.Padding = UDim.new(0, 6)
					nameRowLayout.SortOrder = Enum.SortOrder.LayoutOrder

					local nameLabel = Instance.new("TextLabel")
					nameLabel.Text = Info.Name
					nameLabel.FontFace = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal)
					nameLabel.TextSize = 16
					nameLabel.TextColor3 = UISettings.TextColor
					nameLabel.BackgroundTransparency = 1
					nameLabel.AutomaticSize = Enum.AutomaticSize.X
					nameLabel.Size = UDim2.new(0, 0, 0, 18)
					nameLabel.LayoutOrder = 1
					nameLabel.Parent = nameRow

					for i, badgeText in ipairs(Info.Badges) do
						local badge = Instance.new("TextLabel")
						badge.Text = badgeText
						badge.FontFace = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal)
						badge.TextSize = 11
						badge.TextColor3 = Color3.fromRGB(255, 255, 255)
						badge.BackgroundColor3 = UISettings.AccentColor
						badge.AutomaticSize = Enum.AutomaticSize.X
						badge.Size = UDim2.new(0, 0, 0, 16)
						badge.LayoutOrder = i + 1
						badge.Parent = nameRow
						Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)
						local bp = Instance.new("UIPadding", badge)
						bp.PaddingLeft = UDim.new(0, 6)
						bp.PaddingRight = UDim.new(0, 6)
					end

					local bioLabel = Instance.new("TextLabel")
					bioLabel.Text = Info.Bio
					bioLabel.FontFace = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					bioLabel.TextSize = 13
					bioLabel.TextColor3 = UISettings.MutedTextColor
					bioLabel.TextXAlignment = Enum.TextXAlignment.Left
					bioLabel.TextWrapped = true
					bioLabel.BackgroundTransparency = 1
					bioLabel.AutomaticSize = Enum.AutomaticSize.Y
					bioLabel.Size = UDim2.new(1, 0, 0, 14)
					bioLabel.Visible = Info.Bio ~= ""
					bioLabel.LayoutOrder = 2
					bioLabel.Parent = textCol

					local avatarFrame = Instance.new("ImageLabel")
					avatarFrame.Name = "Avatar"
					avatarFrame.Size = UDim2.new(0, 60, 0, 60)
					avatarFrame.Image = Info.Avatar
					avatarFrame.BackgroundColor3 = Color3.fromRGB(32, 35, 41)
					avatarFrame.LayoutOrder = 1
					avatarFrame.Parent = card
					local avatarPlaceholder = Instance.new("TextLabel")
					avatarPlaceholder.Name = "FallbackInitials"
					avatarPlaceholder.Size = UDim2.fromScale(1, 1)
					avatarPlaceholder.BackgroundTransparency = 1
					avatarPlaceholder.Font = Enum.Font.GothamBold
					avatarPlaceholder.Text = "xN"
					avatarPlaceholder.TextSize = 22
					avatarPlaceholder.TextColor3 = UISettings.AccentColor
					avatarPlaceholder.Visible = Info.Avatar == "" or Info.Avatar == "rbxassetid://0"
					avatarPlaceholder.Parent = avatarFrame
					Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(0, 14)
					local avStroke = Instance.new("UIStroke", avatarFrame)
					avStroke.Color = Color3.fromRGB(61, 61, 75)
					avStroke.Thickness = 1.5

					function Info.AddSocialIcon(icon, copyValue, order)
						return CreateSocialIcon(socialCol, icon, copyValue, order)
					end

					function Info:SetAvatar(id)
						id = tostring(id or "")
						avatarFrame.Image = id
						avatarPlaceholder.Visible = id == "" or id == "rbxassetid://0"
						if id ~= "" and id ~= "rbxassetid://0" then
							 
							 
							 
							local wanted = id
							task.spawn(function()
								for _, waitTime in ipairs({ 1, 2, 3, 5 }) do
									task.wait(waitTime)
									if avatarFrame.Image ~= wanted then return end
									if avatarFrame.IsLoaded then return end
									avatarFrame.Image = ""
									avatarFrame.Image = wanted
								end
							end)
						end
					end
					function Info:SetName(text) nameLabel.Text = text end
					function Info:SetBio(text)
						bioLabel.Text = text
						bioLabel.Visible = text ~= ""
					end
					function Info:Destroy() card:Destroy() end

					return Info
				end

