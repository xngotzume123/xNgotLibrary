local Cross={Shell={Lines={},Version=0},Inputs={},Lang="vi"};local asks={};local replies={}
function Cross.length(s) return #s end
function Cross.say(role,value) table.insert(replies,{role,value});return value end
function Cross.ask(value)table.insert(asks,value);Cross.say("user",value);Cross.say("cross","Đã nhận yêu cầu; chờ xác nhận.") end
local COLORS={cmd="yellow",out="white"}
-- __INSERT_SHELL_LOG__
local function line(n) return Cross.Shell.Lines[n].Segs[1][1] end
Cross.say("user","bật Farm");Cross.say("cross","Bạn có muốn bật Farm không?")
assert(line(1):find("bật Farm") and line(#Cross.Shell.Lines):find("không"))
Cross.say("user","password secret");assert(line(#Cross.Shell.Lines):find("cảm") and not line(#Cross.Shell.Lines):find("secret"))
for i=1,100 do Cross.say("cross","done") end;assert(#Cross.Shell.Lines==80)
local function event()local e={} function e:Connect(f)self.fn=f end return e end
local View={crossTerm={},crossChat={},crossShell={Refresh=function()end}}
local Static={White="white",Gray="gray",Blue="blue"}
local Fonts={Regular="regular"};local Enum={TextXAlignment={Left=1},TextTruncate={AtEnd=1}}
local UDim2={fromOffset=function(...)return {...}end,new=function(...)return {...}end}
local function box(t)return t end
local function corner()end
local function raw()end
local function translate(t)return t end
local function new(kind,props)props.FocusLost=event();props.InputBegan=event();return props end
local function action(parent,x,y,w,h,text,color,cb)return {click=cb}end
-- __INSERT_SHELL_INPUT__
assert(#Cross.Inputs==1 and Cross.Inputs[1]==View.crossShellBox)
View.crossShellBox.Text="bật Farm";View.crossShellSend.click();assert(#asks==1 and asks[1]=="bật Farm" and View.crossShellBox.Text=="")
View.crossShellBox.Text="có";View.crossShellBox.FocusLost.fn(true);assert(#asks==2 and asks[2]=="có")
View.crossShellBox.Text="hủy";View.crossShellBox.FocusLost.fn(false);assert(#asks==2 and View.crossShellBox.Text=="hủy")
View.crossShellBox.Text=string.rep("x",501);View.crossShellSend.click();assert(#asks==2 and replies[#replies][2]:find("quá dài"))
print("PASS shell logs actual Cross messages, redaction, input, enter, bounded history and length")
