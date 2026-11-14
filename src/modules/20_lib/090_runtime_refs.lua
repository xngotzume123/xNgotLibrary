--[[ xngot-studio · src/modules/20_lib/090_runtime_refs.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.runtime
     role   : Tham chiếu service, Gui/Templates cũ, bảng TweenConfigs
     source : main 2.txt L2471-2504 · 34 dòng · delta +0
--]]

		local UIS = game:GetService("UserInputService")

		local Gui = script.Parent
		local Templates = script.Parent.Templates
		local oldWindow = script.Parent.Window
		local oldFloatingIcon = script.Parent.FloatIcon

		Templates.Parent = nil
		oldWindow.Parent = nil
		oldFloatingIcon.Parent = nil

		local TweenConfigs = {
			Global = {
				Duration = 0.25,
				EasingStyle = Enum.EasingStyle.Quart,
				EasingDirection = Enum.EasingDirection.Out
			},
			Notification = {
				Duration = 0.5,
				EasingStyle = Enum.EasingStyle.Back,
				EasingDirection = Enum.EasingDirection.Out
			},
			PopupOpen = {
				Duration = 0.4,
				EasingStyle = Enum.EasingStyle.Back,
				EasingDirection = Enum.EasingDirection.Out
			},
			PopupClose = {
				Duration = 0.4,
				EasingStyle = Enum.EasingStyle.Back,
				EasingDirection = Enum.EasingDirection.In
			},
		}
