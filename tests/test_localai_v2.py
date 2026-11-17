import os,subprocess,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[1]
text=(root/'src/modules/25_localai/010_engine.lua').read_text()
assert 'loadstring' not in text and 'HttpGet' not in text and 'request(' not in text
source=text[text.index('local function __xNgotCreateLocalAI'):]
harness=(root/'tests/localai_v2_harness.luau').read_text().replace('-- __INSERT_ENGINE_CODE__',source)
with tempfile.TemporaryDirectory() as d:
 p=Path(d)/'test.luau';p.write_text(harness);subprocess.run([os.environ.get('LUAU','luau'),str(p)],check=True)

movement=(root/'src/modules/25_localai/015_movement.lua').read_text()
movement=movement[movement.index('local function __xNgotCreateMovement'):]
ui=(root/'src/modules/25_localai/020_ui.lua').read_text()
ui=ui[ui.index('local function __xNgotMountLocalAI'):]
cross=(root/'src/modules/30_overlay/148_cross_control.lua').read_text()
norm=cross[cross.index('local function __askNorm'):cross.index('local function __has')]
routing=cross[cross.index('local __crossAskBase = Cross.ask'):cross.index('\ndo\n    local previousExpand = Isl.expand')]
harness=(root/'tests/localai_cross_harness.luau').read_text().replace('-- __INSERT_ENGINE_CODE__',source).replace('-- __INSERT_MOVEMENT_CODE__',movement).replace('-- __INSERT_MOUNT_CODE__',ui).replace('-- __INSERT_CROSS_CODE__',norm+routing)
with tempfile.TemporaryDirectory() as d:
 p=Path(d)/'test.luau';p.write_text(harness);subprocess.run([os.environ.get('LUAU','luau'),str(p)],check=True)
api=(root/'src/modules/30_overlay/152_api.lua').read_text()
method=api[api.index('        function API:MusicPlayCachedFile'):api.index('\n\t\tfunction API:MusicDeleteFile')]
assert 'download' not in method.lower() or 'downloaded' in method.lower()
harness=(root/'tests/localai_cached_music_harness.luau').read_text().replace('-- __INSERT_API_METHOD__',method)
with tempfile.TemporaryDirectory() as d:
 p=Path(d)/'test.luau';p.write_text(harness);subprocess.run([os.environ.get('LUAU','luau'),str(p)],check=True)
