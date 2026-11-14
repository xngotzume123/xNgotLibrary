--[[ xngot-studio · src/modules/40_window/220_window_actions.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.actions
     role   : SelectTab(index), OpenUISettings, Divider
     source : main 2.txt L14284-14309 · 26 dòng · delta +0
--]]
			function Window:SelectTab(index)
				local tabtarget
				if type(index) == "string" then
					tabtarget = TabLists[index]
				else
					tabtarget = UserTabIndexList[tonumber(index)]
				end
				if tabtarget then
					SelectTab(tabtarget.Name)
					return true
				end
				return false
			end

			function Window:OpenUISettings()
				return Window:SelectTab(Window.SettingsTitle)
			end

			function Window:Divider()
				local newDivier = Templates.Divider:Clone()
				newDivier.LayoutOrder = (#UserTabIndexList * 10) + 5
				newDivier.Parent = newWindow.TabButtons.Lists
				newDivier.Visible = true
				return newDivier
			end

