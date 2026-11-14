--[[ xngot-studio · src/modules/45_notify/010_notify.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/45_notify · thông báo dạng thẻ (LIB:Notify)
     module : notify
     role   : LIB:Notify - thẻ thông báo, icon, duration, tự đóng
     source : main 2.txt L17213-17280 · 68 dòng · delta +0
--]]
		function LIB:Notify(data)
			data = data or {}
			if data.Native ~= true and self.ActiveDynamicIsland and self.ActiveDynamicIsland.Enabled then
				local api = self.ActiveDynamicIsland
				local kind = data.Kind or "info"
				if data.Icon == "circle-check" or data.Icon == "check" then kind = "success" end
				if data.Icon == "triangle-alert" then kind = "warn" end
				local ok, handled = pcall(api.Notify, api,
					tostring(data.Title or "Notification"), tostring(data.Content or ""),
					kind, tonumber(data.Duration) or 4)
				if ok and handled then return {Close = function() end} end
			end
			local Notification = {}

			local Notif = {
				Title = tostring(data.Title or "Notification"),
				Content = tostring(data.Content or ""),
				Icon = data.Icon or "info",
				Duration = math.max(0.1, tonumber(data.Duration) or 5)
			}

			local new = Templates.Notification:Clone()

			local notificationParent = Gui.NotificationList
			for i = #Windows, 1, -1 do
				local win = Windows[i]
				if win and win.Parent and win.Visible and win.Tabs.Visible then
					notificationParent = win.NotificationFrame.NotificationList
					break
				end
			end
			new.Parent = notificationParent
			new.Items.Frame.Title.Text = Notif.Title
			new.Items.Frame.Content.Text = Notif.Content

			ApplyIcon(new.Items.Frame.Title.Icon, Notif.Icon)

			new.Items.Position = UDim2.new(0.75, 0, 0, 0)
			new.Visible = true

			local closing = false
			local function Close()
				if new and not closing then
					closing = true
					local close = Tween(new.Items, {Position = UDim2.new(0.75,0,0,0)}, TweenConfigs.Notification)
					task.wait(TweenConfigs.Notification.Duration - (TweenConfigs.Notification.Duration / 2))
					if new then
						new:Destroy()
					end
					new = nil
				end
			end

			new.Items.Frame.Title.Close.MouseButton1Click:Connect(Close)

			local open = Tween(new.Items, {Position = UDim2.new(0,0,0,0)}, TweenConfigs.Notification)
			open.Completed:Connect(function()
				Tween(new.Items.TimerBarFill.Bar, {Size = UDim2.new(0,0,1,0)}, {Duration = Notif.Duration})
				task.delay(Notif.Duration, Close)
			end)

			function Notification:Close()
				Close()
			end

			return Notification
		end

