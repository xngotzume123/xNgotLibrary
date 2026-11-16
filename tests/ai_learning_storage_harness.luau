-- Mock filesystem/JSON for deterministic persistence tests. Not a Roblox integration test.
local files,encoded={},{}
local serial=0
local function clone(v)
 if type(v)~="table" then return v end
 local t={};for k,x in pairs(v) do t[k]=clone(x) end;return t
end
local http={}
function http:JSONEncode(value) serial+=1;local id="ENC:"..serial;encoded[id]=clone(value);return id end
function http:JSONDecode(value) if not encoded[value] then error("invalid json") end;return clone(encoded[value]) end
local function create(user,mode)
 local player={UserId=user};local Cross={}
 local game={};function game:GetService(name) assert(name=="HttpService");return http end
 local isfile=function(path) if mode=="exists-error" then error("read denied") end;return files[path]~=nil end
 local readfile=function(path) if mode=="read-error" then error("read denied") end;return files[path] end
 local writefile=function(path,body) if mode=="write-error" then error("write denied") end;if mode=="false-write" then return false end;files[path]=body end
 if mode=="no-files" then isfile=nil;readfile=nil;writefile=nil end
 -- __INSERT_LEARNING_CODE__
 return Cross.Learning
end
local a=create(123)
assert(a.State().Persistent and a.State().Remember and a.State().AliasCount==0)
local ok,msg=a.Put({key="farm please",phrase="Farm please",command="bật Main Auto Farm",tab="Main",title="Auto Farm",kind="Toggle"})
assert(ok and msg:find("JSON") and a.State().AliasCount==1)
a.Record({Tab="Main",Title="Auto Farm",Kind="Toggle"});assert(a.Preferences()[1].count==1)
assert(not a.SetRemember(false) and a.State().Remember)
a.SetRemember(true);a.Record({Tab="Main",Title="Auto Farm",Kind="Toggle"});a.Record({Tab="Main",Title="Auto Farm",Kind="Toggle"})
local again=create(123);assert(again.State().Remember and again.Find("farm please").title=="Auto Farm" and again.Preferences()[1].count==3)
local other=create(456);assert(other.State().AliasCount==0 and other.State().Remember and other.State().Path~=again.State().Path)
encoded["old-settings"]={version=1,userId=321,remember=false,aliases={},prefs={}}
files["xNgotCrossAI_user_321.json"]="old-settings";local upgraded=create(321);assert(upgraded.State().Remember)
upgraded.Record({Tab="Main",Title="Auto Farm",Kind="Toggle"});assert(create(321).State().Remember and create(321).Preferences()[1].count==1)
local list=again.List();list[1].command="tampered";assert(again.Find("farm please").command~="tampered")
assert(again.Forget("farm please"));assert(create(123).State().AliasCount==0)
assert(again.Clear());assert(create(123).State().Remember and #create(123).Preferences()==0)
files["xNgotCrossAI_user_999.json"]="not json"
local corrupt=create(999);assert(not corrupt.State().Persistent and corrupt.State().Error:find("invalid"))
local status,message=corrupt.Put({key="x",phrase="x",command="x",tab="x",title="x",kind="x"});assert(status and message:find("Session only") and files["xNgotCrossAI_user_999.json"]=="not json")
assert(corrupt.Clear());assert(create(999).State().AliasCount==0)
encoded["wrong-user"]={version=1,userId=888,remember=false,aliases={},prefs={}}
files["xNgotCrossAI_user_777.json"]="wrong-user";local mismatch=create(777);assert(not mismatch.State().Persistent and mismatch.State().Error:find("another user"))
assert(mismatch.Put({key="new",phrase="new",command="x",tab="x",title="x",kind="x"}));assert(files["xNgotCrossAI_user_777.json"]=="wrong-user")
local unreadable=create(777,"read-error");assert(not unreadable.State().Persistent)
local accessErr=create(778,"exists-error");assert(not accessErr.State().Persistent)
local err=create(456,"write-error");local good,note=err.SetRemember(true);assert(good and note:find("Session only") and not err.State().Persistent)
local f=create(457,"false-write");local yes,why=f.SetRemember(true);assert(yes and why:find("Session only"))
local session=create(0,"no-files");assert(not session.State().Persistent and not session.State().Path);assert(session.Clear())
print("PASS user-scoped learning persistence, automatic preferences, corruption and write failures")
