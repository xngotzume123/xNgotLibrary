from pathlib import Path
import subprocess,tempfile,os
root=Path(__file__).resolve().parents[1]
face=(root/'src/modules/30_overlay/064_cross_face.lua').read_text()
log=face[face.index('        function Cross.shellAdd'):face.index('        local function makeLabel')]
page=(root/'src/modules/30_overlay/128_cross_page.lua').read_text()
input_code=page[page.index('        -- The shell sends'):page.index('        function View.crossMode(mode, instant)')]
harness=(root/'tests/cross_shell_harness.luau').read_text().replace('-- __INSERT_SHELL_LOG__',log).replace('-- __INSERT_SHELL_INPUT__',input_code)
with tempfile.TemporaryDirectory() as d:
 p=Path(d)/'test.luau';p.write_text(harness);subprocess.run([os.environ.get('LUAU','luau'),str(p)],check=True)
assert 'Windows PowerShell' not in face
assert 'Cross.ask(value)' in input_code and 'loadstring' not in input_code
assert 'table.clear(Cross.Shell.Lines)' in (root/'src/modules/30_overlay/148_cross_control.lua').read_text()
engine=(root/'src/modules/25_localai/010_engine.lua').read_text();engine=engine[engine.index('local function __xNgotCreateLocalAI'):]
movement=(root/'src/modules/25_localai/015_movement.lua').read_text();movement=movement[movement.index('local function __xNgotCreateMovement'):]
mount=(root/'src/modules/25_localai/020_ui.lua').read_text();mount=mount[mount.index('local function __xNgotMountLocalAI'):]
cross=(root/'src/modules/30_overlay/148_cross_control.lua').read_text();norm=cross[cross.index('local function __askNorm'):cross.index('local function __has')];routing=cross[cross.index('local __crossAskBase = Cross.ask'):cross.index('\ndo\n    local previousExpand = Isl.expand')]
real=(root/'tests/localai_cross_harness.luau').read_text().replace('-- __INSERT_ENGINE_CODE__',engine).replace('-- __INSERT_MOVEMENT_CODE__',movement).replace('-- __INSERT_MOUNT_CODE__',mount).replace('-- __INSERT_CROSS_CODE__',norm+routing)
ui='''
Cross.Shell={Lines={},Version=0};Cross.Inputs={};function Cross.length(s)return #s end
local COLORS={cmd="yellow",out="white"}
'''+log+'''
local function event()local e={} function e:Connect(f)self.fn=f end return e end
local View={crossTerm={}};local Static={White="white",Gray="gray",Blue="blue"};local Fonts={Regular="regular"};local Enum={TextXAlignment={Left=1},TextTruncate={AtEnd=1}}
local UDim2={fromOffset=function(...)return {...}end,new=function(...)return {...}end}
local function box(t)return t end;local function corner()end;local function raw()end;local function translate(t)return t end
local function new(kind,p)p.FocusLost=event();p.InputBegan=event();return p end
local function action(a,b,c,d,e,f,g,cb)return {click=cb}end
'''+input_code+'''
View.crossShellBox.Text="bật Main Auto Farm";View.crossShellSend.click()
assert(Cross.Pending and not toggle.State and #Cross.Shell.Lines>=2)
View.crossShellBox.Text="có";View.crossShellBox.FocusLost.fn(true)
assert(toggle.State and not Cross.Pending and Cross.Shell.Lines[#Cross.Shell.Lines].Segs[1][1]~="")
toggle.State=false
'''
real=real.replace('local function ask(t)',ui+'\nlocal function ask(t)',1)
with tempfile.TemporaryDirectory() as d:
 p=Path(d)/'combined.luau';p.write_text(real);subprocess.run([os.environ.get('LUAU','luau'),str(p)],check=True)
build=face[face.index('        function Cross.buildShell'):face.index('        function Cross.buildFace')]
mock='''
local Cross={Shell={Lines={},Version=0},Shells={}}
function Cross.renderLine(line,cursor)return line.text..(cursor and "_" or "") end
local codeFace="mono";local Static={White="white"};local Enum={TextXAlignment={Left=1},TextTruncate={AtEnd=1},ScrollingDirection={Y=1}}
local UDim2={fromOffset=function(x,y)return {x=x,y=y}end,new=function(...)return {...}end}
local Vector2={new=function(x,y)return {X=x,Y=y}end}
local queued={};local task={defer=function(f)table.insert(queued,f)end}
local function flush()local tasks=queued;queued={};for _,f in ipairs(tasks) do f() end end
local function box(p)return p end;local function corner()end;local function stroke()end;local function rgb(...)return "rgb" end
local function makeLabel(parent,props) function props:SetAttribute()end;return props end
local function new(kind,p)p.CanvasPosition={X=0,Y=0};p.AbsoluteWindowSize={Y=55};p.AbsoluteCanvasSize={Y=0};return p end
'''+build+'''
local shell=Cross.buildShell({}, {Position={},Size={},Rows=4,Active=function()return true end})
assert(#shell.Labels==80 and shell.Scroll and shell.Frame)
for i=1,8 do Cross.Shell.Lines[i]={text="line"..i} end;Cross.Shell.Version+=1;shell.Refresh(true,false)
assert(shell.Scroll.CanvasSize.y==112 and shell.Labels[1].Text=="line1" and shell.Labels[8].Text=="line8")
shell.Scroll.CanvasPosition={Y=0};shell.Scroll.AbsoluteCanvasSize={Y=112};Cross.Shell.Lines[9]={text="line9"};Cross.Shell.Version+=1;shell.Refresh(false,false)
assert(shell.Scroll.CanvasPosition.Y==126 and shell.Labels[9].Text=="line9")
flush();assert(shell.Scroll.CanvasPosition.Y==126)
shell.Scroll.CanvasPosition={Y=0};shell.Refresh(false,true);assert(shell.Scroll.CanvasPosition.Y==0)
shell.Refresh(true,true);assert(shell.Scroll.CanvasPosition.Y==126)
-- A deferred callback from an older version cannot scroll a newer state.
shell.Scroll.CanvasPosition={Y=0};Cross.Shell.Version+=1;flush();assert(shell.Scroll.CanvasPosition.Y==0)
print("PASS shell auto-scrolls on new lines and reopen, not cursor blink; old deferred work is ignored")
'''
with tempfile.TemporaryDirectory() as d:
 p=Path(d)/'scroll.luau';p.write_text(mock);subprocess.run([os.environ.get('LUAU','luau'),str(p)],check=True)
