--[[ xngot-studio · src/modules/30_overlay/132_view_layout.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.view_layout
     role   : View.available + layoutDock (dàn nút theo bề rộng)
     source : main 2.txt L9825-9890 · 66 dòng · delta +0
--]]
		        function View.available()
		            local list = {}
		            for _, key in ipairs(PAGE_ORDER) do
		                if key == "Home" or key == "Music" or (key == "Cross" and Cross.Enabled) or Activities[key] then
		                    list[#list + 1] = key
		                end
		            end
		            return list
		        end

		        function View.layoutDock(instant)
		            local list = View.available()
		            local textWidths, textSum = {}, 0
		            for _, name in ipairs(list) do
		                local measured = math.ceil(TextService:GetTextSize(View.Tabs[name].Text, 11, Enum.Font.GothamSemibold, Vector2.new(200, 20)).X)
		                textWidths[name] = measured
		                textSum = textSum + measured
		            end
		            local pad = 20
		            local room = PAGE_W - 24 - 2 * math.max(#list - 1, 0)
		            if textSum + pad * #list > room then
		                pad = math.max(6, math.floor((room - textSum) / math.max(#list, 1)))
		            end
		            local x = 3
		            local focus
		            for _, key in ipairs(PAGE_ORDER) do
		                local tab = View.Tabs[key]
		                local shown = false
		                for _, name in ipairs(list) do
		                    if name == key then
		                        shown = true
		                    end
		                end
		                tab.Visible = shown
		                if shown then
		                    local width = textWidths[key] + pad
		                    tab.Position = UDim2.fromOffset(x, 3)
		                    tab.Size = UDim2.fromOffset(width, 24)
		                    if key == View.Current then
		                        focus = { X = x, W = width }
		                    end
		                    local color = key == View.Current and Static.White or Static.LightGray
		                    if instant then
		                        tab.TextColor3 = color
		                    else
		                        tween(tab, 0.2, { TextColor3 = color })
		                    end
		                    x = x + width + 2
		                end
		            end
		            local total = x + 1
		            if instant then
		                View.dock.Size = UDim2.fromOffset(total, 30)
		            else
		                tween(View.dock, 0.28, { Size = UDim2.fromOffset(total, 30) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		            end
		            if focus then
		                if instant then
		                    View.thumb.Position = UDim2.fromOffset(focus.X, 3)
		                    View.thumb.Size = UDim2.fromOffset(focus.W, 24)
		                else
		                    tween(View.thumb, 0.32, { Position = UDim2.fromOffset(focus.X, 3), Size = UDim2.fromOffset(focus.W, 24) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		                end
		            end
		        end

