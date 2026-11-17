local files,encoded={},{};local seq=0
local function clone(x) if type(x)~="table" then return x end local r={} for k,v in pairs(x) do r[k]=clone(v) end return r end
local http={}
function http:JSONEncode(x) seq+=1;local key="encoded-"..seq;encoded[key]=clone(x);return key end
function http:JSONDecode(x) assert(encoded[x],"bad json");return clone(encoded[x]) end
local conn,cb;local heartbeat={Connect=function(_,f)cb=f;conn={Disconnect=function()cb=nil end};return conn end}
local game={GetService=function(_,name) assert(name=="RunService");return {Heartbeat=heartbeat} end}
local env={userId=42,http=http,isfile=function(p)return files[p]~=nil end,readfile=function(p)return files[p] end,writefile=function(p,v)files[p]=v end,delfile=function(p)files[p]=nil end,makefolder=function()end,game=game}
local selected,listener=nil,nil
local api={}
function api:State() return {FPS=25,Ping=250,Playing=true,MusicIndex=1} end
function api:MusicFiles() return {{Title="Gentle Song",Artist="Singer",Path="music/a.mp3"}} end
function api:MusicPlayCachedFile(path) selected=path;return true end
function api:MusicCatalog() return {{Index=1,Name="Gentle Song",Artist="Singer"}} end
function api:OnMusicChanged(fn) listener=fn;return function()listener=nil end end
local root={}; local toggle={State=false,Locked=false,_AIInstance={IsDescendantOf=function(_,r)return r==root end}}
function toggle:Set(v)self.State=v end
local button={count=0,_AIInstance={IsDescendantOf=function(_,r)return r==root end}}
function button:_AIIsLocked()return false end;function button:_AIActivate()self.count+=1;return true end
local window={DynamicIsland=api,_AIControls={{Kind="Toggle",Title="Auto Farm",Tab="Main",Root=root,Object=toggle},{Kind="Button",Title="Collect",Tab="Main",Root=root,Object=button,MacroAllowed=true}}}
function window:SelectTab(name) return name=="Main" end
-- __INSERT_ENGINE_CODE__
local ai=__xNgotCreateLocalAI(window,env)
assert(ai.NLP.Normalize("BẬT AUTO FARM")=="bat auto farm")
local navOk,nav=ai.Core.Ask("mở tab Main");assert(navOk and nav:find("Main") and not ai.Pending)
assert(not ai.Commands.Parse("đừng bật Main Auto Farm"))
assert(ai.Memory.SetEnabled(true))
local ok,msg=ai.Core.Ask("bật Main Auto Farm");assert(ok and ai.Pending and not toggle.State)
ai.Core.Ask("không");assert(not toggle.State and not ai.Pending)
ai.Core.Ask("bat Main Auto Farm");ai.Core.Ask("yes");assert(toggle.State)
assert(ai.Learning.Put("canh tac", "tắt Main Auto Farm"));assert(not ai.Learning.Put("canh tac", "bật Main Auto Farm"));assert(ai.Learning.Put("canh tac", "tắt Main Auto Farm",true))
ai.Core.Ask("canh tac");assert(ai.Pending and toggle.State);ai.Core.Ask("yes");assert(not toggle.State)
assert(not ai.Learning.Put("password abc", "bật Main Auto Farm"))
assert(ai.Macro.Save("vong farm",{"bật Main Auto Farm","bấm Main Collect"}))
assert(ai.Macro.Start("vong farm"));assert(ai.Pending and not toggle.State)
assert(ai.Macro.Pause());assert(not ai.Pending and ai.Macro.Active.paused and not toggle.State)
assert(ai.Macro.Resume());assert(ai.Pending);assert(ai.Core.Confirm(true));assert(toggle.State and ai.Pending and button.count==0)
assert(ai.Macro.Cancel());assert(not ai.Pending and button.count==0)
assert(ai.Macro.Start("vong farm"));assert(ai.Core.Confirm(true));assert(ai.Core.Confirm(true));assert(button.count==1 and not ai.Macro.Active)
assert(ai.Macro.Start("vong farm"));assert(ai.Core.Confirm(true));window._AIControls[2].MacroAllowed=false;assert(not ai.Core.Confirm(true) and button.count==1 and not ai.Macro.Active);window._AIControls[2].MacroAllowed=true
assert(not ai.Learning.Put("absent phrase","bat Main Auto Farm",true))
local origSet=toggle.Set;toggle.Set=function()return false end
local spec=assert(ai.Commands.Parse("bat Main Auto Farm"));assert(not ai.Commands.Execute(spec));toggle.Set=origSet
ai.Core.Ask("bat Main Auto Farm");local origObject=window._AIControls[1].Object;window._AIControls[1].Object={_AIInstance=toggle._AIInstance,Set=function()error("stale callback invoked")end};assert(not ai.Core.Confirm(true));window._AIControls[1].Object=origObject
local dup={Kind="Toggle",Title="Auto Farm",Tab="Main",Root=root,Object=toggle};table.insert(window._AIControls,dup);assert(not ai.Commands.Resolve(spec));table.remove(window._AIControls)
assert(ai.Music.Favorite("gentle song"));assert(ai.Music.Playlist("thu gian","gentle song"));assert(ai.Music.PlaylistPlay("thu gian",1));assert(selected=="music/a.mp3")
assert(ai.Music.ConnectHistory());listener();assert(#ai.Memory.Data.history==1);listener();assert(#ai.Memory.Data.history==1)
assert(ai.Performance.Analyze():find("Low FPS"));local warned=0;assert(ai.Performance.SetMonitor(true,function()warned+=1 end));for i=1,15 do cb(1) end;assert(warned==1)
assert(ai.Diagnostics.Report():find("not all callbacks"));assert(ai.Explainer.Describe("Auto Farm"):find("Toggle"))
local reloaded=__xNgotCreateLocalAI(window,env);assert(reloaded.Memory.Data.enabled and reloaded.Learning.Find("canh tac") and #reloaded.Memory.Data.macros==1 and #reloaded.Memory.Data.favorites==1)
assert(reloaded.Learning.Delete("canh tac"));assert(not reloaded.Learning.Find("canh tac"))
ai:Destroy();assert(listener==nil and cb==nil)
local before=files[ai.Memory.Path];files[ai.Memory.Path]="invalid";local damaged=__xNgotCreateLocalAI(window,env);assert(damaged.Memory.Blocked and not damaged.Memory.Clear() and files[ai.Memory.Path]=="invalid");files[ai.Memory.Path]=before
files[ai.Memory.Path]="changed elsewhere";assert(not reloaded.Memory.Save() and reloaded.Memory.Blocked and files[ai.Memory.Path]=="changed elsewhere");files[ai.Memory.Path]=before
local stable=__xNgotCreateLocalAI(window,env);assert(stable.Memory.Clear());assert(files[ai.Memory.Path]==nil)
local bad=clone(stable.Memory.Data);bad.enabled=true;bad.macros={{name="bad",steps={"not a spec"}}};encoded["bad-nested"]=bad;files[stable.Memory.Path]="bad-nested"
local nested=__xNgotCreateLocalAI(window,env);assert(nested.Memory.Blocked and not nested.Memory.Save() and files[stable.Memory.Path]=="bad-nested")
print("PASS LocalAI offline routing, learning, persistence, macro, diagnostics, music and performance")
