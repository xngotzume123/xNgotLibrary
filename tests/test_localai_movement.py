from pathlib import Path
import tempfile,subprocess,os
root=Path(__file__).resolve().parents[1]
s=(root/'src/modules/25_localai/015_movement.lua').read_text();s=s[s.index('local function __xNgotCreateMovement'):]
h=(root/'tests/localai_movement_harness.luau').read_text().replace('-- __INSERT_MOVEMENT_CODE__',s)
with tempfile.TemporaryDirectory() as d:
 p=Path(d)/'movement.luau';p.write_text(h);subprocess.run([os.environ.get('LUAU','luau'),str(p)],check=True)
setup=(root/'tests/localai_movement_harness.luau').read_text().split('-- __INSERT_MOVEMENT_CODE__')[0]
tail=(root/'tests/localai_movement_cross_tail.luau').read_text()
engine=(root/'src/modules/25_localai/010_engine.lua').read_text();engine=engine[engine.index('local function __xNgotCreateLocalAI'):]
mount=(root/'src/modules/25_localai/020_ui.lua').read_text();mount=mount[mount.index('local function __xNgotMountLocalAI'):]
cross=(root/'src/modules/30_overlay/148_cross_control.lua').read_text();norm=cross[cross.index('local function __askNorm'):cross.index('local function __has')];routing=cross[cross.index('local __crossAskBase = Cross.ask'):cross.index('\ndo\n    local previousExpand = Isl.expand')]
tail=tail.replace('-- __INSERT_ENGINE_CODE__',engine).replace('-- __INSERT_MOVEMENT_CODE__',s).replace('-- __INSERT_MOUNT_CODE__',mount).replace('-- __INSERT_CROSS_CODE__',norm+routing)
with tempfile.TemporaryDirectory() as d:
 p=Path(d)/'cross_movement.luau';p.write_text(setup+tail);subprocess.run([os.environ.get('LUAU','luau'),str(p)],check=True)
api=(root/'src/modules/30_overlay/152_api.lua').read_text()
code=api[api.index('\t\tfunction API:AiPermission'):api.index('\t\tfunction API:AiTeach')]
check='''
local Cross={Perm={Body=true,Free=false,Ui=true,Key=true},Chat={},Enabled=true,Thinking=false,ChatVersion=1,Lang="vi"}
local stopped=0;local __hostWindow={LocalAI={Movement={Pending={}}}};function __hostWindow.LocalAI.Movement.StopAll()stopped+=1;__hostWindow.LocalAI.Movement.Pending=nil end
local API={}
'''+code+'''
assert(API:AiState().Pending==true)
assert(API:AiPermission("Body",false)==false and stopped==1 and not API:AiState().Pending)
assert(API:AiPermission("Body",true)==true and Cross.Perm.Body)
assert(API:AiPermission("Free",true)==false and Cross.Perm.Free==false)
print("PASS movement permission revocation and pending state API")
'''
with tempfile.TemporaryDirectory() as d:
 p=Path(d)/'permission.luau';p.write_text(check);subprocess.run([os.environ.get('LUAU','luau'),str(p)],check=True)
