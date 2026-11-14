--[[ xngot-studio · src/modules/40_window/110_el_section.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_section
     role   : Tab:Section
     source : main 2.txt L12422-12488 · 67 dòng · delta +0
--]]
				function Tab:Section(data)
					data = data or {}
					local Section = {
						Title = data.Title or "Section",
						State = data.Default or false,
						TextXAlignment = Enum.TextXAlignment[data.TextXAlignment or "Left"] and (data.TextXAlignment or "Left") or "Left",
					}

					local newSection = Templates.Section:Clone()
					newSection.Name = Section.Title
					newSection.Button.Title.Text = Section.Title
					newSection.Button.Title.TextXAlignment = Enum.TextXAlignment[Section.TextXAlignment] or Enum.TextXAlignment.Left

					newSection.Visible = true
					newSection.Parent = newTab
					newSection.Frame.Visible = Section.State
					newSection.Button.Title.Arrow.Rotation = Section.State and 90 or 0

					newSection.Button.MouseButton1Click:Connect(function()
						if Section.State == true then

							newSection.Frame.Visible = false
							Tween(newSection.Button.Title.Arrow, {Rotation = 0}, TweenConfigs.Global)
							Section.State = false
						elseif Section.State == false then

							newSection.Frame.Visible = true
							Tween(newSection.Button.Title.Arrow, {Rotation = 90}, TweenConfigs.Global)
							Section.State = true
						end
					end)

					function Section:SetTitle(newTitle)
						Section.Title = tostring(newTitle or "Section")
						newSection.Name = Section.Title
						newSection.Button.Title.Text = Section.Title
					end

					function Section:SetOpen(state)
						Section.State = state == true
						newSection.Frame.Visible = Section.State
						Tween(newSection.Button.Title.Arrow, {Rotation = Section.State and 90 or 0}, TweenConfigs.Global)
						return Section.State
					end

					function Section:Toggle()
						return Section:SetOpen(not Section.State)
					end

					function Section:Destroy()
						if parentElement == newSection.Frame then
							parentElement = newTab
						end
						newSection:Destroy()
					end

					Section._Container = newSection.Frame
					Section._Tab = Tab
					function Section:_Use(methodName, elementData)
						return Tab:_Use(methodName, elementData, newSection.Frame)
					end

					parentElement = newSection.Frame

					return Section
				end

