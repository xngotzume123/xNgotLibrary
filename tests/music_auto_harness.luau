
local pending={}
local task={}
function task.spawn(f) local co=coroutine.create(f); table.insert(pending,co) end
function task.wait() coroutine.yield() end
function task.delay(_,f) task.spawn(f) end
local function step() local batch=pending;pending={} for _,co in ipairs(batch) do local ok,e=coroutine.resume(co); assert(ok,e); if coroutine.status(co)~="dead" then table.insert(pending,co) end end end
local Music={Playing=true,Auto=true,RepeatOne=false,Shuffle=false,Loading=false,Index=1,Volume=60,Tempo=1}
function Music.Sync() end
local TRACKS={{Name="Song A",Artist="Singer",Id="1",Remote=true,Source="youtube"},{Name="Song B",Artist="Singer",Id="2",Remote=true,Source="youtube"},{Name="Bad",Artist="Other",Id="3",Remote=true,Source="youtube"}}
local Covers={{1,2}}; local gui={Parent=true};local loadToken=1
local ended;local currentSound={TimeLength=100,TimePosition=0,SoundId="",Ended={Connect=function(_,f) ended=f end},Stop=function() end,Pause=function() end}
local searchCount=0
local Remote={Plan={query="singer",artist="singer"},Engine={Config={PrefetchNext=false},parse=function(x)return {query=x}end,
 isRelevant=function(t) return string.find((t.author or ""):lower(),"singer",1,true)~=nil end,
 search=function() searchCount+=1;task.wait();return {{name="Song C",author="Singer",source="youtube",id="4"},{name="Noise",author="Other",source="youtube",id="5"}}end}}
local nextPrefetch,prefetchBusy,attemptedToken
local Settings={Language="en"};local function notify()end;local function broadcast()end
local function waitAndPlay()end;local function fetchRemote()end
local SoundService={};local Instance={new=function()return {Destroy=function()end}end};local game={GetService=function() return {PreloadAsync=function()end}end}
local tween=function()end;local Enum={EasingStyle={Sine="sine"}}
-- __INSERT_MUSIC_CODE__

ended();assert(Music.Index==2,"prefer matching unplayed song")
ended();step();assert(searchCount==1);step();assert(Music.Index==4 and TRACKS[4].Name=="Song C" and TRACKS[4].B==2,"online only related novel")
ended();step();Music.Toggle();step();assert(Music.Playing==false and #TRACKS==4,"stale search cannot interrupt pause")
print("PASS nonrepeating auto queue, relevance, online fallback and cancellation")
