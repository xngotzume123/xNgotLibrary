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
local player={UserId=123}
local files={};local store={};local count=0
local function clone(v) if type(v)~="table" then return v end local t={} for k,x in pairs(v) do t[k]=clone(x) end return t end
local http={};function http:JSONEncode(v) count+=1;local key="JSON"..count;store[key]=clone(v);return key end
function http:JSONDecode(v) if not store[v] then error("bad json") end;return clone(store[v]) end
local game={};function game:GetService(_) return http end
local function isfile(p)return files[p]~=nil end
local function readfile(p)return files[p] end
local function writefile(p,v)files[p]=v end
-- __INSERT_LEARNING_CODE__
-- __INSERT_AI_CODE__

local function last()return Cross.Chat[#Cross.Chat].Text end
local fps=obj({State=false,Locked=false});function fps:Set(v)self.State=v end
add("Toggle","Show FPS","Dynamic Island",fps)
local fpsOk=Cross.Teach("show fps please","bật Dynamic Island Show FPS");assert(fpsOk and not fps.State)
Cross.ask("show fps please");assert(Cross.Pending and not fps.State);Cross.ask("yes");assert(fps.State)
local success,msg=Cross.Teach("farm please","bật Main Auto Farm");assert(success and msg:find("Auto Farm") and not toggle.State and not Cross.Pending)
assert(not Cross.Teach("yes","bật Main Auto Farm"))
assert(not Cross.Teach("bad","something unknown"))
assert(not Cross.Teach("ambiguous", "Main Auto Farm"))
Cross.ask("farm please");assert(not toggle.State and Cross.Pending and last():find("câu đã học"));Cross.ask("no");assert(not toggle.State)
assert(Cross.Learning.SetRemember(true))
Cross.ask("farm please");assert(not toggle.State);Cross.ask("yes");assert(toggle.State and Cross.Learning.Preferences()[1].count==1)
Cross.ask("farm please");assert(not Cross.Pending and last():find("trạng thái"))
assert(Cross.Teach("farm again","bật Main Auto Farm"))
Cross.ask("gợi ý");assert(last():find("Auto Farm"))
Cross.ask("danh sách đã học");assert(last():find("farm please"))
toggle:Set(false);Cross.ask("farm please");assert(Cross.Pending);assert(Cross.ForgetPhrase("farm please"));assert(not Cross.Pending)
Cross.ask("farm please");assert(last():find("fallback"))
Cross.ask("farm again");assert(Cross.Pending);Cross.Perm.Ui=false;Cross.ask("yes");assert(not toggle.State and last():find("Quyền"));Cross.Perm.Ui=true
local record=Cross.Learning.List()[1];record.command="tampered";assert(Cross.Learning.List()[1].command~="tampered")
print("PASS legacy teaching, confirmation, automatic preferences, suggestions, forget and permissions")
