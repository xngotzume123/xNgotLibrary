--[[ xngot-studio · src/modules/40_window/150_el_colorpicker.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_colorpicker
     role   : Tab:Colorpicker
     source : main 2.txt L12712-12918 · 207 dòng · delta +0
--]]
				function Tab:Colorpicker(data)
					data = data or {}
					local Colorpicker = {
						Title = data.Title or "Color",
						Desc = data.Desc or "",
						Locked = data.Locked == true,
						Callback = type(data.Callback) == "function" and data.Callback or function() end,
					}

					local function ToColor3(value)
						if typeof(value) == "Color3" then return value end
						if type(value) == "table" then
							local r = value.R or value.r or value[1] or 255
							local g = value.G or value.g or value[2] or 255
							local b = value.B or value.b or value[3] or 255
							if r <= 1 and g <= 1 and b <= 1 then
								return Color3.new(math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1))
							end
							return Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
						end
						if type(value) == "string" then
							local hex = value:gsub("#", "")
							if #hex == 6 then
								local r = tonumber(hex:sub(1, 2), 16)
								local g = tonumber(hex:sub(3, 4), 16)
								local b = tonumber(hex:sub(5, 6), 16)
								if r and g and b then return Color3.fromRGB(r, g, b) end
							end
						end
						return Color3.fromRGB(255, 255, 255)
					end

					local defaultValue = data.Default
					if defaultValue == nil then defaultValue = data.Value end
					local name = Colorpicker.Title
					Colorpicker.Value = ToColor3(defaultValue)
					if CONFIGLOADED and type(CONFIG[NAMETAB][name]) == "table" then
						Colorpicker.Value = ToColor3(CONFIG[NAMETAB][name])
					end

					local root = Instance.new("Frame")
					root.Name = Colorpicker.Title
					root.BackgroundColor3 = Color3.fromRGB(43, 46, 53)
					root.BorderSizePixel = 0
					root.Size = UDim2.new(1, 0, 0, 54)
					root.AutomaticSize = Enum.AutomaticSize.Y
					root.Parent = parentElement
					Instance.new("UICorner", root).CornerRadius = UDim.new(0, 6)
					local rootStroke = Instance.new("UIStroke", root)
					rootStroke.Color = Color3.fromRGB(61, 61, 75)
					rootStroke.Thickness = 1.5

					local rootLayout = Instance.new("UIListLayout", root)
					rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
					rootLayout.Padding = UDim.new(0, 6)
					local rootPad = Instance.new("UIPadding", root)
					rootPad.PaddingTop = UDim.new(0, 10)
					rootPad.PaddingBottom = UDim.new(0, 10)
					rootPad.PaddingLeft = UDim.new(0, 10)
					rootPad.PaddingRight = UDim.new(0, 10)

					local header = Instance.new("Frame", root)
					header.BackgroundTransparency = 1
					header.Size = UDim2.new(1, 0, 0, Colorpicker.Desc ~= "" and 38 or 24)
					header.LayoutOrder = 1

					local title = Instance.new("TextLabel", header)
					title.BackgroundTransparency = 1
					title.Text = Colorpicker.Title
					title.TextColor3 = UISettings.TextColor
					title.TextSize = 16
					title.FontFace = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					title.TextXAlignment = Enum.TextXAlignment.Left
					title.Size = UDim2.new(1, -52, 0, 18)

					local desc = Instance.new("TextLabel", header)
					desc.BackgroundTransparency = 1
					desc.Text = Colorpicker.Desc
					desc.TextColor3 = UISettings.MutedTextColor
					desc.TextSize = 12
					desc.FontFace = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					desc.TextXAlignment = Enum.TextXAlignment.Left
					desc.Position = UDim2.fromOffset(0, 21)
					desc.Size = UDim2.new(1, -52, 0, 15)
					desc.Visible = Colorpicker.Desc ~= ""

					local preview = Instance.new("TextButton", header)
					preview.Name = "NgotStudioColorPreview"
					preview.Text = ""
					preview.AutoButtonColor = false
					preview.AnchorPoint = Vector2.new(1, 0.5)
					preview.Position = UDim2.new(1, 0, 0.5, 0)
					preview.Size = UDim2.fromOffset(40, 28)
					preview.BackgroundColor3 = Colorpicker.Value
					Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)
					local previewStroke = Instance.new("UIStroke", preview)
					previewStroke.Color = Color3.fromRGB(95, 95, 117)

					local panel = Instance.new("Frame", root)
					panel.BackgroundTransparency = 1
					panel.Size = UDim2.new(1, 0, 0, 32)
					panel.LayoutOrder = 2
					panel.Visible = false
					local panelLayout = Instance.new("UIListLayout", panel)
					panelLayout.FillDirection = Enum.FillDirection.Horizontal
					panelLayout.Padding = UDim.new(0, 6)
					panelLayout.VerticalAlignment = Enum.VerticalAlignment.Center

					local boxes = {}
					local function CreateBox(channel)
						local holder = Instance.new("Frame", panel)
						holder.Name = channel
						holder.BackgroundColor3 = Color3.fromRGB(32, 35, 41)
						holder.Size = UDim2.new(1/3, -4, 1, 0)
						Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 5)
						local stroke = Instance.new("UIStroke", holder)
						stroke.Color = Color3.fromRGB(61, 61, 75)
						local label = Instance.new("TextLabel", holder)
						label.BackgroundTransparency = 1
						label.Text = channel
						label.TextColor3 = UISettings.MutedTextColor
						label.TextSize = 12
						label.Size = UDim2.fromOffset(20, 32)
						local box = Instance.new("TextBox", holder)
						box.BackgroundTransparency = 1
						box.TextColor3 = UISettings.TextColor
						box.TextSize = 13
						box.ClearTextOnFocus = false
						box.TextXAlignment = Enum.TextXAlignment.Left
						box.Position = UDim2.fromOffset(22, 0)
						box.Size = UDim2.new(1, -24, 1, 0)
						boxes[channel] = box
					end
					CreateBox("R")
					CreateBox("G")
					CreateBox("B")

					local function ToRGB(color)
						return math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255)
					end
					local function Render(color)
						local r, g, b = ToRGB(color)
						preview.BackgroundColor3 = color
						boxes.R.Text, boxes.G.Text, boxes.B.Text = tostring(r), tostring(g), tostring(b)
					end
					local function SaveColor(color)
						local r, g, b = ToRGB(color)
						CONFIG[NAMETAB][name] = {R = r, G = g, B = b}
						SAVECONFIG()
					end
					local function SetColor(value, fireCallback)
						local color = ToColor3(value)
						Colorpicker.Value = color
						Render(color)
						SaveColor(color)
						if fireCallback ~= false then Colorpicker.Callback(color) end
						return color
					end
					local function ApplyBoxes()
						if Colorpicker.Locked then return end
						local r = math.clamp(tonumber(boxes.R.Text) or 0, 0, 255)
						local g = math.clamp(tonumber(boxes.G.Text) or 0, 0, 255)
						local b = math.clamp(tonumber(boxes.B.Text) or 0, 0, 255)
						SetColor(Color3.fromRGB(r, g, b), true)
					end
					for _, box in pairs(boxes) do box.FocusLost:Connect(ApplyBoxes) end
					preview.MouseButton1Click:Connect(function()
						if not Colorpicker.Locked then panel.Visible = not panel.Visible end
					end)

					function Colorpicker:Set(value) return SetColor(value, true) end
					function Colorpicker:Get() return Colorpicker.Value end
					function Colorpicker:SetTitle(text)
						Colorpicker.Title = tostring(text or "Color")
						title.Text = Colorpicker.Title
						root.Name = Colorpicker.Title
					end
					function Colorpicker:SetDesc(text)
						Colorpicker.Desc = tostring(text or "")
						desc.Text = Colorpicker.Desc
						desc.Visible = Colorpicker.Desc ~= ""
						header.Size = UDim2.new(1, 0, 0, desc.Visible and 38 or 24)
					end
					function Colorpicker:Lock()
						Colorpicker.Locked = true
						panel.Visible = false
						rootStroke.Color = Color3.fromRGB(47, 47, 58)
						root.BackgroundColor3 = Color3.fromRGB(32, 35, 40)
						title.TextColor3 = Color3.fromRGB(75, 77, 83)
						preview.Active = false
					end
					function Colorpicker:Unlock()
						Colorpicker.Locked = false
						rootStroke.Color = Color3.fromRGB(61, 61, 75)
						root.BackgroundColor3 = Color3.fromRGB(43, 46, 53)
						title.TextColor3 = UISettings.TextColor
						preview.Active = true
					end
					function Colorpicker:Destroy() root:Destroy() end

					Render(Colorpicker.Value)
					SaveColor(Colorpicker.Value)
					if Colorpicker.Locked then Colorpicker:Lock() end
					Colorpicker.Callback(Colorpicker.Value)
					return Colorpicker
				end

