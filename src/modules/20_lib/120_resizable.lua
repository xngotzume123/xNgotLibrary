--[[ xngot-studio · src/modules/20_lib/120_resizable.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.resizable
     role   : Kéo góc để đổi kích thước cửa sổ
     source : main 2.txt L2592-2663 · 72 dòng · delta +0
--]]
		local function Resizable(handle, object, minSize, maxSize)
			local Mouse = game.Players.LocalPlayer:GetMouse()
			local funcs = {}
			local allowResizing = true
			local resizing = false
			local destroyed = false
			local connections = {}

			local function Track(connection)
				table.insert(connections, connection)
				return connection
			end

			local function Resize()
				if destroyed or not allowResizing or resizing then return end
				resizing = true
				local dragStartX, dragStartY = Mouse.X, Mouse.Y
				local startSize = object.Size

				repeat
					task.wait()
					if allowResizing and not destroyed and object.Parent then
						local deltaX = Mouse.X - dragStartX
						local deltaY = Mouse.Y - dragStartY
						local newX = math.clamp(startSize.X.Offset + deltaX, minSize.X, maxSize.X)
						local newY = math.clamp(startSize.Y.Offset + deltaY, minSize.Y, maxSize.Y)
						object.Size = UDim2.fromOffset(newX, newY)
					end
				until not resizing or not allowResizing or destroyed
			end

			Track(handle.InputBegan:Connect(function(input)
				if destroyed or not allowResizing then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					task.spawn(Resize)
				end
			end))

			Track(UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					resizing = false
				end
			end))

			function funcs:SetAllowResizing(state)
				allowResizing = state == true
				if not allowResizing then resizing = false end
			end

			function funcs:SetMinSize(size)
				if typeof(size) == "Vector2" then minSize = size end
			end

			function funcs:SetMaxSize(size)
				if typeof(size) == "Vector2" then maxSize = size end
			end

			function funcs:Destroy()
				if destroyed then return end
				destroyed = true
				resizing = false
				for _, connection in ipairs(connections) do
					connection:Disconnect()
				end
				table.clear(connections)
			end

			return funcs
		end

		local HttpService = game:GetService("HttpService")

