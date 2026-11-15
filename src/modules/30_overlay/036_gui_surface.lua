--[[ xngot-studio · src/modules/30_overlay/036_gui_surface.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.surface
     role   : GUI nổi: frame gốc + BlurEffect của island
     source : main 2.txt L3846-3894 · 49 dòng · delta +0
--]]
		    local gui = new("Frame", {
		        Name = "xNgotStudio_FullDynamicIsland",
		        BackgroundTransparency = 1,
		        BorderSizePixel = 0,
		        Position = UDim2.fromScale(0, 0),
		        Size = UDim2.fromScale(1, 1),
		        ZIndex = 100,
		        Visible = false,  
		        Parent = __hostGui,
		    })

		    local blur = new("BlurEffect", { Name = "xNgotStudio_FullIslandBlur", Size = 0, Parent = Lighting })

		    Fwd.applyLanguage = function()
		        for _, item in ipairs(gui:GetDescendants()) do
		            if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then
		                if not item:GetAttribute("BoncutiRaw") then
		                    local translationKey = item:GetAttribute("BoncutiTranslationKey")
		                    if translationKey then
		                        item.Text = string.upper(translate(translationKey))
		                    else
		                        item.Text = translate(item.Text)
		                    end
		                end
		                if item:IsA("TextBox") then
		                    item.PlaceholderText = translate(item.PlaceholderText)
		                end
		            end
		        end
		        if Fwd.musicLanguage then
		            Fwd.musicLanguage()
		        end
		        if Fwd.afkLanguage then
		            Fwd.afkLanguage()
		        end
		        if Fwd.discordLanguage then
		            Fwd.discordLanguage()
		        end
		    end

		    gui.Destroying:Connect(function()
		        for _, connection in ipairs(connections) do
		            connection:Disconnect()
		        end
		        table.clear(connections)
		        table.clear(activeSprings)
		        blur:Destroy()
		    end)

