local API={Enabled=true}
local played
local Music={Auto=true,Covers={{1,2}},Remote={}}
function Music.Remote.ScanDownloaded()return {{Path="cache/song.mp3",Title="Song",Artist="Artist"}}end
function Music.PlayAsset(track)played=track;return 1 end
local getcustomasset=function(p)assert(p=="cache/song.mp3");return "asset://cached" end
local getsynasset=nil
-- __INSERT_API_METHOD__
local ok,reason=API:MusicPlayCachedFile("cache/song.mp3");assert(not ok and reason:find("Auto") and not played)
Music.Auto=false;assert(not API:MusicPlayCachedFile("cache/other.mp3") and not played)
ok,reason=API:MusicPlayCachedFile("cache/song.mp3");assert(ok and played.Name=="Song" and played.Asset=="asset://cached" and played.CachedPath=="cache/song.mp3" and played.A==1)
print("PASS cache-only Music Player adapter and Auto guard")
