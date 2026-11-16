from pathlib import Path
import tempfile,subprocess
import os
root=Path(__file__).resolve().parents[1];luau=os.environ.get('LUAU','luau')
def run(src):
 with tempfile.NamedTemporaryFile(suffix='.luau',mode='w') as f:
  f.write(src);f.flush();subprocess.run([luau,f.name],check=True)
util=(root/'src/modules/30_overlay/070_engine_open.lua').read_text();util=util[util.index('local function trim(s)'):util.index('local function sanitizeName(text)')]
score=(root/'src/modules/30_overlay/084_engine_score.lua').read_text();score=score[score.index('        function CrossAIMusic.isRelevant'):score.index('\t\tfunction CrossAIMusic.learn')]
run('local CrossAIMusic={}\n'+util+score+'''
assert(CrossAIMusic.isRelevant({name="Chung Ta Cua Hien Tai",author="Son Tung MTP"},{explicitTitle="chung ta cua hien tai",artist="son tung mtp"}))
assert(not CrossAIMusic.isRelevant({name="Random Funny Video",author="Unknown"},{explicitTitle="chung ta cua hien tai",artist="son tung mtp"}))
assert(not CrossAIMusic.isRelevant({name="Unrelated",author="Singer"},{explicitTitle="greatest song"}))
assert(CrossAIMusic.isRelevant({name="lofi chill beats"},{tags={genre="lofi"}}))
assert(not CrossAIMusic.isRelevant({name="rock hard"},{tags={genre="lofi"}}))
print("PASS title, artist and genre relevance")
''')
code=(root/'src/modules/40_window/090_tab_list.lua').read_text();code=code[code.index('local SelectedDropdown = nil'):code.index('\n\t\t\tlocal function SelectTab')]
run('''
local UDim2={new=function(...)return {...}end}
local function folder(name) local a={Visible=false};local b={Visible=false};return {Name=name,IsA=function()return true end,FindFirstChild=function(_,key) return key=="DropdownItems" and a or b end, a=a,b=b} end
local one,two=folder("Same"),folder("Same")
local fs={GetChildren=function()return {one,two}end,FindFirstChild=function()return one end}
local txt={Text="old"};local newWindow={DropdownSelection={Dropdowns=fs,TopBar={Title={},BoxFrame={Frame={TextBox=txt}}}},DarkOverlay={}}
local function Tween()return {Completed={Wait=function()end}}end
local TweenConfigs={PopupOpen={},PopupClose={}}
''' + code + '''
DropdownPopup(nil,"Same",two);assert(SelectedDropdown==two and two.a.Visible and not one.a.Visible and txt.Text=="")
DropdownPopup(false);DropdownPopup(nil,"Same",one);assert(SelectedDropdown==one and one.a.Visible and not two.a.Visible)
print("PASS duplicate dropdown identity and search reset")
''')

source=(root/'src/modules/30_overlay/112_remote_io.lua').read_text()
part=source[source.index('        local function startLoad'):source.index('        Hooks.Register(function(dt)')]
run((root/'tests/music_auto_harness.luau').read_text().replace('-- __INSERT_MUSIC_CODE__',part))

run((root/'tests/music_prefetch_current_harness.luau').read_text().replace('-- __INSERT_MUSIC_CODE__',part))
audio=(root/'src/modules/30_overlay/096_engine_audio.lua').read_text()
cache=audio[audio.index('        local function ensureFolder'):audio.index('\n\t\tfunction CrossAIMusic.thumbAsset')]
run('''
local CrossAIMusic={};local CFG={Folder="xNgotLibrary/Music"};local created={}
local function isfolder(path) return created[path]==true end
local function makefolder(path) created[path]=true end
local function hashOf(s) return ("hash"..s) end
local function sanitizeName(s) return s or "" end
''' + cache + '''
local one=CrossAIMusic.cacheCandidates("youtube:id1","same title")
local two=CrossAIMusic.cacheCandidates("soundcloud:id1","same title")
assert(#one==2 and one[1]~=two[1] and one[2]~=two[2]);assert(not table.find(one,"xNgotLibrary/Music/same title.mp3"))
CrossAIMusic.ensureFolder("xNgotLibrary/Music/Covers");assert(created.xNgotLibrary and created["xNgotLibrary/Music"] and created["xNgotLibrary/Music/Covers"])
print("PASS source-qualified cache and recursive folders")
''')
files=(root/'src/modules/30_overlay/100_engine_files.lua').read_text()
asset=files[files.index('\t\tfunction CrossAIMusic.assetFor'):]
run('''
local CrossAIMusic={};local function jsonDecode()return nil end
function CrossAIMusic.download(url) return {url} end
function CrossAIMusic.fetchFile(key,urls) return key,urls[1] end
''' + asset + '''
local err;local result=CrossAIMusic.assetFor({source="soundcloud",id="abc",name="song"},function(state,payload)if state=="error" then err=payload.reason end end)
assert(result==nil and err=="missing source URL")
local key,url=CrossAIMusic.assetFor({source="youtube",id="abc",name="song"});assert(key=="youtube:abc" and url=="https://youtu.be/abc")
key,url=CrossAIMusic.assetFor({source="soundcloud",id="abc",url="https://soundcloud.com/a/b",name="song"});assert(key=="soundcloud:abc" and url=="https://soundcloud.com/a/b")
print("PASS no misdirected non-YouTube download and source-qualified identity")
''')
search=(root/'src/modules/30_overlay/088_engine_search.lua').read_text()
variants=search[search.index('\t\tlocal detectedRegion'):search.index('\t\tlocal function searchOne')]
run('''
local CFG={Region="VN"};local CrossAIMusic={};local task={spawn=function(f)f()end}
local game={GetService=function()return {RobloxLocaleId="vi-VN",GetCountryRegionForPlayerAsync=function()return "VN"end,LocalPlayer={}}end}
local function trim(s)return (tostring(s):gsub("^%s+",""):gsub("%s+$",""))end
local function norm(s)return s:lower()end
''' + variants + '''
local q=CrossAIMusic.queryVariants({query="lofi",tags={}},"lofi");assert(q[1]=="lofi" and q[2]:find("nhac viet nam",1,true))
CFG.Region="GLOBAL";q=CrossAIMusic.queryVariants({query="lofi",tags={}},"lofi");assert(#q==1 and q[1]=="lofi")
print("PASS precise search first and regional variant second")
''')
