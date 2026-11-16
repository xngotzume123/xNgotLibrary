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


local function last() return Cross.Chat[#Cross.Chat].Text end
assert(Cross.Learning.State().Remember)
Cross.ask("bật bay cao");assert(Cross.Clarify and not Cross.Pending and #Cross.Learning.List()==0)
Cross.ask("bật Main Auto Farm");assert(Cross.Pending and not toggle.State and #Cross.Learning.List()==0)
Cross.ask("không");assert(not toggle.State and #Cross.Learning.List()==0)
Cross.ask("bật bay cao");Cross.ask("bật Main Auto Farm");Cross.ask("có")
assert(toggle.State and Cross.Learning.Find("bat bay cao") and Cross.Learning.Preferences()[1].count==1)
-- New instance, same player and filesystem: reload learned phrase and preferences.
-- __INSERT_RELOAD_CODE__
assert(Cross.Learning.Find("bat bay cao") and Cross.Learning.Preferences()[1].count==1)
toggle:Set(false);Cross.ask("bật bay cao");assert(Cross.Pending and not toggle.State and last():find("câu đã học"));Cross.ask("có");assert(toggle.State)
Cross.ask("tắt bay cao");assert(Cross.Clarify);Cross.ask("tắt Main Auto Farm");Cross.ask("có")
assert(not toggle.State and Cross.Learning.Find("tat bay cao"))
-- Contradictory clarification must not teach the initial phrase.
toggle:Set(true);Cross.ask("bật cất cánh");Cross.ask("tắt Main Auto Farm");Cross.ask("yes");assert(not toggle.State and not Cross.Learning.Find("bat cat canh"))
-- Sensitive text and arbitrary input values are not auto-saved as learned phrases.
Cross.ask("bật token bí mật");assert(Cross.Clarify and not Cross.Clarify.Phrase)
Cross.ask("bật Main Auto Farm");Cross.ask("yes");assert(toggle.State and not Cross.Learning.Find("bat token bi mat"))
local before=#Cross.Learning.List();Cross.ask('đổi Nickname "my password"');Cross.ask("yes");assert(input.Text=="my password" and #Cross.Learning.List()==before)
Cross.ask("tắt Main Auto Farm");assert(Cross.Pending);Cross.Perm.Ui=false;Cross.ask("yes");assert(toggle.State);Cross.Perm.Ui=true
Cross.ask("gợi ý");assert(last():find("Auto Farm"))
Cross.ask("bật lạ mới");assert(Cross.Clarify);Cross.ask("không");assert(not Cross.Clarify)
print("PASS automatic learning, clarification, confirmation, persistence and sensitive input exclusions")
