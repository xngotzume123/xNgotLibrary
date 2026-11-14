--[[ xngot-studio · src/modules/20_lib/100_tween.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.tween
     role   : Hàm Tween() bọc TweenService
     source : main 2.txt L2505-2511 · 7 dòng · delta +0
--]]
		local function Tween(inst, props, config)
			local twconfig = TweenInfo.new(config.Duration, config.EasingStyle or Enum.EasingStyle.Linear, config.EasingDirection or Enum.EasingDirection.Out)
			local tw = game:GetService("TweenService"):Create(inst, twconfig, props)
			tw:Play()
			return tw
		end

