--[[ xngot-studio · src/modules/20_lib/110_draggable.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.draggable
     role   : Kéo cửa sổ bằng topbar (chuột + cảm ứng)
     source : main 2.txt L2512-2591 · 80 dòng · delta +0
--]]
		local function Draggable(topbarobject, object)
			local funcs = {}
			local tsv = game:GetService("TweenService")
			local Dragging = false
			local DragInput = nil
			local DragStart = nil
			local StartPosition = nil
			local allowDragging = true
			local destroyed = false
			local connections = {}
			local dragEndConnection = nil

			local function Track(connection)
				table.insert(connections, connection)
				return connection
			end

			local function Update(input)
				if destroyed or not DragStart or not StartPosition then return end
				local Delta = input.Position - DragStart
				local pos = UDim2.new(
					StartPosition.X.Scale,
					StartPosition.X.Offset + Delta.X,
					StartPosition.Y.Scale,
					StartPosition.Y.Offset + Delta.Y
				)
				tsv:Create(object, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = pos}):Play()
			end

			Track(topbarobject.InputBegan:Connect(function(input)
				if destroyed or not allowDragging then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					DragStart = input.Position
					StartPosition = object.Position
					if dragEndConnection then dragEndConnection:Disconnect() end
					dragEndConnection = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							Dragging = false
							if dragEndConnection then
								dragEndConnection:Disconnect()
								dragEndConnection = nil
							end
						end
					end)
				end
			end))

			Track(topbarobject.InputChanged:Connect(function(input)
				if destroyed or not allowDragging then return end
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					DragInput = input
				end
			end))

			Track(UIS.InputChanged:Connect(function(input)
				if not destroyed and allowDragging and input == DragInput and Dragging then
					Update(input)
				end
			end))

			function funcs:SetAllowDragging(state)
				allowDragging = state == true
				if not allowDragging then Dragging = false end
			end

			function funcs:Destroy()
				if destroyed then return end
				destroyed = true
				Dragging = false
				if dragEndConnection then dragEndConnection:Disconnect(); dragEndConnection = nil end
				for _, connection in ipairs(connections) do
					connection:Disconnect()
				end
				table.clear(connections)
			end

			return funcs
		end

