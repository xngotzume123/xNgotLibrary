--[[ xngot-studio · src/modules/40_window/140_el_paragraph.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/40_window · Window / Tab / element builder + Settings tab
     module : window.el_paragraph
     role   : Tab:Paragraph
     source : main 2.txt L12668-12711 · 44 dòng · delta +0
--]]
				function Tab:Paragraph(data)
					data = data or {}
					local Paragraph = {
						Title = data.Title or "Paragraph",
						Desc = data.Desc,
						RichText = data.RichText or false,
					}

					local newParagraph = Templates.Paragraph:Clone()
					newParagraph.Name = Paragraph.Title
					newParagraph.Parent = parentElement
					newParagraph.Title.Text = Paragraph.Title

					if Paragraph.Desc and Paragraph.Desc ~= "" then
						newParagraph.Description.Text = Paragraph.Desc
						newParagraph.Description.Visible = true
					else
						newParagraph.Description.Visible = false
					end

					newParagraph.Title.RichText = Paragraph.RichText
					newParagraph.Description.RichText = Paragraph.RichText

					newParagraph.Visible = true

					function Paragraph:SetTitle(title)
						Paragraph.Title = tostring(title or "Paragraph")
						newParagraph.Name = Paragraph.Title
						newParagraph.Title.Text = Paragraph.Title
					end

					function Paragraph:SetDesc(desc)
						Paragraph.Desc = desc or ""
						newParagraph.Description.Text = Paragraph.Desc
						newParagraph.Description.Visible = Paragraph.Desc ~= ""
					end

					function Paragraph:Destroy()
						newParagraph:Destroy()
					end

					return Paragraph
				end

