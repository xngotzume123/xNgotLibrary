local Window={}; local NAMETAB="Main"; local newWindow={}
local Tab={}
for _,kind in ipairs({"Section", "Button", "Toggle", "Slider", "Input", "Dropdown", "Colorpicker", "Paragraph", "Code", "InfoNguyenNhat", "Discord"}) do
 Tab[kind]=function(self,data) local o={Title=(data and data.Title) or kind,Name=data and data.Name,_AIInstance={}};function o:SetTitle(v) self.Title=v end;function o:SetName(v)self.Name=v end;return o end
end
-- __INSERT_REGISTRY_CODE__

local a=Tab:Toggle({Title="Farm"});local b=Tab:Slider({Title="Speed",Value={Min=0,Max=100},Step=5});local c=Tab:Button({Title="Reset"});Tab:Input({Title="Hidden",AIControl=false});local info=Tab:InfoNguyenNhat({Name="Person"})
assert(#Window._AIControls==4)
assert(Window._AIControls[1].Kind=="Toggle" and Window._AIControls[2].Kind=="Slider" and Window._AIControls[3].Kind=="Button")
assert(Window._AIControls[2].Step==5);a:SetTitle("New Farm");assert(Window._AIControls[1].Title=="New Farm")
info:SetName("Alice");assert(Window._AIControls[4].Title=="Alice")
print("PASS tab control registry, kind capture, exclusion, slider ranges and rename")
