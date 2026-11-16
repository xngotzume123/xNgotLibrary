local Cross={Enabled=true,Chat={},Perm={Ui=true}}
function Cross.say(role,text) table.insert(Cross.Chat,{Role=role,Text=text}) end
function Cross.setEnabled(on) Cross.Enabled=on end
function Cross.setMood() end
function Cross.ask(p) Cross.say("cross","fallback:"..p) end
local root={}
local function obj(data)
 data._AIInstance={alive=true}; function data._AIInstance:IsDescendantOf(r) return self.alive and r==root end
 return data
end
local toggle=obj({State=false,Locked=false}); function toggle:Set(v) self.State=v end
local slider=obj({Value=10,Locked=false}); function slider:Set(v) self.Value=v; return v end
local dropdown=obj({Values={"Normal","Fast","Slow"}, Value="Normal",Locked=false}); function dropdown:Select(v) self.Value=v; return v end
local multi=obj({Values={"Red","Blue"},Value={"Red"},Multi=true,AllowNone=false}); function multi:Select(v) local i=table.find(self.Value,v);if i then table.remove(self.Value,i) else table.insert(self.Value,v) end;return self.Value end
local button=obj({Locked=false,count=0}); function button:_AIIsLocked() return self.Locked end; function button:_AIActivate() self.count+=1; return true end
local section=obj({State=false}); function section:SetOpen(v) self.State=v end
local input=obj({Text=""}); function input:Set(v) self.Text=v end
local color=obj({}); function color:Set(v) self.Value=v end
local paragraph=obj({}); function paragraph:SetDesc(v) self.Desc=v end
local code=obj({}); function code:SetCode(v) self.Code=v end
local info=obj({}); function info:SetBio(v) self.Bio=v end
local discord=obj({}); function discord:SetInvite(v,c) self.link=v; self.code=c end
local entries={}
local function add(kind,title,tab,o) local e={Kind=kind,Title=title,Tab=tab,Object=o,Root=root}; table.insert(entries,e); return e end
add("Toggle","Auto Farm","Main",toggle);local sl=add("Slider","Speed","Main",slider); sl.Min=0; sl.Max=100; sl.Step=5
add("Dropdown","Mode","Main",dropdown);add("Dropdown","Colors","Main",multi)
add("Button","Rejoin","Main",button);add("Section","Controls","Main",section);add("Input","Nickname","Main",input);add("Colorpicker","Accent","Main",color)
add("Paragraph","Status","Main",paragraph);add("Code","Example","Main",code);add("InfoNguyenNhat","Developer","Main",info);add("Discord","Community","Main",discord)
local __hostWindow={_AIControls=entries}
-- __INSERT_AI_CODE__

local function last() return Cross.Chat[#Cross.Chat].Text end
local function ask(p) Cross.ask(p) end
ask("bật auto farm");assert(not toggle.State and Cross.Pending and last():find("Auto Farm"));ask("có");assert(toggle.State and not Cross.Pending)
ask("tắt AUTO FARM");ask("không");assert(toggle.State and not Cross.Pending)
ask("tắt Auto Farm");Cross.Perm.Ui=false;ask("yes");assert(toggle.State and last():find("Quyền"));Cross.Perm.Ui=true
ask("đừng bật Auto Farm");assert(not Cross.Pending)
ask("tắt Auto Farm");toggle.Locked=true;ask("yes");assert(toggle.State and last():find("khóa"));toggle.Locked=false
ask("đặt tốc độ 57"); assert(Cross.Pending.Value==55 and slider.Value==10);ask("yes");assert(slider.Value==55)
ask("đặt Speed 200");assert(not Cross.Pending and last():find("khoảng"))
ask('chọn Mode "Fast"');assert(Cross.Pending and dropdown.Value=="Normal");ask("yes");assert(dropdown.Value=="Fast")
ask('chọn Colors "Blue"');ask("yes");assert(table.find(multi.Value,"Blue"))
ask('chọn Colors "Blue"');assert(not Cross.Pending)
ask('bỏ Colors "Red"');ask("yes");assert(not table.find(multi.Value,"Red"))
ask('bỏ Colors "Blue"');assert(not Cross.Pending)
ask("bấm Rejoin");assert(button.count==0);ask("yes");assert(button.count==1)
ask("bật Controls");ask("yes");assert(section.State)
ask('đổi Nickname "Hana"');ask("yes");assert(input.Text=="Hana")
ask('đổi Accent #66AAFF');ask("yes");assert(color.Value=="#66AAFF")
ask('đổi Status "Ready"');ask("yes");assert(paragraph.Desc=="Ready")
ask('đổi Example "print hi"');ask("yes");assert(code.Code=="print hi")
ask('đổi Developer "Hello"');ask("yes");assert(info.Bio=="Hello")
ask('đổi Community "discord.gg/abc"');ask("yes");assert(discord.code=="abc")
ask("bấm Rejoin");button._AIInstance.alive=false;ask("yes");assert(button.count==1 and last():find("không còn"))
local b2=obj({State=false}); function b2:Set(v)self.State=v end;add("Toggle","Auto Farm","Other",b2)
ask("tắt Auto Farm");assert(not Cross.Pending and last():find("trùng tên"));ask("tắt Main Auto Farm");ask("yes");assert(not toggle.State)
ask("bật Auto Farm Other");assert(Cross.Pending);Cross.Pending.Expires=-1;ask("yes");assert(not b2.State and last():find("hết hạn"))
ask("danh sách chức năng");assert(last():find("Auto Farm"))
local island=obj({State=true});function island:Set(v) self.State=v end;add("Toggle","Enable Dynamic Island","System",island)
ask("tắt Enable Dynamic Island");assert(Cross.Pending and Cross.Pending.Value==false);ask("yes");assert(not island.State)
local music=obj({State=true}); function music:SetOpen(v) self.State=v end;add("Section","Music","Dynamic Island",music)
ask("play music");assert(last():find("fallback") and music.State)
ask('chọn Mode "Slow"');assert(Cross.Pending);dropdown.Values={"Normal","Fast"};ask("yes");assert(dropdown.Value=="Fast" and last():find("đổi"))
ask("weather tomorrow");assert(last():find("fallback"))
print("PASS smart control assistant: 11 control types, confirm/cancel, ambiguity, stale, locking and fallback")
