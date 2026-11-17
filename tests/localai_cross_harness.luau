local files,encoded={},{};local serial=0
local function clone(x)if type(x)~="table" then return x end local r={} for k,v in pairs(x) do r[k]=clone(v)end return r end
local isfile=function(p)return files[p]~=nil end
local readfile=function(p)return files[p]end
local writefile=function(p,v)files[p]=v end
local delfile=function(p)files[p]=nil end
local makefolder=function()end
local http={JSONEncode=function(_,x)serial+=1;local k="file"..serial;encoded[k]=clone(x);return k end,JSONDecode=function(_,x)assert(encoded[x]);return clone(encoded[x])end}
local connection,heartbeatCallback
local game={GetService=function(_,n) if n=="HttpService" then return http elseif n=="Players" then return {LocalPlayer={UserId=44}} elseif n=="RunService" then return {Heartbeat={Connect=function(_,f) heartbeatCallback=f;connection={Disconnect=function()heartbeatCallback=nil end};return connection end}} end error(n) end}
local root={};local toggle={State=false,Locked=false,_AIInstance={IsDescendantOf=function(_,r)return r==root end}}
function toggle:Set(v)self.State=v end
local button={count=0,_AIInstance={IsDescendantOf=function(_,r)return r==root end}};function button:_AIActivate()self.count+=1;return true end
local sub,selected
local api={OnMusicChanged=function(_,fn)sub=fn;return function()sub=nil end end,State=function()return {FPS=60,Ping=80,Playing=false,Cross=true}end,
 MusicFiles=function()return {{Title="Gentle Song",Artist="Singer",Path="a.mp3"}} end,MusicCatalog=function()return {}end,MusicPlayCachedFile=function()return true,"cached requested" end}
local __hostWindow={DynamicIsland=api,_AIControls={{Tab="Main",Title="Auto Farm",Kind="Toggle",Object=toggle,Root=root},{Tab="Main",Title="Collect",Kind="Button",Object=button,Root=root,MacroAllowed=true}}}
function __hostWindow:Tab()error("V2 must not create a tab")end
function __hostWindow:SelectTab(n)selected=n;return n=="Main"end
function __hostWindow:NotifyIsland()return true end
local Cross={Enabled=true,Chat={},Perm={Ui=true}}
local Settings={Language="vi"}
function Cross.say(role,text)table.insert(Cross.Chat,{Role=role,Text=text})end
function Cross.setEnabled(on)Cross.Enabled=on end
function Cross.setMood()end
function Cross.ask(p)Cross.say("cross","fallback:"..p)end
-- __INSERT_ENGINE_CODE__
-- __INSERT_MOVEMENT_CODE__
-- __INSERT_MOUNT_CODE__
local ai=__xNgotMountLocalAI(__hostWindow);assert(ai and ai.Memory.Data.enabled and files[ai.Memory.Path] and sub and heartbeatCallback)
-- __INSERT_CROSS_CODE__
local function ask(t) Cross.ask(t);return Cross.Chat[#Cross.Chat].Text end
assert(ask("giải thích Main Auto Farm"):find("bật hoặc tắt"))
assert(ask("giai thich Main Auto Farm"):find("bật hoặc tắt"))
assert(ask("performance"):find("Samples") and Cross.Lang=="en")
assert(ask("hieu suat"):find("Số mẫu") and Cross.Lang=="vi")
assert(ask("tạo macro test: bật Missing"):find("Không tìm thấy"))
assert(ask("chẩn đoán"):find("control"));assert(ask("fps ping"):find("FPS"))
ask("mở tab Main");assert(selected=="Main")
ask("bật Main Auto Farm");assert(Cross.Pending and not toggle.State);ask("có");assert(toggle.State and not Cross.Pending)
ask("tắt Main Auto Farm rồi bật Main Auto Farm");assert(ai.Pending and not Cross.Pending and toggle.State)
ask("có");assert(not toggle.State and ai.Pending)
ask("tạm dừng macro");assert(ai.Macro.Active and ai.Macro.Active.paused and not ai.Pending)
ask("tiếp tục macro");assert(ai.Pending);Cross.Perm.Ui=false;assert(ask("có"):find("hủy") and not ai.Pending and not toggle.State);Cross.Perm.Ui=true
ask("tạo macro test: bật Main Auto Farm; bấm Main Collect");assert(#ai.Memory.Data.macros==1)
ask("chạy macro test");ask("có");assert(toggle.State and ai.Pending);ask("không");assert(not ai.Pending and button.count==0)
ask("favorite gentle song");assert(#ai.Memory.Data.favorites==1)
ask("thêm gentle song vào playlist chill");assert(#ai.Memory.Data.playlists==1);assert(ask("phát playlist chill"):find("Đã yêu cầu phát"))
assert(ask("play music lofi"):find("fallback"))
assert(ai.Learning.Put("dung canh tac","tat Main Auto Farm"));ask("dung canh tac");assert(ai.Pending);ask("có");assert(not toggle.State)
assert(ask("unknown weather"):find("fallback"))
ai:Destroy();assert(not sub and not heartbeatCallback)
local saved=clone(encoded[files[ai.Memory.Path]]);saved.enabled=false;encoded["old-disabled"]=saved;files[ai.Memory.Path]="old-disabled"
local previous=__xNgotMountLocalAI(__hostWindow);assert(not previous.Memory.Data.enabled and files[ai.Memory.Path]=="old-disabled");previous:Destroy()
files[ai.Memory.Path]="corrupt-file";local damaged=__xNgotMountLocalAI(__hostWindow);assert(damaged.Memory.Blocked and files[ai.Memory.Path]=="corrupt-file");damaged:Destroy()
print("PASS single Cross UI integration, automatic local memory, sequence confirmation, permissions, music and legacy fallback")
