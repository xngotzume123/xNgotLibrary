local function signal()
 local s={listeners={}}
 function s:Connect(f)
  local c={connected=true};function c:Disconnect()self.connected=false end;c.fn=f;table.insert(self.listeners,c);return c
 end
 function s:Fire(...) for _,c in ipairs(self.listeners) do if c.connected then c.fn(...) end end end
 function s:Count()local n=0;for _,c in ipairs(self.listeners) do if c.connected then n+=1 end end;return n end
 return s
end
local vecmeta={}
function vecmeta.__index(v,key)
 if key=="Magnitude" then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end
 if key=="Unit" then local m=v.Magnitude;return setmetatable({X=v.X/m,Y=v.Y/m,Z=v.Z/m},vecmeta) end
 if key=="Dot" then return function(a,b)return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
end
function vecmeta.__mul(v,n)return setmetatable({X=v.X*n,Y=v.Y*n,Z=v.Z*n},vecmeta)end
local Vector3={new=function(x,y,z)return setmetatable({X=x,Y=y,Z=z},vecmeta)end}
local Enum={KeyCode={Space="Space",LeftControl="Ctrl",C="C"}}
local keyboard={};local uis={IsKeyDown=function(_,k)return keyboard[k]==true end}
local run={Stepped=signal(),Heartbeat=signal()};local removing=signal();local added=signal();local died=signal()
local part={Parent=true,CanCollide=true,IsA=function(_,kind)return kind=="BasePart"end}
local origFalse={Parent=true,CanCollide=false,IsA=part.IsA}
local root={Parent=true,CanCollide=true,IsA=part.IsA}
local hum={Parent=true,WalkSpeed=16,Health=100,MoveDirection=Vector3.new(0,0,-1),Jump=false,Died=died}
local char={Parent=true,DescendantAdded=added}
function char:FindFirstChildOfClass(n)assert(n=="Humanoid");return hum end
function char:FindFirstChild(n)assert(n=="HumanoidRootPart");return root end
function char:GetDescendants()return {part,origFalse,root}end
local player={Character=char,CharacterRemoving=removing}
local game={GetService=function(_,n)if n=="Players" then return {LocalPlayer=player} elseif n=="RunService" then return run elseif n=="UserInputService" then return uis end error(n)end}
local instances={}
local Instance={new=function(kind)assert(kind=="BodyVelocity");local v={destroyed=false};function v:Destroy()self.destroyed=true;self.Parent=nil end;table.insert(instances,v);return v end}
local world={CurrentCamera={CFrame={LookVector=Vector3.new(0,0.5,-0.866)}}}
local function normalize(s)return s:lower():gsub("[^%w]+"," "):gsub("%s+"," "):match("^%s*(.-)%s*$")end
-- __INSERT_MOVEMENT_CODE__
local m=__xNgotCreateMovement({}, {game=game,Instance=Instance,Vector3=Vector3,Enum=Enum,workspace=world},normalize)
local function route(s,y,n,allowed)local h,a=m.Route(s,y or false,n or false,allowed~=false,true);return h,a end
local h,a=route("dat toc do 60");assert(h and m.Pending and hum.WalkSpeed==16 and a:find("Có"))
route("co",true);assert(hum.WalkSpeed==60 and not m.Pending)
route("dat toc do 80");route("khong",false,true);assert(hum.WalkSpeed==60)
route("dat lai toc do");assert(hum.WalkSpeed==16)
route("speed -20");assert(not m.Pending and hum.WalkSpeed==16)
route("speed 101");assert(not m.Pending and hum.WalkSpeed==16)
route("speed 30");route("yes",true,false,false);assert(not m.Pending and hum.WalkSpeed==16)
route("noclip");assert(part.CanCollide and m.Pending);route("yes",true);assert(run.Stepped:Count()==1 and added:Count()==1)
run.Stepped:Fire();assert(not part.CanCollide and not root.CanCollide and not origFalse.CanCollide)
local newPart={Parent=true,CanCollide=true,IsA=part.IsA};added:Fire(newPart);run.Stepped:Fire();assert(not newPart.CanCollide)
route("tat noclip");assert(part.CanCollide and root.CanCollide and newPart.CanCollide and not origFalse.CanCollide and run.Stepped:Count()==0 and added:Count()==0)
route("bay");assert(m.Pending and not m.Flying);route("yes",true);assert(m.Flying and #instances==1 and run.Heartbeat:Count()==1)
run.Heartbeat:Fire();assert(instances[1].Velocity.Z==-40 and instances[1].Velocity.Y>0)
keyboard.C=true;run.Heartbeat:Fire();assert(instances[1].Velocity.Y==-40);keyboard.C=false
hum.Jump=true;run.Heartbeat:Fire();assert(instances[1].Velocity.Y==40);hum.Jump=false
route("toc do bay 70");route("yes",true);run.Heartbeat:Fire();assert(instances[1].Velocity.Z==-70)
route("tat bay");assert(instances[1].destroyed and run.Heartbeat:Count()==0)
route("speed 50");route("yes",true);route("noclip");route("yes",true);run.Stepped:Fire();route("bay");route("yes",true)
assert(not part.CanCollide and hum.WalkSpeed==50 and m.Flying);removing:Fire(char)
assert(part.CanCollide and hum.WalkSpeed==16 and not m.Flying and run.Stepped:Count()==0 and run.Heartbeat:Count()==0 and removing:Count()==0)
route("speed 25");player.Character={};route("yes",true);assert(hum.WalkSpeed==16 and not m.Pending);player.Character=char
route("speed 25");m.Pending.expires=-1;route("yes",true);assert(hum.WalkSpeed==16 and not m.Pending)
route("speed 25");route("yes",true);hum.WalkSpeed=35;m.StopAll();assert(hum.WalkSpeed==35)
route("speed 25");route("yes",true);hum.WalkSpeed=55;route("speed 30");route("yes",true);m.ResetSpeed();assert(hum.WalkSpeed==55)
assert(not m.Apply({kind="speed",value=1000,char=char,hum=hum,root=root},true) and hum.WalkSpeed==55)
route("noclip");route("yes",true);m.Destroy();assert(not m.Noclip and run.Stepped:Count()==0 and added:Count()==0)
print("PASS movement confirmations, permissions, limits, flight steering, collision restoration, respawn and cleanup")
