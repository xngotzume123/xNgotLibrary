local workspace=world
local __hostWindow={_AIControls={},DynamicIsland=nil}
function __hostWindow:NotifyIsland()end
local Cross={Enabled=true,Chat={},Perm={Ui=true,Body=true}}
local Settings={Language="en"}
function Cross.say(role,value)table.insert(Cross.Chat,{Role=role,Text=value})end
function Cross.setEnabled(on)Cross.Enabled=on end
function Cross.setMood()end
function Cross.ask(v)Cross.say("cross","fallback:"..v)end
-- __INSERT_ENGINE_CODE__
-- __INSERT_MOVEMENT_CODE__
-- __INSERT_MOUNT_CODE__
__xNgotMountLocalAI(__hostWindow)
-- __INSERT_CROSS_CODE__
local function ask(v)Cross.ask(v);return Cross.Chat[#Cross.Chat].Text end
assert(ask("chỉnh tốc độ 44"):find("Có") and hum.WalkSpeed==16 and __hostWindow.LocalAI.Movement.Pending)
assert(ask("có"):find("44") and hum.WalkSpeed==44)
ask("bật noclip");assert(part.CanCollide and __hostWindow.LocalAI.Movement.Pending)
Cross.Perm.Body=false;assert(ask("có"):find("tắt") and part.CanCollide);Cross.Perm.Body=true
ask("bật noclip");ask("có");run.Stepped:Fire();assert(not part.CanCollide)
ask("tắt noclip");assert(part.CanCollide)
ask("bật bay");ask("có");assert(__hostWindow.LocalAI.Movement.Flying)
Cross.Pending={Expires=os.clock()+60};ask("tắt bay");assert(not __hostWindow.LocalAI.Movement.Flying and Cross.Pending)
ask("không");assert(not Cross.Pending)
ask("đặt lại tốc độ");assert(hum.WalkSpeed==16)
__hostWindow.LocalAI:Destroy();assert(run.Stepped:Count()==0 and run.Heartbeat:Count()==0)
print("PASS Cross routes real movement, asks confirmation, observes body permission and cleans up")
