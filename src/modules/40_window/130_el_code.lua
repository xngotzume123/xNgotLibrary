--[[ xngot-studio · src/modules/40_window/130_el_code.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_code
     role   : Tab:Code
     source : main 2.txt L12632-12667 · 36 dòng · delta +0
--]]
				function Tab:Code(data)
					data = data or {}
					local Code = {
						Title = data.Title or "Code",
						Code = data.Code or ""
					}

					local newCode = Templates.Code:Clone()
					newCode.Name = Code.Title
					newCode.Parent = parentElement

					newCode.Title.Text = Code.Title
					newCode.Code.Text  = Code.Code
					newCode.Code.Visible = true
					newCode.Code.Font = Enum.Font.Code

					newCode.Visible = true

					function Code:SetTitle(newText)
						Code.Title = tostring(newText or "Code")
						newCode.Name = Code.Title
						newCode.Title.Text = Code.Title
					end

					function Code:SetCode(code)
						Code.Code = tostring(code or "")
						newCode.Code.Text = Code.Code
					end

					function Code:Destroy()
						newCode:Destroy()
					end

					return Code
				end

