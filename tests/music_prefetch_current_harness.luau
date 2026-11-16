
local math = setmetatable({random=function(a,b) return a end},{__index=math})
local queue = {}
local task = {}
function task.spawn(fn) local co = coroutine.create(fn); table.insert(queue, co); return co end
function task.wait() coroutine.yield() end
function task.delay(_, fn) task.spawn(fn) end
local function step()
 local current = queue; queue = {}
 for _,co in ipairs(current) do
  local ok,err = coroutine.resume(co)
  if not ok then error(err) end
  if coroutine.status(co) ~= "dead" then table.insert(queue,co) end
 end
end
local function case()
 local calls,played,ending = 0,nil,nil
 local Music = {Playing=true, Auto=true, RepeatOne=false, Shuffle=false, Loading=false, Index=1, Volume=60, Tempo=1}
 function Music.Sync() end
 local TRACKS = {{Name="one",Id="1", Remote=true},{Name="two",Id="2",Remote=true,Source="youtube"},{Name="three",Id="3",Remote=true,Source="youtube"}}
 local gui={Parent=true}
 local loadToken=1
 local currentSound={TimeLength=100, TimePosition=49, SoundId="old",Ended={Connect=function(_,fn) ending=fn end},Stop=function() end}
 local Remote={Supported=function() return true end, Engine={Config={PrefetchNext=true,DownloadTimeout=200},assetFor=function(track) calls+=1; task.wait(); return "asset-"..track.id, "music/"..track.id..".mp3" end}}
 local nextPrefetch,prefetchBusy,attemptedToken=nil,false,nil
 local Settings={Language="en"}
 local function notify() end
 local function broadcast() end
 local function waitAndPlay(_,asset) played=asset; Music.Loading=false end
 local function fetchRemote(_,track) played="fallback-"..track.Id end
 local SoundService={}
 local Instance={new=function() return {Destroy=function() end} end}
 local game={GetService=function() return {PreloadAsync=function() end} end}
-- __INSERT_MUSIC_CODE__

 return {Music=Music,tracks=TRACKS,sound=currentSound,remote=Remote,ended=function() ending() end,stats=function() return calls,played,nextPrefetch end,gui=gui}
end
local t=case()
step(); step(); assert(t.stats()==0, "before 50 percent")
t.sound.TimePosition=50; step(); step(); assert(t.stats()==1,"one prefetch")
local count,played,job=t.stats(); assert(job and job.track==t.tracks[2] and job.pending)
t.ended(); assert(t.Music.Index==2 and t.Music.Loading,"wait for in-flight prefetch")
step(); step(); step(); count,played=t.stats(); assert(count==1 and played=="asset-2", "use prepared asset, no duplicate download")
t.gui.Parent=false
local a=case(); a.Music.RepeatOne=true; a.sound.TimePosition=80; step(); step(); assert(a.stats()==0,"repeat prevents prefetch"); a.ended(); assert(a.Music.Index==1, "repeat wins"); a.gui.Parent=false
local b=case(); b.remote.Engine.Config.PrefetchNext=false; b.sound.TimePosition=80; step(); step(); assert(b.stats()==0,"disabled prefetch"); b.gui.Parent=false
local c=case(); c.sound.TimePosition=80; step(); step(); c.Music.Select(3,true); step(); step(); local _,_,oldjob=c.stats(); c.ended(); assert(c.Music.Index==2,"stale suggestion ignored"); c.gui.Parent=false
print("PASS prefetch threshold, reuse, pending, repeat, disabled, stale")
