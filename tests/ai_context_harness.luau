local Cross={Enabled=true,Chat={},Perm={Ui=true}}
function Cross.say(role,text) table.insert(Cross.Chat,{Role=role,Text=text}) end
function Cross.setEnabled(on) Cross.Enabled=on end
function Cross.setMood() end
function Cross.ask(p) Cross.say("cross","fallback:"..p) end
local Settings={Language="vi"}
local player={Name="AccountReal",DisplayName="DisplayReal",UserId=123456}
local Enum={InfoType={Asset="asset"}}
local calls=0;local product={Name="Actual Place"};local denied=false
local game={PlaceId=111,GameId=222,JobId="job-uuid"}
function game:GetService(service)
 if service=="Players" then return {MaxPlayers=20, GetPlayers=function() return {1,2,3} end} end
 assert(service=="MarketplaceService")
 return {GetProductInfo=function(_,id,kind) calls+=1;assert(id==game.PlaceId and kind=="asset");if denied then error("network") end;return product end}
end
local obj={State=false,_AIInstance={IsDescendantOf=function()return true end}}
function obj:Set(v) self.State=v end
local __hostWindow={_AIControls={{Kind="Toggle",Title="Game",Tab="Main",Object=obj,Root={}}}}
-- __INSERT_AI_CODE__
local function last()return Cross.Chat[#Cross.Chat].Text end
Cross.Learning={Find=function() error("context lookup must not use learning") end, Put=function()error("context must not be learned")end, Record=function()error("context must not be recorded")end}
Cross.ask("Tên tôi là gì?");assert(last():find("AccountReal") and last():find("DisplayReal") and calls==0)
Cross.ask("tôi là ai");assert(last():find("AccountReal"))
Cross.ask("What is my username?");assert(last():find("Username") and last():find("AccountReal"))
Cross.ask("UserId của tôi");assert(last():find("123456"))
Cross.ask("tên game này là gì?");assert(last():find("Actual Place") and calls==1 and not Cross.Pending)
Cross.ask("Thông tin game");assert(last():find("111") and last():find("222") and last():find("job%-uuid") and calls==1)
Cross.ask("bao nhiêu người chơi");assert(last():find("3") and last():find("20"))
Cross.ask("place id");assert(last():find("111") and not last():find("job%-uuid"))
Cross.ask("job id");assert(last():find("job%-uuid"))
Cross.ask("game id");assert(last():find("222"))
Cross.Learning=nil
Cross.ask("bật Game");assert(Cross.Pending and not obj.State)
Cross.ask("job id");assert(last():find("chờ xác nhận") and Cross.Pending)
Cross.ask("yes");assert(obj.State)
Cross.ask("tắt Game");assert(Cross.Pending);Cross.ask("no");assert(obj.State and not Cross.Pending)
game.PlaceId=333;game.JobId="";denied=true
Cross.ask("thông tin game");assert(last():find("không lấy được") and last():find("333") and last():find("222") and calls==2)
Cross.ask("tên game");assert(calls==3,"failed requests are not cached")
denied=false;product={Name="Next Place"};Cross.ask("tên game");assert(last():find("Next Place") and calls==4)
Cross.ask("what game is this");assert(last():find("Current place name") and calls==4)
Cross.ask("next song");assert(last():find("fallback"))
print("PASS player/session context, metadata failure and cache, UI confirmation and music fallback")
