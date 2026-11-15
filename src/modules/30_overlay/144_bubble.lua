--[[ xngot-studio · src/modules/30_overlay/144_bubble.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/30_overlay · bảng nổi: thông báo, hoạt động, hẹn giờ, nhạc, Cross AI, API công khai
     module : overlay.bubble
     role   : Bong bóng thu nhỏ: secondaryKey, bubble, tự thu sau idle
     source : main 2.txt L10348-10443 · 96 dòng · delta -1
--]]
		        local function secondaryKey()
		            for _, key in ipairs(ACTIVITY_ORDER) do
		                if key ~= Island.Key and Activities[key] then
		                    return key
		                end
		            end
		        end

		        Fwd.islandSync = function()
		            local live = Island.Live
		            if not Island.Alerting and not Island.Expanded then
		                if live then
		                    tween(Isl.tint, 0.4, { BackgroundColor3 = live.Color, BackgroundTransparency = 0 })
		                else
		                    tween(Isl.tint, 0.4, { BackgroundTransparency = 1 })
		                end
		            end
		            local key = secondaryKey()
		            local show = key ~= nil and Settings.Split and State.Ready and live ~= nil and not Island.Alerting and not Island.Expanded
		            if show then
		                Island.BubbleKey = key
		                Isl.bubbleRing.Color = Activities[key].Color
		                View.BubbleText = ""
		                Isl.bubble.Visible = true
		                Isl.bubbleTo(1)
		            else
		                Island.BubbleKey = nil
		                Isl.bubbleTo(0)
		            end
		            if Island.Expanded then
		                View.refresh()
		            end
		        end

		        Fwd.islandLayout = function(scale, shift)
		            local pop = math.max(islandState.Bubble, 0)
		            local size = ISLAND.Bubble
		            local center = shift + islandState.W * scale / 2 + (ISLAND.Gap + size * islandState.Base / 2) * math.min(pop, 1.1)
		            Isl.bubble.Position = UDim2.new(0.5, center, 0, islandState.Y + islandState.H * scale / 2)
		            Isl.bubbleScale.Scale = math.max(islandState.Base * pop, 0.01)
		            local visible = pop > 0.02
		            if Isl.bubble.Visible ~= visible then
		                Isl.bubble.Visible = visible
		            end
		        end

		        Isl.bubbleHit.MouseButton1Click:Connect(function()
		            if Island.BubbleKey and Activities[Island.BubbleKey] then
		                playSound("click")
		                Island.Pin = Island.BubbleKey
		                refreshActivity()
		            end
		        end)

		        Hooks.Register(function()
		            if Settings.RimLight then
		                Isl.rimGradient.Rotation = (os.clock() * 55) % 360
		            elseif Isl.rimGradient.Rotation ~= 90 then
		                Isl.rimGradient.Rotation = 90
		            end
		            local stamp = os.clock()
		            if islandState.Bubble > 0.05 and Island.BubbleKey and stamp - View.BubbleAt > 0.1 then
		                View.BubbleAt = stamp
		                local activity = Activities[Island.BubbleKey]
		                if activity then
		                    local value = tostring((activity.Short or activity.Value)() or "")
		                     
		                     
		                    do
		                        local charCount = utf8.len(value) or #value
		                        if charCount > 5 then
		                            local okPos, pos = pcall(function() return utf8.offset(value, 6) end)
		                            if okPos and type(pos) == "number" then
		                                value = value:sub(1, pos - 1):gsub("%s+$", "") .. "…"
		                            else
		                                value = value:sub(1, 5) .. "…"
		                            end
		                        end
		                    end
		                    if value ~= View.BubbleText then
		                        View.BubbleText = value
		                        Isl.bubbleText.Text = value
		                        Isl.bubbleText.TextSize = #value <= 3 and 12 or (#value == 4 and 11 or 10)
		                    end
		                end
		            end
		            if not Island.Expanded then
		                return
		            end
		            View.tick()
		            if os.clock() - View.Touched > IDLE_COLLAPSE then
		                Isl.collapse()
		            end
		        end, 1)
		    end

