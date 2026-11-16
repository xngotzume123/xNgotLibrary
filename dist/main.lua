--[[
       _   _             _   _    _ _____ 
      | \ | |           | | | |  | |_   _|
 __  _|  \| | __ _  ___ | |_| |  | | | |  
 \ \/ / . ` |/ _` |/ _ \| __| |  | | | |  
  >  <| |\  | (_| | (_) | |_| |__| |_| |_ 
 /_/\_\_| \_|\__, |\___/ \__|\____/|_____|
              __/ |                       
             |___/                        
    Rewrited from Wind UI (Footagesus)
    Github: https://github.com/Footagesus/WindUI
    KeySystem UI/Engine: https://github.com/snowdevlol/OphynUI

	Developed by: Nguyễn Minh Nhật (xNgot Zume)

	This User Interface is open source and for public usage.
]]
topN={type="number",min=1,max=40,default=12,
desc="Số kết quả trả về cho dropdown"},
sources={type="table",default={"youtube","soundcloud","audius"},
desc="Nguồn tìm nhạc (youtube / soundcloud / audius / tiktok / audiomack)"},
region={type="string",default="auto",desc="Khu vực tìm nhạc: auto / global / VN / US / KR / JP"},
prefetchNext={type="boolean",default=true,desc="Tải trước bài tiếp theo khi nghe tới 50%"},
searchTimeout={type="number",min=2,max=60,default=12,
desc="Giây tối đa cho 1 lượt tìm"},
preferShort={type="number",min=0,max=7200,default=600,
desc="Ưu tiên bài <= N giây (0 = tắt)"},
folder={type="string",default="xNgotLibrary/Music",
desc="Thư mục cache mp3"},
raceTracks={type="number",min=1,max=4,default=2,
desc="Số bài tải SONG SONG (1 = tuần tự, nhẹ mạng)"},
downloadTimeout={type="number",min=20,max=600,default=200,
desc="Giây tối đa chờ loader.to chuyển mã"},
retries={type="number",min=0,max=5,default=2,
desc="Số lần thử lại khi lỗi"},
renameFiles={type="boolean",default=true,
desc="Đặt tên file theo TÊN BÀI (false = chỉ hash)"},
aiBrain={type="string",default="local",
desc="Bộ não AI: local (offline, không cần mạng)"},
aiLearn={type="boolean",default=true,
desc="AI tự học: ghi nhớ bài bị bỏ qua để lần sau lọc tốt hơn"},
coverArt={type="boolean",default=true,
desc="Hiện ảnh bìa trong dropdown + Dynamic Island"},
compactRows={type="boolean",default=false,
desc="Thẻ nhạc gọn (1 dòng chữ thay vì 2)"},
showSource={type="boolean",default=true,
desc="Hiện nhãn nguồn (YT / SC / AU) trên thẻ"},
notifyOnSearch={type="boolean",default=true,
desc="Hiện thông báo mỗi lần tìm xong"},
debug={type="boolean",default=false,
desc="In log ra console để gỡ lỗi"},
}
local Config={}
local listeners={}
local function coerce(key,value)
local spec=ConfigSchema[key]
if not spec then return nil,"unknown key"end
local okType=true
if spec.type=="number"then
local n=tonumber(value)
if not n then return nil,"cần số"end
if spec.min and n<spec.min then n=spec.min end
if spec.max and n>spec.max then n=spec.max end
return math.floor(n)
elseif spec.type=="boolean"then
return value==true
elseif spec.type=="string"then
return tostring(value or"")
elseif spec.type=="table"then
if type(value)~="table"then return nil,"cần bảng"end
return value
end
return okType and value or nil
end
local function set(key,value,silent)
local v,err=coerce(key,value)
if v==nil then return false,err end
Config[key]=v
if not silent then
for _,fn in ipairs(listeners)do pcall(fn,key,v)end
end
return true
end
for key,spec in pairs(ConfigSchema)do
Config[key]=spec.default
end
do
local ext=type(getgenv)=="function"and getgenv().xNgotMusic or _G.xNgotMusic
if type(ext)=="table"then
for key,value in pairs(ext)do
if ConfigSchema[key]then set(key,value,true)end
end
end
end
local function log(...)
if Config.debug then
warn("[xNgotMusic] "..table.concat({...}," "))
end
end
local function applyToEngine(engine)
if type(engine)~="table"or type(engine.Config)~="table"then return false end
local c=engine.Config
c.TopN=Config.topN
c.Sources=Config.sources
c.Region=Config.region
c.PrefetchNext=Config.prefetchNext
c.SearchTimeout=Config.searchTimeout
c.PreferShort=Config.preferShort
c.Folder=Config.folder
c.CoversFolder=Config.folder.."/Covers"
c.RaceTracks=Config.raceTracks
c.DownloadTimeout=Config.downloadTimeout
c.Retries=Config.retries
c.LlmMode="off"
c.AiBrain=Config.aiBrain
c.AiLearn=Config.aiLearn
if type(engine.renameFiles)=="function"then
engine.renameFiles(Config.renameFiles)
end
return true
end
local Api={}
function Api:Get(key)
if key then return Config[key]end
local copy={}
for k,v in pairs(Config)do
if type(v)=="table"then
local t={}
for i,x in ipairs(v)do t[i]=x end
copy[k]=t
else
copy[k]=v
end
end
return copy
end
function Api:Set(key,value)
local ok,err=set(key,value)
if ok then
log("config",key,"=",tostring(value))
local engine=_G.CrossAIMusic
if engine then applyToEngine(engine)end
end
return ok,err
end
function Api:Schema()return ConfigSchema end
function Api:OnChange(fn)
if type(fn)~="function"then return function()end end
listeners[#listeners+1]=fn
return function()
for i=#listeners,1,-1 do
if listeners[i]==fn then table.remove(listeners,i)end
end
end
end
function Api:Apply()return applyToEngine(_G.CrossAIMusic)end
local Presets={
fast={raceTracks=2,topN=8,searchTimeout=8,preferShort=480,
sources={"youtube","audius"}},
["quality"]={raceTracks=1,topN=20,searchTimeout=20,preferShort=900,
sources={"youtube","soundcloud","audius"}},
["lowdata"]={raceTracks=1,topN=6,searchTimeout=8,coverArt=false,
sources={"youtube"}},
["vietnamese"]={sources={"soundcloud","youtube"},region="VN",topN=15,
preferShort=420},
}
function Api:Preset(name)
local p=Presets[tostring(name or""):lower()]
if not p then return false,"không có preset: "..tostring(name)end
for k,v in pairs(p)do Api:Set(k,v)end
return true
end
function Api:Presets()
local names={}
for k in pairs(Presets)do names[#names+1]=k end
table.sort(names)
return names
end
do
local gv=type(getgenv)=="function"and getgenv()or _G
local preset=gv.xNgotMusicPreset
if type(preset)=="string"and preset~=""and Api.Preset then
pcall(Api.Preset,Api,preset)
end
end
_G.xNgotMusicConfig=Api
local function __xNgotCreateOphyn()
local __modules={}
local __cache={}
local function import(path)
local cached=__cache[path]
if cached~=nil then
return cached
end
local loader=__modules[path]
if not loader then
error("module not found: "..tostring(path))
end
local value=loader()
__cache[path]=value
return value
end
__modules["components/nothing.com/yeahnothing"]=function()
end
__modules["components/window/dialog"]=function()
local Dialog={}
function Dialog.new(ctx,callbacks)
callbacks=callbacks or{}
local C=ctx.C
local make,frame,text,round=ctx.make,ctx.frame,ctx.text,ctx.round
local tween,prep,fade=ctx.tween,ctx.prep,ctx.fade
local state,Images,FONT_BOLD=ctx.state,ctx.images,ctx.FONT_BOLD
local popup=make("Frame",{
Size=UDim2 .new(1,0,1,0),
BackgroundTransparency=1,
BorderSizePixel=0,
ZIndex=10,
Visible=false,
},ctx.canvas)
local dim=make("TextButton",{
Size=UDim2 .new(1,0,1,0),
BackgroundColor3=Color3 .fromRGB(0,0,0),
BackgroundTransparency=0.4,
BorderSizePixel=0,
AutoButtonColor=false,
Text="",
},popup)
make("UICorner",{CornerRadius=UDim.new(0,10)},dim)
local popupCard=make("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,270,0,132),
BackgroundColor3="card",
BorderSizePixel=0,
},popup)
round(popupCard,12,"stroke")
local badge=frame(popupCard,22,20,32,32,"input",0)
round(badge,16,"stroke")
make("ImageLabel",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,12,0,12),
BackgroundTransparency=1,
Image=Images.CLOSE_ICON,
ImageColor3=ctx.tintIcons and"accent"or Color3 .fromRGB(255,255,255),
},badge)
local popupTitle=text(popupCard,"Close Key System?",66,19,182,16,14,"text")
popupTitle.FontFace=FONT_BOLD
local popupDesc=text(popupCard,"Are you sure you want to close the Key System?",66,38,182,30,12,"muted")
popupDesc.TextWrapped=true
popupDesc.TextYAlignment=Enum.TextYAlignment.Top
local function popupButton(label,x,primary)
local btn=make("TextButton",{
Position=UDim2 .new(0,x,0,86),
Size=UDim2 .new(0,109,0,32),
BackgroundColor3=primary and"submitBg"or"btn2",
BackgroundTransparency=primary and 0.12 or 0,
BorderSizePixel=0,
AutoButtonColor=false,
Text=label,
TextSize=13,
TextColor3=primary and"submitText"or"text",
FontFace=ctx.FONT,
},popupCard)
if primary then
round(btn,8)
else
round(btn,8,"stroke")
end
return btn
end
local cancelBtn=popupButton("Cancel",22,false)
local confirmBtn=popupButton("Close",139,true)
cancelBtn.MouseEnter:Connect(function()
if state.closing or not state.popupOpen then
return
end
tween(cancelBtn,0.15,{BackgroundColor3=C.btn2Hover})
end)
cancelBtn.MouseLeave:Connect(function()
if state.closing or not state.popupOpen then
return
end
tween(cancelBtn,0.15,{BackgroundColor3=C.btn2})
end)
confirmBtn.MouseEnter:Connect(function()
if state.closing or not state.popupOpen then
return
end
tween(confirmBtn,0.15,{BackgroundTransparency=0})
end)
confirmBtn.MouseLeave:Connect(function()
if state.closing or not state.popupOpen then
return
end
tween(confirmBtn,0.15,{BackgroundTransparency=0.12})
end)
local popupItems=prep(popup)
fade(popupItems,0)
local function show()
if not state.ready or state.popupOpen or state.closing then
return
end
state.popupOpen=true
popup.Visible=true
popupCard.Position=UDim2 .new(0.5,0,0.5,8)
if callbacks.onOpen then
callbacks.onOpen()
end
fade(popupItems,1,0.22)
tween(popupCard,0.35,{Position=UDim2 .new(0.5,0,0.5,0)},Enum.EasingStyle.Quint)
end
local function hide()
if not state.popupOpen or state.closing then
return
end
state.popupOpen=false
fade(popupItems,0,0.18)
task.delay(0.2,function()
if not state.popupOpen then
popup.Visible=false
end
end)
end
cancelBtn.MouseButton1Click:Connect(hide)
confirmBtn.MouseButton1Click:Connect(function()
if callbacks.onConfirm then
callbacks.onConfirm()
end
end)
return{
popup=popup,
items=popupItems,
show=show,
hide=hide,
}
end
return Dialog
end
__modules["components/window/notification"]=function()
local Lighting=game:GetService("Lighting")
local Notification={}
local STYLE_BY_NAME={stripe="1",pill="2",island="3",ring="4",solid="5"}
function Notification.new(ctx)
local C=ctx.C
local make,frame,text,round=ctx.make,ctx.frame,ctx.text,ctx.round
local tween,prep,fade=ctx.tween,ctx.prep,ctx.fade
local root,cfg,Images=ctx.root,ctx.cfg,ctx.images
local FONT,FONT_BOLD=ctx.FONT,ctx.FONT_BOLD
local markBoldFont=ctx.markBoldFont
local NOTIF_W=cfg.NOTIF_W
local NOTIF_TRANSPARENCY=cfg.NOTIF_TRANSPARENCY
local NOTIF_COLOR=cfg.NOTIF_COLOR
local NOTIF_BLUR=cfg.NOTIF_BLUR
local ISLAND_W=260
local RING_DOTS=28
local MAX_NOTIFS=4
local WHITE=Color3 .fromRGB(255,255,255)
local DARK=Color3 .fromRGB(11,11,11)
local ICONS={
key={Images.KEY,18},
submit={Images.SUBMIT,18},
link={Images.LINK,18},
discord={Images.DISCORD,18},
close={Images.CLOSE_ICON,14},
moon={Images.MOON_ICON,14},
}
local function kindColor(kind)
if kind=="success"then
return C.success
elseif kind=="warn"then
return C.warn
elseif kind=="error"then
return C.error
end
return C.accent
end
local function contrastOn(color)
local luminance=0.299*color.R+0.587*color.G+0.114*color.B
return luminance>0.55 and DARK or WHITE
end
local function cardHover()
return NOTIF_COLOR=="bg"and C.card or C.btn2
end
local cornerHolder=make("Frame",{
AnchorPoint=Vector2 .new(1,1),
Position=UDim2 .new(1,-16,1,-8),
Size=UDim2 .new(0,NOTIF_W,1,-16),
BackgroundTransparency=1,
BorderSizePixel=0,
ZIndex=20,
},root)
make("UIListLayout",{
SortOrder=Enum.SortOrder.LayoutOrder,
VerticalAlignment=Enum.VerticalAlignment.Bottom,
HorizontalAlignment=Enum.HorizontalAlignment.Right,
},cornerHolder)
local islandHolder=make("Frame",{
AnchorPoint=Vector2 .new(0.5,0),
Position=UDim2 .new(0.5,0,0,12),
Size=UDim2 .new(0,ISLAND_W,1,-24),
BackgroundTransparency=1,
BorderSizePixel=0,
ZIndex=20,
},root)
make("UIListLayout",{
SortOrder=Enum.SortOrder.LayoutOrder,
VerticalAlignment=Enum.VerticalAlignment.Top,
HorizontalAlignment=Enum.HorizontalAlignment.Center,
},islandHolder)
local notifCount=0
local activeNotifs={}
local Blur={effect=nil,users=0}
function Blur.to(size,time)
if NOTIF_BLUR<=0 then
return
end
if not Blur.effect then
local ok,effect=pcall(function()
local e=Instance.new("BlurEffect")
e.Name="AirflowBlur"
e.Size=0
e.Parent=Lighting
return e
end)
if not ok then
return
end
Blur.effect=effect
end
tween(Blur.effect,time,{Size=size})
end
function Blur.acquire()
Blur.users+=1
Blur.to(NOTIF_BLUR,0.35)
end
function Blur.release()
Blur.users=math.max(Blur.users-1,0)
if Blur.users==0 and Blur.effect then
Blur.to(0,0.5)
end
end
root.Destroying:Connect(function()
if Blur.effect then
Blur.effect:Destroy()
Blur.effect=nil
end
end)
local function newWrapper(holder,width,height)
return make("Frame",{
LayoutOrder=notifCount,
Size=UDim2 .new(0,width,0,height+8),
BackgroundTransparency=1,
BorderSizePixel=0,
},holder)
end
local function newToast(wrapper,props,radius,strokeColor)
props.BorderSizePixel=0
props.AutoButtonColor=false
props.ClipsDescendants=true
props.Text=""
local toast=make("TextButton",props,wrapper)
round(toast,radius,strokeColor)
local stroke=toast:FindFirstChildOfClass("UIStroke")
if stroke then
stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
stroke.Transparency=0.35
end
return toast
end
local function label(parent,str,x,y,w,h,size,color,bold)
local l=text(parent,str,x,y,w,h,size,color)
if bold then
markBoldFont(l)
end
l.TextTruncate=Enum.TextTruncate.AtEnd
return l
end
local function iconImage(parent,spec,color,size)
return make("ImageLabel",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,size,0,size),
BackgroundTransparency=1,
Image=spec[1],
ImageColor3=color,
},parent)
end
local function buildStripe(title,message,color)
local W,H=NOTIF_W,62
local wrapper=newWrapper(cornerHolder,W,H)
local toast=newToast(wrapper,{
Position=UDim2 .new(0,40,0,0),
Size=UDim2 .new(0,W,0,H),
BackgroundColor3=C[NOTIF_COLOR],
BackgroundTransparency=NOTIF_TRANSPARENCY,
},10,C.stroke)
round(frame(toast,8,10,3,H-20,color,0),2)
label(toast,title,22,11,W-36,18,13,C.text,true)
label(toast,message,22,30,W-36,16,12,C.muted)
local trackW=W-44
round(frame(toast,22,H-9,trackW,2,color,0.8),1)
local fill=frame(toast,22,H-9,trackW,2,color,0)
round(fill,1)
return{
wrapper=wrapper,
toast=toast,
startPos=UDim2 .new(0,40,0,0),
restPos=UDim2 .new(0,0,0,0),
baseColor=C[NOTIF_COLOR],
hoverColor=cardHover(),
progress=function(fraction)
tween(
fill,
0.06,
{Size=UDim2 .new(0,math.floor(trackW*fraction),0,2)},
Enum.EasingStyle.Linear
)
end,
}
end
local function escapeRich(str)
return(str:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"))
end
local function buildPill(title,message,color,spec)
local H=36
local wrapper=make("Frame",{
LayoutOrder=notifCount,
Size=UDim2 .new(0,NOTIF_W,0,0),
AutomaticSize=Enum.AutomaticSize.Y,
BackgroundTransparency=1,
BorderSizePixel=0,
},cornerHolder)
make("UIPadding",{PaddingBottom=UDim.new(0,8)},wrapper)
local toast=newToast(wrapper,{
AnchorPoint=Vector2 .new(1,0),
Position=UDim2 .new(1,40,0,0),
Size=UDim2 .new(0,0,0,0),
AutomaticSize=Enum.AutomaticSize.XY,
BackgroundColor3=C[NOTIF_COLOR],
BackgroundTransparency=NOTIF_TRANSPARENCY,
},H/2,C.stroke)
make("UISizeConstraint",{MinSize=Vector2 .new(0,H)},toast)
make("UIPadding",{
PaddingLeft=UDim.new(0,6),
PaddingRight=UDim.new(0,14),
PaddingTop=UDim.new(0,6),
PaddingBottom=UDim.new(0,6),
},toast)
make("UIListLayout",{
FillDirection=Enum.FillDirection.Horizontal,
VerticalAlignment=Enum.VerticalAlignment.Center,
SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,8),
},toast)
local badge=make("Frame",{
LayoutOrder=1,
Size=UDim2 .new(0,24,0,24),
BackgroundColor3=color,
BorderSizePixel=0,
},toast)
make("UICorner",{CornerRadius=UDim.new(1,0)},badge)
iconImage(badge,spec,contrastOn(color),math.min(spec[2],14))
local rich="<b>"..escapeRich(title).."</b>"
if message~=""then
rich=rich..'  <font color="#'..C.muted:ToHex()..'">'..escapeRich(message).."</font>"
end
local body=make("TextLabel",{
LayoutOrder=2,
Size=UDim2 .new(0,0,0,0),
AutomaticSize=Enum.AutomaticSize.XY,
BackgroundTransparency=1,
BorderSizePixel=0,
RichText=true,
TextWrapped=true,
Text=rich,
TextSize=13,
TextColor3=C.text,
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
FontFace=FONT,
},toast)
make("UISizeConstraint",{MaxSize=Vector2 .new(NOTIF_W-52,math.huge)},body)
return{
wrapper=wrapper,
toast=toast,
startPos=UDim2 .new(1,40,0,0),
restPos=UDim2 .new(1,0,0,0),
baseColor=C[NOTIF_COLOR],
hoverColor=cardHover(),
}
end
local function buildIsland(title,message,color,spec)
local W,H=ISLAND_W,52
local border=Color3 .fromRGB(42,42,48)
local wrapper=newWrapper(islandHolder,W,H)
local toast=newToast(wrapper,{
AnchorPoint=Vector2 .new(0.5,0),
Position=UDim2 .new(0.5,0,0,-70),
Size=UDim2 .new(0,H,0,H),
BackgroundColor3=Color3 .fromRGB(0,0,0),
BackgroundTransparency=0.06,
},H/2,border)
local badge=frame(toast,10,10,32,32,color,0)
make("UICorner",{CornerRadius=UDim.new(1,0)},badge)
iconImage(badge,spec,contrastOn(color),spec[2])
label(toast,title,54,9,W-70,16,13,Color3 .fromRGB(244,244,245),true)
label(toast,message,54,27,W-70,14,12,Color3 .fromRGB(154,154,162))
return{
wrapper=wrapper,
toast=toast,
baseColor=Color3 .fromRGB(0,0,0),
hoverColor=Color3 .fromRGB(22,22,26),
enter=function(items)
fade(items,1,0.25)
tween(toast,0.4,{Position=UDim2 .new(0.5,0,0,0)},Enum.EasingStyle.Quint)
task.delay(0.12,function()
tween(toast,0.5,{Size=UDim2 .new(0,W,0,H)},Enum.EasingStyle.Quint)
end)
end,
leave=function(items)
fade(items,0,0.25)
tween(
toast,
0.3,
{Size=UDim2 .new(0,H,0,H)},
Enum.EasingStyle.Quint,
Enum.EasingDirection.In
)
task.delay(0.15,function()
tween(
toast,
0.3,
{Position=UDim2 .new(0.5,0,0,-70)},
Enum.EasingStyle.Quint,
Enum.EasingDirection.In
)
end)
end,
}
end
local function buildRing(title,message,color,spec)
local W,H=NOTIF_W,60
local wrapper=newWrapper(cornerHolder,W,H)
local toast=newToast(wrapper,{
Position=UDim2 .new(0,40,0,0),
Size=UDim2 .new(0,W,0,H),
BackgroundColor3=C[NOTIF_COLOR],
BackgroundTransparency=NOTIF_TRANSPARENCY,
},10,C.stroke)
local ringBox=frame(toast,10,10,40,40)
local dots={}
for i=0,RING_DOTS-1 do
local angle=(i/RING_DOTS)*math.pi*2-math.pi/2
local dot=make("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5+math.cos(angle)*0.425,0,0.5+math.sin(angle)*0.425,0),
Size=UDim2 .new(0,3,0,3),
BackgroundColor3=color,
BorderSizePixel=0,
},ringBox)
make("UICorner",{CornerRadius=UDim.new(1,0)},dot)
dots[#dots+1]=dot
end
iconImage(ringBox,spec,ctx.tintIcons and color or WHITE,math.min(spec[2],18))
label(toast,title,62,11,W-76,18,13,C.text,true)
label(toast,message,62,31,W-76,16,12,C.muted)
local lastLit=RING_DOTS
return{
wrapper=wrapper,
toast=toast,
startPos=UDim2 .new(0,40,0,0),
restPos=UDim2 .new(0,0,0,0),
baseColor=C[NOTIF_COLOR],
hoverColor=cardHover(),
progress=function(fraction)
local lit=math.ceil(fraction*RING_DOTS)
if lit>=lastLit then
return
end
for i=lit+1,lastLit do
tween(dots[i],0.15,{BackgroundTransparency=0.82})
end
lastLit=lit
end,
}
end
local function buildSolid(title,message,color,spec)
local W,H=NOTIF_W,58
local onColor=contrastOn(color)
local wrapper=newWrapper(cornerHolder,W,H)
local toast=newToast(wrapper,{
Position=UDim2 .new(0,40,0,0),
Size=UDim2 .new(0,W,0,H),
BackgroundColor3=color,
BackgroundTransparency=0.04,
},10,nil)
local iconBox=frame(toast,14,(H-22)/2,22,22)
iconImage(iconBox,spec,onColor,math.min(spec[2]+4,22))
label(toast,title,48,10,W-62,18,13,onColor,true)
label(toast,message,48,30,W-62,16,12,onColor:Lerp(color,0.35))
return{
wrapper=wrapper,
toast=toast,
startPos=UDim2 .new(0,40,0,0),
restPos=UDim2 .new(0,0,0,0),
baseColor=color,
hoverColor=color:Lerp(WHITE,0.12),
}
end
local STYLES={
["1"]=buildStripe,
["2"]=buildPill,
["3"]=buildIsland,
["4"]=buildRing,
["5"]=buildSolid,
}
local function resolveKey()
local raw=ctx.getStyle and ctx.getStyle()or"1"
local key=(tostring(raw):lower():gsub("%s+",""))
key=STYLE_BY_NAME[key]or key
return STYLES[key]and key or"1"
end
local function resolveStyle()
return STYLES[resolveKey()]
end
local function notify(title,message,kind,iconKey,duration)
kind=kind or"info"
duration=duration or 3.5
title=tostring(title or"")
message=tostring(message or"")
local color=kindColor(kind)
local spec=ICONS[iconKey]or(kind=="error"and ICONS.close or ICONS.key)
notifCount+=1
Blur.acquire()
local n=resolveStyle()(title,message,color,spec)
local wrapper,toast=n.wrapper,n.toast
local items=prep(toast)
fade(items,0)
local handle={}
local dismissed=false
function handle.dismiss()
if dismissed then
return
end
dismissed=true
Blur.release()
local idx=table.find(activeNotifs,handle)
if idx then
table.remove(activeNotifs,idx)
end
if n.leave then
n.leave(items)
else
fade(items,0,0.25)
tween(toast,0.3,{Position=n.startPos},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
end
task.delay(0.28,function()
local size=wrapper.Size
local height=wrapper.AbsoluteSize.Y
wrapper.AutomaticSize=Enum.AutomaticSize.None
wrapper.Size=UDim2 .new(size.X.Scale,size.X.Offset,0,height)
tween(wrapper,0.2,{Size=UDim2 .new(size.X.Scale,size.X.Offset,0,0)})
task.delay(0.22,function()
wrapper:Destroy()
end)
end)
end
toast.MouseButton1Click:Connect(handle.dismiss)
if n.enter then
n.enter(items)
else
fade(items,1,0.3)
tween(toast,0.45,{Position=n.restPos},Enum.EasingStyle.Quint)
end
local hovering,hoverSince=false,0
toast.MouseEnter:Connect(function()
if dismissed then
return
end
hovering=true
hoverSince=os.clock()
tween(toast,0.15,{BackgroundColor3=n.hoverColor})
end)
toast.MouseLeave:Connect(function()
if dismissed then
return
end
hovering=false
tween(toast,0.15,{BackgroundColor3=n.baseColor})
end)
task.spawn(function()
local remaining=duration
local started=os.clock()
local last=started
while not dismissed do
task.wait(0.05)
local now=os.clock()
if not(hovering and now-hoverSince<8)then
remaining-=now-last
end
last=now
if n.progress and now-started>0.35 then
n.progress(math.clamp(remaining/duration,0,1))
end
if remaining<=0 then
handle.dismiss()
break
end
end
end)
table.insert(activeNotifs,handle)
while#activeNotifs>MAX_NOTIFS do
activeNotifs[1].dismiss()
end
return handle
end
local function dismissAll()
for i=#activeNotifs,1,-1 do
activeNotifs[i].dismiss()
end
end
return{
notify=notify,
dismissAll=dismissAll,
styleKey=resolveKey,
blur=Blur,
}
end
return Notification
end
__modules["components/window/pages"]=function()
local Lucide=import("utilities/lucide")
local DEFAULT_IMAGE_SIZE=40
local NAMED_COLORS={
red=Color3 .fromRGB(229,57,53),
orange=Color3 .fromRGB(245,124,0),
yellow=Color3 .fromRGB(250,204,21),
green=Color3 .fromRGB(34,160,80),
teal=Color3 .fromRGB(20,160,150),
cyan=Color3 .fromRGB(6,182,212),
blue=Color3 .fromRGB(59,130,246),
indigo=Color3 .fromRGB(99,102,241),
purple=Color3 .fromRGB(147,51,234),
pink=Color3 .fromRGB(236,72,153),
grey=Color3 .fromRGB(100,100,108),
gray=Color3 .fromRGB(100,100,108),
white=Color3 .fromRGB(245,245,245),
black=Color3 .fromRGB(16,16,16),
}
local function parseColor(value)
if value==nil or value==""then
return nil
end
if typeof(value)=="Color3"then
return value
end
if type(value)=="string"then
local named=NAMED_COLORS[value:lower()]
if named then
return named
end
local hex=value:match("^#?(%x%x%x%x%x%x)$")
if hex then
return Color3 .fromHex(hex)
end
end
return nil
end
local function parseImageSize(value)
local d=DEFAULT_IMAGE_SIZE
if typeof(value)=="UDim2"then
return value
end
if typeof(value)=="Vector2"then
return UDim2 .new(0,value.X,0,value.Y)
end
if type(value)=="number"then
return UDim2 .new(0,value,0,value)
end
if type(value)=="string"then
local nums={}
for n in value:gmatch("%d+%.?%d*")do
nums[#nums+1]=tonumber(n)
end
if#nums==1 then
return UDim2 .new(0,nums[1],0,nums[1])
elseif#nums>=2 then
return UDim2 .new(0,nums[1],0,nums[2])
end
end
return UDim2 .new(0,d,0,d)
end
local HttpService=game:GetService("HttpService")
local universeCache={}
local function httpGet(url)
local ok,body=pcall(function()
return game:HttpGet(url)
end)
if ok and type(body)=="string"and body~=""then
return body
end
ok,body=pcall(function()
return game:HttpGetAsync(url)
end)
if ok and type(body)=="string"and body~=""then
return body
end
return nil
end
local function universeOf(placeId)
if universeCache[placeId]then
return universeCache[placeId]
end
local universe
if tostring(game.PlaceId)==placeId then
universe=tostring(game.GameId)
else
for _,host in ipairs({"apis.roblox.com","apis.roproxy.com"})do
local body=httpGet("https://"..host.."/universes/v1/places/"..placeId.."/universe")
if body then
local ok,data=pcall(function()
return HttpService:JSONDecode(body)
end)
if ok and type(data)=="table"and data.universeId then
universe=tostring(data.universeId)
break
end
end
end
end
if universe then
universeCache[placeId]=universe
end
return universe
end
local function resolveGameIcon(id,callback)
task.spawn(function()
local universe=universeOf(id)or id
callback("rbxthumb://type=GameIcon&id="..universe.."&w=256&h=256")
end)
end
local Pages={}
function Pages.new(ctx)
local C,make,round=ctx.C,ctx.make,ctx.round
local tween,prep,fade=ctx.tween,ctx.prep,ctx.fade
local setRole,icon,assetId=ctx.setRole,ctx.icon,ctx.assetId
local contrastOn,iconRole,logoRole=ctx.contrastOn,ctx.iconRole,ctx.logoRole
local FONT,FONT_BOLD,Images=ctx.FONT,ctx.FONT_BOLD,ctx.images
local state,content,canvas=ctx.state,ctx.content,ctx.canvas
local W,H=ctx.width,ctx.height
local TOPBAR_H=38
local SIDE_W=124
local SLIDE_TIME=0.55
local Quint=Enum.EasingStyle.Quint
local SECTION_TEXT_SIZE=15
local SECTION_TEXT_TRANSPARENCY=0.35
local TAB_SLIDE=10
local TAB_IN_TIME=0.32
local TAB_STAGGER=0.045
local TAB_STAGGER_MAX=0.4
local NEXT_ARROW_ROTATION=90
local BACK_ARROW_ROTATION=-NEXT_ARROW_ROTATION
local TABS_BAR_H=34
local TAB_H_STYLE2=26
local tintIcons=type(iconRole("muted"))=="string"
local function arrowIcon(parent,rotation,drop)
local img=make("ImageLabel",{
Name="ArrowIcon",
Position=UDim2 .new(0.5,-8,0.5,-8+(drop or 0)),
Size=UDim2 .new(0,16,0,16),
BackgroundTransparency=1,
Image=Images.SUBMIT,
ImageColor3=iconRole("muted"),
Rotation=rotation,
ZIndex=6,
},parent)
task.spawn(function()
pcall(function()
game:GetService("ContentProvider"):PreloadAsync({img})
end)
end)
return img
end
local function tintArrow(img,color)
if tintIcons then
tween(img,0.15,{ImageColor3=color})
end
end
local function line(parent,x,y,w,h)
return make("Frame",{
Position=UDim2 .new(0,x,0,y),
Size=UDim2 .new(0,w,0,h),
BackgroundColor3="stroke",
BackgroundTransparency=0,
BorderSizePixel=0,
},parent)
end
local page=make("Frame",{
Name="Page2",
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,H),
Size=UDim2 .new(0,W,0,H),
BackgroundTransparency=1,
BorderSizePixel=0,
Visible=false,
},canvas)
local topbar=make("Frame",{
Name="Topbar",
Size=UDim2 .new(0,W,0,TOPBAR_H),
BackgroundTransparency=1,
BorderSizePixel=0,
},page)
make("ImageLabel",{
Position=UDim2 .new(0,14,0,9),
Size=UDim2 .new(0,24,0,20),
BackgroundTransparency=1,
Image=ctx.logo,
ImageColor3=logoRole("accent"),
ScaleType=Enum.ScaleType.Fit,
},topbar)
local pageTitle=make("TextLabel",{
Position=UDim2 .new(0,46,0,0),
Size=UDim2 .new(0,W-46-84,1,0),
BackgroundTransparency=1,
BorderSizePixel=0,
Text=ctx.title,
TextSize=14,
TextColor3="text",
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
TextTruncate=Enum.TextTruncate.AtEnd,
FontFace=FONT_BOLD,
},topbar)
ctx.markTitleFont(pageTitle)
local function topButton(rightOffset)
local btn=make("TextButton",{
Name="TopButton",
AnchorPoint=Vector2 .new(1,0),
Position=UDim2 .new(1,-rightOffset,0,6),
Size=UDim2 .new(0,26,0,26),
BackgroundColor3="card",
BackgroundTransparency=1,
BorderSizePixel=0,
AutoButtonColor=false,
Text="",
ZIndex=5,
},topbar)
make("UICorner",{CornerRadius=UDim.new(0,7)},btn)
return btn
end
local closeBtn=topButton(12)
local closeIcon=make("ImageLabel",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,12,0,12),
BackgroundTransparency=1,
Image=Images.CLOSE_ICON,
ImageColor3=iconRole("muted"),
ZIndex=6,
},closeBtn)
local backBtn=topButton(40)
local backIcon=arrowIcon(backBtn,BACK_ARROW_ROTATION,0)
closeBtn.MouseEnter:Connect(function()
tween(closeBtn,0.15,{BackgroundTransparency=0})
if tintIcons then
tween(closeIcon,0.15,{ImageColor3=C.text})
end
end)
closeBtn.MouseLeave:Connect(function()
tween(closeBtn,0.15,{BackgroundTransparency=1})
if tintIcons then
tween(closeIcon,0.15,{ImageColor3=C.muted})
end
end)
backBtn.MouseEnter:Connect(function()
tween(backBtn,0.15,{BackgroundTransparency=0})
tintArrow(backIcon,C.text)
end)
backBtn.MouseLeave:Connect(function()
tween(backBtn,0.15,{BackgroundTransparency=1})
tintArrow(backIcon,C.muted)
end)
local tabsStyle="1"
local function normalizeStyle(value)
value=tostring(value or"1"):lower()
if value=="2"or value=="horizontal"or value=="row"then
return"2"
end
return"1"
end
if ctx.getTabsStyle then
tabsStyle=normalizeStyle(ctx.getTabsStyle())
end
local topLine=line(page,14,TOPBAR_H,W-28,1)
local tabsLine=line(page,14,TOPBAR_H+TABS_BAR_H,W-28,1)
local sideLine=line(page,SIDE_W,TOPBAR_H+10,1,H-TOPBAR_H-20)
local sidebar=make("ScrollingFrame",{
Name="Tabs",
BackgroundTransparency=1,
BorderSizePixel=0,
CanvasSize=UDim2 .new(0,0,0,0),
ElasticBehavior=Enum.ElasticBehavior.Never,
ScrollBarThickness=0,
},page)
local sideLayout=make("UIListLayout",{
Padding=UDim.new(0,4),
SortOrder=Enum.SortOrder.LayoutOrder,
},sidebar)
local sidePadding=make("UIPadding",{},sidebar)
local holder=make("Frame",{
Name="TabContent",
BackgroundTransparency=1,
BorderSizePixel=0,
ClipsDescendants=true,
},page)
sidebar.InputChanged:Connect(function(input)
if tabsStyle=="2"and input.UserInputType==Enum.UserInputType.MouseWheel then
local maxX=math.max(0,sidebar.AbsoluteCanvasSize.X-sidebar.AbsoluteWindowSize.X)
local x=sidebar.CanvasPosition.X-input.Position.Z*30
sidebar.CanvasPosition=Vector2 .new(math.clamp(x,0,maxX),0)
end
end)
local tabs={}
local current=nil
local function applyTabsStyle()
local row=tabsStyle=="2"
topLine.Visible=not row
sideLine.Visible=not row
tabsLine.Visible=row
sidebar.CanvasPosition=Vector2 .new(0,0)
sidebar.AutomaticCanvasSize=Enum.AutomaticSize.None
sidebar.CanvasSize=UDim2 .new(0,0,0,0)
if row then
sidebar.Position=UDim2 .new(0,0,0,TOPBAR_H)
sidebar.Size=UDim2 .new(0,W,0,TABS_BAR_H)
sidebar.ScrollingDirection=Enum.ScrollingDirection.X
sidebar.AutomaticCanvasSize=Enum.AutomaticSize.X
sideLayout.FillDirection=Enum.FillDirection.Horizontal
sideLayout.VerticalAlignment=Enum.VerticalAlignment.Center
sidePadding.PaddingTop=UDim.new(0,0)
sidePadding.PaddingBottom=UDim.new(0,0)
sidePadding.PaddingLeft=UDim.new(0,12)
sidePadding.PaddingRight=UDim.new(0,12)
holder.Position=UDim2 .new(0,0,0,TOPBAR_H+TABS_BAR_H+1)
holder.Size=UDim2 .new(0,W,0,H-TOPBAR_H-TABS_BAR_H-1)
else
sidebar.Position=UDim2 .new(0,0,0,TOPBAR_H+1)
sidebar.Size=UDim2 .new(0,SIDE_W,0,H-TOPBAR_H-1)
sidebar.ScrollingDirection=Enum.ScrollingDirection.Y
sidebar.AutomaticCanvasSize=Enum.AutomaticSize.Y
sideLayout.FillDirection=Enum.FillDirection.Vertical
sideLayout.VerticalAlignment=Enum.VerticalAlignment.Top
sidePadding.PaddingTop=UDim.new(0,10)
sidePadding.PaddingBottom=UDim.new(0,10)
sidePadding.PaddingLeft=UDim.new(0,10)
sidePadding.PaddingRight=UDim.new(0,10)
holder.Position=UDim2 .new(0,SIDE_W+1,0,TOPBAR_H+1)
holder.Size=UDim2 .new(0,W-SIDE_W-1,0,H-TOPBAR_H-1)
end
for _,tab in ipairs(tabs)do
tab.applyStyle()
end
if current then
current.refresh()
end
end
local opened,moving=false,false
local function open()
if opened or moving then
return
end
opened,moving=true,true
if ctx.onOpen then
ctx.onOpen()
end
if current then
current.refresh()
end
page.Visible=true
tween(page,SLIDE_TIME,{Position=UDim2 .new(0.5,0,0.5,0)},Quint)
tween(content,SLIDE_TIME,{Position=UDim2 .new(0.5,0,0.5,-H)},Quint)
task.delay(SLIDE_TIME+0.05,function()
moving=false
end)
end
local function back()
if not opened or moving then
return
end
opened,moving=false,true
tween(page,SLIDE_TIME,{Position=UDim2 .new(0.5,0,0.5,H)},Quint)
tween(content,SLIDE_TIME,{Position=UDim2 .new(0.5,0,0.5,0)},Quint)
task.delay(SLIDE_TIME+0.05,function()
if not opened then
page.Visible=false
end
moving=false
end)
end
local function fadeOut(time)
if not page.Visible then
return
end
fade(prep(page),0,time)
task.delay(time,function()
page.Visible=false
end)
end
local nextBtn=make("TextButton",{
Name="NextPage",
AnchorPoint=Vector2 .new(0.5,1),
Position=UDim2 .new(0,W/2,0,H-2),
Size=UDim2 .new(0,40,0,20),
BackgroundTransparency=1,
BorderSizePixel=0,
AutoButtonColor=false,
Text="",
Visible=false,
ZIndex=5,
},content)
local nextIcon=arrowIcon(nextBtn,NEXT_ARROW_ROTATION,2)
nextBtn.MouseEnter:Connect(function()
tintArrow(nextIcon,C.text)
end)
nextBtn.MouseLeave:Connect(function()
tintArrow(nextIcon,C.muted)
end)
nextBtn.MouseButton1Click:Connect(function()
if not state.ready or state.closing then
return
end
open()
end)
backBtn.MouseButton1Click:Connect(function()
if not state.ready or state.closing then
return
end
back()
end)
closeBtn.MouseButton1Click:Connect(function()
ctx.requestClose()
end)
local function styleTab(tab,on)
tween(tab.btn,0.15,{BackgroundTransparency=on and 0 or 1})
setRole(tab.label,"TextColor3",on and"text"or"muted")
if tab.iconImage then
local role=iconRole(on and"accent"or"muted")
if type(role)=="string"then
setRole(tab.iconImage,"ImageColor3",role)
end
end
tab.scroll.Visible=on
end
local originals=setmetatable({},{__mode="k"})
local function snapshot(child)
local items=prep(child)
for _,it in ipairs(items)do
local saved=originals[it[1]]
if not saved then
saved={}
originals[it[1]]=saved
end
if saved[it[2]]==nil then
saved[it[2]]=it[3]
else
it[3]=saved[it[2]]
end
end
return items
end
local function animateIn(tab)
tab.animId=(tab.animId or 0)+1
local id=tab.animId
local children={}
for _,child in ipairs(tab.scroll:GetChildren())do
if child:IsA("GuiObject")then
children[#children+1]=child
end
end
table.sort(children,function(a,b)
return a.LayoutOrder<b.LayoutOrder
end)
if#children==0 then
return
end
local lists={}
for i,child in ipairs(children)do
local items=snapshot(child)
fade(items,0)
lists[i]=items
end
tab.scroll.Position=UDim2 .new(0,0,0,TAB_SLIDE)
tween(tab.scroll,TAB_IN_TIME+0.08,{Position=UDim2 .new(0,0,0,0)},Quint)
local step=math.min(TAB_STAGGER,TAB_STAGGER_MAX/#children)
for i,items in ipairs(lists)do
task.delay((i-1)*step,function()
if tab.animId~=id then
return
end
fade(items,1,TAB_IN_TIME)
end)
end
end
local function selectTab(tab,animate)
if current==tab then
return
end
if current then
styleTab(current,false)
end
current=tab
styleTab(tab,true)
tab.refresh()
if animate~=false and(opened or page.Visible)then
animateIn(tab)
end
end
local function createTab(props)
if type(props)~="table"then
props={Title=props}
end
local title=props.Title~=nil and tostring(props.Title)or"Tab"
local image=assetId(props.Icon)
local tab={}
tab.btn=make("TextButton",{
Name="Tab",
Size=UDim2 .new(1,0,0,30),
BackgroundColor3="card",
BackgroundTransparency=1,
BorderSizePixel=0,
AutoButtonColor=false,
Text="",
LayoutOrder=#tabs+1,
},sidebar)
round(tab.btn,7)
tab.inner=make("Frame",{
Name="Inner",
Size=UDim2 .new(1,0,1,0),
BackgroundTransparency=1,
BorderSizePixel=0,
},tab.btn)
tab.pad=make("UIPadding",{},tab.inner)
make("UIListLayout",{
FillDirection=Enum.FillDirection.Horizontal,
Padding=UDim.new(0,6),
VerticalAlignment=Enum.VerticalAlignment.Center,
SortOrder=Enum.SortOrder.LayoutOrder,
},tab.inner)
if image then
local iconHolder=icon(tab.inner,0,0,"muted",image)
iconHolder.LayoutOrder=1
tab.iconImage=iconHolder:FindFirstChild("iconimage")
end
tab.label=make("TextLabel",{
Size=UDim2 .new(1,image and-22 or 0,1,0),
BackgroundTransparency=1,
BorderSizePixel=0,
Text=title,
TextSize=12,
TextColor3="muted",
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
TextTruncate=Enum.TextTruncate.AtEnd,
FontFace=FONT,
LayoutOrder=2,
},tab.inner)
tab.applyStyle=function()
if tabsStyle=="2"then
tab.btn.Size=UDim2 .new(0,0,0,TAB_H_STYLE2)
tab.btn.AutomaticSize=Enum.AutomaticSize.X
tab.inner.Size=UDim2 .new(0,0,1,0)
tab.inner.AutomaticSize=Enum.AutomaticSize.X
tab.pad.PaddingLeft=UDim.new(0,10)
tab.pad.PaddingRight=UDim.new(0,12)
tab.label.Size=UDim2 .new(0,0,1,0)
tab.label.AutomaticSize=Enum.AutomaticSize.X
else
tab.btn.AutomaticSize=Enum.AutomaticSize.None
tab.btn.Size=UDim2 .new(1,0,0,30)
tab.inner.AutomaticSize=Enum.AutomaticSize.None
tab.inner.Size=UDim2 .new(1,0,1,0)
tab.pad.PaddingLeft=UDim.new(0,12)
tab.pad.PaddingRight=UDim.new(0,8)
tab.label.AutomaticSize=Enum.AutomaticSize.None
tab.label.Size=UDim2 .new(1,image and-22 or 0,1,0)
end
end
tab.applyStyle()
tab.scroll=make("ScrollingFrame",{
Name="TabContent",
Size=UDim2 .new(1,0,1,0),
BackgroundTransparency=1,
BorderSizePixel=0,
CanvasSize=UDim2 .new(0,0,0,0),
ScrollingDirection=Enum.ScrollingDirection.Y,
ElasticBehavior=Enum.ElasticBehavior.Never,
VerticalScrollBarInset=Enum.ScrollBarInset.None,
ScrollBarThickness=2,
ScrollBarImageTransparency=0.45,
Visible=false,
},holder)
setRole(tab.scroll,"ScrollBarImageColor3","muted")
local layout=make("UIListLayout",{
Padding=UDim.new(0,8),
SortOrder=Enum.SortOrder.LayoutOrder,
},tab.scroll)
make("UIPadding",{
PaddingTop=UDim.new(0,12),
PaddingBottom=UDim.new(0,12),
PaddingLeft=UDim.new(0,12),
PaddingRight=UDim.new(0,14),
},tab.scroll)
tab.refresh=function()
tab.scroll.CanvasSize=UDim2 .new(0,0,0,layout.AbsoluteContentSize.Y+24)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(tab.refresh)
tab.btn.MouseEnter:Connect(function()
if current~=tab then
tween(tab.btn,0.12,{BackgroundTransparency=0.5})
end
end)
tab.btn.MouseLeave:Connect(function()
if current~=tab then
tween(tab.btn,0.12,{BackgroundTransparency=1})
end
end)
tab.btn.MouseButton1Click:Connect(function()
if state.closing then
return
end
selectTab(tab)
end)
tabs[#tabs+1]=tab
if not nextBtn.Visible then
nextBtn.Visible=true
task.defer(function()
nextIcon.Image=""
nextIcon.Image=Images.SUBMIT
end)
end
if not current then
selectTab(tab,false)
end
local order=0
local function nextOrder()
order=order+1
return order
end
local obj={}
function obj:Select()
selectTab(tab)
return self
end
function obj:Section(p)
p=type(p)=="table"and p or{}
local sectionImage=assetId(p.Icon)
local row=make("Frame",{
Name="Section",
Size=UDim2 .new(1,0,0,26),
BackgroundTransparency=1,
BorderSizePixel=0,
LayoutOrder=nextOrder(),
},tab.scroll)
make("UIListLayout",{
FillDirection=Enum.FillDirection.Horizontal,
Padding=UDim.new(0,7),
VerticalAlignment=Enum.VerticalAlignment.Center,
SortOrder=Enum.SortOrder.LayoutOrder,
},row)
if sectionImage then
local iconHolder=icon(row,0,0,"accent",sectionImage)
iconHolder.LayoutOrder=1
end
local label=make("TextLabel",{
Size=UDim2 .new(1,sectionImage and-23 or 0,1,0),
BackgroundTransparency=1,
BorderSizePixel=0,
Text=p.Title~=nil and tostring(p.Title)or"Section",
TextSize=SECTION_TEXT_SIZE,
TextColor3="text",
TextTransparency=SECTION_TEXT_TRANSPARENCY,
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
TextTruncate=Enum.TextTruncate.AtEnd,
FontFace=FONT_BOLD,
LayoutOrder=2,
},row)
local section={Frame=row}
function section:SetTitle(str)
label.Text=tostring(str)
return self
end
function section:Destroy()
row:Destroy()
end
return section
end
function obj:Paragraph(p)
p=type(p)=="table"and p or{}
local color=parseColor(p.Color)
local onColor=color and contrastOn(color)or nil
local box=make("Frame",{
Name="Paragraph",
Size=UDim2 .new(1,0,0,0),
AutomaticSize=Enum.AutomaticSize.Y,
BackgroundColor3=color or"card",
BackgroundTransparency=0,
BorderSizePixel=0,
LayoutOrder=nextOrder(),
},tab.scroll)
round(box,8,(not color)and"stroke"or nil)
make("UIPadding",{
PaddingTop=UDim.new(0,10),
PaddingBottom=UDim.new(0,10),
PaddingLeft=UDim.new(0,12),
PaddingRight=UDim.new(0,12),
},box)
make("UIListLayout",{
Padding=UDim.new(0,6),
SortOrder=Enum.SortOrder.LayoutOrder,
},box)
local top=make("Frame",{
Name="Main",
Size=UDim2 .new(1,0,0,0),
AutomaticSize=Enum.AutomaticSize.Y,
BackgroundTransparency=1,
BorderSizePixel=0,
LayoutOrder=1,
},box)
make("UIListLayout",{
FillDirection=Enum.FillDirection.Horizontal,
Padding=UDim.new(0,10),
VerticalAlignment=Enum.VerticalAlignment.Top,
SortOrder=Enum.SortOrder.LayoutOrder,
},top)
local IMAGE_GAP=10
local imageSize=parseImageSize(p.ImageSize)
local imageLabel
local textCol=make("Frame",{
Name="Text",
Size=UDim2 .new(1,0,0,0),
AutomaticSize=Enum.AutomaticSize.Y,
BackgroundTransparency=1,
BorderSizePixel=0,
LayoutOrder=2,
},top)
make("UIListLayout",{
Padding=UDim.new(0,6),
SortOrder=Enum.SortOrder.LayoutOrder,
},textCol)
local function layoutImage()
if imageLabel and imageLabel.Visible then
imageLabel.Size=imageSize
textCol.Size=UDim2 .new(1,-(imageSize.X.Offset+IMAGE_GAP),0,0)
else
textCol.Size=UDim2 .new(1,0,0,0)
end
end
local imageToken=0
local function applyImage(value)
imageToken=imageToken+1
local token=imageToken
local gameId=type(value)=="string"and value:match("^rbxgame://%s*(%d+)")or nil
local image=(not gameId)and assetId(value)or nil
if not image and not gameId then
if imageLabel then
imageLabel.Visible=false
end
layoutImage()
return
end
if not imageLabel then
imageLabel=make("ImageLabel",{
Name="Image",
BackgroundTransparency=1,
BorderSizePixel=0,
ScaleType=Enum.ScaleType.Fit,
LayoutOrder=1,
},top)
round(imageLabel,6)
end
imageLabel.Visible=true
layoutImage()
if gameId then
imageLabel.ImageColor3=Color3 .new(1,1,1)
imageLabel.ImageRectSize=Vector2 .new(0,0)
imageLabel.ImageRectOffset=Vector2 .new(0,0)
imageLabel.Image=""
resolveGameIcon(gameId,function(url)
if token==imageToken and imageLabel.Parent then
imageLabel.Image=url
end
end)
return
end
imageLabel.ImageColor3=Lucide.isName(image)and(onColor or"text")or Color3 .new(1,1,1)
Lucide.apply(imageLabel,image)
end
applyImage(p.Image)
local function paragraphLabel(layoutOrder,size,font,textColor,str,transparency)
return make("TextLabel",{
Size=UDim2 .new(1,0,0,0),
AutomaticSize=Enum.AutomaticSize.Y,
BackgroundTransparency=1,
BorderSizePixel=0,
Text=str,
TextSize=size,
TextColor3=textColor,
TextTransparency=transparency,
TextWrapped=true,
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Top,
FontFace=font,
LayoutOrder=layoutOrder,
Visible=str~="",
},textCol)
end
local titleText=p.Title~=nil and tostring(p.Title)or""
local descText=p.Desc~=nil and tostring(p.Desc)or""
local titleLabel=paragraphLabel(1,13,FONT_BOLD,onColor or"text",titleText,0)
local descLabel=paragraphLabel(2,12,FONT,onColor or"muted",descText,onColor and 0.2 or 0)
local buttons=type(p.Buttons)=="table"and p.Buttons or{}
if#buttons>0 then
local row=make("Frame",{
Name="Buttons",
Size=UDim2 .new(1,0,0,0),
AutomaticSize=Enum.AutomaticSize.Y,
BackgroundTransparency=1,
BorderSizePixel=0,
LayoutOrder=2,
},box)
make("UIListLayout",{
FillDirection=Enum.FillDirection.Horizontal,
Wraps=true,
Padding=UDim.new(0,6),
SortOrder=Enum.SortOrder.LayoutOrder,
},row)
for i,b in ipairs(buttons)do
if type(b)=="table"then
local btn=make("TextButton",{
Name="Button",
Size=UDim2 .new(0,0,0,26),
AutomaticSize=Enum.AutomaticSize.X,
BackgroundColor3=color and onColor or"btn2",
BackgroundTransparency=color and 0.86 or 0,
BorderSizePixel=0,
AutoButtonColor=false,
Text="",
LayoutOrder=i,
},row)
round(btn,7,(not color)and"stroke"or nil)
make("UIPadding",{
PaddingLeft=UDim.new(0,9),
PaddingRight=UDim.new(0,10),
},btn)
make("UIListLayout",{
FillDirection=Enum.FillDirection.Horizontal,
Padding=UDim.new(0,6),
VerticalAlignment=Enum.VerticalAlignment.Center,
SortOrder=Enum.SortOrder.LayoutOrder,
},btn)
local buttonImage=assetId(b.Icon)
if buttonImage then
local iconHolder=icon(btn,0,0,onColor or"text",buttonImage)
iconHolder.LayoutOrder=1
end
make("TextLabel",{
Size=UDim2 .new(0,0,1,0),
AutomaticSize=Enum.AutomaticSize.X,
BackgroundTransparency=1,
BorderSizePixel=0,
Text=b.Title~=nil and tostring(b.Title)or"Button",
TextSize=12,
TextColor3=onColor or"text",
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
FontFace=FONT,
LayoutOrder=2,
},btn)
btn.MouseEnter:Connect(function()
if color then
tween(btn,0.12,{BackgroundTransparency=0.72})
else
tween(btn,0.12,{BackgroundColor3=C.btn2Hover})
end
end)
btn.MouseLeave:Connect(function()
if color then
tween(btn,0.12,{BackgroundTransparency=0.86})
else
tween(btn,0.12,{BackgroundColor3=C.btn2})
end
end)
btn.MouseButton1Click:Connect(function()
if state.closing or type(b.Callback)~="function"then
return
end
task.spawn(function()
local ok,err=pcall(b.Callback)
if not ok then
warn("[Ophyn] Button callback error: "..tostring(err))
end
end)
end)
end
end
end
local paragraph={Frame=box}
function paragraph:SetTitle(str)
titleLabel.Text=tostring(str)
titleLabel.Visible=titleLabel.Text~=""
return self
end
function paragraph:SetDesc(str)
descLabel.Text=tostring(str)
descLabel.Visible=descLabel.Text~=""
return self
end
function paragraph:SetImage(value)
applyImage(value)
return self
end
function paragraph:SetImageSize(value)
imageSize=parseImageSize(value)
layoutImage()
return self
end
function paragraph:Destroy()
box:Destroy()
end
return paragraph
end
return obj
end
applyTabsStyle()
if ctx.registerTabsStyle then
ctx.registerTabsStyle(function()
if not page.Parent then
return false
end
local style=normalizeStyle(ctx.getTabsStyle and ctx.getTabsStyle())
if style~=tabsStyle then
tabsStyle=style
applyTabsStyle()
end
return true
end)
end
return{
createTab=createTab,
open=open,
back=back,
fadeOut=fadeOut,
isOpen=function()
return opened
end,
}
end
return Pages
end
__modules["components/window/ui"]=function()
local TweenService=game:GetService("TweenService")
local Players=game:GetService("Players")
local HttpService=game:GetService("HttpService")
local UserInputService=game:GetService("UserInputService")
local MarketplaceService=game:GetService("MarketplaceService")
local player=Players.LocalPlayer
local Images=import("images/images")
local Notification=import("components/window/notification")
local Variables=import("variables")
local Jnkie=import("utilities/jnkie")
local Platoboost=import("utilities/platoboost")
local Panda=import("utilities/panda")
local Pages=import("components/window/pages")
local Lucide=import("utilities/lucide")
local FONT=Font.new(Images.FONT,Enum.FontWeight.Regular,Enum.FontStyle.Normal)
local FONT_BOLD=Font.new(Images.FONT,Enum.FontWeight.Bold,Enum.FontStyle.Normal)
local GLOW=Images.GLOW
local CLOSE_ICON=Images.CLOSE_ICON
local MOON_ICON=Images.MOON_ICON
local FINAL_W,FINAL_H=460,260
local NOTIF_W,NOTIF_H=300,70
local NOTIF_TRANSPARENCY=0.28
local NOTIF_COLOR="bg"
local NOTIF_BLUR=6
local CHECK_TIME=1
local SAVED_CHECK_TIME=0.15
local WHITE=Color3 .fromRGB(255,255,255)
local settings={tintIcons=true,tintLogo=true}
local function asBool(v,default)
if v==nil then
return default
end
if type(v)=="string"then
return v:lower()=="true"
end
return v==true
end
local function assetId(v)
if v==nil or v==""then
return nil
end
local str=tostring(v)
if str:match("^%d+$")then
return"rbxassetid://"..str
end
return str
end
local function iconRole(role)
return settings.tintIcons and role or WHITE
end
local function logoRole(role)
return settings.tintLogo and role or WHITE
end
local THEME_ORDER={
"Carmim",
"Plant",
"Plant-Dark",
"Dark",
"Light",
"Violet",
"Midnight",
"Amber",
"Indigo",
"Amethyst",
}
local THEMES={
Amethyst={
bg=Color3 .fromRGB(20,16,20),
input=Color3 .fromRGB(24,19,24),
card=Color3 .fromRGB(28,22,28),
stroke=Color3 .fromRGB(40,32,41),
btn2=Color3 .fromRGB(42,36,43),
btn2Hover=Color3 .fromRGB(54,47,55),
text=Color3 .fromRGB(233,229,234),
muted=Color3 .fromRGB(125,115,126),
accent=Color3 .fromRGB(235,199,246),
warn=Color3 .fromRGB(240,176,108),
success=Color3 .fromRGB(120,210,140),
error=Color3 .fromRGB(240,120,120),
submitBg=Color3 .fromRGB(235,199,246),
submitText=Color3 .fromRGB(24,18,26),
glowBase=Color3 .fromRGB(226,218,230),
glowFrom=Color3 .fromRGB(255,255,255),
glowTo=Color3 .fromRGB(235,199,246),
confetti={
Color3 .fromRGB(235,199,246),
Color3 .fromRGB(120,210,140),
Color3 .fromRGB(255,255,255),
Color3 .fromRGB(240,176,108),
Color3 .fromRGB(150,190,255),
},
},
Carmim={
bg=Color3 .fromRGB(10,10,10),
input=Color3 .fromRGB(16,14,14),
card=Color3 .fromRGB(20,17,17),
stroke=Color3 .fromRGB(38,32,32),
btn2=Color3 .fromRGB(32,28,28),
btn2Hover=Color3 .fromRGB(46,40,40),
text=Color3 .fromRGB(240,236,236),
muted=Color3 .fromRGB(130,122,122),
accent=Color3 .fromRGB(230,45,55),
warn=Color3 .fromRGB(240,176,108),
success=Color3 .fromRGB(120,210,140),
error=Color3 .fromRGB(240,120,120),
submitBg=Color3 .fromRGB(139,17,27),
submitText=Color3 .fromRGB(255,255,255),
glowBase=Color3 .fromRGB(255,120,120),
glowFrom=Color3 .fromRGB(255,90,90),
glowTo=Color3 .fromRGB(200,20,35),
confetti={
Color3 .fromRGB(230,45,55),
Color3 .fromRGB(255,120,120),
Color3 .fromRGB(255,255,255),
Color3 .fromRGB(240,176,108),
Color3 .fromRGB(150,20,30),
},
},
Plant={
bg=Color3 .fromRGB(28,94,56),
input=Color3 .fromRGB(23,78,46),
card=Color3 .fromRGB(34,108,65),
stroke=Color3 .fromRGB(58,140,92),
btn2=Color3 .fromRGB(44,122,74),
btn2Hover=Color3 .fromRGB(56,140,88),
text=Color3 .fromRGB(255,255,255),
muted=Color3 .fromRGB(188,226,202),
accent=Color3 .fromRGB(255,255,255),
warn=Color3 .fromRGB(255,214,140),
success=Color3 .fromRGB(200,255,210),
error=Color3 .fromRGB(255,150,150),
submitBg=Color3 .fromRGB(96,205,122),
submitText=Color3 .fromRGB(14,66,36),
glowBase=Color3 .fromRGB(255,255,255),
glowFrom=Color3 .fromRGB(255,255,255),
glowTo=Color3 .fromRGB(235,255,240),
confetti={
Color3 .fromRGB(255,255,255),
Color3 .fromRGB(150,235,170),
Color3 .fromRGB(96,205,122),
Color3 .fromRGB(255,214,140),
Color3 .fromRGB(210,255,220),
},
},
["Plant-Dark"]={
bg=Color3 .fromRGB(10,10,10),
input=Color3 .fromRGB(14,16,14),
card=Color3 .fromRGB(18,22,19),
stroke=Color3 .fromRGB(34,42,36),
btn2=Color3 .fromRGB(28,34,29),
btn2Hover=Color3 .fromRGB(40,48,42),
text=Color3 .fromRGB(238,242,238),
muted=Color3 .fromRGB(122,132,124),
accent=Color3 .fromRGB(70,214,110),
warn=Color3 .fromRGB(240,176,108),
success=Color3 .fromRGB(120,220,150),
error=Color3 .fromRGB(240,120,120),
submitBg=Color3 .fromRGB(22,101,52),
submitText=Color3 .fromRGB(255,255,255),
glowBase=Color3 .fromRGB(110,255,150),
glowFrom=Color3 .fromRGB(90,240,130),
glowTo=Color3 .fromRGB(30,170,70),
confetti={
Color3 .fromRGB(70,214,110),
Color3 .fromRGB(150,245,175),
Color3 .fromRGB(255,255,255),
Color3 .fromRGB(240,176,108),
Color3 .fromRGB(22,101,52),
},
},
Dark={
bg=Color3 .fromRGB(10,10,10),
input=Color3 .fromRGB(18,18,18),
card=Color3 .fromRGB(23,23,23),
stroke=Color3 .fromRGB(46,46,46),
btn2=Color3 .fromRGB(34,34,34),
btn2Hover=Color3 .fromRGB(48,48,48),
text=Color3 .fromRGB(255,255,255),
muted=Color3 .fromRGB(150,150,150),
accent=Color3 .fromRGB(255,255,255),
warn=Color3 .fromRGB(240,176,108),
success=Color3 .fromRGB(120,210,140),
error=Color3 .fromRGB(240,120,120),
submitBg=Color3 .fromRGB(66,66,66),
submitText=Color3 .fromRGB(255,255,255),
glowBase=Color3 .fromRGB(255,255,255),
glowFrom=Color3 .fromRGB(255,255,255),
glowTo=Color3 .fromRGB(210,210,210),
confetti={
Color3 .fromRGB(255,255,255),
Color3 .fromRGB(200,200,200),
Color3 .fromRGB(140,140,140),
Color3 .fromRGB(240,176,108),
Color3 .fromRGB(120,210,140),
},
},
Light={
bg=Color3 .fromRGB(255,255,255),
input=Color3 .fromRGB(240,240,240),
card=Color3 .fromRGB(245,245,245),
stroke=Color3 .fromRGB(216,216,216),
btn2=Color3 .fromRGB(232,232,232),
btn2Hover=Color3 .fromRGB(218,218,218),
text=Color3 .fromRGB(10,10,10),
muted=Color3 .fromRGB(110,110,110),
accent=Color3 .fromRGB(10,10,10),
warn=Color3 .fromRGB(196,116,24),
success=Color3 .fromRGB(28,150,72),
error=Color3 .fromRGB(210,58,58),
submitBg=Color3 .fromRGB(20,20,20),
submitText=Color3 .fromRGB(255,255,255),
glowBase=Color3 .fromRGB(30,30,30),
glowFrom=Color3 .fromRGB(60,60,60),
glowTo=Color3 .fromRGB(0,0,0),
confetti={
Color3 .fromRGB(10,10,10),
Color3 .fromRGB(90,90,90),
Color3 .fromRGB(160,160,160),
Color3 .fromRGB(230,150,50),
Color3 .fromRGB(50,170,100),
},
},
Violet={
bg=Color3 .fromRGB(94,64,162),
input=Color3 .fromRGB(78,52,140),
card=Color3 .fromRGB(108,78,180),
stroke=Color3 .fromRGB(136,108,204),
btn2=Color3 .fromRGB(120,90,192),
btn2Hover=Color3 .fromRGB(136,106,208),
text=Color3 .fromRGB(255,255,255),
muted=Color3 .fromRGB(214,202,242),
accent=Color3 .fromRGB(255,255,255),
warn=Color3 .fromRGB(255,214,140),
success=Color3 .fromRGB(200,255,210),
error=Color3 .fromRGB(255,160,170),
submitBg=Color3 .fromRGB(58,32,112),
submitText=Color3 .fromRGB(255,255,255),
glowBase=Color3 .fromRGB(255,255,255),
glowFrom=Color3 .fromRGB(255,255,255),
glowTo=Color3 .fromRGB(240,232,255),
confetti={
Color3 .fromRGB(255,255,255),
Color3 .fromRGB(214,190,255),
Color3 .fromRGB(170,130,255),
Color3 .fromRGB(255,214,140),
Color3 .fromRGB(58,32,112),
},
},
Midnight={
bg=Color3 .fromRGB(26,44,104),
input=Color3 .fromRGB(18,32,80),
card=Color3 .fromRGB(34,56,124),
stroke=Color3 .fromRGB(62,88,158),
btn2=Color3 .fromRGB(44,70,142),
btn2Hover=Color3 .fromRGB(58,86,164),
text=Color3 .fromRGB(255,255,255),
muted=Color3 .fromRGB(190,204,240),
accent=Color3 .fromRGB(255,255,255),
warn=Color3 .fromRGB(255,214,140),
success=Color3 .fromRGB(190,255,215),
error=Color3 .fromRGB(255,150,160),
submitBg=Color3 .fromRGB(52,92,196),
submitText=Color3 .fromRGB(255,255,255),
glowBase=Color3 .fromRGB(255,255,255),
glowFrom=Color3 .fromRGB(255,255,255),
glowTo=Color3 .fromRGB(226,236,255),
confetti={
Color3 .fromRGB(255,255,255),
Color3 .fromRGB(170,200,255),
Color3 .fromRGB(100,150,255),
Color3 .fromRGB(255,214,140),
Color3 .fromRGB(52,92,196),
},
},
Amber={
bg=Color3 .fromRGB(160,84,16),
input=Color3 .fromRGB(132,68,10),
card=Color3 .fromRGB(176,98,28),
stroke=Color3 .fromRGB(206,132,62),
btn2=Color3 .fromRGB(186,108,38),
btn2Hover=Color3 .fromRGB(200,122,52),
text=Color3 .fromRGB(255,255,255),
muted=Color3 .fromRGB(255,228,196),
accent=Color3 .fromRGB(255,255,255),
warn=Color3 .fromRGB(255,240,170),
success=Color3 .fromRGB(215,255,205),
error=Color3 .fromRGB(110,18,18),
submitBg=Color3 .fromRGB(110,50,6),
submitText=Color3 .fromRGB(255,255,255),
glowBase=Color3 .fromRGB(255,255,255),
glowFrom=Color3 .fromRGB(255,255,255),
glowTo=Color3 .fromRGB(255,240,220),
confetti={
Color3 .fromRGB(255,255,255),
Color3 .fromRGB(255,220,160),
Color3 .fromRGB(255,180,90),
Color3 .fromRGB(255,240,170),
Color3 .fromRGB(110,50,6),
},
},
Indigo={
bg=Color3 .fromRGB(20,14,58),
input=Color3 .fromRGB(15,10,46),
card=Color3 .fromRGB(28,20,76),
stroke=Color3 .fromRGB(50,40,112),
btn2=Color3 .fromRGB(38,29,96),
btn2Hover=Color3 .fromRGB(52,42,122),
text=Color3 .fromRGB(240,238,255),
muted=Color3 .fromRGB(150,142,204),
accent=Color3 .fromRGB(150,132,255),
warn=Color3 .fromRGB(240,190,120),
success=Color3 .fromRGB(120,220,160),
error=Color3 .fromRGB(255,120,140),
submitBg=Color3 .fromRGB(84,64,210),
submitText=Color3 .fromRGB(255,255,255),
glowBase=Color3 .fromRGB(160,140,255),
glowFrom=Color3 .fromRGB(140,120,255),
glowTo=Color3 .fromRGB(90,70,230),
confetti={
Color3 .fromRGB(150,132,255),
Color3 .fromRGB(200,190,255),
Color3 .fromRGB(255,255,255),
Color3 .fromRGB(240,190,120),
Color3 .fromRGB(84,64,210),
},
},
}
local themeIndex=1
local C={}
local function loadTheme(theme)
for k,v in pairs(theme)do
C[k]=v
end
end
local COLOR_PROPS={
BackgroundColor3=true,
TextColor3=true,
ImageColor3=true,
Color=true,
PlaceholderColor3=true,
}
local bindings={}
local gradients={}
local fontBindings={}
local fontSettings={ui=nil,title=nil}
local function fontFor(entryFont)
if entryFont.title and fontSettings.title then
local t=fontSettings.title
if entryFont.bold then
return Font.new(t.Family,Enum.FontWeight.Bold,t.Style)
end
return t
end
if fontSettings.ui then
local u=fontSettings.ui
if entryFont.bold then
return Font.new(u.Family,Enum.FontWeight.Bold,u.Style)
end
return u
end
return entryFont.bold and FONT_BOLD or FONT
end
local function applyFontAll()
for _,entryFont in ipairs(fontBindings)do
if entryFont.inst.Parent then
entryFont.inst.FontFace=fontFor(entryFont)
end
end
end
local function markTitleFont(inst)
for _,entryFont in ipairs(fontBindings)do
if entryFont.inst==inst then
entryFont.title=true
inst.FontFace=fontFor(entryFont)
return
end
end
end
local function markBoldFont(inst)
for _,entryFont in ipairs(fontBindings)do
if entryFont.inst==inst then
entryFont.bold=true
inst.FontFace=fontFor(entryFont)
return
end
end
end
local function resolveFont(input)
if input==nil then
return nil
end
if typeof(input)=="Font"then
return input
end
if type(input)=="table"then
return Font.new(input.Family or input.family,input.Weight or Enum.FontWeight.Regular,input.Style or Enum.FontStyle.Normal)
end
local name=tostring(input)
local ok,enumFont=pcall(function()
return Enum.Font[name]
end)
if ok and typeof(enumFont)=="EnumItem"then
return Font.fromEnum(enumFont)
end
local family=name
if family:match("^%d+$")then
family="rbxassetid://"..family
end
return Font.new(family,Enum.FontWeight.Regular,Enum.FontStyle.Normal)
end
local function make(class,props,parent)
local inst=Instance.new(class)
for k,v in pairs(props)do
if type(v)=="string"and COLOR_PROPS[k]then
bindings[#bindings+1]={inst,k,v}
inst[k]=C[v]
elseif k=="FontFace"and(v==FONT or v==FONT_BOLD)then
local entry={inst=inst,bold=(v==FONT_BOLD),title=false}
fontBindings[#fontBindings+1]=entry
inst[k]=fontFor(entry)
else
inst[k]=v
end
end
inst.Parent=parent
return inst
end
local function unbind(inst,prop)
for i=#bindings,1,-1 do
local b=bindings[i]
if b[1]==inst and b[2]==prop then
table.remove(bindings,i)
end
end
end
local function setRole(inst,prop,role)
local found=false
for _,b in ipairs(bindings)do
if b[1]==inst and b[2]==prop then
b[3]=role
found=true
break
end
end
if not found then
bindings[#bindings+1]={inst,prop,role}
end
inst[prop]=C[role]
end
local function frame(parent,x,y,w,h,color,transparency)
return make("Frame",{
Position=UDim2 .new(0,x,0,y),
Size=UDim2 .new(0,w,0,h),
BackgroundColor3=color or C.bg,
BackgroundTransparency=transparency or 1,
BorderSizePixel=0,
},parent)
end
local function text(parent,str,x,y,w,h,size,color,align)
return make("TextLabel",{
Position=UDim2 .new(0,x,0,y),
Size=UDim2 .new(0,w,0,h),
BackgroundTransparency=1,
BorderSizePixel=0,
Text=str,
TextSize=size,
TextColor3=color,
TextXAlignment=align or Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
FontFace=FONT,
},parent)
end
local function round(parent,radius,strokeColor)
if settings.xngotRadius and radius<15 then
radius=math.clamp(settings.xngotRadius+radius-10,4,28)
end
make("UICorner",{CornerRadius=UDim.new(0,radius)},parent)
if strokeColor then
make("UIStroke",{
Thickness=1,
ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual,
Color=strokeColor,
},parent)
end
end
local function icon(parent,x,y,color,image)
local holder=frame(parent,x,y,16,16)
make("ImageLabel",{
Name="iconglow",
Size=UDim2 .new(2,0,2,0),
Position=UDim2 .new(0.5,0,0.5,0),
AnchorPoint=Vector2 .new(0.5,0.5),
BackgroundTransparency=1,
Image=GLOW,
ImageColor3=color,
ImageTransparency=0.9,
ZIndex=0,
},holder)
local img=make("ImageLabel",{
Name="iconimage",
Size=UDim2 .new(1,0,1,0),
BackgroundTransparency=1,
ImageColor3=iconRole(color),
},holder)
local names={[Images.KEY]="key-round",[Images.SUBMIT]="check",[Images.LINK]="link",[Images.KEYLESS]="circle-check"}
local applied=false
if settings.xngotApplyIcon and names[image]then
local ok,result=pcall(settings.xngotApplyIcon,img,names[image])
applied=ok and result==true
end
if not applied then Lucide.apply(img,image)end
return holder
end
local function decor(parent,w,h,x,y,transparency,rotation)
local img=make("ImageLabel",{
Size=UDim2 .new(0,w,0,h),
Position=UDim2 .new(0,x,0,y),
AnchorPoint=Vector2 .new(0.5,0.5),
BackgroundTransparency=1,
Image=GLOW,
ImageColor3="glowBase",
ImageTransparency=transparency,
ScaleType=Enum.ScaleType.Stretch,
},parent)
local grad=make("UIGradient",{
Rotation=rotation,
Color=ColorSequence.new(C.glowFrom,C.glowTo),
},img)
gradients[#gradients+1]=grad
return img
end
local function centered(parent,w,h)
return make("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,w,0,h),
BackgroundTransparency=1,
BorderSizePixel=0,
},parent)
end
local function tween(inst,time,props,style,dir)
local t=TweenService:Create(
inst,
TweenInfo.new(time,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),
props
)
t:Play()
return t
end
local function ring(parent,size,thickness,color,transparency)
local f=make("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,size,0,size),
BackgroundTransparency=1,
BorderSizePixel=0,
},parent)
make("UICorner",{CornerRadius=UDim.new(1,0)},f)
local stroke=make("UIStroke",{Thickness=thickness,Color=color,Transparency=transparency},f)
return f,stroke
end
local function comet(stroke)
make("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,0),
NumberSequenceKeypoint.new(0.35,0),
NumberSequenceKeypoint.new(0.7,1),
NumberSequenceKeypoint.new(1,1),
}),
},stroke)
end
local function prep(container)
local items={}
local function add(inst)
if inst:IsA("GuiObject")then
items[#items+1]={inst,"BackgroundTransparency",inst.BackgroundTransparency}
if inst:IsA("TextLabel")or inst:IsA("TextButton")or inst:IsA("TextBox")then
items[#items+1]={inst,"TextTransparency",inst.TextTransparency}
elseif inst:IsA("ImageLabel")or inst:IsA("ImageButton")then
items[#items+1]={inst,"ImageTransparency",inst.ImageTransparency}
elseif inst:IsA("ScrollingFrame")then
items[#items+1]={inst,"ScrollBarImageTransparency",inst.ScrollBarImageTransparency}
end
elseif inst:IsA("UIStroke")then
items[#items+1]={inst,"Transparency",inst.Transparency}
end
end
add(container)
for _,d in ipairs(container:GetDescendants())do
add(d)
end
return items
end
local function fade(items,alpha,time)
for _,it in ipairs(items)do
local inst,prop,orig=it[1],it[2],it[3]
local target=1-(1-orig)*alpha
if time and time>0 then
tween(inst,time,{[prop]=target})
else
inst[prop]=target
end
end
end
local function tintTo(inst,color)
if settings.tintIcons then
tween(inst,0.15,{ImageColor3=color})
end
end
local function applyTheme(name,time)
local theme=THEMES[name]
if not theme then
return
end
local oldFrom,oldTo=C.glowFrom,C.glowTo
loadTheme(theme)
local style,dir=Enum.EasingStyle.Sine,Enum.EasingDirection.InOut
for i=#bindings,1,-1 do
local b=bindings[i]
local inst=b[1]
if inst.Parent==nil then
table.remove(bindings,i)
else
tween(inst,time,{[b[2]]=C[b[3]]},style,dir)
end
end
local newFrom,newTo=C.glowFrom,C.glowTo
local driver=Instance.new("NumberValue")
local conn=driver.Changed:Connect(function(a)
local seq=ColorSequence.new(oldFrom:Lerp(newFrom,a),oldTo:Lerp(newTo,a))
for _,g in ipairs(gradients)do
g.Color=seq
end
end)
local t=tween(driver,time,{Value=1},style,dir)
t.Completed:Connect(function()
conn:Disconnect()
driver:Destroy()
for _,g in ipairs(gradients)do
g.Color=ColorSequence.new(newFrom,newTo)
end
end)
end
local UI={}
UI.Jnkie=Jnkie
local getkeySettings={title=nil,icon=nil}
local getkeyAppliers={}
local function applyGetkeyAll()
for _,apply in ipairs(getkeyAppliers)do
apply()
end
end
local getMethods={}
local selectedMethodIndex=nil
function UI.GetMethod(entry)
entry=entry or{}
local method={
title=entry.Title~=nil and tostring(entry.Title)or nil,
icon=entry.Icon,
url=entry.URL,
getKeyLink=entry.GetKeyLink or entry.getKeyLink,
fields=entry,
}
table.insert(getMethods,method)
if not selectedMethodIndex then
selectedMethodIndex=1
end
applyGetkeyAll()
return#getMethods
end
local function contrastOn(color)
local luminance=0.299*color.R+0.587*color.G+0.114*color.B
return luminance>0.55 and Color3 .fromRGB(11,11,11)or Color3 .fromRGB(255,255,255)
end
local notifSettings={style=nil}
function UI.SetNotifStyle(style)
notifSettings.style=style~=nil and tostring(style)or nil
end
local tabsSettings={style=nil}
local tabsAppliers={}
function UI.SetTabsStyle(style)
tabsSettings.style=style~=nil and tostring(style)or nil
for i=#tabsAppliers,1,-1 do
if tabsAppliers[i]()==false then
table.remove(tabsAppliers,i)
end
end
end
function UI.SetUIFont(font)
fontSettings.ui=resolveFont(font)
applyFontAll()
end
function UI.SetTitleFont(font)
fontSettings.title=resolveFont(font)
applyFontAll()
end
function UI.SetGetkeyTitle(title)
getkeySettings.title=title~=nil and tostring(title)or nil
applyGetkeyAll()
end
function UI.SetGetkeyIcon(icon)
getkeySettings.icon=icon
applyGetkeyAll()
end
function UI.new(options)
local cfg={}
for k,v in pairs(Variables)do
cfg[k]=v
end
for k,v in pairs(options or{})do
cfg[k]=v
end
local HUB_NAME=tostring(cfg.Title)
local HUB_SUBTITLE=tostring(cfg.Description)
local FOLDER=cfg.Folder
local LOGO=assetId(cfg.Logo)or Images.LOGO
local iconsPreloaded=false
task.spawn(function()
pcall(function()
local list={}
for _,id in pairs(Images)do
if type(id)=="string"then
table.insert(list,id)
end
end
table.insert(list,LOGO)
game:GetService("ContentProvider"):PreloadAsync(list)
end)
iconsPreloaded=true
end)
local INTRO_SIZE=tonumber(cfg.startintro_size)or 80
local LOADING_TIME=3
local SQUARE_TIME=tonumber(cfg.squareintro_time)or 1.2
local SHOW_SQUARE_CONTORN=asBool(cfg.squarecontorn,true)
settings.tintLogo=asBool(cfg.Changelogocolor,true)
settings.tintIcons=asBool(cfg.Changeiconscolor,true)
settings.xngotApplyIcon=type(cfg.XngotApplyIcon)=="function"and cfg.XngotApplyIcon or nil
settings.xngotRadius=tonumber(cfg.XngotRadius)
local SHOW_GETKEY=asBool(cfg.getkey,true)
local SHOW_CHANGE_THEME=asBool(cfg.ChangeTheme,true)
local themeName=cfg.Theme
if not THEMES[themeName]then
themeName="Amethyst"
end
themeIndex=table.find(THEME_ORDER,themeName)or 1
loadTheme(THEMES[themeName])
if type(cfg.XngotPalette)=="table"then loadTheme(cfg.XngotPalette)end
local DISCORD_LINK=tostring(cfg.discord_link or"")
local WEBSITE_LINK=tostring(cfg.website_link or"")
local HAS_DISCORD=DISCORD_LINK~=""
local HAS_WEBSITE=WEBSITE_LINK~=""
local function cardFlag(default,...)
for _,source in ipairs({options or{},Variables})do
for _,key in ipairs({...})do
if source[key]~=nil then
return asBool(source[key],default)
end
end
end
return default
end
local SHOW_DISCORD_CARD=cardFlag(true,"Discord","discord")
local SHOW_WEBSITE_CARD=cardFlag(HAS_WEBSITE,"Website","website")
local SHOW_INFO_CARD=cardFlag(true,"Informations","Information","informations","information")
local SHOW_INTRO=cardFlag(true,"Intro","intro")
local KL={disabletextbox=true,disablegetkey=true,showcard=true,autoconfirm=false}
local KEYLESS=false
do
local raw
for _,source in ipairs({options or{},Variables})do
local v=source.Keyless
if v==nil then
v=source.keyless
end
if v~=nil then
raw=v
break
end
end
if type(raw)=="table"then
KEYLESS=asBool(raw.enabled,true)
for k,default in pairs(KL)do
KL[k]=asBool(raw[k],default)
end
elseif raw~=nil then
KEYLESS=asBool(raw,false)
end
end
local SHOW_KEYLESS_CARD=KEYLESS and KL.showcard
local DISCORD_STARTS_OPEN=SHOW_DISCORD_CARD and not SHOW_WEBSITE_CARD and HAS_DISCORD and not SHOW_KEYLESS_CARD
local NOTIF_STYLE="1"
for _,source in ipairs({options or{},Variables})do
local value=source.NotifStyle
if value==nil then
value=source.notifstyle
end
if value~=nil then
NOTIF_STYLE=tostring(value)
break
end
end
local INVITE_DISPLAY,INVITE_URL,INVITE_CODE="Not Configured","",""
if HAS_DISCORD then
local invite=DISCORD_LINK
if not invite:find("[/.]")then
invite="discord.gg/"..invite
end
INVITE_DISPLAY=invite:gsub("^https?://","")
INVITE_URL=invite:match("^https?://")and invite or("https://"..invite)
INVITE_CODE=(INVITE_DISPLAY:gsub("[?#].*$","")):match("([^/]+)/*$")or INVITE_DISPLAY
end
local WEBSITE_DISPLAY,WEBSITE_URL="Not Configured",""
if HAS_WEBSITE then
WEBSITE_DISPLAY=WEBSITE_LINK:gsub("^https?://","")
WEBSITE_URL=WEBSITE_LINK:match("^https?://")and WEBSITE_LINK or("https://"..WEBSITE_LINK)
end
local KEY_CFG=cfg.KeySystem or{}
local KEY_LIST=KEY_CFG.Key
local SERVICE_BUILDERS={
platoboost=function(entry)
return Platoboost.new(entry)
end,
panda=function(entry)
return Panda.new(entry)
end,
jnkie=function(entry)
local instance=Jnkie.new(entry)
return{
CheckKey=function(_,key)
local result=instance:CheckKey(key)
local reason=result and(result.error or result.message)
return result~=nil and result.valid==true,reason
end,
GetKeyLink=function()
return instance:GetKeyLink()
end,
}
end,
}
local function customRequestFunction()
return request or http_request or(syn and syn.request)or(http and http.request)
end
SERVICE_BUILDERS.custom=function(entry)
local checker=entry.CheckKey or entry.checkKey
if type(checker)~="function"then
error("KeySystem.API custom entry needs a CheckKey function")
end
local getLink=entry.GetKeyLink or entry.getKeyLink
local function context()
local ctx={Request=customRequestFunction()}
for k,v in pairs(entry)do
ctx[k]=v
end
return ctx
end
return{
CheckKey=function(_,key)
local valid,why=checker(key,context())
return valid==true,why
end,
GetKeyLink=(type(getLink)=="function")and function()
return getLink(context())
end or nil,
}
end
SERVICE_BUILDERS.pandaauth=SERVICE_BUILDERS.panda
local apiEntries=type(KEY_CFG.API)=="table"and KEY_CFG.API or{}
if apiEntries.Type~=nil or apiEntries.type~=nil then
apiEntries={apiEntries}
end
local API_SERVICES={}
for i,entry in ipairs(apiEntries)do
local kind=type(entry)=="table"and tostring(entry.Type or entry.type or""):lower()or""
local builder=SERVICE_BUILDERS[kind]
if builder then
local ok,instance=pcall(builder,entry)
if ok and instance then
table.insert(API_SERVICES,instance)
else
warn("["..HUB_NAME.."] KeySystem.API["..i.."] failed to load: "..tostring(instance))
end
else
warn("["..HUB_NAME.."] KeySystem.API["..i.."] has an unknown Type: '"..kind.."'")
end
end
if KEY_LIST==nil and#API_SERVICES==0 then
KEY_LIST=function()return false,"No key validator or provider configured."end
end
local KEY_URL=tostring(KEY_CFG.URL or"")
local KEY_SAVE=asBool(KEY_CFG.SaveKey,false)
local LINKS={
getKey=KEY_URL,
website=WEBSITE_URL,
discord=INVITE_URL,
}
local function isCallable(v)
if type(v)=="function"then
return true
end
local mt=type(v)=="table"and getmetatable(v)
return mt~=nil and mt.__call~=nil
end
if type(KEY_LIST)=="table"and KEY_LIST.__isJnkieInstance and not KEY_LIST.__isJnkie then
KEY_LIST=KEY_LIST:Validator()
end
local KEY_JNKIE=type(KEY_LIST)=="table"and KEY_LIST.__isJnkie and KEY_LIST.__instance or nil
local function validateKey(key)
local reason
if KEY_LIST~=nil then
if isCallable(KEY_LIST)then
local valid,why=KEY_LIST(key)
if valid then
return true
end
reason=why
elseif type(KEY_LIST)=="table"then
for _,k in ipairs(KEY_LIST)do
if tostring(k)==key then
return true
end
end
elseif tostring(KEY_LIST)==key then
return true
end
end
for _,service in ipairs(API_SERVICES)do
local ok,valid,why=pcall(service.CheckKey,service,key)
if ok and valid then
return true
end
reason=(ok and why)or(not ok and tostring(valid))or reason
end
return false,reason
end
local function safeIsFile(path)
if not isfile then
return false
end
local ok,res=pcall(isfile,path)
return ok and res==true
end
local function safeReadFile(path)
if not readfile then
return nil
end
local ok,res=pcall(readfile,path)
if ok and type(res)=="string"then
return res
end
return nil
end
local function safeWriteFile(path,contents)
if not writefile then
return false
end
if type(makefolder)=="function"then
for _,dir in ipairs({tostring(FOLDER or""),tostring(path):gsub("\\","/"):match("^(.*)/[^/]+$")or""})do
local current=""
for part in dir:gmatch("[^/]+")do
current=current==""and part or(current.."/"..part)
local exists=false
if type(isfolder)=="function"then local ok,value=pcall(isfolder,current);exists=ok and value==true end
if not exists then pcall(makefolder,current)end
end
end
end
return pcall(writefile,path,contents)==true
end
local function hashName(seed)
local bxor=bit32 and bit32 .bxor
local parts={}
for round=1,4 do
local h=(2166136261+round*16777619)%4294967296
local input=seed.."|"..round
for i=1,#input do
local b=input:byte(i)
h=bxor and bxor(h,b)or((h+b)%4294967296)
h=(h*16777619)%4294967296
end
parts[round]=string.format("%08x",h)
end
return table.concat(parts)
end
local KEY_HASH=hashName(tostring(FOLDER or"").."|"..HUB_NAME)
local KEY_FILE=KEY_CFG.KeyFile or((FOLDER and FOLDER~=""and(FOLDER.."/"..KEY_HASH))or KEY_HASH)
local SAVED_KEY=nil
if KEY_SAVE and safeIsFile(KEY_FILE)then
local contents=safeReadFile(KEY_FILE)
if contents then
contents=contents:match("^%s*(.-)%s*$")
if contents~=""then
SAVED_KEY=contents
end
end
end
local STATS_HASH=hashName(tostring(FOLDER or"").."|"..HUB_NAME.."|stats")
local STATS_FILE=(FOLDER and FOLDER~=""and(FOLDER.."/"..STATS_HASH))or STATS_HASH
local STATS={valid=0,expired=0,last=0}
do
local contents=safeReadFile(STATS_FILE)
if contents then
local ok,data=pcall(function()
return HttpService:JSONDecode(contents)
end)
if ok and type(data)=="table"then
STATS.valid=tonumber(data.valid)or 0
STATS.expired=tonumber(data.expired)or 0
STATS.last=tonumber(data.last)or 0
end
end
end
local function saveStats()
local ok,encoded=pcall(function()
return HttpService:JSONEncode(STATS)
end)
if ok then
safeWriteFile(STATS_FILE,encoded)
end
end
local function formatAgo(ts)
if not ts or ts<=0 then
return"Never"
end
local diff=os.time()-ts
if diff<60 then
return"Just now"
elseif diff<3600 then
return math.floor(diff/60).." min ago"
elseif diff<86400 then
return math.floor(diff/3600).." h ago"
else
return math.floor(diff/86400).." d ago"
end
end
local state={ready=false,closing=false}
local snapLocked=false
local root=Instance.new("ScreenGui")
root.Name="ophyn-ui-wow"
root.Enabled=true
root.DisplayOrder=999
root.IgnoreGuiInset=true
root.ResetOnSpawn=false
root.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
root.ClipToDeviceSafeArea=true
local main=make("Frame",{
Name="Frame",
Size=UDim2 .new(0,INTRO_SIZE,0,INTRO_SIZE),
Position=UDim2 .new(0.5,0,0.5,0),
AnchorPoint=Vector2 .new(0.5,0.5),
BackgroundTransparency=1,
BorderSizePixel=0,
},root)
local shadow=make("ImageLabel",{
Size=UDim2 .new(1,50,1,50),
Position=UDim2 .new(0,-25,0,-25),
BackgroundTransparency=1,
Image=Images.SHADOW,
ImageColor3=Color3 .fromRGB(0,0,0),
ImageTransparency=1,
ScaleType=Enum.ScaleType.Slice,
SliceCenter=Rect.new(49,49,450,450),
},main)
local canvas=make("Frame",{
Size=UDim2 .new(1,0,1,0),
BackgroundColor3="bg",
BackgroundTransparency=1,
BorderSizePixel=0,
ClipsDescendants=true,
},main)
local canvasCorner=make("UICorner",{CornerRadius=UDim.new(0,math.clamp(settings.xngotRadius or 10,4,28))},canvas)
local borderStroke=make("UIStroke",{
Thickness=1,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Color="accent",
Transparency=1,
},canvas)
local decorGroup=make("CanvasGroup",{
Size=UDim2 .new(1,0,1,0),
BackgroundTransparency=1,
BorderSizePixel=0,
GroupTransparency=1,
},canvas)
make("UICorner",{CornerRadius=UDim.new(0,math.clamp(settings.xngotRadius or 10,4,28))},decorGroup)
local bgFrame=centered(decorGroup,FINAL_W,FINAL_H)
decor(bgFrame,380,140,230,266,0.86,270)
decor(bgFrame,100,46,-8,252,0.75,90)
decor(bgFrame,400,184,450,8,0.92,90)
decor(bgFrame,70,138,5,-5,0.78,90)
local ctx={
C=C,
make=make,
frame=frame,
text=text,
round=round,
tween=tween,
prep=prep,
fade=fade,
images=Images,
FONT=FONT,
FONT_BOLD=FONT_BOLD,
markBoldFont=markBoldFont,
root=root,
canvas=canvas,
state=state,
tintIcons=settings.tintIcons,
getStyle=function()
return notifSettings.style or NOTIF_STYLE
end,
cfg={
NOTIF_W=NOTIF_W,
NOTIF_H=NOTIF_H,
NOTIF_TRANSPARENCY=NOTIF_TRANSPARENCY,
NOTIF_COLOR=NOTIF_COLOR,
NOTIF_BLUR=NOTIF_BLUR,
},
}
local notifs=Notification.new(ctx)
local notify=notifs.notify
local Blur=notifs.blur
local intro=centered(canvas,FINAL_W,FINAL_H)
local introLogo=make("ImageLabel",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,64,0,58),
BackgroundTransparency=1,
Image=LOGO,
ImageRectOffset=cfg.LogoRectOffset or Vector2 .new(0,0),
ImageRectSize=cfg.LogoRectSize or Vector2 .new(0,0),
ImageColor3=logoRole("accent"),
ImageTransparency=1,
ScaleType=Enum.ScaleType.Fit,
},intro)
local spinnerHolder=make("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,36),
Size=UDim2 .new(0,36,0,36),
BackgroundTransparency=1,
BorderSizePixel=0,
},intro)
local ringTrack=make("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,24,0,24),
BackgroundTransparency=1,
BorderSizePixel=0,
},spinnerHolder)
make("UICorner",{CornerRadius=UDim.new(1,0)},ringTrack)
make("UIStroke",{Thickness=2.5,Color="muted",Transparency=0.75},ringTrack)
local spinner=make("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,24,0,24),
BackgroundTransparency=1,
BorderSizePixel=0,
},spinnerHolder)
make("UICorner",{CornerRadius=UDim.new(1,0)},spinner)
local spinnerStroke=make("UIStroke",{Thickness=2.5,Color="accent"},spinner)
make("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,0),
NumberSequenceKeypoint.new(0.35,0),
NumberSequenceKeypoint.new(0.7,1),
NumberSequenceKeypoint.new(1,1),
}),
},spinnerStroke)
local spin=TweenService:Create(
spinner,
TweenInfo.new(0.9,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,-1),
{Rotation=360}
)
local checkScreen=centered(canvas,FINAL_W,FINAL_H)
checkScreen.Visible=false
local ringHolder=centered(checkScreen,64,64)
ringHolder.Position=UDim2 .new(0.5,0,0.5,-12)
local ringScale=make("UIScale",{Scale=1},ringHolder)
ring(ringHolder,56,3,"accent",0)
local P1,P2,P3=Vector2 .new(-12,0),Vector2 .new(-4,9),Vector2 .new(13,-9)
local function makeBar(a,b)
local d=b-a
local bar=make("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,a.X,0.5,a.Y),
Size=UDim2 .new(0,0,0,3),
Rotation=math.deg(math.atan2(d.Y,d.X)),
BackgroundColor3="accent",
BorderSizePixel=0,
Visible=false,
},ringHolder)
make("UICorner",{CornerRadius=UDim.new(1,0)},bar)
return{frame=bar,a=a,b=b,len=d.Magnitude}
end
local checkBar1=makeBar(P1,P2)
local checkBar2=makeBar(P2,P3)
local fxLayer=frame(checkScreen,0,0,FINAL_W,FINAL_H)
fxLayer.ZIndex=3
local checkText=text(checkScreen,"Correct Key!",0,156,FINAL_W,22,16,"text",Enum.TextXAlignment.Center)
markBoldFont(checkText)
checkText.TextTransparency=1
local ringItems=prep(ringHolder)
fade(ringItems,0)
local morph=centered(canvas,NOTIF_W,62)
morph.Visible=false
local MORPH_TITLE,MORPH_HINT="Loading Script..","Can take 1-2s..."
local function morphLoader(parent,size,thickness,arcColor,trackColor,trackTransparency)
ring(parent,size,thickness,trackColor,trackTransparency)
local arc,arcStroke=ring(parent,size,thickness,arcColor,0)
comet(arcStroke)
return TweenService:Create(
arc,
TweenInfo.new(0.8,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,-1),
{Rotation=360}
)
end
local function morphLabel(x,y,w,h,str,size,color,bold)
local l=text(morph,str,x,y,w,h,size,color)
if bold then
markBoldFont(l)
end
return l
end
local function buildMorph(key)
morph:ClearAllChildren()
local w,h=NOTIF_W,62
local spec={
top=false,
radius=10,
bg=C[NOTIF_COLOR],
bgTransparency=NOTIF_TRANSPARENCY,
border=C.stroke,
borderTransparency=0.35,
}
local spin
if key=="2"then
w,h=240,36
spec.radius=18
local box=frame(morph,6,6,24,24)
spin=morphLoader(box,20,2,"accent","muted",0.75)
make("TextLabel",{
Position=UDim2 .new(0,38,0,0),
Size=UDim2 .new(0,w-52,0,h),
BackgroundTransparency=1,
BorderSizePixel=0,
RichText=true,
Text="<b>Loading script..</b>  <font color=\"#"..C.muted:ToHex().."\">1-2s</font>",
TextSize=13,
TextColor3="text",
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Center,
FontFace=FONT,
},morph)
elseif key=="3"then
w,h=260,52
spec.top=true
spec.radius=26
spec.bg=Color3 .fromRGB(0,0,0)
spec.bgTransparency=0.06
spec.border=Color3 .fromRGB(42,42,48)
local badge=frame(morph,10,10,32,32,"accent",0.86)
round(badge,16,"accent")
badge.UIStroke.Transparency=0.6
spin=morphLoader(badge,16,2,"accent","muted",0.75)
morphLabel(54,9,w-70,16,MORPH_TITLE,13,Color3 .fromRGB(244,244,245),true)
morphLabel(54,27,w-70,14,MORPH_HINT,12,Color3 .fromRGB(154,154,162))
elseif key=="4"then
h=60
local box=frame(morph,10,10,40,40)
spin=morphLoader(box,34,3,"accent","muted",0.75)
morphLabel(62,11,w-76,18,MORPH_TITLE,13,"text",true)
morphLabel(62,31,w-76,16,MORPH_HINT,12,"muted")
elseif key=="5"then
h=58
local accent=C.accent
local onColor=contrastOn(accent)
spec.bg=accent
spec.bgTransparency=0.04
spec.borderTransparency=1
local box=frame(morph,14,(h-22)/2,22,22)
spin=morphLoader(box,20,3,onColor,onColor,0.75)
morphLabel(48,10,w-62,18,MORPH_TITLE,13,onColor,true)
morphLabel(48,30,w-62,16,MORPH_HINT,12,onColor:Lerp(accent,0.35))
else
round(frame(morph,8,10,3,h-20,"accent",0),2)
morphLabel(22,11,w-36,18,MORPH_TITLE,13,"text",true)
morphLabel(22,30,w-36,16,MORPH_HINT,12,"muted")
local trackW=w-44
round(frame(morph,22,h-9,trackW,2,"accent",0.8),1)
local fill=frame(morph,22,h-9,0,2,"accent",0)
round(fill,1)
spin=TweenService:Create(
fill,
TweenInfo.new(2.2,Enum.EasingStyle.Linear),
{Size=UDim2 .new(0,trackW,0,2)}
)
end
morph.Size=UDim2 .new(0,w,0,h)
local items=prep(morph)
fade(items,0)
spec.w,spec.h,spec.spin,spec.items=w,h,spin,items
return spec
end
local content=centered(canvas,FINAL_W,FINAL_H)
content.Visible=false
local left=frame(content,0,0,272,260)
make("ImageLabel",{
Position=UDim2 .new(0,22,0,20),
Size=UDim2 .new(0,36,0,32),
BackgroundTransparency=1,
Image=LOGO,
ImageRectOffset=cfg.LogoRectOffset or Vector2 .new(0,0),
ImageRectSize=cfg.LogoRectSize or Vector2 .new(0,0),
ImageColor3=logoRole("accent"),
ScaleType=Enum.ScaleType.Fit,
},left)
local hubTitle=text(left,HUB_NAME,66,20,190,22,20,"text")
markTitleFont(hubTitle)
hubTitle.TextTruncate=Enum.TextTruncate.AtEnd
local hubSubtitle=text(left,HUB_SUBTITLE,66,42,190,14,12,"muted")
hubSubtitle.TextTruncate=Enum.TextTruncate.AtEnd
local licenseLabel=text(left,"License key",22,78,228,14,11,"muted")
local inputBox=frame(left,22,96,228,36,"input",0)
inputBox.ClipsDescendants=true
round(inputBox,8,"stroke")
icon(inputBox,12,10,"muted",Images.KEY)
local KEY_MAX_LENGTH=256
local keyBox=make("TextBox",{
Name="TextBox",
Position=UDim2 .new(0,38,0,0),
Size=UDim2 .new(1,-48,1,0),
BackgroundTransparency=1,
BorderSizePixel=0,
Text="",
TextSize=13,
TextColor3="text",
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
PlaceholderText="Paste your key here",
PlaceholderColor3="muted",
ClearTextOnFocus=false,
MultiLine=false,
FontFace=FONT,
},inputBox)
keyBox:GetPropertyChangedSignal("Text"):Connect(function()
if#keyBox.Text>KEY_MAX_LENGTH then
keyBox.Text=keyBox.Text:sub(1,KEY_MAX_LENGTH)
end
end)
local submit=make("TextButton",{
Name="TextButton",
Position=UDim2 .new(0,22,0,142),
Size=UDim2 .new(0,110,0,34),
BackgroundColor3="submitBg",
BackgroundTransparency=0.12,
BorderSizePixel=0,
AutoButtonColor=false,
Text="Submit",
TextSize=13,
TextColor3="submitText",
FontFace=FONT,
},left)
round(submit,8)
make("UIPadding",{PaddingLeft=UDim.new(0,24)},submit)
icon(submit,-12,9,"submitText",Images.SUBMIT)
local getKey=make("TextButton",{
Name="TextButton",
Position=UDim2 .new(0,140,0,142),
Size=UDim2 .new(0,110,0,34),
BackgroundColor3="btn2",
BorderSizePixel=0,
AutoButtonColor=false,
Text="Get a key",
TextTruncate=Enum.TextTruncate.AtEnd,
TextSize=13,
TextColor3="text",
FontFace=FONT,
},left)
round(getKey,8,"stroke")
local getKeyPadding=make("UIPadding",{PaddingLeft=UDim.new(0,24)},getKey)
local getKeyIcon=icon(getKey,-12,9,"text",Images.KEY)
local methodArrow=make("TextButton",{
Name="TextButton",
Position=UDim2 .new(1,-26,0,0),
Size=UDim2 .new(0,26,1,0),
BackgroundTransparency=1,
AutoButtonColor=false,
Text="\226\150\190",
TextSize=11,
TextColor3="text",
FontFace=FONT,
Visible=false,
},getKey)
local methodDropdown=make("Frame",{
Name="GetKeyDropdown",
BackgroundColor3="card",
BorderSizePixel=0,
Visible=false,
ZIndex=50,
ClipsDescendants=true,
},main)
round(methodDropdown,8,"stroke")
local function closeMethodDropdown()
methodDropdown.Visible=false
end
local function rebuildMethodDropdown()
for _,child in ipairs(methodDropdown:GetChildren())do
if child:IsA("GuiObject")then
child:Destroy()
end
end
local rowH=32
for i,m in ipairs(getMethods)do
local row=make("TextButton",{
Name="TextButton",
Position=UDim2 .new(0,0,0,(i-1)*rowH),
Size=UDim2 .new(1,0,0,rowH),
BackgroundTransparency=1,
AutoButtonColor=false,
Text="",
ZIndex=51,
},methodDropdown)
icon(row,10,8,"text",assetId(m.icon)or Images.KEY)
local label=text(row,m.title or("Method "..i),34,0,96,rowH,12,"text")
label.ZIndex=52
row.MouseButton1Click:Connect(function()
selectedMethodIndex=i
applyGetkeyAll()
closeMethodDropdown()
end)
end
methodDropdown.Size=UDim2 .new(0,140,0,rowH*math.max(#getMethods,1))
end
methodArrow.MouseButton1Click:Connect(function()
if not state.ready or state.closing or#getMethods<2 or(KEYLESS and KL.disablegetkey)then
return
end
if methodDropdown.Visible then
closeMethodDropdown()
return
end
rebuildMethodDropdown()
local pos=getKey.AbsolutePosition-main.AbsolutePosition
local h=methodDropdown.AbsoluteSize.Y
methodDropdown.Position=UDim2 .new(0,pos.X,0,pos.Y-h-6)
methodDropdown.Visible=true
end)
local function applyGetkey()
local method=getMethods[selectedMethodIndex or 0]
local title=method and method.title
local iconValue=method and method.icon
if not title or title==""then
title=getkeySettings.title
end
getKey.Text=(title and title~="")and title or"Get a key"
local image=getKeyIcon:FindFirstChild("iconimage")
if image then
local selectedIcon=assetId(iconValue)or assetId(getkeySettings.icon)
if not selectedIcon and settings.xngotApplyIcon then
local ok,result=pcall(settings.xngotApplyIcon,image,"key-round")
if not ok or not result then Lucide.apply(image,Images.KEY)end
else
Lucide.apply(image,selectedIcon or Images.KEY)
end
end
local showArrow=#getMethods>1
methodArrow.Visible=showArrow
getKeyPadding.PaddingRight=showArrow and UDim.new(0,20)or UDim.new(0,0)
if not showArrow then
closeMethodDropdown()
end
end
applyGetkey()
table.insert(getkeyAppliers,applyGetkey)
root.Destroying:Connect(function()
local index=table.find(getkeyAppliers,applyGetkey)
if index then
table.remove(getkeyAppliers,index)
end
end)
if not SHOW_GETKEY then
getKey.Visible=false
submit.Size=UDim2 .new(0,228,0,34)
end
local avatar=make("ImageLabel",{
Position=UDim2 .new(0,22,0,214),
Size=UDim2 .new(0,32,0,32),
BackgroundColor3="input",
BorderSizePixel=0,
Image=player and("rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=150&h=150")or"",
ScaleType=Enum.ScaleType.Crop,
},left)
round(avatar,16,"stroke")
text(left,"Welcome Back",62,215,188,14,11,"muted")
local welcomeName=text(left,((player and player.DisplayName)or"User").."!",62,229,188,16,14,"text")
markBoldFont(welcomeName)
welcomeName.TextTruncate=Enum.TextTruncate.AtEnd
frame(content,272,20,1,220,"stroke",0)
local right=frame(content,273,0,187,260)
text(right,"Detected game",20,24,147,14,11,"muted")
local gameCard=frame(right,20,42,147,52,"card",0)
round(gameCard,8)
local gameImg=make("ImageLabel",{
Position=UDim2 .new(0,9,0,9),
Size=UDim2 .new(0,34,0,34),
BackgroundColor3="input",
BorderSizePixel=0,
Image=Images.GAME_PLACEHOLDER,
ScaleType=Enum.ScaleType.Stretch,
},gameCard)
round(gameImg,7,"stroke")
local gameName=text(gameCard,"Loading...",52,10,90,14,12,"text")
gameName.TextTruncate=Enum.TextTruncate.AtEnd
local gameStatus=text(gameCard,"Checking...",52,27,90,13,11,"muted")
local rows=frame(right,0,0,187,260)
text(rows,"Executor",20,106,60,14,11,"muted")
local executorLabel=text(rows,"Detecting...",80,106,87,14,11,"text",Enum.TextXAlignment.Right)
executorLabel.TextTruncate=Enum.TextTruncate.AtEnd
text(rows,"Status",20,126,60,14,11,"muted")
local statusValue=text(rows,"Key required",80,126,87,14,11,"warn",Enum.TextXAlignment.Right)
local rightDivider=frame(right,20,148,147,1,"stroke",0)
local CARD_PAD=2
local CARD_VIEW_BOTTOM=256
local cardScroll=make("ScrollingFrame",{
Name="Cards",
Position=UDim2 .new(0,20-CARD_PAD,0,158-CARD_PAD),
Size=UDim2 .new(0,147+CARD_PAD+5,0,CARD_VIEW_BOTTOM-158+CARD_PAD),
BackgroundTransparency=1,
BorderSizePixel=0,
CanvasSize=UDim2 .new(0,0,0,0),
ScrollingDirection=Enum.ScrollingDirection.Y,
ElasticBehavior=Enum.ElasticBehavior.Never,
VerticalScrollBarInset=Enum.ScrollBarInset.None,
ScrollBarThickness=2,
ScrollBarImageTransparency=0.45,
ClipsDescendants=true,
},right)
setRole(cardScroll,"ScrollBarImageColor3","muted")
local function linkButton(y,title,subtitle,image)
local btn=make("TextButton",{
Name="TextButton",
Position=UDim2 .new(0,20,0,y),
Size=UDim2 .new(0,147,0,40),
BackgroundColor3="card",
BorderSizePixel=0,
AutoButtonColor=false,
Text="",
},cardScroll)
round(btn,8,"stroke")
local iconHolder=icon(btn,11,12,"accent",image)
local titleLabel=text(btn,title,36,6,106,14,12,"text")
local subLabel=text(btn,subtitle,36,21,106,13,11,"muted")
subLabel.TextTruncate=Enum.TextTruncate.AtEnd
return btn,iconHolder,titleLabel,subLabel
end
local discord,discordIcon,discordTitle,discordSub=linkButton(158,"Discord",INVITE_DISPLAY,Images.DISCORD)
local website=linkButton(206,"Website",WEBSITE_DISPLAY,Images.LINK)
discord.Visible=SHOW_DISCORD_CARD
website.Visible=SHOW_WEBSITE_CARD
discordTitle.TextTruncate=Enum.TextTruncate.AtEnd
discord.ClipsDescendants=true
local discordExtra=frame(discord,0,0,147,82)
discordExtra.Visible=false
local serverIcon=make("ImageLabel",{
Position=UDim2 .new(0,9,0,7),
Size=UDim2 .new(0,26,0,26),
BackgroundColor3="input",
BorderSizePixel=0,
Image=LOGO,
ImageRectOffset=cfg.LogoRectOffset or Vector2 .new(0,0),
ImageRectSize=cfg.LogoRectSize or Vector2 .new(0,0),
ImageColor3=logoRole("accent"),
ScaleType=Enum.ScaleType.Fit,
},discordExtra)
round(serverIcon,8,"stroke")
local linkHit=make("TextButton",{
Position=UDim2 .new(0,40,0,19),
Size=UDim2 .new(0,102,0,17),
BackgroundTransparency=1,
BorderSizePixel=0,
AutoButtonColor=false,
Text="",
},discordExtra)
frame(discordExtra,10,41,127,1,"stroke",0)
local function statBlock(x,label,dotColor)
local num=text(discordExtra,"...",x,47,62,16,13,"text")
markBoldFont(num)
local dot=frame(discordExtra,x,66,6,6,dotColor,0)
make("UICorner",{CornerRadius=UDim.new(1,0)},dot)
text(discordExtra,label,x+10,62,50,14,10,"muted")
return num
end
local onlineNum=statBlock(12,"Online","success")
local offlineNum=statBlock(80,"Offline","muted")
local extraItems=prep(discordExtra)
local rowsItems=prep(rows)
local discordIconItems=prep(discordIcon)
local infoCard,infoIcon,infoTitle,infoSub=linkButton(254,"Information","Tap to view",Images.KEY)
infoCard.Visible=SHOW_INFO_CARD
infoCard.ClipsDescendants=true
infoTitle.TextTruncate=Enum.TextTruncate.AtEnd
local INFO_OPEN_H=92
local infoUI={}
do
local extra=frame(infoCard,0,0,147,INFO_OPEN_H)
extra.Visible=false
infoUI.extra=extra
local iconBox=frame(extra,9,7,26,26,"input",0)
round(iconBox,8,"stroke")
icon(iconBox,5,5,"accent",Images.KEY)
frame(extra,10,41,127,1,"stroke",0)
local function stat(x,label,dotColor)
local num=text(extra,"0",x,46,62,16,13,"text")
markBoldFont(num)
local dot=frame(extra,x,66,6,6,dotColor,0)
make("UICorner",{CornerRadius=UDim.new(1,0)},dot)
text(extra,label,x+10,62,50,14,10,"muted")
return num
end
infoUI.valid=stat(12,"Valid","success")
infoUI.expired=stat(80,"Expired","warn")
text(extra,"Last used",12,77,56,13,10,"muted")
local lastUsed=text(extra,"Never",66,77,69,13,11,"text",Enum.TextXAlignment.Right)
lastUsed.TextTruncate=Enum.TextTruncate.AtEnd
infoUI.lastUsed=lastUsed
end
infoUI.extraItems=prep(infoUI.extra)
infoUI.iconItems=prep(infoIcon)
local keylessCard=linkButton(206,"Keyless Mode","No key needed",Images.KEYLESS)
keylessCard.Visible=SHOW_KEYLESS_CARD
local closeBtn=make("TextButton",{
Name="CloseButton",
AnchorPoint=Vector2 .new(1,0),
Position=UDim2 .new(1,-12,0,12),
Size=UDim2 .new(0,26,0,26),
BackgroundColor3="card",
BackgroundTransparency=1,
BorderSizePixel=0,
AutoButtonColor=false,
Text="",
ZIndex=5,
},content)
make("UICorner",{CornerRadius=UDim.new(0,7)},closeBtn)
local closeIcon=make("ImageLabel",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,12,0,12),
BackgroundTransparency=1,
Image=CLOSE_ICON,
ImageColor3=iconRole("muted"),
ZIndex=6,
},closeBtn)
if settings.xngotApplyIcon then pcall(settings.xngotApplyIcon,closeIcon,"x")end
local moonBtn=make("TextButton",{
Name="ThemeButton",
AnchorPoint=Vector2 .new(1,0),
Position=UDim2 .new(1,-38,0,12),
Size=UDim2 .new(0,26,0,26),
BackgroundColor3="card",
BackgroundTransparency=1,
BorderSizePixel=0,
AutoButtonColor=false,
Text="",
ZIndex=5,
},content)
make("UICorner",{CornerRadius=UDim.new(0,7)},moonBtn)
local moonIcon=make("ImageLabel",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(0,10,0,10),
BackgroundTransparency=1,
Image=MOON_ICON,
ImageColor3=iconRole("muted"),
ZIndex=6,
},moonBtn)
if settings.xngotApplyIcon then pcall(settings.xngotApplyIcon,moonIcon,"moon")end
moonBtn.Visible=SHOW_CHANGE_THEME
local closeGui
ctx.pages=Pages.new({
C=C,
make=make,
round=round,
tween=tween,
prep=prep,
fade=fade,
setRole=setRole,
icon=icon,
assetId=assetId,
contrastOn=contrastOn,
iconRole=iconRole,
logoRole=logoRole,
markTitleFont=markTitleFont,
getTabsStyle=function()
if tabsSettings.style then
return tabsSettings.style
end
for _,source in ipairs({options or{},Variables})do
local value=source.TabsStyle
if value==nil then
value=source.tabsstyle
end
if value~=nil then
return tostring(value)
end
end
return"1"
end,
registerTabsStyle=function(apply)
table.insert(tabsAppliers,apply)
end,
FONT=FONT,
FONT_BOLD=FONT_BOLD,
images=Images,
canvas=canvas,
content=content,
state=state,
width=FINAL_W,
height=FINAL_H,
title=HUB_NAME,
logo=LOGO,
onOpen=function()
closeMethodDropdown()
end,
requestClose=function()
if not state.ready or state.closing then
return
end
task.spawn(closeGui)
end,
})
if KEYLESS then
local DIM=0.5
local function dim(container)
local function apply(inst)
if inst:IsA("GuiObject")then
inst.BackgroundTransparency=1-(1-inst.BackgroundTransparency)*DIM
if inst:IsA("TextLabel")or inst:IsA("TextButton")or inst:IsA("TextBox")then
inst.TextTransparency=1-(1-inst.TextTransparency)*DIM
elseif inst:IsA("ImageLabel")or inst:IsA("ImageButton")then
inst.ImageTransparency=1-(1-inst.ImageTransparency)*DIM
end
elseif inst:IsA("UIStroke")then
inst.Transparency=1-(1-inst.Transparency)*DIM
end
end
apply(container)
for _,d in ipairs(container:GetDescendants())do
apply(d)
end
end
if KL.disabletextbox then
dim(licenseLabel)
dim(inputBox)
pcall(function()
keyBox.TextEditable=false
keyBox.Active=false
keyBox.Interactable=false
end)
keyBox.Focused:Connect(function()
keyBox:ReleaseFocus()
end)
end
if KL.disablegetkey then
dim(getKey)
pcall(function()
getKey.Active=false
getKey.Interactable=false
methodArrow.Active=false
methodArrow.Interactable=false
end)
end
statusValue.Text="Keyless"
setRole(statusValue,"TextColor3","accent")
end
local spinnerItems=prep(spinnerHolder)
local contentItems=prep(content)
fade(spinnerItems,0)
fade(contentItems,0)
local SUPPORTED_GAMES={}
for _,source in ipairs({options or{},Variables})do
local value=source.SupportedGames
if value==nil then
value=source.supportedgames
end
if type(value)=="table"then
for k,v in pairs(value)do
if type(v)=="number"then
SUPPORTED_GAMES[v]=true
elseif v then
SUPPORTED_GAMES[tonumber(k)or k]=true
end
end
break
end
end
task.spawn(function()
local ok,info=pcall(function()
return MarketplaceService:GetProductInfo(game.PlaceId)
end)
if state.closing then
return
end
gameName.Text=(ok and type(info)=="table"and info.Name)or"Unknown game"
if game.GameId~=0 then
gameImg.Image="rbxthumb://type=GameIcon&id="..game.GameId.."&w=150&h=150"
end
if SUPPORTED_GAMES[game.PlaceId]then
gameStatus.Text="Supported"
setRole(gameStatus,"TextColor3","success")
else
gameStatus.Text="Not in our list"
setRole(gameStatus,"TextColor3","muted")
end
end)
local function detectExecutor()
local ok,name=pcall(function()
if identifyexecutor then
return identifyexecutor()
elseif getexecutorname then
return getexecutorname()
end
end)
if ok and name and tostring(name)~=""then
return tostring(name)
end
return"Unknown"
end
executorLabel.Text=detectExecutor()
local function copyLink(url,label,iconKey)
if not state.ready or state.closing then
return false
end
local fn=setclipboard or toclipboard
local ok=fn and pcall(fn,url)
if ok then
notify(label.." copied","The link is in your clipboard.","success",iconKey)
return true
end
notify("Couldn't copy",url,"warn",iconKey,5)
return false
end
local fetchingKeyLink=false
getKey.MouseButton1Click:Connect(function()
if not state.ready or state.closing then
return
end
if KEYLESS and KL.disablegetkey then
return
end
if#getMethods>0 then
local method=getMethods[selectedMethodIndex or 1]
if not method then
return
end
if method.url and method.url~=""then
copyLink(method.url,"Key link","link")
return
end
if type(method.getKeyLink)=="function"then
if fetchingKeyLink then
return
end
fetchingKeyLink=true
task.spawn(function()
local req=request or http_request or(syn and syn.request)or(http and http.request)
local ctx={Request=req}
for k,v in pairs(method.fields or{})do
ctx[k]=v
end
local ok,link,err=pcall(method.getKeyLink,ctx)
fetchingKeyLink=false
if not state.ready or state.closing then
return
end
if ok and link then
copyLink(link,"Key link","link")
else
notify("Couldn't get a key",tostring((not ok)and link or err or"Try again."),"warn","link",5)
end
end)
end
return
end
if LINKS.getKey~=""then
copyLink(LINKS.getKey,"Key link","link")
return
end
local linkProviders={}
for _,service in ipairs(API_SERVICES)do
if service.GetKeyLink then
table.insert(linkProviders,function()
return service:GetKeyLink()
end)
end
end
if KEY_JNKIE then
table.insert(linkProviders,function()
return KEY_JNKIE:GetKeyLink()
end)
end
if#linkProviders>0 then
if fetchingKeyLink then
return
end
fetchingKeyLink=true
task.spawn(function()
local link,err
for _,getLink in ipairs(linkProviders)do
local ok,res,res2=pcall(getLink)
if ok and res then
link=res
break
end
err=ok and res2 or(not ok and res)or err
end
fetchingKeyLink=false
if not state.ready or state.closing then
return
end
if link then
copyLink(link,"Key link","link")
elseif err=="RATE_LIMITED"then
notify("Slow down","Wait 5 minutes before requesting another link.","warn","link",5)
else
notify("Couldn't get a link",tostring(err or"Unknown error"),"warn","link",5)
end
end)
return
end
if LINKS.website~=""then
copyLink(LINKS.website,"Key link","link")
return
end
notify("No link set","The key link isn't set.","warn","link")
end)
local httpRequest=request or http_request or(syn and syn.request)or(http and http.request)
local discordInfo={fetching=false,ok=false,iconLoaded=false,last=0,online=0,offline=0}
local discordOpen=false
local infoOpen=false
local function anyCardOpen()
return discordOpen or infoOpen
end
local function refreshDiscordTitle()
local target=(discordOpen and discordInfo.name)or"Discord"
if discordTitle.Text==target then
return
end
if not state.ready then
discordTitle.Text=target
return
end
tween(discordTitle,0.12,{TextTransparency=1})
task.delay(0.12,function()
if state.closing then
return
end
discordTitle.Text=(discordOpen and discordInfo.name)or"Discord"
tween(discordTitle,0.15,{TextTransparency=0})
end)
end
local function formatNumber(n)
local reversed=tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):reverse()
return(reversed:gsub("^,",""))
end
local function applyDiscordInfo()
if discordInfo.ok then
onlineNum.Text=formatNumber(discordInfo.online)
offlineNum.Text=formatNumber(discordInfo.offline)
elseif discordInfo.fetching then
onlineNum.Text="..."
offlineNum.Text="..."
else
onlineNum.Text="N/A"
offlineNum.Text="N/A"
end
end
local function fetchDiscord()
if discordInfo.fetching then
return
end
discordInfo.fetching=true
applyDiscordInfo()
if httpRequest then
local ok,res=pcall(httpRequest,{
Url="https://discord.com/api/v10/invites/"..INVITE_CODE.."?with_counts=true",
Method="GET",
})
if ok and res and res.StatusCode==200 and res.Body then
local okJson,data=pcall(function()
return HttpService:JSONDecode(res.Body)
end)
if okJson and type(data)=="table"and data.approximate_member_count then
local online=data.approximate_presence_count or 0
discordInfo.online=online
discordInfo.offline=math.max(data.approximate_member_count-online,0)
discordInfo.ok=true
discordInfo.last=os.clock()
if type(data.guild)=="table"and data.guild.name then
discordInfo.name=data.guild.name
end
local guild=data.guild
local getAsset=getcustomasset or getsynasset
if guild and guild.icon and not discordInfo.iconLoaded and writefile and getAsset then
local url=("https://cdn.discordapp.com/icons/%s/%s.png?size=128"):format(guild.id,guild.icon)
local okI,resI=pcall(httpRequest,{Url=url,Method="GET"})
if okI and resI and resI.StatusCode==200 and resI.Body and#resI.Body>0 then
local okW,asset=pcall(function()
local fileName="discord_"..INVITE_CODE..".png"
if FOLDER and FOLDER~=""then
if isfolder and makefolder and not isfolder(FOLDER)then
makefolder(FOLDER)
end
fileName=FOLDER.."/"..fileName
end
writefile(fileName,resI.Body)
return getAsset(fileName)
end)
if okW and asset then
serverIcon.Image=asset
unbind(serverIcon,"ImageColor3")
serverIcon.ImageColor3=Color3 .fromRGB(255,255,255)
serverIcon.ScaleType=Enum.ScaleType.Crop
discordInfo.iconLoaded=true
end
end
end
end
end
end
discordInfo.fetching=false
applyDiscordInfo()
refreshDiscordTitle()
end
if HAS_DISCORD then
task.spawn(fetchDiscord)
end
local CARD_GAP=8
local cardOrder={}
if SHOW_DISCORD_CARD then
table.insert(cardOrder,discord)
end
if SHOW_KEYLESS_CARD then
table.insert(cardOrder,keylessCard)
end
if SHOW_WEBSITE_CARD then
table.insert(cardOrder,website)
end
if SHOW_INFO_CARD then
table.insert(cardOrder,infoCard)
end
local function cardHeight(card)
if card==discord and discordOpen then
return 82
end
if card==infoCard and infoOpen then
return INFO_OPEN_H
end
return 40
end
local layoutToken=0
local function layoutCards(instant,focusCard)
local Quint=Enum.EasingStyle.Quint
local open=anyCardOpen()
local divider=open and 106 or 148
local top=open and 114 or 158
local y=CARD_PAD
local focusTop,focusBottom
for _,card in ipairs(cardOrder)do
local h=cardHeight(card)
if card==focusCard then
focusTop,focusBottom=y-CARD_PAD,y+h+CARD_PAD
end
if instant then
card.Position=UDim2 .new(0,CARD_PAD,0,y)
card.Size=UDim2 .new(0,147,0,h)
else
tween(card,0.55,{
Position=UDim2 .new(0,CARD_PAD,0,y),
Size=UDim2 .new(0,147,0,h),
},Quint)
end
y=y+h+CARD_GAP
end
local canvasH=math.max(y-CARD_GAP+CARD_PAD,0)
local viewH=CARD_VIEW_BOTTOM-top+CARD_PAD
local maxPos=math.max(canvasH-viewH,0)
local pos=cardScroll.CanvasPosition.Y
local targetPos=math.clamp(pos,0,maxPos)
if focusTop then
if focusBottom>targetPos+viewH then
targetPos=focusBottom-viewH
end
if focusTop<targetPos then
targetPos=focusTop
end
targetPos=math.clamp(targetPos,0,maxPos)
end
local scrollPos=UDim2 .new(0,20-CARD_PAD,0,top-CARD_PAD)
local scrollSize=UDim2 .new(0,147+CARD_PAD+5,0,viewH)
local canvasSize=UDim2 .new(0,0,0,canvasH)
layoutToken+=1
local token=layoutToken
if instant then
rightDivider.Position=UDim2 .new(0,20,0,divider)
cardScroll.Position=scrollPos
cardScroll.Size=scrollSize
cardScroll.CanvasSize=canvasSize
cardScroll.CanvasPosition=Vector2 .new(0,targetPos)
return
end
tween(rightDivider,0.55,{Position=UDim2 .new(0,20,0,divider)},Quint)
if canvasH>=cardScroll.CanvasSize.Y.Offset then
cardScroll.CanvasSize=canvasSize
else
task.delay(0.58,function()
if token==layoutToken then
cardScroll.CanvasSize=canvasSize
end
end)
end
tween(cardScroll,0.55,{
Position=scrollPos,
Size=scrollSize,
CanvasPosition=Vector2 .new(0,targetPos),
},Quint)
end
layoutCards(true)
local suppressClick=false
do
local dragging,dragStartY,dragStartCanvas=false,0,0
local function onPress(input)
if input.UserInputType~=Enum.UserInputType.MouseButton1 or dragging or not state.ready then
return
end
if cardScroll.CanvasSize.Y.Offset<=cardScroll.AbsoluteSize.Y then
return
end
dragging=true
dragStartY=input.Position.Y
dragStartCanvas=cardScroll.CanvasPosition.Y
end
cardScroll.InputBegan:Connect(onPress)
for _,card in ipairs(cardOrder)do
card.InputBegan:Connect(onPress)
end
local dragMove=UserInputService.InputChanged:Connect(function(input)
if not dragging or input.UserInputType~=Enum.UserInputType.MouseMovement then
return
end
local delta=input.Position.Y-dragStartY
if not suppressClick and math.abs(delta)<5 then
return
end
suppressClick=true
local maxPos=math.max(cardScroll.CanvasSize.Y.Offset-cardScroll.AbsoluteSize.Y,0)
cardScroll.CanvasPosition=Vector2 .new(0,math.clamp(dragStartCanvas-delta,0,maxPos))
end)
local dragEnd=UserInputService.InputEnded:Connect(function(input)
if input.UserInputType~=Enum.UserInputType.MouseButton1 or not dragging then
return
end
dragging=false
task.delay(0.1,function()
suppressClick=false
end)
end)
root.Destroying:Connect(function()
dragMove:Disconnect()
dragEnd:Disconnect()
end)
end
local discordToken=0
local function setDiscord(open)
discordOpen=open
refreshDiscordTitle()
discordToken+=1
local token=discordToken
local Quint=Enum.EasingStyle.Quint
layoutCards(false,open and discord or nil)
local textX=open and 40 or 36
tween(discordTitle,0.4,{Position=UDim2 .new(0,textX,0,6)},Quint)
tween(discordSub,0.4,{
Position=UDim2 .new(0,textX,0,21),
Size=UDim2 .new(0,open and 102 or 106,0,13),
},Quint)
fade(rowsItems,anyCardOpen()and 0 or 1,0.25)
fade(discordIconItems,open and 0 or 1,0.2)
if open then
discordExtra.Visible=true
fade(extraItems,0)
task.delay(0.15,function()
if token==discordToken then
fade(extraItems,1,0.3)
end
end)
if not discordInfo.fetching and(not discordInfo.ok or os.clock()-discordInfo.last>60)then
task.spawn(fetchDiscord)
end
else
fade(extraItems,0,0.15)
tween(discordSub,0.15,{TextColor3=C.muted})
task.delay(0.17,function()
if token==discordToken then
discordExtra.Visible=false
end
end)
end
end
if DISCORD_STARTS_OPEN then
discordOpen=true
discordToken+=1
layoutCards(true)
discordTitle.Position=UDim2 .new(0,40,0,6)
discordSub.Position=UDim2 .new(0,40,0,21)
discordSub.Size=UDim2 .new(0,102,0,13)
fade(rowsItems,0)
fade(discordIconItems,0)
discordExtra.Visible=true
end
discord.MouseButton1Click:Connect(function()
if not state.ready or state.closing or suppressClick then
return
end
if not HAS_DISCORD then
notify("Not configured","No Discord link has been set.","warn","discord")
return
end
setDiscord(not discordOpen)
end)
linkHit.MouseButton1Click:Connect(function()
if suppressClick then
return
end
copyLink(LINKS.discord,"Discord invite","discord")
end)
linkHit.MouseEnter:Connect(function()
if discordOpen then
tween(discordSub,0.15,{TextColor3=C.accent})
end
end)
linkHit.MouseLeave:Connect(function()
tween(discordSub,0.15,{TextColor3=C.muted})
end)
website.MouseButton1Click:Connect(function()
if not state.ready or state.closing or suppressClick then
return
end
if not HAS_WEBSITE then
notify("Not configured","No website link has been set.","warn","link")
return
end
copyLink(LINKS.website,"Website link","link")
end)
local function refreshInfo()
infoUI.valid.Text=formatNumber(STATS.valid)
infoUI.expired.Text=formatNumber(STATS.expired)
infoUI.lastUsed.Text=formatAgo(STATS.last)
end
refreshInfo()
do
local function setLabelText(label,str)
if label.Text==str then
return
end
if not state.ready then
label.Text=str
return
end
tween(label,0.12,{TextTransparency=1})
task.delay(0.12,function()
if state.closing then
return
end
label.Text=str
tween(label,0.15,{TextTransparency=0})
end)
end
local infoToken=0
local function setInfo(open)
infoOpen=open
infoToken+=1
local token=infoToken
local Quint=Enum.EasingStyle.Quint
if open then
refreshInfo()
end
setLabelText(infoSub,open and"Key history"or"Tap to view")
layoutCards(false,open and infoCard or nil)
local textX=open and 40 or 36
tween(infoTitle,0.4,{Position=UDim2 .new(0,textX,0,6)},Quint)
tween(infoSub,0.4,{
Position=UDim2 .new(0,textX,0,21),
Size=UDim2 .new(0,open and 102 or 106,0,13),
},Quint)
fade(rowsItems,anyCardOpen()and 0 or 1,0.25)
fade(infoUI.iconItems,open and 0 or 1,0.2)
if open then
infoUI.extra.Visible=true
fade(infoUI.extraItems,0)
task.delay(0.15,function()
if token==infoToken then
fade(infoUI.extraItems,1,0.3)
end
end)
else
fade(infoUI.extraItems,0,0.15)
task.delay(0.17,function()
if token==infoToken then
infoUI.extra.Visible=false
end
end)
end
end
infoCard.MouseButton1Click:Connect(function()
if not state.ready or state.closing or suppressClick then
return
end
setInfo(not infoOpen)
end)
end
local checkingKey=false
local fadeContent
do
local rowsHidden,discordIconHidden,infoIconHidden={},{},{}
for _,it in ipairs(rowsItems)do
rowsHidden[it[1]]=true
end
for _,it in ipairs(discordIconItems)do
discordIconHidden[it[1]]=true
end
for _,it in ipairs(infoUI.iconItems)do
infoIconHidden[it[1]]=true
end
function fadeContent(alpha,time)
if anyCardOpen()and alpha>0 then
local filtered={}
for _,it in ipairs(contentItems)do
local inst=it[1]
local hide=rowsHidden[inst]or(discordOpen and discordIconHidden[inst])or(infoOpen and infoIconHidden[inst])
if not hide then
filtered[#filtered+1]=it
end
end
fade(filtered,alpha,time)
else
fade(contentItems,alpha,time)
end
end
end
local function resetCheckScreen()
ringScale.Scale=0.6
for _,b in ipairs({checkBar1,checkBar2})do
b.frame.Visible=false
b.frame.Size=UDim2 .new(0,0,0,3)
end
checkText.TextTransparency=1
checkText.Position=UDim2 .new(0,0,0,162)
fade(ringItems,0)
end
local function drawBar(bar,time)
bar.frame.Size=UDim2 .new(0,0,0,3)
bar.frame.Position=UDim2 .new(0.5,bar.a.X,0.5,bar.a.Y)
bar.frame.Visible=true
local mid=(bar.a+bar.b)/2
tween(bar.frame,time,{
Size=UDim2 .new(0,bar.len,0,3),
Position=UDim2 .new(0.5,mid.X,0.5,mid.Y),
})
end
local function confetti(count,withPulse)
local colors=C.confetti
for i=1,count do
local angle=(i/count)*math.pi*2+math.random()*0.3
local dist=70+math.random()*45
local piece=make("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,-12),
Size=UDim2 .new(0,math.random(4,7),0,math.random(3,5)),
BackgroundColor3=colors[math.random(#colors)],
BorderSizePixel=0,
Rotation=math.random(0,360),
ZIndex=3,
},fxLayer)
make("UICorner",{CornerRadius=UDim.new(0,2)},piece)
local t=0.55+math.random()*0.3
tween(piece,t,{
Position=UDim2 .new(0.5,math.cos(angle)*dist,0.5,-12+math.sin(angle)*dist*0.85+14),
Rotation=piece.Rotation+math.random(-260,260),
},Enum.EasingStyle.Quint)
task.delay(t*0.6,function()
tween(piece,t*0.8,{BackgroundTransparency=1})
end)
task.delay(t*1.5+0.2,function()
piece:Destroy()
end)
end
if withPulse then
local pulse,pulseStroke=ring(fxLayer,56,2,C.accent,0.2)
pulse.Position=UDim2 .new(0.5,0,0.5,-12)
tween(pulse,0.7,{Size=UDim2 .new(0,150,0,150)},Enum.EasingStyle.Quint)
tween(pulseStroke,0.7,{Transparency=1})
task.delay(0.8,function()
pulse:Destroy()
end)
end
end
local function runKeyCheck(key,isSavedKey)
checkingKey=true
state.ready=false
notifs.dismissAll()
local result
task.spawn(function()
if KEYLESS then
result={ok=true,valid=true}
return
end
local ok,valid,reason=pcall(validateKey,key)
result={ok=ok,valid=valid,reason=reason}
end)
fadeContent(0,0.25)
task.wait(0.25)
content.Visible=false
spinnerHolder.Position=UDim2 .new(0.5,0,0.5,0)
spin:Play()
fade(spinnerItems,1,0.25)
local minCheckTime=isSavedKey and SAVED_CHECK_TIME or CHECK_TIME
local t0=os.clock()
repeat
task.wait()
until(result and os.clock()-t0>=minCheckTime)or os.clock()-t0>15
if not(result and result.ok and result.valid)then
fade(spinnerItems,0,0.25)
task.wait(0.25)
spin:Cancel()
content.Visible=true
fadeContent(1,0.35)
if result and result.ok then
local detail=result.reason and tostring(result.reason)or"That key isn't valid. Get a new one."
if detail:lower():find("expir")then
STATS.expired+=1
saveStats()
refreshInfo()
end
notify("Invalid key",detail,"error")
else
local detail=result and result.valid and tostring(result.valid)or"Couldn't check your key. Try again."
notify("Something went wrong",detail,"error")
end
task.wait(0.35)
state.ready=true
checkingKey=false
return
end
if KEYLESS then
statusValue.Text="Keyless"
setRole(statusValue,"TextColor3","accent")
checkText.Text="Keyless Access!"
else
statusValue.Text="Key valid"
setRole(statusValue,"TextColor3","success")
checkText.Text=isSavedKey and"Saved Key Found!"or"Correct Key!"
if KEY_SAVE then
safeWriteFile(KEY_FILE,key)
end
STATS.valid+=1
STATS.last=os.time()
saveStats()
end
fade(spinnerItems,0,0.25)
task.wait(0.25)
spin:Cancel()
resetCheckScreen()
checkScreen.Visible=true
fade(ringItems,1,0.25)
tween(ringScale,0.45,{Scale=1},Enum.EasingStyle.Back)
task.wait(isSavedKey and 0.15 or 0.4)
drawBar(checkBar1,0.14)
task.wait(0.14)
drawBar(checkBar2,0.22)
task.wait(0.22)
if isSavedKey then
confetti(10,false)
else
confetti(22,true)
task.delay(0.3,function()
confetti(12,false)
end)
end
task.wait(isSavedKey and 0.2 or 1)
tween(checkText,0.3,{TextTransparency=0,Position=UDim2 .new(0,0,0,156)},Enum.EasingStyle.Quint)
task.wait(isSavedKey and 0.35 or 1)
snapLocked=true
fade(ringItems,0,0.2)
tween(checkText,0.2,{TextTransparency=1})
task.wait(0.2)
checkScreen.Visible=false
local morphSpec=buildMorph(notifs.styleKey())
morph.Visible=true
morphSpec.spin:Play()
Blur.acquire()
local vp=root.AbsoluteSize
local targetX,targetY
if morphSpec.top then
targetX=vp.X/2
targetY=12+morphSpec.h/2
else
targetX=vp.X-16-morphSpec.w/2
targetY=vp.Y-16-morphSpec.h/2
end
tween(main,0.7,{
Size=UDim2 .new(0,morphSpec.w,0,morphSpec.h),
Position=UDim2 .new(0,targetX,0,targetY),
},Enum.EasingStyle.Quart,Enum.EasingDirection.InOut)
tween(canvas,0.7,{BackgroundColor3=morphSpec.bg,BackgroundTransparency=morphSpec.bgTransparency})
tween(canvasCorner,0.7,{CornerRadius=UDim.new(0,morphSpec.radius)})
tween(decorGroup,0.4,{GroupTransparency=1})
tween(shadow,0.5,{ImageTransparency=1})
tween(borderStroke,0.5,{Transparency=morphSpec.borderTransparency,Color=morphSpec.border})
task.delay(0.35,function()
fade(morphSpec.items,1,0.3)
end)
task.wait(0.75)
task.wait(isSavedKey and 0.2 or 1)
local runError
task.spawn(function()
local callback=cfg.Callback
if type(callback)=="string"and callback~=""then
if not loadstring then
runError="loadstring is not available"
return
end
local fn,compileError=loadstring(callback)
if not fn then
runError=compileError
return
end
callback=fn
end
if type(callback)=="function"then
local ok,err=pcall(callback,key)
if not ok then
runError=err
end
end
end)
task.wait(0.3)
morphSpec.spin:Cancel()
Blur.release()
fade(morphSpec.items,0,0.25)
tween(canvas,0.3,{BackgroundTransparency=1})
tween(borderStroke,0.3,{Transparency=1})
task.wait(0.35)
if runError then
notify("Script error",tostring(runError):sub(1,80),"error",nil,5)
task.wait(5.5)
end
root:Destroy()
end
submit.MouseButton1Click:Connect(function()
if not state.ready or state.closing or checkingKey then
return
end
if KEYLESS then
runKeyCheck("")
return
end
local key=keyBox.Text:match("^%s*(.-)%s*$")
if key==""then
notify("Empty key","Paste your key in the box first.","warn","key")
return
end
runKeyCheck(key)
end)
closeGui=function()
if state.closing then
return
end
state.closing=true
state.ready=false
notifs.dismissAll()
tintTo(closeIcon,C.muted)
tween(closeBtn,0.15,{BackgroundTransparency=1})
if not SHOW_INTRO then
fadeContent(0,0.3)
ctx.pages.fadeOut(0.3)
tween(canvas,0.35,{BackgroundTransparency=1})
tween(decorGroup,0.35,{GroupTransparency=1})
tween(borderStroke,0.35,{Transparency=1})
tween(shadow,0.35,{ImageTransparency=1})
task.wait(0.4)
root:Destroy()
return
end
fadeContent(0,0.2)
ctx.pages.fadeOut(0.2)
task.wait(0.2)
content.Visible=false
introLogo.Position=UDim2 .new(0.5,0,0.5,0)
tween(introLogo,0.4,{ImageTransparency=0})
tween(borderStroke,0.5,{Transparency=0.55})
tween(main,0.65,{Size=UDim2 .new(0,INTRO_SIZE,0,INTRO_SIZE)},Enum.EasingStyle.Quart,Enum.EasingDirection.InOut)
task.wait(0.7)
tween(canvas,0.35,{BackgroundTransparency=1})
tween(decorGroup,0.35,{GroupTransparency=1})
tween(introLogo,0.35,{ImageTransparency=1})
tween(borderStroke,0.35,{Transparency=1})
tween(shadow,0.35,{ImageTransparency=1})
task.wait(0.4)
root:Destroy()
end
closeBtn.MouseButton1Click:Connect(function()
if not state.ready or state.closing then
return
end
task.spawn(closeGui)
end)
closeBtn.MouseEnter:Connect(function()
if not state.ready or state.closing then
return
end
tween(closeBtn,0.15,{BackgroundTransparency=0})
tintTo(closeIcon,C.text)
end)
closeBtn.MouseLeave:Connect(function()
if not state.ready or state.closing then
return
end
tween(closeBtn,0.15,{BackgroundTransparency=1})
tintTo(closeIcon,C.muted)
end)
moonBtn.MouseEnter:Connect(function()
if not state.ready or state.closing then
return
end
tween(moonBtn,0.15,{BackgroundTransparency=0})
tintTo(moonIcon,C.text)
end)
moonBtn.MouseLeave:Connect(function()
tween(moonBtn,0.15,{BackgroundTransparency=1})
tintTo(moonIcon,C.muted)
end)
local THEME_ANIM_TIME=1.6
local switchingTheme=false
local function switchTheme()
if not state.ready or state.closing or checkingKey or switchingTheme then
return
end
switchingTheme=true
state.ready=false
notifs.dismissAll()
tintTo(moonIcon,C.muted)
tween(moonBtn,0.15,{BackgroundTransparency=1})
fadeContent(0,0.25)
task.wait(0.25)
content.Visible=false
spinnerHolder.Position=UDim2 .new(0.5,0,0.5,0)
spin:Play()
fade(spinnerItems,1,0.25)
task.wait(0.4)
themeIndex=themeIndex%#THEME_ORDER+1
local name=THEME_ORDER[themeIndex]
applyTheme(name,THEME_ANIM_TIME)
task.wait(THEME_ANIM_TIME+0.3)
fade(spinnerItems,0,0.25)
task.wait(0.25)
spin:Cancel()
content.Visible=true
fadeContent(1,0.35)
notify("Theme: "..name,"Theme applied.","info","moon")
task.wait(0.35)
state.ready=true
switchingTheme=false
end
moonBtn.MouseButton1Click:Connect(function()
task.spawn(switchTheme)
end)
local guiParent
pcall(function()if type(gethui)=="function"then guiParent=gethui()end end)
if not guiParent then pcall(function()guiParent=game:GetService("CoreGui")end)end
if not guiParent then guiParent=player:WaitForChild("PlayerGui")end
local okParent=pcall(function()root.Parent=guiParent end)
if not okParent then root.Parent=player:WaitForChild("PlayerGui")end
local mobileScale=Instance.new("UIScale")
mobileScale.Parent=main
local function snap()
local viewport=root.AbsoluteSize
if viewport.X>0 and viewport.Y>0 then
mobileScale.Scale=math.min(1,math.max(0.45,(viewport.X-24)/FINAL_W),math.max(0.45,(viewport.Y-24)/FINAL_H))
end
if snapLocked then
return
end
local size=root.AbsoluteSize
main.Position=UDim2 .new(0,math.floor(size.X/2),0,math.floor(size.Y/2))
end
snap()
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(snap)
task.spawn(function()
if SHOW_INTRO then
main.Size=UDim2 .new(0,INTRO_SIZE-20,0,INTRO_SIZE-20)
tween(main,0.6,{Size=UDim2 .new(0,INTRO_SIZE,0,INTRO_SIZE)},Enum.EasingStyle.Quint)
tween(canvas,0.5,{BackgroundTransparency=0})
tween(decorGroup,0.5,{GroupTransparency=0})
tween(introLogo,0.5,{ImageTransparency=0})
if SHOW_SQUARE_CONTORN then
tween(borderStroke,0.5,{Transparency=0.55})
end
tween(shadow,0.5,{ImageTransparency=0.6})
task.wait(SQUARE_TIME)
tween(borderStroke,0.7,{Transparency=1})
tween(main,0.85,{Size=UDim2 .new(0,FINAL_W,0,FINAL_H)},Enum.EasingStyle.Quint)
tween(introLogo,0.7,{Position=UDim2 .new(0.5,0,0.5,-20)},Enum.EasingStyle.Quint)
task.wait(0.35)
spin:Play()
fade(spinnerItems,1,0.4)
task.wait(LOADING_TIME)
fade(spinnerItems,0,0.3)
tween(introLogo,0.3,{ImageTransparency=1})
task.wait(0.2)
spin:Cancel()
else
main.Size=UDim2 .new(0,FINAL_W,0,FINAL_H)
task.wait(LOADING_TIME)
tween(canvas,0.5,{BackgroundTransparency=0})
tween(decorGroup,0.5,{GroupTransparency=0})
tween(shadow,0.5,{ImageTransparency=0.6})
task.wait(0.25)
end
local iconDeadline=os.clock()+12
while not iconsPreloaded and os.clock()<iconDeadline do
task.wait(0.1)
end
content.Visible=true
fadeContent(1,0.45)
task.wait(0.3)
state.ready=true
if KEYLESS then
if KL.autoconfirm and not checkingKey then
task.wait(0.15)
runKeyCheck("")
end
elseif SAVED_KEY and not checkingKey then
keyBox.Text=SAVED_KEY
task.wait(0.15)
runKeyCheck(SAVED_KEY,true)
end
end)
local api={}
function api:SetGetkeyTitle(title)
UI.SetGetkeyTitle(title)
return self
end
function api:SetGetkeyIcon(icon)
UI.SetGetkeyIcon(icon)
return self
end
function api:SetNotifStyle(style)
UI.SetNotifStyle(style)
return self
end
api.NotifStyle=api.SetNotifStyle
function api:SetTabsStyle(style)
UI.SetTabsStyle(style)
return self
end
api.TabsStyle=api.SetTabsStyle
function api:GetMethod(entry)
UI.GetMethod(entry)
return self
end
function api:SetUIFont(font)
UI.SetUIFont(font)
return self
end
function api:SetTitleFont(font)
UI.SetTitleFont(font)
return self
end
function api:Tab(props)
return ctx.pages.createTab(props)
end
function api:ForgetSavedKey()
SAVED_KEY=nil
if type(delfile)~="function"then return false end
if type(isfile)=="function"then
local ok,exists=pcall(isfile,KEY_FILE)
if ok and not exists then return true end
end
return pcall(delfile,KEY_FILE)
end
api.Gui=root
return setmetatable(api,{
__call=function(_,props)
return ctx.pages.createTab(props)
end,
__index=function(_,key)
local value=root[key]
if type(value)=="function"then
return function(_,...)
return value(root,...)
end
end
return value
end,
__newindex=function(_,key,value)
root[key]=value
end,
})
end
return UI
end
__modules["images/images"]=function()
local Images={
FONT="rbxassetid://12187365364",
KEY="rbxassetid://96510194465420",
SUBMIT="rbxassetid://113692007244654",
LINK="rbxassetid://114238209622913",
DISCORD="rbxassetid://127255077587058",
GLOW="rbxassetid://8992230677",
LOGO="rbxassetid://111673746737789",
CLOSE_ICON="rbxassetid://110786993356448",
MOON_ICON="rbxassetid://83380517901735",
SHADOW="rbxassetid://6014261993",
GAME_PLACEHOLDER="rbxassetid://74584987850498",
KEYLESS="rbxassetid://130551565616516",
}
return Images
end
__modules["utilities/jnkie"]=function()
local SDK_URL="https://jnkie.com/sdk/library.lua"
local Jnkie={}
Jnkie.__index=Jnkie
local function safeLoad(url)
if not loadstring then
return nil,"loadstring is not available"
end
local ok,result=pcall(function()
return game:HttpGet(url)
end)
if not ok then
return nil,tostring(result)
end
local fn,compileErr=loadstring(result)
if not fn then
return nil,tostring(compileErr)
end
local okRun,lib=pcall(fn)
if not okRun then
return nil,tostring(lib)
end
return lib
end
function Jnkie.new(config)
config=config or{}
local self=setmetatable({},Jnkie)
self.__isJnkieInstance=true
self.service=config.Service or config.service
self.identifier=config.Identifier or config.identifier
self.provider=config.Provider or config.provider or"Mixed"
self.client=nil
self.loadError=nil
if not self.service or self.service==""then
warn("[Jnkie] Service is missing — check your dashboard for the exact name")
end
if not self.identifier or self.identifier==""then
warn("[Jnkie] Identifier is missing — check your dashboard for your user ID")
end
return self
end
function Jnkie:_client()
if self.client then
return self.client
end
local lib,err=safeLoad(SDK_URL)
if not lib then
self.loadError=err
warn("[Jnkie] failed to load SDK: "..tostring(err))
return nil
end
lib.service=self.service
lib.identifier=self.identifier
lib.provider=self.provider
self.client=lib
return lib
end
local function isSuccess(result)
if type(result)~="table"then
return false
end
if result.valid==true or result.success==true then
return true
end
if result.message=="KEY_VALID"or result.message=="KEYLESS"then
return true
end
return false
end
function Jnkie:CheckKey(key)
local lib=self:_client()
if not lib then
return{valid=false,error=self.loadError or"SDK_LOAD_FAILED"}
end
local ok,result=pcall(lib.check_key,key)
if not ok then
return{valid=false,error=tostring(result)}
end
if type(result)~="table"then
return{valid=false,error="UNEXPECTED_RESPONSE: "..tostring(result)}
end
result.valid=isSuccess(result)
return result
end
function Jnkie:GetKeyLink()
local lib=self:_client()
if not lib then
return nil,self.loadError or"SDK_LOAD_FAILED"
end
local ok,link,err=pcall(lib.get_key_link)
if not ok then
return nil,tostring(link)
end
return link,err
end
function Jnkie:Validator()
local instance=self
local adapter=setmetatable({
__isJnkie=true,
__instance=instance,
},{
__call=function(_,key)
local result=instance:CheckKey(key)
local reason=result and(result.error or result.message)
return result and result.valid==true,reason
end,
})
return adapter
end
return Jnkie
end
__modules["utilities/luaprotect"]=function()
local HttpService=game:GetService("HttpService")
local Players=game:GetService("Players")
local VALIDATE_URL="https://api.luaprotect.dev/v1/public/validate-key"
local LuaProtect={}
LuaProtect.__index=LuaProtect
local function getRequestFunction()
return request or http_request or(syn and syn.request)or(http and http.request)
end
local function getHwid()
if gethwid then
local ok,hwid=pcall(gethwid)
if ok and hwid~=nil and tostring(hwid)~=""then
return tostring(hwid)
end
end
local okClient,clientId=pcall(function()
return game:GetService("RbxAnalyticsService"):GetClientId()
end)
if okClient and clientId and tostring(clientId)~=""then
return tostring(clientId)
end
local lp=Players.LocalPlayer
return tostring(lp and lp.UserId or 0)
end
local function decode(body)
local ok,result=pcall(HttpService.JSONDecode,HttpService,body)
if ok and type(result)=="table"then
return result
end
return nil
end
function LuaProtect.new(config)
config=config or{}
local self=setmetatable({},LuaProtect)
self.__isLuaProtectInstance=true
self.user=config.User or config.user or config.Username or config.username
self.scriptId=config.ScriptId or config.scriptId or config.Script
self.flow=config.Flow or config.flow
self.website=config.Website or config.website
self.hwid=config.Hwid or config.HWID or config.hwid
self.requestSending=false
if not(self.user or self.scriptId or self.flow)then
warn("[LuaProtect] User is missing — set User = \"your_username\" (or ScriptId / Flow)")
end
return self
end
function LuaProtect:_hwid()
if not self.hwid then
self.hwid=getHwid()
end
return tostring(self.hwid)
end
local function appendQuery(url,name,value)
if value==nil or tostring(value)==""then
return url
end
return url.."&"..name.."="..HttpService:UrlEncode(tostring(value))
end
function LuaProtect:_check(key)
local req=getRequestFunction()
if not req then
warn("your executor doesn't support HTTP requests.")
return false
end
local url=VALIDATE_URL.."?key="..HttpService:UrlEncode(key)
url=appendQuery(url,"user",self.user)
url=appendQuery(url,"scriptId",self.scriptId)
url=appendQuery(url,"flow",self.flow)
url=appendQuery(url,"hwid",self:_hwid())
local okReq,res=pcall(req,{Url=url,Method="GET"})
if not okReq or type(res)~="table"then
warn("network error, please try again.")
return false
end
if res.StatusCode==429 then
warn("you are being rate limited, please wait a moment and try again.")
return false
end
local data=type(res.Body)=="string"and decode(res.Body)or nil
if not data then
warn("invalid response from server.")
return false
end
if data.valid==true then
self.lastResult=data
return true
end
local reason=data.reason or data.message or data.error
warn(reason and tostring(reason)or"key is invalid or expired.")
return false
end
function LuaProtect:CheckKey(key)
key=tostring(key or""):match("^%s*(.-)%s*$")
if key==""then
warn("key is empty.")
return false
end
if not(self.user or self.scriptId or self.flow)then
warn("LuaProtect User (or ScriptId / Flow) is missing.")
return false
end
if self.requestSending then
warn("a request is already being sent, please slow down.")
return false
end
self.requestSending=true
local ok,valid=pcall(self._check,self,key)
self.requestSending=false
if not ok then
warn("error checking key")
return false
end
return valid==true
end
function LuaProtect:GetKeyLink()
local site=self.website
if type(site)~="string"or site==""then
warn("LuaProtect Website is not set.")
return nil
end
if not site:match("^https?://")then
site="https://"..site
end
return site
end
function LuaProtect:Validator()
local instance=self
return setmetatable({
__isLuaProtect=true,
__instance=instance,
},{
__call=function(_,key)
return instance:CheckKey(key)
end,
})
end
return LuaProtect
end
__modules["utilities/lucide"]=function()
local Lucide={}
local PACK_URL="https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"
local PREFIX="lucide:"
local pack=nil
local failed=false
local loading=false
local preloaded={}
local warned={}
local function fetch(url)
local ok,body=pcall(function()
return game:HttpGet(url)
end)
if ok and type(body)=="string"and body~=""then
return body
end
ok,body=pcall(function()
return game:HttpGetAsync(url)
end)
if ok and type(body)=="string"and body~=""then
return body
end
return nil
end
local function loadPack()
if pack or failed then
return pack
end
if loading then
while loading do
task.wait()
end
return pack
end
loading=true
local ok,result=pcall(function()
local body=fetch(PACK_URL)
if not body then
error("could not download the icon pack")
end
local chunk,err=loadstring(body)
if not chunk then
error(err)
end
return chunk()
end)
loading=false
if ok and type(result)=="table"then
pack=result
else
failed=true
warn("[Ophyn] Lucide icons unavailable: "..tostring(result))
end
return pack
end
local function toAsset(value)
if type(value)=="number"then
return"rbxassetid://"..tostring(math.floor(value))
end
if type(value)=="string"and value:match("^%d+$")then
return"rbxassetid://"..value
end
return value
end
function Lucide.isName(value)
if type(value)~="string"or value==""then
return false
end
if value:match("^%d+$")then
return false
end
if value:match("^rbx%a*://")or value:match("^https?://")then
return false
end
return true
end
local function stripPrefix(name)
if name:sub(1,#PREFIX):lower()==PREFIX then
return name:sub(#PREFIX+1)
end
return name
end
local function preload(sheet)
if preloaded[sheet]then
return
end
preloaded[sheet]=true
task.spawn(function()
pcall(function()
game:GetService("ContentProvider"):PreloadAsync({sheet})
end)
end)
end
function Lucide.resolve(value)
if not Lucide.isName(value)then
return nil
end
local name=stripPrefix(value):lower():gsub("_","-")
local loaded=loadPack()
if not loaded then
return nil
end
local icons=loaded.Icons or loaded
local entry=type(icons)=="table"and icons[name]or nil
if type(entry)~="table"then
if not warned[name]then
warned[name]=true
warn('[Ophyn] unknown Lucide icon "'..tostring(value)..'"')
end
return nil
end
local sheet=entry.Image
if type(loaded.Spritesheets)=="table"and loaded.Spritesheets[tostring(entry.Image)]~=nil then
sheet=loaded.Spritesheets[tostring(entry.Image)]
end
sheet=toAsset(sheet)
if type(sheet)~="string"then
return nil
end
preload(sheet)
return{
Image=sheet,
RectSize=entry.ImageRectSize or Vector2 .new(0,0),
RectOffset=entry.ImageRectPosition or entry.ImageRectOffset or Vector2 .new(0,0),
}
end
function Lucide.apply(label,value)
local sprite=Lucide.resolve(value)
if sprite then
label.Image=sprite.Image
label.ImageRectSize=sprite.RectSize
label.ImageRectOffset=sprite.RectOffset
return true
end
label.ImageRectSize=Vector2 .new(0,0)
label.ImageRectOffset=Vector2 .new(0,0)
if Lucide.isName(value)then
label.Image=""
return false
end
label.Image=value or""
return value~=nil
end
return Lucide
end
__modules["utilities/panda"]=function()
local LIB_URL="https://secure.pandauth.com/pv4/lib"
local REASONS={
INVALID_KEY="key is invalid or expired.",
RATE_LIMITED="you are being rate limited, please wait a moment and try again.",
NETWORK="network error, please try again.",
NO_SERVICE="Panda ServiceId is missing or invalid.",
NO_KEY="key is empty.",
NO_HTTP="your executor doesn't support HTTP requests.",
IDENTITY="couldn't verify the Panda server identity, please try again later.",
PROTOCOL="Panda protocol error, please try again later.",
}
local Panda={}
Panda.__index=Panda
function Panda.new(config)
config=config or{}
local self=setmetatable({},Panda)
local serviceId=config.ServiceId or config.Service or config.serviceId
self.serviceId=serviceId~=nil and tostring(serviceId)or""
self.debug=config.Debug==true
self.lib=nil
self.loading=false
if self.serviceId==""then
warn("[Panda] ServiceId is missing — check your Panda dashboard")
end
return self
end
function Panda:_load()
while self.loading do
task.wait(0.1)
end
if self.lib then
return self.lib
end
if self.serviceId==""then
return nil,REASONS.NO_SERVICE
end
self.loading=true
local lib,err
local okFetch,src=pcall(function()
return game:HttpGet(LIB_URL)
end)
if not okFetch or type(src)~="string"or src==""then
err="couldn't download the Panda library."
elseif not loadstring then
err="loadstring is not available."
else
local fn,compileError=loadstring(src)
if not fn then
err="couldn't load the Panda library: "..tostring(compileError)
else
local okRun,result=pcall(fn)
if okRun and type(result)=="table"and type(result.configure)=="function"then
local okConfig,configError=pcall(result.configure,{
serviceId=self.serviceId,
debug=self.debug,
kickOnDetect=false,
})
if okConfig then
lib=result
else
err="couldn't configure the Panda library: "..tostring(configError)
end
else
err="Panda library failed to initialize."
end
end
end
self.loading=false
if lib then
self.lib=lib
return lib
end
return nil,err
end
function Panda:CheckKey(key)
key=tostring(key or""):match("^%s*(.-)%s*$")
if key==""then
return false,REASONS.NO_KEY
end
local lib,err=self:_load()
if not lib then
return false,err
end
if type(lib.validateEx)=="function"then
local ok,valid,reason=pcall(lib.validateEx,key)
if not ok then
return false,tostring(valid)
end
if valid==true then
return true
end
return false,REASONS[reason]or("Panda error: "..tostring(reason))
end
local ok,result=pcall(lib.validate,key)
if not ok then
return false,tostring(result)
end
if type(result)=="table"and result.success==true then
return true
end
local reason=type(result)=="table"and(result.reason or result.error)or nil
return false,REASONS[reason]or tostring(reason or"key is invalid.")
end
function Panda:GetKeyLink()
local lib,err=self:_load()
if not lib then
return nil,err
end
if type(lib.getKeyUrl)~="function"then
return nil,"Panda library has no getKeyUrl."
end
local ok,url=pcall(lib.getKeyUrl)
if ok and type(url)=="string"and url~=""then
return url
end
return nil,"Failed to get link."
end
return Panda
end
__modules["utilities/platoboost"]=function()
local HttpService=game:GetService("HttpService")
local Players=game:GetService("Players")
local sha256=(function()
local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;
return Z
end)()
local Platoboost={}
Platoboost.__index=Platoboost
local HOSTS={"https://api.platoboost.app","https://api.platoboost.com","https://api.platoboost.net"}
local LINK_CACHE_TIME=10*60
local RATE_LIMIT_MESSAGE="you are being rate limited, please wait 20 seconds and try again."
local BAD_STATUS_MESSAGE="server returned an invalid status code, please try again later."
local JSON_HEADERS={["Content-Type"]="application/json"}
local rng=Random.new()
local function getRequestFunction()
return request or http_request or(syn and syn.request)or(http and http.request)
end
local function getHwid()
if gethwid then
local ok,hwid=pcall(gethwid)
if ok and hwid~=nil and tostring(hwid)~=""then
return tostring(hwid)
end
end
local lp=Players.LocalPlayer
return tostring(lp and lp.UserId or 0)
end
local function generateNonce()
local chars=table.create(16)
for i=1,16 do
chars[i]=string.char(rng:NextInteger(97,122))
end
return table.concat(chars)
end
local function decode(body)
local ok,result=pcall(HttpService.JSONDecode,HttpService,body)
if ok and type(result)=="table"then
return result
end
return nil
end
function Platoboost.new(config)
config=config or{}
local self=setmetatable({},Platoboost)
self.__isPlatoboostInstance=true
local service=config.ServiceId or config.Service or config.service
self.service=tonumber(service)or service
self.secret=config.Secret or config.secret
local useNonce=config.UseNonce
if useNonce==nil then
useNonce=config.useNonce
end
self.useNonce=useNonce~=false
local host=config.Host or config.host
if type(host)=="string"and host~=""then
host=host:gsub("/+$","")
if not host:match("^https?://")then
host="https://"..host
end
self.host=host
end
self.identifier=nil
self.requestSending=false
self.cachedLink=nil
self.cachedTime=0
if self.service==nil or self.service==""then
warn("[Platoboost] ServiceId is missing — check your Platoboost dashboard")
end
if self.useNonce and(type(self.secret)~="string"or self.secret=="")then
warn("[Platoboost] Secret is missing — keys can't be verified without it")
end
return self
end
function Platoboost:_host()
if self.host then
return self.host
end
local req=getRequestFunction()
if req then
for _,host in ipairs(HOSTS)do
local ok,res=pcall(req,{Url=host.."/public/connectivity",Method="GET"})
if ok and type(res)=="table"and(res.StatusCode==200 or res.StatusCode==429)then
self.host=host
return self.host
end
end
end
self.host=HOSTS[1]
return self.host
end
function Platoboost:_identifier()
if not self.identifier then
self.identifier=sha256(getHwid())
end
return self.identifier
end
function Platoboost:_send(options)
local req=getRequestFunction()
if not req then
return nil,"your executor doesn't support HTTP requests."
end
local ok,res=pcall(req,options)
if not ok then
return nil,tostring(res)
end
if type(res)~="table"then
return nil,"invalid response from server."
end
return res
end
function Platoboost:GetKeyLink()
if self.cachedLink and self.cachedTime+LINK_CACHE_TIME>os.time()then
return self.cachedLink
end
if self.service==nil or self.service==""then
return nil,"Platoboost ServiceId is missing."
end
local res,err=self:_send({
Url=self:_host().."/public/start",
Method="POST",
Body=HttpService:JSONEncode({
service=self.service,
identifier=self:_identifier(),
}),
Headers=JSON_HEADERS,
})
if not res then
return nil,err
end
if res.StatusCode==200 then
local decoded=decode(res.Body)
if decoded then
if decoded.success==true and type(decoded.data)=="table"and decoded.data.url then
self.cachedLink=decoded.data.url
self.cachedTime=os.time()
return self.cachedLink
end
return nil,tostring(decoded.message or"Failed to get link.")
end
elseif res.StatusCode==429 then
return nil,RATE_LIMIT_MESSAGE
end
return nil,"Failed to get link."
end
function Platoboost:_integrityOk(data,nonce)
if not self.useNonce then
return true
end
return data.hash==sha256("true".."-"..nonce.."-"..tostring(self.secret))
end
function Platoboost:_redeem(key)
local nonce=generateNonce()
local body={
identifier=self:_identifier(),
key=key,
}
if self.useNonce then
body.nonce=nonce
end
local res,err=self:_send({
Url=self:_host().."/public/redeem/"..tostring(self.service),
Method="POST",
Body=HttpService:JSONEncode(body),
Headers=JSON_HEADERS,
})
if not res then
return false,err
end
if res.StatusCode==429 then
return false,RATE_LIMIT_MESSAGE
end
if res.StatusCode~=200 then
return false,BAD_STATUS_MESSAGE
end
local decoded=decode(res.Body)
if not decoded then
return false,"invalid response from server."
end
if decoded.success~=true then
local message=tostring(decoded.message or"request failed.")
if message:sub(1,27)=="unique constraint violation"then
return false,"you already have an active key, please wait for it to expire before redeeming it."
end
return false,message
end
local data=type(decoded.data)=="table"and decoded.data or{}
if data.valid~=true then
return false,"key is invalid."
end
if not self:_integrityOk(data,nonce)then
return false,"failed to verify integrity."
end
return true
end
function Platoboost:_verify(key)
local nonce=generateNonce()
local url=self:_host()
.."/public/whitelist/"
..tostring(self.service)
.."?identifier="
..self:_identifier()
.."&key="
..HttpService:UrlEncode(key)
if self.useNonce then
url=url.."&nonce="..nonce
end
local res,err=self:_send({Url=url,Method="GET"})
if not res then
return false,err
end
if res.StatusCode==429 then
return false,RATE_LIMIT_MESSAGE
end
if res.StatusCode~=200 then
return false,BAD_STATUS_MESSAGE
end
local decoded=decode(res.Body)
if not decoded then
return false,"invalid response from server."
end
if decoded.success~=true then
return false,tostring(decoded.message or"request failed.")
end
local data=type(decoded.data)=="table"and decoded.data or{}
if data.valid==true then
if not self:_integrityOk(data,nonce)then
return false,"failed to verify integrity."
end
return true
end
if key:sub(1,4)=="KEY_"then
return self:_redeem(key)
end
return false,"key is invalid."
end
function Platoboost:CheckKey(key)
key=tostring(key or""):match("^%s*(.-)%s*$")
if key==""then
return false,"key is empty."
end
if self.service==nil or self.service==""then
return false,"Platoboost ServiceId is missing."
end
if self.useNonce and(type(self.secret)~="string"or self.secret=="")then
return false,"Platoboost Secret is missing."
end
if self.requestSending then
return false,"a request is already being sent, please slow down."
end
self.requestSending=true
local ok,valid,reason=pcall(self._verify,self,key)
self.requestSending=false
if not ok then
return false,tostring(valid)
end
return valid==true,reason
end
function Platoboost:Validator()
local instance=self
return setmetatable({
__isPlatoboost=true,
__instance=instance,
},{
__call=function(_,key)
return instance:CheckKey(key)
end,
})
end
return Platoboost
end
__modules["variables"]=function()
return{
Title="Ophyn",
Description="Key System",
Logo="rbxassetid://111673746737789",
Theme="Plant-Dark",
Folder="Ophyn-KSY",
getkey=true,
Intro="true",
startintro_size=80,
squareintro_time=1.2,
squarecontorn="true",
Changelogocolor=true,
Changeiconscolor=true,
ChangeTheme="true",
discord_link="",
website_link="",
Discord="true",
Website="false",
Informations="true",
Keyless={
enabled=false,
disabletextbox=true,
disablegetkey=true,
showcard=true,
autoconfirm=false,
},
NotifStyle="1",
TabsStyle="1",
SupportedGames={},
Callback=function(key)
end,
}
end
local KeySystem={}
function KeySystem.new(options)
return import("components/window/ui").new(options)
end
local function firstArg(a,b)
if a==KeySystem then
return b
end
return a
end
function KeySystem.SetGetkeyTitle(a,b)
import("components/window/ui").SetGetkeyTitle(firstArg(a,b))
return KeySystem
end
function KeySystem.SetGetkeyIcon(a,b)
import("components/window/ui").SetGetkeyIcon(firstArg(a,b))
return KeySystem
end
function KeySystem.SetNotifStyle(a,b)
import("components/window/ui").SetNotifStyle(firstArg(a,b))
return KeySystem
end
KeySystem.NotifStyle=KeySystem.SetNotifStyle
function KeySystem.SetTabsStyle(a,b)
import("components/window/ui").SetTabsStyle(firstArg(a,b))
return KeySystem
end
KeySystem.TabsStyle=KeySystem.SetTabsStyle
function KeySystem.GetMethod(a,b)
return import("components/window/ui").GetMethod(firstArg(a,b))
end
function KeySystem.SetUIFont(a,b)
import("components/window/ui").SetUIFont(firstArg(a,b))
return KeySystem
end
function KeySystem.SetTitleFont(a,b)
import("components/window/ui").SetTitleFont(firstArg(a,b))
return KeySystem
end
KeySystem.Jnkie=import("utilities/jnkie")
return KeySystem
end
local LIB
local CrossAIMusic
local NgotStudio={};
local __xNgotIsInstance=function(value)
if value==nil then return false end
if type(typeof)~="function"then return type(value)=="table"or type(value)=="userdata"end
local ok,kind=pcall(typeof,value)
return ok and kind=="Instance"
end
local __xNgotIsOurGui=function(inst)
if not __xNgotIsInstance(inst)then return false end
local okGui,isGui=pcall(function()return inst:IsA("ScreenGui")end)
if not okGui or not isGui then return false end
local okName,name=pcall(function()return tostring(inst.Name)end)
if not okName then return false end
local marked=false
pcall(function()marked=inst:GetAttribute("xNgotStudioOwned")==true end)
if marked or name=="NgotStudio"or name=="xNgotStudio_FullDynamicIsland"or name=="xNgotStudio_FullIsland"then
return true
end
local okLook,looks=pcall(function()
if inst:FindFirstChild("3e")~=nil and inst:FindFirstChild("NotificationList")~=nil then return true end
if not inst:FindFirstChild("NotificationList")then return false end
for _,child in ipairs(inst:GetChildren())do
if child:IsA("Folder")then
for _,win in ipairs(child:GetChildren())do
if win:FindFirstChild("TopFrame")and win:FindFirstChild("TabButtons")then return true end
end
end
end
return false
end)
return okLook and looks==true
end
local __xNgotGuiParents=function()
local parents={}
local function push(inst)
if __xNgotIsInstance(inst)then parents[#parents+1]=inst end
end
pcall(function()if gethui then push(gethui())end end)
pcall(function()push(game:GetService("CoreGui"))end)
pcall(function()push(game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui"))end)
return parents
end
local __xNgotDestroyGui=function(inst,keep)
if inst==nil or inst==keep then return false end
if not __xNgotIsOurGui(inst)then return false end
local ok=pcall(function()inst:Destroy()end)
return ok
end
pcall(function()
local active=_G.__xNgotActiveWindow
if type(active)=="table"and type(active.Destroy)=="function"then active:Destroy()end
_G.__xNgotActiveWindow=nil
end)
pcall(function()
local tracked=_G.__xNgotStudioGuis
if type(tracked)=="table"then
for inst in pairs(tracked)do __xNgotDestroyGui(inst,nil)end
end
__xNgotDestroyGui(_G.__xNgotStudioGui,nil)
_G.__xNgotStudioGui=nil
_G.__xNgotStudioGuis=setmetatable({},{__mode="k"})
end)
pcall(function()
for _,parent in ipairs(__xNgotGuiParents())do
pcall(function()
for _,child in ipairs(parent:GetChildren())do
__xNgotDestroyGui(child,nil)
end
end)
end
local okLight,Lighting=pcall(function()return game:GetService("Lighting")end)
if okLight and Lighting then
pcall(function()
local blur=Lighting:FindFirstChild("xNgotStudio_FullIslandBlur")
if blur then blur:Destroy()end
end)
end
end)
NgotStudio["1"]=Instance.new("ScreenGui");
NgotStudio["1"]["Name"]=[[NgotStudio]];
NgotStudio["1"]["ZIndexBehavior"]=Enum.ZIndexBehavior.Sibling;
NgotStudio["1"]["ResetOnSpawn"]=false;
pcall(function()NgotStudio["1"]:SetAttribute("xNgotStudioOwned",true)end)
NgotStudio["1"].IgnoreGuiInset=true
pcall(function()
NgotStudio["1"].ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets
end)
local cloneref=cloneref or function(...)return...end
if protect_gui then
protect_gui(NgotStudio["1"])
elseif gethui then
NgotStudio["1"].Parent=gethui()
elseif pcall(function()game.CoreGui:GetChildren()end)then
NgotStudio["1"].Parent=cloneref(game:GetService("CoreGui"))
else
NgotStudio["1"].Parent=game.Players.LocalPlayer:WaitForChild("PlayerGui")
end
pcall(function()
_G.__xNgotStudioGui=NgotStudio["1"]
local tracked=_G.__xNgotStudioGuis
if type(tracked)=="table"then tracked[NgotStudio["1"]]=true end
end)
NgotStudio["2"]=Instance.new("Frame",NgotStudio["1"]);
NgotStudio["2"]["ZIndex"]=0;
NgotStudio["2"]["BorderSizePixel"]=2;
NgotStudio["2"]["BackgroundColor3"]=Color3 .fromRGB(37,40,47);
NgotStudio["2"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["2"]["Size"]=UDim2 .new(0,528,0,334);
NgotStudio["2"]["Position"]=UDim2 .new(0.5278,0,0.5,0);
NgotStudio["2"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["2"]["Name"]=[[Window]];
NgotStudio["3"]=Instance.new("UICorner",NgotStudio["2"]);
NgotStudio["3"]["CornerRadius"]=UDim.new(0,10);
NgotStudio["4"]=Instance.new("Frame",NgotStudio["2"]);
NgotStudio["4"]["Visible"]=false;
NgotStudio["4"]["ZIndex"]=4;
NgotStudio["4"]["BorderSizePixel"]=0;
NgotStudio["4"]["BackgroundColor3"]=Color3 .fromRGB(32,35,41);
NgotStudio["4"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["4"]["ClipsDescendants"]=true;
NgotStudio["4"]["Size"]=UDim2 .new(0.7281,0,0.68367,0);
NgotStudio["4"]["Position"]=UDim2 .new(0.5,0,0.5,0);
NgotStudio["4"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["4"]["Name"]=[[DropdownSelection]];
NgotStudio["5"]=Instance.new("UICorner",NgotStudio["4"]);
NgotStudio["5"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["6"]=Instance.new("UIStroke",NgotStudio["4"]);
NgotStudio["6"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["6"]["Thickness"]=1.5;
NgotStudio["6"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["7"]=Instance.new("Frame",NgotStudio["4"]);
NgotStudio["7"]["BorderSizePixel"]=0;
NgotStudio["7"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["7"]["Size"]=UDim2 .new(1,0,0,50);
NgotStudio["7"]["Position"]=UDim2 .new(0,0,0,0);
NgotStudio["7"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["7"]["Name"]=[[TopBar]];
NgotStudio["7"]["BackgroundTransparency"]=1;
NgotStudio["8"]=Instance.new("Frame",NgotStudio["7"]);
NgotStudio["8"]["BorderSizePixel"]=0;
NgotStudio["8"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["8"]["Size"]=UDim2 .new(0,120,0,25);
NgotStudio["8"]["Position"]=UDim2 .new(1,-50,0.5,0);
NgotStudio["8"]["Name"]=[[BoxFrame]];
NgotStudio["8"]["BackgroundTransparency"]=1;
NgotStudio["9"]=Instance.new("ImageLabel",NgotStudio["8"]);
NgotStudio["9"]["ZIndex"]=0;
NgotStudio["9"]["BorderSizePixel"]=0;
NgotStudio["9"]["SliceCenter"]=Rect.new(49,49,450,450);
NgotStudio["9"]["ScaleType"]=Enum.ScaleType.Slice;
NgotStudio["9"]["ImageTransparency"]=0.75;
NgotStudio["9"]["ImageColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["9"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["9"]["Image"]=[[rbxassetid://6014261993]];
NgotStudio["9"]["Size"]=UDim2 .new(1,30,1,30);
NgotStudio["9"]["BackgroundTransparency"]=1;
NgotStudio["9"]["Name"]=[[DropShadow]];
NgotStudio["9"]["Position"]=UDim2 .new(0.5,0,0.5,0);
NgotStudio["a"]=Instance.new("Frame",NgotStudio["8"]);
NgotStudio["a"]["BorderSizePixel"]=0;
NgotStudio["a"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["a"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["a"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["a"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["b"]=Instance.new("UICorner",NgotStudio["a"]);
NgotStudio["b"]["CornerRadius"]=UDim.new(0,5);
NgotStudio["c"]=Instance.new("UIStroke",NgotStudio["a"]);
NgotStudio["c"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["c"]["Thickness"]=1.5;
NgotStudio["c"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["d"]=Instance.new("TextBox",NgotStudio["a"]);
NgotStudio["d"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["d"]["BorderSizePixel"]=0;
NgotStudio["d"]["TextWrapped"]=true;
NgotStudio["d"]["TextTruncate"]=Enum.TextTruncate.AtEnd;
NgotStudio["d"]["TextSize"]=14;
NgotStudio["d"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["d"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["d"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["d"]["ClipsDescendants"]=true;
NgotStudio["d"]["PlaceholderText"]=[[Input here...]];
NgotStudio["d"]["Size"]=UDim2 .new(1,-25,1,0);
NgotStudio["d"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["d"]["Text"]=[[]];
NgotStudio["d"]["BackgroundTransparency"]=1;
NgotStudio["e"]=Instance.new("UIPadding",NgotStudio["d"]);
NgotStudio["e"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["e"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["e"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["e"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["f"]=Instance.new("ImageButton",NgotStudio["a"]);
NgotStudio["f"]["BorderSizePixel"]=0;
NgotStudio["f"]["BackgroundTransparency"]=1;
NgotStudio["f"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["f"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["f"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["f"]["Image"]=[[rbxassetid://86928976705683]];
NgotStudio["f"]["Size"]=UDim2 .new(0,15,0,15);
NgotStudio["f"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["f"]["Position"]=UDim2 .new(1,-5,0.5,0);
NgotStudio["10"]=Instance.new("ImageButton",NgotStudio["7"]);
NgotStudio["10"]["BorderSizePixel"]=0;
NgotStudio["10"]["BackgroundTransparency"]=1;
NgotStudio["10"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["10"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["10"]["ZIndex"]=0;
NgotStudio["10"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["10"]["Image"]=[[rbxassetid://132453323679056]];
NgotStudio["10"]["Size"]=UDim2 .new(0,25,0,25);
NgotStudio["10"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["10"]["Name"]=[[Close]];
NgotStudio["10"]["Position"]=UDim2 .new(1,-12,0.5,0);
NgotStudio["11"]=Instance.new("TextLabel",NgotStudio["7"]);
NgotStudio["11"]["TextWrapped"]=true;
NgotStudio["11"]["Interactable"]=false;
NgotStudio["11"]["ZIndex"]=0;
NgotStudio["11"]["BorderSizePixel"]=0;
NgotStudio["11"]["TextSize"]=18;
NgotStudio["11"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["11"]["TextScaled"]=true;
NgotStudio["11"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["11"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["11"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["11"]["BackgroundTransparency"]=1;
NgotStudio["11"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["11"]["Size"]=UDim2 .new(0.5,0,0,18);
NgotStudio["11"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["11"]["Text"]=[[Dropdown]];
NgotStudio["11"]["Name"]=[[Title]];
NgotStudio["11"]["Position"]=UDim2 .new(0,12,0.5,0);
NgotStudio["12"]=Instance.new("Folder",NgotStudio["4"]);
NgotStudio["12"]["Name"]=[[Dropdowns]];
NgotStudio["13"]=Instance.new("Frame",NgotStudio["2"]);
NgotStudio["13"]["BorderSizePixel"]=0;
NgotStudio["13"]["BackgroundColor3"]=Color3 .fromRGB(37,40,47);
NgotStudio["13"]["ClipsDescendants"]=true;
NgotStudio["13"]["Size"]=UDim2 .new(0,165,1,-35);
NgotStudio["13"]["Position"]=UDim2 .new(0,0,0,35);
NgotStudio["13"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["13"]["Name"]=[[TabButtons]];
NgotStudio["13"]["SelectionGroup"]=true;
NgotStudio["14"]=Instance.new("ScrollingFrame",NgotStudio["13"]);
NgotStudio["14"]["Active"]=true;
NgotStudio["14"]["ScrollingDirection"]=Enum.ScrollingDirection.Y;
NgotStudio["14"]["BorderSizePixel"]=0;
NgotStudio["14"]["CanvasSize"]=UDim2 .new(0,0,0,0);
NgotStudio["14"]["ElasticBehavior"]=Enum.ElasticBehavior.Never;
NgotStudio["14"]["TopImage"]=[[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["14"]["BackgroundColor3"]=Color3 .fromRGB(37,40,47);
NgotStudio["14"]["Name"]=[[Lists]];
NgotStudio["14"]["Selectable"]=false;
NgotStudio["14"]["BottomImage"]=[[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["14"]["AutomaticCanvasSize"]=Enum.AutomaticSize.Y;
NgotStudio["14"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["14"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["14"]["ScrollBarThickness"]=4;
NgotStudio["14"]["BackgroundTransparency"]=1;
NgotStudio["15"]=Instance.new("UIListLayout",NgotStudio["14"]);
NgotStudio["15"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["16"]=Instance.new("Frame",NgotStudio["14"]);
NgotStudio["16"]["Visible"]=false;
NgotStudio["16"]["BorderSizePixel"]=0;
NgotStudio["16"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["16"]["Size"]=UDim2 .new(1,0,0,36);
NgotStudio["16"]["Position"]=UDim2 .new(-0.0375,0,0.38434,0);
NgotStudio["16"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["16"]["Name"]=[[TabButton]];
NgotStudio["16"]["BackgroundTransparency"]=1;
NgotStudio["17"]=Instance.new("Frame",NgotStudio["16"]);
NgotStudio["17"]["BorderSizePixel"]=0;
NgotStudio["17"]["BackgroundColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["17"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["17"]["Size"]=UDim2 .new(0,5,0,25);
NgotStudio["17"]["Position"]=UDim2 .new(0,8,0,18);
NgotStudio["17"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["17"]["Name"]=[[Bar]];
NgotStudio["18"]=Instance.new("UIGradient",NgotStudio["17"]);
NgotStudio["18"]["Enabled"]=false;
NgotStudio["18"]["Rotation"]=90;
NgotStudio["18"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(110,212,255)),ColorSequenceKeypoint.new(0.978,Color3 .fromRGB(0,124,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,218,255))};
NgotStudio["19"]=Instance.new("UICorner",NgotStudio["17"]);
NgotStudio["19"]["CornerRadius"]=UDim.new(0,100);
NgotStudio["1a"]=Instance.new("ImageButton",NgotStudio["16"]);
NgotStudio["1a"]["BorderSizePixel"]=0;
NgotStudio["1a"]["BackgroundTransparency"]=1;
NgotStudio["1a"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["1a"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["1a"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["1a"]["Image"]=[[rbxassetid://113216930555884]];
NgotStudio["1a"]["Size"]=UDim2 .new(0,31,0,30);
NgotStudio["1a"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["1a"]["Position"]=UDim2 .new(0,21,0,18);
NgotStudio["1b"]=Instance.new("UIAspectRatioConstraint",NgotStudio["1a"]);
NgotStudio["1c"]=Instance.new("TextLabel",NgotStudio["16"]);
NgotStudio["1c"]["TextWrapped"]=true;
NgotStudio["1c"]["BorderSizePixel"]=0;
NgotStudio["1c"]["TextSize"]=14;
NgotStudio["1c"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["1c"]["TextScaled"]=true;
NgotStudio["1c"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["1c"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["1c"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["1c"]["BackgroundTransparency"]=1;
NgotStudio["1c"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["1c"]["Size"]=UDim2 .new(0,88,0,16);
NgotStudio["1c"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["1c"]["Text"]=[[NgotStudio]];
NgotStudio["1c"]["Position"]=UDim2 .new(0,57,0.5,0);
NgotStudio["1d"]=Instance.new("UIPadding",NgotStudio["14"]);
NgotStudio["1d"]["PaddingTop"]=UDim.new(0,8);
NgotStudio["1e"]=Instance.new("Frame",NgotStudio["14"]);
NgotStudio["1e"]["Visible"]=false;
NgotStudio["1e"]["BorderSizePixel"]=0;
NgotStudio["1e"]["BackgroundColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["1e"]["Size"]=UDim2 .new(1,0,0,1);
NgotStudio["1e"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["1e"]["Name"]=[[Divider]];
NgotStudio["1f"]=Instance.new("ImageButton",NgotStudio["14"]);
NgotStudio["1f"]["Active"]=false;
NgotStudio["1f"]["BorderSizePixel"]=0;
NgotStudio["1f"]["AutoButtonColor"]=false;
NgotStudio["1f"]["Visible"]=false;
NgotStudio["1f"]["BackgroundTransparency"]=1;
NgotStudio["1f"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["1f"]["Selectable"]=false;
NgotStudio["1f"]["Size"]=UDim2 .new(1,0,0,36);
NgotStudio["1f"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["1f"]["Name"]=[[TabButton]];
NgotStudio["20"]=Instance.new("ImageButton",NgotStudio["1f"]);
NgotStudio["20"]["BorderSizePixel"]=0;
NgotStudio["20"]["ImageTransparency"]=0.5;
NgotStudio["20"]["BackgroundTransparency"]=1;
NgotStudio["20"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["20"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["20"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["20"]["Image"]=[[rbxassetid://113216930555884]];
NgotStudio["20"]["Size"]=UDim2 .new(0,31,0,30);
NgotStudio["20"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["20"]["Position"]=UDim2 .new(0,6,0,18);
NgotStudio["21"]=Instance.new("UIAspectRatioConstraint",NgotStudio["20"]);
NgotStudio["22"]=Instance.new("TextLabel",NgotStudio["1f"]);
NgotStudio["22"]["TextWrapped"]=true;
NgotStudio["22"]["BorderSizePixel"]=0;
NgotStudio["22"]["TextSize"]=14;
NgotStudio["22"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["22"]["TextTransparency"]=0.5;
NgotStudio["22"]["TextScaled"]=true;
NgotStudio["22"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["22"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["22"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["22"]["BackgroundTransparency"]=1;
NgotStudio["22"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["22"]["Size"]=UDim2 .new(0,103,0,16);
NgotStudio["22"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["22"]["Text"]=[[NgotStudio]];
NgotStudio["22"]["Position"]=UDim2 .new(0,42,0.5,0);
NgotStudio["23"]=Instance.new("Frame",NgotStudio["1f"]);
NgotStudio["23"]["BorderSizePixel"]=0;
NgotStudio["23"]["BackgroundColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["23"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["23"]["Size"]=UDim2 .new(0,5,0,0);
NgotStudio["23"]["Position"]=UDim2 .new(0,8,0,18);
NgotStudio["23"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["23"]["Name"]=[[Bar]];
NgotStudio["23"]["BackgroundTransparency"]=1;
NgotStudio["24"]=Instance.new("UICorner",NgotStudio["23"]);
NgotStudio["24"]["CornerRadius"]=UDim.new(0,100);
NgotStudio["25"]=Instance.new("UICorner",NgotStudio["13"]);
NgotStudio["25"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["26"]=Instance.new("Frame",NgotStudio["13"]);
NgotStudio["26"]["BorderSizePixel"]=0;
NgotStudio["26"]["BackgroundColor3"]=Color3 .fromRGB(37,40,47);
NgotStudio["26"]["Size"]=UDim2 .new(1,0,0,5);
NgotStudio["26"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["26"]["Name"]=[[AntiCornerTop]];
NgotStudio["27"]=Instance.new("Frame",NgotStudio["13"]);
NgotStudio["27"]["BorderSizePixel"]=0;
NgotStudio["27"]["BackgroundColor3"]=Color3 .fromRGB(37,40,47);
NgotStudio["27"]["AnchorPoint"]=Vector2 .new(0.5,0);
NgotStudio["27"]["Size"]=UDim2 .new(0,2,1,0);
NgotStudio["27"]["Position"]=UDim2 .new(1,1,0,0);
NgotStudio["27"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["27"]["Name"]=[[AntiCornerRight]];
NgotStudio["28"]=Instance.new("Frame",NgotStudio["13"]);
NgotStudio["28"]["ZIndex"]=2;
NgotStudio["28"]["BorderSizePixel"]=0;
NgotStudio["28"]["BackgroundColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["28"]["AnchorPoint"]=Vector2 .new(1,0);
NgotStudio["28"]["Size"]=UDim2 .new(0,2,1,0);
NgotStudio["28"]["Position"]=UDim2 .new(1,0,0,0);
NgotStudio["28"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["28"]["Name"]=[[Border]];
NgotStudio["29"]=Instance.new("Frame",NgotStudio["2"]);
NgotStudio["29"]["BorderSizePixel"]=0;
NgotStudio["29"]["BackgroundColor3"]=Color3 .fromRGB(37,40,47);
NgotStudio["29"]["ClipsDescendants"]=true;
NgotStudio["29"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["29"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["29"]["Name"]=[[TopFrame]];
NgotStudio["2a"]=Instance.new("ImageButton",NgotStudio["29"]);
NgotStudio["2a"]["Active"]=false;
NgotStudio["2a"]["Interactable"]=false;
NgotStudio["2a"]["BorderSizePixel"]=0;
NgotStudio["2a"]["BackgroundTransparency"]=1;
NgotStudio["2a"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["2a"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["2a"]["Image"]=[[rbxassetid://113216930555884]];
NgotStudio["2a"]["Size"]=UDim2 .new(0,25,0,25);
NgotStudio["2a"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["2a"]["Name"]=[[Icon]];
NgotStudio["2a"]["Position"]=UDim2 .new(0,10,0.5,0);
NgotStudio["2b"]=Instance.new("UIAspectRatioConstraint",NgotStudio["2a"]);
NgotStudio["2c"]=Instance.new("TextLabel",NgotStudio["29"]);
NgotStudio["2c"]["TextWrapped"]=true;
NgotStudio["2c"]["Interactable"]=false;
NgotStudio["2c"]["BorderSizePixel"]=0;
NgotStudio["2c"]["TextSize"]=14;
NgotStudio["2c"]["TextScaled"]=true;
NgotStudio["2c"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["2c"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["2c"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["2c"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["2c"]["BackgroundTransparency"]=1;
NgotStudio["2c"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["2c"]["Size"]=UDim2 .new(1,-150,0,16);
NgotStudio["2c"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["2c"]["Text"]=[[NgotStudio - v1.2.3]];
NgotStudio["2c"]["Position"]=UDim2 .new(0,45,0.5,-1);
NgotStudio["2d"]=Instance.new("ImageButton",NgotStudio["29"]);
NgotStudio["2d"]["BorderSizePixel"]=0;
NgotStudio["2d"]["BackgroundTransparency"]=1;
NgotStudio["2d"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["2d"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["2d"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["2d"]["Image"]=[[rbxassetid://132453323679056]];
NgotStudio["2d"]["Size"]=UDim2 .new(0,20,0,20);
NgotStudio["2d"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["2d"]["Name"]=[[Close]];
NgotStudio["2d"]["Position"]=UDim2 .new(1,-15,0.5,0);
NgotStudio["2e"]=Instance.new("ImageButton",NgotStudio["29"]);
NgotStudio["2e"]["BorderSizePixel"]=0;
NgotStudio["2e"]["BackgroundTransparency"]=1;
NgotStudio["2e"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["2e"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["2e"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["2e"]["Image"]=[[rbxassetid://108285848026510]];
NgotStudio["2e"]["Size"]=UDim2 .new(0,15,0,15);
NgotStudio["2e"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["2e"]["Name"]=[[Maximize]];
NgotStudio["2e"]["Position"]=UDim2 .new(1,-55,0.5,0);
NgotStudio["2f"]=Instance.new("ImageButton",NgotStudio["29"]);
NgotStudio["2f"]["BorderSizePixel"]=0;
NgotStudio["2f"]["BackgroundTransparency"]=1;
NgotStudio["2f"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["2f"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["2f"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["2f"]["Image"]=[[rbxassetid://128209591224511]];
NgotStudio["2f"]["Size"]=UDim2 .new(0,20,0,20);
NgotStudio["2f"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["2f"]["Name"]=[[Hide]];
NgotStudio["2f"]["Position"]=UDim2 .new(1,-90,0.5,0);
NgotStudio["30"]=Instance.new("UICorner",NgotStudio["29"]);
NgotStudio["30"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["31"]=Instance.new("Frame",NgotStudio["29"]);
NgotStudio["31"]["ZIndex"]=2;
NgotStudio["31"]["BorderSizePixel"]=0;
NgotStudio["31"]["BackgroundColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["31"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["31"]["Size"]=UDim2 .new(1,0,0,2);
NgotStudio["31"]["Position"]=UDim2 .new(0,0,1,0);
NgotStudio["31"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["31"]["Name"]=[[Border]];
NgotStudio["32"]=Instance.new("UIStroke",NgotStudio["2"]);
NgotStudio["32"]["Transparency"]=0.5;
NgotStudio["32"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["32"]["Color"]=Color3 .fromRGB(95,95,117);
NgotStudio["33"]=Instance.new("Frame",NgotStudio["2"]);
NgotStudio["33"]["BorderSizePixel"]=0;
NgotStudio["33"]["BackgroundColor3"]=Color3 .fromRGB(32,35,41);
NgotStudio["33"]["Size"]=UDim2 .new(1,-165,1,-35);
NgotStudio["33"]["Position"]=UDim2 .new(0,165,0,35);
NgotStudio["33"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["33"]["Name"]=[[Tabs]];
NgotStudio["34"]=Instance.new("UICorner",NgotStudio["33"]);
NgotStudio["34"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["35"]=Instance.new("Frame",NgotStudio["33"]);
NgotStudio["35"]["Visible"]=false;
NgotStudio["35"]["BorderSizePixel"]=0;
NgotStudio["35"]["BackgroundColor3"]=Color3 .fromRGB(32,35,41);
NgotStudio["35"]["Size"]=UDim2 .new(0,5,1,0);
NgotStudio["35"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["35"]["Name"]=[[AntiCornerLeft]];
NgotStudio["36"]=Instance.new("Frame",NgotStudio["33"]);
NgotStudio["36"]["BorderSizePixel"]=0;
NgotStudio["36"]["BackgroundColor3"]=Color3 .fromRGB(32,35,41);
NgotStudio["36"]["Size"]=UDim2 .new(1,0,0,5);
NgotStudio["36"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["36"]["Name"]=[[AntiCornerTop]];
NgotStudio["37"]=Instance.new("TextLabel",NgotStudio["33"]);
NgotStudio["37"]["TextWrapped"]=true;
NgotStudio["37"]["Interactable"]=false;
NgotStudio["37"]["BorderSizePixel"]=0;
NgotStudio["37"]["TextSize"]=14;
NgotStudio["37"]["TextScaled"]=true;
NgotStudio["37"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["37"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["37"]["TextColor3"]=Color3 .fromRGB(135,140,150);
NgotStudio["37"]["BackgroundTransparency"]=1;
NgotStudio["37"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["37"]["Size"]=UDim2 .new(1,0,0,16);
NgotStudio["37"]["Visible"]=false;
NgotStudio["37"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["37"]["Text"]=[[This tab is empty :(]];
NgotStudio["37"]["Name"]=[[NoObjectFoundText]];
NgotStudio["37"]["Position"]=UDim2 .new(0.5,0,0.45,0);
NgotStudio["38"]=Instance.new("Frame",NgotStudio["2"]);
NgotStudio["38"]["BorderSizePixel"]=0;
NgotStudio["38"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["38"]["ClipsDescendants"]=true;
NgotStudio["38"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["38"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["38"]["Name"]=[[NotificationFrame]];
NgotStudio["38"]["BackgroundTransparency"]=1;
NgotStudio["39"]=Instance.new("Frame",NgotStudio["38"]);
NgotStudio["39"]["ZIndex"]=5;
NgotStudio["39"]["BorderSizePixel"]=0;
NgotStudio["39"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["39"]["AnchorPoint"]=Vector2 .new(0.5,0);
NgotStudio["39"]["ClipsDescendants"]=true;
NgotStudio["39"]["Size"]=UDim2 .new(0,630,1,-35);
NgotStudio["39"]["Position"]=UDim2 .new(1,0,0,35);
NgotStudio["39"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["39"]["Name"]=[[NotificationList]];
NgotStudio["39"]["BackgroundTransparency"]=1;
NgotStudio["3a"]=Instance.new("UIListLayout",NgotStudio["39"]);
NgotStudio["3a"]["Padding"]=UDim.new(0,12);
NgotStudio["3a"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["3b"]=Instance.new("UIPadding",NgotStudio["39"]);
NgotStudio["3b"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["3b"]["PaddingRight"]=UDim.new(0,40);
NgotStudio["3b"]["PaddingLeft"]=UDim.new(0,40);
NgotStudio["3c"]=Instance.new("Frame",NgotStudio["2"]);
NgotStudio["3c"]["Visible"]=false;
NgotStudio["3c"]["BorderSizePixel"]=0;
NgotStudio["3c"]["BackgroundColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["3c"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["3c"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["3c"]["Name"]=[[DarkOverlay]];
NgotStudio["3c"]["BackgroundTransparency"]=0.6;
NgotStudio["3d"]=Instance.new("UICorner",NgotStudio["3c"]);
NgotStudio["3d"]["CornerRadius"]=UDim.new(0,10);
NgotStudio["3e"]=Instance.new("ModuleScript",NgotStudio["1"]);
NgotStudio["3e"]["Name"]=[[Library]];
NgotStudio["3f"]=Instance.new("ModuleScript",NgotStudio["3e"]);
NgotStudio["3f"]["Name"]=[[IconModule]];
NgotStudio["40"]=Instance.new("ModuleScript",NgotStudio["3f"]);
NgotStudio["40"]["Name"]=[[Lucide]];
NgotStudio["41"]=Instance.new("Folder",NgotStudio["1"]);
NgotStudio["41"]["Name"]=[[Templates]];
NgotStudio["42"]=Instance.new("Frame",NgotStudio["41"]);
NgotStudio["42"]["Visible"]=false;
NgotStudio["42"]["BorderSizePixel"]=0;
NgotStudio["42"]["BackgroundColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["42"]["Size"]=UDim2 .new(1,0,0,1);
NgotStudio["42"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["42"]["Name"]=[[Divider]];
NgotStudio["43"]=Instance.new("ScrollingFrame",NgotStudio["41"]);
NgotStudio["43"]["Visible"]=false;
NgotStudio["43"]["Active"]=true;
NgotStudio["43"]["ScrollingDirection"]=Enum.ScrollingDirection.Y;
NgotStudio["43"]["BorderSizePixel"]=0;
NgotStudio["43"]["CanvasSize"]=UDim2 .new(0,0,0,0);
NgotStudio["43"]["ElasticBehavior"]=Enum.ElasticBehavior.Never;
NgotStudio["43"]["TopImage"]=[[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["43"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["43"]["Name"]=[[Tab]];
NgotStudio["43"]["Selectable"]=false;
NgotStudio["43"]["BottomImage"]=[[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["43"]["AutomaticCanvasSize"]=Enum.AutomaticSize.Y;
NgotStudio["43"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["43"]["ScrollBarImageColor3"]=Color3 .fromRGB(99,106,122);
NgotStudio["43"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["43"]["ScrollBarThickness"]=5;
NgotStudio["43"]["BackgroundTransparency"]=1;
NgotStudio["44"]=Instance.new("UIListLayout",NgotStudio["43"]);
NgotStudio["44"]["Padding"]=UDim.new(0,15);
NgotStudio["44"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["45"]=Instance.new("UIPadding",NgotStudio["43"]);
NgotStudio["45"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["45"]["PaddingRight"]=UDim.new(0,14);
NgotStudio["45"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["45"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["46"]=Instance.new("ImageButton",NgotStudio["41"]);
NgotStudio["46"]["BorderSizePixel"]=0;
NgotStudio["46"]["AutoButtonColor"]=false;
NgotStudio["46"]["Visible"]=false;
NgotStudio["46"]["BackgroundTransparency"]=1;
NgotStudio["46"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["46"]["Selectable"]=false;
NgotStudio["46"]["Size"]=UDim2 .new(1,0,0,36);
NgotStudio["46"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["46"]["Name"]=[[TabButton]];
NgotStudio["47"]=Instance.new("ImageButton",NgotStudio["46"]);
NgotStudio["47"]["BorderSizePixel"]=0;
NgotStudio["47"]["ImageTransparency"]=0.5;
NgotStudio["47"]["BackgroundTransparency"]=1;
NgotStudio["47"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["47"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["47"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["47"]["Image"]=[[rbxassetid://113216930555884]];
NgotStudio["47"]["Size"]=UDim2 .new(0,20,0,20);
NgotStudio["47"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["47"]["Position"]=UDim2 .new(0,12,0,18);
NgotStudio["48"]=Instance.new("UIAspectRatioConstraint",NgotStudio["47"]);
NgotStudio["49"]=Instance.new("TextLabel",NgotStudio["46"]);
NgotStudio["49"]["TextWrapped"]=true;
NgotStudio["49"]["BorderSizePixel"]=0;
NgotStudio["49"]["TextSize"]=14;
NgotStudio["49"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["49"]["TextTransparency"]=0.5;
NgotStudio["49"]["TextScaled"]=true;
NgotStudio["49"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["49"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["49"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["49"]["BackgroundTransparency"]=1;
NgotStudio["49"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["49"]["Size"]=UDim2 .new(0,103,0,16);
NgotStudio["49"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["49"]["Text"]=[[]];
NgotStudio["49"]["Position"]=UDim2 .new(0,42,0.5,0);
NgotStudio["4a"]=Instance.new("Frame",NgotStudio["46"]);
NgotStudio["4a"]["BorderSizePixel"]=0;
NgotStudio["4a"]["BackgroundColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["4a"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["4a"]["Size"]=UDim2 .new(0,5,0,0);
NgotStudio["4a"]["Position"]=UDim2 .new(0,8,0,18);
NgotStudio["4a"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["4a"]["Name"]=[[Bar]];
NgotStudio["4a"]["BackgroundTransparency"]=1;
NgotStudio["4b"]=Instance.new("UICorner",NgotStudio["4a"]);
NgotStudio["4b"]["CornerRadius"]=UDim.new(0,100);
NgotStudio["4c"]=Instance.new("ImageButton",NgotStudio["41"]);
NgotStudio["4c"]["BorderSizePixel"]=0;
NgotStudio["4c"]["AutoButtonColor"]=false;
NgotStudio["4c"]["Visible"]=false;
NgotStudio["4c"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["4c"]["Selectable"]=false;
NgotStudio["4c"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["4c"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["4c"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["4c"]["Name"]=[[Button]];
NgotStudio["4c"]["Position"]=UDim2 .new(0,0,0.384,0);
NgotStudio["4d"]=Instance.new("UICorner",NgotStudio["4c"]);
NgotStudio["4d"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["4e"]=Instance.new("Frame",NgotStudio["4c"]);
NgotStudio["4e"]["BorderSizePixel"]=0;
NgotStudio["4e"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["4e"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["4e"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["4e"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["4e"]["BackgroundTransparency"]=1;
NgotStudio["4f"]=Instance.new("UIListLayout",NgotStudio["4e"]);
NgotStudio["4f"]["Padding"]=UDim.new(0,5);
NgotStudio["4f"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["50"]=Instance.new("UIPadding",NgotStudio["4e"]);
NgotStudio["50"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["50"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["50"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["50"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["51"]=Instance.new("TextLabel",NgotStudio["4e"]);
NgotStudio["51"]["TextWrapped"]=true;
NgotStudio["51"]["Interactable"]=false;
NgotStudio["51"]["BorderSizePixel"]=0;
NgotStudio["51"]["TextSize"]=16;
NgotStudio["51"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["51"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["51"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["51"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["51"]["BackgroundTransparency"]=1;
NgotStudio["51"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["51"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["51"]["Text"]=[[Button]];
NgotStudio["51"]["Name"]=[[Title]];
NgotStudio["52"]=Instance.new("ImageButton",NgotStudio["51"]);
NgotStudio["52"]["BorderSizePixel"]=0;
NgotStudio["52"]["AutoButtonColor"]=false;
NgotStudio["52"]["BackgroundTransparency"]=1;
NgotStudio["52"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["52"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["52"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["52"]["Image"]=[[rbxassetid://91877599529856]];
NgotStudio["52"]["Size"]=UDim2 .new(0,23,0,23);
NgotStudio["52"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["52"]["Name"]=[[ClickIcon]];
NgotStudio["52"]["Position"]=UDim2 .new(1,0,0.5,0);
NgotStudio["53"]=Instance.new("TextLabel",NgotStudio["4e"]);
NgotStudio["53"]["TextWrapped"]=true;
NgotStudio["53"]["Interactable"]=false;
NgotStudio["53"]["BorderSizePixel"]=0;
NgotStudio["53"]["TextSize"]=16;
NgotStudio["53"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["53"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["53"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["53"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["53"]["BackgroundTransparency"]=1;
NgotStudio["53"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["53"]["Visible"]=false;
NgotStudio["53"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["53"]["Text"]=[[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["53"]["LayoutOrder"]=1;
NgotStudio["53"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["53"]["Name"]=[[Description]];
NgotStudio["54"]=Instance.new("UIGradient",NgotStudio["4e"]);
NgotStudio["54"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["55"]=Instance.new("UIGradient",NgotStudio["4e"]);
NgotStudio["55"]["Enabled"]=false;
NgotStudio["55"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["56"]=Instance.new("UIGradient",NgotStudio["4e"]);
NgotStudio["56"]["Enabled"]=false;
NgotStudio["56"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["57"]=Instance.new("UICorner",NgotStudio["4e"]);
NgotStudio["57"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["58"]=Instance.new("UIStroke",NgotStudio["4c"]);
NgotStudio["58"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["58"]["Thickness"]=1.5;
NgotStudio["58"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["59"]=Instance.new("Frame",NgotStudio["41"]);
NgotStudio["59"]["Visible"]=false;
NgotStudio["59"]["BorderSizePixel"]=0;
NgotStudio["59"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["59"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["59"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["59"]["Position"]=UDim2 .new(-0.0375,0,0.38434,0);
NgotStudio["59"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["59"]["Name"]=[[Paragraph]];
NgotStudio["5a"]=Instance.new("UICorner",NgotStudio["59"]);
NgotStudio["5a"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["5b"]=Instance.new("UIStroke",NgotStudio["59"]);
NgotStudio["5b"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["5b"]["Thickness"]=1.5;
NgotStudio["5b"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["5c"]=Instance.new("TextLabel",NgotStudio["59"]);
NgotStudio["5c"]["TextWrapped"]=true;
NgotStudio["5c"]["Interactable"]=false;
NgotStudio["5c"]["BorderSizePixel"]=0;
NgotStudio["5c"]["TextSize"]=16;
NgotStudio["5c"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["5c"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["5c"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal);
NgotStudio["5c"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["5c"]["BackgroundTransparency"]=1;
NgotStudio["5c"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["5c"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["5c"]["Text"]=[[Title]];
NgotStudio["5c"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["5c"]["Name"]=[[Title]];
NgotStudio["5d"]=Instance.new("UIPadding",NgotStudio["59"]);
NgotStudio["5d"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["5d"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["5d"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["5d"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["5e"]=Instance.new("UIListLayout",NgotStudio["59"]);
NgotStudio["5e"]["Padding"]=UDim.new(0,5);
NgotStudio["5e"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["5f"]=Instance.new("TextLabel",NgotStudio["59"]);
NgotStudio["5f"]["TextWrapped"]=true;
NgotStudio["5f"]["Interactable"]=false;
NgotStudio["5f"]["BorderSizePixel"]=0;
NgotStudio["5f"]["TextSize"]=16;
NgotStudio["5f"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["5f"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["5f"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["5f"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["5f"]["BackgroundTransparency"]=1;
NgotStudio["5f"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["5f"]["Visible"]=false;
NgotStudio["5f"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["5f"]["Text"]=[[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["5f"]["LayoutOrder"]=1;
NgotStudio["5f"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["5f"]["Name"]=[[Description]];
NgotStudio["60"]=Instance.new("ImageButton",NgotStudio["41"]);
NgotStudio["60"]["BorderSizePixel"]=0;
NgotStudio["60"]["AutoButtonColor"]=false;
NgotStudio["60"]["Visible"]=false;
NgotStudio["60"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["60"]["Selectable"]=false;
NgotStudio["60"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["60"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["60"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["60"]["Name"]=[[Toggle]];
NgotStudio["60"]["Position"]=UDim2 .new(-0.0375,0,0.38434,0);
NgotStudio["61"]=Instance.new("UICorner",NgotStudio["60"]);
NgotStudio["61"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["62"]=Instance.new("UIStroke",NgotStudio["60"]);
NgotStudio["62"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["62"]["Thickness"]=1.5;
NgotStudio["62"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["63"]=Instance.new("UIPadding",NgotStudio["60"]);
NgotStudio["63"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["63"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["63"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["63"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["64"]=Instance.new("UIListLayout",NgotStudio["60"]);
NgotStudio["64"]["Padding"]=UDim.new(0,5);
NgotStudio["64"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["65"]=Instance.new("TextLabel",NgotStudio["60"]);
NgotStudio["65"]["TextWrapped"]=true;
NgotStudio["65"]["Interactable"]=false;
NgotStudio["65"]["BorderSizePixel"]=0;
NgotStudio["65"]["TextSize"]=16;
NgotStudio["65"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["65"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["65"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["65"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["65"]["BackgroundTransparency"]=1;
NgotStudio["65"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["65"]["Visible"]=false;
NgotStudio["65"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["65"]["Text"]=[[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["65"]["LayoutOrder"]=1;
NgotStudio["65"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["65"]["Name"]=[[Description]];
NgotStudio["66"]=Instance.new("TextLabel",NgotStudio["60"]);
NgotStudio["66"]["TextWrapped"]=true;
NgotStudio["66"]["BorderSizePixel"]=0;
NgotStudio["66"]["TextSize"]=16;
NgotStudio["66"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["66"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["66"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["66"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["66"]["BackgroundTransparency"]=1;
NgotStudio["66"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["66"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["66"]["Text"]=[[Toggle]];
NgotStudio["66"]["Name"]=[[Title]];
NgotStudio["67"]=Instance.new("ImageButton",NgotStudio["66"]);
NgotStudio["67"]["BorderSizePixel"]=0;
NgotStudio["67"]["AutoButtonColor"]=false;
NgotStudio["67"]["BackgroundColor3"]=Color3 .fromRGB(54,57,63);
NgotStudio["67"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["67"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["67"]["Size"]=UDim2 .new(0,45,0,25);
NgotStudio["67"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["67"]["Name"]=[[Fill]];
NgotStudio["67"]["Position"]=UDim2 .new(1,0,0.5,0);
NgotStudio["68"]=Instance.new("UICorner",NgotStudio["67"]);
NgotStudio["68"]["CornerRadius"]=UDim.new(100,0);
NgotStudio["69"]=Instance.new("ImageButton",NgotStudio["67"]);
NgotStudio["69"]["Active"]=false;
NgotStudio["69"]["Interactable"]=false;
NgotStudio["69"]["BorderSizePixel"]=0;
NgotStudio["69"]["AutoButtonColor"]=false;
NgotStudio["69"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["69"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["69"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["69"]["Size"]=UDim2 .new(0,20,0,20);
NgotStudio["69"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["69"]["Name"]=[[Ball]];
NgotStudio["69"]["Position"]=UDim2 .new(0,0,0.5,0);
NgotStudio["6a"]=Instance.new("UICorner",NgotStudio["69"]);
NgotStudio["6a"]["CornerRadius"]=UDim.new(100,0);
NgotStudio["6b"]=Instance.new("ImageLabel",NgotStudio["69"]);
NgotStudio["6b"]["BorderSizePixel"]=0;
NgotStudio["6b"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["6b"]["ImageColor3"]=Color3 .fromRGB(54,57,63);
NgotStudio["6b"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["6b"]["Size"]=UDim2 .new(1,-5,1,-5);
NgotStudio["6b"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["6b"]["BackgroundTransparency"]=1;
NgotStudio["6b"]["Name"]=[[Icon]];
NgotStudio["6b"]["Position"]=UDim2 .new(0.5,0,0.5,0);
NgotStudio["6c"]=Instance.new("UIPadding",NgotStudio["67"]);
NgotStudio["6c"]["PaddingTop"]=UDim.new(0,2);
NgotStudio["6c"]["PaddingRight"]=UDim.new(0,2);
NgotStudio["6c"]["PaddingLeft"]=UDim.new(0,2);
NgotStudio["6c"]["PaddingBottom"]=UDim.new(0,2);
NgotStudio["6d"]=Instance.new("Frame",NgotStudio["41"]);
NgotStudio["6d"]["Visible"]=false;
NgotStudio["6d"]["BorderSizePixel"]=0;
NgotStudio["6d"]["BackgroundColor3"]=Color3 .fromRGB(37,40,47);
NgotStudio["6d"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["6d"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["6d"]["Size"]=UDim2 .new(1,0,0,65);
NgotStudio["6d"]["Position"]=UDim2 .new(0.8244,0,0.88221,0);
NgotStudio["6d"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["6d"]["Name"]=[[Notification]];
NgotStudio["6d"]["BackgroundTransparency"]=1;
NgotStudio["6e"]=Instance.new("CanvasGroup",NgotStudio["6d"]);
NgotStudio["6e"]["ZIndex"]=2;
NgotStudio["6e"]["BorderSizePixel"]=0;
NgotStudio["6e"]["BackgroundColor3"]=Color3 .fromRGB(37,40,47);
NgotStudio["6e"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["6e"]["Size"]=UDim2 .new(0,265,0,70);
NgotStudio["6e"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["6e"]["Name"]=[[Items]];
NgotStudio["6f"]=Instance.new("Frame",NgotStudio["6e"]);
NgotStudio["6f"]["BorderSizePixel"]=0;
NgotStudio["6f"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["6f"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["6f"]["Size"]=UDim2 .new(0,265,0,70);
NgotStudio["6f"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["6f"]["BackgroundTransparency"]=1;
NgotStudio["70"]=Instance.new("UIListLayout",NgotStudio["6f"]);
NgotStudio["70"]["Padding"]=UDim.new(0,5);
NgotStudio["70"]["VerticalAlignment"]=Enum.VerticalAlignment.Center;
NgotStudio["70"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["71"]=Instance.new("UIPadding",NgotStudio["6f"]);
NgotStudio["71"]["PaddingTop"]=UDim.new(0,15);
NgotStudio["71"]["PaddingLeft"]=UDim.new(0,15);
NgotStudio["71"]["PaddingBottom"]=UDim.new(0,15);
NgotStudio["72"]=Instance.new("TextLabel",NgotStudio["6f"]);
NgotStudio["72"]["TextWrapped"]=true;
NgotStudio["72"]["BorderSizePixel"]=0;
NgotStudio["72"]["TextSize"]=12;
NgotStudio["72"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["72"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["72"]["FontFace"]=Font.new([[rbxasset://fonts/families/GothamSSm.json]],Enum.FontWeight.Regular,Enum.FontStyle.Normal);
NgotStudio["72"]["TextColor3"]=Color3 .fromRGB(181,181,181);
NgotStudio["72"]["BackgroundTransparency"]=1;
NgotStudio["72"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["72"]["Size"]=UDim2 .new(0,218,0,10);
NgotStudio["72"]["Visible"]=false;
NgotStudio["72"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["72"]["Text"]=[[This is a notification]];
NgotStudio["72"]["LayoutOrder"]=1;
NgotStudio["72"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["72"]["Name"]=[[SubContent]];
NgotStudio["72"]["Position"]=UDim2 .new(0,0,0,19);
NgotStudio["73"]=Instance.new("UIGradient",NgotStudio["72"]);
NgotStudio["73"]["Enabled"]=false;
NgotStudio["73"]["Rotation"]=-90;
NgotStudio["73"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(3,100,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,255,226))};
NgotStudio["74"]=Instance.new("TextLabel",NgotStudio["6f"]);
NgotStudio["74"]["TextWrapped"]=true;
NgotStudio["74"]["BorderSizePixel"]=0;
NgotStudio["74"]["TextSize"]=16;
NgotStudio["74"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["74"]["TextScaled"]=true;
NgotStudio["74"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["74"]["FontFace"]=Font.new([[rbxasset://fonts/families/GothamSSm.json]],Enum.FontWeight.Bold,Enum.FontStyle.Normal);
NgotStudio["74"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["74"]["BackgroundTransparency"]=1;
NgotStudio["74"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["74"]["Size"]=UDim2 .new(0,235,0,18);
NgotStudio["74"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["74"]["Text"]=[[Title]];
NgotStudio["74"]["Name"]=[[Title]];
NgotStudio["74"]["Position"]=UDim2 .new(0,0,0,9);
NgotStudio["75"]=Instance.new("ImageButton",NgotStudio["74"]);
NgotStudio["75"]["BorderSizePixel"]=0;
NgotStudio["75"]["BackgroundTransparency"]=1;
NgotStudio["75"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["75"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["75"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["75"]["Image"]=[[rbxassetid://132453323679056]];
NgotStudio["75"]["Size"]=UDim2 .new(0.09706,0,1.33333,0);
NgotStudio["75"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["75"]["Name"]=[[Close]];
NgotStudio["75"]["Position"]=UDim2 .new(0.92,0,0.5,0);
NgotStudio["76"]=Instance.new("UIAspectRatioConstraint",NgotStudio["75"]);
NgotStudio["77"]=Instance.new("UIPadding",NgotStudio["74"]);
NgotStudio["77"]["PaddingLeft"]=UDim.new(0,30);
NgotStudio["78"]=Instance.new("ImageButton",NgotStudio["74"]);
NgotStudio["78"]["BorderSizePixel"]=0;
NgotStudio["78"]["BackgroundTransparency"]=1;
NgotStudio["78"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["78"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["78"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["78"]["Image"]=[[rbxassetid://92049322344253]];
NgotStudio["78"]["Size"]=UDim2 .new(0.09706,0,1.33333,0);
NgotStudio["78"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["78"]["Name"]=[[Icon]];
NgotStudio["78"]["Position"]=UDim2 .new(0,-30,0.5,0);
NgotStudio["79"]=Instance.new("UIAspectRatioConstraint",NgotStudio["78"]);
NgotStudio["7a"]=Instance.new("TextLabel",NgotStudio["6f"]);
NgotStudio["7a"]["TextWrapped"]=true;
NgotStudio["7a"]["BorderSizePixel"]=0;
NgotStudio["7a"]["TextSize"]=16;
NgotStudio["7a"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["7a"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["7a"]["FontFace"]=Font.new([[rbxasset://fonts/families/GothamSSm.json]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["7a"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["7a"]["BackgroundTransparency"]=1;
NgotStudio["7a"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["7a"]["Size"]=UDim2 .new(0,218,0,10);
NgotStudio["7a"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["7a"]["Text"]=[[Content]];
NgotStudio["7a"]["LayoutOrder"]=2;
NgotStudio["7a"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["7a"]["Name"]=[[Content]];
NgotStudio["7a"]["Position"]=UDim2 .new(0,0,0,19);
NgotStudio["7b"]=Instance.new("UIGradient",NgotStudio["7a"]);
NgotStudio["7b"]["Enabled"]=false;
NgotStudio["7b"]["Rotation"]=-90;
NgotStudio["7b"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(3,100,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,255,226))};
NgotStudio["7c"]=Instance.new("Frame",NgotStudio["6e"]);
NgotStudio["7c"]["BorderSizePixel"]=0;
NgotStudio["7c"]["BackgroundColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["7c"]["AnchorPoint"]=Vector2 .new(0,1);
NgotStudio["7c"]["Size"]=UDim2 .new(1,0,0,5);
NgotStudio["7c"]["Position"]=UDim2 .new(0,0,1,0);
NgotStudio["7c"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["7c"]["Name"]=[[TimerBarFill]];
NgotStudio["7c"]["BackgroundTransparency"]=0.7;
NgotStudio["7d"]=Instance.new("UICorner",NgotStudio["7c"]);
NgotStudio["7e"]=Instance.new("Frame",NgotStudio["7c"]);
NgotStudio["7e"]["BorderSizePixel"]=0;
NgotStudio["7e"]["BackgroundColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["7e"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["7e"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["7e"]["Name"]=[[Bar]];
NgotStudio["7f"]=Instance.new("UICorner",NgotStudio["7e"]);
NgotStudio["80"]=Instance.new("UIStroke",NgotStudio["6e"]);
NgotStudio["80"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["80"]["Thickness"]=1.5;
NgotStudio["80"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["81"]=Instance.new("UICorner",NgotStudio["6e"]);
NgotStudio["82"]=Instance.new("Frame",NgotStudio["41"]);
NgotStudio["82"]["Visible"]=false;
NgotStudio["82"]["BorderSizePixel"]=0;
NgotStudio["82"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["82"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["82"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["82"]["Position"]=UDim2 .new(-0.0375,0,0.38434,0);
NgotStudio["82"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["82"]["Name"]=[[Slider]];
NgotStudio["83"]=Instance.new("UICorner",NgotStudio["82"]);
NgotStudio["83"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["84"]=Instance.new("UIStroke",NgotStudio["82"]);
NgotStudio["84"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["84"]["Thickness"]=1.5;
NgotStudio["84"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["85"]=Instance.new("TextLabel",NgotStudio["82"]);
NgotStudio["85"]["TextWrapped"]=true;
NgotStudio["85"]["Interactable"]=false;
NgotStudio["85"]["BorderSizePixel"]=0;
NgotStudio["85"]["TextSize"]=16;
NgotStudio["85"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["85"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["85"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal);
NgotStudio["85"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["85"]["BackgroundTransparency"]=1;
NgotStudio["85"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["85"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["85"]["Text"]=[[Slider]];
NgotStudio["85"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["85"]["Name"]=[[Title]];
NgotStudio["86"]=Instance.new("UIPadding",NgotStudio["82"]);
NgotStudio["86"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["86"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["86"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["86"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["87"]=Instance.new("UIListLayout",NgotStudio["82"]);
NgotStudio["87"]["Padding"]=UDim.new(0,5);
NgotStudio["87"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["88"]=Instance.new("TextLabel",NgotStudio["82"]);
NgotStudio["88"]["TextWrapped"]=true;
NgotStudio["88"]["Interactable"]=false;
NgotStudio["88"]["BorderSizePixel"]=0;
NgotStudio["88"]["TextSize"]=16;
NgotStudio["88"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["88"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["88"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["88"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["88"]["BackgroundTransparency"]=1;
NgotStudio["88"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["88"]["Visible"]=false;
NgotStudio["88"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["88"]["Text"]=[[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["88"]["LayoutOrder"]=1;
NgotStudio["88"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["88"]["Name"]=[[Description]];
NgotStudio["89"]=Instance.new("Frame",NgotStudio["82"]);
NgotStudio["89"]["ZIndex"]=0;
NgotStudio["89"]["BorderSizePixel"]=0;
NgotStudio["89"]["Size"]=UDim2 .new(1,0,0,25);
NgotStudio["89"]["Name"]=[[SliderFrame]];
NgotStudio["89"]["LayoutOrder"]=2;
NgotStudio["89"]["BackgroundTransparency"]=1;
NgotStudio["8a"]=Instance.new("Frame",NgotStudio["89"]);
NgotStudio["8a"]["ZIndex"]=0;
NgotStudio["8a"]["BorderSizePixel"]=0;
NgotStudio["8a"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["8a"]["Size"]=UDim2 .new(1,0,0,20);
NgotStudio["8a"]["Position"]=UDim2 .new(0,0,0.5,0);
NgotStudio["8a"]["BackgroundTransparency"]=1;
NgotStudio["8b"]=Instance.new("ImageLabel",NgotStudio["8a"]);
NgotStudio["8b"]["ZIndex"]=0;
NgotStudio["8b"]["BorderSizePixel"]=0;
NgotStudio["8b"]["SliceCenter"]=Rect.new(49,49,450,450);
NgotStudio["8b"]["ScaleType"]=Enum.ScaleType.Slice;
NgotStudio["8b"]["ImageTransparency"]=0.75;
NgotStudio["8b"]["ImageColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["8b"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["8b"]["Image"]=[[rbxassetid://6014261993]];
NgotStudio["8b"]["Size"]=UDim2 .new(1,25,1,25);
NgotStudio["8b"]["BackgroundTransparency"]=1;
NgotStudio["8b"]["Name"]=[[DropShadow]];
NgotStudio["8b"]["Position"]=UDim2 .new(0.5,0,0.5,0);
NgotStudio["8c"]=Instance.new("CanvasGroup",NgotStudio["8a"]);
NgotStudio["8c"]["BorderSizePixel"]=0;
NgotStudio["8c"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["8c"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["8c"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["8c"]["Name"]=[[Slider]];
NgotStudio["8d"]=Instance.new("UICorner",NgotStudio["8c"]);
NgotStudio["8d"]["CornerRadius"]=UDim.new(0,5);
NgotStudio["8e"]=Instance.new("UIStroke",NgotStudio["8c"]);
NgotStudio["8e"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["8e"]["Thickness"]=1.5;
NgotStudio["8e"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["8f"]=Instance.new("UIPadding",NgotStudio["8c"]);
NgotStudio["8f"]["PaddingTop"]=UDim.new(0,2);
NgotStudio["8f"]["PaddingRight"]=UDim.new(0,2);
NgotStudio["8f"]["PaddingLeft"]=UDim.new(0,2);
NgotStudio["8f"]["PaddingBottom"]=UDim.new(0,2);
NgotStudio["90"]=Instance.new("TextButton",NgotStudio["8c"]);
NgotStudio["90"]["BorderSizePixel"]=0;
NgotStudio["90"]["TextSize"]=14;
NgotStudio["90"]["AutoButtonColor"]=false;
NgotStudio["90"]["TextColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["90"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["90"]["FontFace"]=Font.new([[rbxasset://fonts/families/SourceSansPro.json]],Enum.FontWeight.Regular,Enum.FontStyle.Normal);
NgotStudio["90"]["BackgroundTransparency"]=1;
NgotStudio["90"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["90"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["90"]["Text"]=[[]];
NgotStudio["90"]["Name"]=[[Trigger]];
NgotStudio["91"]=Instance.new("ImageButton",NgotStudio["8c"]);
NgotStudio["91"]["Active"]=false;
NgotStudio["91"]["Interactable"]=false;
NgotStudio["91"]["BorderSizePixel"]=0;
NgotStudio["91"]["AutoButtonColor"]=false;
NgotStudio["91"]["BackgroundTransparency"]=1;
NgotStudio["91"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["91"]["Selectable"]=false;
NgotStudio["91"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["91"]["Size"]=UDim2 .new(0,0,1,0);
NgotStudio["91"]["ClipsDescendants"]=true;
NgotStudio["91"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["91"]["Name"]=[[Fill]];
NgotStudio["91"]["Position"]=UDim2 .new(0,0,0.5,0);
NgotStudio["92"]=Instance.new("UICorner",NgotStudio["91"]);
NgotStudio["92"]["CornerRadius"]=UDim.new(0,4);
NgotStudio["93"]=Instance.new("UIStroke",NgotStudio["91"]);
NgotStudio["93"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["93"]["Thickness"]=1.5;
NgotStudio["93"]["Color"]=Color3 .fromRGB(11,136,214);
NgotStudio["94"]=Instance.new("ImageButton",NgotStudio["91"]);
NgotStudio["94"]["Active"]=false;
NgotStudio["94"]["Interactable"]=false;
NgotStudio["94"]["BorderSizePixel"]=0;
NgotStudio["94"]["AutoButtonColor"]=false;
NgotStudio["94"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["94"]["Selectable"]=false;
NgotStudio["94"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["94"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["94"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["94"]["Name"]=[[BackgroundGradient]];
NgotStudio["94"]["Position"]=UDim2 .new(0,0,0.5,0);
NgotStudio["95"]=Instance.new("UICorner",NgotStudio["94"]);
NgotStudio["95"]["CornerRadius"]=UDim.new(0,4);
NgotStudio["96"]=Instance.new("UIGradient",NgotStudio["94"]);
NgotStudio["96"]["Enabled"]=false;
NgotStudio["96"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["97"]=Instance.new("UIGradient",NgotStudio["94"]);
NgotStudio["97"]["Enabled"]=false;
NgotStudio["97"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["98"]=Instance.new("UIGradient",NgotStudio["94"]);
NgotStudio["98"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["99"]=Instance.new("TextLabel",NgotStudio["8a"]);
NgotStudio["99"]["TextWrapped"]=true;
NgotStudio["99"]["Interactable"]=false;
NgotStudio["99"]["ZIndex"]=2;
NgotStudio["99"]["BorderSizePixel"]=0;
NgotStudio["99"]["TextSize"]=14;
NgotStudio["99"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["99"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["99"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal);
NgotStudio["99"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["99"]["BackgroundTransparency"]=1;
NgotStudio["99"]["RichText"]=true;
NgotStudio["99"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["99"]["Size"]=UDim2 .new(1,-15,1,0);
NgotStudio["99"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["99"]["Text"]=[[0]];
NgotStudio["99"]["Name"]=[[ValueText]];
NgotStudio["99"]["Position"]=UDim2 .new(0.5,0,0.5,0);
NgotStudio["9a"]=Instance.new("Frame",NgotStudio["41"]);
NgotStudio["9a"]["Visible"]=false;
NgotStudio["9a"]["BorderSizePixel"]=0;
NgotStudio["9a"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["9a"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["9a"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["9a"]["Position"]=UDim2 .new(-0.0375,0,0.38434,0);
NgotStudio["9a"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["9a"]["Name"]=[[TextBox]];
NgotStudio["9b"]=Instance.new("UICorner",NgotStudio["9a"]);
NgotStudio["9b"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["9c"]=Instance.new("UIStroke",NgotStudio["9a"]);
NgotStudio["9c"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["9c"]["Thickness"]=1.5;
NgotStudio["9c"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["9d"]=Instance.new("TextLabel",NgotStudio["9a"]);
NgotStudio["9d"]["TextWrapped"]=true;
NgotStudio["9d"]["Interactable"]=false;
NgotStudio["9d"]["BorderSizePixel"]=0;
NgotStudio["9d"]["TextSize"]=16;
NgotStudio["9d"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["9d"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["9d"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal);
NgotStudio["9d"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["9d"]["BackgroundTransparency"]=1;
NgotStudio["9d"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["9d"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["9d"]["Text"]=[[Input Textbox]];
NgotStudio["9d"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["9d"]["Name"]=[[Title]];
NgotStudio["9e"]=Instance.new("UIPadding",NgotStudio["9a"]);
NgotStudio["9e"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["9e"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["9e"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["9e"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["9f"]=Instance.new("UIListLayout",NgotStudio["9a"]);
NgotStudio["9f"]["Padding"]=UDim.new(0,10);
NgotStudio["9f"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["a0"]=Instance.new("TextLabel",NgotStudio["9a"]);
NgotStudio["a0"]["TextWrapped"]=true;
NgotStudio["a0"]["Interactable"]=false;
NgotStudio["a0"]["BorderSizePixel"]=0;
NgotStudio["a0"]["TextSize"]=16;
NgotStudio["a0"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["a0"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["a0"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["a0"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["a0"]["BackgroundTransparency"]=1;
NgotStudio["a0"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["a0"]["Visible"]=false;
NgotStudio["a0"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["a0"]["Text"]=[[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["a0"]["LayoutOrder"]=1;
NgotStudio["a0"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["a0"]["Name"]=[[Description]];
NgotStudio["a1"]=Instance.new("Frame",NgotStudio["9a"]);
NgotStudio["a1"]["ZIndex"]=0;
NgotStudio["a1"]["BorderSizePixel"]=0;
NgotStudio["a1"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["a1"]["Size"]=UDim2 .new(1,0,0,25);
NgotStudio["a1"]["Name"]=[[BoxFrame]];
NgotStudio["a1"]["LayoutOrder"]=2;
NgotStudio["a1"]["BackgroundTransparency"]=1;
NgotStudio["a2"]=Instance.new("ImageLabel",NgotStudio["a1"]);
NgotStudio["a2"]["ZIndex"]=0;
NgotStudio["a2"]["BorderSizePixel"]=0;
NgotStudio["a2"]["SliceCenter"]=Rect.new(49,49,450,450);
NgotStudio["a2"]["ScaleType"]=Enum.ScaleType.Slice;
NgotStudio["a2"]["ImageTransparency"]=0.75;
NgotStudio["a2"]["ImageColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["a2"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["a2"]["Image"]=[[rbxassetid://6014261993]];
NgotStudio["a2"]["Size"]=UDim2 .new(1,35,1,30);
NgotStudio["a2"]["BackgroundTransparency"]=1;
NgotStudio["a2"]["Name"]=[[DropShadow]];
NgotStudio["a2"]["Position"]=UDim2 .new(0.5,0,0.5,0);
NgotStudio["a3"]=Instance.new("Frame",NgotStudio["a1"]);
NgotStudio["a3"]["BorderSizePixel"]=0;
NgotStudio["a3"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["a3"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["a3"]["Size"]=UDim2 .new(1,0,0,25);
NgotStudio["a3"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["a4"]=Instance.new("UICorner",NgotStudio["a3"]);
NgotStudio["a4"]["CornerRadius"]=UDim.new(0,5);
NgotStudio["a5"]=Instance.new("UIStroke",NgotStudio["a3"]);
NgotStudio["a5"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["a5"]["Thickness"]=1.5;
NgotStudio["a5"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["a6"]=Instance.new("UIListLayout",NgotStudio["a3"]);
NgotStudio["a6"]["HorizontalAlignment"]=Enum.HorizontalAlignment.Center;
NgotStudio["a6"]["Padding"]=UDim.new(0,5);
NgotStudio["a6"]["VerticalAlignment"]=Enum.VerticalAlignment.Center;
NgotStudio["a6"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["a7"]=Instance.new("TextBox",NgotStudio["a3"]);
NgotStudio["a7"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["a7"]["PlaceholderColor3"]=Color3 .fromRGB(140,140,140);
NgotStudio["a7"]["BorderSizePixel"]=0;
NgotStudio["a7"]["TextWrapped"]=true;
NgotStudio["a7"]["TextTruncate"]=Enum.TextTruncate.AtEnd;
NgotStudio["a7"]["TextSize"]=14;
NgotStudio["a7"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["a7"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["a7"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["a7"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["a7"]["ClipsDescendants"]=true;
NgotStudio["a7"]["PlaceholderText"]=[[Input here...]];
NgotStudio["a7"]["Size"]=UDim2 .new(1,0,0,25);
NgotStudio["a7"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["a7"]["Text"]=[[]];
NgotStudio["a7"]["BackgroundTransparency"]=1;
NgotStudio["a8"]=Instance.new("UIPadding",NgotStudio["a7"]);
NgotStudio["a8"]["PaddingTop"]=UDim.new(0,5);
NgotStudio["a8"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["a8"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["a8"]["PaddingBottom"]=UDim.new(0,5);
NgotStudio["a9"]=Instance.new("ImageButton",NgotStudio["41"]);
NgotStudio["a9"]["BorderSizePixel"]=0;
NgotStudio["a9"]["AutoButtonColor"]=false;
NgotStudio["a9"]["Visible"]=false;
NgotStudio["a9"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["a9"]["Selectable"]=false;
NgotStudio["a9"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["a9"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["a9"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["a9"]["Name"]=[[Dropdown]];
NgotStudio["a9"]["Position"]=UDim2 .new(-0.0375,0,0.38434,0);
NgotStudio["aa"]=Instance.new("UICorner",NgotStudio["a9"]);
NgotStudio["aa"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["ab"]=Instance.new("UIStroke",NgotStudio["a9"]);
NgotStudio["ab"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["ab"]["Thickness"]=1.5;
NgotStudio["ab"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["ac"]=Instance.new("TextLabel",NgotStudio["a9"]);
NgotStudio["ac"]["TextWrapped"]=true;
NgotStudio["ac"]["BorderSizePixel"]=0;
NgotStudio["ac"]["TextSize"]=16;
NgotStudio["ac"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["ac"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["ac"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["ac"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["ac"]["BackgroundTransparency"]=1;
NgotStudio["ac"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["ac"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["ac"]["Text"]=[[Dropdown]];
NgotStudio["ac"]["Name"]=[[Title]];
NgotStudio["ac"]["Position"]=UDim2 .new(0.03135,0,0,0);
NgotStudio["ad"]=Instance.new("ImageButton",NgotStudio["ac"]);
NgotStudio["ad"]["BorderSizePixel"]=0;
NgotStudio["ad"]["AutoButtonColor"]=false;
NgotStudio["ad"]["BackgroundTransparency"]=1;
NgotStudio["ad"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["ad"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["ad"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["ad"]["Image"]=[[rbxassetid://77563793724007]];
NgotStudio["ad"]["Size"]=UDim2 .new(0,23,0,23);
NgotStudio["ad"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["ad"]["Name"]=[[ClickIcon]];
NgotStudio["ad"]["Position"]=UDim2 .new(1,0,0.5,0);
NgotStudio["ae"]=Instance.new("ImageButton",NgotStudio["ac"]);
NgotStudio["ae"]["Active"]=false;
NgotStudio["ae"]["BorderSizePixel"]=0;
NgotStudio["ae"]["BackgroundTransparency"]=1;
NgotStudio["ae"]["Selectable"]=false;
NgotStudio["ae"]["ZIndex"]=0;
NgotStudio["ae"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["ae"]["AutomaticSize"]=Enum.AutomaticSize.X;
NgotStudio["ae"]["Size"]=UDim2 .new(0,20,0,20);
NgotStudio["ae"]["Name"]=[[BoxFrame]];
NgotStudio["ae"]["Position"]=UDim2 .new(1,-33,0.5,0);
NgotStudio["af"]=Instance.new("ImageLabel",NgotStudio["ae"]);
NgotStudio["af"]["Interactable"]=false;
NgotStudio["af"]["ZIndex"]=0;
NgotStudio["af"]["BorderSizePixel"]=0;
NgotStudio["af"]["SliceCenter"]=Rect.new(49,49,450,450);
NgotStudio["af"]["ScaleType"]=Enum.ScaleType.Slice;
NgotStudio["af"]["ImageTransparency"]=0.75;
NgotStudio["af"]["AutomaticSize"]=Enum.AutomaticSize.X;
NgotStudio["af"]["ImageColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["af"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["af"]["Image"]=[[rbxassetid://6014261993]];
NgotStudio["af"]["Size"]=UDim2 .new(1,28,1,28);
NgotStudio["af"]["Visible"]=false;
NgotStudio["af"]["BackgroundTransparency"]=1;
NgotStudio["af"]["Name"]=[[DropShadow]];
NgotStudio["af"]["Position"]=UDim2 .new(0.5,0,0.5,0);
NgotStudio["b0"]=Instance.new("ImageButton",NgotStudio["ae"]);
NgotStudio["b0"]["BorderSizePixel"]=0;
NgotStudio["b0"]["AutoButtonColor"]=false;
NgotStudio["b0"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["b0"]["Selectable"]=false;
NgotStudio["b0"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["b0"]["AutomaticSize"]=Enum.AutomaticSize.X;
NgotStudio["b0"]["Size"]=UDim2 .new(0,20,0,20);
NgotStudio["b0"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["b0"]["Name"]=[[Trigger]];
NgotStudio["b0"]["Position"]=UDim2 .new(0.5,0,0.5,0);
NgotStudio["b1"]=Instance.new("UICorner",NgotStudio["b0"]);
NgotStudio["b1"]["CornerRadius"]=UDim.new(0,5);
NgotStudio["b2"]=Instance.new("UIStroke",NgotStudio["b0"]);
NgotStudio["b2"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["b2"]["Thickness"]=1.5;
NgotStudio["b2"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["b3"]=Instance.new("UIListLayout",NgotStudio["b0"]);
NgotStudio["b3"]["Padding"]=UDim.new(0,5);
NgotStudio["b3"]["VerticalAlignment"]=Enum.VerticalAlignment.Center;
NgotStudio["b3"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["b4"]=Instance.new("TextLabel",NgotStudio["b0"]);
NgotStudio["b4"]["TextWrapped"]=true;
NgotStudio["b4"]["Interactable"]=false;
NgotStudio["b4"]["BorderSizePixel"]=0;
NgotStudio["b4"]["TextSize"]=16;
NgotStudio["b4"]["TextScaled"]=true;
NgotStudio["b4"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["b4"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["b4"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["b4"]["BackgroundTransparency"]=1;
NgotStudio["b4"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["b4"]["Size"]=UDim2 .new(0,15,0,14);
NgotStudio["b4"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["b4"]["Text"]=[[]];
NgotStudio["b4"]["AutomaticSize"]=Enum.AutomaticSize.X;
NgotStudio["b4"]["Name"]=[[Title]];
NgotStudio["b4"]["Position"]=UDim2 .new(-0.00345,0,0.5,0);
NgotStudio["b5"]=Instance.new("UIPadding",NgotStudio["b0"]);
NgotStudio["b5"]["PaddingRight"]=UDim.new(0,5);
NgotStudio["b5"]["PaddingLeft"]=UDim.new(0,5);
NgotStudio["b6"]=Instance.new("UIPadding",NgotStudio["a9"]);
NgotStudio["b6"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["b6"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["b6"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["b6"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["b7"]=Instance.new("UIListLayout",NgotStudio["a9"]);
NgotStudio["b7"]["Padding"]=UDim.new(0,5);
NgotStudio["b7"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["b8"]=Instance.new("TextLabel",NgotStudio["a9"]);
NgotStudio["b8"]["TextWrapped"]=true;
NgotStudio["b8"]["Interactable"]=false;
NgotStudio["b8"]["BorderSizePixel"]=0;
NgotStudio["b8"]["TextSize"]=16;
NgotStudio["b8"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["b8"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["b8"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["b8"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["b8"]["BackgroundTransparency"]=1;
NgotStudio["b8"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["b8"]["Visible"]=false;
NgotStudio["b8"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["b8"]["Text"]=[[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["b8"]["LayoutOrder"]=1;
NgotStudio["b8"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["b8"]["Name"]=[[Description]];
NgotStudio["b9"]=Instance.new("UIGradient",NgotStudio["a9"]);
NgotStudio["b9"]["Enabled"]=false;
NgotStudio["b9"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["ba"]=Instance.new("UIGradient",NgotStudio["a9"]);
NgotStudio["ba"]["Enabled"]=false;
NgotStudio["ba"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["bb"]=Instance.new("UIGradient",NgotStudio["a9"]);
NgotStudio["bb"]["Enabled"]=false;
NgotStudio["bb"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["bc"]=Instance.new("Folder",NgotStudio["41"]);
NgotStudio["bc"]["Name"]=[[DropdownList]];
NgotStudio["bd"]=Instance.new("ScrollingFrame",NgotStudio["bc"]);
NgotStudio["bd"]["Visible"]=false;
NgotStudio["bd"]["Active"]=true;
NgotStudio["bd"]["ScrollingDirection"]=Enum.ScrollingDirection.Y;
NgotStudio["bd"]["BorderSizePixel"]=0;
NgotStudio["bd"]["CanvasSize"]=UDim2 .new(0,0,0,0);
NgotStudio["bd"]["ElasticBehavior"]=Enum.ElasticBehavior.Never;
NgotStudio["bd"]["TopImage"]=[[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["bd"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["bd"]["Name"]=[[DropdownItems]];
NgotStudio["bd"]["Selectable"]=false;
NgotStudio["bd"]["BottomImage"]=[[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["bd"]["AutomaticCanvasSize"]=Enum.AutomaticSize.Y;
NgotStudio["bd"]["Size"]=UDim2 .new(1,0,1,-50);
NgotStudio["bd"]["ScrollBarImageColor3"]=Color3 .fromRGB(99,106,122);
NgotStudio["bd"]["Position"]=UDim2 .new(0,0,0,50);
NgotStudio["bd"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["bd"]["ScrollBarThickness"]=5;
NgotStudio["bd"]["BackgroundTransparency"]=1;
NgotStudio["be"]=Instance.new("UIListLayout",NgotStudio["bd"]);
NgotStudio["be"]["Padding"]=UDim.new(0,15);
NgotStudio["be"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["bf"]=Instance.new("UIPadding",NgotStudio["bd"]);
NgotStudio["bf"]["PaddingTop"]=UDim.new(0,2);
NgotStudio["bf"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["bf"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["bf"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["c0"]=Instance.new("ScrollingFrame",NgotStudio["bc"]);
NgotStudio["c0"]["Visible"]=false;
NgotStudio["c0"]["Active"]=true;
NgotStudio["c0"]["ScrollingDirection"]=Enum.ScrollingDirection.Y;
NgotStudio["c0"]["BorderSizePixel"]=0;
NgotStudio["c0"]["CanvasSize"]=UDim2 .new(0,0,0,0);
NgotStudio["c0"]["ElasticBehavior"]=Enum.ElasticBehavior.Never;
NgotStudio["c0"]["TopImage"]=[[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["c0"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["c0"]["Name"]=[[DropdownItemsSearch]];
NgotStudio["c0"]["Selectable"]=false;
NgotStudio["c0"]["BottomImage"]=[[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["c0"]["AutomaticCanvasSize"]=Enum.AutomaticSize.Y;
NgotStudio["c0"]["Size"]=UDim2 .new(1,0,1,-50);
NgotStudio["c0"]["ScrollBarImageColor3"]=Color3 .fromRGB(99,106,122);
NgotStudio["c0"]["Position"]=UDim2 .new(0,0,0,50);
NgotStudio["c0"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["c0"]["ScrollBarThickness"]=5;
NgotStudio["c0"]["BackgroundTransparency"]=1;
NgotStudio["c1"]=Instance.new("UIListLayout",NgotStudio["c0"]);
NgotStudio["c1"]["Padding"]=UDim.new(0,15);
NgotStudio["c1"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["c2"]=Instance.new("UIPadding",NgotStudio["c0"]);
NgotStudio["c2"]["PaddingTop"]=UDim.new(0,2);
NgotStudio["c2"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["c2"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["c2"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["c3"]=Instance.new("ImageButton",NgotStudio["41"]);
NgotStudio["c3"]["BorderSizePixel"]=0;
NgotStudio["c3"]["AutoButtonColor"]=false;
NgotStudio["c3"]["Visible"]=false;
NgotStudio["c3"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["c3"]["Selectable"]=false;
NgotStudio["c3"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["c3"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["c3"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["c3"]["Name"]=[[DropdownButton]];
NgotStudio["c3"]["Position"]=UDim2 .new(0,0,0.384,0);
NgotStudio["c4"]=Instance.new("UICorner",NgotStudio["c3"]);
NgotStudio["c4"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["c5"]=Instance.new("Frame",NgotStudio["c3"]);
NgotStudio["c5"]["BorderSizePixel"]=0;
NgotStudio["c5"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["c5"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["c5"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["c5"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["c5"]["BackgroundTransparency"]=1;
NgotStudio["c6"]=Instance.new("UIListLayout",NgotStudio["c5"]);
NgotStudio["c6"]["Padding"]=UDim.new(0,5);
NgotStudio["c6"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["c7"]=Instance.new("UIPadding",NgotStudio["c5"]);
NgotStudio["c7"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["c7"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["c7"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["c7"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["c8"]=Instance.new("TextLabel",NgotStudio["c5"]);
NgotStudio["c8"]["TextWrapped"]=true;
NgotStudio["c8"]["Interactable"]=false;
NgotStudio["c8"]["BorderSizePixel"]=0;
NgotStudio["c8"]["TextSize"]=16;
NgotStudio["c8"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["c8"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["c8"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["c8"]["BackgroundTransparency"]=1;
NgotStudio["c8"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["c8"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["c8"]["Text"]=[[Button]];
NgotStudio["c8"]["Name"]=[[Title]];
NgotStudio["c9"]=Instance.new("TextLabel",NgotStudio["c5"]);
NgotStudio["c9"]["TextWrapped"]=true;
NgotStudio["c9"]["Interactable"]=false;
NgotStudio["c9"]["BorderSizePixel"]=0;
NgotStudio["c9"]["TextSize"]=16;
NgotStudio["c9"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["c9"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["c9"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["c9"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["c9"]["BackgroundTransparency"]=1;
NgotStudio["c9"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["c9"]["Visible"]=false;
NgotStudio["c9"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["c9"]["Text"]=[[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["c9"]["LayoutOrder"]=1;
NgotStudio["c9"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["c9"]["Name"]=[[Description]];
NgotStudio["ca"]=Instance.new("UIGradient",NgotStudio["c5"]);
NgotStudio["ca"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["cb"]=Instance.new("UIGradient",NgotStudio["c5"]);
NgotStudio["cb"]["Enabled"]=false;
NgotStudio["cb"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["cc"]=Instance.new("UIGradient",NgotStudio["c5"]);
NgotStudio["cc"]["Enabled"]=false;
NgotStudio["cc"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["cd"]=Instance.new("UICorner",NgotStudio["c5"]);
NgotStudio["cd"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["ce"]=Instance.new("UIStroke",NgotStudio["c3"]);
NgotStudio["ce"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["ce"]["Thickness"]=1.5;
NgotStudio["ce"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["cf"]=Instance.new("Frame",NgotStudio["41"]);
NgotStudio["cf"]["Visible"]=false;
NgotStudio["cf"]["BorderSizePixel"]=0;
NgotStudio["cf"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["cf"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["cf"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["cf"]["Position"]=UDim2 .new(-0.0375,0,0.38434,0);
NgotStudio["cf"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["cf"]["Name"]=[[Code]];
NgotStudio["d0"]=Instance.new("UICorner",NgotStudio["cf"]);
NgotStudio["d0"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["d1"]=Instance.new("UIStroke",NgotStudio["cf"]);
NgotStudio["d1"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["d1"]["Thickness"]=1.5;
NgotStudio["d1"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["d2"]=Instance.new("TextLabel",NgotStudio["cf"]);
NgotStudio["d2"]["TextWrapped"]=true;
NgotStudio["d2"]["Interactable"]=false;
NgotStudio["d2"]["BorderSizePixel"]=0;
NgotStudio["d2"]["TextSize"]=16;
NgotStudio["d2"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["d2"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["d2"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal);
NgotStudio["d2"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["d2"]["BackgroundTransparency"]=1;
NgotStudio["d2"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["d2"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["d2"]["Text"]=[[Title]];
NgotStudio["d2"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["d2"]["Name"]=[[Title]];
NgotStudio["d3"]=Instance.new("UIPadding",NgotStudio["cf"]);
NgotStudio["d3"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["d3"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["d3"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["d3"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["d4"]=Instance.new("UIListLayout",NgotStudio["cf"]);
NgotStudio["d4"]["Padding"]=UDim.new(0,5);
NgotStudio["d4"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["d5"]=Instance.new("TextBox",NgotStudio["cf"]);
NgotStudio["d5"]["Name"]=[[Code]];
NgotStudio["d5"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["d5"]["BorderSizePixel"]=0;
NgotStudio["d5"]["TextEditable"]=false;
NgotStudio["d5"]["TextWrapped"]=true;
NgotStudio["d5"]["TextSize"]=16;
NgotStudio["d5"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["d5"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["d5"]["FontFace"]=Font.new([[rbxasset://fonts/families/Inconsolata.json]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["d5"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["d5"]["Selectable"]=false;
NgotStudio["d5"]["MultiLine"]=true;
NgotStudio["d5"]["ClearTextOnFocus"]=false;
NgotStudio["d5"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["d5"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["d5"]["Text"]=[[print("Hello World!")]];
NgotStudio["d5"]["LayoutOrder"]=1;
NgotStudio["d5"]["BackgroundTransparency"]=1;
NgotStudio["d6"]=Instance.new("Frame",NgotStudio["41"]);
NgotStudio["d6"]["Visible"]=false;
NgotStudio["d6"]["BorderSizePixel"]=0;
NgotStudio["d6"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["d6"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["d6"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["d6"]["Position"]=UDim2 .new(0,0,0.43728,0);
NgotStudio["d6"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["d6"]["Name"]=[[Section]];
NgotStudio["d6"]["BackgroundTransparency"]=1;
NgotStudio["d7"]=Instance.new("ImageButton",NgotStudio["d6"]);
NgotStudio["d7"]["BorderSizePixel"]=0;
NgotStudio["d7"]["AutoButtonColor"]=false;
NgotStudio["d7"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["d7"]["Selectable"]=false;
NgotStudio["d7"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["d7"]["Size"]=UDim2 .new(1,0,0,35);
NgotStudio["d7"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["d7"]["Name"]=[[Button]];
NgotStudio["d8"]=Instance.new("UICorner",NgotStudio["d7"]);
NgotStudio["d8"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["d9"]=Instance.new("UIStroke",NgotStudio["d7"]);
NgotStudio["d9"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["d9"]["Thickness"]=1.5;
NgotStudio["d9"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["da"]=Instance.new("TextLabel",NgotStudio["d7"]);
NgotStudio["da"]["TextWrapped"]=true;
NgotStudio["da"]["Interactable"]=false;
NgotStudio["da"]["BorderSizePixel"]=0;
NgotStudio["da"]["TextSize"]=16;
NgotStudio["da"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["da"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["da"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["da"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["da"]["BackgroundTransparency"]=1;
NgotStudio["da"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["da"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["da"]["Text"]=[[Section]];
NgotStudio["da"]["Name"]=[[Title]];
NgotStudio["db"]=Instance.new("ImageButton",NgotStudio["da"]);
NgotStudio["db"]["BorderSizePixel"]=0;
NgotStudio["db"]["AutoButtonColor"]=false;
NgotStudio["db"]["BackgroundTransparency"]=1;
NgotStudio["db"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["db"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["db"]["AnchorPoint"]=Vector2 .new(1,0.5);
NgotStudio["db"]["Image"]=[[rbxassetid://120292618616139]];
NgotStudio["db"]["Size"]=UDim2 .new(0,23,0,23);
NgotStudio["db"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["db"]["Name"]=[[Arrow]];
NgotStudio["db"]["Position"]=UDim2 .new(1,0,0.5,0);
NgotStudio["dc"]=Instance.new("UIPadding",NgotStudio["d7"]);
NgotStudio["dc"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["dc"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["dc"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["dc"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["dd"]=Instance.new("UIListLayout",NgotStudio["d7"]);
NgotStudio["dd"]["Padding"]=UDim.new(0,5);
NgotStudio["dd"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["de"]=Instance.new("TextLabel",NgotStudio["d7"]);
NgotStudio["de"]["TextWrapped"]=true;
NgotStudio["de"]["Interactable"]=false;
NgotStudio["de"]["BorderSizePixel"]=0;
NgotStudio["de"]["TextSize"]=16;
NgotStudio["de"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["de"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["de"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal);
NgotStudio["de"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["de"]["BackgroundTransparency"]=1;
NgotStudio["de"]["Size"]=UDim2 .new(1,0,0,15);
NgotStudio["de"]["Visible"]=false;
NgotStudio["de"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["de"]["Text"]=[[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["de"]["LayoutOrder"]=1;
NgotStudio["de"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["de"]["Name"]=[[Description]];
NgotStudio["df"]=Instance.new("UIGradient",NgotStudio["d7"]);
NgotStudio["df"]["Enabled"]=false;
NgotStudio["df"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["e0"]=Instance.new("UIGradient",NgotStudio["d7"]);
NgotStudio["e0"]["Enabled"]=false;
NgotStudio["e0"]["Transparency"]=NumberSequence.new{NumberSequenceKeypoint.new(0.000,1),NumberSequenceKeypoint.new(1.000,1)};
NgotStudio["e0"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["e1"]=Instance.new("UIGradient",NgotStudio["d7"]);
NgotStudio["e1"]["Enabled"]=false;
NgotStudio["e1"]["Color"]=ColorSequence.new{ColorSequenceKeypoint.new(0.000,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.160,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(0.320,Color3 .fromRGB(0,158,255)),ColorSequenceKeypoint.new(0.540,Color3 .fromRGB(0,5,255)),ColorSequenceKeypoint.new(0.782,Color3 .fromRGB(0,235,255)),ColorSequenceKeypoint.new(1.000,Color3 .fromRGB(0,158,255))};
NgotStudio["e2"]=Instance.new("UIStroke",NgotStudio["d7"]);
NgotStudio["e2"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["e2"]["Thickness"]=1.5;
NgotStudio["e2"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["e3"]=Instance.new("Frame",NgotStudio["d6"]);
NgotStudio["e3"]["Visible"]=false;
NgotStudio["e3"]["BorderSizePixel"]=0;
NgotStudio["e3"]["BackgroundColor3"]=Color3 .fromRGB(207,222,255);
NgotStudio["e3"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["e3"]["Size"]=UDim2 .new(1,0,0,30);
NgotStudio["e3"]["Position"]=UDim2 .new(0,0,0,35);
NgotStudio["e3"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["e3"]["BackgroundTransparency"]=1;
NgotStudio["e4"]=Instance.new("UIListLayout",NgotStudio["e3"]);
NgotStudio["e4"]["HorizontalAlignment"]=Enum.HorizontalAlignment.Center;
NgotStudio["e4"]["Padding"]=UDim.new(0,10);
NgotStudio["e4"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["e5"]=Instance.new("UIPadding",NgotStudio["e3"]);
NgotStudio["e5"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["e5"]["PaddingRight"]=UDim.new(0,8);
NgotStudio["e5"]["PaddingLeft"]=UDim.new(0,8);
NgotStudio["e6"]=Instance.new("Frame",NgotStudio["e3"]);
NgotStudio["e6"]["BorderSizePixel"]=0;
NgotStudio["e6"]["BackgroundColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["e6"]["Size"]=UDim2 .new(1,0,0,3);
NgotStudio["e6"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["e6"]["Name"]=[[Divider]];
NgotStudio["e7"]=Instance.new("Folder",NgotStudio["41"]);
NgotStudio["e7"]["Name"]=[[DialogElements]];
NgotStudio["e8"]=Instance.new("Frame",NgotStudio["e7"]);
NgotStudio["e8"]["Visible"]=false;
NgotStudio["e8"]["BorderSizePixel"]=0;
NgotStudio["e8"]["BackgroundColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["e8"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["e8"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["e8"]["Name"]=[[DarkOverlayDialog]];
NgotStudio["e8"]["BackgroundTransparency"]=0.6;
NgotStudio["e9"]=Instance.new("UICorner",NgotStudio["e8"]);
NgotStudio["e9"]["CornerRadius"]=UDim.new(0,10);
NgotStudio["ea"]=Instance.new("Frame",NgotStudio["e7"]);
NgotStudio["ea"]["Visible"]=false;
NgotStudio["ea"]["ZIndex"]=4;
NgotStudio["ea"]["BorderSizePixel"]=0;
NgotStudio["ea"]["BackgroundColor3"]=Color3 .fromRGB(32,35,41);
NgotStudio["ea"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["ea"]["ClipsDescendants"]=true;
NgotStudio["ea"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["ea"]["Size"]=UDim2 .new(0,250,0,0);
NgotStudio["ea"]["Position"]=UDim2 .new(0.5,0,0.5,0);
NgotStudio["ea"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["ea"]["Name"]=[[Dialog]];
NgotStudio["eb"]=Instance.new("UICorner",NgotStudio["ea"]);
NgotStudio["eb"]["CornerRadius"]=UDim.new(0,6);
NgotStudio["ec"]=Instance.new("UIStroke",NgotStudio["ea"]);
NgotStudio["ec"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["ec"]["Thickness"]=1.5;
NgotStudio["ec"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["ed"]=Instance.new("Frame",NgotStudio["ea"]);
NgotStudio["ed"]["BorderSizePixel"]=0;
NgotStudio["ed"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["ed"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["ed"]["Size"]=UDim2 .new(1,0,0,25);
NgotStudio["ed"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["ed"]["Name"]=[[Title]];
NgotStudio["ed"]["BackgroundTransparency"]=1;
NgotStudio["ee"]=Instance.new("TextLabel",NgotStudio["ed"]);
NgotStudio["ee"]["Interactable"]=false;
NgotStudio["ee"]["ZIndex"]=0;
NgotStudio["ee"]["BorderSizePixel"]=0;
NgotStudio["ee"]["TextSize"]=20;
NgotStudio["ee"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["ee"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["ee"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["ee"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["ee"]["BackgroundTransparency"]=1;
NgotStudio["ee"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["ee"]["Size"]=UDim2 .new(0,0,0,20);
NgotStudio["ee"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["ee"]["Text"]=[[]];
NgotStudio["ee"]["LayoutOrder"]=1;
NgotStudio["ee"]["AutomaticSize"]=Enum.AutomaticSize.XY;
NgotStudio["ee"]["Position"]=UDim2 .new(-0.05455,12,0.5,0);
NgotStudio["ef"]=Instance.new("UIListLayout",NgotStudio["ed"]);
NgotStudio["ef"]["Padding"]=UDim.new(0,10);
NgotStudio["ef"]["VerticalAlignment"]=Enum.VerticalAlignment.Center;
NgotStudio["ef"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["ef"]["FillDirection"]=Enum.FillDirection.Horizontal;
NgotStudio["f0"]=Instance.new("UIPadding",NgotStudio["ed"]);
NgotStudio["f0"]["PaddingTop"]=UDim.new(0,5);
NgotStudio["f0"]["PaddingRight"]=UDim.new(0,15);
NgotStudio["f0"]["PaddingLeft"]=UDim.new(0,15);
NgotStudio["f0"]["PaddingBottom"]=UDim.new(0,5);
NgotStudio["f1"]=Instance.new("ImageButton",NgotStudio["ed"]);
NgotStudio["f1"]["BorderSizePixel"]=0;
NgotStudio["f1"]["Visible"]=false;
NgotStudio["f1"]["BackgroundTransparency"]=1;
NgotStudio["f1"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["f1"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["f1"]["Size"]=UDim2 .new(0,33,0,25);
NgotStudio["f1"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["f1"]["Name"]=[[Icon]];
NgotStudio["f1"]["Position"]=UDim2 .new(0,0,0.2125,0);
NgotStudio["f2"]=Instance.new("UIAspectRatioConstraint",NgotStudio["f1"]);
NgotStudio["f3"]=Instance.new("UIListLayout",NgotStudio["ea"]);
NgotStudio["f3"]["HorizontalAlignment"]=Enum.HorizontalAlignment.Center;
NgotStudio["f3"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["f4"]=Instance.new("Frame",NgotStudio["ea"]);
NgotStudio["f4"]["Visible"]=false;
NgotStudio["f4"]["ZIndex"]=2;
NgotStudio["f4"]["BorderSizePixel"]=0;
NgotStudio["f4"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["f4"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["f4"]["Size"]=UDim2 .new(1,0,0,0);
NgotStudio["f4"]["Position"]=UDim2 .new(0,0,0.21886,0);
NgotStudio["f4"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["f4"]["Name"]=[[Content]];
NgotStudio["f4"]["BackgroundTransparency"]=1;
NgotStudio["f5"]=Instance.new("UIListLayout",NgotStudio["f4"]);
NgotStudio["f5"]["VerticalAlignment"]=Enum.VerticalAlignment.Center;
NgotStudio["f5"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["f6"]=Instance.new("UIPadding",NgotStudio["f4"]);
NgotStudio["f6"]["PaddingTop"]=UDim.new(0,5);
NgotStudio["f6"]["PaddingRight"]=UDim.new(0,15);
NgotStudio["f6"]["PaddingLeft"]=UDim.new(0,15);
NgotStudio["f6"]["PaddingBottom"]=UDim.new(0,5);
NgotStudio["f7"]=Instance.new("TextLabel",NgotStudio["f4"]);
NgotStudio["f7"]["TextWrapped"]=true;
NgotStudio["f7"]["Interactable"]=false;
NgotStudio["f7"]["BorderSizePixel"]=0;
NgotStudio["f7"]["TextSize"]=15;
NgotStudio["f7"]["TextXAlignment"]=Enum.TextXAlignment.Left;
NgotStudio["f7"]["TextYAlignment"]=Enum.TextYAlignment.Top;
NgotStudio["f7"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["f7"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["f7"]["TextColor3"]=Color3 .fromRGB(145,154,173);
NgotStudio["f7"]["BackgroundTransparency"]=1;
NgotStudio["f7"]["Size"]=UDim2 .new(1,0,0,0);
NgotStudio["f7"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["f7"]["Text"]=[[]];
NgotStudio["f7"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["f7"]["Position"]=UDim2 .new(0,0,0.125,0);
NgotStudio["f8"]=Instance.new("UIPadding",NgotStudio["ea"]);
NgotStudio["f8"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["f8"]["PaddingBottom"]=UDim.new(0,10);
NgotStudio["f9"]=Instance.new("Frame",NgotStudio["ea"]);
NgotStudio["f9"]["ZIndex"]=3;
NgotStudio["f9"]["BorderSizePixel"]=0;
NgotStudio["f9"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["f9"]["AutomaticSize"]=Enum.AutomaticSize.Y;
NgotStudio["f9"]["Size"]=UDim2 .new(1,0,0,0);
NgotStudio["f9"]["Position"]=UDim2 .new(0,0,0.53017,0);
NgotStudio["f9"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["f9"]["Name"]=[[Buttons]];
NgotStudio["f9"]["BackgroundTransparency"]=1;
NgotStudio["fa"]=Instance.new("UIListLayout",NgotStudio["f9"]);
NgotStudio["fa"]["HorizontalAlignment"]=Enum.HorizontalAlignment.Center;
NgotStudio["fa"]["Padding"]=UDim.new(0,10);
NgotStudio["fa"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["fb"]=Instance.new("UIPadding",NgotStudio["f9"]);
NgotStudio["fb"]["PaddingTop"]=UDim.new(0,5);
NgotStudio["fb"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["fb"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["fc"]=Instance.new("Frame",NgotStudio["e7"]);
NgotStudio["fc"]["Visible"]=false;
NgotStudio["fc"]["BorderSizePixel"]=0;
NgotStudio["fc"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["fc"]["AnchorPoint"]=Vector2 .new(0.5,1);
NgotStudio["fc"]["Size"]=UDim2 .new(1,0,0,30);
NgotStudio["fc"]["Position"]=UDim2 .new(0.5,0,0.327,0);
NgotStudio["fc"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["fc"]["Name"]=[[DialogButton]];
NgotStudio["fc"]["BackgroundTransparency"]=1;
NgotStudio["fd"]=Instance.new("TextButton",NgotStudio["fc"]);
NgotStudio["fd"]["BorderSizePixel"]=0;
NgotStudio["fd"]["AutoButtonColor"]=false;
NgotStudio["fd"]["BackgroundColor3"]=Color3 .fromRGB(43,46,53);
NgotStudio["fd"]["Selectable"]=false;
NgotStudio["fd"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["fd"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["fd"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["fd"]["Name"]=[[Button]];
NgotStudio["fd"]["Position"]=UDim2 .new(0.5,0,0.5,0);
NgotStudio["fe"]=Instance.new("UICorner",NgotStudio["fd"]);
NgotStudio["fe"]["CornerRadius"]=UDim.new(0,5);
NgotStudio["ff"]=Instance.new("UIStroke",NgotStudio["fd"]);
NgotStudio["ff"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["ff"]["Thickness"]=1.5;
NgotStudio["ff"]["Color"]=Color3 .fromRGB(61,61,75);
NgotStudio["100"]=Instance.new("UIListLayout",NgotStudio["fd"]);
NgotStudio["100"]["HorizontalAlignment"]=Enum.HorizontalAlignment.Center;
NgotStudio["100"]["Padding"]=UDim.new(0,5);
NgotStudio["100"]["VerticalAlignment"]=Enum.VerticalAlignment.Center;
NgotStudio["100"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["101"]=Instance.new("TextLabel",NgotStudio["fd"]);
NgotStudio["101"]["TextWrapped"]=true;
NgotStudio["101"]["Interactable"]=false;
NgotStudio["101"]["BorderSizePixel"]=0;
NgotStudio["101"]["TextSize"]=14;
NgotStudio["101"]["TextScaled"]=true;
NgotStudio["101"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["101"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal);
NgotStudio["101"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["101"]["BackgroundTransparency"]=1;
NgotStudio["101"]["Size"]=UDim2 .new(1,0,0.45,0);
NgotStudio["101"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["101"]["Text"]=[[]];
NgotStudio["101"]["Name"]=[[Label]];
NgotStudio["101"]["Position"]=UDim2 .new(0,45,0.083,0);
NgotStudio["102"]=Instance.new("Frame",NgotStudio["1"]);
NgotStudio["102"]["ZIndex"]=10;
NgotStudio["102"]["BorderSizePixel"]=0;
NgotStudio["102"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["102"]["AnchorPoint"]=Vector2 .new(0.5,0);
NgotStudio["102"]["Size"]=UDim2 .new(0,630,1,0);
NgotStudio["102"]["Position"]=UDim2 .new(1,0,0,0);
NgotStudio["102"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["102"]["Name"]=[[NotificationList]];
NgotStudio["102"]["BackgroundTransparency"]=1;
NgotStudio["103"]=Instance.new("UIListLayout",NgotStudio["102"]);
NgotStudio["103"]["Padding"]=UDim.new(0,12);
NgotStudio["103"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["104"]=Instance.new("UIPadding",NgotStudio["102"]);
NgotStudio["104"]["PaddingTop"]=UDim.new(0,10);
NgotStudio["104"]["PaddingRight"]=UDim.new(0,40);
NgotStudio["104"]["PaddingLeft"]=UDim.new(0,40);
NgotStudio["105"]=Instance.new("Frame",NgotStudio["1"]);
NgotStudio["105"]["Visible"]=false;
NgotStudio["105"]["ZIndex"]=0;
NgotStudio["105"]["BorderSizePixel"]=2;
NgotStudio["105"]["BackgroundColor3"]=Color3 .fromRGB(37,40,47);
NgotStudio["105"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["105"]["ClipsDescendants"]=true;
NgotStudio["105"]["AutomaticSize"]=Enum.AutomaticSize.X;
NgotStudio["105"]["Size"]=UDim2 .new(0,85,0,45);
NgotStudio["105"]["Position"]=UDim2 .new(0.5,0,0,45);
NgotStudio["105"]["BorderColor3"]=Color3 .fromRGB(61,61,75);
NgotStudio["105"]["Name"]=[[FloatIcon]];
NgotStudio["106"]=Instance.new("UICorner",NgotStudio["105"]);
NgotStudio["106"]["CornerRadius"]=UDim.new(0,10);
NgotStudio["107"]=Instance.new("UIStroke",NgotStudio["105"]);
NgotStudio["107"]["Transparency"]=0.5;
NgotStudio["107"]["ApplyStrokeMode"]=Enum.ApplyStrokeMode.Border;
NgotStudio["107"]["Thickness"]=1.5;
NgotStudio["107"]["Color"]=Color3 .fromRGB(95,95,117);
NgotStudio["108"]=Instance.new("UIPadding",NgotStudio["105"]);
NgotStudio["108"]["PaddingTop"]=UDim.new(0,8);
NgotStudio["108"]["PaddingRight"]=UDim.new(0,10);
NgotStudio["108"]["PaddingLeft"]=UDim.new(0,10);
NgotStudio["108"]["PaddingBottom"]=UDim.new(0,8);
NgotStudio["109"]=Instance.new("UIListLayout",NgotStudio["105"]);
NgotStudio["109"]["Padding"]=UDim.new(0,8);
NgotStudio["109"]["VerticalAlignment"]=Enum.VerticalAlignment.Center;
NgotStudio["109"]["SortOrder"]=Enum.SortOrder.LayoutOrder;
NgotStudio["109"]["FillDirection"]=Enum.FillDirection.Horizontal;
NgotStudio["10a"]=Instance.new("ImageButton",NgotStudio["105"]);
NgotStudio["10a"]["Active"]=false;
NgotStudio["10a"]["Interactable"]=false;
NgotStudio["10a"]["BorderSizePixel"]=0;
NgotStudio["10a"]["AutoButtonColor"]=false;
NgotStudio["10a"]["BackgroundTransparency"]=1;
NgotStudio["10a"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["10a"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["10a"]["Image"]=[[rbxassetid://113216930555884]];
NgotStudio["10a"]["Size"]=UDim2 .new(1,0,1,0);
NgotStudio["10a"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["10a"]["Name"]=[[Icon]];
NgotStudio["10a"]["Position"]=UDim2 .new(0,10,0.5,0);
NgotStudio["10b"]=Instance.new("UIAspectRatioConstraint",NgotStudio["10a"]);
NgotStudio["10c"]=Instance.new("TextLabel",NgotStudio["105"]);
NgotStudio["10c"]["Interactable"]=false;
NgotStudio["10c"]["BorderSizePixel"]=0;
NgotStudio["10c"]["TextSize"]=16;
NgotStudio["10c"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["10c"]["FontFace"]=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal);
NgotStudio["10c"]["TextColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["10c"]["BackgroundTransparency"]=1;
NgotStudio["10c"]["AnchorPoint"]=Vector2 .new(0.5,0.5);
NgotStudio["10c"]["Size"]=UDim2 .new(0,20,0,20);
NgotStudio["10c"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["10c"]["Text"]=[[NgotStudio]];
NgotStudio["10c"]["AutomaticSize"]=Enum.AutomaticSize.X;
NgotStudio["10c"]["Position"]=UDim2 .new(0.38615,0,0.53448,-1);
NgotStudio["10d"]=Instance.new("ImageButton",NgotStudio["105"]);
NgotStudio["10d"]["BorderSizePixel"]=0;
NgotStudio["10d"]["AutoButtonColor"]=false;
NgotStudio["10d"]["BackgroundTransparency"]=1;
NgotStudio["10d"]["BackgroundColor3"]=Color3 .fromRGB(255,255,255);
NgotStudio["10d"]["ImageColor3"]=Color3 .fromRGB(197,204,219);
NgotStudio["10d"]["Selectable"]=false;
NgotStudio["10d"]["AnchorPoint"]=Vector2 .new(0,0.5);
NgotStudio["10d"]["Image"]=[[rbxassetid://122219713887461]];
NgotStudio["10d"]["Size"]=UDim2 .new(0,20,0,20);
NgotStudio["10d"]["BorderColor3"]=Color3 .fromRGB(0,0,0);
NgotStudio["10d"]["Name"]=[[Open]];
NgotStudio["10d"]["Position"]=UDim2 .new(0,128,0.5,0);
NgotStudio["10e"]=Instance.new("UIAspectRatioConstraint",NgotStudio["10d"]);
NgotStudio["10f"]=Instance.new("UICorner",NgotStudio["10d"]);
local NgotStudio_REQUIRE=require;
local NgotStudio_MODULES={};
local function require(Module:ModuleScript)
local ModuleState=NgotStudio_MODULES[Module];
if ModuleState then
if not ModuleState.Required then
ModuleState.Required=true;
ModuleState.Value=ModuleState.Closure();
end
return ModuleState.Value;
end;
return NgotStudio_REQUIRE(Module);
end
NgotStudio_MODULES[NgotStudio["3e"]]={
Closure=function()
local script=NgotStudio["3e"];local LIB={}
local IconModule=require(script.IconModule)
local UIS=game:GetService("UserInputService")
local Gui=script.Parent
local Templates=script.Parent.Templates
local oldWindow=script.Parent.Window
local oldFloatingIcon=script.Parent.FloatIcon
Templates.Parent=nil
oldWindow.Parent=nil
oldFloatingIcon.Parent=nil
local TweenConfigs={
Global={
Duration=0.25,
EasingStyle=Enum.EasingStyle.Quart,
EasingDirection=Enum.EasingDirection.Out
},
Notification={
Duration=0.5,
EasingStyle=Enum.EasingStyle.Back,
EasingDirection=Enum.EasingDirection.Out
},
PopupOpen={
Duration=0.4,
EasingStyle=Enum.EasingStyle.Back,
EasingDirection=Enum.EasingDirection.Out
},
PopupClose={
Duration=0.4,
EasingStyle=Enum.EasingStyle.Back,
EasingDirection=Enum.EasingDirection.In
},
}
local function Tween(inst,props,config)
local twconfig=TweenInfo.new(config.Duration,config.EasingStyle or Enum.EasingStyle.Linear,config.EasingDirection or Enum.EasingDirection.Out)
local tw=game:GetService("TweenService"):Create(inst,twconfig,props)
tw:Play()
return tw
end
local function Draggable(topbarobject,object)
local funcs={}
local tsv=game:GetService("TweenService")
local Dragging=false
local DragInput=nil
local DragStart=nil
local StartPosition=nil
local allowDragging=true
local destroyed=false
local connections={}
local dragEndConnection=nil
local function Track(connection)
table.insert(connections,connection)
return connection
end
local function Update(input)
if destroyed or not DragStart or not StartPosition then return end
local Delta=input.Position-DragStart
local pos=UDim2 .new(
StartPosition.X.Scale,
StartPosition.X.Offset+Delta.X,
StartPosition.Y.Scale,
StartPosition.Y.Offset+Delta.Y
)
tsv:Create(object,TweenInfo.new(0.2,Enum.EasingStyle.Quart),{Position=pos}):Play()
end
Track(topbarobject.InputBegan:Connect(function(input)
if destroyed or not allowDragging then return end
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
Dragging=true
DragStart=input.Position
StartPosition=object.Position
if dragEndConnection then dragEndConnection:Disconnect()end
dragEndConnection=input.Changed:Connect(function()
if input.UserInputState==Enum.UserInputState.End then
Dragging=false
if dragEndConnection then
dragEndConnection:Disconnect()
dragEndConnection=nil
end
end
end)
end
end))
Track(topbarobject.InputChanged:Connect(function(input)
if destroyed or not allowDragging then return end
if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
DragInput=input
end
end))
Track(UIS.InputChanged:Connect(function(input)
if not destroyed and allowDragging and input==DragInput and Dragging then
Update(input)
end
end))
function funcs:SetAllowDragging(state)
allowDragging=state==true
if not allowDragging then Dragging=false end
end
function funcs:Destroy()
if destroyed then return end
destroyed=true
Dragging=false
if dragEndConnection then dragEndConnection:Disconnect();dragEndConnection=nil end
for _,connection in ipairs(connections)do
connection:Disconnect()
end
table.clear(connections)
end
return funcs
end
local function Resizable(handle,object,minSize,maxSize)
local Mouse=game.Players.LocalPlayer:GetMouse()
local funcs={}
local allowResizing=true
local resizing=false
local destroyed=false
local connections={}
local function Track(connection)
table.insert(connections,connection)
return connection
end
local function Resize()
if destroyed or not allowResizing or resizing then return end
resizing=true
local dragStartX,dragStartY=Mouse.X,Mouse.Y
local startSize=object.Size
repeat
task.wait()
if allowResizing and not destroyed and object.Parent then
local deltaX=Mouse.X-dragStartX
local deltaY=Mouse.Y-dragStartY
local newX=math.clamp(startSize.X.Offset+deltaX,minSize.X,maxSize.X)
local newY=math.clamp(startSize.Y.Offset+deltaY,minSize.Y,maxSize.Y)
object.Size=UDim2 .fromOffset(newX,newY)
end
until not resizing or not allowResizing or destroyed
end
Track(handle.InputBegan:Connect(function(input)
if destroyed or not allowResizing then return end
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
task.spawn(Resize)
end
end))
Track(UIS.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
resizing=false
end
end))
function funcs:SetAllowResizing(state)
allowResizing=state==true
if not allowResizing then resizing=false end
end
function funcs:SetMinSize(size)
if typeof(size)=="Vector2"then minSize=size end
end
function funcs:SetMaxSize(size)
if typeof(size)=="Vector2"then maxSize=size end
end
function funcs:Destroy()
if destroyed then return end
destroyed=true
resizing=false
for _,connection in ipairs(connections)do
connection:Disconnect()
end
table.clear(connections)
end
return funcs
end
local HttpService=game:GetService("HttpService")
local function CopyText(text)
local clipboard=type(setclipboard)=="function"and setclipboard
or(type(toclipboard)=="function"and toclipboard)
if not clipboard then return false end
return pcall(clipboard,tostring(text or""))
end
local function ShowCopiedTip(target)
local tip=Instance.new("TextLabel")
tip.Text="Copied!"
tip.FontFace=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal)
tip.TextSize=12
tip.TextColor3=Color3 .fromRGB(255,255,255)
tip.BackgroundColor3=Color3 .fromRGB(10,135,213)
tip.AutomaticSize=Enum.AutomaticSize.XY
tip.AnchorPoint=Vector2 .new(0.5,1)
tip.Position=UDim2 .new(0.5,0,0,-4)
tip.ZIndex=20
tip.BackgroundTransparency=1
tip.TextTransparency=1
tip.Parent=target
local pad=Instance.new("UIPadding",tip)
pad.PaddingLeft=UDim.new(0,6)
pad.PaddingRight=UDim.new(0,6)
pad.PaddingTop=UDim.new(0,3)
pad.PaddingBottom=UDim.new(0,3)
Instance.new("UICorner",tip).CornerRadius=UDim.new(0,4)
Tween(tip,{BackgroundTransparency=0,TextTransparency=0},TweenConfigs.Global)
task.delay(1,function()
if tip and tip.Parent then
local tw=Tween(tip,{BackgroundTransparency=1,TextTransparency=1},TweenConfigs.Global)
tw.Completed:Wait()
tip:Destroy()
end
end)
end
local function CreateSocialIcon(parent,iconId,copyValue,order)
local btn=Instance.new("ImageButton")
btn.Name="SocialIcon"
btn.BackgroundColor3=Color3 .fromRGB(53,56,62)
btn.Size=UDim2 .new(0,32,0,32)
btn.AutoButtonColor=false
btn.LayoutOrder=order or 0
btn.Parent=parent
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
local stroke=Instance.new("UIStroke",btn)
stroke.Color=Color3 .fromRGB(61,61,75)
stroke.Thickness=1.5
local icon=Instance.new("ImageLabel",btn)
icon.BackgroundTransparency=1
icon.Image=iconId
icon.ImageColor3=Color3 .fromRGB(197,204,219)
icon.ScaleType=Enum.ScaleType.Fit
icon.AnchorPoint=Vector2 .new(0.5,0.5)
icon.Position=UDim2 .new(0.5,0,0.5,0)
icon.Size=UDim2 .new(1,-14,1,-14)
btn.MouseEnter:Connect(function()
Tween(stroke,{Color=Color3 .fromRGB(10,135,213)},TweenConfigs.Global)
end)
btn.MouseLeave:Connect(function()
Tween(stroke,{Color=Color3 .fromRGB(61,61,75)},TweenConfigs.Global)
end)
btn.MouseButton1Click:Connect(function()
if copyValue and copyValue~=""and CopyText(copyValue)then
Tween(btn,{BackgroundColor3=Color3 .fromRGB(10,135,213)},TweenConfigs.Global)
task.delay(0.2,function()
if btn.Parent then Tween(btn,{BackgroundColor3=Color3 .fromRGB(53,56,62)},TweenConfigs.Global)end
end)
ShowCopiedTip(btn)
end
end)
return btn
end
local function ApplyIcon(target,iconValue)
if not target then return false end
local value=tostring(iconValue or"")
target.ImageRectOffset=Vector2 .new(0,0)
target.ImageRectSize=Vector2 .new(0,0)
if value==""then
target.Image=""
return false
end
local iconData=IconModule.Icon(value)
if iconData then
target.Image=iconData[1]or""
target.ImageRectOffset=iconData[2].ImageRectPosition or Vector2 .new(0,0)
target.ImageRectSize=iconData[2].ImageRectSize or Vector2 .new(0,0)
return true
end
target.Image=value
return true
end
local function createIntegratedDynamicIsland(__hostGui,__hostWindow)
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local TextService=game:GetService("TextService")
local Stats=game:GetService("Stats")
local SoundService=game:GetService("SoundService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera or workspace:WaitForChild("Camera")
do
local parents={playerGui}
local okHui,hui=pcall(function()return gethui and gethui()end)
if okHui and hui then parents[#parents+1]=hui end
local okCore,core=pcall(function()return game:GetService("CoreGui")end)
if okCore and core then parents[#parents+1]=core end
for _,parent in ipairs(parents)do
pcall(function()
for _,child in ipairs(parent:GetChildren())do
local childName=tostring(child.Name)
if childName=="xNgotStudio_FullDynamicIsland"or childName=="xNgotStudio_FullIsland"then
child:Destroy()
end
end
end)
end
pcall(function()
local existingBlur=Lighting:FindFirstChild("xNgotStudio_FullIslandBlur")
if existingBlur then
existingBlur:Destroy()
end
end)
end
local connections={}
local function track(connection)
table.insert(connections,connection)
return connection
end
local VERSION="3.0.0"
local FAMILY="rbxasset://fonts/families/GothamSSm.json"
local Fonts={
Regular=Font.new(FAMILY,Enum.FontWeight.Regular),
Medium=Font.new(FAMILY,Enum.FontWeight.Medium),
Semibold=Font.new(FAMILY,Enum.FontWeight.SemiBold),
Bold=Font.new(FAMILY,Enum.FontWeight.Bold),
}
local function rgb(r,g,b)
return Color3 .fromRGB(r,g,b)
end
local Static={
White=Color3 .new(1,1,1),
Black=Color3 .new(0,0,0),
Blue=rgb(10,132,255),
Green=rgb(48,209,88),
Orange=rgb(255,159,10),
Red=rgb(255,69,58),
Purple=rgb(191,90,242),
Gray=rgb(142,142,147),
LightGray=rgb(174,174,178),
TrafficRed=rgb(255,95,87),
TrafficYellow=rgb(254,188,46),
TrafficGreen=rgb(40,200,64),
}
local Palettes={
{
Window=rgb(24,24,27),
Card=rgb(44,44,48),
Field=rgb(28,28,31),
Off=rgb(78,78,84),
Text=rgb(245,245,247),
Sub=rgb(152,152,160),
Line=rgb(255,255,255),
Seg=rgb(99,99,102),
},
{
Window=rgb(244,244,247),
Card=rgb(255,255,255),
Field=rgb(236,236,241),
Off=rgb(208,208,214),
Text=rgb(28,28,30),
Sub=rgb(110,110,118),
Line=rgb(0,0,0),
Seg=rgb(255,255,255),
},
{
Window=rgb(5,5,9),
Card=rgb(21,21,28),
Field=rgb(11,11,16),
Off=rgb(56,57,68),
Text=rgb(240,242,250),
Sub=rgb(128,133,152),
Line=rgb(255,255,255),
Seg=rgb(68,70,86),
},
{
Window=rgb(9,24,42),
Card=rgb(19,44,70),
Field=rgb(12,31,52),
Off=rgb(50,78,106),
Text=rgb(232,244,255),
Sub=rgb(128,160,192),
Line=rgb(255,255,255),
Seg=rgb(60,94,128),
},
{
Window=rgb(13,28,21),
Card=rgb(23,49,37),
Field=rgb(16,36,28),
Off=rgb(56,88,71),
Text=rgb(234,249,239),
Sub=rgb(132,172,149),
Line=rgb(255,255,255),
Seg=rgb(64,104,82),
},
{
Window=rgb(30,22,19),
Card=rgb(53,41,35),
Field=rgb(37,28,24),
Off=rgb(92,76,67),
Text=rgb(250,240,229),
Sub=rgb(178,153,136),
Line=rgb(255,255,255),
Seg=rgb(112,92,80),
},
{
Window=rgb(252,237,243),
Card=rgb(255,250,252),
Field=rgb(247,225,234),
Off=rgb(233,204,216),
Text=rgb(60,27,41),
Sub=rgb(152,102,125),
Line=rgb(0,0,0),
Seg=rgb(255,255,255),
},
}
local ThemeNames={"Tối","Sáng","Nửa đêm","Đại dương","Rừng xanh","Cà phê","Sakura"}
local Accents={
{"Xanh dương",rgb(10,132,255)},
{"Tím",rgb(191,90,242)},
{"Hồng",rgb(255,55,95)},
{"Cam",rgb(255,159,10)},
{"Xanh lá",rgb(48,209,88)},
{"Ngọc",rgb(64,200,224)},
}
local ScaleFactors={0.9,1,1.12}
local KIND_ORDER={"success","info","warn","error"}
local Settings={
Expand=true,
Split=true,
RimLight=true,
Theme=1,
Language="en",
Accent=1,
Blur=true,
BlurSize=16,
Scale=2,
Sound=true,
Volume=40,
ToggleKey=Enum.KeyCode.RightShift,
Breathe=true,
AutoHide=true,
Duration=2.5,
NotifyKind=1,
Reverb=true,
Ring=true,
}
local function crossPromptIsVi(prompt)
if type(prompt)~="string"then return false end
return prompt:find("[\195-\197\204]")~=nil
end
local VI_EN={
["Tổng quan"]="Overview",
["Âm nhạc"]="Music",
["Thông báo"]="Notifications",
["Tiện ích"]="Utilities",
["Giao diện"]="Appearance",
["Cài đặt"]="Settings",
["Giới thiệu"]="About",
["Hiệu năng"]="Performance",
["FPS trong 15 giây gần nhất"]="FPS over the last 15 seconds",
["Thao tác nhanh"]="Quick actions",
["Đổi giao diện"]="Toggle appearance",
["Hẹn giờ 15s"]="15s timer",
["Hẹn giờ 30s"]="30s timer",
["Dừng hẹn giờ"]="Stop timer",
["Xin chào"]="Hello",
["Đây là thông báo từ xNgọtStudio"]="This is a notification from xNgọtStudio",
["Âm thanh"]="Sound",
["Âm thanh giao diện"]="Interface sounds",
["Tiếng khi bấm và khi có thông báo"]="Sounds for clicks and notifications",
["Âm lượng"]="Volume",
["Âm vang"]="Reverb",
["Thêm hiệu ứng vang cho âm thanh"]="Add reverb to interface sounds",
["Nghe thử"]="Preview sound",
["Phím tắt"]="Shortcuts",
["Ẩn / hiện cửa sổ"]="Show / hide window",
["Bấm rồi nhấn phím mới, Esc để huỷ"]="Click, then press a key. Esc to cancel",
["Đã đổi phím tắt"]="Shortcut changed",
["Quản lý"]="Management",
["Đặt lại cài đặt"]="Reset settings",
["Mọi tuỳ chọn sẽ trở về mặc định."]="All options will return to their defaults.",
["Đặt lại"]="Reset",
["Đã đặt lại"]="Reset complete",
["Cài đặt đã về mặc định"]="Settings restored to defaults",
["Gỡ xNgọtStudio"]="Unload xNgọtStudio",
["Gỡ xNgọtStudio?"]="Unload xNgọtStudio?",
["Giao diện sẽ bị xoá khỏi phiên chơi này."]="The interface will be removed from this session.",
["Gỡ"]="Unload",
["Màu nhấn"]="Accent color",
["Màu chủ đạo"]="Main color",
["Chế độ"]="Mode",
["Tối"]="Dark",
["Sáng"]="Light",
["Cửa sổ"]="Window",
["Làm mờ nền"]="Background blur",
["Hiệu ứng blur phía sau cửa sổ"]="Blur behind the window",
["Độ mờ"]="Blur amount",
["Kích thước"]="Size",
["Nhỏ"]="Small",
["Vừa"]="Medium",
["Lớn"]="Large",
["Dynamic Island"]="Dynamic Island",
["Hiện FPS trên đảo"]="Show FPS on the island",
["Hiển thị hiệu năng ngay trên đảo"]="Show performance on the island",
["Chấm nhịp thở"]="Breathing dot",
["Chấm xanh nhấp nháy khi đảo nghỉ"]="Green dot pulses while idle",
["Viền đếm ngược"]="Countdown ring",
["Vòng sáng chạy quanh đảo khi có thông báo"]="Ring drains around the island for notifications",
["Tự ẩn thông báo"]="Auto-hide notifications",
["Thời gian thông báo"]="Notification duration",
["Loại thông báo"]="Notification type",
["Thông tin"]="Information",
["Thành công"]="Success",
["Cảnh báo"]="Warning",
["Lỗi"]="Error",
["Gửi thử"]="Send test",
["Gửi thử thông báo"]="Send test notification",
["Nhập liệu"]="Input",
["Gần đây"]="Recent",
["Chưa có thông báo nào"]="No notifications yet",
["Xoá tất cả"]="Clear all",
["Huỷ"]="Cancel",
["Hoạt động trên đảo"]="Island activity",
["Tải xuống thử"]="Test download",
["Tải thử"]="Test load",
["Tải xuống"]="Download",
["Tải xuống hoàn tất"]="Download complete",
["Hẹn giờ"]="Timer",
["Bấm giờ"]="Stopwatch",
["Vòng"]="Lap",
["Đặt lại cài đặt?"]="Reset settings?",
["Phiên bản"]="Version",
["Giao diện Luau kiểu Apple"]="Apple-style Luau interface",
["Đang phát"]="Now playing",
["Tạm dừng"]="Paused",
["Danh sách phát"]="Playlist",
["Tuỳ chỉnh"]="Options",
["Âm lượng nhạc"]="Music volume",
["Tốc độ"]="Playback speed",
["Tự chuyển bài"]="Auto-advance",
["Chuyển bài sau mỗi hai vòng lặp"]="Advance after the track ends",
["Hiện trên đảo"]="Show on island",
["Hiển thị bài đang phát trên Dynamic Island"]="Show the current track on Dynamic Island",
["Phát"]="Play",
["Dừng"]="Pause",
["‹ Trước"]="‹ Previous",
["Sau ›"]="Next ›",
["Tốc độ chạy"]="Walk speed",
["Lực nhảy"]="Jump power",
["Nhảy liên tục"]="Infinite jump",
["Cho phép nhảy khi đang ở trên không"]="Allow jumping while airborne",
["Máy ảnh"]="Camera",
["Góc nhìn (FOV)"]="Field of view (FOV)",
["Môi trường"]="Environment",
["Giờ trong ngày"]="Time of day",
["Sáng toàn cảnh"]="Global lighting",
["Tắt bóng đổ"]="Disable shadows",
["Thanh trượt"]="Slider",
["Công tắc"]="Toggle",
["Công tắc thử"]="Test toggle",
["Chấm nhịp thở"]="Breathing dot",
["Nhấn phím…"]="Press a key…",
["Chào buổi sáng"]="Good morning",
["Chào buổi trưa"]="Good afternoon",
["Chào buổi chiều"]="Good afternoon",
["Chào buổi tối"]="Good evening",
["Đã dừng hẹn giờ"]="Timer stopped",
["Hoạt động đã được gỡ khỏi đảo"]="Activity removed from the island",
["Bắt đầu hẹn giờ"]="Timer started",
["giây"]="seconds",
["Hết giờ"]="Time is up",
["Hẹn giờ đã kết thúc"]="Timer has ended",
["Đã thu nhỏ"]="Minimized",
["Chạm vào Dynamic Island để mở lại"]="Tap Dynamic Island to reopen",
["Chào mừng đến xNgọtStudio"]="Welcome to xNgọtStudio",
["Nhấn phím để ẩn hoặc hiện cửa sổ"]="Press the shortcut to show or hide the window",
["Nhấn "]="Press ",
[" để ẩn hoặc hiện cửa sổ"]=" to show or hide the window",
["Ô nhịp 1/4"]="Track progress",
["Ngôn ngữ"]="Language",
["Tiếng Việt"]="Tiếng Việt",
["Kiểm thử"]="Test",
["Không thể tải nhạc"]="Unable to load audio",
["Âm thanh này có thể bị giới hạn quyền truy cập trong trải nghiệm hiện tại."]="This audio may not be permitted in the current experience.",
["Đang khởi tạo..."]="Initializing...",
["Khởi tạo giao diện"]="Initializing interface",
["Nạp tài nguyên"]="Loading assets",
["Đồng bộ cài đặt"]="Syncing settings",
["Hoàn tất"]="Ready",
["Chạm vào Dynamic Island để mở cửa sổ"]="Tap Dynamic Island to open the window",
["Tab Âm nhạc phát nhạc mà không cần ID"]="Play tracks from the Music tab",
["Kéo thanh tiêu đề để di chuyển cửa sổ"]="Drag the title bar to move the window",
["Bật hoặc tắt để xem thông báo"]="Toggle to preview notifications",
["Chuyển bài sau khi phát xong"]="Advance after the track ends",
["Chạm để mở / ẩn"]="Tap to show / hide",
["Chạm để đóng sớm"]="Tap to dismiss early",
["Có điều gì đó cần chú ý"]="Something needs your attention",
["Hồng"]="Pink",
["Không thể hoàn tất thao tác"]="Could not complete the action",
["Mọi thứ đã sẵn sàng"]="Everything is ready",
["Mục này sẽ được lưu ở đây"]="This item will be saved here",
["Người chơi"]="Players",
["Ngọc"]="Teal",
["Nhân vật"]="Character",
["Nhập rồi nhấn Enter…"]="Type, then press Enter…",
["Thao tác"]="Actions",
["Thông báo thử"]="Test notification",
["Tin nhắn"]="Message",
["Tin nhắn mới"]="New message",
["Tím"]="Purple",
["Tăng FPS trên máy yếu"]="Improve FPS on low-end devices",
["Tắt đi thì chạm vào đảo để đóng"]="When disabled, tap the island to close",
["Vòng "]="Lap ",
["Xanh dương"]="Blue",
["Xanh lá"]="Green",
["Xoá các vùng tối trên bản đồ"]="Remove dark areas from the map",
["Đây là một thông báo thử"]="This is a test notification",
["Đã bật"]="Enabled",
["Đã tắt"]="Disabled",
["Đã xảy ra lỗi"]="An error occurred",
["Độ trong suốt cửa sổ"]="Window transparency",
["Độ trễ"]="Ping",
["Không thể tải nhạc"]="Unable to load audio",
[" để ẩn hoặc hiện"]=" to show or hide",
}
local EN_VI={}
for vi,en in pairs(VI_EN)do
if EN_VI[en]==nil then
EN_VI[en]=vi
end
end
local Extra={
En={
["Tìm chức năng…"]="Search features…",
["Không tìm thấy chức năng"]="No matching features",
["Thử một từ khoá khác"]="Try a different keyword",
["Mở tab"]="Open tab",
["Nút"]="Button",
["Tuỳ chọn"]="Option",
["Màu sắc"]="Color",
["Tiến trình"]="Progress",
["Bài hát"]="Track",
["Xáo trộn"]="Shuffle",
["Phát ngẫu nhiên khi chuyển bài"]="Pick a random track when advancing",
["Lặp bài"]="Repeat",
["Lặp một bài"]="Repeat one",
["Phát lại bài hiện tại khi kết thúc"]="Replay the current track when it ends",
["Bass"]="Bass",
["Không gian"]="Spatial",
["Thêm hiệu ứng vang cho nhạc"]="Add reverb to the music",
["Enter để mở  ·  Esc để đóng"]="Enter to open  ·  Esc to close",
["Dựng lớp kính"]="Building glass layers",
["Tài khoản"]="Account",
["Phiên đăng nhập"]="Session",
["Đăng xuất"]="Sign out",
["Đăng xuất?"]="Sign out?",
["Cài đặt đã được lưu theo tài khoản. Bạn cần đăng nhập lại để dùng tiếp."]="Your settings are saved to this account. Sign in again to keep using xNgọtStudio.",
["Đăng nhập"]="Sign in",
["Đăng ký"]="Sign up",
["Tạo tài khoản"]="Create account",
["Đăng nhập để tiếp tục"]="Sign in to continue",
["Tạo tài khoản mới"]="Create a new account",
["Tên tài khoản"]="Username",
["Mật khẩu"]="Password",
["Nhập lại mật khẩu"]="Confirm password",
["Hiện"]="Show",
["Ẩn"]="Hide",
["Thoát"]="Quit",
["Đang xác thực…"]="Verifying…",
["Nhập tên tài khoản"]="Enter your username",
["Tên tài khoản cần từ 3 đến 20 ký tự"]="Username must be 3 to 20 characters",
["Chỉ dùng chữ, số và dấu gạch dưới"]="Use only letters, numbers and underscores",
["Nhập mật khẩu"]="Enter your password",
["Mật khẩu cần từ 6 ký tự"]="Password needs at least 6 characters",
["Mật khẩu nhập lại không khớp"]="Passwords do not match",
["Tên tài khoản đã tồn tại"]="That username is already taken",
["Sai tên tài khoản hoặc mật khẩu"]="Wrong username or password",
["Thử lại sau %d giây"]="Try again in %d seconds",
["Đăng nhập thành công"]="Signed in successfully",
["Đã tạo tài khoản"]="Account created",
["Phiên đăng nhập đã hết hạn"]="Your session has expired",
["Đã đăng xuất"]="Signed out",
["Đã đăng nhập"]="Signed in",
["Mỗi lần đăng nhập dùng được 5 ngày"]="One sign-in lasts 5 days",
["Executor không lưu được file, đăng nhập chỉ giữ trong phiên này"]="This executor cannot save files, so sign-in only lasts for this session",
["%d ngày %d giờ"]="%d days %d hr",
["%d giờ %d phút"]="%d hr %d min",
["%d phút"]="%d min",
["Nửa đêm"]="Midnight",
["Đại dương"]="Ocean",
["Rừng xanh"]="Forest",
["Cà phê"]="Mocha",
["Giữ nhân vật hoạt động để không bị kick khi đứng yên"]="Keeps your character active so you are not kicked for idling",
["Trạng thái"]="Status",
["Đang bảo vệ"]="Protecting",
["Đang tắt"]="Turned off",
["Lần chặn kick"]="Kicks prevented",
["Đã giữ bạn hoạt động, không bị kick"]="Kept you active so you were not kicked",
["Playlist Pastefy"]="Pastefy Playlist",
["Đang tải danh sách phát…"]="Loading playlist…",
["Không tải được danh sách phát"]="Could not load the playlist",
["Danh sách phát trống"]="The playlist is empty",
["Cần writefile và getcustomasset để phát nhạc tải về"]="Needs writefile and getcustomasset to play downloaded music",
["%d bài hát · tải về khi phát lần đầu"]="%d tracks · downloaded on first play",
["Đang tải bài hát…"]="Downloading track…",
["Tải lại"]="Reload",
["Đang tải"]="Loading",
["Liên kết Discord"]="Link Discord",
["Tạm ngừng"]="Pause",
["Đang mở"]="Open",
["Đã đóng"]="Closed",
["Đã dừng"]="Stopped",
["Tiếp tục"]="Resume",
["Đồng hồ"]="Clock",
["Hiện ping trên đảo"]="Show ping on the island",
["Hiển thị độ trễ mạng ngay trên đảo"]="Show network latency right on the island",
["Hiện đồng hồ trên đảo"]="Show the clock on the island",
["Hiển thị giờ hiện tại ngay trên đảo"]="Show the current time right on the island",
["Mở rộng đảo"]="Expandable island",
["Nhấn giữ hoặc chuột phải vào đảo để mở bảng điều khiển"]="Press and hold or right-click the island to open its controls",
["Đảo tách đôi"]="Split island",
["Hoạt động thứ hai hiện thành bong bóng cạnh đảo"]="A second activity appears as a bubble beside the island",
["Ánh sáng viền"]="Edge light",
["Vệt sáng chạy quanh viền đảo"]="A highlight that glides around the island edge",
["Chưa liên kết tài khoản Discord"]="No Discord account linked",
["Đã liên kết"]="Linked",
["Chưa liên kết"]="Not linked",
["ID %s · webhook sẵn sàng"]="ID %s · webhook ready",
["ID %s · chưa có webhook"]="ID %s · no webhook yet",
["ID %s · executor thiếu hàm request"]="ID %s · executor lacks request",
["ID Discord"]="Discord ID",
["ID người dùng, 17–20 chữ số"]="User ID, 17–20 digits",
["Dán URL webhook của kênh Discord"]="Paste your Discord channel webhook URL",
["Liên kết"]="Link",
["Hủy liên kết"]="Unlink",
["Chuyển thông báo"]="Forward notifications",
["Gửi thông báo của xNgọt Studio sang kênh Discord"]="Send xNgọtStudio notifications to your Discord channel",
["Báo phiên đăng nhập"]="Report sessions",
["Gửi tin khi đăng nhập, đăng xuất hoặc hết hạn"]="Post a message on sign-in, sign-out or expiry",
["Đã liên kết Discord"]="Discord linked",
["Đã lưu ID Discord"]="Discord ID saved",
["Hủy liên kết Discord?"]="Unlink Discord?",
["Tài khoản này sẽ không còn nhận thông báo qua Discord."]="This account will no longer receive notifications on Discord.",
["Cần hàm request, http_request hoặc syn.request"]="Needs request, http_request or syn.request",
["Thông báo của xNgọt Studio sẽ được gửi tới kênh này"]="xNgọtStudio notifications will be sent to this channel",
["Chưa có webhook nên chưa gửi được tin"]="No webhook yet, so nothing can be sent",
["ID Discord không hợp lệ"]="Invalid Discord ID",
["Cần 17–20 chữ số"]="Needs 17–20 digits",
["Webhook Discord không hợp lệ"]="Invalid Discord webhook",
["Dán URL dạng discord.com/api/webhooks/…"]="Paste a URL like discord.com/api/webhooks/…",
["Không xác thực được webhook"]="Could not verify the webhook",
["Kiểm tra URL hoặc kết nối mạng"]="Check the URL or your connection",
["Executor không hỗ trợ gửi tới Discord"]="This executor cannot send to Discord",
["Thiếu hàm request nên chỉ lưu ID"]="The request function is missing, so only the ID was saved",
["Chưa có webhook để gửi"]="No webhook to send to",
["Đã gửi tới Discord"]="Sent to Discord",
["Không gửi được tới Discord"]="Could not send to Discord",
["Đã hủy liên kết Discord"]="Discord unlinked",
["Tin nhắn thử từ xNgọtStudio"]="Test message from xNgọtStudio",
["Kết nối Discord hoạt động bình thường"]="Your Discord connection works",
["Tài khoản đã đăng nhập"]="Account signed in",
["Phiên đăng nhập được khôi phục"]="Session resumed",
["Tài khoản đã đăng xuất"]="Account signed out",
["Đã thêm %d bài hát"]="Added %d tracks",
["Không thể tải bài hát"]="Could not download the track",
["Kiểm tra kết nối hoặc executor"]="Check your connection or executor",
["Trợ lý AI"]="AI Assistant",
["Bật Cross"]="Enable Cross",
["Trợ lý AI: trò chuyện, chỉnh giao diện, điều khiển nhân vật"]="AI assistant: chat, tweak the interface, control your character",
["Kiểu hoạt động"]="Type",
["Tích hợp sẵn · chạy offline"]="Built-in · runs offline",
["Cách gọi"]="How to call",
["Gõ cross hoặc giữ đảo"]="Type cross or hold the island",
["Trò chuyện"]="Chat",
["Xoá"]="Clear",
["Gửi"]="Send",
["Nhắn cho Cross…"]="Message Cross…",
["Chưa có tin nhắn. Thử nói: ê Cross, trời nóng quá làm UI mát xíu coi"]="No messages yet. Try saying: hey Cross, it's so hot, make the UI cooler",
["Quyền của Cross"]="Cross permissions",
["Chỉnh giao diện"]="Edit the interface",
["Cho phép Cross đổi giao diện, cài đặt, tab và cửa sổ"]="Let Cross change the theme, settings, tabs and window",
["Điều khiển nhân vật"]="Control the character",
["Cho phép Cross đi, nhảy, xoay nhân vật"]="Let Cross walk, jump and spin your character",
["Tự chơi tự do"]="Free play",
["Cho phép Cross tự đi dạo, nhảy và né vật cản"]="Let Cross wander, jump and dodge obstacles by itself",
["Gọi bằng phím"]="Call with a key",
["Gõ cross trên bàn phím để mở Cross"]="Type cross on your keyboard to open Cross",
["Gợi ý lệnh"]="Command ideas",
["Ê Cross, trời nóng quá, làm UI mát xíu coi"]="Hey Cross, it's so hot, make the UI cooler",
["Bật nhạc đi"]="Play some music",
["Đặt tốc độ chạy 60"]="Set walk speed to 60",
["Hẹn giờ 2 phút"]="Timer 2 minutes",
["Anti AFK dùng sao?"]="How do I use Anti AFK?",
["Nhảy 2 lần"]="Jump twice",
["Tự chơi đi"]="Play by yourself",
["Hoàn tác"]="Undo",
["Cross đang tắt"]="Cross is off",
["Bật Cross ở phía trên để thử lệnh này"]="Turn Cross on above to try this command",
},
Vi={},
}
for vi,en in pairs(Extra.En)do
Extra.Vi[en]=vi
end
local function orderedKeys(mapping)
local keys={}
for key in pairs(mapping)do
table.insert(keys,key)
end
table.sort(keys,function(a,b)
return#a>#b
end)
return keys
end
local VI_KEYS=orderedKeys(VI_EN)
local EN_KEYS=orderedKeys(EN_VI)
local function replacePlain(source,needle,replacement)
if needle==""then
return source
end
local chunks={}
local cursor=1
while true do
local first,last=string.find(source,needle,cursor,true)
if not first then
table.insert(chunks,string.sub(source,cursor))
break
end
table.insert(chunks,string.sub(source,cursor,first-1))
table.insert(chunks,replacement)
cursor=last+1
end
return table.concat(chunks)
end
local function translate(value)
if type(value)~="string"then
return value
end
local mapping=Settings.Language=="en"and VI_EN or EN_VI
local keys=Settings.Language=="en"and VI_KEYS or EN_KEYS
if mapping[value]then
return mapping[value]
end
local extra=Settings.Language=="en"and Extra.En or Extra.Vi
if extra[value]then
return extra[value]
end
local result=value
for _,key in ipairs(keys)do
if string.find(result,key,1,true)then
result=replacePlain(result,key,mapping[key])
end
end
return result
end
local State={
Ready=false,
Open=false,
}
local Metrics={
Fps=60,
Ping=0,
}
local P={}
for key,value in pairs(Palettes[1])do
P[key]=value
end
P.Accent=Accents[1][2]
local Fwd,Isl,Spr={},{},{}
local function tween(obj,duration,props,style,direction)
local info=TweenInfo.new(duration,style or Enum.EasingStyle.Quint,direction or Enum.EasingDirection.Out)
local playing=TweenService:Create(obj,info,props)
playing:Play()
return playing
end
local function new(class,props,children)
local inst=Instance.new(class)
local parent
for key,value in pairs(props or{})do
if key=="Parent"then
parent=value
else
inst[key]=value
end
end
for _,child in ipairs(children or{})do
child.Parent=inst
end
if parent then
inst.Parent=parent
end
return inst
end
local painted={}
local paletteListeners={}
local function paint(inst,prop,role)
inst[prop]=P[role]
table.insert(painted,{inst,prop,role})
end
local function refreshPalette(duration)
local info=TweenInfo.new(duration,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
for _,item in ipairs(painted)do
TweenService:Create(item[1],info,{[item[2]]=P[item[3]]}):Play()
end
for _,listener in ipairs(paletteListeners)do
listener(duration)
end
end
local function applyTheme(index)
Settings.Theme=index
for key,value in pairs(Palettes[index])do
P[key]=value
end
refreshPalette(0.4)
end
local function applyAccent(index)
Settings.Accent=index
P.Accent=Accents[index][2]
refreshPalette(0.3)
end
local function corner(radius,parent)
return new("UICorner",{CornerRadius=UDim.new(0,radius),Parent=parent})
end
local function stroke(parent,color,transparency,thickness)
local line=new("UIStroke",{
Transparency=transparency,
Thickness=thickness or 1,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=parent,
})
if type(color)=="string"then
paint(line,"Color",color)
else
line.Color=color
end
return line
end
local function text(props)
local role=props.Role
props.Role=nil
props.BackgroundTransparency=1
props.BorderSizePixel=0
if type(props.Text)=="string"then
props.Text=translate(props.Text)
end
if type(props.PlaceholderText)=="string"then
props.PlaceholderText=translate(props.PlaceholderText)
end
props.FontFace=props.FontFace or Fonts.Medium
props.TextSize=props.TextSize or 14
local fixed=props.TextColor3
local label=new("TextLabel",props)
if not fixed then
paint(label,"TextColor3",role or"Text")
end
return label
end
local function box(props)
local class=props.Class or"Frame"
local role=props.Role
props.Class=nil
props.Role=nil
props.BorderSizePixel=0
local inst=new(class,props)
if role then
paint(inst,"BackgroundColor3",role)
end
return inst
end
local Glass={}
local Search={Index={},Open=false,Count=0}
function Search.Add(row,kind,title,desc,action)
Search.Count=Search.Count+1
table.insert(Search.Index,{
Row=row,
Kind=kind,
Title=title,
Desc=desc,
Action=action,
Order=Search.Count,
})
end
function Glass.Skin(frame,transparency,tint)
frame.BackgroundTransparency=transparency
new("UIGradient",{
Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Static.White),
ColorSequenceKeypoint.new(0.42,rgb(238,241,250)),
ColorSequenceKeypoint.new(1,tint or rgb(204,210,228)),
}),
Rotation=90,
Parent=frame,
})
local rim=new("UIStroke",{
Color=Static.White,
Thickness=1,
Transparency=0,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=frame,
})
new("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,0.2),
NumberSequenceKeypoint.new(0.3,0.82),
NumberSequenceKeypoint.new(0.7,0.93),
NumberSequenceKeypoint.new(1,0.42),
}),
Rotation=55,
Parent=rim,
})
return rim
end
function Glass.Band(parent,height)
local band=new("Frame",{
Name="GlassBand",
Size=UDim2 .new(1,0,0,height),
BackgroundColor3=Static.White,
BorderSizePixel=0,
ZIndex=0,
Parent=parent,
})
new("UIGradient",{
Transparency=NumberSequence.new(0.84,1),
Rotation=90,
Parent=band,
})
return band
end
function Glass.Rim(parent,radius)
local rim=new("Frame",{
Name="GlassRim",
Position=UDim2 .fromOffset(2,2),
Size=UDim2 .new(1,-4,1,-4),
BackgroundTransparency=1,
BorderSizePixel=0,
ZIndex=30,
Parent=parent,
})
new("UICorner",{CornerRadius=UDim.new(0,math.max(radius-2,2)),Parent=rim})
local line=new("UIStroke",{
Color=Static.White,
Thickness=1.5,
Transparency=0,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=rim,
})
local gradient=new("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,0.12),
NumberSequenceKeypoint.new(0.3,0.88),
NumberSequenceKeypoint.new(0.62,0.94),
NumberSequenceKeypoint.new(1,0.32),
}),
Rotation=45,
Parent=line,
})
return rim,gradient
end
function Glass.Mark(parent,size,fresh)
local tile=new("Frame",{
Name="Mark",
Size=UDim2 .fromOffset(size,size),
BackgroundColor3=Static.White,
BorderSizePixel=0,
Parent=parent,
})
local radius=math.floor(size*0.3)
new("UICorner",{CornerRadius=UDim.new(0,radius),Parent=tile})
new("UIGradient",{
Color=fresh and ColorSequence.new({
ColorSequenceKeypoint.new(0,rgb(98,162,255)),
ColorSequenceKeypoint.new(0.5,rgb(104,92,240)),
ColorSequenceKeypoint.new(1,rgb(58,36,140)),
})or ColorSequence.new(rgb(118,192,255),rgb(158,100,255)),
Rotation=fresh and 55 or 38,
Parent=tile,
})
new("UIStroke",{
Color=Static.White,
Thickness=1,
Transparency=0.72,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=tile,
})
local gloss=new("Frame",{
Position=UDim2 .fromOffset(1,1),
Size=UDim2 .new(1,-2,0.52,0),
BackgroundColor3=Static.White,
BorderSizePixel=0,
Parent=tile,
})
new("UICorner",{CornerRadius=UDim.new(0,math.max(radius-1,2)),Parent=gloss})
new("UIGradient",{
Transparency=NumberSequence.new(0.55,1),
Rotation=90,
Parent=gloss,
})
if fresh then
local stemWidth=size*0.12
local stem=new("Frame",{
Position=UDim2 .fromOffset(size*0.3,size*0.17),
Size=UDim2 .fromOffset(stemWidth,size*0.64),
BackgroundColor3=Static.White,
BorderSizePixel=0,
Parent=tile,
})
new("UICorner",{CornerRadius=UDim.new(0,stemWidth/2),Parent=stem})
local bowl=new("Frame",{
Position=UDim2 .fromOffset(size*0.42,size*0.49),
Size=UDim2 .fromOffset(size*0.2,size*0.2),
BackgroundTransparency=1,
BorderSizePixel=0,
Parent=tile,
})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=bowl})
new("UIStroke",{
Color=Static.White,
Thickness=stemWidth,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=bowl,
})
local spark=new("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .fromOffset(size*0.74,size*0.25),
Size=UDim2 .fromOffset(size*0.11,size*0.11),
BackgroundColor3=rgb(120,230,255),
BorderSizePixel=0,
Parent=tile,
})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=spark})
return tile
end
local thickness=math.max(2,size*0.075)
local ring=new("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .fromScale(0.5,0.5),
Size=UDim2 .fromOffset(size*0.5,size*0.5),
BackgroundTransparency=1,
BorderSizePixel=0,
Parent=tile,
})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=ring})
new("UIStroke",{
Color=Static.White,
Thickness=thickness,
Transparency=0.35,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=ring,
})
local core=new("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .fromScale(0.5,0.5),
Size=UDim2 .fromOffset(size*0.14,size*0.14),
BackgroundColor3=Static.White,
BorderSizePixel=0,
Parent=tile,
})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=core})
local orbit=size*0.25+thickness/2
local satellite=new("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,orbit*0.7071,0.5,-orbit*0.7071),
Size=UDim2 .fromOffset(size*0.17,size*0.17),
BackgroundColor3=Static.White,
BorderSizePixel=0,
Parent=tile,
})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=satellite})
return tile
end
function Glass.Decorate(parent,radius)
local layer=new("Frame",{
Name="GlassLayer",
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
BorderSizePixel=0,
ZIndex=0,
Parent=parent,
})
local sheen=new("Frame",{
Name="Sheen",
Size=UDim2 .fromScale(1,1),
BackgroundColor3=Static.White,
BorderSizePixel=0,
Parent=layer,
})
Glass.Sheen=new("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,1),
NumberSequenceKeypoint.new(0.32,1),
NumberSequenceKeypoint.new(0.45,0.93),
NumberSequenceKeypoint.new(0.52,0.88),
NumberSequenceKeypoint.new(0.6,0.94),
NumberSequenceKeypoint.new(0.72,1),
NumberSequenceKeypoint.new(1,1),
}),
Rotation=28,
Parent=sheen,
})
Glass.Band(layer,120)
local caustic=new("Frame",{
Name="Caustic",
Size=UDim2 .fromScale(1,1),
BackgroundColor3=Static.White,
BorderSizePixel=0,
Parent=layer,
})
Glass.Caustic=new("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,1),
NumberSequenceKeypoint.new(0.16,1),
NumberSequenceKeypoint.new(0.34,0.96),
NumberSequenceKeypoint.new(0.42,0.91),
NumberSequenceKeypoint.new(0.5,0.96),
NumberSequenceKeypoint.new(0.68,1),
NumberSequenceKeypoint.new(1,1),
}),
Rotation=-34,
Parent=caustic,
})
local depth=new("Frame",{
Name="Depth",
AnchorPoint=Vector2 .new(0,1),
Position=UDim2 .fromScale(0,1),
Size=UDim2 .new(1,0,0,150),
BackgroundColor3=Static.Black,
BorderSizePixel=0,
Parent=layer,
})
new("UIGradient",{
Transparency=NumberSequence.new(1,0.92),
Rotation=90,
Parent=depth,
})
local _,rimGradient=Glass.Rim(parent,radius)
Glass.RimGradient=rimGradient
Glass.Layer=layer
end
function Glass.Step()
if not Glass.Layer or not Glass.Layer.Parent then
return
end
local clock=os.clock()
Glass.Sheen.Offset=Vector2 .new(math.sin(clock*0.3)*0.5,0)
if Glass.Caustic then
Glass.Caustic.Offset=Vector2 .new(math.cos(clock*0.21+1.3)*0.55,math.sin(clock*0.17)*0.2)
end
if Glass.RimGradient then
Glass.RimGradient.Rotation=45+math.sin(clock*0.5)*32
end
end
local Spring={}
Spring.__index=Spring
local activeSprings={}
function Spring.new(initial,stiffness,damping,callback,epsilon)
local self=setmetatable({},Spring)
self.Value=initial
self.Target=initial
self.Velocity=0
self.Stiffness=stiffness
self.Damping=damping
self.Callback=callback
self.Epsilon=epsilon or 0.01
callback(initial)
return self
end
function Spring:Set(target)
self.Target=target
activeSprings[self]=true
end
function Spring:Snap(value)
self.Value=value
self.Target=value
self.Velocity=0
activeSprings[self]=nil
self.Callback(value)
end
local function stepSprings(dt)
dt=math.min(dt,1/20)
local steps=math.max(1,math.ceil(dt/(1/120)))
local h=dt/steps
local list={}
for spring in pairs(activeSprings)do
table.insert(list,spring)
end
for _,spring in ipairs(list)do
local value=spring.Value
local velocity=spring.Velocity
for _=1,steps do
local acceleration=spring.Stiffness*(spring.Target-value)-spring.Damping*velocity
velocity=velocity+acceleration*h
value=value+velocity*h
end
if math.abs(spring.Target-value)<spring.Epsilon and math.abs(velocity)<spring.Epsilon*8 then
value=spring.Target
velocity=0
activeSprings[spring]=nil
end
spring.Value=value
spring.Velocity=velocity
spring.Callback(value)
end
end
local gui=new("Frame",{
Name="xNgotStudio_FullDynamicIsland",
BackgroundTransparency=1,
BorderSizePixel=0,
Position=UDim2 .fromScale(0,0),
Size=UDim2 .fromScale(1,1),
ZIndex=100,
Visible=false,
Parent=__hostGui,
})
local blur=new("BlurEffect",{Name="xNgotStudio_FullIslandBlur",Size=0,Parent=Lighting})
Fwd.applyLanguage=function()
for _,item in ipairs(gui:GetDescendants())do
if item:IsA("TextLabel")or item:IsA("TextButton")or item:IsA("TextBox")then
if not item:GetAttribute("BoncutiRaw")then
local translationKey=item:GetAttribute("BoncutiTranslationKey")
if translationKey then
item.Text=string.upper(translate(translationKey))
else
item.Text=translate(item.Text)
end
end
if item:IsA("TextBox")then
item.PlaceholderText=translate(item.PlaceholderText)
end
end
end
if Fwd.musicLanguage then
Fwd.musicLanguage()
end
if Fwd.afkLanguage then
Fwd.afkLanguage()
end
if Fwd.discordLanguage then
Fwd.discordLanguage()
end
end
gui.Destroying:Connect(function()
for _,connection in ipairs(connections)do
connection:Disconnect()
end
table.clear(connections)
table.clear(activeSprings)
blur:Destroy()
end)
local Hooks={}
track(RunService.RenderStepped:Connect(function(dt)
if dt>0 then
Metrics.Fps=Metrics.Fps+(1/dt-Metrics.Fps)*0.06
end
stepSprings(dt)
if Hooks.Frame then
Hooks.Frame(dt)
end
end))
local playSound
local sfxReverb
do
local SFX={
Click="rbxasset://sounds/button.wav",
Tick="rbxasset://sounds/switch.wav",
Ping="rbxasset://sounds/electronicpingshort.wav",
Fast="rbxasset://sounds/clickfast.wav",
Snap="rbxasset://sounds/snap.wav",
}
local Voices={
tick={{"Tick",1.9,0.5,0}},
click={{"Fast",1.2,0.6,0},{"Ping",2.2,0.14,0.02}},
slide={{"Tick",1.5,0.22,0}},
on={{"Tick",1.6,0.55,0},{"Ping",2.1,0.22,0.035}},
off={{"Tick",1.15,0.5,0},{"Ping",1.45,0.16,0.035}},
open={{"Tick",1.3,0.45,0},{"Ping",1.25,0.3,0.03},{"Ping",1.88,0.26,0.1}},
close={{"Ping",1.7,0.26,0},{"Ping",1.15,0.26,0.08}},
success={{"Ping",1,0.5,0},{"Ping",1.26,0.46,0.085},{"Ping",1.5,0.46,0.17}},
info={{"Ping",1.12,0.45,0},{"Ping",1.68,0.38,0.1}},
warn={{"Ping",0.86,0.5,0},{"Ping",0.86,0.5,0.14}},
error={{"Ping",0.92,0.55,0},{"Ping",0.69,0.6,0.11}},
welcome={{"Ping",1,0.4,0},{"Ping",1.26,0.4,0.11},{"Ping",1.5,0.4,0.22},{"Ping",2,0.46,0.35}},
}
local Gaps={slide=0.05,tick=0.04}
local sfxGroup=new("SoundGroup",{Name="BoncutiSFX",Volume=1,Parent=SoundService})
sfxReverb=new("ReverbSoundEffect",{
DecayTime=1.2,
Density=0.75,
Diffusion=0.85,
DryLevel=0,
WetLevel=-10,
Parent=sfxGroup,
})
new("EqualizerSoundEffect",{LowGain=-8,MidGain=0,HighGain=3,Parent=sfxGroup})
gui.Destroying:Connect(function()
sfxGroup:Destroy()
end)
local lastPlayed={}
local function emit(id,speed,volume,delay)
local function fire()
if not Settings.Sound or not gui.Parent then
return
end
local sound=new("Sound",{
SoundId=SFX[id],
PlaybackSpeed=speed,
Volume=math.clamp(volume*Settings.Volume/100*1.6,0,1),
SoundGroup=sfxGroup,
Parent=gui,
})
sound:Play()
Debris:AddItem(sound,3)
end
if delay and delay>0 then
task.delay(delay,fire)
else
fire()
end
end
function playSound(name,pitch)
if not Settings.Sound then
return
end
local voice=Voices[name]
if not voice then
return
end
local now=os.clock()
if lastPlayed[name]and now-lastPlayed[name]<(Gaps[name]or 0.03)then
return
end
lastPlayed[name]=now
for _,part in ipairs(voice)do
emit(part[1],part[2]*(pitch or 1),part[3],part[4])
end
end
end
local ISLAND={
IdleW=100,
LiveW=158,
H=30,
AlertH=62,
Top=8,
Ring=2,
MediaW=212,
MediaH=38,
ExpandW=340,
ExpandH=192,
ExpandR=38,
Gap=8,
Bubble=30,
}
local islandState={W=ISLAND.IdleW,H=ISLAND.H,R=15,Y=-70,X=0,Bubble=0,Base=1,Hover=1,Dirty=true}
local Media={}
local Ring={
Visible=false,
Dirty=true,
Progress=1,
Source=nil,
Mode="drain",
Token=0,
Segments={},
}
Ring.Holder=new("Frame",{
Name="IslandRing",
AnchorPoint=Vector2 .new(0.5,0),
Position=UDim2 .new(0.5,0,0,-70),
Size=UDim2 .fromOffset(ISLAND.IdleW,ISLAND.H),
BackgroundTransparency=1,
ZIndex=49,
Parent=gui,
})
Ring.Scale=new("UIScale",{Parent=Ring.Holder})
Ring.Glow={}
Ring.GlowSpread={2,5,9,14,20}
Ring.GlowBase={0.80,0.87,0.915,0.945,0.965}
Ring.GlowLit={0.66,0.78,0.86,0.90,0.94}
for index,spread in ipairs(Ring.GlowSpread)do
local glow=new("Frame",{
Name="IslandShadow"..tostring(index),
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0.5,0),
Size=UDim2 .new(1,spread*2,1,spread*2),
BackgroundColor3=Static.Black,
BackgroundTransparency=Ring.GlowBase[index],
BorderSizePixel=0,
ZIndex=48,
Parent=Ring.Holder,
})
Ring.Glow[index]=glow
Ring.GlowCorner=Ring.GlowCorner or{}
Ring.GlowCorner[index]=corner(0,glow)
end
function Ring.layoutGlow(radius)
radius=math.max(tonumber(radius)or 15,0)
for index,glow in ipairs(Ring.Glow)do
local spread=Ring.GlowSpread[index]
glow.Size=UDim2 .new(1,spread*2,1,spread*2)
local holder=Ring.GlowCorner[index]
if holder then
holder.CornerRadius=UDim.new(0,radius+spread)
end
end
end
Ring.layoutGlow(15)
do
local track_=new("Frame",{
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
Parent=Ring.Holder,
})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=track_})
Ring.TrackStroke=new("UIStroke",{
Thickness=ISLAND.Ring,
Color=Static.White,
Transparency=1,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=track_,
})
for index=1,5 do
local clip=new("Frame",{
BackgroundTransparency=1,
ClipsDescendants=true,
Parent=Ring.Holder,
})
local full=new("Frame",{BackgroundTransparency=1,Parent=clip})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=full})
local line=new("UIStroke",{
Thickness=ISLAND.Ring,
Color=Static.White,
Transparency=1,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=full,
})
local vertical=index==2 or index==4
local mask=new("UIGradient",{Rotation=vertical and 90 or 0,Parent=line})
Ring.Segments[index]={Clip=clip,Full=full,Line=line,Mask=mask}
end
end
Isl.islandFrame=new("Frame",{
Name="DynamicIsland",
AnchorPoint=Vector2 .new(0.5,0),
Position=UDim2 .new(0.5,0,0,-70),
Size=UDim2 .fromOffset(ISLAND.IdleW,ISLAND.H),
BackgroundColor3=Static.White,
BorderSizePixel=0,
ClipsDescendants=true,
ZIndex=50,
Parent=gui,
})
Isl.islandCorner=corner(15,Isl.islandFrame)
new("UIGradient",{
Color=ColorSequence.new(rgb(30,30,35),rgb(2,2,4)),
Rotation=90,
Parent=Isl.islandFrame,
})
Isl.islandRim=stroke(Isl.islandFrame,Static.White,0,1)
Isl.rimGradient=new("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,0.58),
NumberSequenceKeypoint.new(0.2,0.9),
NumberSequenceKeypoint.new(0.5,0.97),
NumberSequenceKeypoint.new(0.8,0.9),
NumberSequenceKeypoint.new(1,0.58),
}),
Rotation=90,
Parent=Isl.islandRim,
})
Isl.islandScale=new("UIScale",{Parent=Isl.islandFrame})
Media.Content=new("CanvasGroup",{
Name="Content",
BackgroundTransparency=1,
Size=UDim2 .fromScale(1,1),
Parent=Isl.islandFrame,
})
Media.ContentCorner=corner(15,Media.Content)
Isl.tint=box({
AnchorPoint=Vector2 .new(0,1),
Position=UDim2 .fromScale(0,1),
Size=UDim2 .fromScale(1,0.9),
BackgroundColor3=Static.Blue,
BackgroundTransparency=1,
Parent=Media.Content,
})
new("UIGradient",{
Transparency=NumberSequence.new(1,0.66),
Rotation=90,
Parent=Isl.tint,
})
Isl.gloss=box({
Size=UDim2 .fromScale(1,0.52),
BackgroundColor3=Static.White,
Parent=Media.Content,
})
new("UIGradient",{
Transparency=NumberSequence.new(0.86,1),
Rotation=90,
Parent=Isl.gloss,
})
Media.Shine=box({
Size=UDim2 .fromScale(1,1),
BackgroundColor3=Static.White,
Parent=Media.Content,
})
Media.ShineGradient=new("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,1),
NumberSequenceKeypoint.new(0.4,1),
NumberSequenceKeypoint.new(0.5,0.84),
NumberSequenceKeypoint.new(0.6,1),
NumberSequenceKeypoint.new(1,1),
}),
Rotation=20,
Offset=Vector2 .new(-1,0),
Parent=Media.Shine,
})
function Isl.layoutIsland()
local scale=islandState.Base*islandState.Hover
local shift=-(ISLAND.Bubble+ISLAND.Gap)/2*math.clamp(islandState.Bubble,0,1)*islandState.Base
islandState.X=shift
Isl.islandFrame.Size=UDim2 .fromOffset(islandState.W,islandState.H)
Isl.islandFrame.Position=UDim2 .new(0.5,shift,0,islandState.Y)
Isl.islandCorner.CornerRadius=UDim.new(0,math.max(islandState.R,0))
if Ring.layoutGlow then
Ring.layoutGlow(math.max(islandState.R,0))
end
Media.ContentCorner.CornerRadius=Isl.islandCorner.CornerRadius
Isl.islandScale.Scale=scale
Ring.Holder.Size=UDim2 .fromOffset(islandState.W,islandState.H)
Ring.Holder.Position=UDim2 .new(0.5,shift,0,islandState.Y)
Ring.Scale.Scale=scale
Ring.Dirty=true
if Fwd.islandLayout then
Fwd.islandLayout(scale,shift)
end
end
Spr.springIslandW=Spring.new(ISLAND.IdleW,300,24,function(value)
islandState.W=value
islandState.Dirty=true
end,0.05)
Spr.springIslandH=Spring.new(ISLAND.H,340,26,function(value)
islandState.H=value
islandState.Dirty=true
end,0.05)
Spr.springIslandR=Spring.new(15,300,30,function(value)
islandState.R=value
islandState.Dirty=true
end,0.05)
Spr.springIslandY=Spring.new(-70,240,20,function(value)
islandState.Y=value
islandState.Dirty=true
end,0.05)
Spr.springIslandHover=Spring.new(1,420,26,function(value)
islandState.Hover=value
islandState.Dirty=true
end,0.0005)
Spr.springBubble=Spring.new(0,240,15,function(value)
islandState.Bubble=value
islandState.Dirty=true
end,0.002)
function Isl.bubbleTo(target)
Spr.springBubble.Damping=target>0 and 14 or 30
Spr.springBubble:Set(target)
end
Isl.idleGroup=new("CanvasGroup",{
Name="Idle",
BackgroundTransparency=1,
Size=UDim2 .fromScale(1,1),
Parent=Media.Content,
})
new("UIListLayout",{
FillDirection=Enum.FillDirection.Horizontal,
HorizontalAlignment=Enum.HorizontalAlignment.Center,
VerticalAlignment=Enum.VerticalAlignment.Center,
SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,6),
Parent=Isl.idleGroup,
})
Isl.idleDot=box({
Size=UDim2 .fromOffset(7,7),
BackgroundColor3=Static.Green,
LayoutOrder=1,
Parent=Isl.idleGroup,
})
corner(4,Isl.idleDot)
text({
Text="xNgọtStudio",
FontFace=Fonts.Semibold,
TextSize=12,
TextColor3=Static.White,
AutomaticSize=Enum.AutomaticSize.X,
Size=UDim2 .fromOffset(0,14),
LayoutOrder=2,
Parent=Isl.idleGroup,
})
Isl.liveGroup=new("CanvasGroup",{
Name="Live",
BackgroundTransparency=1,
GroupTransparency=1,
Size=UDim2 .fromScale(1,1),
Parent=Media.Content,
})
Isl.liveDot=box({
Position=UDim2 .fromOffset(12,11),
Size=UDim2 .fromOffset(8,8),
BackgroundColor3=Static.Orange,
Parent=Isl.liveGroup,
})
corner(4,Isl.liveDot)
Isl.liveTitle=text({
Position=UDim2 .fromOffset(26,0),
Size=UDim2 .new(0.5,-26,1,0),
Text="",
FontFace=Fonts.Medium,
TextSize=11,
TextColor3=Static.LightGray,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
Parent=Isl.liveGroup,
})
Isl.liveValue=text({
AnchorPoint=Vector2 .new(1,0),
Position=UDim2 .new(1,-13,0,0),
Size=UDim2 .new(0.5,-8,1,0),
Text="",
FontFace=Fonts.Semibold,
TextSize=12,
TextColor3=Static.White,
TextXAlignment=Enum.TextXAlignment.Right,
TextTruncate=Enum.TextTruncate.AtEnd,
Parent=Isl.liveGroup,
})
Isl.alertGroup=new("CanvasGroup",{
Name="Alert",
BackgroundTransparency=1,
GroupTransparency=1,
Size=UDim2 .fromScale(1,1),
Parent=Media.Content,
})
Isl.alertGlow=box({
Size=UDim2 .fromScale(1,1),
BackgroundColor3=Static.Blue,
Parent=Isl.alertGroup,
})
new("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,0.7),
NumberSequenceKeypoint.new(0.6,1),
NumberSequenceKeypoint.new(1,1),
}),
Parent=Isl.alertGlow,
})
Isl.alertIcon=box({
AnchorPoint=Vector2 .new(0,0.5),
Position=UDim2 .new(0,10,0.5,0),
Size=UDim2 .fromOffset(26,26),
BackgroundColor3=Static.Blue,
Parent=Isl.alertGroup,
})
corner(13,Isl.alertIcon)
Isl.alertGlyph=text({
Size=UDim2 .fromScale(1,1),
Text="i",
FontFace=Fonts.Bold,
TextSize=14,
TextColor3=Static.White,
Parent=Isl.alertIcon,
})
Isl.alertTitle=text({
AnchorPoint=Vector2 .new(0,0.5),
Position=UDim2 .new(0,44,0.5,-8),
Size=UDim2 .new(1,-56,0,16),
Text="",
FontFace=Fonts.Semibold,
TextSize=13,
TextColor3=Static.White,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
TextScaled=false,
Parent=Isl.alertGroup,
})
Isl.alertMessage=text({
AnchorPoint=Vector2 .new(0,0.5),
Position=UDim2 .new(0,44,0.5,9),
Size=UDim2 .new(1,-56,0,14),
Text="",
FontFace=Fonts.Regular,
TextSize=12,
TextColor3=Static.LightGray,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
TextScaled=false,
Parent=Isl.alertGroup,
})
Isl.alertIconScale=new("UIScale",{Parent=Isl.alertIcon})
Isl.alertPulse=new("Frame",{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0,23,0.5,0),
Size=UDim2 .fromOffset(26,26),
BackgroundTransparency=1,
BorderSizePixel=0,
Parent=Isl.alertGroup,
})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=Isl.alertPulse})
Isl.alertPulseStroke=new("UIStroke",{
Color=Static.Blue,
Thickness=2,
Transparency=1,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=Isl.alertPulse,
})
Isl.alertBadge=box({
AnchorPoint=Vector2 .new(1,0),
Position=UDim2 .new(1,-12,0,7),
Size=UDim2 .fromOffset(26,15),
BackgroundColor3=Static.White,
BackgroundTransparency=0.82,
Visible=false,
Parent=Isl.alertGroup,
})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=Isl.alertBadge})
Isl.alertBadgeText=text({
Size=UDim2 .fromScale(1,1),
Text="",
FontFace=Fonts.Semibold,
TextSize=10,
TextColor3=Static.White,
Parent=Isl.alertBadge,
})
Isl.alertBadgeText:SetAttribute("BoncutiRaw",true)
Spr.springAlertIcon=Spring.new(1,420,17,function(value)
Isl.alertIconScale.Scale=math.max(value,0.05)
end,0.001)
Media.Group=new("CanvasGroup",{
Name="Media",
BackgroundTransparency=1,
GroupTransparency=1,
Size=UDim2 .fromScale(1,1),
Parent=Media.Content,
})
Media.Art=box({
Position=UDim2 .fromOffset(6,6),
Size=UDim2 .fromOffset(26,26),
BackgroundColor3=Static.White,
Parent=Media.Group,
})
corner(8,Media.Art)
Media.Cover=new("ImageLabel",{
Name="Cover",
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
Image="",
ScaleType=Enum.ScaleType.Crop,
Visible=false,
ZIndex=5,
Parent=Media.Art,
})
corner(8,Media.Cover)
Media.ArtGradient=new("UIGradient",{
Color=ColorSequence.new(Static.Blue,Static.Purple),
Rotation=45,
Parent=Media.Art,
})
Media.Letter=text({
Size=UDim2 .fromScale(1,1),
Text="♪",
FontFace=Fonts.Bold,
TextSize=13,
TextColor3=Static.White,
Parent=Media.Art,
})
Media.Title=text({
Position=UDim2 .fromOffset(40,5),
Size=UDim2 .new(1,-78,0,15),
Text="",
FontFace=Fonts.Semibold,
TextSize=12,
TextColor3=Static.White,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
TextScaled=false,
Parent=Media.Group,
})
Media.Sub=text({
Position=UDim2 .fromOffset(40,20),
Size=UDim2 .new(1,-78,0,12),
Text="",
FontFace=Fonts.Regular,
TextSize=10,
TextColor3=Static.LightGray,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
TextScaled=false,
Parent=Media.Group,
})
Media.BarsFrame=new("Frame",{
AnchorPoint=Vector2 .new(1,0.5),
Position=UDim2 .new(1,-14,0.5,0),
Size=UDim2 .fromOffset(23,18),
BackgroundTransparency=1,
Parent=Media.Group,
})
Media.DlFrame=new("Frame",{
Position=UDim2 .fromOffset(6,6),
Size=UDim2 .fromOffset(26,26),
BackgroundColor3=Static.Blue,
Visible=false,
Parent=Media.Group,
})
corner(8,Media.DlFrame)
Media.DlIcon=text({
Size=UDim2 .fromScale(1,1),
Text="↓",
FontFace=Fonts.Bold,
TextSize=15,
TextColor3=Static.White,
Parent=Media.DlFrame,
})
Media.DlTrack=new("Frame",{
Position=UDim2 .new(0,40,1,-9),
Size=UDim2 .new(1,-54,0,3),
BackgroundColor3=Static.White,
BackgroundTransparency=0.78,
Visible=false,
Parent=Media.Group,
})
corner(2,Media.DlTrack)
Media.DlFill=new("Frame",{
Size=UDim2 .new(0,0,1,0),
BackgroundColor3=Static.White,
BackgroundTransparency=0.05,
Parent=Media.DlTrack,
})
corner(2,Media.DlFill)
Media.Bars={}
for index=1,5 do
local bar=box({
AnchorPoint=Vector2 .new(0,1),
Position=UDim2 .new(0,(index-1)*5,1,0),
Size=UDim2 .fromOffset(3,4),
BackgroundColor3=Static.Green,
Parent=Media.BarsFrame,
})
corner(2,bar)
Media.Bars[index]=bar
end
Isl.islandHit=new("TextButton",{
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
Text="",
ZIndex=60,
Parent=Isl.islandFrame,
})
Isl.bubble=new("Frame",{
Name="IslandBubble",
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(0.5,0,0,-70),
Size=UDim2 .fromOffset(ISLAND.Bubble,ISLAND.Bubble),
BackgroundColor3=Static.White,
BorderSizePixel=0,
Visible=false,
ZIndex=50,
Parent=gui,
})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=Isl.bubble})
new("UIGradient",{
Color=ColorSequence.new(rgb(30,30,35),rgb(2,2,4)),
Rotation=90,
Parent=Isl.bubble,
})
Isl.bubbleRing=stroke(Isl.bubble,Static.Green,0.1,1.5)
Isl.bubbleScale=new("UIScale",{Scale=0.01,Parent=Isl.bubble})
Isl.bubbleText=text({
Size=UDim2 .fromScale(1,1),
Text="",
FontFace=Fonts.Semibold,
TextSize=10,
TextTruncate=Enum.TextTruncate.AtEnd,
TextColor3=Static.White,
ZIndex=51,
Parent=Isl.bubble,
})
Isl.bubbleText:SetAttribute("BoncutiRaw",true)
Isl.bubbleHit=new("TextButton",{
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
Text="",
ZIndex=60,
Parent=Isl.bubble,
})
function Ring.ringMask(t,after)
if t<=0.002 then
return NumberSequence.new(after and 0 or 1)
elseif t>=0.998 then
return NumberSequence.new(after and 1 or 0)
end
local high=math.min(t+0.002,1)
if after then
return NumberSequence.new({
NumberSequenceKeypoint.new(0,1),
NumberSequenceKeypoint.new(t,1),
NumberSequenceKeypoint.new(high,0),
NumberSequenceKeypoint.new(1,0),
})
end
return NumberSequence.new({
NumberSequenceKeypoint.new(0,0),
NumberSequenceKeypoint.new(t,0),
NumberSequenceKeypoint.new(high,1),
NumberSequenceKeypoint.new(1,1),
})
end
function Ring.updateRing()
local width=islandState.W
local height=islandState.H
local radius=height/2
local straight=math.max(width-height,0)
local half=straight/2
local arc=math.pi*radius
local total=half*2+arc*2+straight
local fill=Ring.Mode=="fill"
local used=(fill and Ring.Progress or 1-Ring.Progress)*total
local margin=ISLAND.Ring+2
local starts={0,half,half+arc,half+arc+straight,half+arc*2+straight}
local lengths={half,arc,straight,arc,half}
local boxes={
{width/2,-margin,half,radius+margin},
{width-radius,-margin,radius+margin,height+margin*2},
{radius,radius,straight,radius+margin},
{-margin,-margin,radius+margin,height+margin*2},
{radius,-margin,half,radius+margin},
}
for index=1,5 do
local segment=Ring.Segments[index]
local length=lengths[index]
local f
if length>0.01 then
f=math.clamp((used-starts[index])/length,0,1)
else
f=fill and 0 or 1
end
local hidden=(fill and f<=0)or(not fill and f>=1)
segment.Clip.Visible=not hidden
if not hidden then
local b=boxes[index]
segment.Clip.Position=UDim2 .fromOffset(b[1],b[2])
segment.Clip.Size=UDim2 .fromOffset(b[3],b[4])
segment.Full.Position=UDim2 .fromOffset(-b[1],-b[2])
segment.Full.Size=UDim2 .fromOffset(width,height)
local threshold,after
if index==1 then
threshold=(width/2+f*half)/width
after=true
elseif index==2 then
threshold=radius*(1-math.cos(f*math.pi))/height
after=true
elseif index==3 then
threshold=(width-radius-f*straight)/width
after=false
elseif index==4 then
threshold=radius*(1+math.cos(f*math.pi))/height
after=false
else
threshold=(radius+f*half)/width
after=true
end
if fill then
after=not after
end
segment.Mask.Transparency=Ring.ringMask(threshold,after)
end
end
end
function Ring.ringGlow(color)
for index,glow in ipairs(Ring.Glow)do
tween(glow,0.35,{
BackgroundColor3=color or Static.Black,
BackgroundTransparency=(color and Ring.GlowLit or Ring.GlowBase)[index],
})
end
end
function Ring.ringShow(color,source,mode)
if not Settings.Ring then
return
end
Ring.Token=Ring.Token+1
Ring.Source=source
Ring.Mode=mode or"drain"
Ring.Progress=math.clamp(source and source()or 1,0,1)
if not Ring.Visible then
for _,segment in ipairs(Ring.Segments)do
segment.Line.Color=color
end
Ring.TrackStroke.Color=color
end
Ring.Visible=true
Ring.ringGlow(color)
for _,segment in ipairs(Ring.Segments)do
tween(segment.Line,0.3,{Color=color,Transparency=0})
end
tween(Ring.TrackStroke,0.3,{Color=color,Transparency=0.86})
Ring.updateRing()
end
function Ring.ringHide()
if not Ring.Visible then
return
end
Ring.Source=nil
Ring.Token=Ring.Token+1
local token=Ring.Token
for _,segment in ipairs(Ring.Segments)do
tween(segment.Line,0.25,{Transparency=1})
end
tween(Ring.TrackStroke,0.25,{Transparency=1})
Ring.ringGlow(nil)
task.delay(0.32,function()
if Ring.Token==token then
Ring.Visible=false
end
end)
end
Hooks.Tasks={}
Hooks.Stride={}
function Hooks.Register(fn,stride)
local index=#Hooks.Tasks+1
Hooks.Tasks[index]=fn
Hooks.Stride[index]=math.max(tonumber(stride)or 1,1)
return index
end
Hooks.Register(function()
local phase=(os.clock()%7)/1.5
Media.ShineGradient.Offset=Vector2 .new(phase<1 and(2*phase-1)or-1,0)
end,3)
Hooks.Frame=function(dt)
Hooks.FrameTick=(Hooks.FrameTick or 0)+1
local visible=gui.Visible and islandState.Base>0.02
if islandState.Dirty then
islandState.Dirty=false
Isl.layoutIsland()
end
if Ring.Visible then
if Ring.Source then
local value=math.clamp(Ring.Source(),0,1)
if math.abs(value-Ring.Progress)>0.0005 then
Ring.Progress=value
Ring.Dirty=true
end
end
if Ring.Dirty then
Ring.Dirty=false
Ring.updateRing()
end
end
if not visible then
return
end
local heaviest=Island and Island.Expanded
for index=1,#Hooks.Tasks do
local task_=Hooks.Tasks[index]
local stride=Hooks.Stride and Hooks.Stride[index]or 1
if stride<=1 or heaviest or Hooks.FrameTick%stride==0 then
task_(dt*stride)
end
end
end
local KINDS={
success={Static.Green,"✓"},
info={Static.Blue,"i"},
warn={Static.Orange,"!"},
error={Static.Red,"×"},
}
local Island={
Queue={},
Busy=false,
Alerting=false,
Skip=false,
Live=nil,
Key=nil,
Pin=nil,
Expanded=false,
Pressing=false,
HoldDone=false,
PressToken=0,
}
Isl.groupShown=Isl.groupShown or{}
function Isl.showGroup(group,visible,duration)
if not group then return end
visible=visible and true or false
Isl.groupShown[group]=visible
local target=visible and 0 or 1
local current=tonumber(group.GroupTransparency)or 0
if math.abs(current-target)<0.02 then
group.GroupTransparency=target
return
end
tween(group,duration or 0.25,{GroupTransparency=target})
end
function Isl.onlyGroup(visibleGroup,duration)
for _,group in ipairs({Isl.idleGroup,Isl.liveGroup,Media.Group,Isl.alertGroup})do
if group then
Isl.showGroup(group,group==visibleGroup,duration)
end
end
end
function Isl.setIslandMode(mode,width,height)
if mode=="expand"then
Spr.springIslandW:Set(width or ISLAND.ExpandW)
Spr.springIslandH:Set(height or ISLAND.ExpandH)
Spr.springIslandR:Set(ISLAND.ExpandR)
elseif mode=="alert"then
Spr.springIslandW:Set(width)
Spr.springIslandH:Set(ISLAND.AlertH)
Spr.springIslandR:Set(ISLAND.AlertH/2)
elseif mode=="media"then
Spr.springIslandW:Set(ISLAND.MediaW)
Spr.springIslandH:Set(ISLAND.MediaH)
Spr.springIslandR:Set(ISLAND.MediaH/2)
elseif mode=="live"then
Spr.springIslandW:Set(ISLAND.LiveW)
Spr.springIslandH:Set(ISLAND.H)
Spr.springIslandR:Set(ISLAND.H/2)
else
Spr.springIslandW:Set(ISLAND.IdleW)
Spr.springIslandH:Set(ISLAND.H)
Spr.springIslandR:Set(ISLAND.H/2)
end
end
local settleToken=0
function Isl.settleIsland()
settleToken=settleToken+1
local token=settleToken
task.defer(function()
if token==settleToken then
Isl.settleIslandNow()
end
end)
end
function Isl.settleIslandNow()
if Island.Expanded then
if Fwd.islandSync then
Fwd.islandSync()
end
return
end
local live=Island.Live
if live and live.Ring then
Ring.ringShow(live.Color,live.Ring,live.RingMode)
elseif not Island.Alerting then
Ring.ringHide()
end
if Island.Alerting then
Isl.onlyGroup(Isl.alertGroup,0.12)
elseif live then
local media=live.Media and true or false
Isl.setIslandMode(media and"media"or"live")
Isl.onlyGroup(media and Media.Group or Isl.liveGroup,0.28)
else
Isl.setIslandMode("idle")
Isl.onlyGroup(Isl.idleGroup,0.28)
end
if Fwd.islandSync then
Fwd.islandSync()
end
end
function Isl.pop(amount)
Spr.springIslandHover:Set(1+(amount or 0.05))
task.delay(0.1,function()
Spr.springIslandHover:Set(1)
end)
end
function Isl.effects(kind,color)
Spr.springAlertIcon:Snap(0.3)
Spr.springAlertIcon:Set(1)
Isl.alertPulseStroke.Color=color
Isl.alertPulseStroke.Transparency=0.15
Isl.alertPulse.Size=UDim2 .fromOffset(26,26)
tween(Isl.alertPulse,0.7,{Size=UDim2 .fromOffset(58,58)},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
tween(Isl.alertPulseStroke,0.7,{Transparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
Isl.alertGlow.BackgroundTransparency=0.5
tween(Isl.alertGlow,0.9,{BackgroundTransparency=0},Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
if kind=="error"then
task.spawn(function()
for _,dx in ipairs({7,-6,5,-4,2,0})do
Media.Content.Position=UDim2 .fromOffset(dx,0)
task.wait(0.045)
end
end)
elseif kind=="warn"then
task.spawn(function()
for _,angle in ipairs({-16,13,-9,5,0})do
Isl.alertIcon.Rotation=angle
task.wait(0.06)
end
end)
end
end
Isl.mediaText={Title=ISLAND.MediaW-81,Sub=ISLAND.MediaW-81}
Isl.liveText={Title=math.floor(ISLAND.LiveW*0.5)-26,Value=math.floor(ISLAND.LiveW*0.5)-8}
function Isl.pushAlert(title,message,kind,duration)
title=tostring(title or""):gsub("%s+$","")
message=tostring(message or""):gsub("%s+$","")
local last=Island.Queue[#Island.Queue]
if last and last.title==title then
last.message=message
last.kind=kind or last.kind
last.duration=duration or last.duration
return false
end
if Island.Alerting and Island.Current and Island.Current.title==title then
Isl.alertMessage.Text=translate(message)
return false
end
local item={title=title,message=message,kind=kind or"info",duration=duration}
Island.Queue[#Island.Queue+1]=item
return true
end
function Isl.measureAlert(title,message)
local titleWidth,messageWidth=0,0
local ok,sizes=pcall(function()
return TextService:GetTextSize(title,14,Enum.Font.GothamSemibold,Vector2 .new(1000,40)).X,
TextService:GetTextSize(message,12,Enum.Font.Gotham,Vector2 .new(1000,40)).X
end)
if ok then
titleWidth,messageWidth=sizes,select(2,pcall(function()
return TextService:GetTextSize(message,12,Enum.Font.Gotham,Vector2 .new(1000,40)).X
end))
end
titleWidth=tonumber(titleWidth)or 0
messageWidth=tonumber(messageWidth)or 0
local wanted=math.max(titleWidth,messageWidth)+78
wanted=math.max(wanted,230)
return math.min(wanted,330)
end
function Isl.playAlert(item)
local style=KINDS[item.kind]or KINDS.info
if Island.Expanded and Isl.collapse then
Isl.collapse(true,true)
end
local waiting=#Island.Queue
Isl.alertIcon.BackgroundColor3=style[1]
Isl.alertGlow.BackgroundColor3=style[1]
Isl.alertGlyph.Text=style[2]
Island.Current=item
local alertW=Isl.measureAlert(item.title,item.message)
Isl.alertWidth=alertW
local titleBox=alertW-44-16
if type(Isl.fitText)=="function"then
Isl.alertTitle.Text=Isl.fitText(translate(item.title),nil,titleBox,"GothamSemibold",13)
Isl.alertMessage.Text=Isl.fitText(translate(item.message),nil,titleBox,"Gotham",12)
else
Isl.alertTitle.Text=translate(item.title)
Isl.alertMessage.Text=translate(item.message)
end
Island.Alerting=true
Island.Skip=false
Isl.alertBadge.Visible=waiting>0
Isl.alertBadgeText.Text="+"..waiting
Isl.bubbleTo(0)
tween(Isl.tint,0.35,{BackgroundColor3=style[1],BackgroundTransparency=0})
Isl.showGroup(Isl.idleGroup,false,0.12)
Isl.showGroup(Isl.liveGroup,false,0.12)
Isl.showGroup(Media.Group,false,0.12)
Isl.showGroup(Isl.alertGroup,false,0.12)
Isl.setIslandMode("alert",alertW+(waiting>0 and 34 or 0))
Isl.pop(0.06)
playSound(item.kind)
task.wait(0.14)
Isl.showGroup(Isl.alertGroup,true,0.28)
Isl.effects(item.kind,style[1])
local hold=item.duration
local started=os.clock()
Ring.ringShow(style[1],function()
if hold then
return 1-(os.clock()-started)/hold
end
return 1
end)
while not Island.Skip and(not hold or os.clock()-started<hold)do
local pending=#Island.Queue
if Isl.alertBadge.Visible~=(pending>0)then
Isl.alertBadge.Visible=pending>0
end
if pending>0 then
local label="+"..pending
if Isl.alertBadgeText.Text~=label then
Isl.alertBadgeText.Text=label
end
end
task.wait(0.03)
end
Isl.alertBadge.Visible=false
Island.Alerting=false
Ring.ringHide()
Isl.showGroup(Isl.alertGroup,false,0.16)
task.wait(0.32)
end
function Isl.runQueue()
if Island.Busy then
return
end
if Island.Expanded then
if Isl.drainToToast then
Isl.drainToToast()
end
return
end
Island.Busy=true
task.spawn(function()
while#Island.Queue>0 do
local item=table.remove(Island.Queue,1)
Isl.playAlert(item)
end
Isl.settleIsland()
Island.Busy=false
if#Island.Queue>0 then
Isl.runQueue()
end
end)
end
local History={}
local function notify(title,message,kind,duration,localOnly)
if History.Add then
History.Add(title,message,kind or"info")
end
if not localOnly and Fwd.discordForward then
pcall(Fwd.discordForward,title,message,kind or"info")
end
if#Island.Queue>=4 then
table.remove(Island.Queue,1)
end
local added=Isl.pushAlert(title,message,kind or"info",
Settings.AutoHide and(duration or Settings.Duration)or nil)
if added then
Isl.runQueue()
end
end
Isl.islandHit.MouseEnter:Connect(function()
if UserInputService:GetLastInputType()~=Enum.UserInputType.Touch then Spr.springIslandHover:Set(1.05)end
end)
Isl.islandHit.MouseLeave:Connect(function()
Spr.springIslandHover:Set(1)
end)
Isl.islandHit.MouseButton1Down:Connect(function()
Spr.springIslandHover:Set(0.94)
end)
Isl.islandHit.MouseButton1Up:Connect(function()
Spr.springIslandHover:Set(UserInputService:GetLastInputType()~=Enum.UserInputType.Touch and UserInputService.MouseEnabled and 1.05 or 1)
end)
Isl.islandHit.MouseButton1Click:Connect(function()
if not State.Ready then
return
end
if Island.HoldDone then
Island.HoldDone=false
return
end
if Island.Alerting then
Island.Skip=true
else
Fwd.setWindow(not State.Open)
end
end)
task.spawn(function()
while gui.Parent do
if Settings.Breathe then
tween(Isl.idleDot,1,{BackgroundTransparency=0.65},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
task.wait(1)
tween(Isl.idleDot,1,{BackgroundTransparency=0},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
task.wait(1)
else
tween(Isl.idleDot,0.3,{BackgroundTransparency=0})
task.wait(0.5)
end
end
end)
local Activities={}
local ACTIVITY_ORDER={"Music","Download","Cross","Timer","Gameplay","Stopwatch","Fps","Ping","Clock"}
local downloadValue=0
local liveShown=""
local function refreshActivity()
local current,currentKey
if Island.Pin and Activities[Island.Pin]then
current,currentKey=Activities[Island.Pin],Island.Pin
else
Island.Pin=nil
for _,key in ipairs(ACTIVITY_ORDER)do
if Activities[key]then
current,currentKey=Activities[key],key
break
end
end
end
Island.Live=current
Island.Key=currentKey
if current then
tween(Isl.liveDot,0.3,{BackgroundColor3=current.Color})
local half=math.floor(ISLAND.LiveW*0.5)
local fit=Isl.fitText
if type(fit)=="function"then
Isl.liveTitle.Text=fit(translate(current.Title),Isl.liveTitle,half-30,"Gotham",11)
liveShown=current.Value()
Isl.liveValue.Text=fit(translate(liveShown),Isl.liveValue,half-10,"GothamMedium",12)
else
Isl.liveTitle.Text=translate(current.Title)
liveShown=current.Value()
Isl.liveValue.Text=translate(liveShown)
end
end
if not Island.Busy then
if Island.Alerting then
task.delay(0.45,function()
if not Island.Alerting and not Island.Busy then
Isl.settleIsland()
end
end)
else
Isl.settleIsland()
end
end
if Fwd.islandSync then
Fwd.islandSync()
end
end
local function startTimer(seconds)
local timer={
Title="Hẹn giờ",
Color=Static.Orange,
Finish=os.clock()+seconds,
Total=seconds,
RingMode="drain",
}
timer.Value=function()
local remaining=math.max(0,math.ceil(timer.Finish-os.clock()))
return string.format("%d:%02d",math.floor(remaining/60),remaining%60)
end
timer.Short=timer.Value
timer.Ring=function()
return(timer.Finish-os.clock())/timer.Total
end
Activities.Timer=timer
refreshActivity()
notify("Bắt đầu hẹn giờ",string.format("%d %s",seconds,translate("giây")),"info",1.6)
end
local function extendTimer(extra)
local timer=Activities.Timer
if timer then
timer.Finish=timer.Finish+extra
timer.Total=timer.Total+extra
end
end
local function stopTimer()
if Activities.Timer then
Activities.Timer=nil
refreshActivity()
notify("Đã dừng hẹn giờ","Hoạt động đã được gỡ khỏi đảo","info",1.6)
end
end
local stopwatchToggle,stopwatchLap,stopwatchReset
do
local Stopwatch={Running=false,Elapsed=0,Started=0,Laps=0}
local function stopwatchElapsed()
if Stopwatch.Running then
return Stopwatch.Elapsed+os.clock()-Stopwatch.Started
end
return Stopwatch.Elapsed
end
local function stopwatchText()
local total=stopwatchElapsed()
return string.format("%02d:%02d.%02d",math.floor(total/60),math.floor(total%60),math.floor(total*100%100))
end
function stopwatchToggle()
if Stopwatch.Running then
Stopwatch.Elapsed=stopwatchElapsed()
Stopwatch.Running=false
if Activities.Stopwatch then
Activities.Stopwatch.Title="Tạm dừng"
end
else
Stopwatch.Started=os.clock()
Stopwatch.Running=true
if not Activities.Stopwatch then
Activities.Stopwatch={
Title="Bấm giờ",
Color=Static.Purple,
Value=stopwatchText,
Short=function()
local total=stopwatchElapsed()
return string.format("%d:%02d",math.floor(total/60),math.floor(total%60))
end,
Ring=function()
return stopwatchElapsed()%60/60
end,
RingMode="fill",
}
end
Activities.Stopwatch.Title="Bấm giờ"
end
refreshActivity()
end
function stopwatchLap()
if Activities.Stopwatch then
Stopwatch.Laps=Stopwatch.Laps+1
Activities.Stopwatch.Lap={Index=Stopwatch.Laps,Text=stopwatchText()}
notify("Vòng "..Stopwatch.Laps,stopwatchText(),"info",1.8)
end
end
function stopwatchReset()
Stopwatch.Running=false
Stopwatch.Elapsed=0
Stopwatch.Laps=0
if Activities.Stopwatch then
Activities.Stopwatch=nil
refreshActivity()
end
end
end
local function setFpsActivity(on)
if on then
local value=function()
return string.format("%d",math.floor(Metrics.Fps+0.5))
end
Activities.Fps={
Title="FPS",
Color=Static.Green,
Value=value,
Short=value,
}
else
Activities.Fps=nil
end
refreshActivity()
end
local function setPingActivity(on)
if on then
local value=function()
return string.format("%d ms",Metrics.Ping)
end
Activities.Ping={
Title="Ping",
Color=rgb(100,210,255),
Value=value,
Short=function()
return string.format("%d",Metrics.Ping)
end,
}
else
Activities.Ping=nil
end
refreshActivity()
end
local function setClockActivity(on)
if on then
local value=function()
return os.date("%H:%M")
end
Activities.Clock={
Title="Đồng hồ",
Color=Static.Gray,
Value=value,
Short=value,
}
else
Activities.Clock=nil
end
refreshActivity()
end
task.spawn(function()
while gui.Parent do
local ok,ping=pcall(function()
return player:GetNetworkPing()*1000
end)
if ok and type(ping)=="number"then
Metrics.Ping=math.clamp(math.floor(ping+0.5),0,9999)
end
task.wait(2)
end
end)
task.spawn(function()
while gui.Parent do
local timer=Activities.Timer
if timer and os.clock()>=timer.Finish then
Activities.Timer=nil
refreshActivity()
notify("Hết giờ","Hẹn giờ đã kết thúc","warn",3)
end
task.wait(0.2)
end
end)
Hooks.Register(function()
local live=Island.Live
if live then
local value=live.Value()
if value~=liveShown then
liveShown=value
Isl.liveValue.Text=translate(value)
end
end
end,3)
local Cross={
Enabled=false,
Mood="neutral",
MoodUntil=0,
SpeakUntil=0,
Thinking=false,
Acting=false,
Lang="vi",
Chat={},
ChatVersion=0,
Shell={Lines={},Version=0},
Bubble={Full="",Shown="",Count=0,Rate=54},
Echo="",
Faces={},
Shells={},
MarkText="",
Pose={},
Target={},
Perm={Ui=true,Body=false,Free=false,Key=true},
Busy=0,
Idle="neutral",
Inputs={},
}
do
local HEAD=rgb(17,19,27)
local PINK=rgb(255,112,146)
local DROP=rgb(120,200,255)
local SHADE=rgb(6,7,10)
local HEART=rgb(255,96,128)
local NEUTRAL={
eyeW=1,eyeH=1,lidB=0,lidT=0,tilt=0,browY=0,browTilt=0,browA=0,
smile=0.35,mouthW=0.34,open=0,cheek=0,shade=0,heart=0,sweat=0,
gx=0,gy=0,winkR=0,markA=0,
}
local MOODS={
neutral={},
happy={lidB=0.58,smile=0.95,cheek=0.55,mouthW=0.38},
joy={lidB=0.62,smile=1,cheek=0.85,mouthW=0.46,open=0.38},
think={gx=0.9,gy=-0.9,smile=0,browA=0.85,browY=0.6,browTilt=-8,mouthW=0.2,eyeH=0.92,mark="…"},
sad={lidT=0.34,tilt=-17,smile=-0.85,browA=0.9,browTilt=-15,browY=0.1,mouthW=0.26,eyeH=0.95},
angry={lidT=0.36,tilt=17,smile=-0.55,browA=0.9,browTilt=16,browY=-0.4,mouthW=0.3},
surprised={eyeW=1.2,eyeH=1.32,open=0.85,mouthW=0.2,browA=0.9,browY=1,smile=0,mark="!"},
love={lidB=0.5,smile=0.95,cheek=0.95,heart=1,mouthW=0.38},
sleepy={lidT=0.62,smile=0.1,mouthW=0.2,browA=0,mark="z"},
wink={lidB=0.15,winkR=0.8,smile=0.95,cheek=0.4,mouthW=0.4},
cool={shade=1,smile=0.75,mouthW=0.38},
sweat={lidT=0.2,smile=-0.4,sweat=1,mouthW=0.3,browA=0.85,browTilt=11},
confused={gx=-0.7,smile=-0.2,browA=0.9,browTilt=13,mouthW=0.22,mark="?"},
listen={eyeW=1.1,eyeH=1.14,smile=0.25,browA=0.55,browY=0.7},
}
for key,value in pairs(NEUTRAL)do
Cross.Pose[key]=value
Cross.Target[key]=value
end
Cross.Pose.open=0
local blink={Next=2,Start=-10,Value=0}
local wander={Next=1,X=0,Y=0,CX=0,CY=0}
local openSmooth=0
local clock=0
local lastAccent
local glow=Static.White
function Cross.setMood(name,hold)
local def=MOODS[name]or MOODS.neutral
Cross.Mood=MOODS[name]and name or"neutral"
for key,value in pairs(NEUTRAL)do
local target=def[key]
Cross.Target[key]=target~=nil and target or value
end
Cross.MarkText=def.mark or Cross.MarkText
Cross.Target.markA=def.mark and 1 or 0
Cross.MoodUntil=hold and hold>0 and os.clock()+hold or 0
end
function Cross.speak(seconds)
Cross.SpeakUntil=os.clock()+math.clamp(seconds,0.6,7)
end
local function prefix(source,count)
local length=utf8 .len(source)
if not length then
return string.sub(source,1,count)
end
if count>=length then
return source
end
if count<=0 then
return""
end
return string.sub(source,1,utf8 .offset(source,count+1)-1)
end
Cross.prefix=prefix
function Cross.length(source)
return utf8 .len(source)or#source
end
function Cross.say(role,value)
local previous=Cross.Bubble.Entry
if previous then
previous.Shown=previous.Text
end
local entry={Role=role,Text=value,Shown=role=="cross"and""or value,At=os.clock()}
table.insert(Cross.Chat,entry)
if#Cross.Chat>60 then
table.remove(Cross.Chat,1)
end
Cross.ChatVersion=Cross.ChatVersion+1
if role=="cross"then
Cross.Bubble.Full=value
Cross.Bubble.Count=0
Cross.Bubble.Shown=""
Cross.Bubble.Entry=entry
Cross.speak(Cross.length(value)/Cross.Bubble.Rate+0.4)
else
Cross.Echo=value
end
return entry
end
local function hex(color)
return string.format("%02X%02X%02X",math.floor(color.R*255+0.5),math.floor(color.G*255+0.5),math.floor(color.B*255+0.5))
end
local function escape(source)
source=string.gsub(source,"&","&amp;")
source=string.gsub(source,"<","&lt;")
source=string.gsub(source,">","&gt;")
return source
end
Cross.escape=escape
local COLORS={
prompt="EEEDF0",
cmd="FFEB64",
arg="64DCE6",
out="C8D3E6",
ok="50FA7B",
warn="FFC46B",
err="FF6B6B",
dim="7C8CA8",
}
Cross.ShellColors=COLORS
function Cross.renderLine(line,cursor)
local parts={}
local left=line.Shown or math.huge
for _,segment in ipairs(line.Segs)do
if left<=0 then
break
end
local value=segment[1]
local length=Cross.length(value)
if length>left then
value=prefix(value,left)
left=0
else
left=left-length
end
parts[#parts+1]=string.format('<font color="#%s">%s</font>',segment[2],escape(value))
end
if cursor then
parts[#parts+1]='<font color="#EEEDF0">_</font>'
end
return table.concat(parts)
end
function Cross.shellAdd(segments,typed)
local line={Segs=segments,Shown=typed and 0 or nil}
table.insert(Cross.Shell.Lines,line)
if#Cross.Shell.Lines>80 then
table.remove(Cross.Shell.Lines,1)
end
Cross.Shell.Version=Cross.Shell.Version+1
return line
end
function Cross.shellTouch()
Cross.Shell.Version=Cross.Shell.Version+1
end
function Cross.shellText(kind,value)
local width=46
local color=COLORS[kind]or COLORS.out
local first=true
local words={}
for word in string.gmatch(value,"%S+")do
words[#words+1]=word
end
local current=""
local function flush()
Cross.shellAdd({{(first and""or"  ")..current,color}})
first=false
current=""
end
for _,word in ipairs(words)do
if current==""then
current=word
elseif Cross.length(current)+1+Cross.length(word)>width then
flush()
current=word
else
current=current.." "..word
end
end
if current~=""then
flush()
end
end
local function makeLabel(parent,props)
props.BackgroundTransparency=1
props.BorderSizePixel=0
props.Parent=parent
return new("TextLabel",props)
end
local codeFace=Fonts.Medium
pcall(function()
codeFace=Font.fromEnum(Enum.Font.Code)
end)
function Cross.buildShell(parent,props)
local rows=props.Rows or 8
local textSize=props.TextSize or 11
local lineHeight=props.LineHeight or 14
local frame=box({
Name="CrossShell",
Position=props.Position,
Size=props.Size,
BackgroundColor3=rgb(1,36,86),
ClipsDescendants=true,
ZIndex=props.ZIndex or 5,
Parent=parent,
})
corner(props.Radius or 10,frame)
stroke(frame,Static.White,0.86,1)
local header=makeLabel(frame,{
Name="Header",
Position=UDim2 .fromOffset(10,5),
Size=UDim2 .new(1,-20,0,14),
Text="Windows PowerShell · cross@xNgọtStudio",
FontFace=codeFace,
TextSize=10,
TextColor3=rgb(138,160,200),
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=(props.ZIndex or 5)+1,
})
header:SetAttribute("BoncutiRaw",true)
local labels={}
for index=1,rows do
local label=makeLabel(frame,{
Name="Line"..index,
Position=UDim2 .fromOffset(10,22+(index-1)*lineHeight),
Size=UDim2 .new(1,-20,0,lineHeight),
Text="",
FontFace=codeFace,
TextSize=textSize,
TextColor3=rgb(238,237,240),
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
RichText=true,
ZIndex=(props.ZIndex or 5)+1,
})
label:SetAttribute("BoncutiRaw",true)
labels[index]=label
end
local shell={Frame=frame,Labels=labels,Rows=rows,Version=-1,Cursor=false,Active=props.Active}
function shell.Refresh(force,cursor)
if not force and shell.Version==Cross.Shell.Version and shell.Cursor==cursor then
return
end
shell.Version=Cross.Shell.Version
shell.Cursor=cursor
local lines=Cross.Shell.Lines
local total=#lines
for index=1,rows do
local line=lines[total-rows+index]
local label=labels[index]
local value=""
if line then
value=Cross.renderLine(line,cursor and total-rows+index==total)
end
if label.Text~=value then
label.Text=value
end
end
end
table.insert(Cross.Shells,shell)
return shell
end
function Cross.buildFace(parent,size,position,props)
props=props or{}
local S=size
local z=props.ZIndex or 3
local root=new("Frame",{
Name="CrossFace",
Position=position,
Size=UDim2 .fromOffset(S,S),
BackgroundTransparency=1,
ZIndex=z,
Parent=parent,
})
local head=box({
Name="Head",
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .fromScale(0.5,0.5),
Size=UDim2 .fromScale(1,1),
BackgroundColor3=HEAD,
ZIndex=z,
Parent=root,
})
corner(S*0.3,head)
local scale=new("UIScale",{Parent=head})
local rim=stroke(head,P.Accent,0.4,1.5)
local face={Root=root,Head=head,Scale=scale,Rim=rim,Eyes={},Brows={},Cheeks={},Hearts={},Lens={},Glints={},Active=props.Active,Size=S}
for index=1,2 do
local cheek=box({
AnchorPoint=Vector2 .new(0.5,0.5),
Size=UDim2 .fromOffset(S*0.17,S*0.09),
BackgroundColor3=PINK,
BackgroundTransparency=1,
ZIndex=z+1,
Parent=head,
})
corner(S,cheek)
face.Cheeks[index]=cheek
end
for index=1,2 do
local eye=box({
Name="Eye"..index,
AnchorPoint=Vector2 .new(0.5,0.5),
Size=UDim2 .fromOffset(S*0.15,S*0.2),
BackgroundColor3=Static.White,
ClipsDescendants=true,
ZIndex=z+2,
Parent=head,
})
local round=corner(S*0.075,eye)
local lidTop=box({
AnchorPoint=Vector2 .new(0.5,1),
Size=UDim2 .fromOffset(S*0.36,S*0.2),
BackgroundColor3=HEAD,
ZIndex=z+3,
Parent=eye,
})
local lidBottom=box({
AnchorPoint=Vector2 .new(0.5,0),
Size=UDim2 .fromOffset(S*0.26,S*0.24),
BackgroundColor3=HEAD,
ZIndex=z+3,
Parent=eye,
})
new("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=lidBottom})
face.Eyes[index]={Eye=eye,Round=round,LidTop=lidTop,LidBottom=lidBottom}
local brow=box({
AnchorPoint=Vector2 .new(0.5,0.5),
Size=UDim2 .fromOffset(S*0.2,3),
BackgroundColor3=Static.White,
BackgroundTransparency=1,
ZIndex=z+2,
Parent=head,
})
corner(2,brow)
face.Brows[index]=brow
local lens=box({
AnchorPoint=Vector2 .new(0.5,0.5),
Size=UDim2 .fromOffset(S*0.3,S*0.15),
BackgroundColor3=SHADE,
BackgroundTransparency=1,
ZIndex=z+5,
Parent=head,
})
corner(S*0.05,lens)
local lensLine=stroke(lens,Static.White,1,1.5)
local glint=box({
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .fromScale(0.3,0.38),
Size=UDim2 .fromOffset(S*0.1,2),
BackgroundColor3=Static.White,
BackgroundTransparency=1,
Rotation=-28,
ZIndex=z+6,
Parent=lens,
})
face.Lens[index]={Lens=lens,Line=lensLine}
face.Glints[index]=glint
local heart=makeLabel(head,{
AnchorPoint=Vector2 .new(0.5,0.5),
Size=UDim2 .fromOffset(S*0.3,S*0.3),
Text="♥",
FontFace=Fonts.Bold,
TextSize=math.floor(S*0.24),
TextColor3=HEART,
TextTransparency=1,
ZIndex=z+6,
})
heart:SetAttribute("BoncutiRaw",true)
face.Hearts[index]=heart
end
face.Bridge=box({
AnchorPoint=Vector2 .new(0.5,0.5),
Size=UDim2 .fromOffset(S*0.1,3),
BackgroundColor3=SHADE,
BackgroundTransparency=1,
ZIndex=z+5,
Parent=head,
})
face.MouthClip=new("Frame",{
Name="Mouth",
AnchorPoint=Vector2 .new(0.5,0),
BackgroundTransparency=1,
ClipsDescendants=true,
ZIndex=z+2,
Parent=head,
})
face.MouthRing=new("Frame",{
BackgroundTransparency=1,
ZIndex=z+2,
Parent=face.MouthClip,
})
new("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=face.MouthRing})
face.MouthLine=new("UIStroke",{
Color=Static.White,
Thickness=math.max(2,S*0.035),
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=face.MouthRing,
})
face.Open=box({
AnchorPoint=Vector2 .new(0.5,0),
BackgroundColor3=Static.White,
BackgroundTransparency=1,
ZIndex=z+2,
Parent=head,
})
new("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=face.Open})
face.Sweat=box({
AnchorPoint=Vector2 .new(0.5,0),
Size=UDim2 .fromOffset(S*0.07,S*0.11),
BackgroundColor3=DROP,
BackgroundTransparency=1,
ZIndex=z+4,
Parent=head,
})
corner(S,face.Sweat)
face.Mark=makeLabel(head,{
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .fromScale(0.84,0.16),
Size=UDim2 .fromOffset(S*0.3,S*0.3),
Text="",
FontFace=Fonts.Bold,
TextSize=math.floor(S*0.22),
TextColor3=Static.White,
TextTransparency=1,
ZIndex=z+6,
})
face.Mark:SetAttribute("BoncutiRaw",true)
local gloss=box({
Name="Shine",
Size=UDim2 .fromScale(1,1),
BackgroundColor3=Static.White,
ZIndex=z+7,
Parent=head,
})
corner(S*0.3,gloss)
new("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,0.86),
NumberSequenceKeypoint.new(0.5,1),
NumberSequenceKeypoint.new(1,1),
}),
Rotation=90,
Parent=gloss,
})
table.insert(Cross.Faces,face)
return face
end
local function applyFace(face,pose,now,wx,wy,blinkValue,open)
local S=face.Size
face.Scale.Scale=1+math.sin(now*1.8)*0.012
local baseW,baseH=S*0.15,S*0.2
local gap=S*0.17
local eyeY=S*0.4
local eyeW=baseW*pose.eyeW
for index=1,2 do
local side=index==1 and-1 or 1
local part=face.Eyes[index]
local wink=index==2 and pose.winkR or 0
local height=math.max(baseH*pose.eyeH*(1-0.94*blinkValue),2)
local cx=S/2+side*gap+(pose.gx+wx)*S*0.05
local cy=eyeY+(pose.gy+wy)*S*0.045
part.Eye.Position=UDim2 .fromOffset(cx,cy)
part.Eye.Size=UDim2 .fromOffset(eyeW,height)
part.Eye.BackgroundColor3=glow
part.Eye.BackgroundTransparency=math.clamp(pose.heart*1.2,0,1)
part.Round.CornerRadius=UDim.new(0,eyeW/2)
part.LidTop.Size=UDim2 .fromOffset(eyeW*2.4,height)
part.LidTop.Position=UDim2 .fromOffset(eyeW/2,height*pose.lidT)
part.LidTop.Rotation=-side*pose.tilt
local bottom=math.clamp(pose.lidB+wink,0,1)
part.LidBottom.Size=UDim2 .fromOffset(eyeW*1.7,height*1.25)
part.LidBottom.Position=UDim2 .fromOffset(eyeW/2,height*(1-bottom*0.9))
local brow=face.Brows[index]
brow.BackgroundColor3=glow
brow.BackgroundTransparency=1-pose.browA
brow.Size=UDim2 .fromOffset(eyeW*1.35,3)
brow.Position=UDim2 .fromOffset(cx,cy-baseH*pose.eyeH/2-7-pose.browY*5)
brow.Rotation=-side*pose.browTilt
local cheek=face.Cheeks[index]
cheek.Position=UDim2 .fromOffset(S/2+side*(gap+S*0.07),S*0.6)
cheek.BackgroundTransparency=1-0.5*pose.cheek
local lens=face.Lens[index]
lens.Lens.Position=UDim2 .fromOffset(cx,cy)
lens.Lens.Size=UDim2 .fromOffset(eyeW*2.2,math.max(baseH*0.78,S*0.14))
lens.Lens.BackgroundTransparency=1-pose.shade
lens.Line.Color=glow
lens.Line.Transparency=1-0.65*pose.shade
face.Glints[index].BackgroundTransparency=1-0.55*pose.shade
local heart=face.Hearts[index]
heart.Position=UDim2 .fromOffset(cx,cy)
heart.TextColor3=HEART
heart.TextTransparency=1-pose.heart
heart.TextSize=math.floor(S*0.24*(1+0.1*math.sin(now*8)))
end
face.Bridge.Position=UDim2 .fromOffset(S/2+(pose.gx+wx)*S*0.05,eyeY+(pose.gy+wy)*S*0.045)
face.Bridge.BackgroundTransparency=1-pose.shade
local mouthY=S*0.66
local mouthW=S*pose.mouthW
local thick=math.max(2,S*0.035)
local deep=thick+math.abs(pose.smile)*S*0.09
face.MouthClip.Position=UDim2 .fromOffset(S/2,mouthY-deep/2)
face.MouthClip.Size=UDim2 .fromOffset(mouthW,deep)
local ringHeight=math.max(2*(deep-thick),0.5)
face.MouthRing.Size=UDim2 .fromOffset(math.max(mouthW-2*thick,1),ringHeight)
face.MouthRing.Position=UDim2 .fromOffset(thick,pose.smile>=0 and-(deep-thick)or thick)
face.MouthLine.Color=glow
face.MouthLine.Transparency=math.clamp(open*4,0,1)
local openHeight=S*0.025+open*S*0.2
local openWidth=mouthW*(0.5+0.35*open)
face.Open.Size=UDim2 .fromOffset(openWidth,openHeight)
face.Open.Position=UDim2 .fromOffset(S/2,mouthY-S*0.02)
face.Open.BackgroundColor3=glow
face.Open.BackgroundTransparency=1-math.clamp(open*5,0,1)
local drip=(now*0.55)%1
face.Sweat.Position=UDim2 .fromOffset(S*0.8,S*0.12+drip*S*0.16)
face.Sweat.BackgroundTransparency=1-pose.sweat*(1-drip*drip)*0.9
face.Mark.Text=Cross.MarkText
face.Mark.TextColor3=glow
face.Mark.TextTransparency=1-pose.markA
face.Mark.Position=UDim2 .fromScale(0.84,0.16+(Cross.MarkText=="z"and math.sin(now*2.2)*0.04 or 0))
end
Hooks.Register(function(dt)
clock=clock+dt
local now=os.clock()
if Cross.MoodUntil>0 and now>=Cross.MoodUntil then
Cross.setMood(Cross.Idle or"neutral")
end
local alpha=1-math.exp(-dt*11)
local pose,target=Cross.Pose,Cross.Target
for key,value in pairs(target)do
pose[key]=pose[key]+(value-pose[key])*alpha
end
local anyActive=false
for _,face in ipairs(Cross.Faces)do
if face.Active and face.Active()then
anyActive=true
end
end
local anyShell=false
for _,shell in ipairs(Cross.Shells)do
if shell.Active and shell.Active()then
anyShell=true
end
end
local bubble=Cross.Bubble
if Cross.Thinking then
local dots=string.rep(".",1+math.floor(now*3)%3)
if bubble.Shown~=dots then
bubble.Shown=dots
end
elseif bubble.Full~=""and bubble.Count<Cross.length(bubble.Full)then
bubble.Count=bubble.Count+dt*bubble.Rate
local shown=prefix(bubble.Full,math.floor(bubble.Count))
if shown~=bubble.Shown then
bubble.Shown=shown
if bubble.Entry then
bubble.Entry.Shown=shown
Cross.ChatVersion=Cross.ChatVersion+1
end
end
elseif bubble.Entry and bubble.Entry.Shown~=bubble.Entry.Text then
bubble.Shown=bubble.Full
bubble.Entry.Shown=bubble.Entry.Text
Cross.ChatVersion=Cross.ChatVersion+1
end
if anyShell then
local cursor=math.floor(now*2)%2==0
for _,shell in ipairs(Cross.Shells)do
if shell.Active and shell.Active()then
shell.Refresh(false,cursor)
end
end
end
if not anyActive then
return
end
if now>=blink.Next then
blink.Start=now
blink.Next=now+2.2+math.random()*3.2
if math.random()<0.18 then
blink.Next=now+0.32
end
end
local since=now-blink.Start
blink.Value=since>=0 and since<0.17 and math.sin(math.pi*since/0.17)or 0
if now>=wander.Next then
wander.Next=now+1.3+math.random()*2.2
wander.X=(math.random()-0.5)*1.1
wander.Y=(math.random()-0.5)*0.7
end
local calm=Cross.Mood=="neutral"or Cross.Mood=="happy"or Cross.Mood=="cool"or Cross.Mood=="listen"
local fade=1-math.exp(-dt*5)
wander.CX=wander.CX+((calm and wander.X or 0)-wander.CX)*fade
wander.CY=wander.CY+((calm and wander.Y or 0)-wander.CY)*fade
local speaking=now<Cross.SpeakUntil
local goal=Cross.Target.open
if speaking then
local talk=0.2+0.5*math.abs(math.sin(now*9.5))*(0.55+0.45*math.sin(now*2.7+1))
goal=math.max(goal,talk)
end
openSmooth=openSmooth+(goal-openSmooth)*(1-math.exp(-dt*22))
local accent=P.Accent
if accent~=lastAccent then
lastAccent=accent
glow=Color3 .new(accent.R+(1-accent.R)*0.74,accent.G+(1-accent.G)*0.74,accent.B+(1-accent.B)*0.74)
end
local anyFace=false
for _,face in ipairs(Cross.Faces)do
if face.Active and face.Active()and face.Root and face.Root.Visible then
anyFace=true
face.Rim.Color=accent
applyFace(face,pose,now,wander.CX,wander.CY,blink.Value,openSmooth)
end
end
Cross.AnyFace=anyFace
end,2)
Cross.setMood("neutral")
end
local Music={
Playing=false,
Index=1,
Volume=60,
Tempo=1,
Position=0,
Clock=0,
Phrase=0,
Auto=true,
ShowIsland=true,
Shuffle=false,
RepeatOne=false,
Fails=0,
Loading=false,
Levels={0,0,0,0,0},
Listeners={},
}
do
local TRACKS={
{Name="Lo-fi Chill A",Mood="Lo-fi / Chill",Id=9043887091,A=rgb(88,86,214),B=rgb(191,90,242)},
{Name="Relaxed Scene",Mood="Relaxing",Id=1848354536,A=rgb(64,200,224),B=rgb(10,132,255)},
{Name="Chill Jazz",Mood="Jazz / Lounge",Id=1845341094,A=rgb(255,159,10),B=rgb(255,55,95)},
{Name="Soft Music",Mood="Soft / Ambient",Id=1837429944,A=rgb(64,200,224),B=rgb(48,209,88)},
{Name="Piano Bar Jazz",Mood="Piano / Jazz",Id=1841979451,A=rgb(191,90,242),B=rgb(88,86,214)},
{Name="Smooth Vibes",Mood="Smooth Chill",Id=9044565954,A=rgb(48,209,88),B=rgb(64,200,224)},
{Name="Sunday In Bed",Mood="Lo-fi / Relax",Id=9047104336,A=rgb(255,159,10),B=rgb(191,90,242)},
{Name="Light Dreamer",Mood="Dreamy",Id=9047107124,A=rgb(10,132,255),B=rgb(191,90,242)},
{Name="Paradise Falls",Mood="Cinematic",Id=1837879082,A=rgb(48,209,88),B=rgb(10,132,255)},
{Name="Upbeat Electronica",Mood="Electronic",Id=1837849285,A=rgb(255,55,95),B=rgb(255,159,10)},
}
Music.Tracks=TRACKS
local group=new("SoundGroup",{Name="BoncutiPlaylistGroup",Volume=1,Parent=SoundService})
Music.Reverb=new("ReverbSoundEffect",{
DecayTime=1.5,
Density=0.5,
Diffusion=0.65,
DryLevel=-1,
WetLevel=-12,
Parent=group,
})
Music.Eq=new("EqualizerSoundEffect",{LowGain=1,MidGain=0,HighGain=-1,Parent=group})
local currentSound=new("Sound",{
Name="BoncutiPlaylistAudio",
SoundId="rbxassetid://"..TRACKS[1].Id,
Volume=Music.Volume/100,
PlaybackSpeed=Music.Tempo,
Looped=false,
SoundGroup=group,
Parent=SoundService,
})
local loadToken=0
local function broadcast()
for _,listener in ipairs(Music.Listeners)do
pcall(listener)
end
end
Music.Broadcast=broadcast
local TextWidthCache={}
local function measure(text,size,font)
if TextService==nil then return nil end
font=font or"Gotham"
local key=tostring(size).."|"..tostring(font).."|"..tostring(text)
if TextWidthCache[key]~=nil then return TextWidthCache[key]end
local ok,bounds=pcall(function()
local enumFont=Enum.Font[font]or Enum.Font.Gotham
return TextService:GetTextSize(text,size,enumFont,Vector2 .new(4000,400))
end)
local width=ok and bounds and bounds.X or nil
TextWidthCache[key]=width
return width
end
local function fitText(value,box,fallbackWidth,font,sizeOverride)
local raw=tostring(value or""):gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$","")
if raw==""then return""end
local width=fallbackWidth
local size=sizeOverride or 12
if box~=nil then
local okSize,current=pcall(function()return box.TextSize end)
if okSize and type(current)=="number"and current>0 then size=current end
local okAbs,abs=pcall(function()return box.AbsoluteSize.X end)
if okAbs and type(abs)=="number"and abs>24 then width=abs-6 end
end
width=math.max(tonumber(width)or 120,24)
local natural=measure(raw,size,font)
if natural and natural<=width then return raw end
local charCount=utf8 .len(raw)or#raw
local function prefixChars(count)
if count>=charCount then return raw end
if count<=0 then return""end
local okPos,pos=pcall(function()return utf8 .offset(raw,count+1)end)
if okPos and type(pos)=="number"then return raw:sub(1,pos-1)end
return raw:sub(1,count)
end
local limit=charCount
while limit>2 do
local cut=prefixChars(limit-1):gsub("%s+$","").."…"
local span=measure(cut,size,font)
if span and span<=width then return cut end
limit=limit-1
end
local budget=math.max(math.floor(width/7),6)
if charCount>budget then return prefixChars(budget-1):gsub("%s+$","").."…"end
return raw
end
Isl.fitText=fitText
Isl.measureText=measure
local function applyMedia(track,state)
track=track or{}
local downloading=state=="download"
Media.ArtGradient.Color=ColorSequence.new(track.A or Static.Blue,track.B or Static.Purple)
Media.Title.Text=fitText(track.Name or"Đang tải nhạc",Media.Title,131,"GothamMedium")
Media.Sub.Text=fitText(downloading and"Đang tải mp3…"or(track.Mood or""),Media.Sub,131,"Gotham")
for _,bar in ipairs(Media.Bars)do
bar.BackgroundColor3=track.B or Static.Purple
bar.Visible=not downloading
end
if Media.BarsFrame then
Media.BarsFrame.Visible=not downloading
end
if Media.Art then
Media.Art.Visible=not downloading
end
if Media.DlFrame then
Media.DlFrame.Visible=downloading
end
if Media.DlTrack then
Media.DlTrack.Visible=downloading
end
Media.IsDownload=downloading
if Media.Cover then
local asset=track.CoverAsset
if type(asset)=="string"and asset~=""and not downloading then
Media.Cover.Image=asset
Media.Cover.Visible=true
Media.Letter.Visible=false
else
Media.Cover.Image=""
Media.Cover.Visible=false
Media.Letter.Visible=true
if not downloading and track and CrossAIMusic and type(CrossAIMusic.thumbAsset)=="function"then
local wanted=tostring(track.Id or track.Url or track.Name or"")
task.spawn(function()
local okCover,cover=pcall(CrossAIMusic.thumbAsset,track)
if not okCover or type(cover)~="string"or cover==""then return end
track.CoverAsset=cover
local cur=TRACKS[Music.Index]
if cur and tostring(cur.Id or cur.Url or cur.Name or"")==wanted then
Media.Cover.Image=cover
Media.Cover.Visible=true
Media.Letter.Visible=false
end
end)
end
end
end
end
function Music.setDownloadState(percent,title)
local track=TRACKS[Music.Index]or{}
local alpha=math.clamp(tonumber(percent)or 0,0,1)
local shown={
A=track.A or Static.Blue,
B=track.B or Static.Purple,
Name=title or track.Name,
Mood="Đang tải mp3…",
}
applyMedia(shown,"download")
if Media.DlFill then
Media.DlFill.Size=UDim2 .new(alpha,0,1,0)
end
if Media.Title then
Media.Title.Text=fitText(alpha>=1 and"Đang phát…"or shown.Name,Media.Title,131,"GothamMedium")
end
if Media.DlIcon then
Media.DlIcon.Text=alpha>=1 and"✓"or"↓"
end
end
function Music.Progress()
local length=currentSound.TimeLength
if length<=0 then
return 0
end
return math.clamp(currentSound.TimePosition/length,0,1)
end
function Music.Sync()
local track=TRACKS[Music.Index]
Music.Position=currentSound.TimePosition
if Music.Playing and Music.ShowIsland then
Activities.Music={
Title=track.Name,
Color=track.B,
Media=true,
Short=function()
return"♪"
end,
Value=function()
return track.Name
end,
Ring=Music.Progress,
RingMode="fill",
}
else
Activities.Music=nil
end
applyMedia(track)
refreshActivity()
end
local function waitAndPlay(token,id)
task.spawn(function()
local deadline=os.clock()+12
while gui.Parent and token==loadToken and currentSound.SoundId==id and not currentSound.IsLoaded and os.clock()<deadline do
task.wait(0.1)
end
if token~=loadToken or currentSound.SoundId~=id or not gui.Parent then
return
end
if currentSound.IsLoaded then
currentSound.Volume=0
currentSound.PlaybackSpeed=Music.Tempo
currentSound:Play()
tween(currentSound,0.8,{Volume=Music.Volume/100},Enum.EasingStyle.Sine)
Music.Playing=true
Music.Fails=0
Music.Sync()
broadcast()
else
Music.Playing=false
Music.Fails=Music.Fails+1
Music.Sync()
broadcast()
notify("Không thể tải nhạc","Âm thanh này có thể bị giới hạn quyền truy cập trong trải nghiệm hiện tại.","warn",3)
if Music.Auto and Music.Fails<3 then
task.wait(0.8)
if token==loadToken and gui.Parent then
Music.Next(1)
end
end
end
end)
end
local function __xNgotCreateAIMusicEngine(HsIn)
local CrossAIMusic={}
CrossAIMusic.__factory=true
local CFG={
ApiBase="https://ymp-api.ymp-api.workers.dev",
PowBase="https://p.savenow.to",
PowReferer="https://en.loader.to/",
PowApiKey="dfcb6d76f2f6a9894gjkege8a4ab232222",
Folder="xNgotLibrary/Music",
CoversFolder="xNgotLibrary/Music/Covers",
TopN=12,
SearchTimeout=12,
PowTimeout=25,
DownloadTimeout=200,
Retries=2,
PreferShort=600,
RaceTracks=2,
Sources={"youtube","soundcloud","audius"},
Region="auto",
PrefetchNext=true,
MaxTrackSeconds=1200,
}
CrossAIMusic.Config=CFG
CrossAIMusic.Sources={
{id="youtube",label="YouTube",domain="youtube.com",canStream=false},
{id="soundcloud",label="SoundCloud",domain="soundcloud.com",canStream=false},
{id="tiktok",label="TikTok",domain="tiktok.com",canStream=false},
{id="audius",label="Audius",domain="audius.co",canStream=true},
{id="audiomack",label="Audiomack",domain="audiomack.com",canStream=false},
{id="mixcloud",label="Mixcloud",domain="mixcloud.com",canStream=false},
}
local Hs=HsIn
if not Hs then pcall(function()Hs=game:GetService("HttpService")end)end
local function md5dec(t)end
local function trim(s)return(tostring(s or""):gsub("^%s+",""):gsub("%s+$",""))end
local function stripAccent(s)
s=tostring(s or"")
s=s:gsub("à","a"):gsub("á","a"):gsub("ạ","a"):gsub("ả","a"):gsub("ã","a")
s=s:gsub("â","a"):gsub("ầ","a"):gsub("ấ","a"):gsub("ậ","a"):gsub("ẩ","a"):gsub("ẫ","a")
s=s:gsub("ă","a"):gsub("ằ","a"):gsub("ắ","a"):gsub("ặ","a"):gsub("ẳ","a"):gsub("ẵ","a")
s=s:gsub("è","e"):gsub("é","e"):gsub("ẹ","e"):gsub("ẻ","e"):gsub("ẽ","e")
s=s:gsub("ê","e"):gsub("ề","e"):gsub("ế","e"):gsub("ệ","e"):gsub("ể","e"):gsub("ễ","e")
s=s:gsub("ì","i"):gsub("í","i"):gsub("ị","i"):gsub("ỉ","i"):gsub("ĩ","i")
s=s:gsub("ò","o"):gsub("ó","o"):gsub("ọ","o"):gsub("ỏ","o"):gsub("õ","o")
s=s:gsub("ô","o"):gsub("ồ","o"):gsub("ố","o"):gsub("ộ","o"):gsub("ổ","o"):gsub("ỗ","o")
s=s:gsub("ơ","o"):gsub("ờ","o"):gsub("ớ","o"):gsub("ợ","o"):gsub("ở","o"):gsub("ỡ","o")
s=s:gsub("ù","u"):gsub("ú","u"):gsub("ụ","u"):gsub("ủ","u"):gsub("ũ","u")
s=s:gsub("ư","u"):gsub("ừ","u"):gsub("ứ","u"):gsub("ự","u"):gsub("ử","u"):gsub("ữ","u")
s=s:gsub("ỳ","y"):gsub("ý","y"):gsub("ỵ","y"):gsub("ỷ","y"):gsub("ỹ","y")
s=s:gsub("đ","d"):gsub("Đ","D")
s=s:gsub("À","A"):gsub("Á","A"):gsub("Ạ","A"):gsub("Ả","A"):gsub("Ã","A"):gsub("Â","A"):gsub("Ă","A")
s=s:gsub("È","E"):gsub("É","E"):gsub("Ẹ","E"):gsub("Ẻ","E"):gsub("Ẽ","E"):gsub("Ê","E")
s=s:gsub("Ì","I"):gsub("Í","I"):gsub("Ị","I"):gsub("Ỉ","I"):gsub("Ĩ","I")
s=s:gsub("Ò","O"):gsub("Ó","O"):gsub("Ọ","O"):gsub("Ỏ","O"):gsub("Õ","O"):gsub("Ô","O"):gsub("Ơ","O")
s=s:gsub("Ù","U"):gsub("Ú","U"):gsub("Ụ","U"):gsub("Ủ","U"):gsub("Ũ","U"):gsub("Ư","U")
s=s:gsub("Ỳ","Y"):gsub("Ý","Y"):gsub("Ỵ","Y"):gsub("Ỷ","Y"):gsub("Ỹ","Y")
return s
end
local function norm(s)
s=stripAccent(s):lower()
s=s:gsub("[%p%c]"," ")
s=s:gsub("%s+"," ")
return trim(s)
end
local function words(normalized)
local out,seen={},{}
for w in normalized:gmatch("[%w]+")do
if#w>1 and not seen[w]then
seen[w]=true
out[#out+1]=w
end
end
return out
end
local function sanitizeName(text)
local out=tostring(text or""):gsub("[%c]"," ")
out=out:gsub('[<>:"/\\|%?%*]'," ")
out=out:gsub("[%[%]%(%){}#%%&,;]"," ")
out=out:gsub("%s+"," ")
out=trim(out)
if#out>80 then out=trim(out:sub(1,80))end
return out
end
CrossAIMusic.Util={
trim=trim,stripAccent=stripAccent,norm=norm,words=words,sanitizeName=sanitizeName,
}
local function getHttp()
if Hs then return Hs end
pcall(function()Hs=game:GetService("HttpService")end)
return Hs
end
local function jsonDecode(text)
local hs=getHttp()
if not hs or type(text)~="string"or#text==0 then return nil end
local ok,data=pcall(function()return hs:JSONDecode(text)end)
if ok then return data end
return nil
end
local function urlEncode(s)
local hs=getHttp()
local ok,out=pcall(function()return hs:UrlEncode(tostring(s))end)
if ok and type(out)=="string"then return out end
return(tostring(s):gsub("[^%w%-%._~]",function(c)
return string.format("%%02X",string.byte(c))
end))
end
local function httpGet(url)
local ok,data=pcall(function()return game:HttpGet(url)end)
if ok and type(data)=="string"and#data>0 then return data end
local hs=getHttp()
if hs then
ok,data=pcall(function()return hs:GetAsync(url)end)
if ok and type(data)=="string"and#data>0 then return data end
end
return nil
end
function CrossAIMusic.request(url,method,headers,body,timeout)
local raw
pcall(function()
raw=request or http_request or syn_request
or(syn and syn.request)
or(http and http.request)
or(fluxus and fluxus.request)
end)
if raw then
local ok,res=pcall(raw,{
Url=url,Method=method or"GET",Headers=headers,
Body=body,Timeout=timeout or 15,Redirects=false,
})
if ok and type(res)=="table"then return res end
end
local hs=getHttp()
if hs then
local ok,res=pcall(function()
local opts={Url=url,Method=method or"GET"}
if body then opts.Body=body end
return hs:RequestAsync(opts)
end)
if ok and type(res)=="table"then return res end
end
return nil
end
local Llm={
enabled=false,
mode="hybrid",
lastAt=0,
lastPlan=nil,
lastPrompt=nil,
lastError=nil,
okCount=0,
failCount=0,
busy=false,
cache={},
}
CrossAIMusic.Llm=Llm
local LLM_CACHE_TTL=600
function CrossAIMusic.llmAvailable()
return false
end
function CrossAIMusic.llmEnabled()
return false
end
function CrossAIMusic.llmSetEnabled(on)
Llm.enabled=false
CFG.LlmMode=Llm.enabled and"hybrid"or"off"
return Llm.enabled
end
function CrossAIMusic.applyLlmPlan(plan,extra)
if type(plan)~="table"or type(extra)~="table"then return plan end
local pieces={}
local base=trim(tostring(plan.query or""))
if base~=""then pieces[#pieces+1]=base end
local q=trim(tostring(extra.query or""))
if q~=""and q:lower()~=base:lower()then pieces[#pieces+1]=q end
if q~=""then plan.query=q end
if extra.artist~=""then
plan.llmArtist=extra.artist
if plan.query:lower():find(extra.artist:lower(),1,true)==nil then
plan.query=trim(plan.query.." "..extra.artist)
end
end
if extra.genre~=""and not plan.tags.genre then plan.tags.genre=extra.genre end
if extra.mood~=""and not plan.tags.mood then plan.tags.mood=extra.mood end
if extra.reason~=""then plan.llmReason=extra.reason end
plan.fromLlm=true
return plan
end
function CrossAIMusic.llmStatus()
return{enabled=false,removed=true,mode="local",ok=0,fail=0}
end
local function llmCall(_prompt,_system)
return nil,"off"
end
function CrossAIMusic.llmPlan(prompt,plan)
if not CrossAIMusic.llmEnabled()then return nil end
prompt=trim(tostring(prompt or""))
if prompt==""then return nil end
local key=prompt:lower()
local hit=Llm.cache[key]
if hit and os.time()-hit.at<LLM_CACHE_TTL then return hit.plan end
local ask=string.format(
'Người dùng nói: "%s". Hãy tách thành JSON đúng schema: '..
'{"query":"từ khóa tìm nhạc ngắn (giữ nguyên tên bài nếu có)","genre":"thể loại hoặc rỗng",'..
'"mood":"cảm xúc hoặc rỗng","artist":"ca sĩ hoặc rỗng","reason":"1 câu tiếng Việt ngắn"}. '..
'Chỉ trả JSON, không giải thích, không markdown.',prompt)
local text=llmCall(ask,"Bạn là bộ tách yêu cầu nhạc. Chỉ trả về JSON hợp lệ, không giải thích.")
if not text then return nil end
local json=extractJson(text)
local data=json and jsonDecode(json)
if type(data)~="table"then
Llm.lastError="LLM trả về không phải JSON"
return nil
end
local merged={
query=trim(tostring(data.query or"")),
genre=trim(tostring(data.genre or"")),
mood=trim(tostring(data.mood or"")),
artist=trim(tostring(data.artist or"")),
reason=trim(tostring(data.reason or"")),
}
if merged.query==""and merged.genre==""and merged.mood==""then return nil end
Llm.cache[key]={plan=merged,at=os.time()}
return merged
end
function CrossAIMusic.llmSay(prompt,context)
if not CrossAIMusic.llmEnabled()or not CFG.LlmReply then return nil end
local ask=string.format(
'Người dùng: "%s". %sTrả lời như một trợ lý âm nhạc thân thiện, tiếng Việt, tối đa 2 câu, '..
'không markdown, không lan man.',
tostring(prompt or""),(context and(tostring(context).." "))or"")
return llmCall(ask,"Bạn là Cross AI, trợ lý âm nhạc trong một script Roblox. Trả lời tiếng Việt, thân thiện, ngắn.")
end
local K256={
0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
}
local function shr(x,n)return math.floor(x/2^n)%2^32 end
local function rotr32(x,n)
n=n%32
local low=x%2^n
return(x-low)/2^n+low*2^(32-n)
end
local function band(a,b)
local res,bit=0,1
for _=1,32 do
local ai,bi=a%2,b%2
if ai==1 and bi==1 then res=res+bit end
a=(a-ai)/2
b=(b-bi)/2
bit=bit*2
end
return res
end
local function bxor(a,b)
local res,bit=0,1
for _=1,32 do
local ai,bi=a%2,b%2
if ai~=bi then res=res+bit end
a=(a-ai)/2
b=(b-bi)/2
bit=bit*2
end
return res
end
local function addmod(...)
local sum=0
for _,v in ipairs({...})do sum=(sum+v)%4294967296 end
return sum
end
local function sha256hex(msg)
msg=tostring(msg)
local len=#msg
local bytes={}
for i=1,len do bytes[i]=string.byte(msg,i)end
local bitLen=len*8
bytes[#bytes+1]=128
while#bytes%64~=56 do bytes[#bytes+1]=0 end
local hi=math.floor(bitLen/4294967296)
local lo=bitLen%4294967296
for i=3,0,-1 do bytes[#bytes+1]=math.floor(hi/2^(8*i))%256 end
for i=3,0,-1 do bytes[#bytes+1]=math.floor(lo/2^(8*i))%256 end
local h0,h1,h2,h3=1779033703,3144134277,1013904242,2773480762
local h4,h5,h6,h7=1359893119,2600822924,528734635,1541459225
for chunk=1,#bytes,64 do
local w={}
for i=0,15 do
local p=chunk+i*4
w[i+1]=bytes[p]*16777216+bytes[p+1]*65536+bytes[p+2]*256+bytes[p+3]
end
for i=17,64 do
local s0=bxor(bxor(rotr32(w[i-15],7),rotr32(w[i-15],18)),shr(w[i-15],3))
local s1=bxor(bxor(rotr32(w[i-2],17),rotr32(w[i-2],19)),shr(w[i-2],10))
w[i]=addmod(w[i-16],s0,w[i-7],s1)
end
local a,b,c,d,e,f,g,h=h0,h1,h2,h3,h4,h5,h6,h7
for i=1,64 do
local S1=bxor(bxor(rotr32(e,6),rotr32(e,11)),rotr32(e,25))
local ch=bxor(band(e,f),band((4294967295-e)%4294967296,g))
local t1=addmod(h,S1,ch,K256[i],w[i])
local S0=bxor(bxor(rotr32(a,2),rotr32(a,13)),rotr32(a,22))
local maj=bxor(bxor(band(a,b),band(a,c)),band(b,c))
local t2=addmod(S0,maj)
h=g;g=f;f=e
e=addmod(d,t1)
d=c;c=b;b=a
a=addmod(t1,t2)
end
h0=addmod(h0,a);h1=addmod(h1,b);h2=addmod(h2,c);h3=addmod(h3,d)
h4=addmod(h4,e);h5=addmod(h5,f);h6=addmod(h6,g);h7=addmod(h7,h)
end
return string.format("%08x%08x%08x%08x%08x%08x%08x%08x",h0,h1,h2,h3,h4,h5,h6,h7)
end
CrossAIMusic.sha256=sha256hex
local function solvePow(salt,difficulty)
local prefix=string.rep("0",tonumber(difficulty)or 0)
local base=tostring(salt)..":"
local nonce=0
local slice=os.clock()
while true do
if sha256hex(base..tostring(nonce)):sub(1,#prefix)==prefix then
return tostring(nonce)
end
nonce=nonce+1
if os.clock()-slice>0.003 then
pcall(task.wait)
slice=os.clock()
end
if nonce>5e6 then return nil end
end
end
CrossAIMusic.solvePow=solvePow
local LEXICON={}
local function put(group,canonical,list)
for _,w in ipairs(list)do LEXICON[norm(w)]={tag=group,canon=canonical}end
end
put("genre","lofi",{"lofi","lo-fi","lo fi","chillhop","nhac nhe"})
put("genre","chill",{"chill","chillout","thu gian","thư giãn","relax","thu thai","thư thái"})
put("genre","jazz",{"jazz","jazzy","nhac jazz"})
put("genre","piano",{"piano","dan piano","đàn piano"})
put("genre","acoustic",{"acoustic","moc","mộc","guitar"})
put("genre","edm",{"edm","electronic","dien tu","điện tử","house","techno","remix","vinahouse"})
put("genre","hiphop",{"hiphop","hip hop","rap","trap","drill"})
put("genre","rock",{"rock","metal","punk"})
put("genre","pop",{"pop","nhac pop","vpop","usuk","us uk"})
put("genre","ballad",{"ballad","buon","buồn","sad","tam trang","tâm trạng","that tinh","thất tình"})
put("genre","classical",{"classical","co dien","cổ điển","orchestra","giao huong","giao hưởng"})
put("genre","latin",{"latin","salsa","bossa","bossa nova"})
put("genre","kpop",{"kpop","k-pop","nhac han","nhạc hàn"})
put("genre","anime",{"anime","ost anime","nhac nhat","nhạc nhật","jpop"})
put("genre","country",{"country","folk","dan ca","dân ca"})
put("genre","ambient",{"ambient","khong loi","không lời","instrumental","nhac nen","nhạc nền"})
put("genre","cinematic",{"cinematic","epic","hung trang","hùng tráng","trailer"})
put("genre","game",{"game","8bit","chiptune","retro","roblox"})
put("mood","happy",{"vui","happy","vui ve","vui vẻ","phan khich","phấn khích","upbeat","sang khoai","sảng khoái"})
put("mood","sad",{"buon","buồn","sad","co don","cô đơn","alone","u sau","u sầu"})
put("mood","focus",{"hoc bai","học bài","tap trung","tập trung","focus","study","lam viec","làm việc","work"})
put("mood","sleep",{"ngu","ngủ","ru ngu","ru ngủ","sleep","mat ngu","mất ngủ","insomnia"})
put("mood","chill",{"thu gian","thư giãn","chill","nhe nhang","nhẹ nhàng","em diu","êm dịu","soft"})
put("mood","hype",{"soi dong","sôi động","chay","cháy","hype","mau lua","máu lửa","workout","gym","tap the duc"})
put("mood","romantic",{"lang man","lãng mạn","romantic","tinh yeu","tình yêu","love"})
put("mood","dark",{"dark","toi tam","tăm tối","u am","u ám","horror","dang so","đáng sợ"})
put("mood","cafe",{"cafe","cà phê","quan cafe","quán cà phê","buoi sang","buổi sáng","morning","sang som","sáng sớm"})
put("mood","rain",{"mua","mưa","rain","rainy","dem mua","đêm mưa"})
put("mood","night",{"buoi toi","buổi tối","toi nay","tối nay","buoi dem","buổi đêm",
"dem","đêm","night","evening","midnight","nua dem","nửa đêm","khuya"})
put("mood","drive",{"lai xe","lái xe","drive","phuot","phượt","roadtrip","xe"})
put("mood","party",{"tiec","tiệc","party","club","bar","nhay","nhảy"})
put("ctx","short",{"ngan","ngắn","short","duoi 3 phut","dưới 3 phút"})
put("ctx","long",{"dai","dài","long","nhieu gio","nhiều giờ","mix","playlist dai"})
put("ctx","vietnam",{"viet","việt","vpop","nhac viet","nhạc việt","nhac tre","nhạc trẻ"})
put("genre","bolero",{"bolero","nhac vang","nhạc vàng","tru tinh","trữ tình","nhac tru tinh","nhạc trữ tình","nhac song","nhạc sống","ho quang","hồ quảng"})
put("mood","romantic",{"lang man","lãng mạn","tinh cam","tình cảm","yeu","yêu","nho","nhớ"})
put("ctx","english",{"english","us-uk","usuk","nhac my","nhạc mỹ","quoc te","quốc tế"})
put("ctx","looptrack",{"lap lai","lặp lại","repeat","loop"})
put("ctx","gaming",{"choi game","chơi game","gaming","tryhard","rank","dang rank","đang rank",
"lien quan","liên quân","valorant","lol","minecraft","blox fruits","pvp","speedrun"})
put("ctx","code",{"code","lap trinh","lập trình","coding","dev","debug","type code","viet code","viết code"})
put("mood","calm",{"binh yen","bình yên","an yen","an yên","peaceful","calm","tinh lang","tĩnh lặng","nhe nhang"})
put("mood","nostalgia",{"hoai niem","hoài niệm","xua","xưa","ky uc","ký ức","memory","nostalgic","8x","9x"})
put("mood","motivated",{"truyen cam hung","truyền cảm hứng","dong luc","động lực","motivation","inspire","chay deadline"})
put("mood","heartbreak",{"that tinh","thất tình","chia tay","breakup","bi bo roi","bị bỏ rơi","co don"})
put("mood","sunny",{"nang","nắng","troi nang","trời nắng","summer","mua he","mùa hè","bien","biển"})
put("mood","coffee",{"ca phe","cà phê","cafe","highlands","phuc long","quan ca phe"})
put("mood","focus",{"deadline","thi","ôn thi","on thi","chay deadline","nang suat","năng suất"})
put("genre","phonk",{"phonk","drift phonk","sigma"})
put("genre","indie",{"indie","indie viet","nhac indie","nhạc indie"})
put("genre","rap-viet",{"rap viet","rap việt","rap vn","nhac rap viet"})
put("genre","remix-viet",{"remix viet","remix việt","vinahouse","vina house","nonstop viet"})
put("genre","kpop-dance",{"kpop dance","nhay kpop","nhảy kpop","dance cover"})
put("genre","citypop",{"city pop","citypop","thanh thi","thành thị"})
put("artist","son-tung-mtp",{"son tung","sơn tùng","son tung mtp","sơn tùng mtp"})
put("artist","mono",{"mono","mono viet"})
put("artist","hoang-dung",{"hoang dung","hoàng dũng"})
put("artist","vu-cat-tuong",{"vu","vũ","vu cat tuong","vũ cát tường"})
put("artist","my-tam",{"my tam","mỹ tâm"})
put("artist","binz",{"binz"})
put("artist","den-vau",{"den vau","đen vâu","den"})
put("artist","justatee",{"justatee","justa tee"})
put("artist","taylor-swift",{"taylor swift","taylor","swiftie"})
put("artist","lofi-girl",{"lofi girl","lofigirl"})
put("artist","weeknd",{"the weeknd","weeknd","abel"})
put("artist","billie-eilish",{"billie eilish","billie","eilish"})
put("artist","ed-sheeran",{"ed sheeran","ed"})
put("artist","chill-nation",{"chill nation"})
put("artist","newjeans",{"newjeans","new jeans","nj"})
put("artist","bts",{"bts","bangtan"})
put("artist","blackpink",{"blackpink","black pink","bp"})
put("artist","adele",{"adele"})
put("artist","eminem",{"eminem","slim shady"})
put("artist","daft-punk",{"daft punk"})
put("artist","hans-zimmer",{"hans zimmer"})
put("artist","lofi-records",{"chilledcow","lofi records"})
CrossAIMusic.Lexicon=LEXICON
local STOP={}
for _,w in ipairs({
"toi","tôi","minh","mình","ban","bạn","muon","muốn","can","cần","hay","hãy",
"giup","giúp","cho","và","va","cua","của","mot","một","bai","bài","hat","hát",
"nhac","nhạc","nghe","mo","mở","phat","phát","tim","tìm","kiem","kiếm",
"play","some","please","me","song","songs","music","track","tracks","a","an","the",
"for","with","and","or","to","in","on","of","that","this","like","want","need",
"gi","gì","nao","nào","duoc","được","roi","rồi","nhe","nhé","nha",
"luc","lúc","khi","trong","ngoai","giua","buoi","buổi","chieu","chiều",
"trua","sang","som","sớm","muon","muộn","de","để","voi","với","o","ở",
"tai","tại","nay","kia","do","đó","thi","thì","cung","cũng","se","sẽ",
"dang","đang","vua","vừa","rat","rất","qua","quá","lam","làm","di","đi",
"chut","chút","vao","vào","ra","len","lên","xuong","xuống",
"study","work","gym","any","good","best","vibe","vibes",
})do STOP[norm(w)]=true end
function CrossAIMusic.parse(prompt)
local raw=trim(prompt)
raw=raw:gsub("^%s*",""):gsub("%s*$","")
local plan={
raw=raw,query=raw,tags={},weight={},
sources={"youtube"},limit=CFG.TopN,
}
if raw==""then return plan end
local n=norm(raw)
local consumed,matched={},{}
local phrases={}
for k,v in pairs(LEXICON)do
phrases[#phrases+1]={key=k,data=v,size=#k:gsub("[^ ]","")}
end
table.sort(phrases,function(a,b)return a.size>b.size end)
for _,item in ipairs(phrases)do
local key=item.key
local init=1
while true do
local s,e=n:find(key,init,true)
if not s then break end
local okLeft=(s==1)or(n:sub(s-1,s-1)==" ")
local okRight=(e==#n)or(n:sub(e+1,e+1)==" ")
if okLeft and okRight then
for i=s,e do consumed[i]=true end
local tag,canon=item.data.tag,item.data.canon
if not plan.tags[tag]then plan.tags[tag]=canon end
plan.weight[tag]=(plan.weight[tag]or 0)+1
matched[canon]=true
end
init=e+1
end
end
plan.sources=CFG.Sources or{"youtube","soundcloud","audius"}
if plan.tags.artist then
local artistWords=plan.tags.artist:gsub("%-"," ")
plan.artist=artistWords
end
if plan.tags.ctx=="gaming"then plan.limit=math.max(plan.limit or 12,14)end
if matched["short"]then plan.limit=6 end
if matched["long"]then plan.limit=20 end
local buf,i={},1
while i<=#n do
if not consumed[i]then
buf[#buf+1]=n:sub(i,i)
while i<#n and not consumed[i+1]and n:sub(i+1,i+1)~=" "do
i=i+1
buf[#buf+1]=n:sub(i,i)
end
end
i=i+1
end
local rest=trim(table.concat(buf):gsub("%s+"," "))
local parts={}
for _,w in ipairs(words(rest))do
if not STOP[w]and LEXICON[w]==nil then parts[#parts+1]=w end
end
local final={}
local kept=#parts>0 and table.concat(parts," ")or""
if kept~=""then final[#final+1]=kept end
if plan.tags.artist and plan.tags.artist~=""then
local artistText=plan.tags.artist:gsub("%-"," ")
if kept==""or not kept:lower():find(artistText:lower(),1,true)then
final[#final+1]=artistText
end
end
if plan.tags.genre and plan.tags.genre~=""then final[#final+1]=plan.tags.genre end
if plan.tags.mood and plan.tags.mood~=""and plan.tags.mood~=plan.tags.genre then
local moodText=plan.tags.mood
local already=false
for _,piece in ipairs(final)do
if piece:lower():find(moodText:lower(),1,true)then already=true end
end
if not already then final[#final+1]=moodText end
end
if plan.tags.ctx=="gaming"then final[#final+1]="gaming music"end
if plan.tags.ctx=="code"then final[#final+1]="coding focus"end
if final[1]==nil then
local fb={}
for _,w in ipairs(words(n))do
if not STOP[w]then fb[#fb+1]=w end
end
final[1]=#fb>0 and table.concat(fb," ")or n
end
plan.vietnam=matched["vietnam"]==true or matched["bolero"]==true
plan.query=table.concat(final," ")
plan.explicitTitle=#parts>0 and table.concat(parts," ")or nil
return plan
end
local SOURCE_BIAS={youtube=1.0,soundcloud=0.92,audius=0.9,tiktok=0.85,audiomack=0.8,mixcloud=0.8}
function CrossAIMusic.durationSeconds(text)
text=tostring(text or"")
local h,m,s=text:match("^(%d+):(%d%d):(%d%d)$")
if h then return tonumber(h)*3600+tonumber(m)*60+tonumber(s)end
local mm,ss=text:match("^(%d+):(%d%d)$")
if mm then return tonumber(mm)*60+tonumber(ss)end
return 0
end
function CrossAIMusic.normalizeRow(row,sourceId)
if type(row)~="table"then return nil end
local id=tostring(row.id or row.fileId or row.videoId or"")
if id==""then return nil end
local thumb=row.thumbnail or row.cover or row.Thumbnail or row.image or""
if type(thumb)=="table"then
thumb=thumb.url or(thumb.url_list and thumb.url_list[1])or""
end
local author=row.author or row.artist or row.uploader or row.channel or""
if type(author)=="table"then
author=author.nickname or author.name or author.unique_id or""
end
local url=row.url or row.share_url or row.permalink or""
local direct=row.directUrl or row.direct_url or row.audioUrl or row.audio_url or nil
if sourceId=="audius"then
local clean=id:gsub("^audius:","")
direct=direct or("https://api.audius.co/v1/tracks/"..urlEncode(clean).."/stream")
end
local dur=row.duration or row.durationText or"0:00"
if type(dur)=="number"then
dur=string.format("%d:%02d",math.floor(dur/60),dur%60)
end
return{
id=id,source=sourceId,
name=trim(tostring(row.name or row.title or row.track or"Unknown")),
author=trim(tostring(author)),
thumbnail=tostring(thumb),duration=tostring(dur),
url=tostring(url),directUrl=direct,kind=row.kind or"track",
}
end
function CrossAIMusic.score(track,plan)
track=track or{}
plan=plan or{tags={},weight={}}
plan.tags=plan.tags or{}
plan.weight=plan.weight or{}
local score=0
local text=norm(tostring(track.name or track.title or"").." "..tostring(track.author or track.artist or"").." "..tostring(track.text or""))
for tag,canon in pairs(plan.tags)do
if canon and canon~=""and text:find(norm(canon),1,true)then
score=score+3*(plan.weight[tag]or 1)
end
end
if plan.explicitTitle and plan.explicitTitle~=""then
local hit,total=0,0
for w in plan.explicitTitle:gmatch("%S+")do
total=total+1
if text:find(w,1,true)then hit=hit+1 end
end
if total>0 then score=score+(hit/total)*8 end
end
local wantsLong=plan.tags.ctx=="long"
local penalty=0
if text:find("1 hour",1,true)or text:find("10 hours",1,true)
or text:find("1hour",1,true)or text:find("hours",1,true)then
penalty=6
elseif text:find(" mix",1,true)or text:find("playlist",1,true)
or text:find("compilation",1,true)or text:find("medley",1,true)then
penalty=4
end
if not wantsLong then score=score-penalty end
local secs=CrossAIMusic.durationSeconds(track.duration)
if secs>0 and not wantsLong then
if secs>2700 then score=score-16
elseif secs>1200 then score=score-11
elseif secs>600 then score=score-6
elseif secs>480 then score=score-2
elseif secs>=90 and secs<=480 then score=score+2
elseif secs<45 then score=score-2 end
end
if plan.artist and plan.artist~=""then
local artistText=norm(track.text or"")
local artistWords=norm(plan.artist)
local hitArtist=0
local totalArtist=0
for w in artistWords:gmatch("%S+")do
totalArtist=totalArtist+1
if#w>2 and artistText:find(w,1,true)then hitArtist=hitArtist+1 end
end
if totalArtist>0 then
local ratio=hitArtist/totalArtist
score=score+ratio*12
if ratio==0 then score=score-6 end
end
end
if plan.tags.genre and plan.tags.genre~=""then
local wanted=norm(plan.tags.genre)
local got=norm(track.text or"")
if wanted~=""and got:find(wanted,1,true)then
score=score+5
elseif(plan.tags.genre=="lofi"or plan.tags.genre=="ambient")and got:find("remix",1,true)then
score=score-5
end
end
if plan.tags.ctx=="gaming"then
local got=norm(track.text or"")
if got:find("gaming",1,true)or got:find("epic",1,true)or got:find("battle",1,true)then
score=score+3
end
end
if CrossAIMusic._banned then
for _,word in ipairs(CrossAIMusic._banned)do
if norm(track.text or""):find(word,1,true)then
score=score-25
break
end
end
end
score=score+(SOURCE_BIAS[track.source]or 0.7)
if track.directUrl then score=score+0.5 end
if track.thumbnail~=""then score=score+0.2 end
return score
end
function CrossAIMusic.learn(title,good)
CrossAIMusic._banned=CrossAIMusic._banned or{}
if type(title)~="string"or title==""then return end
local words={}
for w in norm(title):gmatch("%S+")do
if#w>3 then words[#words+1]=w end
end
if good==false then
for index=1,math.min(#words,3)do
local word=words[index]
local exists=false
for _,item in ipairs(CrossAIMusic._banned)do
if item==word then exists=true end
end
if not exists then CrossAIMusic._banned[#CrossAIMusic._banned+1]=word end
end
if#CrossAIMusic._banned>40 then table.remove(CrossAIMusic._banned,1)end
end
return CrossAIMusic._banned
end
local detectedRegion=""
pcall(function()
local loc=game:GetService("LocalizationService")
local locale=""
pcall(function()locale=tostring(loc.RobloxLocaleId or"")end)
local suffix=locale:match("[-_]([%a][%a])$")
if suffix then detectedRegion=suffix:upper()
elseif locale:lower():match("^vi")then detectedRegion="VN"end
task.spawn(function()
local ok,code=pcall(function()return loc:GetCountryRegionForPlayerAsync(game:GetService("Players").LocalPlayer)end)
if ok and type(code)=="string"and code:match("^%a%a$")then detectedRegion=code:upper()end
end)
end)
local regionTerms={VN="nhac viet nam",US="american music",KR="kpop korean music",JP="japanese music"}
function CrossAIMusic.searchRegion()
local region=tostring(CFG.Region or"auto"):upper()
if region=="AUTO"then region=detectedRegion end
if region=="GLOBAL"then return""end
return regionTerms[region]and region or""
end
function CrossAIMusic.queryVariants(plan,prompt)
local raw=tostring((prompt or plan.raw or"")):gsub("^%s+",""):gsub("%s+$","")
local main=tostring(plan.query or"")
local out,seen={},{}
local function add(q)
q=trim(tostring(q or""):gsub("%s+"," "))
if q==""or seen[q:lower()]then return end
if#q>90 then q=trim(q:sub(1,90))end
seen[q:lower()]=true
out[#out+1]=q
end
add(main)
if plan.vietnam or(plan.tags and plan.tags.ctx=="vietnam")then
add(main.." viet nam")
end
local flat=trim(norm(main))
if flat~=""and flat~=main:lower()then add(flat)end
if raw~=""and raw~=main then add(raw)end
local title=plan.explicitTitle
if title and title~=""and title~=main then add(title)end
if title and title~=""and plan.tags and plan.tags.genre then add(title.." "..plan.tags.genre)end
if title and title~=""then
local plain=trim(norm(title))
if plain~=""and plain~=title:lower()then add(plain)end
end
if plan.artist and plan.artist~=""then
add(plan.artist.." "..(title or plan.tags.genre or""))
if title and title~=""then add(title.." "..plan.artist)end
end
if plan.vietnam or(plan.tags and plan.tags.ctx=="vietnam")then
add(main.." viet nam")
end
plan.weak=plan.weak~=false
local region=CrossAIMusic.searchRegion()
local term=regionTerms[region]
local trimmed,unique={},{}
for i=1,math.min(#out,3)do
local q=term and trim(out[i].." "..term)or out[i]
if not unique[q:lower()]then trimmed[#trimmed+1]=q;unique[q:lower()]=true end
end
plan.region=region
return trimmed
end
local function searchOne(sourceId,query,page)
local url=CFG.ApiBase.."/search/"..sourceId.."/"..urlEncode(query)
if page and page>1 then url=url.."?page="..tostring(page)end
local body=httpGet(url)
if not body then
local res=CrossAIMusic.request(url,"GET",{["accept"]="application/json"},nil,CFG.SearchTimeout)
body=res and res.Body
end
if not body or type(body)~="string"then return nil,"network"end
local low=body:lower()
if low:find("too many requests",1,true)then return nil,"rate"end
if low:find("no results",1,true)or low:find("not found",1,true)then return nil,"empty"end
local data=jsonDecode(body)
if type(data)~="table"then return nil,"decode"end
local rows=data.results or data
if type(rows)~="table"then return nil,"shape"end
local out={}
for _,r in ipairs(rows)do
local t=CrossAIMusic.normalizeRow(r,sourceId)
if t then out[#out+1]=t end
end
if#out==0 then return nil,"empty"end
return out
end
function CrossAIMusic.search(plan,callback,prompt)
callback=callback or function()end
if type(plan)=="string"then plan=CrossAIMusic.parse(plan)end
local variants=CrossAIMusic.queryVariants(plan,prompt)
if#variants==0 then variants={plan.query}end
callback("searching",{query=variants[1],sources=plan.sources,variants=variants})
local collected,errors,seenIds={},{},{}
local jobs=0
local function push(list)
if type(list)~="table"then return end
for _,t in ipairs(list)do
local key=tostring(t.source).."|"..tostring(t.id)
if not seenIds[key]then
seenIds[key]=true
collected[#collected+1]=t
end
end
end
local sources=plan.sources or{"youtube"}
if#sources==0 then
callback("error",{reason="no source"})
return{}
end
for _,q in ipairs(variants)do
for _,src in ipairs(sources)do
jobs=jobs+1
task.spawn(function()
local ok,list,err=pcall(searchOne,src,q,1)
if ok and list then
push(list)
else
errors[#errors+1]=src..":"..tostring(err or"error")
end
jobs=jobs-1
end)
end
end
local waited=0
local minWait=3.5
local hardWait=6.5
while jobs>0 and waited<CFG.SearchTimeout+3 do
if waited>minWait and#collected>=6 then break end
if waited>hardWait and#collected>0 then break end
task.wait(0.1)
waited=waited+0.1
end
if#collected==0 then
plan.weak=true
local rescue=CrossAIMusic.queryVariants(plan,plan.query)
for _,q in ipairs(rescue)do
for _,src in ipairs(sources)do
local ok,list=pcall(searchOne,src,q,2)
if ok then push(list)end
end
end
end
if#collected==0 then
callback("error",{reason=table.concat(errors,", ")})
return{}
end
local maxSecs=CFG.MaxTrackSeconds or 0
if maxSecs>0 then
local shortList={}
for _,t in ipairs(collected)do
local secs=CrossAIMusic.durationSeconds(t.duration)
if secs>0 and secs<=maxSecs then shortList[#shortList+1]=t end
end
if#shortList>=3 then collected=shortList end
end
for _,t in ipairs(collected)do t._score=CrossAIMusic.score(t,plan)end
table.sort(collected,function(a,b)return a._score>b._score end)
local top={}
for i=1,math.min(#collected,plan.limit or CFG.TopN)do top[i]=collected[i]end
callback("done",{plan=plan,results=top,total=#collected})
return top
end
local tokenCache={token=nil,expires=0,busy=false}
local function powHeaders(bearer,withJson)
local h={
["accept"]="*/*",
["accept-language"]="vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7",
["referer"]=CFG.PowReferer,
["sec-ch-ua"]='"Chromium";v="137", "Not/A)Brand";v="24"',
["sec-ch-ua-mobile"]="?1",
["sec-ch-ua-platform"]='"Android"',
["sec-fetch-dest"]="empty",
["sec-fetch-mode"]="cors",
["sec-fetch-site"]="cross-site",
}
if withJson then h["content-type"]="application/json"end
if bearer then h["authorization"]="Bearer "..tostring(bearer)end
return h
end
function CrossAIMusic.getPowToken()
if tokenCache.token and os.time()<tokenCache.expires-30 then
return tokenCache.token
end
if tokenCache.busy then
local t0=os.clock()
while tokenCache.busy and os.clock()-t0<20 do task.wait(0.1)end
if tokenCache.token and os.time()<tokenCache.expires-30 then
return tokenCache.token
end
end
tokenCache.busy=true
local ok,token,expires=pcall(function()
local chRes=CrossAIMusic.request(CFG.PowBase.."/api/pow/challenge","GET",powHeaders(nil,false),nil,CFG.PowTimeout)
local chBody=chRes and chRes.Body
if not chBody then chBody=httpGet(CFG.PowBase.."/api/pow/challenge")end
local ch=jsonDecode(tostring(chBody or""))
if type(ch)~="table"or ch.salt==nil or ch.difficulty==nil
or ch.expires_at==nil or ch.signature==nil then
return nil
end
local nonce=solvePow(ch.salt,ch.difficulty)
if not nonce then return nil end
local hs=getHttp()
local body=hs:JSONEncode({
salt=ch.salt,difficulty=ch.difficulty,
expires_at=ch.expires_at,signature=ch.signature,nonce=nonce,
})
local vRes=CrossAIMusic.request(CFG.PowBase.."/api/pow/verify","POST",powHeaders(nil,true),body,CFG.PowTimeout)
local v=jsonDecode(tostring(vRes and vRes.Body or""))
if type(v)~="table"or v.success~=true or type(v.token)~="string"then return nil end
return v.token,tonumber(v.expires_at)or tonumber(ch.expires_at)or(os.time()+300)
end)
tokenCache.busy=false
if ok and type(token)=="string"then
tokenCache.token=token
tokenCache.expires=tonumber(expires)or(os.time()+300)
return token
end
return nil
end
function CrossAIMusic.download(url,onProgress)
onProgress=onProgress or function()end
local started=os.clock()
for attempt=1,CFG.Retries+1 do
onProgress("pow",{attempt=attempt})
local token=CrossAIMusic.getPowToken()
if token then
local submitUrl=CFG.PowBase.."/api/v2/download?format=mp3"
.."&url="..urlEncode(url)
.."&apikey="..urlEncode(CFG.PowApiKey)
local res=CrossAIMusic.request(submitUrl,"GET",powHeaders(token,false),nil,CFG.PowTimeout)
local data=jsonDecode(tostring(res and res.Body or""))
if type(data)=="table"and data.success~=false and type(data.progress_url)=="string"then
onProgress("queue",{progressUrl=data.progress_url})
task.wait(0.6)
local done,stuck=nil,0
while os.clock()-started<CFG.DownloadTimeout do
local pRes=CrossAIMusic.request(data.progress_url,"GET",powHeaders(token,false),nil,CFG.PowTimeout)
local p=jsonDecode(tostring(pRes and pRes.Body or""))
if type(p)=="table"then
if p.progress==1000 and type(p.download_url)=="string"then
done=p
break
end
if p.progress==1000 then
stuck=stuck+1
if stuck>=2 then break end
else
local pct=tonumber(p.progress)
if pct then onProgress("progress",{percent=math.clamp(pct/1000,0,1)})end
end
end
local span=os.clock()-started
task.wait(span<6 and 0.5 or(span<30 and 0.9 or 1.6))
end
if done then
local candidates={done.download_url}
if type(done.alternative_download_urls)=="table"then
for _,alt in ipairs(done.alternative_download_urls)do
if#candidates>=4 then break end
if type(alt)=="table"and type(alt.url)=="string"and alt.url~=done.download_url then
candidates[#candidates+1]=alt.url
end
end
end
onProgress("done",{urls=candidates})
return candidates
end
end
else
onProgress("pow",{attempt=attempt,failed=true})
end
if attempt<=CFG.Retries then
onProgress("retry",{attempt=attempt})
task.wait(2)
end
end
onProgress("error",{reason="pow/download failed"})
return nil
end
local function looksLikeErrorPayload(s)
if#s==0 then return true end
local low=s:sub(1,64):lower()
if low:sub(1,1)=="{"then return true end
if low:find("<!doctype",1,true)or low:find("<html",1,true)then return true end
if low:find("api_key_required",1,true)or low:find("error_code",1,true)then return true end
return false
end
local function looksLikeAudio(s)
if type(s)~="string"or#s<1024 then return false end
local b1,b2,b3,b4=s:byte(1,4)
if b1==0x49 and b2==0x44 and b3==0x33 then return true end
if b1==0xFF and b2 and b2>=0xE0 then return true end
if s:sub(5,8)=="ftyp"then return true end
if b1==0x4F and b2==0x67 and b3==0x67 and b4==0x53 then return true end
if b1==0x1A and b2==0x45 and b3==0xDF and b4==0xA3 then return true end
if b1==0x52 and b2==0x49 and b3==0x46 and b4==0x46 then return true end
return false
end
CrossAIMusic.looksLikeAudio=looksLikeAudio
local function readID3(data)
if type(data)~="string"or#data<64 then return nil end
if data:sub(1,3)~="ID3"then return nil end
local version=data:byte(4)or 3
local size=0
for i=7,10 do
size=size*128+((data:byte(i)or 0)%128)
end
local limit=math.min(11+size,#data)
local pos=11
local info={}
local function decodeText(bytes,encoding)
if encoding==0 then
return bytes
elseif encoding==3 then
return bytes
end
local out={}
local step=2
local i=1
if#bytes%2==1 then i=1 end
while i<#bytes do
local lo=bytes:byte(i)
local hi=bytes:byte(i+1)
local code=lo+hi*256
if code>0 then out[#out+1]=string.char(lo)end
i=i+step
end
return table.concat(out)
end
while pos+10<=limit do
local id=data:sub(pos,pos+3)
if not id:match("^[A-Z0-9]+$")then break end
local fsize=0
for k=0,3 do
fsize=fsize*256+(data:byte(pos+4+k)or 0)
end
local body=data:sub(pos+10,pos+9+fsize)
pos=pos+10+fsize
if#body<2 then break end
if id=="TIT2"then
info.title=decodeText(body:sub(2),body:byte(1))
elseif id=="TPE1"then
info.artist=decodeText(body:sub(2),body:byte(1))
elseif id=="TALB"then
info.album=decodeText(body:sub(2),body:byte(1))
elseif id=="APIC"then
local enc=body:byte(1)
local mimeEnd=body:find("\0",2,true)
if mimeEnd then
local mime=body:sub(2,mimeEnd-1):lower()
local p=mimeEnd+1
if body:byte(p)then p=p+1 end
local descEnd=body:find("\0",p,true)
if descEnd then p=descEnd+1 end
local pic=body:sub(p)
if#pic>200 then
local ext=".jpg"
if mime:find("png",1,true)then ext=".png"end
info.cover=pic
info.coverExt=ext
end
end
end
end
for k,v in pairs(info)do
if type(v)=="string"then
info[k]=trim((v:gsub("%c"," ")))
end
end
if info.title==""then info.title=nil end
if info.artist==""then info.artist=nil end
return info
end
CrossAIMusic.readID3=readID3
local function hashOf(text)
return sha256hex(tostring(text)):sub(1,10)
end
CrossAIMusic.hash=hashOf
local function ensureFolder(folder)
folder=folder or CFG.Folder
if type(makefolder)=="function"and type(isfolder)=="function"and not isfolder(folder)then
pcall(makefolder,folder)
end
end
CrossAIMusic.ensureFolder=ensureFolder
local renameEnabled=true
function CrossAIMusic.renameFiles(on)
renameEnabled=on~=false
return renameEnabled
end
function CrossAIMusic.isRenameEnabled()return renameEnabled end
function CrossAIMusic.cacheCandidates(key,title)
if not renameEnabled then title=nil end
local out={}
local base=sanitizeName(title)
if base~=""then
out[#out+1]=string.format("%s/%s [%s].mp3",CFG.Folder,base,string.sub(hashOf(key),1,8))
out[#out+1]=string.format("%s/%s.mp3",CFG.Folder,base)
end
out[#out+1]=string.format("%s/%s.mp3",CFG.Folder,hashOf(key))
return out
end
function CrossAIMusic.cachePath(key,title)
local list=CrossAIMusic.cacheCandidates(key,title)
return list[1]
end
local function readExisting(candidates)
for _,path in ipairs(candidates)do
if type(isfile)=="function"and isfile(path)and type(readfile)=="function"then
local ok,data=pcall(readfile,path)
if ok and type(data)=="string"and#data>1024 then
return data,path
end
end
end
return nil
end
function CrossAIMusic.thumbAsset(track)
if type(track)~="table"then return nil end
return CrossAIMusic.coverAsset(track)
end
function CrossAIMusic.prefetchCovers(list,onOne)
list=list or{}
onOne=onOne or function()end
for _,track in ipairs(list)do
task.spawn(function()
local ok,asset=pcall(CrossAIMusic.coverAsset,track)
if ok and type(asset)=="string"and asset~=""then
pcall(onOne,track,asset)
end
end)
end
end
function CrossAIMusic.coverAsset(track)
if type(track)~="table"then return nil end
if track.CoverAsset then return track.CoverAsset end
if type(writefile)~="function"then return nil end
local getter=getcustomasset or getsynasset
if type(getter)~="function"then return nil end
local url=track.thumbnail
if type(url)~="string"or url==""or not url:match("^https?://")then return nil end
ensureFolder(CFG.CoversFolder)
local ext=url:match("%.png")and".png"or".jpg"
local path=string.format("%s/%s%s",CFG.CoversFolder,hashOf(url),ext)
if type(isfile)=="function"and isfile(path)then
local okAsset,asset=pcall(getter,path)
if okAsset and type(asset)=="string"and asset~=""then
track.CoverAsset=asset
return asset
end
end
local data=httpGet(url)
if type(data)=="string"and#data>512 then
local okWrite=pcall(writefile,path,data)
if okWrite then
local okAsset,asset=pcall(getter,path)
if okAsset and type(asset)=="string"and asset~=""then
track.CoverAsset=asset
return asset
end
end
end
return nil
end
function CrossAIMusic.saveBytes(key,data,title)
if type(data)~="string"or#data<1024 then return nil end
if not looksLikeAudio(data)then return nil end
if type(writefile)~="function"then return nil end
local getter=getcustomasset or getsynasset
if type(getter)~="function"then return nil end
ensureFolder()
local candidates=CrossAIMusic.cacheCandidates(key,title)
local path=candidates[1]
if type(_G.xNgotLog)=="table"and type(_G.xNgotLog.debug)=="function"then
_G.xNgotLog.debug("music","lưu file: "..tostring(path).." ("..tostring(#data).." byte)")
_G.xNgotLog.debug("music","tên thật: "..tostring(title or key))
end
if not pcall(writefile,path,data)then
path=candidates[#candidates]
if not pcall(writefile,path,data)then return nil end
end
local check=readExisting({path})
if check and#check~=#data then
end
pcall(function()
local id3=readID3(data)
CrossAIMusic.writeDownloadedMeta(path,{
Title=(id3 and id3 .title)or title,
Artist=(id3 and id3 .artist)or"",
Album=(id3 and id3 .album)or"",
})
end)
local okAsset,asset=pcall(getter,path)
if okAsset and type(asset)=="string"and asset~=""then return asset,path end
local altAsset=(customAsset==getcustomasset)and getsynasset or getcustomasset
if type(altAsset)=="function"and altAsset~=customAsset then
local okAlt,alt=pcall(altAsset,path)
if okAlt and type(alt)=="string"and alt~=""then return alt,path end
end
return nil
end
local function dlFormatBytes(bytes)
bytes=tonumber(bytes)or 0
if bytes<1024 then return string.format("%d B",bytes)end
if bytes<1024*1024 then return string.format("%.1f KB",bytes/1024)end
if bytes<1024*1024*1024 then return string.format("%.2f MB",bytes/(1024*1024))end
return string.format("%.2f GB",bytes/(1024*1024*1024))
end
CrossAIMusic.formatBytes=dlFormatBytes
local function dlFileName(path)
local normalized=tostring(path or""):gsub("\\","/")
return normalized:match("([^/]+)$")or normalized
end
local function dlTitleFromFileName(fileName)
local base=tostring(fileName or""):gsub("%.mp3$",""):gsub("%.MP3$","")
base=base:gsub("%s%[%x+%]$","")
base=trim(base)
if base==""then return"Bai da tai"end
if base:match("^%x+$")and#base<=12 then return"Bai da tai "..base end
return base
end
local function dlMetaPath(path)
return tostring(path or"")..".json"
end
function CrossAIMusic.readDownloadedMeta(path)
local metaPath=dlMetaPath(path)
if type(isfile)=="function"and not isfile(metaPath)then return nil end
if type(readfile)~="function"then return nil end
local ok,data=pcall(readfile,metaPath)
if not ok or type(data)~="string"or data==""then return nil end
local decoded=jsonDecode(data)
return type(decoded)=="table"and decoded or nil
end
function CrossAIMusic.writeDownloadedMeta(path,meta)
if type(path)~="string"or path==""or type(writefile)~="function"then return false end
local hs=getHttp()
if not hs then return false end
local src=type(meta)=="table"and meta or{}
local clean={
Title=tostring(src.Title or src.title or src.Name or src.name or""),
Artist=tostring(src.Artist or src.artist or src.Author or src.author or""),
Album=tostring(src.Album or src.album or""),
Duration=tostring(src.Duration or src.duration or""),
Thumbnail=tostring(src.Thumbnail or src.thumbnail or""),
Source=tostring(src.Source or src.source or""),
Url=tostring(src.Url or src.url or""),
Id=tostring(src.Id or src.id or""),
SavedAt=os.time and os.time()or 0,
}
if clean.Title==""and clean.Artist==""and clean.Thumbnail==""then return false end
local ok,encoded=pcall(function()return hs:JSONEncode(clean)end)
if not ok or type(encoded)~="string"then return false end
local okWrite=pcall(writefile,dlMetaPath(path),encoded)
return okWrite==true
end
local function dlEmbeddedCoverAsset(path,info)
if type(info)~="table"or type(info.cover)~="string"or#info.cover<=200 then return nil end
if type(writefile)~="function"then return nil end
local getter=getcustomasset or getsynasset
if type(getter)~="function"then return nil end
ensureFolder(CFG.CoversFolder)
local ext=info.coverExt or".jpg"
if ext~=".jpg"and ext~=".png"then ext=".jpg"end
local coverPath=string.format("%s/%s_id3%s",CFG.CoversFolder,hashOf(path),ext)
if type(isfile)=="function"and isfile(coverPath)then
local okAsset,asset=pcall(getter,coverPath)
if okAsset and type(asset)=="string"and asset~=""then return asset,coverPath end
end
if not pcall(writefile,coverPath,info.cover)then return nil end
local okAsset,asset=pcall(getter,coverPath)
if okAsset and type(asset)=="string"and asset~=""then return asset,coverPath end
return nil,coverPath
end
function CrossAIMusic.listDownloaded(includeSizes)
local stats={
Folder=CFG.Folder,CoversFolder=CFG.CoversFolder,
Count=0,Mp3Bytes=0,Mp3Text="0 B",
CoversCount=0,CoversBytes=0,CoversText="0 B",
TotalBytes=0,TotalText="0 B",
SizesKnown=false,Supported=type(listfiles)=="function",
}
if type(listfiles)~="function"then
return{},stats
end
ensureFolder()
ensureFolder(CFG.CoversFolder)
local files={}
local mp3Bytes,sizesKnown=0,includeSizes==true and type(readfile)=="function"
local okList,list=pcall(listfiles,CFG.Folder)
if okList and type(list)=="table"then
for _,rawPath in ipairs(list)do
local path=tostring(rawPath)
local fileName=dlFileName(path)
if fileName:lower():sub(-4)==".mp3"then
local entry={
Path=path,FileName=fileName,
Title=dlTitleFromFileName(fileName),Artist="",Album="",
Duration="",Thumbnail="",CoverAsset=nil,CoverPath=nil,HasMeta=false,
Size=nil,SizeText="",
}
if includeSizes and type(readfile)=="function"then
local okData,data=pcall(readfile,path)
if okData and type(data)=="string"then
entry.Size=#data
entry.SizeText=dlFormatBytes(#data)
mp3Bytes=mp3Bytes+#data
local info=readID3(data)
if type(info)=="table"then
if info.title and info.title~=""then entry.Title=info.title;entry.HasMeta=true end
if info.artist and info.artist~=""then entry.Artist=info.artist;entry.HasMeta=true end
if info.album and info.album~=""then entry.Album=info.album;entry.HasMeta=true end
local coverAsset,coverPath=dlEmbeddedCoverAsset(path,info)
if coverAsset then entry.CoverAsset=coverAsset;entry.HasMeta=true end
if coverPath then entry.CoverPath=coverPath end
end
else
sizesKnown=false
end
end
local sidecar=CrossAIMusic.readDownloadedMeta(path)
if type(sidecar)=="table"then
entry.HasMeta=true
local sTitle=tostring(sidecar.Title or sidecar.title or"")
local sArtist=tostring(sidecar.Artist or sidecar.artist or"")
local sAlbum=tostring(sidecar.Album or sidecar.album or"")
local sDuration=tostring(sidecar.Duration or sidecar.duration or"")
local sThumb=tostring(sidecar.Thumbnail or sidecar.thumbnail or"")
if sTitle~=""then entry.Title=sTitle end
if sArtist~=""then entry.Artist=sArtist end
if sAlbum~=""then entry.Album=sAlbum end
if sDuration~=""then entry.Duration=sDuration end
if sThumb~=""then entry.Thumbnail=sThumb end
end
files[#files+1]=entry
end
end
end
table.sort(files,function(a,b)
local ta,tb=tostring(a.Title):lower(),tostring(b.Title):lower()
if ta==tb then return tostring(a.FileName):lower()<tostring(b.FileName):lower()end
return ta<tb
end)
local coversCount,coversBytes=0,0
local okCovers,coverList=pcall(listfiles,CFG.CoversFolder)
if okCovers and type(coverList)=="table"then
for _,rawPath in ipairs(coverList)do
local name=dlFileName(rawPath):lower()
if name:sub(-4)==".jpg"or name:sub(-4)==".png"or name:sub(-5)==".jpeg"then
coversCount=coversCount+1
if includeSizes and type(readfile)=="function"then
local okData,data=pcall(readfile,tostring(rawPath))
if okData and type(data)=="string"then coversBytes=coversBytes+#data end
end
end
end
end
stats.Count=#files
stats.Mp3Bytes=mp3Bytes
stats.CoversCount=coversCount
stats.CoversBytes=coversBytes
stats.TotalBytes=mp3Bytes+coversBytes
stats.SizesKnown=sizesKnown
stats.Mp3Text=sizesKnown and dlFormatBytes(mp3Bytes)or(tostring(#files).." bai")
stats.CoversText=sizesKnown and dlFormatBytes(coversBytes)or(tostring(coversCount).." file")
stats.TotalText=sizesKnown and dlFormatBytes(mp3Bytes+coversBytes)or"Chua quet dung luong"
return files,stats
end
function CrossAIMusic.downloadedStats(includeSizes)
local _,stats=CrossAIMusic.listDownloaded(includeSizes==true)
return stats
end
function CrossAIMusic.deleteDownloaded(path)
if type(delfile)~="function"then return false,"Executor khong ho tro delfile"end
local raw=tostring(path or"")
local normalized=raw:gsub("\\","/")
local prefix=tostring(CFG.Folder):gsub("\\","/").."/"
if normalized:sub(1,#prefix)~=prefix then return false,"Duong dan nam ngoai thu muc nhac"end
local rest=normalized:sub(#prefix+1)
if rest==""or rest:find("/",1,true)then return false,"Chi xoa file mp3 truc tiep trong thu muc nhac"end
if rest:lower():sub(-4)~=".mp3"then return false,"Chi xoa duoc file .mp3"end
if type(isfile)=="function"and not isfile(raw)then return false,"File khong con ton tai"end
local ok,err=pcall(delfile,raw)
if not ok then return false,tostring(err)end
pcall(delfile,raw..".json")
for _,ext in ipairs({".jpg",".png"})do
local coverPath=string.format("%s/%s_id3%s",CFG.CoversFolder,hashOf(raw),ext)
if type(isfile)~="function"or isfile(coverPath)then pcall(delfile,coverPath)end
end
return true
end
function CrossAIMusic.clearDownloaded()
local files=CrossAIMusic.listDownloaded(false)
local deleted,failed=0,0
for _,file in ipairs(files)do
local ok=CrossAIMusic.deleteDownloaded(file.Path)
if ok then deleted=deleted+1 else failed=failed+1 end
end
return deleted,failed
end
local function raceUrls(urls,onProgress)
local list=urls or{}
if#list==0 then return nil end
if#list==1 then
return httpGet(list[1])
end
local done,winner=false,nil
local pending=#list
for index,url in ipairs(list)do
task.spawn(function()
local data=httpGet(url)
pending=pending-1
if not done and looksLikeAudio(data)then
done=true
winner=data
if onProgress then onProgress("winner",{index=index,url=url})end
end
end)
end
local waited=0
while not done and pending>0 and waited<240 do
task.wait(0.2)
waited=waited+0.2
end
return winner
end
CrossAIMusic.raceUrls=raceUrls
function CrossAIMusic.fetchFile(key,urls,onProgress,title)
onProgress=onProgress or function()end
if type(writefile)~="function"then
onProgress("error",{reason="executor thiếu writefile"})
return nil
end
local getter=getcustomasset or getsynasset
if type(getter)~="function"then
onProgress("error",{reason="executor thiếu getcustomasset/getsynasset"})
return nil
end
local candidates=CrossAIMusic.cacheCandidates(key,title)
for _,path in ipairs(candidates)do
if type(isfile)=="function"and isfile(path)then
local okAsset,asset=pcall(getter,path)
if okAsset and type(asset)=="string"and asset~=""then
onProgress("cache",{path=path})
return asset,path
end
end
end
ensureFolder()
local list=urls or{}
onProgress("fetch",{url=list[1],count=#list})
local data=raceUrls(list,onProgress)
if looksLikeAudio(data)then
local asset,path=CrossAIMusic.saveBytes(key,data,title)
if asset then return asset,path end
end
onProgress("error",{reason="không tải được file mp3"})
return nil
end
function CrossAIMusic.assetFor(track,onProgress)
onProgress=onProgress or function()end
local urls=nil
if track.directUrl and track.source=="audius"then
local res=CrossAIMusic.request(track.directUrl,"GET",{["accept"]="application/json"},nil,20)
if res then
if res.StatusCode==200 and type(res.Body)=="string"and res.Body:sub(1,1)=="{"then
local info=jsonDecode(res.Body)
if type(info)=="table"and type(info.data)=="string"and info.data~=""then
urls={info.data}
end
elseif res.StatusCode==200 and type(res.Body)=="string"and#res.Body>1024 then
urls={track.directUrl}
track._inline=res.Body
elseif res.StatusCode and res.StatusCode>=300 and res.StatusCode<400 and type(res.Headers)=="table"then
local loc=res.Headers.Location or res.Headers.location
if type(loc)=="string"and loc~=""then urls={loc}end
end
end
if not urls then urls={track.directUrl}end
end
if not urls then
local target=track.url or track.Url
if not target or target==""then
target="https://youtu.be/"..tostring(track.id or track.Id)
end
urls=CrossAIMusic.download(target,onProgress)
end
if not urls then return nil end
local key=track.id or track.Id or track.url or track.Url or"track"
local title=track.name or track.Name or track.title
if track._inline and type(writefile)=="function"then
local asset,path=CrossAIMusic.saveBytes(key,track._inline,title)
track._inline=nil
if asset then return asset,path end
end
return CrossAIMusic.fetchFile(key,urls,onProgress,title)
end
function CrossAIMusic.resolve(prompt,onState)
onState=onState or function()end
local plan=CrossAIMusic.parse(prompt)
onState("parse",{plan=plan})
local results=CrossAIMusic.search(plan,function(state,payload)
if state=="ai_wait"then
local secs=tonumber(payload.waitFor)or 45
return{text=t(string.format("AI trực tuyến đang chờ hạn mức miễn phí (%d giây) — mình dùng AI offline trước nhé.",secs),
string.format("Online AI cooling down (%ds) — using offline AI.",secs)),mood="think"}
end
if state=="error"then onState("error",{stage="search",payload=payload})end
end,prompt)
if#results==0 then return nil end
local limit=math.min(#results,math.max(1,CFG.RaceTracks or 1))
local finished,won=0,false
local bestAsset,bestTrack,bestPath
for rank=1,limit do
local track=results[rank]
task.spawn(function()
if won then
finished=finished+1
return
end
onState("trying",{track=track,rank=rank})
local ok,asset,path=pcall(CrossAIMusic.assetFor,track,function(state,payload)
if not won then
onState("download",{state=state,track=track,rank=rank,payload=payload})
end
end)
finished=finished+1
if ok and type(asset)=="string"and asset~=""and not won then
won=true
bestAsset,bestTrack,bestPath=asset,track,path
end
end)
end
local waited=0
while not won and finished<limit and waited<CFG.DownloadTimeout do
task.wait(0.1)
waited=waited+0.1
end
if won then
bestTrack.asset=bestAsset
bestTrack.path=bestPath
onState("ready",{track=bestTrack})
return bestAsset,bestTrack
end
onState("error",{stage="download",payload={reason="tất cả kết quả đều thất bại"}})
return nil
end
function CrossAIMusic.rowLabel(track,index)
index=tonumber(index)or 1
local title=trim(track.name or track.Name or"Unknown")
local who=trim(track.author or track.Artist or"")
if#title>52 then title=trim(title:sub(1,52)).."…"end
if who~=""then
if#who>26 then who=trim(who:sub(1,26)).."…"end
return string.format("%02d. %s — %s",index,title,who)
end
return string.format("%02d. %s",index,title)
end
function CrossAIMusic.rowValue(track,index)
index=tonumber(index)or 1
local src=trim(track.source or track.Source or"yt")
local id=trim(track.id or track.Id or track.url or track.Url or"")
if id==""then id=tostring(index)end
return string.format("#%02d %s:%s",index,src,id)
end
function CrossAIMusic.rowData(track,index)
track=track or{}
index=tonumber(index)or 1
local secs=CrossAIMusic.durationSeconds(track.duration or track.Duration or"")
local durText=""
if secs>0 then
durText=string.format("%d:%02d",math.floor(secs/60),secs%60)
elseif track.duration and tostring(track.duration)~=""then
durText=tostring(track.duration)
end
local artist=trim(track.author or track.Artist or"")
local src=tostring(track.source or track.Source or""):upper()
if src=="YOUTUBE"then src="YT"end
return{
Index=index,
Title=trim(track.name or track.Name or"Unknown"),
Artist=artist,
Duration=durText,
Thumbnail=tostring(track.thumbnail or track.Thumbnail or""),
Source=src,
Value=CrossAIMusic.rowValue(track,index),
}
end
function CrossAIMusic.say(state,payload,vi)
payload=payload or{}
vi=vi~=false
local function t(viText,enText)return vi and viText or enText end
if state=="thinking"then
local q=trim(payload.query or"")
if q~=""then
return{text=t("Đang tìm cho bạn: "..q.." …","Searching for: "..q.." …"),mood="think"}
end
return{text=t("Đang nghe yêu cầu của bạn…","Reading your request…"),mood="think"}
end
if state=="searching"then
return{text=t("Đang lùng nhạc trên nhiều nguồn…","Searching across sources…"),mood="think"}
end
if state=="found"then
local n=tonumber(payload.count)or 0
return{text=t(string.format("Tìm được %d bài. Bạn chọn bài nào?",n),
string.format("Found %d tracks. Which one?",n)),mood="happy"}
end
if state=="none"then
local q=trim(payload.query or"")
if q~=""then
return{text=t("Không thấy bài nào khớp \""..q.."\". Bạn thử mô tả khác xem, ví dụ: \"lofi buổi tối\" hay \"nhạc buồn piano\".",
"No match for \""..q.."\". Try a different description."),mood="sad"}
end
return{text=t("Không thấy bài nào phù hợp. Bạn mô tả rõ hơn giúp mình nhé.",
"No matching track. Could you describe it more?"),mood="sad"}
end
if state=="error"then
return{text=t("Mạng hoặc nguồn nhạc đang lỗi, mình thử lại sau nhé.","Network or source error, try again later."),mood="sad"}
end
if state=="trying"then
local rank=tonumber(payload.rank)or 1
local name=trim((payload.track and payload.track.name)or"")
if name~=""then
return{text=t(string.format("Thử tải bài %d: %s (%d%%)",rank,name,tonumber(payload.percent)or 0),
string.format("Downloading #%d: %s",rank,name)),mood="think"}
end
return{text=t(string.format("Đang thử bài số %d…",rank),string.format("Trying track #%d…",rank)),mood="think"}
end
if state=="progress"then
local pct=math.floor((tonumber(payload.percent)or 0)*100+0.5)
return{text=t(string.format("Đang tải… %d%%",pct),string.format("Downloading… %d%%",pct)),mood="think"}
end
if state=="retry"then
return{text=t("Bài đó lỗi, mình thử lại bài gần giống nhé…","That one failed, trying another…"),mood="think"}
end
if state=="ready"then
local name=trim(payload.name or"")
local who=trim(payload.author or"")
if who~=""then
return{text=t("Đang phát: "..name.." — "..who,"Now playing: "..name.." — "..who),mood="happy"}
end
return{text=t("Đang phát: "..name,"Now playing: "..name),mood="happy"}
end
return nil
end
function CrossAIMusic.enrich(track)
if type(track)~="table"then return track end
if not track.CoverAsset and track.thumbnail and track.thumbnail~=""then
pcall(function()CrossAIMusic.coverAsset(track)end)
end
if(not track.name or track.name==""or track.name=="Unknown")or(not track.author or track.author=="")then
local key=track.id or track.Id or track.url or track.Url
local title=track.name or track.Name
local data=readExisting(CrossAIMusic.cacheCandidates(key,title))
if data then
local id3=readID3(data)
if id3 then
if(not track.name or track.name==""or track.name=="Unknown")and id3 .title then
track.name=id3 .title
end
if(not track.author or track.author=="")and id3 .artist then
track.author=id3 .artist
end
if id3 .album and(not track.album or track.album=="")then track.album=id3 .album end
end
end
end
local bits={}
if track.author and track.author~=""then bits[#bits+1]=track.author end
if track.album and track.album~=""and track.album~=track.author then bits[#bits+1]=track.album end
local secs=CrossAIMusic.durationSeconds(track.duration or"")
if secs<=0 and track.durationSec then secs=track.durationSec end
if secs>0 then
bits[#bits+1]=string.format("%d:%02d",math.floor(secs/60),secs%60)
end
track.desc=table.concat(bits," · ")
local srcLabel=tostring(track.source or""):upper()
if srcLabel=="YOUTUBE"then srcLabel="YT"end
track.sourceLabel=srcLabel
return track
end
return CrossAIMusic
end
local Remote={
Folder="xNgotLibrary/Music",
State="idle",
Count=0,
Busy=false,
Listeners={},
Query="",
Plan=nil,
Progress=0,
Error=nil,
Rows={},
Labels={},
}
Music.Remote=Remote
local Http
pcall(function()
Http=game:GetService("HttpService")
end)
local Covers={
{rgb(255,55,95),rgb(255,159,10)},
{rgb(10,132,255),rgb(191,90,242)},
{rgb(48,209,88),rgb(64,200,224)},
{rgb(191,90,242),rgb(255,55,95)},
{rgb(255,159,10),rgb(255,214,10)},
{rgb(64,200,224),rgb(88,86,214)},
}
Remote.Supported=function()
return type(writefile)=="function"
and(type(getcustomasset)=="function"or type(getsynasset)=="function")
end
Remote.Notify=function()
for _,listener in ipairs(Remote.Listeners)do
pcall(listener)
end
end
local function applyResults(results,plan)
while#TRACKS>0 do
table.remove(TRACKS,#TRACKS)
end
local Engine=Remote.Engine or CrossAIMusic
Remote.Rows={}
Remote.Labels={}
for index,item in ipairs(results)do
local cover=Covers[(index-1)%#Covers+1]
if Engine and type(Engine.enrich)=="function"then
pcall(function()Engine.enrich(item)end)
end
local row=Engine and type(Engine.rowData)=="function"
and Engine.rowData(item,index)
or{Index=index,Title=tostring(item.name or"Unknown"),Artist=tostring(item.author or""),
Duration=tostring(item.duration or""),Thumbnail=tostring(item.thumbnail or""),
Source=tostring(item.source or""),Value="#"..index}
local desc=row.Artist
if row.Duration~=""then
desc=(desc~=""and(desc.." · "..row.Duration)or row.Duration)
end
if row.Source~=""then
desc=desc~=""and(desc.." · "..row.Source)or row.Source
end
Remote.Rows[index]={
Index=index,
Value=row.Value,
Title=row.Title,
Artist=row.Artist,
Duration=row.Duration,
Source=row.Source,
Thumbnail=row.Thumbnail,
CoverAsset=item.coverAsset or item.CoverAsset,
Desc=desc,
}
Remote.Labels[row.Value]=Engine and type(Engine.rowLabel)=="function"
and Engine.rowLabel(item,index)
or(tostring(index)..". "..row.Title)
TRACKS[#TRACKS+1]={
Name=item.name,
Artist=item.author or"",
Mood=desc,
Remote=true,
Source=item.source,
Duration=item.duration,
Thumbnail=item.thumbnail,
thumbnail=item.thumbnail,
CoverAsset=item.coverAsset or item.CoverAsset,
Url=item.url,
Id=item.id,
Asset=item.asset,
DirectId=item.id,
CachedPath=item.path,
FileName=item.fileName,
Downloaded=item.downloaded==true,
Desc=desc,
Value=row.Value,
Row=Remote.Rows[index],
A=cover[1],
B=cover[2],
}
end
if Music.Playing then
Music.Playing=false
Music.Loading=false
pcall(function()currentSound:Stop()end)
Music.Position=0
Music.Clock=0
end
if#TRACKS>0 then
if Music.Index<1 then Music.Index=1 end
if Music.Index>#TRACKS then Music.Index=#TRACKS end
end
pcall(function()Music.Sync()end)
Remote.Count=#results
Remote.Plan=plan
Remote.State=#results>0 and"ready"or"empty"
local coverOn=true
pcall(function()
local cfgApi=_G.xNgotMusicConfig
if cfgApi and type(cfgApi.Get)=="function"then coverOn=cfgApi:Get("coverArt")~=false end
end)
if coverOn and Engine and type(Engine.prefetchCovers)=="function"then
pcall(function()
Engine.prefetchCovers(results,function(item,asset)
for i,track in ipairs(TRACKS)do
if track.Remote and item and track.Url==item.url and track.Id==item.id then
track.CoverAsset=asset
if Remote.Rows[i]then Remote.Rows[i].CoverAsset=asset end
break
end
end
Remote.Notify()
end)
end)
end
end
Remote.Say=function(state,payload)
local vi=Settings.Language~="en"
local fn=Remote.Engine and Remote.Engine.say or(CrossAIMusic and CrossAIMusic.say)
if type(fn)=="function"then
local ok,res=pcall(fn,state,payload,vi)
if ok and type(res)=="table"then return res end
end
return nil
end
Music.Covers=Covers
Music.AddTrack=function(track)
if type(track)~="table"then return nil end
TRACKS[#TRACKS+1]=track
return#TRACKS
end
Music.PlayAsset=function(track)
if type(track)~="table"then return nil end
local index=Music.AddTrack(track)
if not index then return nil end
loadToken=loadToken+1
Music.Index=index
currentSound:Stop()
currentSound.SoundId=track.Asset or""
currentSound.TimePosition=0
currentSound.PlaybackSpeed=Music.Tempo
currentSound.Volume=Music.Volume/100
Music.Position=0
Music.Clock=0
Music.Phrase=0
Music.Loading=false
Music.Playing=true
Music.Sync()
broadcast()
if track.Asset then
waitAndPlay(loadToken,track.Asset)
end
return index
end
Remote.Load=function()
if Remote.Busy then
notify("Music search","A search is already running - please wait...","warn",2.5,true)
return
end
local Engine=Remote.Engine
if not Engine then
notify("Music",(Settings.Language=="en")and"Music AI is not ready yet"
or"AI tìm nhạc chưa sẵn sàng","warn",3,true)
return
end
Remote.Busy=true
Remote.State="searching"
Remote.Notify()
if Remote.Query and Remote.Query~=""then
notify("Music search",string.format("Searching for \"%s\"...",tostring(Remote.Query)),"info",3,true)
end
task.spawn(function()
local prompt=Remote.Query
if not prompt or prompt==""then
local loaded=0
local okLoaded,result=pcall(function()return Remote.LoadDownloaded()end)
if okLoaded then loaded=tonumber(result)or 0 end
Remote.Busy=false
if loaded<=0 then
Remote.State="localempty"
Remote.Notify()
end
return
end
local plan=Engine.parse(prompt)
local results=Engine.search(plan,function(state,payload)
if state=="searching"then
Remote.State="searching"
Remote.Notify()
elseif state=="ai"then
Remote.State="searching"
Remote.Notify()
elseif state=="error"then
Remote.State="failed"
Remote.Error=tostring(payload and payload.reason or"unknown")
Remote.Notify()
end
end,prompt)
Remote.Busy=false
if not gui.Parent then
return
end
if#results==0 then
if Remote.State~="failed"then Remote.State="empty"end
Remote.Notify()
local msg=Remote.Say("none",{query=plan.query})
notify(
(Settings.Language=="en")and"Music search"or"Tìm nhạc",
(msg and msg.text)or("Không có kết quả cho: "..tostring(plan.query)),
"warn",4,true
)
return
end
applyResults(results,plan)
Remote.CatalogSource="search"
Remote.Notify()
local found=Remote.Say("found",{count=#results,query=plan.query})
notify(
(Settings.Language=="en")and"Music found"or"Đã tìm thấy nhạc",
string.format(
(Settings.Language=="en")and"%d tracks · \"%s\""or"%d bài · \"%s\"",
#results,tostring(plan.query)
)..((found and found.text)and(" — "..found.text)or""),
"success",3,true
)
end)
end
Remote.Search=function(prompt)
Remote.Query=tostring(prompt or"")
Remote.State="idle"
Remote.Error=nil
Remote.Load()
end
Remote.DownloadedFiles={}
Remote.DownloadedStats=nil
Remote.CatalogSource=nil
Remote.ScanDownloaded=function(includeSizes)
local Engine=Remote.Engine or CrossAIMusic
if Engine and type(Engine.listDownloaded)=="function"then
local files,stats=Engine.listDownloaded(includeSizes==true)
files=type(files)=="table"and files or{}
stats=type(stats)=="table"and stats or{}
Remote.DownloadedFiles=files
Remote.DownloadedStats=stats
return files,stats
end
local files,stats={},{
Folder=Remote.Folder,Count=0,TotalBytes=0,TotalText="0 B",
Mp3Text="0 B",CoversText="0 B",CoversCount=0,Supported=false,
}
Remote.DownloadedFiles,Remote.DownloadedStats=files,stats
return files,stats
end
Remote.LoadDownloaded=function()
local files=Remote.ScanDownloaded(true)
if#files==0 then
if Remote.CatalogSource=="downloaded"then
for i=#TRACKS,1,-1 do
if TRACKS[i].Downloaded then table.remove(TRACKS,i)end
end
Remote.Rows,Remote.Labels={},{}
if Music.Playing then
Music.Playing=false
Music.Loading=false
pcall(function()currentSound:Stop()end)
end
if#TRACKS>0 then
Music.Index=math.clamp(Music.Index,1,#TRACKS)
pcall(function()Music.Sync()end)
end
end
Remote.State="localempty"
Remote.Count=0
Remote.Error=nil
Remote.Notify()
return 0
end
local items={}
for index,file in ipairs(files)do
items[index]={
name=file.Title,author=file.Artist or"",duration=file.Duration or"",thumbnail=file.Thumbnail or"",
coverAsset=file.CoverAsset,album=file.Album or"",
source="local",url="",id=file.Path,
path=file.Path,fileName=file.FileName,downloaded=true,
}
end
applyResults(items,{query="__downloaded__"})
Remote.CatalogSource="downloaded"
Remote.State="ready"
Remote.Query=""
Remote.Error=nil
Remote.Notify()
return#files
end
local nextPrefetch=nil
local prefetchBusy=false
local attemptedToken=nil
local function fetchRemote(token,track)
if not Remote.Supported()then
Music.Playing=false
Music.Loading=false
Music.Sync()
broadcast()
notify("Music unavailable",
"Executor requires writefile and getcustomasset/getsynasset to play PoW MP3",
"warn",4)
return
end
if track.CachedPath and type(track.CachedPath)=="string"and track.CachedPath~=""then
if type(isfile)=="function"and not isfile(track.CachedPath)then
Music.Playing=false
Music.Loading=false
Music.Sync()
broadcast()
notify((Settings.Language=="en")and"File missing"or"File da bi xoa",
tostring(track.FileName or track.Name or""),"warn",3,true)
return
end
local getter=getcustomasset or getsynasset
if type(getter)=="function"then
local okAsset,asset=pcall(getter,track.CachedPath)
if okAsset and type(asset)=="string"and asset~=""then
Music.Loading=false
currentSound.SoundId=asset
waitAndPlay(token,asset)
return
end
end
end
Remote.Progress=0
Remote.Label=tostring(track.Name or track.Title or track.Id or"Download")
Remote.FileName=tostring(track.FileName or(Remote.Label..".mp3"))
local function downloadLabel()
return Remote.Label
end
if type(Music.setDownloadState)=="function"then
pcall(Music.setDownloadState,0,Remote.Label)
end
Activities.Download={
Title="Download",
Label=Remote.Label,
FileName=Remote.FileName,
Color=Static.Blue,
Value=function()
return string.format("%d%%",math.floor((Remote.Progress or 0)*100+0.5))
end,
Short=function()
return string.format("%d%%",math.floor((Remote.Progress or 0)*100+0.5))
end,
Sub=downloadLabel,
Ring=function()return Remote.Progress or 0 end,
RingMode="fill",
}
refreshActivity()
task.spawn(function()
Music.Loading=true
broadcast()
local lookup={
id=track.Id,
url=track.Url,
source=track.Source or"youtube",
directUrl=nil,
}
if lookup.source=="audius"and lookup.id then
lookup.directUrl="https://api.audius.co/v1/tracks/"
..tostring(lookup.id):gsub("^audius:","").."/stream"
end
local ok,asset,savedPath=pcall(function()
return Remote.Engine.assetFor(lookup,function(state,payload)
if state=="progress"and payload and payload.percent then
Remote.Progress=payload.percent
if type(Music.setDownloadState)=="function"then
pcall(Music.setDownloadState,payload.percent,Remote.Label)
end
end
if state=="cache"and payload and payload.path then
Remote.FileName=tostring(payload.path):match("([^/]+)$")or Remote.FileName
end
end)
end)
Activities.Download=nil
if type(Music.clearDownloadState)=="function"then
pcall(Music.clearDownloadState)
end
refreshActivity()
if token~=loadToken or not gui.Parent then
return
end
Music.Loading=false
if ok and type(asset)=="string"and asset~=""then
if type(savedPath)=="string"and savedPath~=""and Remote.Engine and type(Remote.Engine.writeDownloadedMeta)=="function"then
pcall(Remote.Engine.writeDownloadedMeta,savedPath,{
Title=track.Name,Artist=track.Artist,Duration=track.Duration,
Thumbnail=track.Thumbnail,Source=track.Source,Url=track.Url,Id=track.Id,
})
track.CachedPath=savedPath
track.FileName=tostring(savedPath):match("([^/]+)$")or track.FileName
track.Downloaded=true
end
currentSound.SoundId=asset
waitAndPlay(token,asset)
else
Music.Playing=false
Music.Fails=Music.Fails+1
Music.Sync()
broadcast()
local fail=Remote.Say("error",{})
notify(
(Settings.Language=="en")and"Cannot download track"or"Không tải được bài",
(fail and fail.text)or"Kiểm tra kết nối hoặc executor",
"warn",4,true
)
if Music.Auto and Music.Fails<3 then
task.wait(0.8)
if token==loadToken and gui.Parent then
Music.Next(1)
end
end
end
end)
end
CrossAIMusic=__xNgotCreateAIMusicEngine(Http)
Remote.Engine=CrossAIMusic
Remote.Folder=CrossAIMusic.Config.Folder
pcall(function()
if Settings then Settings.MusicAiOnline=false end
end)
_G.CrossAIMusic=CrossAIMusic
_G.xNgotMusicEngine=CrossAIMusic
pcall(function()
local api=_G.xNgotMusicConfig
if api and type(api.Apply)=="function"then api.Apply()end
end)
local function startLoad(token,track)
if not track then return end
if not track.Remote then
waitAndPlay(token,currentSound.SoundId)
return
end
local job=nextPrefetch
if job and job.track==track and job.pending then
Music.Loading=true
task.spawn(function()
local deadline=os.clock()+(tonumber(Remote.Engine.Config.DownloadTimeout)or 200)
while job.pending and token==loadToken and gui.Parent and os.clock()<deadline do task.wait(0.1)end
if token~=loadToken or not gui.Parent then return end
if track.Asset then currentSound.SoundId=track.Asset;waitAndPlay(token,track.Asset)
else fetchRemote(token,track)end
end)
elseif track.Asset then
currentSound.SoundId=track.Asset
waitAndPlay(token,track.Asset)
else
fetchRemote(token,track)
end
end
function Music.Select(index,play)
Music.Index=(index-1)%#TRACKS+1
local track=TRACKS[Music.Index]
loadToken=loadToken+1
currentSound:Stop()
Music.Playing=play and true or false
Music.Loading=false
Music.Position=0
Music.Clock=0
Music.Phrase=0
currentSound.SoundId=track.Remote and""or("rbxassetid://"..track.Id)
currentSound.TimePosition=0
currentSound.PlaybackSpeed=Music.Tempo
currentSound.Volume=Music.Volume/100
Music.Sync()
broadcast()
if play then
startLoad(loadToken,track)
end
end
function Music.Toggle()
if Music.Playing then
loadToken=loadToken+1
Music.Playing=false
Music.Loading=false
tween(currentSound,0.2,{Volume=0})
task.delay(0.22,function()
if not Music.Playing then
currentSound:Pause()
end
end)
Music.Sync()
broadcast()
return
end
if currentSound.IsLoaded and currentSound.TimePosition>0 then
currentSound.Volume=0
currentSound.PlaybackSpeed=Music.Tempo
currentSound:Resume()
tween(currentSound,0.6,{Volume=Music.Volume/100},Enum.EasingStyle.Sine)
Music.Playing=true
Music.Sync()
broadcast()
else
loadToken=loadToken+1
Music.Playing=true
Music.Sync()
startLoad(loadToken,TRACKS[Music.Index])
end
end
function Music.Next(direction)
if Music.Shuffle and direction>0 and#TRACKS>1 then
local nextIndex=Music.Index
while nextIndex==Music.Index do
nextIndex=math.random(1,#TRACKS)
end
Music.Select(nextIndex,true)
else
Music.Select(Music.Index+direction,true)
end
end
function Music.SetVolume(value)
Music.Volume=math.clamp(value,0,100)
currentSound.Volume=Music.Volume/100
end
function Music.SetTempo(value)
Music.Tempo=math.clamp(value,0.7,1.4)
currentSound.PlaybackSpeed=Music.Tempo
end
function Music.Seek(alpha)
local length=currentSound.TimeLength
if length>0 then
currentSound.TimePosition=math.clamp(alpha,0,1)*length
Music.Position=currentSound.TimePosition
end
end
function Music.Duration()
return math.max(0,currentSound.TimeLength)
end
currentSound.Ended:Connect(function()
if not Music.Playing then
return
end
if Music.RepeatOne then
Music.Select(Music.Index,true)
elseif Music.Auto then
local job=nextPrefetch
if Remote.Engine.Config.PrefetchNext~=false and job and job.token==loadToken and job.current==TRACKS[Music.Index]
and job.shuffle==Music.Shuffle and TRACKS[job.index]==job.track then
Music.Select(job.index,true)
else
Music.Next(1)
end
else
Music.Playing=false
Music.Position=0
Music.Sync()
broadcast()
end
end)
Music.Sync()
task.spawn(function()
while gui.Parent do
task.wait(0.5)
if Music.Playing and Music.Auto and not Music.RepeatOne and not Music.Loading and#TRACKS>1
and Remote.Engine.Config.PrefetchNext~=false and currentSound.TimeLength>0
and currentSound.TimePosition>=currentSound.TimeLength*0.5
and attemptedToken~=loadToken and not prefetchBusy then
local nextIndex=Music.Index%#TRACKS+1
if Music.Shuffle then
nextIndex=math.random(1,#TRACKS-1)
if nextIndex>=Music.Index then nextIndex=nextIndex+1 end
end
local candidate=TRACKS[nextIndex]
local job={token=loadToken,current=TRACKS[Music.Index],index=nextIndex,
track=candidate,shuffle=Music.Shuffle,pending=true}
nextPrefetch,attemptedToken,prefetchBusy=job,loadToken,true
notify(Settings.Language=="en"and"Up next"or"Bài tiếp theo",
tostring(candidate.Name or"Track")..(Settings.Language=="en"and" · preparing"or" · đang chuẩn bị"),"info",3,true)
task.spawn(function()
local ok,asset,path=pcall(function()
if candidate.Asset then return candidate.Asset,candidate.CachedPath end
if not candidate.Remote then return"rbxassetid://"..tostring(candidate.Id)end
if candidate.CachedPath then
local getter=getcustomasset or getsynasset
if type(getter)=="function"and(type(isfile)~="function"or isfile(candidate.CachedPath))then
local got,cached=pcall(getter,candidate.CachedPath)
if got and type(cached)=="string"and cached~=""then return cached,candidate.CachedPath end
end
end
if not Remote.Supported()then return nil end
local lookup={id=candidate.Id,url=candidate.Url,source=candidate.Source or"youtube",name=candidate.Name}
if lookup.source=="audius"and lookup.id then
lookup.directUrl="https://api.audius.co/v1/tracks/"..tostring(lookup.id):gsub("^audius:","").."/stream"
end
return Remote.Engine.assetFor(lookup,function()end)
end)
if ok and type(asset)=="string"and asset~=""then
if candidate.Remote then candidate.Asset=asset end
if type(path)=="string"and path~=""then
candidate.CachedPath,candidate.Downloaded=path,true
candidate.FileName=path:match("([^/]+)$")or candidate.FileName
if Remote.Engine.writeDownloadedMeta then
pcall(Remote.Engine.writeDownloadedMeta,path,{Title=candidate.Name,Artist=candidate.Artist,
Duration=candidate.Duration,Thumbnail=candidate.Thumbnail,Source=candidate.Source,Url=candidate.Url,Id=candidate.Id})
end
end
local sound
pcall(function()
sound=Instance.new("Sound")
sound.SoundId=asset
sound.Parent=SoundService
game:GetService("ContentProvider"):PreloadAsync({sound})
end)
if sound then pcall(function()sound:Destroy()end)end
end
job.pending,prefetchBusy=false,false
end)
end
end
end)
Hooks.Register(function(dt)
if not Music.Playing then return end
local levels=Music.Levels
local loudness=Music.Playing and math.clamp(currentSound.PlaybackLoudness/850,0,1)or 0
for index=1,5 do
local wave=0.18+0.82*math.abs(math.sin(os.clock()*(3.2+index*0.83)+index*1.4))
local target=Music.Playing and math.clamp(loudness*wave+0.04,0,1)or 0
levels[index]=levels[index]+(target-levels[index])*math.clamp(dt*10,0,1)
end
Music.Position=currentSound.TimePosition
if Music.Playing and Island.Live and Island.Live.Media then
for index,bar in ipairs(Media.Bars)do
local level=math.clamp(levels[index]+0.08,0,1)
bar.Size=UDim2 .fromOffset(3,3+15*level)
end
end
end,2)
gui.Destroying:Connect(function()
pcall(function()
currentSound:Stop()
currentSound:Destroy()
group:Destroy()
end)
end)
end
do
local PAGE_ORDER={"Home","Music","Cross","Timer","Stopwatch","Download"}
local PAGE_TITLES={Home="Tổng quan",Music="Âm nhạc",Timer="Hẹn giờ",Stopwatch="Bấm giờ",Download="Tải xuống",Cross="Cross"}
local PAGE_W=ISLAND.ExpandW
local PAGE_H=ISLAND.ExpandH
local DOCK_Y=PAGE_H-40
local SWIPE=44
local IDLE_COLLAPSE=20
local View={
Pages={},
Tabs={},
Updaters={},
Quick={},
Current="Home",
Touched=0,
Shown={},
BubbleText="",
BubbleAt=0,
Toasts={},
ToastBusy=false,
ToastSkip=false,
ToastToken=0,
Gesture=nil,
SeekStamp=0,
TickAt=0,
DockLang="",
Inset=36,
}
pcall(function()
View.Inset=game:GetService("GuiService"):GetGuiInset().Y
end)
local function pageIndex(key)
for index,name in ipairs(PAGE_ORDER)do
if name==key then
return index
end
end
return 1
end
View.group=new("CanvasGroup",{
Name="Expanded",
AnchorPoint=Vector2 .new(0.5,0),
Position=UDim2 .new(0.5,0,0,0),
Size=UDim2 .fromOffset(PAGE_W,PAGE_H),
BackgroundTransparency=1,
GroupTransparency=1,
Visible=false,
Parent=Media.Content,
})
View.sink=new("TextButton",{
Name="Sink",
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
BorderSizePixel=0,
AutoButtonColor=false,
Text="",
ZIndex=1,
Parent=View.group,
})
local function fmt(seconds)
seconds=math.max(0,seconds)
return string.format("%d:%02d",math.floor(seconds/60),math.floor(seconds%60))
end
local function put(label,value)
if label.Text~=value then
label.Text=value
end
end
local function label(parent,props)
props.TextScaled=false
props.Parent=parent
props.TextColor3=props.TextColor3 or Static.White
props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
return text(props)
end
local function raw(item)
item:SetAttribute("BoncutiRaw",true)
return item
end
local function makePage(key)
local page=new("CanvasGroup",{
Name=key,
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
GroupTransparency=1,
Visible=false,
ZIndex=2,
Parent=View.group,
})
View.Pages[key]=page
return page
end
local function pressable(button)
local scale=new("UIScale",{Parent=button})
local spring=Spring.new(1,600,30,function(value)
scale.Scale=value
end,0.001)
local pressInput
button.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then pressInput=input end
end)
track(UserInputService.InputEnded:Connect(function(input)
if input==pressInput or(pressInput and pressInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)then
pressInput=nil
spring:Set(1)
end
end))
button.MouseButton1Down:Connect(function()
spring:Set(0.92)
end)
button.MouseButton1Up:Connect(function()
spring:Set(1)
end)
button.MouseLeave:Connect(function()
spring:Set(1)
end)
return spring
end
local function touch(callback)
return function()
View.Touched=os.clock()
playSound("click")
callback()
end
end
local function shine(parent,radius,amount)
local gloss=box({
Name="Shine",
Size=UDim2 .fromScale(1,1),
BackgroundColor3=Static.White,
ZIndex=4,
Parent=parent,
})
corner(radius,gloss)
new("UIGradient",{
Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,amount or 0.84),
NumberSequenceKeypoint.new(0.55,1),
NumberSequenceKeypoint.new(1,1),
}),
Rotation=90,
Parent=gloss,
})
return gloss
end
local function action(parent,x,y,w,h,caption,color,callback)
local radius=math.floor(h/2.4)
local button=box({
Class="TextButton",
Position=UDim2 .fromOffset(x,y),
Size=UDim2 .fromOffset(w,h),
BackgroundColor3=color or Static.White,
BackgroundTransparency=color and 0 or 0.88,
AutoButtonColor=false,
Text=translate(caption),
FontFace=Fonts.Semibold,
TextSize=13,
TextColor3=Static.White,
ZIndex=5,
Parent=parent,
})
corner(radius,button)
stroke(button,Static.White,color and 0.8 or 0.9,1)
shine(button,radius,color and 0.82 or 0.9)
pressable(button)
button.MouseButton1Click:Connect(touch(callback))
return button
end
local function icon(parent,kind,x,y,size,color)
local holder=new("Frame",{
Name="Icon",
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .fromOffset(x,y),
Size=UDim2 .fromOffset(size,size),
BackgroundTransparency=1,
ZIndex=6,
Parent=parent,
})
local function add(px,py,pw,ph,radius)
local part=new("Frame",{
Position=UDim2 .fromOffset(px,py),
Size=UDim2 .fromOffset(pw,ph),
BackgroundColor3=color,
BorderSizePixel=0,
ZIndex=6,
Parent=holder,
})
if radius then
new("UICorner",{CornerRadius=UDim.new(0,radius),Parent=part})
end
end
local function wedge(origin,width,height,mirrored)
local steps=math.max(6,math.floor(width*1.5+0.5))
local step=width/steps
for index=0,steps-1 do
local along=(index+0.5)/steps
local tall=math.max(height*(mirrored and along or(1-along)),1)
add(origin+index*step,(size-tall)/2,step+0.5,tall)
end
end
if kind=="play"then
wedge(size*0.24,size*0.68,size*0.8,false)
elseif kind=="pause"then
local bar=size*0.22
add(size*0.2,size*0.12,bar,size*0.76,bar*0.45)
add(size*0.58,size*0.12,bar,size*0.76,bar*0.45)
elseif kind=="next"then
wedge(size*0.1,size*0.52,size*0.64,false)
add(size*0.68,size*0.18,size*0.14,size*0.64,1)
elseif kind=="prev"then
add(size*0.18,size*0.18,size*0.14,size*0.64,1)
wedge(size*0.38,size*0.52,size*0.64,true)
end
return holder
end
local function rail(parent,x,y,w,h,color,knob)
local track_=box({
Position=UDim2 .fromOffset(x,y),
Size=UDim2 .fromOffset(w,h),
BackgroundColor3=Static.White,
BackgroundTransparency=0.82,
Parent=parent,
})
corner(h/2,track_)
local fill=box({
Size=UDim2 .new(0,0,1,0),
BackgroundColor3=color,
Parent=track_,
})
corner(h/2,fill)
local dot
if knob then
dot=box({
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .new(1,0,0.5,0),
Size=UDim2 .fromOffset(knob,knob),
BackgroundColor3=Static.White,
ZIndex=3,
Parent=fill,
})
corner(knob/2,dot)
end
return track_,fill,dot
end
local home=makePage("Home")
View.clock=raw(label(home,{
Position=UDim2 .fromOffset(20,12),
Size=UDim2 .fromOffset(170,46),
Text="--:--",
FontFace=Fonts.Bold,
TextSize=40,
}))
View.date=raw(label(home,{
Position=UDim2 .fromOffset(22,58),
Size=UDim2 .fromOffset(170,16),
Text="",
FontFace=Fonts.Medium,
TextSize=12,
TextColor3=Static.LightGray,
}))
local function badge(parent,x,y)
local frame=box({
Position=UDim2 .fromOffset(x,y),
Size=UDim2 .fromOffset(106,26),
BackgroundColor3=Static.White,
BackgroundTransparency=0.88,
Parent=parent,
})
corner(13,frame)
stroke(frame,Static.White,0.92,1)
local dot=box({
Position=UDim2 .fromOffset(11,10),
Size=UDim2 .fromOffset(6,6),
BackgroundColor3=Static.Green,
Parent=frame,
})
corner(3,dot)
local value=raw(label(frame,{
Position=UDim2 .fromOffset(24,0),
Size=UDim2 .new(1,-30,1,0),
Text="",
FontFace=Fonts.Semibold,
TextSize=12,
}))
return dot,value
end
View.fpsDot,View.fpsText=badge(home,216,16)
View.pingDot,View.pingText=badge(home,216,48)
local quick={
{
Text="Cửa sổ",
Color=Static.Blue,
Active=function()
return State.Open
end,
Sub=function()
return translate(State.Open and"Đang mở"or"Đã đóng")
end,
Click=function()
Fwd.setWindow(not State.Open)
end,
},
{
Text="Hẹn giờ",
Color=Static.Orange,
Active=function()
return Activities.Timer~=nil
end,
Sub=function()
return Activities.Timer and Activities.Timer.Value()or"0:30"
end,
Click=function()
if Activities.Timer then
stopTimer()
else
startTimer(30)
end
end,
},
{
Text="Bấm giờ",
Color=Static.Purple,
Active=function()
return Activities.Stopwatch~=nil
end,
Sub=function()
return Activities.Stopwatch and Activities.Stopwatch.Short()or"0:00"
end,
Click=function()
stopwatchToggle()
end,
},
{
Text="Âm nhạc",
Color=Static.Green,
Active=function()
return Music.Playing
end,
Sub=function()
return translate(Music.Playing and"Đang phát"or"Đã dừng")
end,
Click=function()
Music.Toggle()
end,
},
}
for index,def in ipairs(quick)do
local button=box({
Class="TextButton",
Position=UDim2 .fromOffset(18+(index-1)*78,92),
Size=UDim2 .fromOffset(70,50),
BackgroundColor3=Static.White,
BackgroundTransparency=0.88,
AutoButtonColor=false,
Text="",
ZIndex=5,
Parent=home,
})
corner(16,button)
stroke(button,Static.White,0.92,1)
shine(button,16,0.9)
local caption=label(button,{
Position=UDim2 .fromOffset(0,9),
Size=UDim2 .new(1,0,0,16),
Text=def.Text,
FontFace=Fonts.Semibold,
TextSize=11,
TextXAlignment=Enum.TextXAlignment.Center,
TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=6,
})
local sub=raw(label(button,{
Position=UDim2 .fromOffset(0,27),
Size=UDim2 .new(1,0,0,14),
Text="",
FontFace=Fonts.Medium,
TextSize=10,
TextColor3=Static.LightGray,
TextXAlignment=Enum.TextXAlignment.Center,
ZIndex=6,
}))
pressable(button)
button.MouseButton1Click:Connect(touch(def.Click))
View.Quick[index]={Button=button,Caption=caption,Sub=sub,Def=def,On=false}
end
local music=makePage("Music")
View.art=box({
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .fromOffset(43,41),
Size=UDim2 .fromOffset(54,54),
BackgroundColor3=Static.White,
Parent=music,
})
corner(14,View.art)
View.artGradient=new("UIGradient",{Color=Media.ArtGradient.Color,Rotation=45,Parent=View.art})
View.artCover=new("ImageLabel",{
Name="Cover",Size=UDim2 .fromScale(1,1),BackgroundTransparency=1,
Image="",ScaleType=Enum.ScaleType.Crop,Visible=false,ZIndex=3,Parent=View.art,
})
corner(14,View.artCover)
local artScale=new("UIScale",{Parent=View.art})
View.artSpring=Spring.new(0.86,180,15,function(value)
artScale.Scale=value
end,0.001)
raw(label(View.art,{
Size=UDim2 .fromScale(1,1),
Text="♪",
FontFace=Fonts.Bold,
TextSize=24,
TextXAlignment=Enum.TextXAlignment.Center,
}))
local artGloss=box({
Position=UDim2 .fromOffset(1,1),
Size=UDim2 .new(1,-2,0.5,0),
BackgroundColor3=Static.White,
Parent=View.art,
})
corner(13,artGloss)
new("UIGradient",{Transparency=NumberSequence.new(0.62,1),Rotation=90,Parent=artGloss})
View.title=raw(label(music,{
Position=UDim2 .fromOffset(82,20),
Size=UDim2 .fromOffset(190,20),
Text="",
FontFace=Fonts.Semibold,
TextSize=16,
TextTruncate=Enum.TextTruncate.AtEnd,
}))
View.mood=raw(label(music,{
Position=UDim2 .fromOffset(82,42),
Size=UDim2 .fromOffset(190,16),
Text="",
FontFace=Fonts.Regular,
TextSize=12,
TextColor3=Static.LightGray,
TextTruncate=Enum.TextTruncate.AtEnd,
}))
View.bars={}
local barsFrame=new("Frame",{
Position=UDim2 .fromOffset(PAGE_W-16-23,30),
Size=UDim2 .fromOffset(23,18),
BackgroundTransparency=1,
Parent=music,
})
for index=1,5 do
local bar=box({
AnchorPoint=Vector2 .new(0,1),
Position=UDim2 .new(0,(index-1)*5,1,0),
Size=UDim2 .fromOffset(3,4),
BackgroundColor3=Static.Green,
Parent=barsFrame,
})
corner(2,bar)
View.bars[index]=bar
end
View.rail,View.fill,View.knob=rail(music,16,80,308,5,Static.White,11)
View.elapsed=raw(label(music,{
Position=UDim2 .fromOffset(16,92),
Size=UDim2 .fromOffset(70,14),
Text="0:00",
FontFace=Fonts.Medium,
TextSize=11,
TextColor3=Static.LightGray,
}))
View.total=raw(label(music,{
Position=UDim2 .fromOffset(PAGE_W-16-70,92),
Size=UDim2 .fromOffset(70,14),
Text="-:--",
FontFace=Fonts.Medium,
TextSize=11,
TextColor3=Static.LightGray,
TextXAlignment=Enum.TextXAlignment.Right,
}))
View.railHit=new("TextButton",{
Position=UDim2 .fromOffset(10,68),
Size=UDim2 .fromOffset(320,28),
BackgroundTransparency=1,
BorderSizePixel=0,
Text="",
ZIndex=6,
Parent=music,
})
local function transport(x,size,filled,callback)
local button=box({
Class="TextButton",
AnchorPoint=Vector2 .new(0.5,0.5),
Position=UDim2 .fromOffset(x,119),
Size=UDim2 .fromOffset(size,size),
BackgroundColor3=Static.White,
BackgroundTransparency=filled and 0 or 0.88,
AutoButtonColor=false,
Text="",
ZIndex=5,
Parent=music,
})
corner(size/2,button)
if not filled then
stroke(button,Static.White,0.9,1)
end
local spring=pressable(button)
button.MouseButton1Click:Connect(touch(callback))
return button,spring
end
local prev=transport(108,40,false,function()
Music.Next(-1)
end)
icon(prev,"prev",20,20,18,Static.White)
local dark=rgb(18,18,22)
View.playButton,View.playSpring=transport(PAGE_W/2,50,true,function()
Music.Toggle()
end)
View.playIcon=icon(View.playButton,"play",25,25,22,dark)
View.pauseIcon=icon(View.playButton,"pause",25,25,22,dark)
View.pauseIcon.Visible=false
local nextButton=transport(PAGE_W-108,40,false,function()
Music.Next(1)
end)
icon(nextButton,"next",20,20,18,Static.White)
local seeking=false
local function seekFromX(x)
local ratio=math.clamp((x-View.rail.AbsolutePosition.X)/math.max(View.rail.AbsoluteSize.X,1),0,1)
Music.Seek(ratio)
end
View.railHit.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
seeking=true
View.SeekStamp=os.clock()
View.Touched=os.clock()
seekFromX(input.Position.X)
end
end)
track(UserInputService.InputChanged:Connect(function(input)
if seeking and(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then
View.Touched=os.clock()
seekFromX(input.Position.X)
end
end))
track(UserInputService.InputEnded:Connect(function(input)
if seeking and(input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)then
seeking=false
end
end))
local timerPage=makePage("Timer")
label(timerPage,{
Position=UDim2 .fromOffset(22,14),
Size=UDim2 .fromOffset(200,16),
Text="Hẹn giờ",
FontFace=Fonts.Semibold,
TextSize=12,
TextColor3=Static.Orange,
})
View.timerBig=raw(label(timerPage,{
Position=UDim2 .fromOffset(20,28),
Size=UDim2 .fromOffset(300,54),
Text="0:00",
FontFace=Fonts.Bold,
TextSize=48,
}))
View.timerRail,View.timerFill=rail(timerPage,18,90,304,8,Static.Orange)
action(timerPage,18,104,148,38,"Dừng hẹn giờ",Static.Red,function()
stopTimer()
end)
action(timerPage,174,104,148,38,"+30s",nil,function()
extendTimer(30)
end)
local watchPage=makePage("Stopwatch")
View.watchTitle=label(watchPage,{
Position=UDim2 .fromOffset(22,14),
Size=UDim2 .fromOffset(200,16),
Text="Bấm giờ",
FontFace=Fonts.Semibold,
TextSize=12,
TextColor3=Static.Purple,
})
View.watchBig=raw(label(watchPage,{
Position=UDim2 .fromOffset(20,28),
Size=UDim2 .fromOffset(300,54),
Text="00:00.00",
FontFace=Fonts.Bold,
TextSize=44,
}))
View.watchLap=raw(label(watchPage,{
Position=UDim2 .fromOffset(22,82),
Size=UDim2 .fromOffset(296,16),
Text="",
FontFace=Fonts.Medium,
TextSize=12,
TextColor3=Static.LightGray,
}))
View.watchToggle=action(watchPage,18,104,96,38,"Tạm ngừng",Static.Purple,function()
stopwatchToggle()
end)
action(watchPage,122,104,96,38,"Vòng",nil,function()
stopwatchLap()
end)
action(watchPage,226,104,96,38,"Đặt lại",nil,function()
stopwatchReset()
end)
local loadPage=makePage("Download")
label(loadPage,{
Position=UDim2 .fromOffset(22,14),
Size=UDim2 .fromOffset(200,16),
Text="Tải xuống",
FontFace=Fonts.Semibold,
TextSize=12,
TextColor3=Static.Blue,
})
View.loadBig=raw(label(loadPage,{
Position=UDim2 .fromOffset(20,28),
Size=UDim2 .fromOffset(300,54),
Text="0%",
FontFace=Fonts.Bold,
TextSize=48,
}))
View.loadName=raw(label(loadPage,{
Position=UDim2 .fromOffset(22,84),
Size=UDim2 .fromOffset(296,16),
Text="Chưa có file",
FontFace=Fonts.Medium,
TextSize=12,
TextColor3=Static.LightGray,
TextWrapped=false,
TextTruncate=Enum.TextTruncate.AtEnd,
TextXAlignment=Enum.TextXAlignment.Left,
}))
View.loadRail,View.loadFill=rail(loadPage,18,108,304,8,Static.Blue)
local crossPage=makePage("Cross")
View.CrossMode="chat"
View.crossChat=new("CanvasGroup",{
Name="Chat",
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
ZIndex=2,
Parent=crossPage,
})
View.crossTerm=new("CanvasGroup",{
Name="Terminal",
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
GroupTransparency=1,
Visible=false,
ZIndex=2,
Parent=crossPage,
})
local function crossActive(mode)
return Island.Expanded and View.Current=="Cross"and View.CrossMode==mode
end
View.crossFace=Cross.buildFace(View.crossChat,66,UDim2 .fromOffset(12,12),{
ZIndex=4,
Active=function()
return crossActive("chat")
end,
})
View.crossBubble=box({
Name="Bubble",
Position=UDim2 .fromOffset(88,12),
Size=UDim2 .fromOffset(240,68),
BackgroundColor3=Static.White,
BackgroundTransparency=0.9,
ZIndex=4,
Parent=View.crossChat,
})
corner(14,View.crossBubble)
stroke(View.crossBubble,Static.White,0.9,1)
View.crossScroll=new("ScrollingFrame",{
Name="BubbleScroll",
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
BorderSizePixel=0,
ScrollBarThickness=2,
CanvasSize=UDim2 .new(0,0,0,0),
AutomaticCanvasSize=Enum.AutomaticSize.Y,
ScrollingDirection=Enum.ScrollingDirection.Y,
ZIndex=5,
Parent=View.crossBubble,
})
new("UIPadding",{
PaddingLeft=UDim.new(0,10),
PaddingRight=UDim.new(0,10),
PaddingTop=UDim.new(0,7),
PaddingBottom=UDim.new(0,7),
Parent=View.crossScroll,
})
View.crossText=raw(label(View.crossScroll,{
Size=UDim2 .new(1,0,0,0),
AutomaticSize=Enum.AutomaticSize.Y,
Text="",
FontFace=Fonts.Medium,
TextSize=12,
TextWrapped=true,
TextYAlignment=Enum.TextYAlignment.Top,
ZIndex=6,
}))
View.crossScroll.InputBegan:Connect(function()
View.SeekStamp=os.clock()
View.Touched=os.clock()
end)
View.crossEcho=raw(label(View.crossChat,{
Position=UDim2 .fromOffset(90,84),
Size=UDim2 .fromOffset(238,20),
Text="",
FontFace=Fonts.Regular,
TextSize=11,
TextColor3=Static.LightGray,
TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=5,
}))
View.crossShellBtn=action(View.crossChat,12,84,68,22,"Shell",nil,function()
View.crossMode("shell")
end)
View.crossShellBtn.TextSize=11
View.crossStop=action(View.crossChat,272,84,56,22,"Dừng",Static.Red,function()
if Cross.Body then
Cross.Body.stop("button")
end
end)
View.crossStop.TextSize=11
View.crossStop.Visible=false
View.crossField=box({
Name="Field",
Position=UDim2 .fromOffset(12,112),
Size=UDim2 .fromOffset(264,32),
BackgroundColor3=Static.White,
BackgroundTransparency=0.9,
ZIndex=4,
Parent=View.crossChat,
})
corner(16,View.crossField)
View.crossFieldLine=stroke(View.crossField,Static.White,0.88,1)
View.crossBox=new("TextBox",{
Name="Input",
Position=UDim2 .fromOffset(14,0),
Size=UDim2 .new(1,-28,1,0),
BackgroundTransparency=1,
BorderSizePixel=0,
ClearTextOnFocus=false,
Text="",
PlaceholderText=translate("Nhắn cho Cross…"),
PlaceholderColor3=Static.Gray,
FontFace=Fonts.Regular,
TextSize=13,
TextColor3=Static.White,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=6,
Parent=View.crossField,
})
raw(View.crossBox)
table.insert(Cross.Inputs,View.crossBox)
local function crossSend()
local value=View.crossBox.Text
View.crossBox.Text=""
if value~=""then
Cross.ask(value)
end
end
function View.crossFocus()
local field=View.crossBox
if not Island.Expanded or View.Current~="Cross"or View.CrossMode~="chat"then
return
end
pcall(function()
field:CaptureFocus()
end)
task.defer(function()
if#field.Text<=1 then
field.Text=""
end
end)
end
View.crossBox.Focused:Connect(function()
View.Touched=os.clock()
tween(View.crossFieldLine,0.2,{Color=P.Accent,Transparency=0.1})
end)
View.crossBox.FocusLost:Connect(function(enterPressed)
View.Touched=os.clock()
tween(View.crossFieldLine,0.2,{Color=Static.White,Transparency=0.88})
if enterPressed then
crossSend()
task.delay(0.05,View.crossFocus)
end
end)
View.crossBox:GetPropertyChangedSignal("Text"):Connect(function()
View.Touched=os.clock()
end)
View.crossBox.InputBegan:Connect(function()
View.SeekStamp=os.clock()
end)
View.crossSend=action(View.crossChat,282,112,46,32,"Gửi",Static.Blue,function()
crossSend()
View.crossFocus()
end)
View.crossShell=Cross.buildShell(View.crossTerm,{
Position=UDim2 .fromOffset(12,12),
Size=UDim2 .fromOffset(316,134),
Rows=7,
Radius=12,
ZIndex=3,
Active=function()
return crossActive("shell")
end,
})
View.crossChatBtn=action(View.crossTerm,262,15,58,18,"Chat",nil,function()
View.crossMode("chat")
end)
View.crossChatBtn.TextSize=11
View.crossChatBtn.ZIndex=8
function View.crossMode(mode,instant)
if View.CrossMode==mode and not instant then
return
end
View.CrossMode=mode
local chat=mode=="chat"
local keep,show=View.crossTerm,View.crossChat
if not chat then
keep,show=View.crossChat,View.crossTerm
end
if instant then
show.Visible=true
show.GroupTransparency=0
keep.GroupTransparency=1
keep.Visible=false
else
show.Visible=true
tween(show,0.26,{GroupTransparency=0})
tween(keep,0.16,{GroupTransparency=1})
task.delay(0.2,function()
if View.CrossMode==mode then
keep.Visible=false
end
end)
end
if not chat then
View.crossShell.Refresh(true,false)
pcall(function()
View.crossBox:ReleaseFocus()
end)
end
View.Touched=os.clock()
end
View.Updaters.Cross=function()
local bubble=Cross.Bubble
local shown=bubble.Shown
if shown==""then
shown=Settings.Language=="en"and"I'm Cross. Type something, or ask 'what can you do'!"or"Mình là Cross. Nhắn gì đó, hoặc hỏi 'bạn làm được gì' nhé!"
end
if View.crossText.Text~=shown then
View.crossText.Text=shown
View.crossScroll.CanvasPosition=Vector2 .new(0,100000)
end
put(View.crossEcho,Cross.Echo~=""and("› "..Cross.Echo)or"")
local moving=Cross.Body and Cross.Body.Active and true or false
if View.crossStop.Visible~=moving then
View.crossStop.Visible=moving
View.crossEcho.Size=UDim2 .fromOffset(moving and 176 or 238,20)
end
local focused=false
pcall(function()
focused=View.crossBox:IsFocused()
end)
if focused or Cross.Busy>0 or os.clock()<Cross.SpeakUntil then
View.Touched=os.clock()
end
end
Fwd.crossOpen=function(mode,focus)
task.spawn(function()
local tries=0
while(Island.Alerting or Island.Busy or not State.Ready)and tries<60 do
task.wait(0.05)
tries=tries+1
end
if not Island.Expanded then
Isl.expand("Cross")
end
if Island.Expanded then
if View.Current~="Cross"then
View.show("Cross")
end
View.crossMode("chat")
View.Touched=os.clock()
if focus then
task.wait(0.3)
View.crossFocus()
end
end
end)
end
Fwd.crossSync=function()
if Island.Expanded then
View.refresh()
end
end
View.grabber=box({
Name="Grabber",
Position=UDim2 .fromOffset(PAGE_W/2-18,6),
Size=UDim2 .fromOffset(36,4),
BackgroundColor3=Static.White,
BackgroundTransparency=0.72,
ZIndex=3,
Parent=View.group,
})
corner(2,View.grabber)
View.grabHit=new("TextButton",{
Name="Grab",
AnchorPoint=Vector2 .new(0.5,0),
Position=UDim2 .fromOffset(PAGE_W/2,0),
Size=UDim2 .fromOffset(84,22),
BackgroundTransparency=1,
BorderSizePixel=0,
Text="",
ZIndex=8,
Parent=View.group,
})
View.dock=box({
Name="Dock",
AnchorPoint=Vector2 .new(0.5,0),
Position=UDim2 .fromOffset(PAGE_W/2,DOCK_Y),
Size=UDim2 .fromOffset(200,30),
BackgroundColor3=Static.White,
BackgroundTransparency=0.9,
ZIndex=4,
Parent=View.group,
})
corner(15,View.dock)
stroke(View.dock,Static.White,0.9,1)
View.thumb=box({
Name="Thumb",
Position=UDim2 .fromOffset(3,3),
Size=UDim2 .fromOffset(40,24),
BackgroundColor3=Static.White,
BackgroundTransparency=0.78,
ZIndex=5,
Parent=View.dock,
})
corner(12,View.thumb)
shine(View.thumb,12,0.7)
for _,key in ipairs(PAGE_ORDER)do
local tab=box({
Class="TextButton",
Name=key,
Position=UDim2 .fromOffset(3,3),
Size=UDim2 .fromOffset(40,24),
BackgroundTransparency=1,
AutoButtonColor=false,
Text=translate(PAGE_TITLES[key]),
FontFace=Fonts.Semibold,
TextSize=11,
TextColor3=Static.LightGray,
Visible=false,
ZIndex=6,
Parent=View.dock,
})
tab.MouseButton1Click:Connect(function()
View.Touched=os.clock()
playSound("click")
View.show(key)
end)
View.Tabs[key]=tab
end
View.toast=box({
Name="Toast",
Position=UDim2 .fromOffset(12,-60),
Size=UDim2 .fromOffset(PAGE_W-24,46),
BackgroundColor3=rgb(30,30,36),
Visible=false,
ZIndex=9,
Parent=View.group,
})
corner(23,View.toast)
stroke(View.toast,Static.White,0.86,1)
shine(View.toast,23,0.9)
View.toastIcon=box({
Position=UDim2 .fromOffset(9,9),
Size=UDim2 .fromOffset(28,28),
BackgroundColor3=Static.Blue,
ZIndex=10,
Parent=View.toast,
})
corner(14,View.toastIcon)
View.toastGlyph=raw(label(View.toastIcon,{
Size=UDim2 .fromScale(1,1),
Text="i",
FontFace=Fonts.Bold,
TextSize=15,
TextXAlignment=Enum.TextXAlignment.Center,
ZIndex=11,
}))
View.toastTitle=raw(label(View.toast,{
Position=UDim2 .fromOffset(48,6),
Size=UDim2 .new(1,-62,0,18),
Text="",
FontFace=Fonts.Semibold,
TextSize=13,
TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=10,
}))
View.toastMessage=raw(label(View.toast,{
Position=UDim2 .fromOffset(48,25),
Size=UDim2 .new(1,-62,0,14),
Text="",
FontFace=Fonts.Regular,
TextSize=11,
TextColor3=Static.LightGray,
TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=10,
}))
View.toastHit=new("TextButton",{
Name="ToastHit",
Size=UDim2 .fromScale(1,1),
BackgroundTransparency=1,
BorderSizePixel=0,
Text="",
ZIndex=12,
Parent=View.toast,
})
View.toastHit.MouseButton1Click:Connect(function()
View.ToastSkip=true
end)
function View.available()
local list={}
for _,key in ipairs(PAGE_ORDER)do
if key=="Home"or key=="Music"or(key=="Cross"and Cross.Enabled)or Activities[key]then
list[#list+1]=key
end
end
return list
end
function View.layoutDock(instant)
local list=View.available()
local textWidths,textSum={},0
for _,name in ipairs(list)do
local measured=math.ceil(TextService:GetTextSize(View.Tabs[name].Text,11,Enum.Font.GothamSemibold,Vector2 .new(200,20)).X)
textWidths[name]=measured
textSum=textSum+measured
end
local pad=20
local room=PAGE_W-24-2*math.max(#list-1,0)
if textSum+pad*#list>room then
pad=math.max(6,math.floor((room-textSum)/math.max(#list,1)))
end
local x=3
local focus
for _,key in ipairs(PAGE_ORDER)do
local tab=View.Tabs[key]
local shown=false
for _,name in ipairs(list)do
if name==key then
shown=true
end
end
tab.Visible=shown
if shown then
local width=textWidths[key]+pad
tab.Position=UDim2 .fromOffset(x,3)
tab.Size=UDim2 .fromOffset(width,24)
if key==View.Current then
focus={X=x,W=width}
end
local color=key==View.Current and Static.White or Static.LightGray
if instant then
tab.TextColor3=color
else
tween(tab,0.2,{TextColor3=color})
end
x=x+width+2
end
end
local total=x+1
if instant then
View.dock.Size=UDim2 .fromOffset(total,30)
else
tween(View.dock,0.28,{Size=UDim2 .fromOffset(total,30)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
end
if focus then
if instant then
View.thumb.Position=UDim2 .fromOffset(focus.X,3)
View.thumb.Size=UDim2 .fromOffset(focus.W,24)
else
tween(View.thumb,0.32,{Position=UDim2 .fromOffset(focus.X,3),Size=UDim2 .fromOffset(focus.W,24)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
end
end
end
function View.show(key,instant,direction)
if not View.Pages[key]then
key="Home"
end
local previous=View.Current
View.Current=key
View.Touched=os.clock()
local way=direction or(pageIndex(key)>=pageIndex(previous)and 1 or-1)
for name,page in pairs(View.Pages)do
if name==key then
if instant then
page.Visible=true
page.GroupTransparency=0
page.Position=UDim2 .fromOffset(0,0)
elseif previous~=key or not page.Visible then
page.Position=UDim2 .fromOffset(way*28,0)
page.Visible=true
tween(page,0.34,{GroupTransparency=0,Position=UDim2 .fromOffset(0,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
end
elseif page.Visible then
if instant then
page.GroupTransparency=1
page.Visible=false
else
tween(page,0.16,{GroupTransparency=1,Position=UDim2 .fromOffset(-way*20,0)})
task.delay(0.2,function()
if View.Current~=name then
page.Visible=false
page.Position=UDim2 .fromOffset(0,0)
end
end)
end
end
end
View.layoutDock(instant)
View.tick(true)
end
function View.nudge(direction)
local page=View.Pages[View.Current]
if page then
page.Position=UDim2 .fromOffset(-direction*12,0)
tween(page,0.4,{Position=UDim2 .fromOffset(0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
end
end
function View.step(direction)
local list=View.available()
local at=1
for index,key in ipairs(list)do
if key==View.Current then
at=index
end
end
local target=list[at+direction]
View.Touched=os.clock()
if target then
playSound("click")
View.show(target,false,direction)
else
View.nudge(direction)
end
end
function View.tick(force)
local now=os.clock()
if not force and now-View.TickAt<(View.TickRate or 0.05)then
return
end
View.TickAt=now
if not Island.Expanded then
return
end
if View.DockLang~=Settings.Language then
View.DockLang=Settings.Language
View.layoutDock(true)
end
local updater=View.Updaters[View.Current]
if updater then
updater()
end
end
View.Updaters.Home=function()
local stamp=os.clock()
if stamp-(View.HomeAt or 0)>0.5 then
View.HomeAt=stamp
put(View.clock,os.date("%H:%M"))
put(View.date,os.date("%d/%m/%Y"))
end
local stamp2=View.HomeAt or 0
if View.HomeMetricsAt~=stamp2 then
View.HomeMetricsAt=stamp2
local fps=math.floor(Metrics.Fps+0.5)
put(View.fpsText,fps.." FPS")
local fpsColor=fps>=50 and Static.Green or(fps>=30 and Static.Orange or Static.Red)
if View.fpsDot.BackgroundColor3~=fpsColor then
View.fpsDot.BackgroundColor3=fpsColor
end
put(View.pingText,Metrics.Ping.." ms")
local pingColor=Metrics.Ping<90 and Static.Green or(Metrics.Ping<180 and Static.Orange or Static.Red)
if View.pingDot.BackgroundColor3~=pingColor then
View.pingDot.BackgroundColor3=pingColor
end
end
for _,entry in ipairs(View.Quick)do
local on=entry.Def.Active()and true or false
put(entry.Sub,entry.Def.Sub())
if entry.On~=on then
entry.On=on
tween(entry.Button,0.25,{
BackgroundColor3=on and entry.Def.Color or Static.White,
BackgroundTransparency=on and 0.06 or 0.88,
})
tween(entry.Sub,0.25,{TextColor3=on and Static.White or Static.LightGray})
end
end
end
View.Updaters.Music=function()
local track_=Music.Tracks[Music.Index]
put(View.title,Media.Title.Text)
put(View.mood,Media.Sub.Text)
local gradient=Media.ArtGradient.Color
if View.Shown.Art~=gradient then
View.Shown.Art=gradient
View.artGradient.Color=gradient
end
local coverImage=Media.Cover and Media.Cover.Image or""
if View.Shown.Cover~=coverImage then
View.Shown.Cover=coverImage
if View.artCover then
View.artCover.Image=coverImage
View.artCover.Visible=coverImage~=""
end
end
local color=track_ and track_.B or Static.White
if View.Shown.Fill~=color then
View.Shown.Fill=color
View.fill.BackgroundColor3=color
for _,bar in ipairs(View.bars)do
bar.BackgroundColor3=color
end
end
View.fill.Size=UDim2 .new(Music.Progress(),0,1,0)
put(View.elapsed,fmt(Music.Position))
local length=Music.Duration()
put(View.total,length>0 and fmt(length)or"-:--")
local playing=Music.Playing and true or false
if View.Shown.Playing~=playing then
View.Shown.Playing=playing
View.artSpring:Set(playing and 1 or 0.86)
View.playSpring:Snap(0.84)
View.playSpring:Set(1)
end
if View.playIcon.Visible==playing then
View.playIcon.Visible=not playing
View.pauseIcon.Visible=playing
end
for index,bar in ipairs(View.bars)do
bar.Size=UDim2 .fromOffset(3,3+14*math.clamp(Music.Levels[index]+0.06,0,1))
end
end
View.Updaters.Timer=function()
local timer=Activities.Timer
if timer then
put(View.timerBig,timer.Value())
View.timerFill.Size=UDim2 .new(math.clamp(timer.Ring(),0,1),0,1,0)
end
end
View.Updaters.Stopwatch=function()
local watch=Activities.Stopwatch
if watch then
put(View.watchBig,watch.Value())
local running=watch.Title=="Bấm giờ"
put(View.watchTitle,translate(watch.Title))
put(View.watchToggle,translate(running and"Tạm ngừng"or"Tiếp tục"))
local lap=watch.Lap
put(View.watchLap,lap and(translate("Vòng").." "..lap.Index.."  ·  "..lap.Text)or"")
end
end
View.Updaters.Download=function()
local load=Activities.Download
if load then
put(View.loadBig,load.Value())
local label=load.FileName or load.Label or load.Title
if label and label~=""and View.Shown.LoadName~=label then
View.Shown.LoadName=label
put(View.loadName,tostring(label))
end
View.loadFill.Size=UDim2 .new(math.clamp(downloadValue,0,1),0,1,0)
end
end
function View.refresh()
local list=View.available()
local found=false
for _,key in ipairs(list)do
if key==View.Current then
found=true
end
end
if not found then
View.show("Home")
else
View.layoutDock()
end
end
function View.clearToasts()
View.Toasts={}
View.ToastToken=View.ToastToken+1
View.ToastSkip=false
View.toast.Visible=false
View.toast.Position=UDim2 .fromOffset(12,-60)
end
function View.toastRun()
if View.ToastBusy then
return
end
View.ToastBusy=true
local token=View.ToastToken
task.spawn(function()
while#View.Toasts>0 and Island.Expanded and token==View.ToastToken do
local item=table.remove(View.Toasts,1)
local style=KINDS[item.kind]or KINDS.info
View.toastIcon.BackgroundColor3=style[1]
View.toastGlyph.Text=style[2]
View.toastTitle.Text=translate(item.title)
View.toastMessage.Text=translate(item.message)
View.ToastSkip=false
View.toast.Position=UDim2 .fromOffset(12,-60)
View.toast.Visible=true
playSound(item.kind)
tween(View.toast,0.4,{Position=UDim2 .fromOffset(12,14)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
local hold=math.clamp(item.duration or 2.6,1.8,4)
local started=os.clock()
while Island.Expanded and token==View.ToastToken and not View.ToastSkip and os.clock()-started<hold do
task.wait(0.05)
end
if Island.Expanded and token==View.ToastToken then
tween(View.toast,0.26,{Position=UDim2 .fromOffset(12,-60)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
task.wait(0.28)
View.toast.Visible=false
end
View.ToastSkip=false
end
View.ToastBusy=false
if#View.Toasts>0 and Island.Expanded then
View.toastRun()
end
end)
end
function Isl.drainToToast()
local moved=false
while#Island.Queue>0 do
local item=table.remove(Island.Queue,1)
if item.kind~="info"then
if#View.Toasts>=3 then
table.remove(View.Toasts,1)
end
table.insert(View.Toasts,item)
moved=true
end
end
if moved then
View.toastRun()
end
end
function Isl.expand(page)
if Island.Expanded or Island.Alerting or Island.Busy or not State.Ready then
return
end
Island.Expanded=true
Island.Pressing=false
View.Touched=os.clock()
View.Gesture=nil
View.clearToasts()
View.group.Visible=true
local key=page
if not key then
key=Island.Key
if key~="Music"and key~="Timer"and key~="Stopwatch"and key~="Download"and key~="Cross"then
key="Home"
end
end
for _,pageGroup in pairs(View.Pages)do
pageGroup.Visible=false
pageGroup.GroupTransparency=1
pageGroup.Position=UDim2 .fromOffset(0,0)
end
View.Current="Home"
View.show(key,true)
if key=="Cross"then
View.crossMode("chat",true)
end
Ring.ringHide()
Isl.bubbleTo(0)
Isl.showGroup(Isl.idleGroup,false,0.12)
Isl.showGroup(Isl.liveGroup,false,0.12)
Isl.showGroup(Isl.alertGroup,false,0.12)
Isl.showGroup(Media.Group,false,0.12)
Isl.islandHit.Visible=false
Isl.setIslandMode("expand",PAGE_W,PAGE_H)
Isl.pop(0.035)
playSound("open")
local live=Island.Live
tween(Isl.tint,0.4,{
BackgroundColor3=live and live.Color or Static.Blue,
BackgroundTransparency=live and 0 or 0.5,
})
task.delay(0.1,function()
if Island.Expanded then
Isl.showGroup(View.group,true,0.32)
end
end)
end
function Isl.collapse(instant,quiet)
if not Island.Expanded then
return
end
Island.Expanded=false
Island.HoldDone=false
View.Gesture=nil
if Cross.releaseFocus then
Cross.releaseFocus()
end
View.clearToasts()
Isl.islandHit.Visible=true
if instant then
View.group.GroupTransparency=1
View.group.Visible=false
else
Isl.showGroup(View.group,false,0.14)
playSound("close")
task.delay(0.2,function()
if not Island.Expanded then
View.group.Visible=false
end
end)
end
if not quiet then
Isl.settleIsland()
end
if#Island.Queue>0 and not quiet then
Isl.runQueue()
end
end
Fwd.islandExpand=Isl.expand
Fwd.islandCollapse=Isl.collapse
View.grabHit.MouseButton1Click:Connect(function()
Isl.collapse()
end)
local function pointInside(x,y,margin)
local pos=Isl.islandFrame.AbsolutePosition
local size=Isl.islandFrame.AbsoluteSize
if x<pos.X-margin or x>pos.X+size.X+margin then
return false
end
local top,bottom=pos.Y-margin,pos.Y+size.Y+margin
return(y>=top and y<=bottom)or(y+View.Inset>=top and y+View.Inset<=bottom)
end
track(UserInputService.InputBegan:Connect(function(input,processed)
if not Island.Expanded then
return
end
local code=input.KeyCode
if code==Enum.KeyCode.Escape then
Isl.collapse()
return
end
if code==Enum.KeyCode.Left or code==Enum.KeyCode.Right then
if not processed then
View.step(code==Enum.KeyCode.Right and 1 or-1)
end
return
end
local kind=input.UserInputType
if kind~=Enum.UserInputType.MouseButton1 and kind~=Enum.UserInputType.Touch then
return
end
local point=input.Position
if point and not pointInside(point.X,point.Y,10)then
Isl.collapse()
return
end
View.Touched=os.clock()
View.Gesture=point and{X=point.X,Y=point.Y,At=os.clock()}or nil
end))
track(UserInputService.InputChanged:Connect(function(input)
if not Island.Expanded or input.UserInputType~=Enum.UserInputType.MouseMovement then
return
end
local now=os.clock()
local point=input.Position
if point and now-View.Touched>0.4 and pointInside(point.X,point.Y,10)then
View.Touched=now
end
end))
track(UserInputService.InputEnded:Connect(function(input)
local gesture=View.Gesture
local kind=input.UserInputType
if not gesture or(kind~=Enum.UserInputType.MouseButton1 and kind~=Enum.UserInputType.Touch)then
return
end
View.Gesture=nil
local point=input.Position
if not Island.Expanded or not point or View.SeekStamp>=gesture.At-0.05 then
return
end
local dx,dy=point.X-gesture.X,point.Y-gesture.Y
local ax,ay=math.abs(dx),math.abs(dy)
local limit=SWIPE*islandState.Base
if ax>limit and ax>ay*1.3 then
View.step(dx<0 and 1 or-1)
elseif-dy>limit and ay>ax*1.3 then
Isl.collapse()
end
end))
local islandPressInput
Isl.islandHit.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then islandPressInput=input end
end)
track(UserInputService.InputEnded:Connect(function(input)
if input==islandPressInput or(islandPressInput and islandPressInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)then
islandPressInput=nil
Island.Pressing=false
Spr.springIslandHover:Set(1)
end
end))
Isl.islandHit.MouseButton1Down:Connect(function()
Island.HoldDone=false
Island.Pressing=true
Island.PressToken=Island.PressToken+1
local token=Island.PressToken
task.delay(0.4,function()
if Island.Pressing and Island.PressToken==token and Settings.Expand and State.Ready and not Island.Expanded then
Island.HoldDone=true
Isl.expand()
end
end)
end)
Isl.islandHit.MouseButton1Up:Connect(function()
Island.Pressing=false
end)
Isl.islandHit.MouseLeave:Connect(function()
Island.Pressing=false
end)
Isl.islandHit.MouseButton2Click:Connect(function()
if Settings.Expand and State.Ready then
Isl.expand()
end
end)
local function secondaryKey()
for _,key in ipairs(ACTIVITY_ORDER)do
if key~=Island.Key and Activities[key]then
return key
end
end
end
Fwd.islandSync=function()
local live=Island.Live
if not Island.Alerting and not Island.Expanded then
if live then
tween(Isl.tint,0.4,{BackgroundColor3=live.Color,BackgroundTransparency=0})
else
tween(Isl.tint,0.4,{BackgroundTransparency=1})
end
end
local key=secondaryKey()
local show=key~=nil and Settings.Split and State.Ready and live~=nil and not Island.Alerting and not Island.Expanded
if show then
Island.BubbleKey=key
Isl.bubbleRing.Color=Activities[key].Color
View.BubbleText=""
Isl.bubble.Visible=true
Isl.bubbleTo(1)
else
Island.BubbleKey=nil
Isl.bubbleTo(0)
end
if Island.Expanded then
View.refresh()
end
end
Fwd.islandLayout=function(scale,shift)
local pop=math.max(islandState.Bubble,0)
local size=ISLAND.Bubble
local center=shift+islandState.W*scale/2+(ISLAND.Gap+size*islandState.Base/2)*math.min(pop,1.1)
Isl.bubble.Position=UDim2 .new(0.5,center,0,islandState.Y+islandState.H*scale/2)
Isl.bubbleScale.Scale=math.max(islandState.Base*pop,0.01)
local visible=pop>0.02
if Isl.bubble.Visible~=visible then
Isl.bubble.Visible=visible
end
end
Isl.bubbleHit.MouseButton1Click:Connect(function()
if Island.BubbleKey and Activities[Island.BubbleKey]then
playSound("click")
Island.Pin=Island.BubbleKey
refreshActivity()
end
end)
Hooks.Register(function()
if Settings.RimLight then
Isl.rimGradient.Rotation=(os.clock()*55)%360
elseif Isl.rimGradient.Rotation~=90 then
Isl.rimGradient.Rotation=90
end
local stamp=os.clock()
if islandState.Bubble>0.05 and Island.BubbleKey and stamp-View.BubbleAt>0.1 then
View.BubbleAt=stamp
local activity=Activities[Island.BubbleKey]
if activity then
local value=tostring((activity.Short or activity.Value)()or"")
do
local charCount=utf8 .len(value)or#value
if charCount>5 then
local okPos,pos=pcall(function()return utf8 .offset(value,6)end)
if okPos and type(pos)=="number"then
value=value:sub(1,pos-1):gsub("%s+$","").."…"
else
value=value:sub(1,5).."…"
end
end
end
if value~=View.BubbleText then
View.BubbleText=value
Isl.bubbleText.Text=value
Isl.bubbleText.TextSize=#value<=3 and 12 or(#value==4 and 11 or 10)
end
end
end
if not Island.Expanded then
return
end
View.tick()
if os.clock()-View.Touched>IDLE_COLLAPSE then
Isl.collapse()
end
end,1)
end
local function refreshIslandScale()
local currentCamera=workspace.CurrentCamera or camera
local viewport=currentCamera and currentCamera.ViewportSize or Vector2 .new(800,600)
islandState.Base=math.clamp(viewport.X/430,0.6,1)
Isl.layoutIsland()
end
refreshIslandScale()
track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshIslandScale))
Fwd.setWindow=function(open)
if not __hostWindow then return end
if open then
if type(__hostWindow.Show)=="function"then __hostWindow:Show()end
elseif type(__hostWindow.Hide)=="function"then
__hostWindow:Hide()
end
State.Open=open and true or false
end
function Cross.releaseFocus()
for _,field in ipairs(Cross.Inputs)do
if field and field.Parent then
pcall(function()field:ReleaseFocus()end)
end
end
end
function Cross.setEnabled(on)
Cross.Enabled=on and true or false
if Cross.Enabled then
if not Cross.Chat[1]then
Cross.say("cross",Settings.Language=="en"
and"Hi! I'm Cross. You can ask me to play music, skip tracks or set a timer."
or"Chào bạn! Mình là Cross. Bạn có thể nhờ mình mở nhạc, chuyển bài hoặc hẹn giờ.")
end
Cross.setMood("happy",2)
Activities.Cross={
Title="Cross",
Color=Static.Purple,
Value=function()return Settings.Language=="en"and"Ready"or"Sẵn sàng"end,
Short=function()return"Cross"end,
}
else
Activities.Cross=nil
Cross.releaseFocus()
end
refreshActivity()
end
local function __askNorm(text)
local raw=string.lower(tostring(text or""))
local map={
["à"]="a",["á"]="a",["ạ"]="a",["ả"]="a",["ã"]="a",["â"]="a",["ầ"]="a",["ấ"]="a",["ậ"]="a",["ẩ"]="a",["ẫ"]="a",
["ă"]="a",["ằ"]="a",["ắ"]="a",["ặ"]="a",["ẳ"]="a",["ẵ"]="a",
["è"]="e",["é"]="e",["ẹ"]="e",["ẻ"]="e",["ẽ"]="e",["ê"]="e",["ề"]="e",["ế"]="e",["ệ"]="e",["ể"]="e",["ễ"]="e",
["ì"]="i",["í"]="i",["ị"]="i",["ỉ"]="i",["ĩ"]="i",
["ò"]="o",["ó"]="o",["ọ"]="o",["ỏ"]="o",["õ"]="o",["ô"]="o",["ồ"]="o",["ố"]="o",["ộ"]="o",["ổ"]="o",["ỗ"]="o",
["ơ"]="o",["ờ"]="o",["ớ"]="o",["ợ"]="o",["ở"]="o",["ỡ"]="o",
["ù"]="u",["ú"]="u",["ụ"]="u",["ủ"]="u",["ũ"]="u",["ư"]="u",["ừ"]="u",["ứ"]="u",["ự"]="u",["ử"]="u",["ữ"]="u",
["ỳ"]="y",["ý"]="y",["ỵ"]="y",["ỷ"]="y",["ỹ"]="y",["đ"]="d",
}
for key,value in pairs(map)do raw=raw:gsub(key,value)end
return(raw:gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$",""))
end
local function __has(text,...)
for _,word in ipairs({...})do
if text:find(word,1,true)then return true end
end
return false
end
function Cross.ask(prompt)
prompt=tostring(prompt or"")
if prompt==""then return end
if not Cross.Enabled then Cross.setEnabled(true)end
Cross.say("user",prompt)
do
local Engine=Music.Remote and Music.Remote.Engine
local nrm=(CrossAIMusic and CrossAIMusic.Util and CrossAIMusic.Util.norm(prompt))or""
local isControl=false
for _,w in ipairs({
"next","chuyen bai","bai tiep","previous","bai truoc",
"pause","tam dung","dung hen gio","hen gio",
"volume","am luong","tang am","giam am","stop nhac","tat nhac",
})do
if nrm:find(w,1,true)then
isControl=true
break
end
end
local hasTag=false
if CrossAIMusic and CrossAIMusic.Lexicon then
for key in pairs(CrossAIMusic.Lexicon)do
if nrm:find(key,1,true)then
hasTag=true
break
end
end
end
local asksSearch=nrm:find("tim nhac",1,true)or nrm:find("tim bai",1,true)
or nrm:find("phat nhac",1,true)or nrm:find("mo nhac",1,true)
or nrm:find("nghe nhac",1,true)or nrm:find("play music",1,true)
or nrm:find("find music",1,true)or nrm:find("search music",1,true)
or nrm:find("bat nhac",1,true)or nrm:find("bai hat",1,true)
or prompt:find("https://",1,true)or prompt:find("http://",1,true)
if Engine and(hasTag or asksSearch)and not isControl then
local vi=crossPromptIsVi(prompt)
local plan=Engine.parse(prompt)
if prompt:find("https://",1,true)or prompt:find("http://",1,true)then
plan.query=prompt:match("https?://%S+")or prompt
end
local function say(state,payload)
local sayFn=Engine.say or(CrossAIMusic and CrossAIMusic.say)
if type(sayFn)~="function"then return end
local ok,res=pcall(sayFn,state,payload,vi)
if ok and type(res)=="table"and res.text then
Cross.say("cross",res.text)
if res.mood then Cross.setMood(res.mood,4)end
end
end
Cross.Thinking=true
Cross.setMood("think",6)
say("thinking",{query=plan.query})
local okRun,asset,track=pcall(function()
return Engine.resolve(prompt,function(state,payload)
payload=payload or{}
if state=="parse"then
Cross.setMood("think",6)
elseif state=="searching"then
Cross.Echo=vi and"đang tìm…"or"searching…"
elseif state=="trying"then
Cross.setMood("think",6)
Cross.Echo=(vi and"thử bài "or"try #")..tostring(payload.rank or 1)
elseif state=="download"then
local inner=payload.payload or{}
if type(inner.percent)=="number"then
Cross.Echo=string.format("%d%%",math.floor(inner.percent*100+0.5))
end
end
end)
end)
Cross.Thinking=false
Cross.Echo=""
if okRun and type(asset)=="string"and asset~=""and type(track)=="table"then
local covers=Music.Covers or{{Static.Purple,Static.Blue}}
local cover=covers[(Music.Index%#covers)+1]
local row=(CrossAIMusic and type(CrossAIMusic.rowData)=="function")
and CrossAIMusic.rowData(track,#Music.Tracks+1)or nil
local desc,value="",nil
if row then
desc,value=row.Artist,row.Value
if row.Duration~=""then
desc=(desc~=""and(desc.." · "..row.Duration)or row.Duration)
end
end
local coverAsset=track.CoverAsset
if not coverAsset and CrossAIMusic and type(CrossAIMusic.thumbAsset)=="function"then
local okCover,got=pcall(CrossAIMusic.thumbAsset,track)
if okCover then coverAsset=got end
end
local index=Music.PlayAsset({
Name=track.name,
Artist=track.author or"",
Mood=desc,
Desc=desc,
Value=value,
Remote=true,
Source=track.source,
Duration=track.duration,
Thumbnail=track.thumbnail,
CoverAsset=coverAsset,
Url=track.url,
Id=track.id,
Asset=asset,
A=cover[1],
B=cover[2],
})
Cross.setMood("happy",3)
say("ready",{name=track.name,author=track.author})
notify("Cross AI",
(vi and"Đã thêm vào danh sách: "or"Added to list: ")..tostring(track.name),
"success",3,true)
if index and Island.Expanded and Isl.expand then
Isl.expand("Music")
end
else
Cross.setMood("sad",4)
local okSay,none=pcall(function()
return Engine.say("none",{query=plan.query},vi)
end)
if okSay and type(none)=="table"and none.text then
Cross.say("cross",none.text)
else
Cross.say("cross",vi
and"Mình không tìm/tải được bài phù hợp. Thử mô tả khác nhé (vd: \"nhạc lofi buổi tối\")."
or"I could not find or download a matching track. Try another description.")
end
end
return
end
end
local lower=__askNorm(prompt)
local vi=crossPromptIsVi(prompt)
local response
local seconds=lower:match("timer%s+(%d+)")or lower:match("hen gio%s+(%d+)")or lower:match("(%d+)%s*giay")
local minutes=lower:match("(%d+)%s*phut")
if __has(lower,"chuyen bai","bai tiep","next","skip")then
Music.Next(1)
response=vi and"Đã chuyển bài tiếp theo."or"Skipped to the next song."
elseif __has(lower,"bai truoc","previous","quay lai")then
Music.Next(-1)
response=vi and"Đã trở về bài trước."or"Playing the previous track."
elseif __has(lower,"tam dung","dung nhac","pause","stop nhac")then
if Music.Playing then Music.Toggle()end
response=vi and"Đã tạm dừng nhạc."or"Music paused."
elseif __has(lower,"dung hen gio","huy hen gio","stop timer")then
stopTimer()
response=vi and"Đã dừng hẹn giờ."or"Timer stopped."
elseif __has(lower,"to hon","lon hon","tang am","volume up","to tieng")then
Music.SetVolume(math.min(100,(Music.Volume or 50)+10))
response=vi and("Âm lượng "..tostring(Music.Volume).."%.")or("Volume "..tostring(Music.Volume).."%.")
elseif __has(lower,"nho hon","giam am","volume down","nho tieng")then
Music.SetVolume(math.max(0,(Music.Volume or 50)-10))
response=vi and("Âm lượng "..tostring(Music.Volume).."%.")or("Volume "..tostring(Music.Volume).."%.")
elseif seconds and __has(lower,"gio","timer","hen")then
seconds=math.clamp(tonumber(seconds)or 60,1,86400)
startTimer(seconds)
response=(vi and"Đã đặt hẹn giờ "or"Timer set for ")..tostring(seconds)..(vi and" giây."or" seconds.")
elseif minutes and __has(lower,"gio","timer","hen")then
local total=math.clamp(tonumber(minutes)*60,1,86400)
startTimer(total)
response=(vi and"Đã đặt hẹn giờ "or"Timer set for ")..tostring(minutes)..(vi and" phút."or" minutes.")
elseif __has(lower,"mo nhac","phat nhac","bat nhac","play")then
if not Music.Playing then Music.Toggle()end
response=vi and"Đã bật nhạc."or"Playing music."
else
local wantsSong=__has(lower,"tim","mo","phat","nhac","bai hat","nghe","play","song")
local track=Music.Tracks and Music.Tracks[Music.Index]
local search=_G.xNgotQueueMusicSearch
if wantsSong and search and not __has(lower,"mo ta","help","huong dan")then
local ok=pcall(search,prompt)
if ok then
response=vi and"Đang tìm bài bạn muốn nghe…"or"Looking for that song…"
end
end
if not response and wantsSong and track then
response=vi and("Đang phát: "..tostring(track.Name))or("Now playing: "..tostring(track.Name))
end
if not response then
response=vi
and"Mình mở/tạm dừng nhạc, chuyển bài, đổi âm lượng, đặt hẹn giờ. Thử: mở nhạc lofi chill, hẹn giờ 90 giây."
or"I can play/pause music, skip tracks, change volume and set timers. Try: play lofi chill, timer 90."
end
end
Cross.say("cross",response)
Cross.setMood("happy",2)
end
local __crossAskBase=Cross.ask
function Cross.ask(prompt)
prompt=tostring(prompt or"")
if prompt==""then return end
__crossAskBase(prompt)
local vi=crossPromptIsVi(prompt)
local nrm=(CrossAIMusic and CrossAIMusic.Util and CrossAIMusic.Util.norm and CrossAIMusic.Util.norm(prompt))
or string.lower(prompt)
if nrm:find("script",1,true)then
Cross.say("cross",vi
and"Mình đã bỏ Script Hub — bản này chỉ còn nhạc + trợ lý."
or"Script Hub was removed — this build only has music + assistant.")
return
end
end
do
local previousExpand=Isl.expand
Isl.expand=function(page)
if page=="Cross"then
local ok=pcall(previousExpand,"Cross")
pcall(function()Fwd.crossOpen("chat")end)
return ok
end
return previousExpand(page)
end
Fwd.islandExpand=Isl.expand
end
function Cross.clearChat()
table.clear(Cross.Chat)
Cross.ChatVersion+=1
Cross.Bubble.Full=""
Cross.Bubble.Shown=""
Cross.Bubble.Entry=nil
Cross.Echo=""
end
function Cross.shutdown()
Cross.setEnabled(false)
Cross.clearChat()
end
task.spawn(function()
if Music.Remote and type(Music.Remote.LoadDownloaded)=="function"then
local ok,err=pcall(Music.Remote.LoadDownloaded)
if not ok then warn("[xNgotStudio] Music downloaded: "..tostring(err))end
elseif Music.Remote and type(Music.Remote.Load)=="function"then
local ok,err=pcall(Music.Remote.Load)
if not ok then warn("[xNgotStudio] Music AI: "..tostring(err))end
end
end)
local env=type(getgenv)=="function"and getgenv()or _G
local previous=env.__xNgotStudioFullDynamic
if previous and type(previous.Destroy)=="function"then pcall(previous.Destroy,previous)end
State.Ready=true
blur.Size=0
Spr.springIslandY:Set(ISLAND.Top)
Isl.settleIsland()
Cross.Lang=Settings.Language
local API={Version="3.0.0",Enabled=true,Settings=Settings,OriginalUI=true,Root=gui}
function API:Notify(title,message,kind,duration)
if not self.Enabled then return false end
notify(tostring(title or"xNgotStudio"),tostring(message or""),kind or"info",duration or Settings.Duration,true)
return true
end
local gameplayActivityGeneration=0
function API:GameplayActivity(title,message,duration,kind)
if not self.Enabled then return false end
gameplayActivityGeneration+=1
local generation=gameplayActivityGeneration
local text=tostring(message or"")
local shade=kind=="success"and Static.Green or Static.Blue
Activities.Gameplay={
Title=tostring(title or"Auto Farm"),
Color=shade,
Value=function()return text end,
Short=function()return text end,
}
refreshActivity()
task.delay(math.clamp(tonumber(duration)or 11,3,30),function()
if gameplayActivityGeneration~=generation then return end
Activities.Gameplay=nil
if gui.Parent then refreshActivity()end
end)
return true
end
function API:Enable(on)
self.Enabled=on and true or false
gui.Visible=self.Enabled and(not __hostWindow or __hostWindow.__IslandReady==true)
Ring.Holder.Visible=self.Enabled
if not self.Enabled then
if Isl.collapse then Isl.collapse(true,true)end
else
Isl.settleIsland()
end
end
function API:Set(name,value)
if name=="Fps"then setFpsActivity(value and true or false)
elseif name=="Ping"then setPingActivity(value and true or false)
elseif name=="Clock"then setClockActivity(value and true or false)
elseif name=="Language"then
Settings.Language="en"
Cross.Lang="en"
Fwd.applyLanguage()
Fwd.applyLanguage()
elseif Settings[name]~=nil then
Settings[name]=value
if name=="Ring"then
if not value then Ring.ringHide()else Isl.settleIsland()end
elseif name=="Split"then
if Fwd.islandSync then Fwd.islandSync()end
elseif name=="Expand"and not value then
if Isl.collapse then Isl.collapse(true,true)end
elseif name=="Reverb"and sfxReverb then sfxReverb.Enabled=value end
end
end
function API:Theme(n)applyTheme(math.clamp(math.floor(tonumber(n)or 1),1,#Palettes))end
function API:Accent(n)applyAccent(math.clamp(math.floor(tonumber(n)or 1),1,#Accents))end
function API:MusicSelect(n,play)
Music.Select(math.clamp(math.floor(tonumber(n)or 1),1,#Music.Tracks),play~=false)
end
function API:MusicCatalog()
local catalog={}
for index,track in ipairs(Music.Tracks)do
if track.Remote then
catalog[#catalog+1]={
Index=index,
Name=track.Name,
Artist=track.Artist or"",
Genre=track.Mood or"",
Desc=track.Desc or track.Mood or"",
Duration=track.Duration or"",
Thumbnail=track.Thumbnail or"",
Value=track.Value or"",
CoverAsset=track.CoverAsset or"",
Row=track.Row,
}
end
end
return catalog,Music.Remote.State,Music.Remote.Supported()
end
function API:OnMusicCatalogChanged(callback)
if type(callback)~="function"then return function()end end
table.insert(Music.Remote.Listeners,callback)
return function()
local index=table.find(Music.Remote.Listeners,callback)
if index then table.remove(Music.Remote.Listeners,index)end
end
end
function API:OnMusicChanged(callback)
if type(callback)~="function"then return function()end end
table.insert(Music.Listeners,callback)
return function()
local index=table.find(Music.Listeners,callback)
if index then table.remove(Music.Listeners,index)end
end
end
function API:DemoDownload()
if Activities.Download then return end
downloadValue=0
Activities.Download={Title="Download",Label="Demo · xngot_pack.zip",FileName="xngot_pack.zip",Color=Static.Blue,
Value=function()return string.format("%d%%",math.floor(downloadValue*100+0.5))end,
Short=function()return string.format("%d%%",math.floor(downloadValue*100+0.5))end,
Ring=function()return downloadValue end,RingMode="fill"}
refreshActivity()
task.spawn(function()
local started=os.clock()
while gui.Parent and os.clock()-started<4.5 do
local alpha=math.clamp((os.clock()-started)/4.5,0,1)
downloadValue=alpha*alpha*(3-2*alpha)
task.wait(0.05)
end
downloadValue=1
Activities.Download=nil
refreshActivity()
notify("Download complete","Demo progress finished","success",2.8,true)
end)
end
function API:Expand(page)if not self.Enabled then return end Isl.expand(page or"Home")end
function API:Collapse()Isl.collapse(false,false)end
function API:Timer(seconds)startTimer(math.clamp(tonumber(seconds)or 60,1,86400))end
function API:StopTimer()stopTimer()end
function API:ExtendTimer(seconds)extendTimer(tonumber(seconds)or 30)end
function API:WatchToggle()stopwatchToggle()end
function API:WatchLap()stopwatchLap()end
function API:WatchReset()stopwatchReset()end
function API:PlayMusic()Music.Toggle()end
function API:NextMusic(n)Music.Next(tonumber(n)or 1)end
function API:MusicVolume(n)Music.SetVolume(math.clamp(tonumber(n)or 40,0,100))end
function API:MusicSpeed(n)Music.SetTempo(math.clamp(tonumber(n)or 1,0.5,2))end
function API:MusicMode(name,value)
if name=="Auto"or name=="Shuffle"or name=="RepeatOne"or name=="ShowIsland"then Music[name]=value and true or false;Music.Sync()end
end
function API:AiEnable(on)Cross.setEnabled(on and true or false,false)end
function API:AiAsk(prompt)Cross.ask(tostring(prompt or""))end
function API:MusicSearch(prompt)
if not(Music.Remote and Music.Remote.Search)then
notify("Music search","Music search is not ready yet","warn",3,true)
return false
end
Music.Remote.Search(tostring(prompt or""))
return true
end
function API:MusicSearchState()
local remote=Music.Remote
if not remote then return"idle","",0 end
return remote.State,tostring(remote.Query or""),remote.Count or 0
end
function API:MusicSelectValue(value,play)
if type(value)~="string"or value==""then return false end
local wanted=tostring(value)
for index,track in ipairs(Music.Tracks)do
if track.Remote and(track.Value==wanted or tostring(track.Name or"")==wanted)then
Music.Select(index,play~=false)
return true
end
end
return false
end
function API:MusicRows()
local remote=Music.Remote
if not remote then return{},"idle"end
return remote.Rows or{},remote.State
end
function API:MusicFiles(includeSizes)
local remote=Music.Remote
if not remote or type(remote.ScanDownloaded)~="function"then
return{},{Count=0,TotalBytes=0,TotalText="0 B",Mp3Text="0 B",CoversText="0 B",CoversCount=0,Folder="xNgotLibrary/Music",Supported=false}
end
local files,stats=remote.ScanDownloaded(includeSizes==true)
return files or{},stats or{}
end
function API:MusicStorage()
local _,stats=self:MusicFiles(true)
return stats
end
function API:MusicLoadDownloaded()
if not(Music.Remote and type(Music.Remote.LoadDownloaded)=="function")then return 0 end
return Music.Remote.LoadDownloaded()or 0
end
function API:MusicPlayFile(path)
if not self.Enabled then return false end
local wanted=tostring(path or"")
if wanted==""then return false end
local function findAndPlay()
for index,track in ipairs(Music.Tracks)do
if track.CachedPath==wanted or track.FileName==wanted then
Music.Select(index,true)
return true
end
end
return false
end
if findAndPlay()then return true end
self:MusicLoadDownloaded()
return findAndPlay()
end
function API:MusicDeleteFile(path)
local engine=Music.Remote and Music.Remote.Engine
if not engine or type(engine.deleteDownloaded)~="function"then return false,"Engine chua san sang"end
local ok,err=engine.deleteDownloaded(tostring(path or""))
return ok,err
end
function API:MusicClearDownloaded()
local engine=Music.Remote and Music.Remote.Engine
if not engine or type(engine.clearDownloaded)~="function"then return 0,0 end
local deleted,failed=engine.clearDownloaded()
return deleted or 0,failed or 0
end
function API:MusicAiOnline(_on)
return false
end
function API:MusicAiOnlineState()
return{enabled=false,removed=true,mode="local",brain="local"}
end
function API:MusicAiLearn(title,good)
local engine=Music.Remote and Music.Remote.Engine
if not engine or type(engine.learn)~="function"then return false end
engine.learn(title,good)
return true
end
function API:MusicPlayTrack(id,url,source)
if not self.Enabled then return false end
local track={
Id=tostring(id or""),
Url=tostring(url or""),
Source=tostring(source or"youtube"),
}
if track.Id==""and track.Url==""then return false end
local covers=Music.Covers or{{Static.Purple,Static.Blue}}
local cover=covers[(Music.Index%#covers)+1]
Music.AddTrack({
Name=(Settings.Language=="en")and"External track"or"Bài ngoài",
Artist=track.Source,
Mood=track.Source,
Remote=true,
Source=track.Source,
Url=track.Url,
Id=track.Id,
A=cover[1],
B=cover[2],
})
local index=#Music.Tracks
Music.Select(index,true)
return true
end
function API:MusicDownloadOne(id,url,source)
local engine=Music.Remote and Music.Remote.Engine
if not engine then return false end
local track={id=tostring(id or""),url=tostring(url or""),source=tostring(source or"youtube")}
if track.source=="audius"then
track.directUrl="https://api.audius.co/v1/tracks/"
..tostring(track.id):gsub("^audius:","").."/stream"
end
local ok,asset=pcall(function()return engine.assetFor(track,function()end)end)
if ok and type(asset)=="string"and asset~=""then return asset end
return false
end
function API:AiPermission(name,on)
if name=="Body"or name=="Free"then Cross.Perm[name]=false;return false end
if name=="Ui"or name=="Key"then Cross.Perm[name]=on and true or false end
end
function API:AiClear()Cross.clearChat()end
function API:AiOpen()if not Cross.Enabled then Cross.setEnabled(true,false)end self:Expand("Cross")end
function API:SetLanguage(lang)self:Set("Language",lang)end
function API:State()
return{Cross=Cross.Enabled,Playing=Music.Playing,MusicIndex=Music.Index,FPS=math.floor(Metrics.Fps+0.5),Ping=Metrics.Ping,
Timer=Activities.Timer~=nil,Island=self.Enabled}
end
function API:Destroy()
self.Enabled=false
pcall(function()Cross.shutdown()end)
pcall(function()if Isl.collapse then Isl.collapse(true,true)end end)
if gui then pcall(gui.Destroy,gui)end
if env.__xNgotStudioFullDynamic==self then env.__xNgotStudioFullDynamic=nil end
end
env.__xNgotStudioFullDynamic=API
return API
end
local Windows={}
local WindowByTitle={}
local OwnerToken={}
local function WindowIsOurs(win)
return type(win)=="table"and win.__NgotOwner==OwnerToken
end
local function CleanupOtherInstances()
pcall(function()
local prev=_G.xNgotStudio
if type(prev)=="table"and not WindowIsOurs(prev.Window)then
if type(prev.Window)=="table"and type(prev.Window.Destroy)=="function"then
pcall(function()prev.Window:Destroy()end)
end
end
local prevWindow=_G.__xNgotActiveWindow
if type(prevWindow)=="table"and type(prevWindow.Destroy)=="function"then
pcall(function()prevWindow:Destroy()end)
end
end)
local parents={}
pcall(function()if gethui then parents[#parents+1]=gethui()end end)
pcall(function()parents[#parents+1]=game:GetService("CoreGui")end)
pcall(function()
local pg=game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
if pg then parents[#parents+1]=pg end
end)
for _,parent in ipairs(parents)do
pcall(function()
for _,child in ipairs(parent:GetChildren())do
if child~=Gui and child:IsA("ScreenGui")then
local foreign=child:GetAttribute("xNgotStudioOwned")==true
or(child:FindFirstChild("NotificationList")~=nil and child:FindFirstChild("3e")~=nil)
or tostring(child.Name)=="NgotStudio"
or tostring(child.Name):find("xNgotStudio_Full",1,true)~=nil
if not foreign and child:FindFirstChild("NotificationList")then
for _,sub in ipairs(child:GetChildren())do
if sub:IsA("Folder")then
for _,win in ipairs(sub:GetChildren())do
if win:FindFirstChild("TopFrame")and win:FindFirstChild("TabButtons")then
foreign=true
break
end
end
end
if foreign then break end
end
end
if foreign then child:Destroy()end
end
end
end)
end
end
function LIB:CreateWindow(data)
data=data or{}
CleanupOtherInstances()
local titleKey=tostring(data.Title or"NgotStudio")
local previousWindow=WindowByTitle[titleKey]
if previousWindow and type(previousWindow.Destroy)=="function"then
pcall(function()previousWindow:Destroy()end)
end
WindowByTitle[titleKey]=nil
local Window={
__NgotOwner=OwnerToken,
Title=data.Title or"NgotStudio",
Icon=data.Icon or"layout-dashboard",
Version=data.Author or data.Version or"v1.0",
Folder=data.Folder,
Size=data.Size or UDim2 .fromOffset(580,420),
ToggleKey=data.ToggleKey or Enum.KeyCode.RightShift,
ToggleButtonPlatform=data.ToggleButtonPlatform or"Both",
LiveSearchDropdown=data.LiveSearchDropdown==true,
AutoSave=data.AutoSave~=false,
FileSaveName=data.FileSaveName or"NgotStudio_Config.json",
SettingsUI=data.SettingsUI~=false,
SettingsTitle=tostring(data.SettingsTitle or"Settings Ui"),
SettingsIcon=tostring(data.SettingsIcon or"settings"),
Loading=data.Loading,
KeySystem=data.KeySystem,
KeyUnlocked=false,
KeyAttempts=0,
AdminInfo=data.AdminInfo~=false and(type(data.AdminInfo)=="table"and data.AdminInfo or{
Name="Nguyễn Minh Nhật",
Badges={"Owner","Developer"},
Bio="Tuy Tôi Không Giỏi Mọi Thứ, Nhưng Đủ Khiến Người Khác Nể!",
AvatarURL="https://github.com/xngotzume123.png",
})or false,
}
local CONFIG={}
local CONFIGLOADED=false
local canReadConfig=type(isfile)=="function"and type(readfile)=="function"
local canWriteConfig=type(writefile)=="function"
Window.ConfigPath=Window.FileSaveName
if type(Window.Folder)=="string"and Window.Folder~=""then
local folder=Window.Folder:gsub("\\","/"):gsub("/+$","")
local folderReady=false
if type(isfolder)=="function"then
local ok,exists=pcall(isfolder,folder)
folderReady=ok and exists==true
end
if not folderReady and type(makefolder)=="function"then
local ok=pcall(makefolder,folder)
if ok then
if type(isfolder)=="function"then
local checkOk,exists=pcall(isfolder,folder)
folderReady=checkOk and exists==true
else
folderReady=true
end
end
end
if folderReady then
Window.ConfigPath=folder.."/"..Window.FileSaveName
else
warn("Config Folder is unavailable in this environment; using '"..Window.FileSaveName.."' instead.")
end
end
if canReadConfig and isfile(Window.ConfigPath)then
local success,result=pcall(function()
return HttpService:JSONDecode(readfile(Window.ConfigPath))
end)
if success and type(result)=="table"then
CONFIG=result
CONFIGLOADED=true
elseif not success then
warn("Failed to load config '"..Window.ConfigPath.."': "..tostring(result))
end
end
local function WRITECONFIG(force)
if(not force and not Window.AutoSave)or not canWriteConfig then return false end
local success,err=pcall(function()
writefile(Window.ConfigPath,HttpService:JSONEncode(CONFIG))
end)
if not success then
warn("Failed to save config '"..Window.ConfigPath.."': "..tostring(err))
end
return success
end
local function SAVECONFIG()
return WRITECONFIG(false)
end
function Window:SaveConfig()
return WRITECONFIG(true)
end
function Window:GetConfigPath()
return Window.ConfigPath
end
local touchStarts=setmetatable({},{__mode="k"})
local presses=setmetatable({},{__mode="k"})
local touchConnections={}
local function isTouchInput()
local ok,kind=pcall(function()return UIS:GetLastInputType()end)
return ok and kind==Enum.UserInputType.Touch
end
local function BindSafeActivate(button,callback)
button.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch then
touchStarts[input]={x=input.Position.X,y=input.Position.Y,moved=false}
end
end)
button.Activated:Connect(function(input)
if input and input.UserInputType==Enum.UserInputType.Touch then
local start=touchStarts[input]
if not start or start.moved or input.UserInputState==Enum.UserInputState.Cancel then return end
local dx,dy=input.Position.X-start.x,input.Position.Y-start.y
if dx*dx+dy*dy>144 then return end
end
callback()
end)
end
local function BindPressFeedback(button,pressed,released)
button.InputBegan:Connect(function(input)
local kind=input.UserInputType
if kind==Enum.UserInputType.Touch or kind==Enum.UserInputType.MouseButton1 then
presses[input]=released
pressed()
end
end)
button.MouseLeave:Connect(function()released()end)
end
touchConnections[#touchConnections+1]=UIS.InputChanged:Connect(function(input)
local start=touchStarts[input]
if start then
local dx,dy=input.Position.X-start.x,input.Position.Y-start.y
if dx*dx+dy*dy>144 then start.moved=true end
end
end)
touchConnections[#touchConnections+1]=UIS.InputEnded:Connect(function(input)
local release=presses[input]
presses[input]=nil
if release then pcall(release)end
if touchStarts[input]then task.delay(0.5,function()touchStarts[input]=nil end)end
end)
touchConnections[#touchConnections+1]=UIS.WindowFocusReleased:Connect(function()
for key,release in pairs(presses)do pcall(release);presses[key]=nil end
table.clear(touchStarts)
end)
local function touchCleanup()
for _,connection in ipairs(touchConnections)do connection:Disconnect()end
table.clear(touchConnections)
for key,release in pairs(presses)do pcall(release);presses[key]=nil end
end
local windowFolder=Instance.new("Folder")
windowFolder.Parent=Gui
Gui.Name=Window.Title
local newFloatingIcon=oldFloatingIcon:Clone()
newFloatingIcon.Parent=windowFolder
newFloatingIcon.TextLabel.Text=Window.Title
newFloatingIcon.Visible=false
ApplyIcon(newFloatingIcon.Icon,Window.Icon)
local newWindow=oldWindow:Clone()
local mainFrame=newWindow
local TopFrame=mainFrame.TopFrame
local TabButtons=mainFrame.TabButtons
local Tabs=mainFrame.Tabs
local function SetEmptyTabNotice(visible)
if not Tabs then return nil end
local notice=Tabs:FindFirstChild("NoObjectFoundText")
if not notice then
local sourceTabs=oldWindow and oldWindow:FindFirstChild("Tabs")
local sourceNotice=sourceTabs and sourceTabs:FindFirstChild("NoObjectFoundText")
if sourceNotice then
notice=sourceNotice:Clone()
else
notice=Instance.new("TextLabel")
notice.Name="NoObjectFoundText"
notice.BackgroundTransparency=1
notice.BorderSizePixel=0
notice.TextWrapped=true
notice.TextScaled=true
notice.TextColor3=Color3 .fromRGB(135,140,150)
notice.Text="This tab is empty :("
notice.AnchorPoint=Vector2 .new(0.5,0.5)
notice.Position=UDim2 .new(0.5,0,0.45,0)
notice.Size=UDim2 .new(1,0,0,16)
end
notice.Parent=Tabs
end
notice.Visible=visible==true
return notice
end
newWindow.Name=Window.Title
TopFrame.TextLabel.Text=Window.Title.." - "..Window.Version
ApplyIcon(TopFrame.Icon,Window.Icon)
newWindow.Size=Window.Size
newWindow.Visible=false
newWindow.Parent=windowFolder
table.insert(Windows,newWindow)
local Lighting=game:GetService("Lighting")
local themeBase=setmetatable({},{__mode="k"})
local themeDestroyed=false
local themeApplyToken=0
local uiSaveToken=0
local settingsControls={}
local settingsBuilding=false
local syncSettingsControls=function()end
local function clampNumber(value,minimum,maximum,fallback)
value=tonumber(value)
if value==nil then return fallback end
return math.clamp(value,minimum,maximum)
end
local function colorToHex(color)
if typeof(color)~="Color3"then return"#FFFFFF"end
return string.format("#%02X%02X%02X",
math.floor(color.R*255+0.5),
math.floor(color.G*255+0.5),
math.floor(color.B*255+0.5)
)
end
local function colorFrom(value,fallback)
if typeof(value)=="Color3"then return value end
if type(value)=="table"then
local r=tonumber(value.R or value.r or value[1])
local g=tonumber(value.G or value.g or value[2])
local b=tonumber(value.B or value.b or value[3])
if r and g and b then
if math.max(r,g,b)<=1 then return Color3 .new(r,g,b)end
return Color3 .fromRGB(math.clamp(r,0,255),math.clamp(g,0,255),math.clamp(b,0,255))
end
end
if type(value)=="string"then
local hex=value:gsub("#",""):gsub("0x","")
if#hex==6 and hex:match("^[%x]+$")then
return Color3 .fromRGB(
tonumber(hex:sub(1,2),16),
tonumber(hex:sub(3,4),16),
tonumber(hex:sub(5,6),16)
)
end
end
return fallback
end
local FONT_MAP={
Gotham=Enum.Font.Gotham,
GothamMedium=Enum.Font.GothamMedium,
GothamBold=Enum.Font.GothamBold,
SourceSans=Enum.Font.SourceSans,
SourceSansSemibold=Enum.Font.SourceSansSemibold,
SourceSansBold=Enum.Font.SourceSansBold,
Arial=Enum.Font.Arial,
ArialBold=Enum.Font.ArialBold,
Code=Enum.Font.Code,
Cartoon=Enum.Font.Cartoon,
SciFi=Enum.Font.SciFi,
}
local function normalizeFontSelection(value)
value=tostring(value or"Original")
if value=="GothamMedium"or value=="GothamBold"then return"Gotham"end
if value=="SourceSansSemibold"or value=="SourceSansBold"then return"SourceSans"end
if value=="ArialBold"then return"Arial"end
if value=="Original"or value=="Gotham"or value=="SourceSans"or value=="Arial"or value=="Code"or value=="Cartoon"or value=="SciFi"then
return value
end
return"Original"
end
local function fontForBase(baseFont,family)
family=normalizeFontSelection(family)
if family=="Original"then return baseFont end
if family=="Code"or family=="Cartoon"or family=="SciFi"then
return FONT_MAP[family]or baseFont
end
local baseName=tostring(baseFont or"")
local bold=string.find(baseName,"Bold",1,true)~=nil or string.find(baseName,"Black",1,true)~=nil
local medium=bold or string.find(baseName,"Medium",1,true)~=nil or string.find(baseName,"Semibold",1,true)~=nil
if family=="Gotham"then
if bold then return Enum.Font.GothamBold end
if medium then return Enum.Font.GothamMedium end
return Enum.Font.Gotham
elseif family=="SourceSans"then
if bold then return Enum.Font.SourceSansBold end
if medium then return Enum.Font.SourceSansSemibold end
return Enum.Font.SourceSans
elseif family=="Arial"then
return bold and Enum.Font.ArialBold or Enum.Font.Arial
end
return baseFont
end
local originalWindowSize=Window.Size
local originalWindowWidth=tonumber(Window.Size.X.Offset)or 0
local originalWindowHeight=tonumber(Window.Size.Y.Offset)or 0
if originalWindowWidth<=0 then originalWindowWidth=math.max(420,math.floor(newWindow.AbsoluteSize.X+0.5))end
if originalWindowHeight<=0 then originalWindowHeight=math.max(300,math.floor(newWindow.AbsoluteSize.Y+0.5))end
originalWindowWidth=math.clamp(originalWindowWidth,420,1000)
originalWindowHeight=math.clamp(originalWindowHeight,300,800)
local windowSizeRuntimeSetter=nil
local UI_DEFAULTS={
Enabled=false,
Preset="Default",
Font="Original",
TextScale=1,
UIScale=1,
WindowWidth=originalWindowWidth,
WindowHeight=originalWindowHeight,
WindowOpacity=100,
BoxOpacity=100,
BackgroundMode="Color",
BackgroundColor=Color3 .fromRGB(37,40,47),
SurfaceColor=Color3 .fromRGB(32,35,41),
AccentColor=Color3 .fromRGB(10,135,213),
TextColor=Color3 .fromRGB(197,204,219),
MutedTextColor=Color3 .fromRGB(150,155,165),
BackgroundImage="",
BackgroundImageTransparency=25,
BackgroundImageScale="Crop",
Blur=0,
CornerRadius=10,
AnimationSpeed=1,
ReduceMotion=false,
LiquidGlassStrength=55,
ShowFloatingButtonText=true,
}
local UI_PRESETS={
Default={},
Midnight={
BackgroundColor=Color3 .fromRGB(15,18,25),SurfaceColor=Color3 .fromRGB(22,27,38),
AccentColor=Color3 .fromRGB(88,166,255),TextColor=Color3 .fromRGB(232,237,247),
MutedTextColor=Color3 .fromRGB(142,153,174),WindowOpacity=100,BoxOpacity=96,
CornerRadius=12,Blur=0,BackgroundMode="Color",
},
OLED={
BackgroundColor=Color3 .fromRGB(0,0,0),SurfaceColor=Color3 .fromRGB(10,10,12),
AccentColor=Color3 .fromRGB(0,170,255),TextColor=Color3 .fromRGB(245,245,247),
MutedTextColor=Color3 .fromRGB(145,145,150),WindowOpacity=100,BoxOpacity=100,
CornerRadius=10,Blur=0,BackgroundMode="Color",
},
Light={
BackgroundColor=Color3 .fromRGB(242,244,248),SurfaceColor=Color3 .fromRGB(255,255,255),
AccentColor=Color3 .fromRGB(0,122,255),TextColor=Color3 .fromRGB(28,30,34),
MutedTextColor=Color3 .fromRGB(94,99,110),WindowOpacity=100,BoxOpacity=96,
CornerRadius=12,Blur=0,BackgroundMode="Color",
},
Ocean={
BackgroundColor=Color3 .fromRGB(12,24,36),SurfaceColor=Color3 .fromRGB(18,38,52),
AccentColor=Color3 .fromRGB(0,188,212),TextColor=Color3 .fromRGB(224,247,250),
MutedTextColor=Color3 .fromRGB(128,177,188),WindowOpacity=98,BoxOpacity=92,
CornerRadius=14,Blur=4,BackgroundMode="Color",
},
Violet={
BackgroundColor=Color3 .fromRGB(27,20,40),SurfaceColor=Color3 .fromRGB(39,29,58),
AccentColor=Color3 .fromRGB(168,85,247),TextColor=Color3 .fromRGB(245,238,255),
MutedTextColor=Color3 .fromRGB(177,157,199),WindowOpacity=98,BoxOpacity=92,
CornerRadius=14,Blur=4,BackgroundMode="Color",
},
Rose={
BackgroundColor=Color3 .fromRGB(21,21,21),SurfaceColor=Color3 .fromRGB(31,31,31),
AccentColor=Color3 .fromRGB(183,243,74),TextColor=Color3 .fromRGB(243,243,238),
MutedTextColor=Color3 .fromRGB(134,134,128),WindowOpacity=100,BoxOpacity=96,
CornerRadius=12,Blur=0,BackgroundMode="Color",
},
["Liquid Glass"]={
BackgroundColor=Color3 .fromRGB(22,25,31),SurfaceColor=Color3 .fromRGB(47,53,63),
AccentColor=Color3 .fromRGB(0,122,255),TextColor=Color3 .fromRGB(245,247,252),
MutedTextColor=Color3 .fromRGB(183,190,203),WindowOpacity=72,BoxOpacity=58,
CornerRadius=18,Blur=18,BackgroundMode="Liquid Glass",LiquidGlassStrength=62,
},
}
local function copySettings(source)
local result={}
for key,value in pairs(source)do result[key]=value end
return result
end
local UISettings=copySettings(UI_DEFAULTS)
local UIOverrides={}
local function copyOverrides(source)
local result={}
if type(source)=="table"then
for key,value in pairs(source)do
if value==true then result[key]=true end
end
end
return result
end
local function hasUIOverrides()
return next(UIOverrides)~=nil
end
local function setOverride(key,enabled)
if enabled==false then UIOverrides[key]=nil else UIOverrides[key]=true end
UISettings.Enabled=hasUIOverrides()
end
local function serializeUISettings(settings)
return{
Enabled=settings.Enabled==true and hasUIOverrides(),
SettingsVersion=3,
Overrides=copyOverrides(UIOverrides),
Preset=settings.Preset,
Font=settings.Font,
TextScale=settings.TextScale,
UIScale=settings.UIScale,
WindowWidth=settings.WindowWidth,
WindowHeight=settings.WindowHeight,
WindowOpacity=settings.WindowOpacity,
BoxOpacity=settings.BoxOpacity,
BackgroundMode=settings.BackgroundMode,
BackgroundColor=colorToHex(settings.BackgroundColor),
SurfaceColor=colorToHex(settings.SurfaceColor),
AccentColor=colorToHex(settings.AccentColor),
TextColor=colorToHex(settings.TextColor),
MutedTextColor=colorToHex(settings.MutedTextColor),
BackgroundImage=settings.BackgroundImage,
BackgroundImageTransparency=settings.BackgroundImageTransparency,
BackgroundImageScale=settings.BackgroundImageScale,
Blur=settings.Blur,
CornerRadius=settings.CornerRadius,
AnimationSpeed=settings.AnimationSpeed,
ReduceMotion=settings.ReduceMotion,
LiquidGlassStrength=settings.LiquidGlassStrength,
ShowFloatingButtonText=settings.ShowFloatingButtonText,
}
end
local function mergeUISettings(source)
if type(source)~="table"then return end
if source.Enabled~=nil then UISettings.Enabled=source.Enabled==true end
if type(source.Preset)=="string"then UISettings.Preset=source.Preset end
if type(source.Font)=="string"then UISettings.Font=normalizeFontSelection(source.Font)end
UISettings.TextScale=clampNumber(source.TextScale,0.7,1.5,UISettings.TextScale)
UISettings.UIScale=clampNumber(source.UIScale,0.65,1.5,UISettings.UIScale)
UISettings.WindowWidth=clampNumber(source.WindowWidth,420,1000,UISettings.WindowWidth)
UISettings.WindowHeight=clampNumber(source.WindowHeight,300,800,UISettings.WindowHeight)
UISettings.WindowOpacity=clampNumber(source.WindowOpacity,15,100,UISettings.WindowOpacity)
UISettings.BoxOpacity=clampNumber(source.BoxOpacity,10,100,UISettings.BoxOpacity)
if type(source.BackgroundMode)=="string"then UISettings.BackgroundMode=source.BackgroundMode end
UISettings.BackgroundColor=colorFrom(source.BackgroundColor,UISettings.BackgroundColor)
UISettings.SurfaceColor=colorFrom(source.SurfaceColor,UISettings.SurfaceColor)
UISettings.AccentColor=colorFrom(source.AccentColor,UISettings.AccentColor)
UISettings.TextColor=colorFrom(source.TextColor,UISettings.TextColor)
UISettings.MutedTextColor=colorFrom(source.MutedTextColor,UISettings.MutedTextColor)
if source.BackgroundImage~=nil then UISettings.BackgroundImage=tostring(source.BackgroundImage or"")end
UISettings.BackgroundImageTransparency=clampNumber(source.BackgroundImageTransparency,0,100,UISettings.BackgroundImageTransparency)
if type(source.BackgroundImageScale)=="string"then UISettings.BackgroundImageScale=source.BackgroundImageScale end
UISettings.Blur=clampNumber(source.Blur,0,32,UISettings.Blur)
UISettings.CornerRadius=clampNumber(source.CornerRadius,0,28,UISettings.CornerRadius)
UISettings.AnimationSpeed=clampNumber(source.AnimationSpeed,0.2,3,UISettings.AnimationSpeed)
if source.ReduceMotion~=nil then UISettings.ReduceMotion=source.ReduceMotion==true end
UISettings.LiquidGlassStrength=clampNumber(source.LiquidGlassStrength,0,100,UISettings.LiquidGlassStrength)
if source.ShowFloatingButtonText~=nil then UISettings.ShowFloatingButtonText=source.ShowFloatingButtonText==true end
end
local savedUISettings=CONFIG.__NgotUISettings
if type(savedUISettings)=="table"and savedUISettings.SettingsVersion==3 and type(savedUISettings.Overrides)=="table"then
mergeUISettings(savedUISettings)
UIOverrides=copyOverrides(savedUISettings.Overrides)
UISettings.Enabled=hasUIOverrides()
if not UISettings.Enabled then UISettings.Preset="Default"end
else
UIOverrides={}
UISettings.Enabled=false
UISettings.Preset="Default"
end
if type(CONFIG.__NgotUIProfiles)~="table"then CONFIG.__NgotUIProfiles={}end
local backgroundLayer=Instance.new("ImageLabel")
backgroundLayer.Name="NgotStudioThemeBackground"
backgroundLayer.BackgroundTransparency=1
backgroundLayer.BorderSizePixel=0
backgroundLayer.Size=UDim2 .fromScale(1,1)
backgroundLayer.Position=UDim2 .fromScale(0,0)
backgroundLayer.Image=""
backgroundLayer.ImageTransparency=1
backgroundLayer.ScaleType=Enum.ScaleType.Crop
backgroundLayer.ZIndex=0
backgroundLayer.Parent=newWindow
local backgroundCorner=Instance.new("UICorner")
backgroundCorner.Name="NgotStudioThemeBackgroundCorner"
backgroundCorner.CornerRadius=UDim.new(0,10)
backgroundCorner.Parent=backgroundLayer
local liquidGradient=Instance.new("UIGradient")
liquidGradient.Name="NgotStudioThemeLiquidGradient"
liquidGradient.Rotation=135
local liquidStroke=Instance.new("UIStroke")
liquidStroke.Name="NgotStudioThemeLiquidStroke"
liquidStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
liquidStroke.Thickness=1.2
liquidStroke.Transparency=1
liquidStroke.Parent=newWindow
local liquidBlur=Instance.new("BlurEffect")
liquidBlur.Name="NgotStudioLiquidGlass_"..tostring(math.random(100000,999999))
liquidBlur.Size=0
liquidBlur.Enabled=false
liquidBlur.Parent=Lighting
local uiScale=newWindow:FindFirstChild("NgotStudioThemeScale")or Instance.new("UIScale")
uiScale.Name="NgotStudioThemeScale"
uiScale.Parent=newWindow
local floatingScale=newFloatingIcon:FindFirstChild("NgotStudioThemeScale")or Instance.new("UIScale")
floatingScale.Name="NgotStudioThemeScale"
floatingScale.Parent=newFloatingIcon
local floatingText=newFloatingIcon:FindFirstChild("TextLabel")
local floatingTextOriginalVisible=floatingText and floatingText.Visible or nil
local BASE_TWEEN={Global=0.25,Notification=0.5,PopupOpen=0.4,PopupClose=0.4}
local function captureThemeBase(instance)
if themeBase[instance]then return themeBase[instance]end
local state={}
if instance:IsA("GuiObject")then
state.BackgroundColor3=instance.BackgroundColor3
state.BackgroundTransparency=instance.BackgroundTransparency
end
if instance:IsA("TextLabel")or instance:IsA("TextButton")or instance:IsA("TextBox")then
state.TextColor3=instance.TextColor3
state.TextTransparency=instance.TextTransparency
state.Font=instance.Font
state.TextSize=instance.TextSize
end
if instance:IsA("ImageLabel")or instance:IsA("ImageButton")then
state.ImageColor3=instance.ImageColor3
state.ImageTransparency=instance.ImageTransparency
end
if instance:IsA("UIStroke")then
state.Color=instance.Color
state.Transparency=instance.Transparency
state.Thickness=instance.Thickness
end
if instance:IsA("UICorner")then state.CornerRadius=instance.CornerRadius end
themeBase[instance]=state
return state
end
local function restoreThemeObject(instance)
local base=themeBase[instance]
if not base or not instance or not instance.Parent then return end
if instance:IsA("GuiObject")then
if base.BackgroundColor3~=nil then instance.BackgroundColor3=base.BackgroundColor3 end
if base.BackgroundTransparency~=nil then instance.BackgroundTransparency=base.BackgroundTransparency end
end
if instance:IsA("TextLabel")or instance:IsA("TextButton")or instance:IsA("TextBox")then
if base.TextColor3~=nil then instance.TextColor3=base.TextColor3 end
if base.TextTransparency~=nil then instance.TextTransparency=base.TextTransparency end
if base.Font~=nil then instance.Font=base.Font end
if base.TextSize~=nil then instance.TextSize=base.TextSize end
end
if instance:IsA("ImageLabel")or instance:IsA("ImageButton")then
if base.ImageColor3~=nil then instance.ImageColor3=base.ImageColor3 end
if base.ImageTransparency~=nil then instance.ImageTransparency=base.ImageTransparency end
end
if instance:IsA("UIStroke")then
if base.Color~=nil then instance.Color=base.Color end
if base.Transparency~=nil then instance.Transparency=base.Transparency end
if base.Thickness~=nil then instance.Thickness=base.Thickness end
end
if instance:IsA("UICorner")and base.CornerRadius~=nil then
instance.CornerRadius=base.CornerRadius
end
end
captureThemeBase(newWindow)
captureThemeBase(newFloatingIcon)
if newWindow:FindFirstChild("UICorner")then captureThemeBase(newWindow.UICorner)end
local function getDesiredWindowSize()
if not UIOverrides.WindowWidth and not UIOverrides.WindowHeight then
return originalWindowSize
end
local width=UIOverrides.WindowWidth and UISettings.WindowWidth or originalWindowWidth
local height=UIOverrides.WindowHeight and UISettings.WindowHeight or originalWindowHeight
return UDim2 .fromOffset(
math.floor(math.clamp(tonumber(width)or originalWindowWidth,420,1000)+0.5),
math.floor(math.clamp(tonumber(height)or originalWindowHeight,300,800)+0.5)
)
end
local function applyWindowSizeOverrides()
local desired=getDesiredWindowSize()
Window.Size=desired
if type(windowSizeRuntimeSetter)=="function"then
windowSizeRuntimeSetter(desired)
elseif newWindow and newWindow.Parent then
newWindow.Size=desired
end
return desired
end
local function restoreOriginalUI()
if themeDestroyed then return end
Window.Size=originalWindowSize
if type(windowSizeRuntimeSetter)=="function"then
windowSizeRuntimeSetter(originalWindowSize)
elseif newWindow and newWindow.Parent then
newWindow.Size=originalWindowSize
end
for instance in pairs(themeBase)do
restoreThemeObject(instance)
end
backgroundLayer.Visible=false
backgroundLayer.Image=""
backgroundLayer.ImageTransparency=1
liquidGradient.Parent=nil
liquidStroke.Transparency=1
uiScale.Scale=1
floatingScale.Scale=1
if floatingText and floatingTextOriginalVisible~=nil then
floatingText.Visible=floatingTextOriginalVisible
end
restoreThemeObject(newFloatingIcon)
TweenConfigs.Global.Duration=BASE_TWEEN.Global
TweenConfigs.Notification.Duration=BASE_TWEEN.Notification
TweenConfigs.PopupOpen.Duration=BASE_TWEEN.PopupOpen
TweenConfigs.PopupClose.Duration=BASE_TWEEN.PopupClose
liquidBlur.Size=0
liquidBlur.Enabled=false
end
local function restoreOverrideKey(key)
key=tostring(key or"")
if key=="WindowWidth"or key=="WindowHeight"then
applyWindowSizeOverrides()
elseif key=="BackgroundColor"then
local base=themeBase[newWindow]
if base and base.BackgroundColor3~=nil then newWindow.BackgroundColor3=base.BackgroundColor3 end
elseif key=="WindowOpacity"then
local base=themeBase[newWindow]
if base and base.BackgroundTransparency~=nil then newWindow.BackgroundTransparency=base.BackgroundTransparency end
elseif key=="BackgroundMode"then
local base=themeBase[newWindow]
if base and base.BackgroundTransparency~=nil then newWindow.BackgroundTransparency=base.BackgroundTransparency end
backgroundLayer.Visible=false
backgroundLayer.Image=""
liquidGradient.Parent=nil
liquidStroke.Transparency=1
liquidBlur.Size=0
liquidBlur.Enabled=false
elseif key=="BackgroundImage"then
backgroundLayer.Image=""
elseif key=="BackgroundImageTransparency"then
backgroundLayer.ImageTransparency=1
elseif key=="BackgroundImageScale"then
backgroundLayer.ScaleType=Enum.ScaleType.Crop
elseif key=="UIScale"then
uiScale.Scale=1
floatingScale.Scale=1
elseif key=="ShowFloatingButtonText"then
if floatingText and floatingTextOriginalVisible~=nil then floatingText.Visible=floatingTextOriginalVisible end
elseif key=="AnimationSpeed"or key=="ReduceMotion"then
TweenConfigs.Global.Duration=BASE_TWEEN.Global
TweenConfigs.Notification.Duration=BASE_TWEEN.Notification
TweenConfigs.PopupOpen.Duration=BASE_TWEEN.PopupOpen
TweenConfigs.PopupClose.Duration=BASE_TWEEN.PopupClose
elseif key=="Blur"then
liquidBlur.Size=0
liquidBlur.Enabled=false
end
for instance,base in pairs(themeBase)do
if instance and instance.Parent and base then
if key=="Font"and(instance:IsA("TextLabel")or instance:IsA("TextButton")or instance:IsA("TextBox"))then
if base.Font~=nil then instance.Font=base.Font end
elseif key=="TextScale"and(instance:IsA("TextLabel")or instance:IsA("TextButton")or instance:IsA("TextBox"))then
if base.TextSize~=nil then instance.TextSize=base.TextSize end
elseif key=="SurfaceColor"and instance:IsA("GuiObject")and instance~=newWindow then
if base.BackgroundColor3~=nil then instance.BackgroundColor3=base.BackgroundColor3 end
elseif key=="AccentColor"then
if instance:IsA("GuiObject")and instance~=newWindow and base.BackgroundColor3~=nil then instance.BackgroundColor3=base.BackgroundColor3 end
if(instance:IsA("ImageLabel")or instance:IsA("ImageButton"))and base.ImageColor3~=nil then instance.ImageColor3=base.ImageColor3 end
if instance:IsA("UIStroke")and base.Color~=nil then instance.Color=base.Color end
elseif key=="TextColor"then
if(instance:IsA("TextLabel")or instance:IsA("TextButton")or instance:IsA("TextBox"))and base.TextColor3~=nil then instance.TextColor3=base.TextColor3 end
if(instance:IsA("ImageLabel")or instance:IsA("ImageButton"))and base.ImageColor3~=nil then instance.ImageColor3=base.ImageColor3 end
elseif key=="MutedTextColor"and(instance:IsA("TextLabel")or instance:IsA("TextButton")or instance:IsA("TextBox"))then
if base.TextColor3~=nil then instance.TextColor3=base.TextColor3 end
elseif key=="BoxOpacity"and instance:IsA("GuiObject")and instance~=newWindow then
if base.BackgroundTransparency~=nil then instance.BackgroundTransparency=base.BackgroundTransparency end
elseif key=="CornerRadius"and instance:IsA("UICorner")then
if base.CornerRadius~=nil then instance.CornerRadius=base.CornerRadius end
end
end
end
end
local function isAccentColor(color)
if typeof(color)~="Color3"then return false end
local h,s,v=color:ToHSV()
return h>=0.50 and h<=0.67 and s>=0.40 and v>=0.45
end
local function imageScaleType(name)
if name=="Fit"then return Enum.ScaleType.Fit end
if name=="Stretch"then return Enum.ScaleType.Stretch end
if name=="Tile"then return Enum.ScaleType.Tile end
return Enum.ScaleType.Crop
end
local function resolveBackgroundImage(value)
value=tostring(value or"")
if value==""then return""end
if tonumber(value)then return"rbxassetid://"..value end
return value
end
local function blendColor(baseColor,targetColor,amount)
if typeof(baseColor)~="Color3"or typeof(targetColor)~="Color3"then return baseColor end
return baseColor:Lerp(targetColor,math.clamp(amount or 0.65,0,1))
end
local function opacityFromBase(baseTransparency,opacityPercent)
baseTransparency=tonumber(baseTransparency)or 0
local opacity=math.clamp((tonumber(opacityPercent)or 100)/100,0,1)
return 1-((1-baseTransparency)*opacity)
end
local function applyThemeToObject(instance)
if not UISettings.Enabled or not hasUIOverrides()then return end
if not instance or not instance.Parent then return end
if instance==backgroundLayer or instance==liquidGradient or instance==liquidStroke or instance==uiScale or instance==floatingScale then return end
if string.sub(instance.Name,1,15)=="NgotStudioTheme"or instance.Name=="NgotStudioColorPreview"then return end
local base=captureThemeBase(instance)
local lowerName=string.lower(instance.Name or"")
if instance:IsA("GuiObject")and instance~=newWindow then
if base.BackgroundTransparency~=nil and base.BackgroundTransparency<0.98 then
if UIOverrides.SurfaceColor and not string.find(lowerName,"overlay",1,true)and not isAccentColor(base.BackgroundColor3)then
instance.BackgroundColor3=blendColor(base.BackgroundColor3,UISettings.SurfaceColor,0.62)
end
if UIOverrides.AccentColor and isAccentColor(base.BackgroundColor3)then
instance.BackgroundColor3=UISettings.AccentColor
end
if UIOverrides.BoxOpacity and not string.find(lowerName,"overlay",1,true)then
instance.BackgroundTransparency=opacityFromBase(base.BackgroundTransparency,UISettings.BoxOpacity)
end
end
end
if instance:IsA("TextLabel")or instance:IsA("TextButton")or instance:IsA("TextBox")then
if UIOverrides.Font then instance.Font=fontForBase(base.Font or instance.Font,UISettings.Font)end
if UIOverrides.TextScale then instance.TextSize=math.max(8,(base.TextSize or instance.TextSize)*UISettings.TextScale)end
if UIOverrides.TextColor and(base.TextTransparency or 0)<0.28 then
instance.TextColor3=UISettings.TextColor
elseif UIOverrides.MutedTextColor and(base.TextTransparency or 0)>=0.28 then
instance.TextColor3=UISettings.MutedTextColor
end
end
if instance:IsA("ImageLabel")or instance:IsA("ImageButton")then
if UIOverrides.AccentColor and isAccentColor(base.ImageColor3)then
instance.ImageColor3=UISettings.AccentColor
elseif UIOverrides.TextColor and base.ImageColor3 and base.ImageColor3 .R>0.45 and base.ImageColor3 .G>0.45 and base.ImageColor3 .B>0.45 then
instance.ImageColor3=blendColor(base.ImageColor3,UISettings.TextColor,0.75)
end
end
if instance:IsA("UIStroke")then
if UIOverrides.AccentColor and isAccentColor(base.Color)then instance.Color=UISettings.AccentColor end
end
if instance:IsA("UICorner")and base.CornerRadius and UIOverrides.CornerRadius then
if base.CornerRadius.Scale<0.4 then instance.CornerRadius=UDim.new(0,UISettings.CornerRadius)end
end
end
local function applyUITheme()
if themeDestroyed or not newWindow or not newWindow.Parent then return end
UISettings.Enabled=hasUIOverrides()
if not UISettings.Enabled then return end
local liquid=UIOverrides.BackgroundMode and UISettings.BackgroundMode=="Liquid Glass"
local imageMode=UIOverrides.BackgroundMode and UISettings.BackgroundMode=="Image"
if UIOverrides.WindowWidth or UIOverrides.WindowHeight then applyWindowSizeOverrides()end
if UIOverrides.BackgroundColor then newWindow.BackgroundColor3=UISettings.BackgroundColor end
if UIOverrides.WindowOpacity then
local rootBase=captureThemeBase(newWindow)
newWindow.BackgroundTransparency=opacityFromBase(rootBase.BackgroundTransparency,UISettings.WindowOpacity)
end
backgroundLayer.Visible=false
liquidGradient.Parent=nil
liquidStroke.Transparency=1
liquidBlur.Size=0
liquidBlur.Enabled=false
if imageMode then
backgroundLayer.Image=resolveBackgroundImage(UISettings.BackgroundImage)
backgroundLayer.ScaleType=imageScaleType(UISettings.BackgroundImageScale)
backgroundLayer.ImageTransparency=math.clamp(UISettings.BackgroundImageTransparency/100,0,1)
backgroundLayer.Visible=backgroundLayer.Image~=""
if backgroundLayer.Visible then newWindow.BackgroundTransparency=1 end
elseif liquid then
local strength=math.clamp(UISettings.LiquidGlassStrength/100,0,1)
local rootBase=captureThemeBase(newWindow)
newWindow.BackgroundTransparency=math.max(newWindow.BackgroundTransparency,opacityFromBase(rootBase.BackgroundTransparency,94-18*strength))
liquidGradient.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3 .fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.55,rootBase.BackgroundColor3 or Color3 .fromRGB(37,40,47)),
ColorSequenceKeypoint.new(1,UIOverrides.AccentColor and UISettings.AccentColor or Color3 .fromRGB(120,170,255)),
})
liquidGradient.Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,0.90-0.10*strength),
NumberSequenceKeypoint.new(0.55,0.96),
NumberSequenceKeypoint.new(1,0.91-0.08*strength),
})
liquidGradient.Parent=newWindow
liquidStroke.Color=Color3 .fromRGB(236,243,255)
liquidStroke.Transparency=math.clamp(0.92-0.18*strength,0.68,0.94)
if UIOverrides.Blur then
liquidBlur.Size=UISettings.Blur
liquidBlur.Enabled=UISettings.Blur>0 and newWindow.Visible
end
end
if UIOverrides.UIScale then
uiScale.Scale=UISettings.UIScale
floatingScale.Scale=UISettings.UIScale
end
if UIOverrides.ShowFloatingButtonText and floatingText then
floatingText.Visible=UISettings.ShowFloatingButtonText
end
if UIOverrides.AnimationSpeed or UIOverrides.ReduceMotion then
local speed=UIOverrides.AnimationSpeed and math.max(UISettings.AnimationSpeed,0.2)or 1
if UIOverrides.ReduceMotion and UISettings.ReduceMotion then speed=100 end
TweenConfigs.Global.Duration=math.max(0.01,BASE_TWEEN.Global/speed)
TweenConfigs.Notification.Duration=math.max(0.01,BASE_TWEEN.Notification/speed)
TweenConfigs.PopupOpen.Duration=math.max(0.01,BASE_TWEEN.PopupOpen/speed)
TweenConfigs.PopupClose.Duration=math.max(0.01,BASE_TWEEN.PopupClose/speed)
end
for _,descendant in ipairs(newWindow:GetDescendants())do applyThemeToObject(descendant)end
for _,descendant in ipairs(newFloatingIcon:GetDescendants())do applyThemeToObject(descendant)end
applyThemeToObject(newFloatingIcon)
end
local function scheduleThemeApply()
themeApplyToken+=1
local token=themeApplyToken
task.delay(0.03,function()
if token==themeApplyToken and not themeDestroyed then applyUITheme()end
end)
end
local function storeUISettings(force)
CONFIG.__NgotUISettings=serializeUISettings(UISettings)
if force then return WRITECONFIG(true)end
return SAVECONFIG()
end
function Window:SaveConfig()
CONFIG.__NgotUISettings=serializeUISettings(UISettings)
return WRITECONFIG(true)
end
local function queueUISettingsSave()
if settingsBuilding or not Window.AutoSave then return end
uiSaveToken+=1
local token=uiSaveToken
task.delay(0.4,function()
if token==uiSaveToken and not themeDestroyed then storeUISettings(false)end
end)
end
local function setUISetting(key,value)
if settingsBuilding then return end
key=tostring(key or"")
restoreOverrideKey(key)
if key=="Font"then
value=normalizeFontSelection(value)
UISettings.Font=value
if value=="Original"then
setOverride(key,false)
else
setOverride(key,true)
end
elseif key=="BackgroundColor"or key=="SurfaceColor"or key=="AccentColor"or key=="TextColor"or key=="MutedTextColor"then
UISettings[key]=colorFrom(value,UISettings[key])
setOverride(key,true)
else
UISettings[key]=value
setOverride(key,true)
end
UISettings.Preset=hasUIOverrides()and"Custom"or"Default"
if settingsControls.Preset and type(settingsControls.Preset.Select)=="function"then
settingsBuilding=true
pcall(settingsControls.Preset.Select,settingsControls.Preset,UISettings.Preset)
settingsBuilding=false
end
applyUITheme()
queueUISettingsSave()
end
local function applyPreset(name,save)
name=tostring(name or"Default")
if name=="Default"then
for key,value in pairs(UI_DEFAULTS)do UISettings[key]=value end
UIOverrides={}
UISettings.Enabled=false
UISettings.Preset="Default"
restoreOriginalUI()
syncSettingsControls()
if save~=false then queueUISettingsSave()end
return true
end
if name=="Custom"then
UISettings.Enabled=hasUIOverrides()
UISettings.Preset="Custom"
if save~=false then queueUISettingsSave()end
return true
end
local preset=UI_PRESETS[name]
if not preset then return false end
restoreOriginalUI()
for key,value in pairs(UI_DEFAULTS)do UISettings[key]=value end
UIOverrides={}
for key,value in pairs(preset)do UISettings[key]=value;UIOverrides[key]=true end
UISettings.Enabled=hasUIOverrides()
UISettings.Preset=name
applyUITheme()
syncSettingsControls()
if save~=false then queueUISettingsSave()end
return true
end
function Window:SetUISize(width,height,save)
width=math.floor(math.clamp(tonumber(width)or UISettings.WindowWidth,420,1000)+0.5)
height=math.floor(math.clamp(tonumber(height)or UISettings.WindowHeight,300,800)+0.5)
restoreOverrideKey("WindowWidth")
restoreOverrideKey("WindowHeight")
UISettings.WindowWidth=width
UISettings.WindowHeight=height
setOverride("WindowWidth",width~=originalWindowWidth)
setOverride("WindowHeight",height~=originalWindowHeight)
UISettings.Preset=hasUIOverrides()and"Custom"or"Default"
applyWindowSizeOverrides()
syncSettingsControls()
if save~=false then queueUISettingsSave()end
return Window.Size
end
function Window:GetUISize()
local size=getDesiredWindowSize()
return size,UISettings.WindowWidth,UISettings.WindowHeight
end
function Window:ResetUISize(save)
UIOverrides.WindowWidth=nil
UIOverrides.WindowHeight=nil
UISettings.WindowWidth=originalWindowWidth
UISettings.WindowHeight=originalWindowHeight
UISettings.Enabled=hasUIOverrides()
UISettings.Preset=UISettings.Enabled and"Custom"or"Default"
applyWindowSizeOverrides()
syncSettingsControls()
if save~=false then queueUISettingsSave()end
return Window.Size
end
function Window:GetUISettings()
local result=copySettings(UISettings)
result.Overrides=copyOverrides(UIOverrides)
return result
end
function Window:GetUIOverrides()
return copyOverrides(UIOverrides)
end
function Window:ClearUIOverride(key,save)
key=tostring(key or"")
UIOverrides[key]=nil
if UI_DEFAULTS[key]~=nil then UISettings[key]=UI_DEFAULTS[key]end
restoreOverrideKey(key)
UISettings.Enabled=hasUIOverrides()
UISettings.Preset=UISettings.Enabled and"Custom"or"Default"
applyUITheme()
syncSettingsControls()
if save~=false then queueUISettingsSave()end
return true
end
function Window:SetUISettings(settings,save)
if type(settings)~="table"then return Window:GetUISettings()end
if settings.Preset=="Default"or settings.Enabled==false then
applyPreset("Default",save)
return Window:GetUISettings()
end
restoreOriginalUI()
for key,value in pairs(UI_DEFAULTS)do UISettings[key]=value end
UIOverrides={}
mergeUISettings(settings)
if type(settings.Overrides)=="table"then
UIOverrides=copyOverrides(settings.Overrides)
else
for key in pairs(settings)do
if UI_DEFAULTS[key]~=nil and key~="Enabled"and key~="Preset"then UIOverrides[key]=true end
end
end
UISettings.Preset=tostring(settings.Preset or"Custom")
UISettings.Enabled=hasUIOverrides()
applyUITheme()
syncSettingsControls()
if save~=false then queueUISettingsSave()end
return Window:GetUISettings()
end
function Window:ApplyUIPreset(name,save)
return applyPreset(name,save)
end
function Window:UseOriginalUI(save)
return applyPreset("Default",save)
end
function Window:GetUIPresets()
local names={}
for name in pairs(UI_PRESETS)do table.insert(names,name)end
table.sort(names)
table.insert(names,"Custom")
return names
end
function Window:SaveUISettings()
return storeUISettings(true)
end
function Window:ExportUISettings()
local ok,result=pcall(HttpService.JSONEncode,HttpService,serializeUISettings(UISettings))
return ok and result or nil
end
function Window:ImportUISettings(json,save)
if type(json)~="string"or json==""then return false,"Empty JSON"end
local ok,decoded=pcall(HttpService.JSONDecode,HttpService,json)
if not ok or type(decoded)~="table"then return false,tostring(decoded)end
local imported=decoded.UISettings or decoded
restoreOriginalUI()
for key,value in pairs(UI_DEFAULTS)do UISettings[key]=value end
UIOverrides={}
mergeUISettings(imported)
if type(imported.Overrides)=="table"then
UIOverrides=copyOverrides(imported.Overrides)
else
UIOverrides={}
for key in pairs(imported)do
if UI_DEFAULTS[key]~=nil and key~="Enabled"and key~="Preset"then UIOverrides[key]=true end
end
end
UISettings.Preset="Custom"
UISettings.Enabled=hasUIOverrides()
applyUITheme()
syncSettingsControls()
if save~=false then storeUISettings(true)end
return true
end
function Window:ResetUISettings(save)
restoreOriginalUI()
for key,value in pairs(UI_DEFAULTS)do UISettings[key]=value end
UIOverrides={}
UISettings.Enabled=false
UISettings.Preset="Default"
syncSettingsControls()
if save~=false then storeUISettings(true)end
return Window:GetUISettings()
end
function Window:GetUIProfileNames()
local names={}
for name,profile in pairs(CONFIG.__NgotUIProfiles)do
if type(name)=="string"and type(profile)=="table"then table.insert(names,name)end
end
table.sort(names)
return names
end
function Window:SaveUIProfile(name)
name=tostring(name or""):match("^%s*(.-)%s*$")
if name==""then return false,"Profile name is empty"end
CONFIG.__NgotUIProfiles[name]=serializeUISettings(UISettings)
return WRITECONFIG(true)
end
function Window:LoadUIProfile(name,save)
local profile=CONFIG.__NgotUIProfiles[tostring(name or"")]
if type(profile)~="table"then return false,"Profile not found"end
if profile.SettingsVersion~=3 then return false,"Legacy UI profile. Save it again with the current UI version."end
restoreOriginalUI()
for key,value in pairs(UI_DEFAULTS)do UISettings[key]=value end
UIOverrides={}
mergeUISettings(profile)
UIOverrides=type(profile.Overrides)=="table"and copyOverrides(profile.Overrides)or{}
UISettings.Preset=tostring(profile.Preset or(hasUIOverrides()and"Custom"or"Default"))
UISettings.Enabled=hasUIOverrides()
applyUITheme()
syncSettingsControls()
if save~=false then storeUISettings(true)end
return true
end
function Window:DeleteUIProfile(name)
name=tostring(name or"")
if CONFIG.__NgotUIProfiles[name]==nil then return false end
CONFIG.__NgotUIProfiles[name]=nil
return WRITECONFIG(true)
end
function Window:DeleteConfig()
if type(delfile)~="function"then return false,"delfile unavailable"end
local exists=true
if type(isfile)=="function"then
local ok,result=pcall(isfile,Window.ConfigPath)
exists=ok and result==true
end
if not exists then return true end
local ok,err=pcall(delfile,Window.ConfigPath)
return ok,err
end
local themeDescendantConnection=newWindow.DescendantAdded:Connect(function(descendant)
task.defer(function()
if UISettings.Enabled and not themeDestroyed and descendant and descendant.Parent then
applyThemeToObject(descendant)
end
end)
end)
local themeVisibilityConnection=newWindow:GetPropertyChangedSignal("Visible"):Connect(function()
if liquidBlur then
liquidBlur.Enabled=UISettings.Enabled and UIOverrides.BackgroundMode and UISettings.BackgroundMode=="Liquid Glass"and UIOverrides.Blur and UISettings.Blur>0 and newWindow.Visible
end
end)
applyUITheme()
local selected
local TabLists={}
local TabIndexList={}
local UserTabIndexList={}
local function AddTabToList(name:string,tab:ScrollingFrame,tabbtn:GuiButton,hasicon:boolean,isSystem:boolean)
local entry={
Name=name,
TabObject=tab,
TabButton=tabbtn,
HasIcon=hasicon,
System=isSystem==true,
}
TabLists[name]=entry
table.insert(TabIndexList,entry)
if not entry.System then
table.insert(UserTabIndexList,entry)
end
end
local SelectedDropdown=nil
local DropdownState=false
local dropdownTransition=0
local function DropdownPopup(state,name)
local opening=state==nil and not DropdownState or state==true
if opening and name then
local folder=newWindow.DropdownSelection.Dropdowns:FindFirstChild(name)
if not folder then return end
SelectedDropdown=name
for _,item in newWindow.DropdownSelection.Dropdowns:GetChildren()do
if item:IsA("Folder")then
item:FindFirstChild("DropdownItems").Visible=false
item:FindFirstChild("DropdownItemsSearch").Visible=false
end
end
newWindow.DropdownSelection.TopBar.Title.Text=name
folder:FindFirstChild("DropdownItems").Visible=true
folder:FindFirstChild("DropdownItemsSearch").Visible=false
end
dropdownTransition=dropdownTransition+1
local token=dropdownTransition
DropdownState=opening
if opening then
newWindow.DropdownSelection.Size=UDim2 .new(0.728,0,0.684,0)
newWindow.DarkOverlay.BackgroundTransparency=1
newWindow.DropdownSelection.Visible=true
newWindow.DarkOverlay.Visible=true
Tween(newWindow.DarkOverlay,{BackgroundTransparency=0.6},TweenConfigs.PopupOpen)
else
newWindow.DropdownSelection.Size=UDim2 .new(0,0,0,0)
local tw=Tween(newWindow.DarkOverlay,{BackgroundTransparency=1},TweenConfigs.PopupClose)
tw.Completed:Wait()
if token==dropdownTransition and not DropdownState then
newWindow.DropdownSelection.Visible=false
newWindow.DarkOverlay.Visible=false
end
end
end
local function SelectTab(tabName)
for tablistname,tab in pairs(TabLists)do
if tablistname~=tabName then
tab.TabObject.Visible=false
Tween(tab.TabButton.TextLabel,{Position=UDim2 .new(0,42,0.5,0),Size=UDim2 .new(0,103,0,16),TextTransparency=0.5},TweenConfigs.Global)
Tween(tab.TabButton.ImageButton,{Position=UDim2 .new(0,12,0,18),ImageTransparency=0.5},TweenConfigs.Global)
Tween(tab.TabButton.Bar,{Size=UDim2 .new(0,5,0,0),BackgroundTransparency=1},TweenConfigs.Global)
elseif tablistname==tabName then
selected=tabName
tab.TabObject.Visible=true
Tween(tab.TabButton.TextLabel,{Position=UDim2 .new(0,57,0.5,0),Size=UDim2 .new(0,88,0,16),TextTransparency=0},TweenConfigs.Global)
Tween(tab.TabButton.ImageButton,{Position=UDim2 .new(0,25,0,18),ImageTransparency=0},TweenConfigs.Global)
Tween(tab.TabButton.Bar,{Size=UDim2 .new(0,5,0,25),BackgroundTransparency=0},TweenConfigs.Global)
local objectCount=0
for _,obj in ipairs(tab.TabObject:GetChildren())do
if obj:IsA("GuiObject")then
objectCount=objectCount+1
end
end
if objectCount==0 then
SetEmptyTabNotice(true)
else
SetEmptyTabNotice(false)
end
end
end
end
newWindow.DropdownSelection.TopBar.Close.MouseButton1Click:Connect(function()DropdownPopup(false)end)
local textbox=newWindow.DropdownSelection.TopBar.BoxFrame.Frame.TextBox
textbox:GetPropertyChangedSignal("Text"):Connect(function()
if not Window.LiveSearchDropdown then return end
local currentFolder=newWindow.DropdownSelection.Dropdowns:FindFirstChild(SelectedDropdown)
if string.gsub(textbox.Text," ","")~=""then
if not currentFolder then return end
currentFolder:FindFirstChild("DropdownItems").Visible=false
currentFolder:FindFirstChild("DropdownItemsSearch").Visible=true
for _,button in currentFolder:FindFirstChild("DropdownItemsSearch"):GetChildren()do
if button:IsA("GuiButton")then
if string.find(button.Name:lower(),textbox.Text:lower(),1,true)then
button.Visible=true
else
button.Visible=false
end
end
end
else
currentFolder:FindFirstChild("DropdownItems").Visible=true
currentFolder:FindFirstChild("DropdownItemsSearch").Visible=false
end
end)
textbox.FocusLost:Connect(function()
if Window.LiveSearchDropdown then return end
local currentFolder=newWindow.DropdownSelection.Dropdowns:FindFirstChild(SelectedDropdown)
if string.gsub(textbox.Text," ","")~=""then
if not currentFolder then return end
currentFolder:FindFirstChild("DropdownItems").Visible=false
currentFolder:FindFirstChild("DropdownItemsSearch").Visible=true
for _,button in currentFolder:FindFirstChild("DropdownItemsSearch"):GetChildren()do
if button:IsA("GuiButton")then
if string.find(button.Name:lower(),textbox.Text:lower(),1,true)then
button.Visible=true
else
button.Visible=false
end
end
end
else
currentFolder:FindFirstChild("DropdownItems").Visible=true
currentFolder:FindFirstChild("DropdownItemsSearch").Visible=false
end
end)
function Window:Tab(data)
data=data or{}
local Tab={}
local TabData={
Title=data.Title or("Tab "..tostring(#UserTabIndexList+1)),
Icon=data.Icon or"circle",
System=data.__System==true,
}
local NAMETAB=TabData.Title
if type(CONFIG[NAMETAB])~="table"then
CONFIG[NAMETAB]={}
end
local newTabButton=Templates.TabButton:Clone()
newTabButton.Name=TabData.Title
newTabButton.Parent=newWindow.TabButtons.Lists
newTabButton.Visible=true
newTabButton.TextLabel.Text=TabData.Title
ApplyIcon(newTabButton.ImageButton,TabData.Icon)
local newTab=Templates.Tab:Clone()
newTab.Name=TabData.Title
newTab.Parent=newWindow.Tabs
newTab.Visible=false
AddTabToList(TabData.Title,newTab,newTabButton,true,TabData.System)
newTabButton.LayoutOrder=TabData.System and 100000 or(#UserTabIndexList*10)
if selected==TabData.Title then
newTab.Visible=true
newTabButton.TextLabel.Position=UDim2 .new(0,57,0.5,0)
newTabButton.TextLabel.Size=UDim2 .new(0,88,0,16)
newTabButton.TextLabel.TextTransparency=0
newTabButton.ImageButton.Position=UDim2 .new(0,25,0,18)
newTabButton.ImageButton.ImageTransparency=0
newTabButton.Bar.Size=UDim2 .new(0,5,0,25)
newTabButton.Bar.BackgroundTransparency=0
else
newTabButton.TextLabel.Position=UDim2 .new(0,42,0.5,0)
newTabButton.TextLabel.Size=UDim2 .new(0,103,0,16)
newTabButton.TextLabel.TextTransparency=0.5
newTabButton.ImageButton.Position=UDim2 .new(0,12,0,18)
newTabButton.ImageButton.ImageTransparency=0.5
newTabButton.Bar.Size=UDim2 .new(0,5,0,0)
newTabButton.Bar.BackgroundTransparency=1
end
BindSafeActivate(newTabButton,function()
SelectTab(TabData.Title)
end)
local function GetCurrentElementObjects()
local objects={}
for _,v in pairs(newTab:GetChildren())do
if v:IsA("GuiObject")then
table.insert(objects,v)
end
end
return objects
end
local parentElement=newTab
Tab._Container=newTab
function Tab:_Use(methodName,elementData,targetParent)
local method=Tab[methodName]
if type(method)~="function"then
error("Unknown NgotStudio tab method: "..tostring(methodName),2)
end
local previousParent=parentElement
parentElement=targetParent or newTab
local ok,result=pcall(method,Tab,elementData)
parentElement=previousParent
if not ok then error(result,2)end
return result
end
function Tab:Section(data)
data=data or{}
local Section={
Title=data.Title or"Section",
State=data.Default or false,
TextXAlignment=Enum.TextXAlignment[data.TextXAlignment or"Left"]and(data.TextXAlignment or"Left")or"Left",
}
local newSection=Templates.Section:Clone()
newSection.Name=Section.Title
newSection.Button.Title.Text=Section.Title
newSection.Button.Title.TextXAlignment=Enum.TextXAlignment[Section.TextXAlignment]or Enum.TextXAlignment.Left
newSection.Visible=true
newSection.Parent=newTab
newSection.Frame.Visible=Section.State
newSection.Button.Title.Arrow.Rotation=Section.State and 90 or 0
BindSafeActivate(newSection.Button,function()
if Section.State==true then
newSection.Frame.Visible=false
Tween(newSection.Button.Title.Arrow,{Rotation=0},TweenConfigs.Global)
Section.State=false
elseif Section.State==false then
newSection.Frame.Visible=true
Tween(newSection.Button.Title.Arrow,{Rotation=90},TweenConfigs.Global)
Section.State=true
end
end)
function Section:SetTitle(newTitle)
Section.Title=tostring(newTitle or"Section")
newSection.Name=Section.Title
newSection.Button.Title.Text=Section.Title
end
function Section:SetOpen(state)
Section.State=state==true
newSection.Frame.Visible=Section.State
Tween(newSection.Button.Title.Arrow,{Rotation=Section.State and 90 or 0},TweenConfigs.Global)
return Section.State
end
function Section:Toggle()
return Section:SetOpen(not Section.State)
end
function Section:Destroy()
if parentElement==newSection.Frame then
parentElement=newTab
end
newSection:Destroy()
end
Section._Container=newSection.Frame
Section._Tab=Tab
function Section:_Use(methodName,elementData)
return Tab:_Use(methodName,elementData,newSection.Frame)
end
parentElement=newSection.Frame
return Section
end
function Tab:Button(data)
data=data or{}
local Button={}
local ButtonData={
Title=data.Title or"Button",
Desc=data.Desc,
Locked=data.Locked or false,
Callback=type(data.Callback)=="function"and data.Callback or function()end
}
local newButton=Templates.Button:Clone()
newButton.Name=ButtonData.Title
newButton.Parent=parentElement
newButton.Frame.Title.Text=ButtonData.Title
if ButtonData.Desc and ButtonData.Desc~=""then
newButton.Frame.Description.Visible=true
newButton.Frame.Description.Text=ButtonData.Desc
end
if ButtonData.Locked then
newButton.UIStroke.Color=Color3 .fromRGB(47,47,58)
newButton.BackgroundColor3=Color3 .fromRGB(32,35,40)
newButton.Frame.Title.TextColor3=Color3 .fromRGB(75,77,83)
newButton.Frame.Title.ClickIcon.ImageColor3=Color3 .fromRGB(75,77,83)
newButton.Frame.Description.TextColor3=Color3 .fromRGB(75,77,83)
end
newButton.Visible=true
local function GetRandomGradient()
local gradient={}
for _,g in ipairs(newButton.Frame:GetChildren())do
if g:IsA("UIGradient")then
g.Enabled=false
table.insert(gradient,g)
end
end
local selectedGrad=gradient[math.random(1,#gradient)]
selectedGrad.Enabled=true
return selectedGrad
end
GetRandomGradient()
local function resetButtonPress()
if ButtonData.Locked or not newButton.Parent then return end
Tween(newButton.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(newButton.Frame.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newButton.Frame.Title.ClickIcon,{ImageColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newButton.Frame.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newButton.Frame,{BackgroundTransparency=1},TweenConfigs.Global)
end
newButton.MouseEnter:Connect(function()
if not ButtonData.Locked and not isTouchInput()then Tween(newButton.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)end
end)
BindPressFeedback(newButton,function()
if ButtonData.Locked then return end
GetRandomGradient()
Tween(newButton.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)
Tween(newButton.Frame.Title,{TextColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(newButton.Frame.Title.ClickIcon,{ImageColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(newButton.Frame.Description,{TextColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(newButton.Frame,{BackgroundTransparency=0},TweenConfigs.Global)
end,resetButtonPress)
BindSafeActivate(newButton,function()
resetButtonPress()
if not ButtonData.Locked then ButtonData.Callback()end
end)
newTab.ChildAdded:Connect(function()
if#GetCurrentElementObjects()>0 then
SetEmptyTabNotice(false)
else
SetEmptyTabNotice(true)
end
end)
newTab.ChildRemoved:Connect(function()
if#GetCurrentElementObjects()>0 then
SetEmptyTabNotice(false)
else
SetEmptyTabNotice(true)
end
end)
function Button:SetTitle(newText)
ButtonData.Title=tostring(newText or"Button")
newButton.Name=ButtonData.Title
newButton.Frame.Title.Text=ButtonData.Title
end
function Button:SetDesc(newDesc)
ButtonData.Desc=tostring(newDesc or"")
newButton.Frame.Description.Text=ButtonData.Desc
newButton.Frame.Description.Visible=ButtonData.Desc~=""
end
function Button:Lock()
resetButtonPress()
ButtonData.Locked=true
Tween(newButton,{BackgroundColor3=Color3 .fromRGB(32,35,40)},TweenConfigs.Global)
Tween(newButton.UIStroke,{Color=Color3 .fromRGB(47,47,58)},TweenConfigs.Global)
Tween(newButton.Frame.Title,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newButton.Frame.Title.ClickIcon,{ImageColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newButton.Frame.Description,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
end
function Button:Unlock()
ButtonData.Locked=false
Tween(newButton,{BackgroundColor3=Color3 .fromRGB(42,45,52)},TweenConfigs.Global)
Tween(newButton.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(newButton.Frame.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newButton.Frame.Title.ClickIcon,{ImageColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newButton.Frame.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
end
function Button:Destroy()
newButton:Destroy()
end
return Button
end
function Tab:Code(data)
data=data or{}
local Code={
Title=data.Title or"Code",
Code=data.Code or""
}
local newCode=Templates.Code:Clone()
newCode.Name=Code.Title
newCode.Parent=parentElement
newCode.Title.Text=Code.Title
newCode.Code.Text=Code.Code
newCode.Code.Visible=true
newCode.Code.Font=Enum.Font.Code
newCode.Visible=true
function Code:SetTitle(newText)
Code.Title=tostring(newText or"Code")
newCode.Name=Code.Title
newCode.Title.Text=Code.Title
end
function Code:SetCode(code)
Code.Code=tostring(code or"")
newCode.Code.Text=Code.Code
end
function Code:Destroy()
newCode:Destroy()
end
return Code
end
function Tab:Paragraph(data)
data=data or{}
local Paragraph={
Title=data.Title or"Paragraph",
Desc=data.Desc,
RichText=data.RichText or false,
}
local newParagraph=Templates.Paragraph:Clone()
newParagraph.Name=Paragraph.Title
newParagraph.Parent=parentElement
newParagraph.Title.Text=Paragraph.Title
if Paragraph.Desc and Paragraph.Desc~=""then
newParagraph.Description.Text=Paragraph.Desc
newParagraph.Description.Visible=true
else
newParagraph.Description.Visible=false
end
newParagraph.Title.RichText=Paragraph.RichText
newParagraph.Description.RichText=Paragraph.RichText
newParagraph.Visible=true
function Paragraph:SetTitle(title)
Paragraph.Title=tostring(title or"Paragraph")
newParagraph.Name=Paragraph.Title
newParagraph.Title.Text=Paragraph.Title
end
function Paragraph:SetDesc(desc)
Paragraph.Desc=desc or""
newParagraph.Description.Text=Paragraph.Desc
newParagraph.Description.Visible=Paragraph.Desc~=""
end
function Paragraph:Destroy()
newParagraph:Destroy()
end
return Paragraph
end
function Tab:Colorpicker(data)
data=data or{}
local Colorpicker={
Title=data.Title or"Color",
Desc=data.Desc or"",
Locked=data.Locked==true,
Callback=type(data.Callback)=="function"and data.Callback or function()end,
}
local function ToColor3(value)
if typeof(value)=="Color3"then return value end
if type(value)=="table"then
local r=value.R or value.r or value[1]or 255
local g=value.G or value.g or value[2]or 255
local b=value.B or value.b or value[3]or 255
if r<=1 and g<=1 and b<=1 then
return Color3 .new(math.clamp(r,0,1),math.clamp(g,0,1),math.clamp(b,0,1))
end
return Color3 .fromRGB(math.clamp(r,0,255),math.clamp(g,0,255),math.clamp(b,0,255))
end
if type(value)=="string"then
local hex=value:gsub("#","")
if#hex==6 then
local r=tonumber(hex:sub(1,2),16)
local g=tonumber(hex:sub(3,4),16)
local b=tonumber(hex:sub(5,6),16)
if r and g and b then return Color3 .fromRGB(r,g,b)end
end
end
return Color3 .fromRGB(255,255,255)
end
local defaultValue=data.Default
if defaultValue==nil then defaultValue=data.Value end
local name=Colorpicker.Title
Colorpicker.Value=ToColor3(defaultValue)
if CONFIGLOADED and type(CONFIG[NAMETAB][name])=="table"then
Colorpicker.Value=ToColor3(CONFIG[NAMETAB][name])
end
local root=Instance.new("Frame")
root.Name=Colorpicker.Title
root.BackgroundColor3=Color3 .fromRGB(43,46,53)
root.BorderSizePixel=0
root.Size=UDim2 .new(1,0,0,54)
root.AutomaticSize=Enum.AutomaticSize.Y
root.Parent=parentElement
Instance.new("UICorner",root).CornerRadius=UDim.new(0,6)
local rootStroke=Instance.new("UIStroke",root)
rootStroke.Color=Color3 .fromRGB(61,61,75)
rootStroke.Thickness=1.5
local rootLayout=Instance.new("UIListLayout",root)
rootLayout.SortOrder=Enum.SortOrder.LayoutOrder
rootLayout.Padding=UDim.new(0,6)
local rootPad=Instance.new("UIPadding",root)
rootPad.PaddingTop=UDim.new(0,10)
rootPad.PaddingBottom=UDim.new(0,10)
rootPad.PaddingLeft=UDim.new(0,10)
rootPad.PaddingRight=UDim.new(0,10)
local header=Instance.new("Frame",root)
header.BackgroundTransparency=1
header.Size=UDim2 .new(1,0,0,Colorpicker.Desc~=""and 38 or 24)
header.LayoutOrder=1
local title=Instance.new("TextLabel",header)
title.BackgroundTransparency=1
title.Text=Colorpicker.Title
title.TextColor3=UISettings.TextColor
title.TextSize=16
title.FontFace=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
title.TextXAlignment=Enum.TextXAlignment.Left
title.Size=UDim2 .new(1,-52,0,18)
local desc=Instance.new("TextLabel",header)
desc.BackgroundTransparency=1
desc.Text=Colorpicker.Desc
desc.TextColor3=UISettings.MutedTextColor
desc.TextSize=12
desc.FontFace=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal)
desc.TextXAlignment=Enum.TextXAlignment.Left
desc.Position=UDim2 .fromOffset(0,21)
desc.Size=UDim2 .new(1,-52,0,15)
desc.Visible=Colorpicker.Desc~=""
local preview=Instance.new("TextButton",header)
preview.Name="NgotStudioColorPreview"
preview.Text=""
preview.AutoButtonColor=false
preview.AnchorPoint=Vector2 .new(1,0.5)
preview.Position=UDim2 .new(1,0,0.5,0)
preview.Size=UDim2 .fromOffset(40,28)
preview.BackgroundColor3=Colorpicker.Value
Instance.new("UICorner",preview).CornerRadius=UDim.new(0,6)
local previewStroke=Instance.new("UIStroke",preview)
previewStroke.Color=Color3 .fromRGB(95,95,117)
local panel=Instance.new("Frame",root)
panel.BackgroundTransparency=1
panel.Size=UDim2 .new(1,0,0,32)
panel.LayoutOrder=2
panel.Visible=false
local panelLayout=Instance.new("UIListLayout",panel)
panelLayout.FillDirection=Enum.FillDirection.Horizontal
panelLayout.Padding=UDim.new(0,6)
panelLayout.VerticalAlignment=Enum.VerticalAlignment.Center
local boxes={}
local function CreateBox(channel)
local holder=Instance.new("Frame",panel)
holder.Name=channel
holder.BackgroundColor3=Color3 .fromRGB(32,35,41)
holder.Size=UDim2 .new(1/3,-4,1,0)
Instance.new("UICorner",holder).CornerRadius=UDim.new(0,5)
local stroke=Instance.new("UIStroke",holder)
stroke.Color=Color3 .fromRGB(61,61,75)
local label=Instance.new("TextLabel",holder)
label.BackgroundTransparency=1
label.Text=channel
label.TextColor3=UISettings.MutedTextColor
label.TextSize=12
label.Size=UDim2 .fromOffset(20,32)
local box=Instance.new("TextBox",holder)
box.BackgroundTransparency=1
box.TextColor3=UISettings.TextColor
box.TextSize=13
box.ClearTextOnFocus=false
box.TextXAlignment=Enum.TextXAlignment.Left
box.Position=UDim2 .fromOffset(22,0)
box.Size=UDim2 .new(1,-24,1,0)
boxes[channel]=box
end
CreateBox("R")
CreateBox("G")
CreateBox("B")
local function ToRGB(color)
return math.round(color.R*255),math.round(color.G*255),math.round(color.B*255)
end
local function Render(color)
local r,g,b=ToRGB(color)
preview.BackgroundColor3=color
boxes.R.Text,boxes.G.Text,boxes.B.Text=tostring(r),tostring(g),tostring(b)
end
local function SaveColor(color)
local r,g,b=ToRGB(color)
CONFIG[NAMETAB][name]={R=r,G=g,B=b}
SAVECONFIG()
end
local function SetColor(value,fireCallback)
local color=ToColor3(value)
Colorpicker.Value=color
Render(color)
SaveColor(color)
if fireCallback~=false then Colorpicker.Callback(color)end
return color
end
local function ApplyBoxes()
if Colorpicker.Locked then return end
local r=math.clamp(tonumber(boxes.R.Text)or 0,0,255)
local g=math.clamp(tonumber(boxes.G.Text)or 0,0,255)
local b=math.clamp(tonumber(boxes.B.Text)or 0,0,255)
SetColor(Color3 .fromRGB(r,g,b),true)
end
for _,box in pairs(boxes)do box.FocusLost:Connect(ApplyBoxes)end
preview.MouseButton1Click:Connect(function()
if not Colorpicker.Locked then panel.Visible=not panel.Visible end
end)
function Colorpicker:Set(value)return SetColor(value,true)end
function Colorpicker:Get()return Colorpicker.Value end
function Colorpicker:SetTitle(text)
Colorpicker.Title=tostring(text or"Color")
title.Text=Colorpicker.Title
root.Name=Colorpicker.Title
end
function Colorpicker:SetDesc(text)
Colorpicker.Desc=tostring(text or"")
desc.Text=Colorpicker.Desc
desc.Visible=Colorpicker.Desc~=""
header.Size=UDim2 .new(1,0,0,desc.Visible and 38 or 24)
end
function Colorpicker:Lock()
Colorpicker.Locked=true
panel.Visible=false
rootStroke.Color=Color3 .fromRGB(47,47,58)
root.BackgroundColor3=Color3 .fromRGB(32,35,40)
title.TextColor3=Color3 .fromRGB(75,77,83)
preview.Active=false
end
function Colorpicker:Unlock()
Colorpicker.Locked=false
rootStroke.Color=Color3 .fromRGB(61,61,75)
root.BackgroundColor3=Color3 .fromRGB(43,46,53)
title.TextColor3=UISettings.TextColor
preview.Active=true
end
function Colorpicker:Destroy()root:Destroy()end
Render(Colorpicker.Value)
SaveColor(Colorpicker.Value)
if Colorpicker.Locked then Colorpicker:Lock()end
Colorpicker.Callback(Colorpicker.Value)
return Colorpicker
end
function Tab:Toggle(data)
data=data or{}
local Toggle={
Title=data.Title or"Toggle",
Desc=data.Desc,
State=data.Default~=nil and data.Default or(data.Value~=nil and data.Value or false),
Locked=data.Locked or false,
Icon=data.Icon,
Callback=type(data.Callback)=="function"and data.Callback or function()end
}
local name=Toggle.Title
if CONFIGLOADED and CONFIG[NAMETAB][name]~=nil then
Toggle.State=CONFIG[NAMETAB][name]
elseif not CONFIGLOADED or CONFIG[NAMETAB][name]==nil then
CONFIG[NAMETAB][name]=Toggle.State
end
local newToggle=Templates.Toggle:Clone()
newToggle.Name=Toggle.Title
newToggle.Parent=parentElement
newToggle.Title.Text=Toggle.Title
if Toggle.Icon then ApplyIcon(newToggle.Title.Fill.Ball.Icon,Toggle.Icon)end
if Toggle.Desc and Toggle.Desc~=""then
newToggle.Description.Visible=true
newToggle.Description.Text=Toggle.Desc
end
if Toggle.State==true then
newToggle.Title.Fill.Ball.Position=UDim2 .new(0.5,0,0.5,0)
newToggle.Title.Fill.BackgroundColor3=UISettings.AccentColor
newToggle.Title.Fill.Ball.Icon.ImageTransparency=0
else
newToggle.Title.Fill.Ball.Position=UDim2 .new(0,0,0.5,0)
newToggle.Title.Fill.BackgroundColor3=Color3 .fromRGB(53,56,62)
newToggle.Title.Fill.Ball.Icon.ImageTransparency=1
end
if Toggle.Locked then
newToggle.UIStroke.Color=Color3 .fromRGB(47,47,58)
newToggle.BackgroundColor3=Color3 .fromRGB(32,35,40)
newToggle.Title.TextColor3=Color3 .fromRGB(75,77,83)
newToggle.Description.TextColor3=Color3 .fromRGB(75,77,83)
newToggle.Title.Fill.BackgroundTransparency=0.7
newToggle.Title.Fill.Ball.BackgroundTransparency=0.7
end
newToggle.Visible=true
newToggle.Title.Fill.MouseEnter:Connect(function()
if not Toggle.Locked and not isTouchInput()then
Tween(newToggle.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)
end
end)
newToggle.Title.Fill.MouseLeave:Connect(function()
if not Toggle.Locked then
Tween(newToggle.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
newToggle.BackgroundColor3=Color3 .fromRGB(42,45,52)
Tween(newToggle.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newToggle.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
end
end)
local function AnimateSwitch(targetState)
if targetState==true then
Tween(newToggle.Title.Fill.Ball,{Position=UDim2 .new(0.5,0,0.5,0)},TweenConfigs.Global)
Tween(newToggle.Title.Fill,{BackgroundColor3=UISettings.AccentColor},TweenConfigs.Global)
Tween(newToggle.Title.Fill.Ball.Icon,{ImageTransparency=0},TweenConfigs.Global)
elseif targetState==false then
Tween(newToggle.Title.Fill.Ball,{Position=UDim2 .new(0,0,0.5,0)},TweenConfigs.Global)
Tween(newToggle.Title.Fill,{BackgroundColor3=Color3 .fromRGB(53,56,62)},TweenConfigs.Global)
Tween(newToggle.Title.Fill.Ball.Icon,{ImageTransparency=1},TweenConfigs.Global)
end
end
local function SetState(newState)
if newState==nil then
newState=not Toggle.State
else
newState=newState==true
end
AnimateSwitch(newState)
Toggle.State=newState
Toggle.Callback(Toggle.State)
CONFIG[NAMETAB][name]=Toggle.State
SAVECONFIG()
end
local toggleHit=newToggle.Title.Fill
if UIS.TouchEnabled then
toggleHit=Instance.new("TextButton")
toggleHit.Name="TouchTarget"
toggleHit.BackgroundTransparency=1
toggleHit.Text=""
toggleHit.AutoButtonColor=false
toggleHit.AnchorPoint=Vector2 .new(1,0.5)
toggleHit.Position=UDim2 .new(1,0,0.5,0)
toggleHit.Size=UDim2 .fromOffset(56,44)
toggleHit.ZIndex=newToggle.Title.Fill.ZIndex+2
toggleHit.Parent=newToggle.Title
newToggle.Title.Fill.Active=false
pcall(function()newToggle.Title.Fill.Interactable=false end)
end
BindPressFeedback(toggleHit,function()
if not Toggle.Locked then Tween(newToggle.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)end
end,function()
if not Toggle.Locked and newToggle.Parent then Tween(newToggle.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)end
end)
BindSafeActivate(toggleHit,function()
if not Toggle.Locked then
SetState()
end
end)
function Toggle:SetTitle(newText)
Toggle.Title=tostring(newText or"Toggle")
newToggle.Name=Toggle.Title
newToggle.Title.Text=Toggle.Title
end
function Toggle:SetDesc(newDesc)
Toggle.Desc=tostring(newDesc or"")
newToggle.Description.Text=Toggle.Desc
newToggle.Description.Visible=Toggle.Desc~=""
end
function Toggle:Set(newState)
SetState(newState)
end
function Toggle:Lock()
Toggle.Locked=true
Tween(newToggle,{BackgroundColor3=Color3 .fromRGB(32,35,40)},TweenConfigs.Global)
Tween(newToggle.UIStroke,{Color=Color3 .fromRGB(47,47,58)},TweenConfigs.Global)
Tween(newToggle.Title,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newToggle.Description,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newToggle.Title.Fill,{BackgroundTransparency=0.7},TweenConfigs.Global)
Tween(newToggle.Title.Fill.Ball,{BackgroundTransparency=0.7},TweenConfigs.Global)
end
function Toggle:Unlock()
Toggle.Locked=false
Tween(newToggle,{BackgroundColor3=Color3 .fromRGB(42,45,52)},TweenConfigs.Global)
Tween(newToggle.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(newToggle.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newToggle.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newToggle.Title.Fill,{BackgroundTransparency=0},TweenConfigs.Global)
Tween(newToggle.Title.Fill.Ball,{BackgroundTransparency=0},TweenConfigs.Global)
end
function Toggle:Destroy()
newToggle:Destroy()
end
Toggle.Callback(Toggle.State)
return Toggle
end
function Tab:Slider(data)
data=data or{}
data.Value=data.Value or{}
local Slider={
Title=data.Title or"Slider",
Desc=data.Desc,
Step=data.Step or 1,
Value={
Min=data.Value.Min or 0,
Max=data.Value.Max or 100,
Default=nil,
},
Locked=data.Locked,
Callback=type(data.Callback)=="function"and data.Callback or function()end
}
Slider.Value.Default=data.Value.Default~=nil and data.Value.Default or(data.Default~=nil and data.Default or Slider.Value.Min)
local increment=tonumber(Slider.Step)or 1
if increment<=0 then increment=1 end
local name=Slider.Title
if CONFIGLOADED and CONFIG[NAMETAB][name]~=nil then
Slider.Value.Default=tonumber(CONFIG[NAMETAB][name])or Slider.Value.Default
elseif not CONFIGLOADED or CONFIG[NAMETAB][name]==nil then
CONFIG[NAMETAB][name]=Slider.Value.Default
end
Slider.Value.Min=tonumber(Slider.Value.Min)or 0
Slider.Value.Max=tonumber(Slider.Value.Max)or 100
if Slider.Value.Max<Slider.Value.Min then
Slider.Value.Min,Slider.Value.Max=Slider.Value.Max,Slider.Value.Min
end
Slider.Value.Default=math.clamp(tonumber(Slider.Value.Default)or Slider.Value.Min,Slider.Value.Min,Slider.Value.Max)
local newSlider=Templates.Slider:Clone()
newSlider.Parent=parentElement
newSlider.Name=Slider.Title
newSlider.Title.Text=Slider.Title
if Slider.Desc and Slider.Desc~=""then
newSlider.Description.Visible=true
newSlider.Description.Text=Slider.Desc
end
newSlider.Visible=true
local function GetRandomGradient()
local gradient={}
for _,g in ipairs(newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient:GetChildren())do
if g:IsA("UIGradient")then
g.Enabled=false
table.insert(gradient,g)
end
end
local selectedGrad=gradient[math.random(1,#gradient)]
selectedGrad.Enabled=true
return selectedGrad
end
newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient.Size=UDim2 .new(0,newSlider.SliderFrame.Frame.Slider.AbsoluteSize.X,1,0)
newSlider.SliderFrame.Frame.Slider:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient.Size=UDim2 .new(0,newSlider.SliderFrame.Frame.Slider.AbsoluteSize.X,1,0)
end)
local lastprop=nil
newSlider.SliderFrame.Frame.Slider.Fill:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
if newSlider.SliderFrame.Frame.Slider.Fill.AbsoluteSize.X<=3 then
lastprop=newSlider.SliderFrame.Frame.Slider.Fill.AbsoluteSize.X
end
if lastprop and newSlider.SliderFrame.Frame.Slider.Fill.AbsoluteSize.X>lastprop then
GetRandomGradient()
lastprop=nil
end
end)
GetRandomGradient()
if Slider.Locked then
newSlider.UIStroke.Color=Color3 .fromRGB(47,47,58)
newSlider.BackgroundColor3=Color3 .fromRGB(32,35,40)
newSlider.Title.TextColor3=Color3 .fromRGB(75,77,83)
newSlider.Description.TextColor3=Color3 .fromRGB(75,77,83)
newSlider.SliderFrame.Frame.Slider.UIStroke.Color=Color3 .fromRGB(47,47,58)
newSlider.SliderFrame.Frame.Slider.BackgroundTransparency=0.5
newSlider.SliderFrame.Frame.Slider.Fill.UIStroke.Transparency=0.5
newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient.BackgroundTransparency=0.5
newSlider.SliderFrame.Frame.ValueText.TextTransparency=0.6
end
local Trigger=newSlider.SliderFrame.Frame.Slider.Trigger
local Label=newSlider.SliderFrame.Frame.ValueText
local Fill=newSlider.SliderFrame.Frame.Slider.Fill
local default=Slider.Value.Default
local min=Slider.Value.Min
local max=Slider.Value.Max
local increment=increment or 1
local perc=Slider.Value.Default
local Percent
local MouseDown=false
local Hovering=false
local function convertValueToScale(value)
if max==min then return 0 end
return math.clamp((value-min)/(max-min),0,1)
end
Label.Text=tostring(default)or tostring(min)
Fill.Size=UDim2 .fromScale(convertValueToScale(default),1)
local activeInput,dragMode,startX,startY=nil,nil,0,0
local inputChangedConnection,inputEndedConnection,focusLostConnection
local sliderDisposed=false
local function applyPosition(x)
if Slider.Locked or sliderDisposed then return end
local bar=newSlider.SliderFrame.Frame.Slider
local width=math.max(bar.AbsoluteSize.X,1)
Percent=math.clamp((x-bar.AbsolutePosition.X)/width,0,1)
local value=math.clamp(math.round((min+Percent*(max-min))/increment)*increment,min,max)
if value==perc then return end
perc=value
Tween(Fill,{Size=UDim2 .fromScale(convertValueToScale(value),1)},TweenConfigs.Global)
Label.Text=tostring(value)
Slider.Value=value
CONFIG[NAMETAB][name]=value
task.spawn(Slider.Callback,value)
end
local function finishDrag(save)
local wasDragging=MouseDown
MouseDown,activeInput,dragMode=false,nil,nil
Hovering=false
if not Slider.Locked and newSlider.Parent then Tween(newSlider.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)end
if wasDragging and save and not sliderDisposed then SAVECONFIG()end
end
local function Update(value)
value=tonumber(value)
if value==nil or value>max or value<min then
return nil
end
local roundedValue=math.round(value/increment)*increment
perc=math.clamp(roundedValue,min,max)
Tween(Fill,{Size=UDim2 .fromScale(convertValueToScale(perc),1)},TweenConfigs.Global)
Label.Text=tostring(perc)
Slider.Value=perc
task.spawn(Slider.Callback,perc)
CONFIG[NAMETAB][name]=perc
SAVECONFIG()
return perc
end
Trigger.MouseEnter:Connect(function()
if isTouchInput()then return end
Hovering=true
if not Slider.Locked then Tween(newSlider.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)end
end)
Trigger.MouseLeave:Connect(function()
Hovering=false
if not Slider.Locked and not MouseDown then Tween(newSlider.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)end
end)
Trigger.InputBegan:Connect(function(input)
if Slider.Locked or activeInput then return end
local kind=input.UserInputType
if kind~=Enum.UserInputType.Touch and kind~=Enum.UserInputType.MouseButton1 then return end
activeInput,MouseDown=input,true
startX,startY=input.Position.X,input.Position.Y
dragMode=kind==Enum.UserInputType.Touch and"pending"or"mouse"
Tween(newSlider.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)
if dragMode=="mouse"then applyPosition(startX)end
end)
inputChangedConnection=UIS.InputChanged:Connect(function(input)
if not activeInput or Slider.Locked then return end
if activeInput.UserInputType==Enum.UserInputType.Touch then
if input~=activeInput then return end
local dx,dy=input.Position.X-startX,input.Position.Y-startY
if dragMode=="pending"and(math.abs(dx)>8 or math.abs(dy)>8)then
dragMode=math.abs(dx)>math.abs(dy)and"horizontal"or"scroll"
end
if dragMode=="horizontal"then applyPosition(input.Position.X)end
elseif input.UserInputType==Enum.UserInputType.MouseMovement then
applyPosition(input.Position.X)
end
end)
inputEndedConnection=UIS.InputEnded:Connect(function(input)
if not activeInput then return end
local isTouch=activeInput.UserInputType==Enum.UserInputType.Touch
if(isTouch and input~=activeInput)or(not isTouch and input.UserInputType~=Enum.UserInputType.MouseButton1)then return end
if isTouch and dragMode=="pending"and input.UserInputState~=Enum.UserInputState.Cancel then
local dx,dy=input.Position.X-startX,input.Position.Y-startY
if dx*dx+dy*dy<=144 then applyPosition(input.Position.X)end
end
finishDrag(dragMode~="scroll")
end)
focusLostConnection=UIS.WindowFocusReleased:Connect(function()finishDrag(false)end)
local function disposeSlider()
if sliderDisposed then return end
sliderDisposed=true
finishDrag(false)
if inputChangedConnection then inputChangedConnection:Disconnect()end
if inputEndedConnection then inputEndedConnection:Disconnect()end
if focusLostConnection then focusLostConnection:Disconnect()end
end
newSlider.Destroying:Connect(disposeSlider)
function Slider:SetTitle(newText)
Slider.Title=tostring(newText or"Slider")
newSlider.Title.Text=Slider.Title
newSlider.Name=Slider.Title
end
function Slider:SetDesc(newDesc)
Slider.Desc=tostring(newDesc or"")
newSlider.Description.Text=Slider.Desc
newSlider.Description.Visible=Slider.Desc~=""
end
function Slider:Set(value)
return Update(value)
end
function Slider:Lock()
Slider.Locked=true
finishDrag(false)
Tween(newSlider,{BackgroundColor3=Color3 .fromRGB(32,35,40)},TweenConfigs.Global)
Tween(newSlider.UIStroke,{Color=Color3 .fromRGB(47,47,58)},TweenConfigs.Global)
Tween(newSlider.Title,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newSlider.Description,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newSlider.SliderFrame.Frame.Slider.UIStroke,{Color=Color3 .fromRGB(47,47,58)},TweenConfigs.Global)
Tween(newSlider.SliderFrame.Frame.Slider,{BackgroundTransparency=0.5},TweenConfigs.Global)
Tween(newSlider.SliderFrame.Frame.Slider.Fill.UIStroke,{Transparency=0.5},TweenConfigs.Global)
Tween(newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient,{BackgroundTransparency=0.5},TweenConfigs.Global)
Tween(newSlider.SliderFrame.Frame.ValueText,{TextTransparency=0.6},TweenConfigs.Global)
end
function Slider:Unlock()
Slider.Locked=false
Tween(newSlider,{BackgroundColor3=Color3 .fromRGB(42,45,52)},TweenConfigs.Global)
Tween(newSlider.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(newSlider.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newSlider.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newSlider.SliderFrame.Frame.Slider.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(newSlider.SliderFrame.Frame.Slider,{BackgroundTransparency=0},TweenConfigs.Global)
Tween(newSlider.SliderFrame.Frame.Slider.Fill.UIStroke,{Transparency=0},TweenConfigs.Global)
Tween(newSlider.SliderFrame.Frame.Slider.Fill.BackgroundGradient,{BackgroundTransparency=0},TweenConfigs.Global)
Tween(newSlider.SliderFrame.Frame.ValueText,{TextTransparency=0},TweenConfigs.Global)
end
function Slider:Destroy()
disposeSlider()
newSlider:Destroy()
end
Slider.Callback(default)
return Slider
end
function Tab:Input(data)
data=data or{}
local Input={
Title=data.Title or"Input",
Desc=data.Desc,
Placeholder=data.Placeholder or"",
Default=data.Default or data.Value or"",
Text=data.Default or data.Value or"",
ClearTextOnFocus=data.ClearTextOnFocus or false,
Locked=data.Locked or false,
MultiLine=data.MultiLine or false,
Callback=type(data.Callback)=="function"and data.Callback or function()end
}
local name=Input.Title
if CONFIGLOADED and CONFIG[NAMETAB][name]~=nil then
Input.Default=CONFIG[NAMETAB][name]
elseif not CONFIGLOADED or CONFIG[NAMETAB][name]==nil then
CONFIG[NAMETAB][name]=Input.Default
end
Input.Text=tostring(Input.Default or"")
Input.Default=Input.Text
local newInput=Templates.TextBox:Clone()
newInput.Name=Input.Title
newInput.Parent=parentElement
newInput.Title.Text=Input.Title
if Input.Desc and Input.Desc~=""then
newInput.Description.Text=Input.Desc
newInput.Description.Visible=true
else
newInput.Description.Visible=false
end
if Input.Locked then
newInput.UIStroke.Color=Color3 .fromRGB(47,47,58)
newInput.BackgroundColor3=Color3 .fromRGB(32,35,40)
newInput.Title.TextColor3=Color3 .fromRGB(75,77,83)
newInput.Description.TextColor3=Color3 .fromRGB(75,77,83)
newInput.BoxFrame.Frame.BackgroundColor3=Color3 .fromRGB(32,35,40)
newInput.BoxFrame.Frame.UIStroke.Color=Color3 .fromRGB(47,47,58)
newInput.BoxFrame.Frame.TextBox.TextColor3=Color3 .fromRGB(75,77,83)
newInput.BoxFrame.Frame.TextBox.PlaceholderColor3=Color3 .fromRGB(75,77,83)
newInput.BoxFrame.Frame.TextBox.Active=false
newInput.BoxFrame.Frame.TextBox.Interactable=false
newInput.BoxFrame.Frame.TextBox.TextEditable=false
end
newInput.BoxFrame.Frame.TextBox.Text=Input.Default
newInput.BoxFrame.Frame.TextBox.PlaceholderText=Input.Placeholder
newInput.BoxFrame.Frame.TextBox.MultiLine=Input.MultiLine
if Input.MultiLine then
newInput.BoxFrame.Frame.TextBox.AutomaticSize=Enum.AutomaticSize.Y
else
newInput.BoxFrame.Frame.TextBox.AutomaticSize=Enum.AutomaticSize.None
end
newInput.BoxFrame.Frame.TextBox.ClearTextOnFocus=Input.ClearTextOnFocus
newInput.Visible=true
newInput.BoxFrame.Frame.TextBox.MouseEnter:Connect(function()
if not Input.Locked and not isTouchInput()then
Tween(newInput.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)
end
end)
newInput.BoxFrame.Frame.TextBox.MouseLeave:Connect(function()
if not Input.Locked then
Tween(newInput.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
end
end)
newInput.BoxFrame.Frame.TextBox.Focused:Connect(function()
if not Input.Locked then
Tween(newInput.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(newInput.BoxFrame.Frame.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)
end
end)
newInput.BoxFrame.Frame.TextBox.FocusLost:Connect(function()
if not Input.Locked then
Tween(newInput.BoxFrame.Frame.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Input.Text=newInput.BoxFrame.Frame.TextBox.Text
Input.Callback(Input.Text)
CONFIG[NAMETAB][name]=Input.Text
SAVECONFIG()
end
end)
function Input:Set(newText)
newText=tostring(newText or"")
newInput.BoxFrame.Frame.TextBox.Text=newText
Input.Text=newText
Input.Callback(newText)
CONFIG[NAMETAB][name]=newText
SAVECONFIG()
end
function Input:SetTitle(newText)
Input.Title=tostring(newText or"Input")
newInput.Title.Text=Input.Title
newInput.Name=Input.Title
end
function Input:SetDesc(newDesc)
Input.Desc=tostring(newDesc or"")
newInput.Description.Text=Input.Desc
newInput.Description.Visible=Input.Desc~=""
end
function Input:SetPlaceholder(newText)
Input.Placeholder=tostring(newText or"")
newInput.BoxFrame.Frame.TextBox.PlaceholderText=Input.Placeholder
end
function Input:Lock()
Input.Locked=true
Tween(newInput.UIStroke,{Color=Color3 .fromRGB(47,47,58)},TweenConfigs.Global)
Tween(newInput,{BackgroundColor3=Color3 .fromRGB(32,35,40)},TweenConfigs.Global)
Tween(newInput.Title,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newInput.Description,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newInput.BoxFrame.Frame,{BackgroundColor3=Color3 .fromRGB(32,35,40)},TweenConfigs.Global)
Tween(newInput.BoxFrame.Frame.UIStroke,{Color=Color3 .fromRGB(47,47,58)},TweenConfigs.Global)
Tween(newInput.BoxFrame.Frame.TextBox,{
TextColor3=Color3 .fromRGB(75,77,83),
PlaceholderColor3=Color3 .fromRGB(75,77,83)
},TweenConfigs.Global)
newInput.BoxFrame.Frame.TextBox.Active=false
newInput.BoxFrame.Frame.TextBox.Interactable=false
newInput.BoxFrame.Frame.TextBox.TextEditable=false
end
function Input:Unlock()
Input.Locked=false
Tween(newInput.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(newInput,{BackgroundColor3=Color3 .fromRGB(42,45,52)},TweenConfigs.Global)
Tween(newInput.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newInput.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newInput.BoxFrame.Frame,{BackgroundColor3=Color3 .fromRGB(42,45,52)},TweenConfigs.Global)
Tween(newInput.BoxFrame.Frame.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(newInput.BoxFrame.Frame.TextBox,{
TextColor3=UISettings.TextColor,
PlaceholderColor3=Color3 .fromRGB(139,139,139)
},TweenConfigs.Global)
newInput.BoxFrame.Frame.TextBox.Active=true
newInput.BoxFrame.Frame.TextBox.Interactable=true
newInput.BoxFrame.Frame.TextBox.TextEditable=true
end
function Input:Destroy()
newInput:Destroy()
end
Input.Callback(Input.Default)
return Input
end
local function AddDropdownButton(name,folder)
local newButton=Templates.DropdownButton:Clone()
newButton.Parent=folder or nil
newButton.Name=name
newButton.Frame.Title.Text=name
local function GetRandomGradient()
local gradient={}
for _,g in ipairs(newButton.Frame:GetChildren())do
if g:IsA("UIGradient")then
g.Enabled=false
table.insert(gradient,g)
end
end
local selectedGrad=gradient[math.random(1,#gradient)]
selectedGrad.Enabled=true
return selectedGrad
end
GetRandomGradient()
return newButton
end
local function TableToString(tbl)
return table.concat(tbl,", ")
end
function Tab:Dropdown(data)
data=data or{}
local Dropdown={
Title=data.Title or"Dropdown",
Desc=data.Desc,
Multi=data.Multi or false,
Values=data.Values or{},
Value=data.Value~=nil and data.Value or data.Default,
AllowNone=data.AllowNone or false,
Locked=data.Locked or false,
Callback=type(data.Callback)=="function"and data.Callback or function()end
}
if not Dropdown.Multi and Dropdown.AllowNone then
Dropdown.Values={"None",unpack(Dropdown.Values)}
end
local name=Dropdown.Title
if CONFIGLOADED and CONFIG[NAMETAB][name]~=nil then
Dropdown.Value=CONFIG[NAMETAB][name]
elseif not CONFIGLOADED or CONFIG[NAMETAB][name]==nil then
CONFIG[NAMETAB][name]=Dropdown.Value
end
if Dropdown.Multi then
if type(Dropdown.Value)=="string"then
Dropdown.Value={Dropdown.Value}
elseif type(Dropdown.Value)~="table"then
Dropdown.Value={}
end
elseif Dropdown.AllowNone and(Dropdown.Value==""or Dropdown.Value==nil)then
Dropdown.Value="None"
end
if Dropdown.Multi and not Dropdown.AllowNone and#Dropdown.Value==0 then
for _,candidate in ipairs(Dropdown.Values)do
if type(candidate)=="string"then
Dropdown.Value={candidate}
CONFIG[NAMETAB][name]=Dropdown.Value
break
end
end
end
local selected=nil
local newDropdown=Templates.Dropdown:Clone()
local dropdownFolder=Templates.DropdownList:Clone()
dropdownFolder.Name=Dropdown.Title
dropdownFolder.Parent=newWindow.DropdownSelection.Dropdowns
newDropdown.Parent=parentElement
newDropdown.Name=Dropdown.Title
newDropdown.Title.Text=Dropdown.Title
if Dropdown.Desc and Dropdown.Desc~=""then
newDropdown.Description.Visible=true
newDropdown.Description.Text=Dropdown.Desc
else
newDropdown.Description.Visible=false
end
if Dropdown.Locked then
newDropdown.UIStroke.Color=Color3 .fromRGB(47,47,58)
newDropdown.BackgroundColor3=Color3 .fromRGB(32,35,40)
newDropdown.Title.TextColor3=Color3 .fromRGB(75,77,83)
newDropdown.Description.TextColor3=Color3 .fromRGB(75,77,83)
newDropdown.Title.ClickIcon.ImageColor3=Color3 .fromRGB(75,77,83)
newDropdown.Title.BoxFrame.Trigger.BackgroundColor3=Color3 .fromRGB(32,35,40)
newDropdown.Title.BoxFrame.Trigger.UIStroke.Color=Color3 .fromRGB(47,47,58)
newDropdown.Title.BoxFrame.Trigger.Title.TextColor3=Color3 .fromRGB(75,77,83)
newDropdown.Active=false
newDropdown.Interactable=false
end
newDropdown.Visible=true
local function SelectValue(multi,newvalue)
if not multi then
if type(newvalue)~="string"then return nil end
local targetButton=dropdownFolder.DropdownItems:FindFirstChild(newvalue)
local targetbuttonSearch=dropdownFolder.DropdownItemsSearch:FindFirstChild(newvalue)
if not targetButton or not targetbuttonSearch then return nil end
selected=newvalue
Dropdown.Value=selected
local prettyLabel=Window._MusicTriggerLabels and Window._MusicTriggerLabels[selected]
newDropdown.Title.BoxFrame.Trigger.Title.Text=prettyLabel or selected
for _,otherButton in dropdownFolder.DropdownItems:GetChildren()do
if otherButton:IsA("GuiButton")and otherButton.Name~=newvalue then
Tween(otherButton.Frame.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(otherButton.Frame.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(otherButton.Frame,{BackgroundTransparency=1},TweenConfigs.Global)
Tween(otherButton.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
end
end
for _,otherButton in dropdownFolder.DropdownItemsSearch:GetChildren()do
if otherButton:IsA("GuiButton")and otherButton.Name~=newvalue then
Tween(otherButton.Frame.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(otherButton.Frame.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(otherButton.Frame,{BackgroundTransparency=1},TweenConfigs.Global)
Tween(otherButton.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
end
end
Tween(targetButton.Frame.Title,{TextColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(targetButton.Frame.Description,{TextColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(targetButton.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)
Tween(targetButton.Frame,{BackgroundTransparency=0},TweenConfigs.Global)
Tween(targetbuttonSearch.Frame.Title,{TextColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(targetbuttonSearch.Frame.Description,{TextColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(targetbuttonSearch.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)
Tween(targetbuttonSearch.Frame,{BackgroundTransparency=0},TweenConfigs.Global)
if selected=="None"then return""end
return selected
elseif multi then
if type(newvalue)~="table"then newvalue={newvalue}end
selected=type(selected)=="table"and selected or{}
for _,newSelected in newvalue do
if type(newSelected)~="string"then continue end
local targetButton=dropdownFolder.DropdownItems:FindFirstChild(newSelected)
local targetbuttonSearch=dropdownFolder.DropdownItemsSearch:FindFirstChild(newSelected)
if not targetButton or not targetbuttonSearch then continue end
local idx=table.find(selected,newSelected)
if idx then
if not Dropdown.AllowNone and#selected==1 then continue end
table.remove(selected,idx)
Tween(targetButton.Frame.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(targetButton.Frame.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(targetButton.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(targetButton.Frame,{BackgroundTransparency=1},TweenConfigs.Global)
Tween(targetbuttonSearch.Frame.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(targetbuttonSearch.Frame.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(targetbuttonSearch.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(targetbuttonSearch.Frame,{BackgroundTransparency=1},TweenConfigs.Global)
else
table.insert(selected,newSelected)
Tween(targetButton.Frame.Title,{TextColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(targetButton.Frame.Description,{TextColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(targetButton.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)
Tween(targetButton.Frame,{BackgroundTransparency=0},TweenConfigs.Global)
Tween(targetbuttonSearch.Frame.Title,{TextColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(targetbuttonSearch.Frame.Description,{TextColor3=Color3 .fromRGB(255,255,255)},TweenConfigs.Global)
Tween(targetbuttonSearch.UIStroke,{Color=UISettings.AccentColor},TweenConfigs.Global)
Tween(targetbuttonSearch.Frame,{BackgroundTransparency=0},TweenConfigs.Global)
end
end
Dropdown.Value=selected
newDropdown.Title.BoxFrame.Trigger.Title.Text=TableToString(selected)
return selected
end
end
local function AddButtons(buttonListUnfiltered,refresh)
buttonListUnfiltered=type(buttonListUnfiltered)=="table"and buttonListUnfiltered or{}
local seen={}
local buttonList={}
for i,value in buttonListUnfiltered do
if typeof(value)=="string"then
if not seen[value]then
seen[value]=1
table.insert(buttonList,value)
else
seen[value]=seen[value]+1
table.insert(buttonList,value.." ("..seen[value]..")")
end
end
end
if refresh then
Dropdown.Values=buttonList
for _,oldButton in dropdownFolder.DropdownItems:GetChildren()do
if oldButton:IsA("GuiButton")then
oldButton:Destroy()
end
end
for _,oldButton in dropdownFolder.DropdownItemsSearch:GetChildren()do
if oldButton:IsA("GuiButton")then
oldButton:Destroy()
end
end
end
if not Dropdown.Multi then
if refresh then
selected=nil
newDropdown.Title.BoxFrame.Trigger.Title.Text=""
end
for _,buttonName in buttonList do
local newDropdownButton=AddDropdownButton(buttonName,dropdownFolder.DropdownItems)
local newDropdownButtonSearch=AddDropdownButton(buttonName,dropdownFolder.DropdownItemsSearch)
if Window._MusicRowDecorate then
pcall(Window._MusicRowDecorate,buttonName,newDropdownButton)
pcall(Window._MusicRowDecorate,buttonName,newDropdownButtonSearch)
end
newDropdownButton.Visible=true
newDropdownButtonSearch.Visible=true
if selected==buttonName then
newDropdownButton.Frame.Title.TextColor3=Color3 .fromRGB(255,255,255)
newDropdownButton.Frame.Description.TextColor3=Color3 .fromRGB(255,255,255)
newDropdownButton.UIStroke.Color=UISettings.AccentColor
newDropdownButton.Frame.BackgroundTransparency=0
newDropdownButton.Frame.Title.TextColor3=Color3 .fromRGB(255,255,255)
newDropdownButtonSearch.Frame.Title.TextColor3=Color3 .fromRGB(255,255,255)
newDropdownButtonSearch.Frame.Description.TextColor3=Color3 .fromRGB(255,255,255)
newDropdownButtonSearch.UIStroke.Color=UISettings.AccentColor
newDropdownButtonSearch.Frame.BackgroundTransparency=0
newDropdownButtonSearch.Frame.Title.TextColor3=Color3 .fromRGB(255,255,255)
end
BindSafeActivate(newDropdownButton,function()
if not Dropdown.Locked then
local value=SelectValue(false,buttonName)
if value then
if isTouchInput()then task.defer(function()if DropdownState and SelectedDropdown==Dropdown.Title then DropdownPopup(false)end end)end
Dropdown.Callback(value)
CONFIG[NAMETAB][name]=Dropdown.Value
SAVECONFIG()
end
end
end)
BindSafeActivate(newDropdownButtonSearch,function()
if not Dropdown.Locked then
local value=SelectValue(false,buttonName)
if value then
if isTouchInput()then task.defer(function()if DropdownState and SelectedDropdown==Dropdown.Title then DropdownPopup(false)end end)end
Dropdown.Callback(value)
CONFIG[NAMETAB][name]=Dropdown.Value
SAVECONFIG()
end
end
end)
end
elseif Dropdown.Multi then
if refresh then
selected={}
newDropdown.Title.BoxFrame.Trigger.Title.Text=TableToString(selected)
end
for _,buttonName in buttonList do
local newDropdownButton=AddDropdownButton(buttonName,dropdownFolder.DropdownItems)
local newDropdownButtonSearch=AddDropdownButton(buttonName,dropdownFolder.DropdownItemsSearch)
if Window._MusicRowDecorate then
pcall(Window._MusicRowDecorate,buttonName,newDropdownButton)
pcall(Window._MusicRowDecorate,buttonName,newDropdownButtonSearch)
end
newDropdownButton.Visible=true
newDropdownButtonSearch.Visible=true
if table.find(selected,buttonName)then
newDropdownButton.Frame.Title.TextColor3=Color3 .fromRGB(255,255,255)
newDropdownButton.Frame.Description.TextColor3=Color3 .fromRGB(255,255,255)
newDropdownButton.UIStroke.Color=UISettings.AccentColor
newDropdownButton.Frame.BackgroundTransparency=0
newDropdownButton.Frame.Title.TextColor3=Color3 .fromRGB(255,255,255)
newDropdownButtonSearch.Frame.Title.TextColor3=Color3 .fromRGB(255,255,255)
newDropdownButtonSearch.Frame.Description.TextColor3=Color3 .fromRGB(255,255,255)
newDropdownButtonSearch.UIStroke.Color=UISettings.AccentColor
newDropdownButtonSearch.Frame.BackgroundTransparency=0
newDropdownButtonSearch.Frame.Title.TextColor3=Color3 .fromRGB(255,255,255)
end
BindSafeActivate(newDropdownButton,function()
if not Dropdown.Locked then
local value=SelectValue(true,{buttonName})
if value then
Dropdown.Callback(value)
CONFIG[NAMETAB][name]=Dropdown.Value
SAVECONFIG()
end
end
end)
BindSafeActivate(newDropdownButtonSearch,function()
if not Dropdown.Locked then
local value=SelectValue(true,{buttonName})
if value then
Dropdown.Callback(value)
CONFIG[NAMETAB][name]=Dropdown.Value
SAVECONFIG()
end
end
end)
end
end
end
if not Dropdown.Multi then
selected=Dropdown.Value or nil
newDropdown.Title.BoxFrame.Trigger.Title.Text=selected
AddButtons(Dropdown.Values)
elseif Dropdown.Multi then
newDropdown.Title.ClickIcon.Image="rbxassetid://91415671397056"
if type(Dropdown.Value)=="string"then
Dropdown.Value={Dropdown.Value}
end
selected=Dropdown.Value or{}
newDropdown.Title.BoxFrame.Trigger.Title.Text=TableToString(selected)
AddButtons(Dropdown.Values)
end
BindSafeActivate(newDropdown.Title.BoxFrame.Trigger,function()
if not Dropdown.Locked then DropdownPopup(nil,Dropdown.Title)end
end)
function Dropdown:SetTitle(newText)
local oldTitle=Dropdown.Title
Dropdown.Title=tostring(newText or"Dropdown")
newDropdown.Title.Text=Dropdown.Title
newDropdown.Name=Dropdown.Title
dropdownFolder.Name=Dropdown.Title
if SelectedDropdown==oldTitle then
SelectedDropdown=Dropdown.Title
newWindow.DropdownSelection.TopBar.Title.Text=Dropdown.Title
end
end
function Dropdown:SetDesc(newDesc)
Dropdown.Desc=tostring(newDesc or"")
newDropdown.Description.Text=Dropdown.Desc
newDropdown.Description.Visible=Dropdown.Desc~=""
end
function Dropdown:Refresh(newvals)
local values=type(newvals)=="table"and newvals or{}
if not Dropdown.Multi and Dropdown.AllowNone then
local withNone={"None"}
for _,value in ipairs(values)do if value~="None"then table.insert(withNone,value)end end
values=withNone
end
AddButtons(values,true)
if Dropdown.Multi then
Dropdown.Value={}
selected=Dropdown.Value
if not Dropdown.AllowNone and#Dropdown.Values>0 then
SelectValue(true,{Dropdown.Values[1]})
end
elseif Dropdown.AllowNone then
SelectValue(false,"None")
else
Dropdown.Value=nil
selected=nil
end
CONFIG[NAMETAB][name]=Dropdown.Value
SAVECONFIG()
return Dropdown.Value
end
function Dropdown:Select(newval)
local value=SelectValue(Dropdown.Multi,newval)
if value==nil then return nil end
Dropdown.Callback(value)
CONFIG[NAMETAB][name]=Dropdown.Value
SAVECONFIG()
return value
end
function Dropdown:Lock()
Dropdown.Locked=true
Tween(newDropdown.UIStroke,{Color=Color3 .fromRGB(47,47,58)},TweenConfigs.Global)
Tween(newDropdown,{BackgroundColor3=Color3 .fromRGB(32,35,40)},TweenConfigs.Global)
Tween(newDropdown.Title,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newDropdown.Description,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newDropdown.Title.ClickIcon,{ImageColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
Tween(newDropdown.Title.BoxFrame.Trigger,{BackgroundColor3=Color3 .fromRGB(32,35,40)},TweenConfigs.Global)
Tween(newDropdown.Title.BoxFrame.Trigger.UIStroke,{Color=Color3 .fromRGB(47,47,58)},TweenConfigs.Global)
Tween(newDropdown.Title.BoxFrame.Trigger.Title,{TextColor3=Color3 .fromRGB(75,77,83)},TweenConfigs.Global)
newDropdown.Active=false
newDropdown.Interactable=false
end
function Dropdown:Unlock()
Dropdown.Locked=false
Tween(newDropdown.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(newDropdown,{BackgroundColor3=Color3 .fromRGB(42,45,52)},TweenConfigs.Global)
Tween(newDropdown.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newDropdown.Description,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newDropdown.Title.ClickIcon,{ImageColor3=UISettings.TextColor},TweenConfigs.Global)
Tween(newDropdown.Title.BoxFrame.Trigger,{BackgroundColor3=Color3 .fromRGB(42,45,52)},TweenConfigs.Global)
Tween(newDropdown.Title.BoxFrame.Trigger.UIStroke,{Color=Color3 .fromRGB(60,60,74)},TweenConfigs.Global)
Tween(newDropdown.Title.BoxFrame.Trigger.Title,{TextColor3=UISettings.TextColor},TweenConfigs.Global)
newDropdown.Active=true
newDropdown.Interactable=true
end
function Dropdown:Destroy()
if SelectedDropdown==Dropdown.Title then
SelectedDropdown=nil
DropdownState=false
newWindow.DropdownSelection.Visible=false
newWindow.DarkOverlay.Visible=false
end
newDropdown:Destroy()
if dropdownFolder then dropdownFolder:Destroy()end
end
if(not Dropdown.Multi and Dropdown.AllowNone)and Dropdown.Value=="None"then
Dropdown.Callback("")
else
Dropdown.Callback(Dropdown.Value)
end
return Dropdown
end
function Tab:InfoNguyenNhat(data)
data=data or{}
local Info={
Avatar=tostring(data.Avatar or"rbxassetid://0"),
Name=tostring(data.Name or"Nguyen Nhat"),
Badges=type(data.Badges)=="table"and data.Badges or{},
Bio=tostring(data.Bio or""),
}
local card=Instance.new("Frame")
card.Name="InfoNguyenNhat"
card.BackgroundColor3=Color3 .fromRGB(43,46,53)
card.AutomaticSize=Enum.AutomaticSize.Y
card.Size=UDim2 .new(1,0,0,90)
card.Parent=parentElement
Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
local cardStroke=Instance.new("UIStroke",card)
cardStroke.Color=Color3 .fromRGB(61,61,75)
cardStroke.Thickness=1.5
local pad=Instance.new("UIPadding",card)
pad.PaddingTop=UDim.new(0,12)
pad.PaddingBottom=UDim.new(0,12)
pad.PaddingLeft=UDim.new(0,12)
pad.PaddingRight=UDim.new(0,12)
local layout=Instance.new("UIListLayout",card)
layout.FillDirection=Enum.FillDirection.Horizontal
layout.VerticalAlignment=Enum.VerticalAlignment.Center
layout.HorizontalAlignment=Enum.HorizontalAlignment.Left
layout.Padding=UDim.new(0,14)
layout.SortOrder=Enum.SortOrder.LayoutOrder
local socialCol=Instance.new("Frame")
socialCol.Name="Socials"
socialCol.BackgroundTransparency=1
socialCol.AutomaticSize=Enum.AutomaticSize.XY
socialCol.LayoutOrder=3
socialCol.Parent=card
local socialLayout=Instance.new("UIListLayout",socialCol)
socialLayout.VerticalAlignment=Enum.VerticalAlignment.Center
socialLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
socialLayout.Padding=UDim.new(0,8)
socialLayout.SortOrder=Enum.SortOrder.LayoutOrder
local textCol=Instance.new("Frame")
textCol.Name="Info"
textCol.BackgroundTransparency=1
textCol.AutomaticSize=Enum.AutomaticSize.Y
textCol.Size=UDim2 .new(1,-110,0,0)
textCol.LayoutOrder=2
textCol.Parent=card
local textLayout=Instance.new("UIListLayout",textCol)
textLayout.Padding=UDim.new(0,4)
textLayout.SortOrder=Enum.SortOrder.LayoutOrder
local nameRow=Instance.new("Frame")
nameRow.BackgroundTransparency=1
nameRow.AutomaticSize=Enum.AutomaticSize.XY
nameRow.Size=UDim2 .new(0,0,0,18)
nameRow.LayoutOrder=1
nameRow.Parent=textCol
local nameRowLayout=Instance.new("UIListLayout",nameRow)
nameRowLayout.FillDirection=Enum.FillDirection.Horizontal
nameRowLayout.VerticalAlignment=Enum.VerticalAlignment.Center
nameRowLayout.Padding=UDim.new(0,6)
nameRowLayout.SortOrder=Enum.SortOrder.LayoutOrder
local nameLabel=Instance.new("TextLabel")
nameLabel.Text=Info.Name
nameLabel.FontFace=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal)
nameLabel.TextSize=16
nameLabel.TextColor3=UISettings.TextColor
nameLabel.BackgroundTransparency=1
nameLabel.AutomaticSize=Enum.AutomaticSize.X
nameLabel.Size=UDim2 .new(0,0,0,18)
nameLabel.LayoutOrder=1
nameLabel.Parent=nameRow
for i,badgeText in ipairs(Info.Badges)do
local badge=Instance.new("TextLabel")
badge.Text=badgeText
badge.FontFace=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal)
badge.TextSize=11
badge.TextColor3=Color3 .fromRGB(255,255,255)
badge.BackgroundColor3=UISettings.AccentColor
badge.AutomaticSize=Enum.AutomaticSize.X
badge.Size=UDim2 .new(0,0,0,16)
badge.LayoutOrder=i+1
badge.Parent=nameRow
Instance.new("UICorner",badge).CornerRadius=UDim.new(0,4)
local bp=Instance.new("UIPadding",badge)
bp.PaddingLeft=UDim.new(0,6)
bp.PaddingRight=UDim.new(0,6)
end
local bioLabel=Instance.new("TextLabel")
bioLabel.Text=Info.Bio
bioLabel.FontFace=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal)
bioLabel.TextSize=13
bioLabel.TextColor3=UISettings.MutedTextColor
bioLabel.TextXAlignment=Enum.TextXAlignment.Left
bioLabel.TextWrapped=true
bioLabel.BackgroundTransparency=1
bioLabel.AutomaticSize=Enum.AutomaticSize.Y
bioLabel.Size=UDim2 .new(1,0,0,14)
bioLabel.Visible=Info.Bio~=""
bioLabel.LayoutOrder=2
bioLabel.Parent=textCol
local avatarFrame=Instance.new("ImageLabel")
avatarFrame.Name="Avatar"
avatarFrame.Size=UDim2 .new(0,60,0,60)
avatarFrame.Image=Info.Avatar
avatarFrame.BackgroundColor3=Color3 .fromRGB(32,35,41)
avatarFrame.LayoutOrder=1
avatarFrame.Parent=card
local avatarPlaceholder=Instance.new("TextLabel")
avatarPlaceholder.Name="FallbackInitials"
avatarPlaceholder.Size=UDim2 .fromScale(1,1)
avatarPlaceholder.BackgroundTransparency=1
avatarPlaceholder.Font=Enum.Font.GothamBold
avatarPlaceholder.Text="xN"
avatarPlaceholder.TextSize=22
avatarPlaceholder.TextColor3=UISettings.AccentColor
avatarPlaceholder.Visible=Info.Avatar==""or Info.Avatar=="rbxassetid://0"
avatarPlaceholder.Parent=avatarFrame
Instance.new("UICorner",avatarFrame).CornerRadius=UDim.new(0,14)
local avStroke=Instance.new("UIStroke",avatarFrame)
avStroke.Color=Color3 .fromRGB(61,61,75)
avStroke.Thickness=1.5
function Info.AddSocialIcon(icon,copyValue,order)
return CreateSocialIcon(socialCol,icon,copyValue,order)
end
function Info:SetAvatar(id)
id=tostring(id or"")
avatarFrame.Image=id
avatarPlaceholder.Visible=id==""or id=="rbxassetid://0"
if id~=""and id~="rbxassetid://0"then
local wanted=id
task.spawn(function()
for _,waitTime in ipairs({1,2,3,5})do
task.wait(waitTime)
if avatarFrame.Image~=wanted then return end
if avatarFrame.IsLoaded then return end
avatarFrame.Image=""
avatarFrame.Image=wanted
end
end)
end
end
function Info:SetName(text)nameLabel.Text=text end
function Info:SetBio(text)
bioLabel.Text=text
bioLabel.Visible=text~=""
end
function Info:Destroy()card:Destroy()end
return Info
end
function Tab:Discord(data)
data=data or{}
local Discord={
Avatar=tostring(data.Avatar or"rbxassetid://0"),
Name=tostring(data.Name or"Discord Server"),
Desc=tostring(data.Desc or""),
InviteLink=tostring(data.InviteLink or"discord.gg/xxxxxxx"),
InviteCode=data.InviteCode~=nil and tostring(data.InviteCode)or nil,
}
local card=Instance.new("Frame")
card.Name="DiscordCard"
card.BackgroundColor3=Color3 .fromRGB(43,46,53)
card.AutomaticSize=Enum.AutomaticSize.Y
card.Size=UDim2 .new(1,0,0,90)
card.Parent=parentElement
Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
local cardStroke2=Instance.new("UIStroke",card)
cardStroke2 .Color=Color3 .fromRGB(61,61,75)
cardStroke2 .Thickness=1.5
local pad2=Instance.new("UIPadding",card)
pad2 .PaddingTop=UDim.new(0,12)
pad2 .PaddingBottom=UDim.new(0,12)
pad2 .PaddingLeft=UDim.new(0,12)
pad2 .PaddingRight=UDim.new(0,12)
local layout2=Instance.new("UIListLayout",card)
layout2 .FillDirection=Enum.FillDirection.Horizontal
layout2 .VerticalAlignment=Enum.VerticalAlignment.Center
layout2 .Padding=UDim.new(0,12)
layout2 .SortOrder=Enum.SortOrder.LayoutOrder
local avatarFrame2=Instance.new("ImageLabel")
avatarFrame2 .Size=UDim2 .new(0,54,0,54)
avatarFrame2 .Image=Discord.Avatar
avatarFrame2 .BackgroundColor3=Color3 .fromRGB(32,35,41)
avatarFrame2 .LayoutOrder=1
avatarFrame2 .Parent=card
Instance.new("UICorner",avatarFrame2).CornerRadius=UDim.new(1,0)
local textCol2=Instance.new("Frame")
textCol2 .BackgroundTransparency=1
textCol2 .AutomaticSize=Enum.AutomaticSize.Y
textCol2 .Size=UDim2 .new(1,-180,0,0)
textCol2 .LayoutOrder=2
textCol2 .Parent=card
local textLayout2=Instance.new("UIListLayout",textCol2)
textLayout2 .Padding=UDim.new(0,2)
textLayout2 .SortOrder=Enum.SortOrder.LayoutOrder
local nameLabel2=Instance.new("TextLabel")
nameLabel2 .Text=Discord.Name
nameLabel2 .FontFace=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal)
nameLabel2 .TextSize=16
nameLabel2 .TextColor3=UISettings.TextColor
nameLabel2 .TextXAlignment=Enum.TextXAlignment.Left
nameLabel2 .BackgroundTransparency=1
nameLabel2 .AutomaticSize=Enum.AutomaticSize.Y
nameLabel2 .Size=UDim2 .new(1,0,0,18)
nameLabel2 .LayoutOrder=1
nameLabel2 .Parent=textCol2
local descLabel=Instance.new("TextLabel")
descLabel.Text=Discord.Desc
descLabel.FontFace=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Medium,Enum.FontStyle.Normal)
descLabel.TextSize=12
descLabel.TextColor3=UISettings.MutedTextColor
descLabel.TextXAlignment=Enum.TextXAlignment.Left
descLabel.TextWrapped=true
descLabel.BackgroundTransparency=1
descLabel.AutomaticSize=Enum.AutomaticSize.Y
descLabel.Size=UDim2 .new(1,0,0,14)
descLabel.Visible=Discord.Desc~=""
descLabel.LayoutOrder=2
descLabel.Parent=textCol2
local statusLabel=Instance.new("TextLabel")
statusLabel.Text=""
statusLabel.FontFace=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
statusLabel.TextSize=11
statusLabel.TextColor3=Color3 .fromRGB(87,242,135)
statusLabel.TextXAlignment=Enum.TextXAlignment.Left
statusLabel.BackgroundTransparency=1
statusLabel.AutomaticSize=Enum.AutomaticSize.Y
statusLabel.Size=UDim2 .new(1,0,0,12)
statusLabel.Visible=false
statusLabel.LayoutOrder=3
statusLabel.Parent=textCol2
local joinBtn=Instance.new("TextButton")
joinBtn.Text="Join Discord"
joinBtn.FontFace=Font.new([[rbxassetid://11702779517]],Enum.FontWeight.Bold,Enum.FontStyle.Normal)
joinBtn.TextSize=13
joinBtn.TextColor3=Color3 .fromRGB(255,255,255)
joinBtn.BackgroundColor3=Color3 .fromRGB(88,101,242)
joinBtn.AutoButtonColor=false
joinBtn.Size=UDim2 .new(0,110,0,32)
joinBtn.LayoutOrder=3
joinBtn.Parent=card
Instance.new("UICorner",joinBtn).CornerRadius=UDim.new(0,6)
joinBtn.MouseEnter:Connect(function()
Tween(joinBtn,{BackgroundColor3=Color3 .fromRGB(71,82,196)},TweenConfigs.Global)
end)
joinBtn.MouseLeave:Connect(function()
Tween(joinBtn,{BackgroundColor3=Color3 .fromRGB(88,101,242)},TweenConfigs.Global)
end)
joinBtn.MouseButton1Click:Connect(function()
if CopyText(Discord.InviteLink)then
ShowCopiedTip(joinBtn)
end
end)
local httpRequest=(syn and syn.request)or(http and http.request)or request or http_request
if httpRequest and Discord.InviteCode then
task.spawn(function()
local ok,result=pcall(function()
return httpRequest({
Url="https://discord.com/api/v9/invites/"..Discord.InviteCode.."?with_counts=true",
Method="GET",
})
end)
if ok and result and result.StatusCode==200 then
local success,decoded=pcall(function()
return HttpService:JSONDecode(result.Body)
end)
if success and decoded then
local online=decoded.approximate_presence_count
local total=decoded.approximate_member_count
if online and total then
statusLabel.Text=("● %d online / %d thành viên"):format(online,total)
statusLabel.Visible=true
end
end
end
end)
end
function Discord:SetInvite(link,code)
Discord.InviteLink=tostring(link or"")
if code~=nil then Discord.InviteCode=tostring(code)end
end
function Discord:Destroy()card:Destroy()end
return Discord
end
return Tab
end
function Window:SelectTab(index)
local tabtarget
if type(index)=="string"then
tabtarget=TabLists[index]
else
tabtarget=UserTabIndexList[tonumber(index)]
end
if tabtarget then
SelectTab(tabtarget.Name)
return true
end
return false
end
function Window:OpenUISettings()
return Window:SelectTab(Window.SettingsTitle)
end
function Window:Divider()
local newDivier=Templates.Divider:Clone()
newDivier.LayoutOrder=(#UserTabIndexList*10)+5
newDivier.Parent=newWindow.TabButtons.Lists
newDivier.Visible=true
return newDivier
end
function Window:SetToggleKey(newKey)
local resolved=newKey
if type(newKey)=="string"then
resolved=Enum.KeyCode[newKey]
end
if resolved then Window.ToggleKey=resolved end
return Window.ToggleKey
end
function Window:SetToggleButtonPlatform(platform)
local normalized=tostring(platform or"Both")
if normalized~="Mobile"and normalized~="Both"then normalized="Both"end
Window.ToggleButtonPlatform=normalized
if normalized=="Mobile"and not UIS.TouchEnabled then
newFloatingIcon.Visible=false
elseif newWindow.Visible==false then
newFloatingIcon.Visible=true
end
return Window.ToggleButtonPlatform
end
function Window:GetToggleButtonPlatform()
return Window.ToggleButtonPlatform
end
local oldFloatingSize=newFloatingIcon.Size
function Window:EditOpenButton(data)
data=data or{}
if data.Title~=nil then
newFloatingIcon.TextLabel.Text=tostring(data.Title)
end
if data.Icon~=nil then
ApplyIcon(newFloatingIcon.Icon,data.Icon)
end
if data.OpenIcon~=nil then
ApplyIcon(newFloatingIcon.Open,data.OpenIcon)
end
if data.Size then
newFloatingIcon.Size=data.Size
oldFloatingSize=data.Size
end
if data.Position then newFloatingIcon.Position=data.Position end
if data.BackgroundColor3 then newFloatingIcon.BackgroundColor3=data.BackgroundColor3 end
if data.TextColor3 then newFloatingIcon.TextLabel.TextColor3=data.TextColor3 end
if data.IconColor3 then newFloatingIcon.Icon.ImageColor3=data.IconColor3 end
if data.OpenIconColor3 then newFloatingIcon.Open.ImageColor3=data.OpenIconColor3 end
if data.ShowText~=nil then newFloatingIcon.TextLabel.Visible=data.ShowText==true end
if data.CornerRadius and newFloatingIcon:FindFirstChildOfClass("UICorner")then
newFloatingIcon:FindFirstChildOfClass("UICorner").CornerRadius=data.CornerRadius
end
return newFloatingIcon
end
function Window:Dialog(data)
data=data or{}
local Dialog={
Title=data.Title or"Dialog",
Content=data.Content or"",
Icon=data.Icon,
Buttons=type(data.Buttons)=="table"and data.Buttons or{},
Size=nil,
PressDecreaseSize=UDim2 .fromOffset(5,5)
}
local newDialog=Templates.DialogElements.Dialog:Clone()
local newDialogDarkOverlay=Templates.DialogElements.DarkOverlayDialog:Clone()
newDialog.Title.TextLabel.Text=Dialog.Title
newDialog.Content.Visible=Dialog.Content~=""
newDialog.Content.TextLabel.Text=Dialog.Content
if Dialog.Icon then
ApplyIcon(newDialog.Title.Icon,Dialog.Icon)
newDialog.Title.Icon.Visible=true
end
newDialog.Parent=newWindow
newDialogDarkOverlay.Parent=newWindow
Dialog.Size=UDim2 .fromOffset(newDialog.AbsoluteSize.X,newDialog.AbsoluteSize.Y)
newDialogDarkOverlay.BackgroundTransparency=1
local dialogClosed=false
local function CloseDialog()
if dialogClosed then return end
dialogClosed=true
if newDialog and newDialog.Parent then newDialog:Destroy()end
if newDialogDarkOverlay and newDialogDarkOverlay.Parent then
local tw=Tween(newDialogDarkOverlay,{BackgroundTransparency=1},TweenConfigs.Global)
tw.Completed:Wait()
if newDialogDarkOverlay.Parent then newDialogDarkOverlay:Destroy()end
end
end
function Dialog:Close()CloseDialog()end
for _,button in Dialog.Buttons do
if type(button)~="table"then continue end
local buttonData={
Title=button.Title or"Button",
Callback=type(button.Callback)=="function"and button.Callback or function()end
}
local newButton=Templates.DialogElements.DialogButton:Clone()
local originalSize=newButton.Button.Size
newButton.Button.Label.Text=buttonData.Title
newButton.Button.MouseButton1Click:Connect(function()
CloseDialog()
local ok,err=pcall(buttonData.Callback)
if not ok then warn("Dialog callback error: "..tostring(err))end
end)
newButton.Button.MouseButton1Down:Connect(function()
Tween(newButton.Button,{Size=originalSize-Dialog.PressDecreaseSize},TweenConfigs.Global)
end)
newButton.Button.MouseButton1Up:Connect(function()
Tween(newButton.Button,{Size=originalSize},TweenConfigs.Global)
end)
newButton.Button.MouseLeave:Connect(function()
Tween(newButton.Button,{Size=originalSize},TweenConfigs.Global)
end)
newButton.Parent=newDialog.Buttons
newButton.Visible=true
end
Tween(newDialogDarkOverlay,{BackgroundTransparency=0.6},TweenConfigs.Global)
newDialog.Visible=true
newDialogDarkOverlay.Visible=true
return Dialog
end
local oldWindowSize=Window.Size
local oldWindowSizeMaximize=Window.Size
local oldWindowPositionMaximize=newWindow.Position
local maximizedWindow=false
local windowDraggable=Draggable(newWindow.TopFrame,newWindow)
local floatingDraggable=Draggable(newFloatingIcon,newFloatingIcon)
local keybindConnection=nil
local resizeHandle=Instance.new("ImageButton")
resizeHandle.Name="ResizeHandle"
resizeHandle.BackgroundTransparency=1
resizeHandle.AutoButtonColor=false
resizeHandle.ImageColor3=Color3 .fromRGB(150,155,165)
resizeHandle.ImageTransparency=0.6
resizeHandle.Image=(IconModule.Icon("move-diagonal-2")and IconModule.Icon("move-diagonal-2")[1])or""
resizeHandle.ImageRectOffset=(IconModule.Icon("move-diagonal-2")and IconModule.Icon("move-diagonal-2")[2].ImageRectPosition)or Vector2 .new(0,0)
resizeHandle.ImageRectSize=(IconModule.Icon("move-diagonal-2")and IconModule.Icon("move-diagonal-2")[2].ImageRectSize)or Vector2 .new(0,0)
resizeHandle.AnchorPoint=Vector2 .new(1,1)
resizeHandle.Position=UDim2 .new(1,-3,1,-3)
resizeHandle.Size=UDim2 .new(0,16,0,16)
resizeHandle.ZIndex=10
resizeHandle.Parent=newWindow
resizeHandle.MouseEnter:Connect(function()
Tween(resizeHandle,{ImageTransparency=0},TweenConfigs.Global)
end)
resizeHandle.MouseLeave:Connect(function()
Tween(resizeHandle,{ImageTransparency=0.6},TweenConfigs.Global)
end)
local windowResizable=Resizable(
resizeHandle,
newWindow,
Vector2 .new(420,300),
Vector2 .new(1000,800)
)
newWindow.Visible=true
newWindow.Size=UDim2 .fromOffset(0,0)
local windowstate=newWindow.Visible
local startupGatePassed=true
local startupGateFinished=true
local startupMenuBuilt=false
local timeout=false
local windowDestroyed=false
Window.__IslandReady=false
local function releaseStartupIsland()
if windowDestroyed or not startupMenuBuilt or not startupGateFinished then return end
Window.__IslandReady=true
local islandApi=Window.DynamicIsland
if islandApi and type(islandApi.Enable)=="function"then
pcall(islandApi.Enable,islandApi,islandApi.Enabled)
end
end
windowSizeRuntimeSetter=function(size)
if typeof(size)~="UDim2"then return end
Window.Size=size
oldWindowSize=size
if maximizedWindow then
oldWindowSizeMaximize=size
elseif windowstate and newWindow and newWindow.Parent then
newWindow.Size=size
end
end
local function toggleButtonAllowed()
return Window.ToggleButtonPlatform~="Mobile"or UIS.TouchEnabled
end
local function ToggleWindow(state)
if windowDestroyed then return end
if state==true then
oldFloatingSize=newFloatingIcon.Size
newWindow.Size=UDim2 .fromOffset(0,0)
newWindow.Visible=true
do local dropShadow=newWindow:FindFirstChild("DropShadow")if dropShadow then pcall(function()dropShadow.Visible=true end)end end
Tween(newFloatingIcon,{Size=UDim2 .new(0,0,0,0)},TweenConfigs.Global)
Tween(newWindow,{Size=oldWindowSize},TweenConfigs.Global)
.Completed:Wait()
newWindow.Tabs.Visible=true
newWindow.TabButtons.Visible=true
newFloatingIcon.Visible=false
windowstate=true
elseif state==false then
oldWindowSize=newWindow.Size
newFloatingIcon.Size=UDim2 .fromOffset(0,0)
newFloatingIcon.Visible=toggleButtonAllowed()
newWindow.Tabs.Visible=false
newWindow.TabButtons.Visible=false
do local dropShadow=newWindow:FindFirstChild("DropShadow")if dropShadow then pcall(function()dropShadow.Visible=false end)end end
Tween(newFloatingIcon,{Size=oldFloatingSize},TweenConfigs.Global)
Tween(newWindow,{Size=UDim2 .fromOffset(0,0)},TweenConfigs.Global)
.Completed:Wait()
newWindow.Visible=false
windowstate=false
else
if windowstate then
oldWindowSize=newWindow.Size
newFloatingIcon.Size=UDim2 .fromOffset(0,0)
newFloatingIcon.Visible=toggleButtonAllowed()
newWindow.Tabs.Visible=false
newWindow.TabButtons.Visible=false
do local dropShadow=newWindow:FindFirstChild("DropShadow")if dropShadow then pcall(function()dropShadow.Visible=false end)end end
Tween(newFloatingIcon,{Size=oldFloatingSize},TweenConfigs.Global)
Tween(newWindow,{Size=UDim2 .fromOffset(0,0)},TweenConfigs.Global)
.Completed:Wait()
newWindow.Visible=false
windowstate=false
else
oldFloatingSize=newFloatingIcon.Size
newWindow.Size=UDim2 .fromOffset(0,0)
newWindow.Visible=true
do local dropShadow=newWindow:FindFirstChild("DropShadow")if dropShadow then pcall(function()dropShadow.Visible=true end)end end
Tween(newFloatingIcon,{Size=UDim2 .new(0,0,0,0)},TweenConfigs.Global)
Tween(newWindow,{Size=oldWindowSize},TweenConfigs.Global)
.Completed:Wait()
newWindow.Tabs.Visible=true
newWindow.TabButtons.Visible=true
newFloatingIcon.Visible=false
windowstate=true
end
end
end
function Window:Show()
if not startupGatePassed then return end
if not windowstate then ToggleWindow(true)end
end
function Window:Hide()
if not startupGatePassed then return end
if windowstate then ToggleWindow(false)end
end
function Window:Toggle(state)
if not startupGatePassed then return end
ToggleWindow(state)
end
local guiDestroyConnection
function Window:Destroy()
if windowDestroyed then return end
windowDestroyed=true
if _G.__xNgotActiveWindow==self then _G.__xNgotActiveWindow=nil end
if guiDestroyConnection then guiDestroyConnection:Disconnect();guiDestroyConnection=nil end
if touchCleanup then touchCleanup()end
if self.__OphynWindow and self.__OphynWindow.Gui then
pcall(function()self.__OphynWindow.Gui:Destroy()end)
self.__OphynWindow=nil
end
if self.DynamicIsland then
pcall(self.DynamicIsland.Destroy,self.DynamicIsland)
if LIB.ActiveDynamicIsland==self.DynamicIsland then LIB.ActiveDynamicIsland=nil end
self.DynamicIsland=nil
end
themeDestroyed=true
timeout=true
if themeDescendantConnection then themeDescendantConnection:Disconnect();themeDescendantConnection=nil end
if themeVisibilityConnection then themeVisibilityConnection:Disconnect();themeVisibilityConnection=nil end
if liquidBlur and liquidBlur.Parent then liquidBlur:Destroy()end
if keybindConnection then keybindConnection:Disconnect();keybindConnection=nil end
if windowDraggable then windowDraggable:Destroy()end
if floatingDraggable then floatingDraggable:Destroy()end
if windowResizable then windowResizable:Destroy()end
local index=table.find(Windows,newWindow)
if index then table.remove(Windows,index)end
if WindowByTitle[Window.Title]==Window then WindowByTitle[Window.Title]=nil end
if windowFolder and windowFolder.Parent then windowFolder:Destroy()end
end
_G.__xNgotActiveWindow=Window
WindowByTitle[Window.Title]=Window
guiDestroyConnection=Gui.Destroying:Connect(function()if not windowDestroyed then Window:Destroy()end end)
newWindow.TopFrame.Hide.MouseButton1Click:Connect(function()
if not timeout then
timeout=true
ToggleWindow(false)
task.delay(TweenConfigs.Global.Duration,function()
timeout=false
end)
end
end)
newFloatingIcon.Open.MouseButton1Click:Connect(function()
if not timeout then
timeout=true
ToggleWindow(true)
task.delay(TweenConfigs.Global.Duration,function()
timeout=false
end)
end
end)
newWindow.TopFrame.Close.MouseButton1Click:Connect(function()
Window:Dialog({
Icon="triangle-alert",
Title="Close Window",
Content="Do you want to close this window? You will not able to open it again.",
Buttons={
{
Title="Cancel"
},
{
Title="Close Window",
Callback=function()
Window:Destroy()
end,
}
}
})
end)
newWindow.TopFrame.Maximize.MouseButton1Click:Connect(function()
if not maximizedWindow then
windowDraggable:SetAllowDragging(false)
windowResizable:SetAllowResizing(false)
resizeHandle.Visible=false
oldWindowSizeMaximize=newWindow.Size
oldWindowPositionMaximize=newWindow.Position
Tween(newWindow,{Size=UDim2 .new(1,0,1,0)},TweenConfigs.Global)
Tween(newWindow,{Position=UDim2 .new(0.5,0,0.5,0)},TweenConfigs.Global)
Tween(newWindow.UICorner,{CornerRadius=UDim.new(0,0)},TweenConfigs.Global)
maximizedWindow=true
else
windowDraggable:SetAllowDragging(true)
windowResizable:SetAllowResizing(true)
resizeHandle.Visible=true
Tween(newWindow,{Size=oldWindowSizeMaximize},TweenConfigs.Global)
Tween(newWindow,{Position=oldWindowPositionMaximize},TweenConfigs.Global)
if UISettings.Enabled then
Tween(newWindow.UICorner,{CornerRadius=UDim.new(0,UISettings.CornerRadius)},TweenConfigs.Global)
else
local originalCorner=themeBase[newWindow.UICorner]and themeBase[newWindow.UICorner].CornerRadius
Tween(newWindow.UICorner,{CornerRadius=originalCorner or UDim.new(0,10)},TweenConfigs.Global)
end
maximizedWindow=false
end
end)
local startupGateLoading=Window.Loading
local startupGateKey=type(Window.KeySystem)=="table"and Window.KeySystem or nil
local startupGateEnabled=startupGateLoading~=false or(startupGateKey~=nil and startupGateKey.Enabled==true)
if startupGateEnabled and startupGateKey and startupGateKey.Enabled==true and startupGateKey.Style~="Legacy"then
startupGateFinished=false
startupGatePassed=false
newWindow.Visible=false
newFloatingIcon.Visible=false
windowstate=false
function Window:ForgetSavedKey()
local gate=self.__OphynWindow
if gate and type(gate.ForgetSavedKey)=="function"then return gate:ForgetSavedKey()end
local path=startupGateKey.KeyFile or"xNgotLibrary/Keys/key.txt"
if type(delfile)~="function"then return false end
if type(isfile)=="function"then
local ok,exists=pcall(isfile,path)
if ok and not exists then return true end
end
return pcall(delfile,path)
end
task.spawn(function()
local ok,err=xpcall(function()
if windowDestroyed then return end
local ophyn=__xNgotCreateOphyn()
local keyConfig,options={},{}
for k,v in pairs(startupGateKey)do keyConfig[k]=v end
for k,v in pairs(type(startupGateKey.Ophyn)=="table"and startupGateKey.Ophyn or{})do options[k]=v end
local configuredKey=keyConfig.Key
if configuredKey==nil then configuredKey=keyConfig.Keys end
if keyConfig.CaseSensitive~=true and(type(configuredKey)=="string"or type(configuredKey)=="table"and getmetatable(configuredKey)==nil and not configuredKey.__isJnkieInstance and not configuredKey.__isJnkie)then
local list=type(configuredKey)=="string"and{configuredKey}or configuredKey
keyConfig.Key=function(value)
local normalized=tostring(value or""):match("^%s*(.-)%s*$"):lower()
if normalized==""then return false end
for _,item in ipairs(list)do
if type(item)=="table"then item=item.Key or item.key or item.Value end
if type(item)=="string"and item:match("^%s*(.-)%s*$"):lower()==normalized then return true end
end
return false
end
else
keyConfig.Key=configuredKey
end
keyConfig.URL=keyConfig.URL or keyConfig.GetKeyUrl or keyConfig.GetKey or""
if keyConfig.SaveKey==nil then keyConfig.SaveKey=true end
keyConfig.KeyFile=keyConfig.KeyFile or"xNgotLibrary/Keys/key.txt"
Window.KeyFilePath=keyConfig.KeyFile
options.Title=options.Title or keyConfig.Title or Window.Title
options.Description=options.Description or keyConfig.Subtitle or"Key System"
options.Folder=options.Folder or"xNgotLibrary/Keys"
if options.SyncTheme~=false then
local background=UISettings.BackgroundColor or Color3 .fromRGB(37,40,47)
local surface=UISettings.SurfaceColor or Color3 .fromRGB(32,35,41)
local textColor=UISettings.TextColor or Color3 .fromRGB(197,204,219)
local muted=UISettings.MutedTextColor or Color3 .fromRGB(150,155,165)
local accent=UISettings.AccentColor or Color3 .fromRGB(10,135,213)
local surfaceLight=(surface.R*0.299+surface.G*0.587+surface.B*0.114)>0.55
local overlay=surfaceLight and Color3 .new(0,0,0)or Color3 .new(1,1,1)
local accentLight=(accent.R*0.299+accent.G*0.587+accent.B*0.114)>0.55
options.XngotPalette={
bg=background,card=surface,input=surface:Lerp(overlay,0.05),
stroke=surface:Lerp(textColor,0.22),btn2=surface:Lerp(overlay,0.10),
btn2Hover=surface:Lerp(overlay,0.18),text=textColor,muted=muted,accent=accent,
submitBg=accent,submitText=accentLight and Color3 .fromRGB(20,24,30)or Color3 .new(1,1,1),
glowBase=accent,glowFrom=accent:Lerp(Color3 .new(1,1,1),0.35),glowTo=accent,
confetti={accent,accent:Lerp(Color3 .new(1,1,1),0.35),textColor,Color3 .fromRGB(120,210,140)},
}
options.XngotRadius=UISettings.CornerRadius
if options.ChangeTheme==nil then options.ChangeTheme=false end
end
if options.Logo==nil and TopFrame and TopFrame:FindFirstChild("Icon")then
local menuIcon=TopFrame.Icon
if menuIcon.Image~=""then
options.Logo=menuIcon.Image
options.LogoRectOffset=menuIcon.ImageRectOffset
options.LogoRectSize=menuIcon.ImageRectSize
end
end
options.XngotApplyIcon=ApplyIcon
if options.SyncFont~=false then
local chosenFont=options.UIFont
if not chosenFont and UISettings.Font~="Original"then chosenFont=UISettings.Font end
if not chosenFont then
pcall(function()chosenFont=TopFrame.TextLabel.FontFace end)
end
if chosenFont then pcall(function()ophyn:SetUIFont(chosenFont)end)end
if options.TitleFont then pcall(function()ophyn:SetTitleFont(options.TitleFont)end)end
end
options.KeySystem=keyConfig
if keyConfig.Keyless~=nil then options.Keyless=keyConfig.Keyless end
if type(keyConfig.GetMethods)=="table"then
for _,method in ipairs(keyConfig.GetMethods)do ophyn:GetMethod(method)end
end
local userCallback=options.Callback
local accepted=false
options.Callback=function(key)
if windowDestroyed then return end
accepted=true
Window.KeyUnlocked=true
if type(userCallback)=="function"then
local cbOk,cbErr=pcall(userCallback,key)
if not cbOk then warn("[xNgot/Ophyn] Callback: "..tostring(cbErr))end
end
end
local gate=ophyn.new(options)
if windowDestroyed then
if gate and gate.Gui then pcall(function()gate.Gui:Destroy()end)end
return
end
Window.__OphynWindow=gate
gate.Gui.Destroying:Connect(function()
Window.__OphynWindow=nil
if windowDestroyed then return end
if not accepted then Window:Destroy();return end
startupGatePassed=true
newWindow.Size=oldWindowSize
newWindow.Visible=true
if newWindow:FindFirstChild("Tabs")then newWindow.Tabs.Visible=true end
if newWindow:FindFirstChild("TabButtons")then newWindow.TabButtons.Visible=true end
newFloatingIcon.Visible=false
windowstate=true
startupGateFinished=true
releaseStartupIsland()
end)
end,function(e)
return debug and type(debug.traceback)=="function"and debug.traceback(tostring(e),2)or tostring(e)
end)
if not ok then
warn("[xNgot/Ophyn] Startup failed: "..tostring(err))
if LIB.ShowStartupError then pcall(LIB.ShowStartupError,"Ophyn key system failed: "..tostring(err))end
if not windowDestroyed then Window:Destroy()end
end
end)
elseif startupGateEnabled then
startupGateFinished=false
startupGatePassed=false
newWindow.Visible=false
windowstate=false
task.spawn(function()
local function gateMain()
local GateTS=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")
local function gTween(inst,props,dur,style,dir)
local tw=GateTS:Create(inst,TweenInfo.new(dur or 0.25,style or Enum.EasingStyle.Quart,dir or Enum.EasingDirection.Out),props)
tw:Play()
return tw
end
local function mk(class,props)
local obj=Instance.new(class)
for key,value in pairs(props or{})do
if key~="Parent"then obj[key]=value end
end
if props and props.Parent then obj.Parent=props.Parent end
return obj
end
local G_BG=UISettings.BackgroundColor or Color3 .fromRGB(24,27,33)
local G_SURFACE=UISettings.SurfaceColor or Color3 .fromRGB(32,35,41)
local G_S2=G_SURFACE:Lerp(Color3 .fromRGB(255,255,255),0.07)
local G_S3=G_SURFACE:Lerp(Color3 .fromRGB(255,255,255),0.14)
local G_TEXT=UISettings.TextColor or Color3 .fromRGB(240,242,245)
local G_MUTED=UISettings.MutedTextColor or Color3 .fromRGB(150,155,165)
local G_ACCENT=UISettings.AccentColor or Color3 .fromRGB(10,135,213)
local G_STROKE=G_SURFACE:Lerp(G_TEXT,0.22)
local G_ERROR=Color3 .fromRGB(240,120,120)
local G_SUCCESS=Color3 .fromRGB(150,220,170)
local G_RADIUS=math.clamp(tonumber(UISettings.CornerRadius)or 12,8,28)
local G_FONT="rbxassetid://11702779517"
pcall(function()
local menuLabel=TopFrame and TopFrame:FindFirstChild("TextLabel")
if menuLabel and menuLabel.FontFace and menuLabel.FontFace.Family and menuLabel.FontFace.Family~=""then G_FONT=menuLabel.FontFace.Family end
end)
local function gCorner(parent,radius)return mk("UICorner",{CornerRadius=UDim.new(0,radius or G_RADIUS),Parent=parent})end
local function gStroke(parent,color,transparency)
return mk("UIStroke",{Color=color or G_STROKE,Transparency=transparency or 0,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=parent})
end
local function gText(props)
local merged={BackgroundTransparency=1,TextColor3=G_TEXT,TextSize=14,FontFace=Font.new(G_FONT,Enum.FontWeight.Medium),TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd}
for key,value in pairs(props or{})do merged[key]=value end
return mk("TextLabel",merged)
end
local loadCfg=type(startupGateLoading)=="table"and startupGateLoading or{}
local loadTitle=tostring(loadCfg.Title or Window.Title or"xNgot Studio")
local loadText=tostring(loadCfg.Text or"Loading")
local loadSteps=type(loadCfg.Steps)=="table"and loadCfg.Steps or{"Preparing interface","Loading icons","Almost there"}
local loadDuration=math.clamp(tonumber(loadCfg.Duration)or 1.6,0.6,8)
local keyCfg=startupGateKey or{}
local keyHeader=tostring(keyCfg.Title or loadTitle)
local keySubtitle=tostring(keyCfg.Subtitle or"Enter your key to continue")
if keyCfg.Title==nil then keySubtitle="Key System \u{00B7} "..keySubtitle end
local keyNote=tostring(keyCfg.Note or"Your key is saved on this device for next time.")
local keyGetUrl=tostring(keyCfg.GetKeyUrl or keyCfg.GetKey or"")
local keyCaseSensitive=keyCfg.CaseSensitive==true
local keyFilePath=tostring(keyCfg.KeyFile or"xNgotLibrary/Keys/key.txt")
Window.KeyFilePath=keyFilePath
local function keyNorm(val)
val=tostring(val or""):gsub("^%s+",""):gsub("%s+$","")
if not keyCaseSensitive then val=val:lower()end
return val
end
local keyList={}
if type(keyCfg.Key)=="string"then keyList[#keyList+1]=keyCfg.Key end
if type(keyCfg.Keys)=="table"then
for _,kk in ipairs(keyCfg.Keys)do
if type(kk)=="string"then keyList[#keyList+1]=kk
elseif type(kk)=="table"then keyList[#keyList+1]=tostring(kk.Key or kk.key or kk.Value or"")end
end
end
local function keyMatches(input)
local nn=keyNorm(input)
if nn==""then return false end
for _,kk in ipairs(keyList)do if keyNorm(kk)==nn then return true end end
return false
end
local savedKeyOk=false
if type(isfile)=="function"and type(readfile)=="function"then
local okSaved,saved=pcall(function()if isfile(keyFilePath)then return readfile(keyFilePath)end return nil end)
if okSaved and type(saved)=="string"and keyMatches(saved)then savedKeyOk=true end
end
local needKey=startupGateKey~=nil and keyCfg.Enabled==true and not savedKeyOk
if savedKeyOk then Window.KeyUnlocked=true end
function Window:ForgetSavedKey()
if type(delfile)=="function"and type(isfile)=="function"then
return pcall(function()if isfile(keyFilePath)then delfile(keyFilePath)end end)
end
return false
end
local card=mk("CanvasGroup",{Name="xNgotStartupGate",AnchorPoint=Vector2 .new(0.5,0.5),Position=UDim2 .new(0.5,0,0.5,16),Size=UDim2 .fromOffset(300,132),BackgroundColor3=G_BG,BorderSizePixel=0,GroupTransparency=1,ZIndex=100,Parent=windowFolder})
Window.__startupGateCard=card
local cardCorner=gCorner(card,G_RADIUS)
local cardStroke=gStroke(card,G_STROKE,0)
mk("Frame",{Position=UDim2 .fromOffset(0,0),Size=UDim2 .new(1,0,0,1),BackgroundColor3=Color3 .new(1,1,1),BackgroundTransparency=0.93,BorderSizePixel=0,ZIndex=1,Parent=card})
local function addGlow(size,pos,transparency,rotation)
local glow=mk("ImageLabel",{AnchorPoint=Vector2 .new(0.5,0.5),Position=pos,Size=size,BackgroundTransparency=1,Image="rbxassetid://8992230677",ImageColor3=G_ACCENT:Lerp(Color3 .new(1,1,1),0.45),ImageTransparency=transparency,ZIndex=0,Parent=card})
mk("UIGradient",{Color=ColorSequence.new(Color3 .fromRGB(255,255,255),G_ACCENT),Rotation=rotation or 90,Parent=glow})
return glow
end
addGlow(UDim2 .fromOffset(320,140),UDim2 .new(1,-20,0,-20),0.85,90)
addGlow(UDim2 .fromOffset(240,100),UDim2 .new(0,10,1,10),0.9,270)
local cardScale=mk("UIScale",{Scale=0.92,Parent=card})
local shadow=mk("ImageLabel",{Position=UDim2 .fromOffset(-25,-25),Size=UDim2 .new(1,50,1,50),BackgroundTransparency=1,Image="rbxassetid://6014261993",ImageColor3=Color3 .new(0,0,0),ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=0,Parent=card})
pcall(function()
local winShadow=newWindow and newWindow:FindFirstChild("DropShadow")
if winShadow and winShadow:IsA("ImageLabel")and winShadow.Image and winShadow.Image~=""then
shadow.Image=winShadow.Image
shadow.ScaleType=winShadow.ScaleType
shadow.SliceCenter=winShadow.SliceCenter
shadow.ImageColor3=winShadow.ImageColor3
end
end)
local iconHolder=mk("Frame",{Position=UDim2 .fromOffset(24,26),Size=UDim2 .fromOffset(40,40),BackgroundTransparency=1,ZIndex=3,Parent=card})
local iconImg=mk("ImageLabel",{AnchorPoint=Vector2 .new(0.5,0.5),Position=UDim2 .fromScale(0.5,0.5),Size=UDim2 .fromScale(0.5,0.5),Rotation=-14,BackgroundTransparency=1,ImageColor3=G_ACCENT,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=3,Parent=iconHolder})
local menuIconSource=TopFrame and TopFrame:FindFirstChild("Icon")
if menuIconSource then
iconImg.Image=menuIconSource.Image
iconImg.ImageRectOffset=menuIconSource.ImageRectOffset
iconImg.ImageRectSize=menuIconSource.ImageRectSize
iconImg.ImageColor3=menuIconSource.ImageColor3
else
ApplyIcon(iconImg,Window.Icon)
end
local loaderGroup=mk("CanvasGroup",{Size=UDim2 .fromScale(1,1),BackgroundTransparency=1,GroupTransparency=0,ZIndex=4,Parent=card})
gText({Position=UDim2 .fromOffset(78,30),Size=UDim2 .new(1,-100,0,22),Text=loadTitle,TextSize=20,FontFace=Font.new(G_FONT,Enum.FontWeight.SemiBold),Parent=loaderGroup})
local loadStatus=gText({Position=UDim2 .fromOffset(78,52),Size=UDim2 .new(1,-100,0,16),Text=savedKeyOk and"Saved key found"or loadText,TextSize=13,FontFace=Font.new(G_FONT,Enum.FontWeight.Regular),TextColor3=G_MUTED,Parent=loaderGroup})
local track=mk("Frame",{Position=UDim2 .new(0,24,1,-30),Size=UDim2 .new(1,-48,0,4),BackgroundColor3=G_S3,BorderSizePixel=0,ClipsDescendants=true,ZIndex=4,Parent=loaderGroup})
gCorner(track,999)
local fill=mk("Frame",{Size=UDim2 .fromScale(0,1),BackgroundColor3=G_ACCENT,BorderSizePixel=0,ZIndex=4,Parent=track})
gCorner(fill,999)
local shimmer=mk("Frame",{Position=UDim2 .fromScale(-0.4,0),Size=UDim2 .fromScale(0.4,1),BackgroundColor3=Color3 .new(1,1,1),BackgroundTransparency=0.6,BorderSizePixel=0,ZIndex=5,Parent=track})
mk("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)}),Parent=shimmer})
local keyGroup=mk("CanvasGroup",{Size=UDim2 .fromScale(1,1),BackgroundTransparency=1,GroupTransparency=1,Visible=false,ZIndex=4,Parent=card})
gText({Position=UDim2 .fromOffset(78,24),Size=UDim2 .new(1,-102,0,22),Text=keyHeader,TextSize=18,FontFace=Font.new(G_FONT,Enum.FontWeight.SemiBold),Parent=keyGroup})
local keyStatus=gText({Position=UDim2 .fromOffset(78,47),Size=UDim2 .new(1,-102,0,16),Text=keySubtitle,TextSize=12,FontFace=Font.new(G_FONT,Enum.FontWeight.Regular),TextColor3=G_MUTED,Parent=keyGroup})
local inputBox=mk("Frame",{Position=UDim2 .fromOffset(24,86),Size=UDim2 .new(1,-48,0,42),BackgroundColor3=G_S2,BorderSizePixel=0,ClipsDescendants=true,ZIndex=4,Parent=keyGroup})
gCorner(inputBox,math.max(4,G_RADIUS-4))
local inputStroke=gStroke(inputBox,G_STROKE,0)
local keyInput=mk("TextBox",{Position=UDim2 .fromOffset(10,0),Size=UDim2 .new(1,-20,1,0),BackgroundTransparency=1,PlaceholderText="Enter your key...",PlaceholderColor3=G_MUTED,Text="",TextColor3=G_TEXT,TextSize=14,FontFace=Font.new(G_FONT,Enum.FontWeight.Regular),TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ClipsDescendants=true,ZIndex=4,Parent=inputBox})
local hasGetKey=keyGetUrl~=""
local enterBtn=mk("TextButton",{Position=UDim2 .fromOffset(24,140),Size=hasGetKey and UDim2 .new(1,-168,0,38)or UDim2 .new(1,-48,0,38),BackgroundColor3=G_ACCENT,BackgroundTransparency=0.12,BorderSizePixel=0,AutoButtonColor=false,FontFace=Font.new(G_FONT,Enum.FontWeight.SemiBold),Text="Enter",TextSize=13,TextColor3=G_BG,ZIndex=4,Parent=keyGroup})
gCorner(enterBtn,math.max(4,G_RADIUS-4))
local enterStroke=gStroke(enterBtn,G_ACCENT,0.4)
enterBtn.MouseEnter:Connect(function()gTween(enterBtn,{BackgroundTransparency=0},0.12)gTween(enterStroke,{Transparency=0},0.12)end)
enterBtn.MouseLeave:Connect(function()gTween(enterBtn,{BackgroundTransparency=0.12},0.25)gTween(enterStroke,{Transparency=0.4},0.25)end)
local getBtn=nil
if hasGetKey then
getBtn=mk("TextButton",{Position=UDim2 .new(1,-128,0,140),Size=UDim2 .fromOffset(104,38),BackgroundColor3=G_S3,BorderSizePixel=0,AutoButtonColor=false,FontFace=Font.new(G_FONT,Enum.FontWeight.Medium),Text="Get Key",TextSize=12,TextColor3=G_TEXT,ZIndex=4,Parent=keyGroup})
gCorner(getBtn,math.max(4,G_RADIUS-4))
gStroke(getBtn,G_STROKE,0)
end
gText({Position=UDim2 .fromOffset(24,192),Size=UDim2 .new(1,-48,0,16),Text=keyNote,TextSize=11,FontFace=Font.new(G_FONT,Enum.FontWeight.Regular),TextColor3=G_MUTED,Parent=keyGroup})
local gateDone,gateBusy=false,false
local function shakeCard()
task.spawn(function()
for _,dx in ipairs({-10,10,-6,6,0})do
if not card.Parent then return end
gTween(card,{Position=UDim2 .new(0.5,dx,0.5,0)},0.05,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut):Wait()
end
gTween(card,{Position=UDim2 .fromScale(0.5,0.5)},0.05)
end)
end
local function submitKey()
if gateBusy or gateDone then return end
gateBusy=true
if keyMatches(keyInput.Text)then
Window.KeyUnlocked=true
if type(writefile)=="function"then pcall(writefile,keyFilePath,keyNorm(keyInput.Text))end
inputStroke.Color=G_SUCCESS
keyStatus.TextColor3=G_SUCCESS
keyStatus.Text="Key accepted - welcome!"
enterBtn.Text="Success"
gateDone=true
else
Window.KeyAttempts=(Window.KeyAttempts or 0)+1
inputStroke.Color=G_ERROR
keyStatus.TextColor3=G_ERROR
keyStatus.Text=string.format("Invalid key - try again (%d attempt%s)",Window.KeyAttempts,Window.KeyAttempts==1 and""or"s")
keyInput.Text=""
shakeCard()
task.delay(1.2,function()if not gateDone and inputStroke.Parent then inputStroke.Color=G_STROKE end end)
end
gateBusy=false
end
enterBtn.MouseButton1Click:Connect(submitKey)
keyInput.FocusLost:Connect(function(enterPressed)if enterPressed then submitKey()end end)
keyInput.Focused:Connect(function()if not gateDone then gTween(inputStroke,{Color=G_ACCENT},0.15)end end)
if getBtn then
getBtn.MouseButton1Click:Connect(function()
local copied=false
if type(setclipboard)=="function"then copied=pcall(setclipboard,keyGetUrl)end
keyStatus.TextColor3=G_MUTED
keyStatus.Text=copied and"Key link copied to clipboard"or keyGetUrl
end)
end
gTween(card,{GroupTransparency=0,Position=UDim2 .fromScale(0.5,0.5)},0.4,Enum.EasingStyle.Quint)
gTween(cardScale,{Scale=1},0.5,Enum.EasingStyle.Back)
gTween(shadow,{ImageTransparency=0.6},0.4)
task.delay(0.15,function()
if not card.Parent then return end
gTween(iconImg,{Size=UDim2 .fromScale(0.85,0.85),Rotation=0},0.6,Enum.EasingStyle.Back)
gTween(iconImg,{ImageTransparency=0},0.4)
end)
local shimmerTween=GateTS:Create(shimmer,TweenInfo.new(1.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1),{Position=UDim2 .fromScale(1,0)})
shimmerTween:Play()
local assetList,seenAssets={},{}
local totalAssets,loadedAssets,pendingBatches=0,0,0
local function queueAssets(list)
local batch={}
for _,id in ipairs(list or{})do
if type(id)=="string"and id~=""and id~="rbxassetid://0"and not seenAssets[id]then
seenAssets[id]=true
batch[#batch+1]=id
end
end
if#batch==0 then return end
totalAssets=totalAssets+#batch
pendingBatches=pendingBatches+1
task.spawn(function()
pcall(function()ContentProvider:PreloadAsync(batch,function()loadedAssets=loadedAssets+1 end)end)
pendingBatches=pendingBatches-1
end)
end
local function addAsset(id)assetList[#assetList+1]=id end
for _,sheet in ipairs({
"rbxassetid://131526378523863","rbxassetid://98656588890340","rbxassetid://122516128999742",
"rbxassetid://136045238860745","rbxassetid://138056954680929","rbxassetid://139241675471365",
"rbxassetid://120281540002144","rbxassetid://122481504913348","rbxassetid://125136326597802",
"rbxassetid://132619645919851","rbxassetid://124546836680911","rbxassetid://138714413596023",
"rbxassetid://95318701976229","rbxassetid://87465848394141","rbxassetid://77771201330939",
"rbxassetid://126006375824005",
})do addAsset(sheet)end
for _,asset in ipairs({
"rbxassetid://113216930555884","rbxassetid://132453323679056","rbxassetid://108285848026510",
"rbxassetid://120292618616139","rbxassetid://122219713887461","rbxassetid://128209591224511",
"rbxassetid://77563793724007","rbxassetid://86928976705683","rbxassetid://91877599529856",
"rbxassetid://92049322344253","rbxassetid://91415671397056",
"rbxassetid://6014261993","rbxassetid://8992230677","rbxassetid://11702779517",
"rbxasset://sounds/button.wav","rbxasset://sounds/switch.wav","rbxasset://sounds/electronicpingshort.wav",
"rbxasset://sounds/clickfast.wav","rbxasset://sounds/snap.wav",
})do addAsset(asset)end
pcall(function()
local iconData=IconModule.Icon(Window.Icon)
if type(iconData)=="table"and iconData[1]then addAsset(tostring(iconData[1]))end
end)
pcall(function()
local plrs=game:GetService("Players")
local lp=plrs.LocalPlayer
if lp then addAsset(plrs:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420))end
end)
pcall(function()
if game.GameId and game.GameId~=0 then addAsset("rbxthumb://type=GameIcon&id="..tostring(game.GameId).."&w=150&h=150")end
end)
queueAssets(assetList)
local function scanGuiAssets()
local found={}
pcall(function()
for _,inst in ipairs(Gui:GetDescendants())do
if inst:IsA("ImageLabel")or inst:IsA("ImageButton")then
found[#found+1]=inst.Image
if inst:IsA("ImageButton")then
found[#found+1]=inst.HoverImage
found[#found+1]=inst.PressedImage
end
elseif inst:IsA("Sound")then
found[#found+1]=inst.SoundId
end
if inst:IsA("TextLabel")or inst:IsA("TextButton")or inst:IsA("TextBox")then
local ff=inst.FontFace
if ff and type(ff.Family)=="string"and ff.Family~=""then found[#found+1]=ff.Family end
end
end
end)
queueAssets(found)
end
scanGuiAssets()
local steps=savedKeyOk and{"Preparing interface","Saved key found","Welcome back"}or loadSteps
local loadStart=os.clock()
local lastScan=0
local minLoadTime=math.max(loadDuration,2.2)
while true do
if windowDestroyed or not card.Parent then return end
local frac=math.clamp(loadedAssets/math.max(totalAssets,1),0,1)
gTween(fill,{Size=UDim2 .fromScale(0.85*math.max(frac,0.08),1)},0.25,Enum.EasingStyle.Quart)
local stepText=steps[math.clamp(math.floor(frac*#steps)+1,1,#steps)]
if loadStatus.Text~=stepText then loadStatus.Text=stepText end
local elapsed=os.clock()-loadStart
if elapsed-lastScan>=0.45 then lastScan=elapsed scanGuiAssets()end
if(pendingBatches<=0 and elapsed>=minLoadTime)or elapsed>=9 then break end
task.wait(0.12)
end
gTween(fill,{Size=UDim2 .fromScale(1,1)},0.25,Enum.EasingStyle.Quint)
task.wait(0.25)
if windowDestroyed or not card.Parent then return end
shimmerTween:Cancel()
gTween(loaderGroup,{GroupTransparency=1},0.15)
task.wait(0.15)
if windowDestroyed or not card.Parent then return end
if needKey then
loaderGroup.Visible=false
keyGroup.Visible=true
local keyWidth=340
pcall(function()local abs=Gui.AbsoluteSize if abs and abs.X>40 then keyWidth=math.min(340,abs.X-24)end end)
gTween(card,{Size=UDim2 .fromOffset(keyWidth,232)},0.5,Enum.EasingStyle.Quint)
gTween(cardCorner,{CornerRadius=UDim.new(0,G_RADIUS)},0.5,Enum.EasingStyle.Quint)
task.wait(0.3)
if windowDestroyed or not card.Parent then return end
gTween(keyGroup,{GroupTransparency=0},0.25)
pcall(function()keyInput:CaptureFocus()end)
while not gateDone do
if windowDestroyed or not card.Parent then return end
task.wait(0.1)
end
task.wait(0.5)
if windowDestroyed or not card.Parent then return end
gTween(keyGroup,{GroupTransparency=1},0.2)
end
task.wait(0.15)
if windowDestroyed or not card.Parent then return end
gTween(card,{Size=UDim2 .fromOffset(oldWindowSize.X.Offset,oldWindowSize.Y.Offset),Position=UDim2 .fromScale(0.5,0.5)},0.5,Enum.EasingStyle.Quint)
gTween(cardCorner,{CornerRadius=UDim.new(0,G_RADIUS)},0.5,Enum.EasingStyle.Quint)
gTween(cardScale,{Scale=1},0.5,Enum.EasingStyle.Quint)
task.wait(0.28)
if windowDestroyed or not card.Parent then return end
startupGatePassed=true
newWindow.Size=oldWindowSize
newWindow.Visible=true
do local dropShadow=newWindow:FindFirstChild("DropShadow")if dropShadow then pcall(function()dropShadow.Visible=true end)end end
if newWindow:FindFirstChild("Tabs")then newWindow.Tabs.Visible=true end
if newWindow:FindFirstChild("TabButtons")then newWindow.TabButtons.Visible=true end
newFloatingIcon.Visible=false
windowstate=true
if type(Window.RefreshAdminAvatar)=="function"then pcall(function()Window:RefreshAdminAvatar()end)end
gTween(card,{GroupTransparency=1},0.25)
gTween(cardStroke,{Transparency=1},0.2)
gTween(shadow,{ImageTransparency=1},0.2)
task.wait(0.6)
if card.Parent then card:Destroy()end
startupGateFinished=true
releaseStartupIsland()
end
local gateOk,gateErr=xpcall(gateMain,function(err)
if debug and type(debug.traceback)=="function"then return debug.traceback(tostring(err),2)end
return tostring(err)
end)
if not gateOk then
warn("[xNgotStudio] Startup gate error (da tu mo cua so): "..tostring(gateErr))
startupGatePassed=true
Window.KeyUnlocked=true
if Window.__startupGateCard and Window.__startupGateCard.Parent then Window.__startupGateCard:Destroy()end
newWindow.Size=oldWindowSize
newWindow.Visible=true
windowstate=true
startupGateFinished=true
releaseStartupIsland()
end
end)
else
Tween(newWindow,{Size=oldWindowSize},TweenConfigs.Global)
end
keybindConnection=UIS.InputBegan:Connect(function(input,gpe)
if windowDestroyed then return end
if not timeout and not gpe and startupGatePassed and input.KeyCode==Window.ToggleKey then
timeout=true
ToggleWindow()
task.delay(TweenConfigs.Global.Duration,function()
timeout=false
end)
end
end)
function Window:GetDynamicIsland()
return self.DynamicIsland
end
function Window:NotifyIsland(title,message,kind,duration)
local api=self.DynamicIsland
if not api or type(api.Notify)~="function"then return false end
local ok,result=pcall(api.Notify,api,title,message,kind,duration)
return ok and result==true
end
function Window:IslandActivity(title,message,duration,kind)
local api=self.DynamicIsland
if not api or type(api.GameplayActivity)~="function"then return false end
local ok,result=pcall(api.GameplayActivity,api,title,message,duration,kind)
return ok and result==true
end
if Window.SettingsUI then
settingsBuilding=true
CONFIG[Window.SettingsTitle]={}
local settingsDivider=Templates.Divider:Clone()
settingsDivider.Name="SettingsUiDivider"
settingsDivider.LayoutOrder=99999
settingsDivider.Parent=newWindow.TabButtons.Lists
settingsDivider.Visible=true
local SettingsTab=Window:Tab({Title=Window.SettingsTitle,Icon=Window.SettingsIcon,__System=true})
Window.SettingsTab=SettingsTab
do
local function buildHomeDashboard()
local homePlayers=game:GetService("Players")
local homePlayer=homePlayers and homePlayers.LocalPlayer
if homePlayer then
local homeRunService=game:GetService("RunService")
local homeTeleport=game:GetService("TeleportService")
local homeMarketplace=game:GetService("MarketplaceService")
local homeHttp=game:GetService("HttpService")
local homeHttpGet
local HOME_SURFACE=UISettings.SurfaceColor or Color3 .fromRGB(32,35,41)
local HOME_CARD=HOME_SURFACE:Lerp(Color3 .fromRGB(255,255,255),0.05)
local HOME_CARD2=HOME_SURFACE:Lerp(Color3 .fromRGB(255,255,255),0.11)
local HOME_TEXT=UISettings.TextColor or Color3 .fromRGB(243,243,238)
local HOME_MUTED=UISettings.MutedTextColor or Color3 .fromRGB(150,155,165)
local HOME_ACCENT=UISettings.AccentColor or Color3 .fromRGB(10,135,213)
local HOME_STROKE=HOME_SURFACE:Lerp(HOME_TEXT,0.22)
local HOME_BAR=Color3 .fromRGB(55,190,255)
local HOME_BAR2=Color3 .fromRGB(255,165,75)
local HOME_HISTORY=60
local HOME_RADIUS=math.clamp(tonumber(UISettings.CornerRadius)or 10,6,28)
local function homeCorner(parent,radius)
local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(0,radius or 12)
c.Parent=parent
return c
end
local function homeStroke(parent)
local st=Instance.new("UIStroke")
st.Color=HOME_STROKE
st.Thickness=1
st.Parent=parent
return st
end
local function homeLabel(parent,text,size,color,bold)
local label=Instance.new("TextLabel")
label.BackgroundTransparency=1
label.FontFace=Font.new("rbxassetid://11702779517",bold and Enum.FontWeight.Bold or Enum.FontWeight.Medium,Enum.FontStyle.Normal)
label.Text=tostring(text or"")
label.TextSize=size or 13
label.TextColor3=color or HOME_TEXT
label.TextTransparency=(color~=nil and color==HOME_MUTED)and 0.3 or 0
label.TextXAlignment=Enum.TextXAlignment.Left
label.TextYAlignment=Enum.TextYAlignment.Center
label.Parent=parent
return label
end
local function homeFrame(parent,bg)
local f=Instance.new("Frame")
f.BackgroundColor3=bg or HOME_CARD
f.BorderSizePixel=0
f.Parent=parent
return f
end
local function homeCard(parent,height,order)
local card=homeFrame(parent,HOME_CARD)
card.Size=UDim2 .new(1,0,0,height)
card.LayoutOrder=order or 1
card.Name="HomeCard"
homeCorner(card,HOME_RADIUS+4)
homeStroke(card)
return card
end
local function homeButton(parent,text,order)
local b=Instance.new("TextButton")
b.AutoButtonColor=false
b.BackgroundColor3=HOME_CARD2
b.BorderSizePixel=0
b.FontFace=Font.new("rbxassetid://11702779517",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
b.Text=tostring(text or"")
b.TextSize=12
b.TextColor3=HOME_TEXT
b.LayoutOrder=order or 1
b.Name="HomeButton"
homeCorner(b,math.max(4,HOME_RADIUS-2))
homeStroke(b)
local homeBtnBg=b.BackgroundColor3
b.MouseEnter:Connect(function()Tween(b,{BackgroundColor3=homeBtnBg:Lerp(HOME_ACCENT,0.22)},TweenConfigs.Global)end)
b.MouseLeave:Connect(function()Tween(b,{BackgroundColor3=homeBtnBg},TweenConfigs.Global)end)
b.Parent=parent
return b
end
local homeRoot=Instance.new("Frame")
homeRoot.Name="ExampleHomeDashboard"
homeRoot.BackgroundTransparency=1
homeRoot.Size=UDim2 .new(1,0,0,0)
homeRoot.AutomaticSize=Enum.AutomaticSize.Y
homeRoot.LayoutOrder=-100
homeRoot.Parent=SettingsTab._Container
local homeRootLayout=Instance.new("UIListLayout")
homeRootLayout.Padding=UDim.new(0,10)
homeRootLayout.SortOrder=Enum.SortOrder.LayoutOrder
homeRootLayout.Parent=homeRoot
Window.HomeDashboard=homeRoot
local homeHeader=homeFrame(homeRoot,HOME_CARD)
homeHeader.BackgroundTransparency=1
homeHeader.Size=UDim2 .new(1,0,0,32)
homeHeader.LayoutOrder=1
local homeTitle=homeLabel(homeHeader,"Welcome to "..tostring(Window.Title).."!",19,HOME_TEXT,true)
homeTitle.Size=UDim2 .new(1,-112,1,0)
homeTitle.TextTruncate=Enum.TextTruncate.AtEnd
local homeRefreshBtn=homeButton(homeHeader,"Refresh",1)
homeRefreshBtn.AnchorPoint=Vector2 .new(1,0.5)
homeRefreshBtn.Position=UDim2 .new(1,0,0.5,0)
homeRefreshBtn.Size=UDim2 .new(0,100,0,28)
local profileCard=homeCard(homeRoot,114,2)
local profileText=homeFrame(profileCard,HOME_CARD)
profileText.BackgroundTransparency=1
profileText.Position=UDim2 .new(0,14,0,10)
profileText.Size=UDim2 .new(1,-122,1,-20)
local welcomeLabel=homeLabel(profileText,"WELCOME BACK",11,HOME_MUTED,true)
welcomeLabel.Size=UDim2 .new(1,0,0,14)
local playerNameLabel=homeLabel(profileText,homePlayer.DisplayName,20,HOME_TEXT,true)
playerNameLabel.Position=UDim2 .new(0,0,0,15)
playerNameLabel.Size=UDim2 .new(1,0,0,26)
playerNameLabel.TextTruncate=Enum.TextTruncate.AtEnd
local playerUserLabel=homeLabel(profileText,"@"..homePlayer.Name,13,HOME_MUTED,false)
playerUserLabel.Position=UDim2 .new(0,0,0,43)
playerUserLabel.Size=UDim2 .new(1,0,0,18)
playerUserLabel.TextTruncate=Enum.TextTruncate.AtEnd
local chipRow=homeFrame(profileText,HOME_CARD)
chipRow.BackgroundTransparency=1
chipRow.Position=UDim2 .new(0,0,0,76)
chipRow.Size=UDim2 .new(1,0,0,26)
local chipLayout=Instance.new("UIListLayout")
chipLayout.FillDirection=Enum.FillDirection.Horizontal
chipLayout.Padding=UDim.new(0,6)
chipLayout.SortOrder=Enum.SortOrder.LayoutOrder
chipLayout.Parent=chipRow
local function homeChip(text,order,isButton)
local chip=Instance.new(isButton and"TextButton"or"TextLabel")
chip.BackgroundColor3=HOME_CARD2
chip.BorderSizePixel=0
chip.FontFace=Font.new("rbxassetid://11702779517",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
chip.Text=tostring(text or"")
chip.TextSize=11
chip.TextColor3=HOME_TEXT
chip.AutomaticSize=Enum.AutomaticSize.X
chip.Size=UDim2 .new(0,0,0,24)
chip.LayoutOrder=order or 1
chip.Name="HomeChip"
if isButton then chip.AutoButtonColor=false end
homeCorner(chip,math.max(4,HOME_RADIUS-4))
local cp=Instance.new("UIPadding")
cp.PaddingLeft=UDim.new(0,9)
cp.PaddingRight=UDim.new(0,9)
cp.Parent=chip
chip.Parent=chipRow
return chip
end
local versionText=tostring(Window.Version or"")
if#versionText>18 then versionText=versionText:sub(1,18).."..."end
homeChip(versionText~=""and versionText or"Release",1,false)
local nameChip=homeChip("Name",2,true)
local avatarChip=homeChip("Avatar",3,true)
local homeAvatar=Instance.new("ImageLabel")
homeAvatar.Name="PlayerAvatar"
homeAvatar.AnchorPoint=Vector2 .new(1,0)
homeAvatar.Position=UDim2 .new(1,-10,0,11)
homeAvatar.Size=UDim2 .new(0,92,0,92)
homeAvatar.BackgroundColor3=HOME_CARD2
homeAvatar.ScaleType=Enum.ScaleType.Fit
homeCorner(homeAvatar,HOME_RADIUS)
homeStroke(homeAvatar)
homeAvatar.Parent=profileCard
local avatarMode="Avatar"
local function homeAvatarUrl(mode)
return"rbxthumb://type="..mode.."&id="..tostring(homePlayer.UserId).."&w=420&h=420"
end
local function homeSetAvatar(mode)
avatarMode=mode
local okThumb,content=pcall(function()
return homePlayers:GetUserThumbnailAsync(homePlayer.UserId,mode=="AvatarHeadShot"and Enum.ThumbnailType.HeadShot or Enum.ThumbnailType.Avatar,Enum.ThumbnailSize.Size420x420)
end)
if okThumb and type(content)=="string"and content~=""then
homeAvatar.Image=content
else
homeAvatar.Image=homeAvatarUrl(mode)
end
local wantedMode=mode
task.spawn(function()
local deadline=os.clock()+3
while os.clock()<deadline and avatarMode==wantedMode and not homeAvatar.IsLoaded and homeAvatar.Parent do task.wait(0.1)end
if avatarMode~=wantedMode or homeAvatar.IsLoaded or not homeAvatar.Parent then return end
if type(homeHttpGet)~="function"or type(writefile)~="function"then return end
local customAsset=getcustomasset or getsynasset
if type(customAsset)~="function"then return end
local apiUrl=wantedMode=="AvatarHeadShot"
and("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..tostring(homePlayer.UserId).."&size=420x420&format=Png&isCircular=false")
or("https://thumbnails.roblox.com/v1/users/avatar?userIds="..tostring(homePlayer.UserId).."&size=420x420&format=Png&isCircular=false")
local apiBody=homeHttpGet(apiUrl)
local imageUrl=type(apiBody)=="string"and apiBody:match('"imageUrl"%s*:%s*"(https://[^"]+)"')or nil
if not imageUrl then return end
imageUrl=imageUrl:gsub("\\/","/")
local bytes=homeHttpGet(imageUrl)
if type(bytes)~="string"or#bytes<64 then return end
local ext=nil
if bytes:sub(1,8)=="\137PNG\r\n\26\n"then ext="png"elseif bytes:sub(1,3)=="\255\216\255"then ext="jpg"end
if not ext then return end
local path="xNgotLibrary/Avatars/PlayerAvatar_"..wantedMode.."."..ext
if not pcall(writefile,path,bytes)then return end
local okAsset,asset=pcall(customAsset,path)
if okAsset and type(asset)=="string"and asset~=""and avatarMode==wantedMode and homeAvatar.Parent then
homeAvatar.Image=asset
end
end)
end
homeSetAvatar(avatarMode)
nameChip.MouseButton1Click:Connect(function()
playerUserLabel.Visible=not playerUserLabel.Visible
end)
avatarChip.MouseButton1Click:Connect(function()
homeSetAvatar(avatarMode=="Avatar"and"AvatarHeadShot"or"Avatar")
end)
local statsCard=homeCard(homeRoot,172,3)
local statsRow=homeFrame(statsCard,HOME_CARD)
statsRow.BackgroundTransparency=1
statsRow.Position=UDim2 .new(0,12,0,10)
statsRow.Size=UDim2 .new(1,-24,0,102)
local statsLayout=Instance.new("UIListLayout")
statsLayout.FillDirection=Enum.FillDirection.Horizontal
statsLayout.Padding=UDim.new(0,14)
statsLayout.SortOrder=Enum.SortOrder.LayoutOrder
statsLayout.Parent=statsRow
local function homeStatCell(order,title)
local cell=homeFrame(statsRow,HOME_CARD)
cell.BackgroundTransparency=1
cell.Size=UDim2 .new(0.5,-7,1,0)
cell.LayoutOrder=order
local head=homeLabel(cell,title,11,HOME_MUTED,true)
head.Size=UDim2 .new(0.3,0,0,14)
local meta=homeLabel(cell,"",10,HOME_MUTED,false)
meta.AnchorPoint=Vector2 .new(1,0)
meta.Position=UDim2 .new(1,0,0,0)
meta.Size=UDim2 .new(0.85,0,0,14)
meta.TextXAlignment=Enum.TextXAlignment.Right
local value=homeLabel(cell,"--",22,HOME_TEXT,true)
value.Position=UDim2 .new(0,0,0,15)
value.Size=UDim2 .new(1,0,0,28)
local graph=homeFrame(cell,HOME_CARD)
graph.Name="HomeGraph"
graph.BackgroundTransparency=1
graph.Position=UDim2 .new(0,0,1,-54)
graph.Size=UDim2 .new(1,0,0,50)
graph.ClipsDescendants=true
local lines={}
for i=1,HOME_HISTORY-1 do
local line=homeFrame(graph,HOME_BAR)
line.AnchorPoint=Vector2 .new(0.5,0.5)
line.Name="HomeBar"
line.Visible=false
homeCorner(line,2)
lines[i]=line
end
return value,meta,lines,head
end
local fpsValue,fpsMeta,fpsBars,fpsHead=homeStatCell(1,"FPS")
local pingValue,pingMeta,pingBars,pingHead=homeStatCell(2,"Ping")
fpsValue.Name,fpsHead.Name="HomeFpsText","HomeFpsText"
pingValue.Name,pingHead.Name="HomePingText","HomePingText"
fpsValue.TextColor3,fpsHead.TextColor3=HOME_BAR,HOME_BAR
pingValue.TextColor3,pingHead.TextColor3=HOME_BAR2,HOME_BAR2
fpsHead.TextTransparency,pingHead.TextTransparency=0,0
for _,line in ipairs(pingBars)do line.BackgroundColor3=HOME_BAR2;line.Name="HomeBarPing"end
local statsRow2=homeFrame(statsCard,HOME_CARD)
statsRow2 .BackgroundTransparency=1
statsRow2 .Position=UDim2 .new(0,12,1,-46)
statsRow2 .Size=UDim2 .new(1,-24,0,38)
local statsLayout2=Instance.new("UIListLayout")
statsLayout2 .FillDirection=Enum.FillDirection.Horizontal
statsLayout2 .Padding=UDim.new(0,14)
statsLayout2 .SortOrder=Enum.SortOrder.LayoutOrder
statsLayout2 .Parent=statsRow2
local function homeInfoCell(order)
local cell=homeFrame(statsRow2,HOME_CARD)
cell.BackgroundTransparency=1
cell.Size=UDim2 .new(0.5,-7,1,0)
cell.LayoutOrder=order
local value=homeLabel(cell,"--",15,HOME_TEXT,true)
value.Size=UDim2 .new(1,0,0,19)
local caption=homeLabel(cell,"",11,HOME_MUTED,false)
caption.Position=UDim2 .new(0,0,0,20)
caption.Size=UDim2 .new(1,0,0,15)
return value,caption
end
local playersValue,playersCaption=homeInfoCell(1)
playersCaption.Text="Players"
local sessionValue,sessionCaption=homeInfoCell(2)
sessionCaption.Text="Session"
local gameCard=homeCard(homeRoot,148,4)
local gameIcon=Instance.new("ImageLabel")
gameIcon.Name="GameIcon"
gameIcon.Position=UDim2 .new(0,14,0,14)
gameIcon.Size=UDim2 .new(0,44,0,44)
gameIcon.BackgroundColor3=HOME_CARD2
gameIcon.ScaleType=Enum.ScaleType.Crop
gameIcon.Image=""
homeCorner(gameIcon,math.max(4,HOME_RADIUS-2))
gameIcon.Parent=gameCard
local gameNameLabel=homeLabel(gameCard,"Loading game info...",14,HOME_TEXT,true)
gameNameLabel.Position=UDim2 .new(0,68,0,15)
gameNameLabel.Size=UDim2 .new(1,-82,0,20)
gameNameLabel.TextTruncate=Enum.TextTruncate.AtEnd
local gameMetaLabel=homeLabel(gameCard,"",11,HOME_MUTED,false)
gameMetaLabel.Position=UDim2 .new(0,68,0,37)
gameMetaLabel.Size=UDim2 .new(1,-82,0,16)
gameMetaLabel.TextTruncate=Enum.TextTruncate.AtEnd
local serverRow=homeFrame(gameCard,HOME_CARD)
serverRow.BackgroundTransparency=1
serverRow.Position=UDim2 .new(0,12,0,62)
serverRow.Size=UDim2 .new(1,-24,0,56)
local serverLayout=Instance.new("UIListLayout")
serverLayout.FillDirection=Enum.FillDirection.Horizontal
serverLayout.Padding=UDim.new(0,8)
serverLayout.SortOrder=Enum.SortOrder.LayoutOrder
serverLayout.Parent=serverRow
local function homeIconButton(name,iconName,order)
local button=homeButton(serverRow,"",order)
button:SetAttribute("Action",name)
local icon=Instance.new("ImageLabel")
icon.Name="HomeActionIcon"
icon.BackgroundTransparency=1
icon.AnchorPoint=Vector2 .new(0.5,0.5)
icon.Position=UDim2 .new(0.5,0,0,15)
icon.Size=UDim2 .new(0,20,0,20)
icon.ImageColor3=HOME_TEXT
ApplyIcon(icon,iconName)
icon.Parent=button
local caption=homeLabel(button,name,11,HOME_TEXT,false)
caption.Position=UDim2 .new(0,2,0,30)
caption.Size=UDim2 .new(1,-4,0,20)
caption.TextXAlignment=Enum.TextXAlignment.Center
caption.TextTruncate=Enum.TextTruncate.AtEnd
return button
end
local rejoinBtn=homeIconButton("Rejoin","refresh-cw",1)
local hopBtn=homeIconButton("Hop","shuffle",2)
local lowestBtn=homeIconButton("Lowest","signal",3)
local jobBtn=homeIconButton("Job ID","copy",4)
for _,b in ipairs({rejoinBtn,hopBtn,lowestBtn,jobBtn})do b.Size=UDim2 .new(0.25,-6,1,0)end
local jobText=game.JobId~=""and(game.JobId:sub(1,8).."..."..game.JobId:sub(-4))or"--"
local jobLabel=homeLabel(gameCard,"Job "..jobText.."  ·  Place "..tostring(game.PlaceId),10,HOME_MUTED,false)
jobLabel.Position=UDim2 .new(0,12,0,126)
jobLabel.Size=UDim2 .new(1,-28,0,14)
jobLabel.TextTruncate=Enum.TextTruncate.AtEnd
local homeCreator=""
local function homeLoadGameInfo()
task.spawn(function()
local ok,info=pcall(function()return homeMarketplace:GetProductInfo(game.PlaceId)end)
if ok and type(info)=="table"and homeRoot.Parent then
if type(info.Name)=="string"and info.Name~=""then gameNameLabel.Text=info.Name end
if type(info.Creator)=="table"and info.Creator.Name then homeCreator=tostring(info.Creator.Name)end
gameMetaLabel.Text=(homeCreator~=""and("by "..homeCreator.."  ·  ")or"")..tostring(#homePlayers:GetPlayers()).."/"..tostring(homePlayers.MaxPlayers).." players"
end
if gameNameLabel.Text=="Loading game info..."then gameNameLabel.Text="Place "..tostring(game.PlaceId)end
end)
end
homeHttpGet=function(url)
local reqFn=nil
if type(request)=="function"then reqFn=request
elseif type(http_request)=="function"then reqFn=http_request
elseif type(syn_request)=="function"then reqFn=syn_request
elseif type(syn)=="table"and type(syn.request)=="function"then reqFn=syn.request
elseif type(http)=="table"and type(http.request)=="function"then reqFn=http.request
elseif type(fluxus)=="table"and type(fluxus.request)=="function"then reqFn=fluxus.request end
if reqFn then
local ok,res=pcall(reqFn,{Url=url,Method="GET",Headers={["Accept"]="application/json"}})
if ok and type(res)=="table"and type(res.Body)=="string"and#res.Body>2 then return res.Body end
end
local ok,body=pcall(function()return game:HttpGet(url)end)
if ok and type(body)=="string"and#body>2 then return body end
local ok2,body2=pcall(function()return homeHttp:GetAsync(url)end)
if ok2 and type(body2)=="string"and#body2>2 then return body2 end
return nil
end
local function homeLoadGameIcon()
task.spawn(function()
local universeId=nil
local universeBody=homeHttpGet("https://apis.roblox.com/universes/v1/places/"..tostring(game.PlaceId).."/universe")
if type(universeBody)=="string"then
local okDec,decoded=pcall(function()return homeHttp:JSONDecode(universeBody)end)
if okDec and type(decoded)=="table"and decoded.universeId then universeId=decoded.universeId end
end
if universeId and gameIcon.Parent then
gameIcon.Image="rbxthumb://type=GameIcon&id="..tostring(universeId).."&w=150&h=150"
local deadline=os.clock()+3
while os.clock()<deadline and not gameIcon.IsLoaded and gameIcon.Parent do task.wait(0.1)end
if gameIcon.IsLoaded then return end
end
if type(writefile)~="function"then return end
local customAsset=getcustomasset or getsynasset
if type(customAsset)~="function"then return end
local apiBody=homeHttpGet("https://thumbnails.roblox.com/v1/places/gameicons?placeIds="..tostring(game.PlaceId).."&size=150x150&format=Png&isCircular=false")
local imageUrl=type(apiBody)=="string"and apiBody:match('"imageUrl"%s*:%s*"(https://[^"]+)"')or nil
if not imageUrl then return end
imageUrl=imageUrl:gsub("\\/","/")
local bytes=homeHttpGet(imageUrl)
if type(bytes)~="string"or#bytes<64 then return end
local ext=nil
if bytes:sub(1,8)=="\137PNG\r\n\26\n"then ext="png"elseif bytes:sub(1,3)=="\255\216\255"then ext="jpg"end
if not ext then return end
local path="xNgotLibrary/Avatars/GameIcon_"..tostring(game.PlaceId).."."..ext
if not pcall(writefile,path,bytes)then return end
local okAsset,asset=pcall(customAsset,path)
if okAsset and type(asset)=="string"and asset~=""and gameIcon.Parent then gameIcon.Image=asset end
end)
end
homeLoadGameIcon()
local function homeHop(lowest)
LIB:Notify({Title="Home",Content=lowest and"Finding the lowest-ping server..."or"Finding another server...",Duration=3})
task.spawn(function()
local url="https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/Public?sortOrder=Desc&limit=100"
local body=homeHttpGet(url)
local servers=nil
if body then
local okDecode,decoded=pcall(function()return homeHttp:JSONDecode(body)end)
if okDecode and type(decoded)=="table"and type(decoded.data)=="table"then servers=decoded.data end
end
if not servers then
LIB:Notify({Title="Home",Content="Could not load the server list in this executor.",Icon="triangle-alert",Duration=4})
return
end
local candidates={}
for _,entry in ipairs(servers)do
if type(entry)=="table"and type(entry.id)=="string"and entry.id~=game.JobId then
local playing=tonumber(entry.playing)or 0
local maxPlayers=tonumber(entry.maxPlayers)or homePlayers.MaxPlayers
if playing<maxPlayers then candidates[#candidates+1]=entry end
end
end
if#candidates==0 then
LIB:Notify({Title="Home",Content="No other server with free slots was found.",Icon="triangle-alert",Duration=4})
return
end
local chosen
if lowest then
table.sort(candidates,function(x,y)return(tonumber(x.ping)or 9999)<(tonumber(y.ping)or 9999)end)
chosen=candidates[1]
else
chosen=candidates[math.random(1,#candidates)]
end
local okTp,errTp=pcall(function()homeTeleport:TeleportToPlaceInstance(game.PlaceId,chosen.id,homePlayer)end)
if not okTp then LIB:Notify({Title="Home",Content="Teleport failed: "..tostring(errTp),Icon="triangle-alert",Duration=4})end
end)
end
rejoinBtn.MouseButton1Click:Connect(function()
local okTp,errTp=pcall(function()homeTeleport:Teleport(game.PlaceId,homePlayer)end)
if not okTp then LIB:Notify({Title="Home",Content="Rejoin failed: "..tostring(errTp),Icon="triangle-alert",Duration=4})end
end)
hopBtn.MouseButton1Click:Connect(function()homeHop(false)end)
lowestBtn.MouseButton1Click:Connect(function()homeHop(true)end)
jobBtn.MouseButton1Click:Connect(function()
if game.JobId==""then
LIB:Notify({Title="Home",Content="This session has no Job ID.",Icon="triangle-alert",Duration=3})
elseif CopyText(game.JobId)then
LIB:Notify({Title="Home",Content="Job ID copied.",Icon="copy",Duration=2.5})
end
end)
local function homeRecolor()
HOME_SURFACE=UISettings.SurfaceColor or HOME_SURFACE
HOME_CARD=HOME_SURFACE:Lerp(Color3 .fromRGB(255,255,255),0.05)
HOME_CARD2=HOME_SURFACE:Lerp(Color3 .fromRGB(255,255,255),0.11)
HOME_TEXT=UISettings.TextColor or HOME_TEXT
HOME_MUTED=UISettings.MutedTextColor or HOME_MUTED
HOME_ACCENT=UISettings.AccentColor or HOME_ACCENT
HOME_STROKE=HOME_SURFACE:Lerp(HOME_TEXT,0.22)
for _,obj in ipairs(homeRoot:GetDescendants())do
if obj:IsA("UIStroke")then
obj.Color=HOME_STROKE
elseif obj.Name=="HomeCard"then
obj.BackgroundColor3=HOME_CARD
elseif obj.Name=="HomeButton"or obj.Name=="HomeChip"then
obj.BackgroundColor3=HOME_CARD2
obj.TextColor3=HOME_TEXT
elseif obj.Name=="HomeBar"then
obj.BackgroundColor3=HOME_BAR
elseif obj.Name=="HomeBarPing"then
obj.BackgroundColor3=HOME_BAR2
elseif obj.Name=="HomeFpsText"then
obj.TextColor3=HOME_BAR
elseif obj.Name=="HomePingText"then
obj.TextColor3=HOME_BAR2
elseif obj.Name=="HomeActionIcon"then
obj.ImageColor3=HOME_TEXT
elseif obj.Name=="PlayerAvatar"or obj.Name=="GameIcon"then
obj.BackgroundColor3=HOME_CARD2
elseif obj:IsA("TextLabel")then
obj.TextColor3=(obj.TextTransparency or 0)>=0.28 and HOME_MUTED or HOME_TEXT
end
end
end
local homeSessionStart=os.time()
local fpsSamples,pingSamples={},{}
local homeFrames=0
local homeRsConn=homeRunService.RenderStepped:Connect(function()homeFrames+=1 end)
local function homeStats(samples)
local minV,maxV,sum=math.huge,0,0
for _,v in ipairs(samples)do
if v<minV then minV=v end
if v>maxV then maxV=v end
sum+=v
end
if#samples==0 then minV=0 end
return samples[#samples]or 0,minV,(#samples>0 and math.floor(sum/#samples+0.5)or 0),maxV
end
local function homeBars(lines,samples)
local graph=lines[1].Parent
local width,height=graph.AbsoluteSize.X,graph.AbsoluteSize.Y
local maxV=1
for _,v in ipairs(samples)do if v>maxV then maxV=v end end
local scale=maxV*1.2
local step=math.max(width-4,0)/(HOME_HISTORY-1)
for i,line in ipairs(lines)do
local idx=i-(HOME_HISTORY-#samples)
line.Visible=width>4 and height>4 and idx>=1 and idx+1<=#samples
if line.Visible then
local x1,x2=2+(i-1)*step,2+i*step
local y1=height-2-math.clamp(samples[idx]/scale,0,1)*(height-4)
local y2=height-2-math.clamp(samples[idx+1]/scale,0,1)*(height-4)
local dx,dy=x2-x1,y2-y1
line.Position=UDim2 .new(0,(x1+x2)/2,0,(y1+y2)/2)
line.Size=UDim2 .new(0,math.sqrt(dx*dx+dy*dy)+1,0,2)
line.Rotation=math.deg(math.atan2(dy,dx))
end
end
end
local function homePing()
local ok,value=pcall(function()return homePlayer:GetNetworkPing()end)
if ok and type(value)=="number"then return math.floor(value*1000+0.5)end
local ok2,value2=pcall(function()return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()end)
if ok2 and type(value2)=="number"then return math.floor(value2+0.5)end
return 0
end
local function homeSessionText()
local elapsed=math.max(os.time()-homeSessionStart,0)
if elapsed<60 then return tostring(elapsed).."s"end
if elapsed<3600 then return string.format("%dm %02ds",math.floor(elapsed/60),elapsed%60)end
return string.format("%dh %02dm",math.floor(elapsed/3600),math.floor(elapsed%3600/60))
end
homeRefreshBtn.MouseButton1Click:Connect(function()
fpsSamples,pingSamples={},{}
homeRecolor()
homeLoadGameInfo()
homeLoadGameIcon()
end)
Window.RefreshHomeDashboard=function()
fpsSamples,pingSamples={},{}
homeRecolor()
homeLoadGameInfo()
homeLoadGameIcon()
end
homeLoadGameInfo()
task.spawn(function()
local lastSample=os.clock()
while not windowDestroyed and not themeDestroyed and homeRoot.Parent do
task.wait(0.5)
if windowDestroyed or themeDestroyed or not homeRoot.Parent then break end
local now=os.clock()
local elapsed=math.max(now-lastSample,0.001)
local fps=math.floor(homeFrames/elapsed+0.5)
homeFrames=0
lastSample=now
fpsSamples[#fpsSamples+1]=fps
if#fpsSamples>HOME_HISTORY then table.remove(fpsSamples,1)end
pingSamples[#pingSamples+1]=homePing()
if#pingSamples>HOME_HISTORY then table.remove(pingSamples,1)end
local fpsNow,fpsMin,fpsAvg,fpsMax=homeStats(fpsSamples)
fpsValue.Text=tostring(fpsNow).." fps"
fpsMeta.Text=string.format("min %d  avg %d  max %d",fpsMin,fpsAvg,fpsMax)
homeBars(fpsBars,fpsSamples)
local pingNow,pingMin,pingAvg,pingMax=homeStats(pingSamples)
pingValue.Text=tostring(pingNow).." ms"
pingMeta.Text=string.format("min %d  avg %d  max %d",pingMin,pingAvg,pingMax)
homeBars(pingBars,pingSamples)
playersValue.Text=tostring(#homePlayers:GetPlayers()).."/"..tostring(homePlayers.MaxPlayers)
gameMetaLabel.Text=(homeCreator~=""and("by "..homeCreator.."  ·  ")or"")..tostring(#homePlayers:GetPlayers()).."/"..tostring(homePlayers.MaxPlayers).." players"
sessionValue.Text=homeSessionText()
if UISettings.SurfaceColor~=HOME_SURFACE or UISettings.AccentColor~=HOME_ACCENT or UISettings.TextColor~=HOME_TEXT then homeRecolor()end
end
if homeRsConn then homeRsConn:Disconnect()end
end)
end
end
buildHomeDashboard()
end
if type(Window.AdminInfo)=="table"then
local admin=Window.AdminInfo
SettingsTab:Paragraph({
Title="Administrator",
Desc="xNgọt Studio · Developer information",
})
local adminCard=SettingsTab:InfoNguyenNhat({
Avatar=tostring(admin.Avatar or"rbxassetid://0"),
Name=tostring(admin.Name or"Nguyễn Minh Nhật"),
Badges=type(admin.Badges)=="table"and admin.Badges or{"Owner","Developer"},
Bio=tostring(admin.Bio or""),
})
Window.AdminInfoCard=adminCard
local avatarURL=admin.AvatarURL
Window.AdminAvatarURL=avatarURL
local avatarManifest="xNgotLibrary/Avatars/AdminAvatarCache.txt"
local avatarLegacyPath="xNgotStudio_AdminAvatar.png"
local avatarRefreshSerial=0
local avatarHttpService=game:GetService("HttpService")
local ADMIN_AVATAR_EMBEDDED_B64=[[
/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAUDBAQEAwUEBAQFBQUGBwwIBwcHBw8LCwkMEQ8SEhEPERETFhwXExQaFRERGCEYGh0dHx8fExciJCIeJBweHx7/
2wBDAQUFBQcGBw4ICA4eFBEUHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh7/wAARCAEAAQADASIAAhEBAxEB/8QA
HwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkK
FhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXG
x8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAEC
AxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOE
hYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDWJGccDjrS
kEjP86gU5HIHHHWpo2bbzXCn0PSaIBu6c1InTB70p+Unkc0m4Y6c9qGhDgMMD0zTmxjHrTM7gCDT85ANIaIADnA6U5FAOW4HrTyh6ipQNyYoS1NOYQAAY+nN
C53HIpdpCjn8aD7UMSdwbgZ9qReDmnAdiaXAApFjxjIpQw2nFJ/D6UzaeRQx2Jl9afngUyPhcdqcAWHpSAcFB5FSLwabF0705+mfWkMlUhs4PSpE6ZqBDtU1
KpOKCh+Dn60pP97oOlIGyKMn170tgFI4FIuQ3tQSSPxqZF4GapEsc3A49KrXAJxn61cGM9KrTZ3jPpUvczb0GKc1JGvJ4piD86kUkVqjNksdTxA5HpUEZ3dq
sRA4FUiS5FjHIq5AVBGOKpRHAySTVgS5+VenrTRJ51tAwRxzT1zjGaG+ZcgUhyD1OTUGgEA55+lNAwpB609VCsCO9K3OCOTQIYvTA4qVApUDv9aagAHJ5qQY
XpzSGMIAbqaevFDDPOBTVbBwBmmA7d7Up5HTJpJFKqT1x1qNmcDIx70mXFEgYA89KVW3HI6CsbXdf0/RrF7jULqKFA20bzglvQDqfwrhdU+L+j2jJFZw3FyM
4acKAPfAJ5/HFCi3sPmR6zGvXqPrSkYbnoa5/wAMa/Hq+m2V+gufIvMiNpoShyPwwR7iugPJGDSK1FI7CpU4WoBnrU6sNpqRgv3ulK+SoxTT1GTwaeB78Uhi
RgsOaliYjI7UsY4xQoxmmAR/XNPJ9Kaq4yKVM96GNDgTtqdT8me9RptHU04AMDg4poTZMvIznmqchLSnk8cVb+6v4VTc5kOOxp2uzFtD1YY9KkTpURXNPGcL
npVozLMIGRirCdqgiHGQKlLBR7mqEyVpcHywefapogccEfjVOJRndnJNXEZVBORgdeaaQjhO5HOMdqME/wBKAOep/OlXOSDisyyRRnikYHkD0py+nrTGJBOK
AGqME0/pTRwenFBb5uO9IaJO3PHFA647UinNKSc9KVxjiwfOAcEVl6/qNtpOmz3t5PHBDEpLOx/IAdz7VpLke1eGftC69Kdbg0SF3EcESyyDsztyD+A/maqM
eZ2CUuRXOL8b+Jr3xNqUUtwiZiBijWNSC2T6f3jwOPavY/gb8F0N1/b3jiGKXytpt9MkUshJGQ02Ovsg78ngYrynwT4WkM2n+INcee1sGcTWkUC5uLwqwxsH
RVyPvn8Aa9G8ffEDxf4kl/s/R4tR09Yg0b2sEbRl9wAJLA4zjJ46c10VJKnHV2QsNRlXlaMW35Hofxg1650u6gm+waZdaRZyQzhbi58qcOjcqi9CCp246gVj
N8T/AAXeSudOuLu0QKpZbiL5F+jZz1/lXgfirSfEkdubzW5pfLifYqPLuZCexz0Ncy4w3JZvTNY0o06q5oO6OjFutQtSrQ5WvkfUln46029kSPTGguNxxl7l
EJ+i5LH8hW1Bq5kysixQkY+VpQx/SvkBMqwYDntU8V3MknmJI4buc4NU8O+5yrE+R9lRTmVNyMjDvircBDoCPSvlrwZ8QdZ0W8QtdST2xOJYmOcj2z3r6E8E
+KNP8QaeLiylRgG2kDhlPoynpWUoOL1NoTUlodMCBS96aWBYAfjTxUl3BsjmlPQU7v0zTXYhc4osO4Lx+dTRd6rxgkbjzU8DZIBHfmmkTJ6FhjhM1QQ5JOOp
zV442+1VogAOBiqRztjlx3pwHak4Xk0odQu7mqFckDleD+FIjszHd+tNHLgmpE5NUkK5LFjqOAaqa/di0012B+dxgVciOK5PxVdfar0Qhsqg/WtIoVxoD9do
xTlI+lLLnGOeKcke5QcgYrnZYdcHGPxpAM0vHoOKc3sKBojbjrTCuSTzUowT60oHfNSO4xAd2PansRjFOGCM45FRyAnrxj0oKTuxSOuM+teU/FvRtDfUbbxF
dS6eZbWVVuLe4uNougOQmFy3Y5IHSu+1qKSaBsB9uCAFPzH6Z4/nXgfxDtt2rzJYW/2mWBGefYSywgHkuxwCfXsOlOm/eHNXiyHxz8TNb8T2K6TcW9hb2iTC
RRDD86kHjax5UAcYGOOtRWPxA1XRlEegwLaMgIWeQ73GRyfTJ55rjkKCTe6/KecCh3BPyjj9a6KuGp1rKavYzw+YV8IpKk7c25f1fWdX1g7tT1CS4w27DdCf
WqDsTxnPpSpiRsY9utXrfTyzBz90njmtIwjTjaKsjCpVqV5c9STb8yvBbvKN2CFHU1YgEO7ynwewYdRVm/EkcK2iMoGSzY7n3rFlDq2RkH1oWpPMouxcvbdI
mBgkByM103ww1y40XxHDIsxSOVgrqT8r88A1xYkYDkmpop8KCM5/lSlC6sVGaTufZGmaksrK0m1S3v1z0PvW1uJA+teMfBfxZFqelrZXZDXFr8rlurIePy/k
a9b0xgYjGxJKHAJ6kdj+VcdmnZnfe6ujSAG3jvTOSSSODQjnpinFhmgRJCnynuKWEYkIPbpToyAmOgpsBLOTWj2MmyZuVPaq8Q+VfpU78I30NRIMBfpRFESY
owBkiombPTpSu+SR2qMD0NVYi5OnHvT0J7VEnHUZqwnStEtAIrif7PbPI5xxxXm3jHWG0XQ7/W/s32g26h2j37dwyAefxrtvEU/yLCD1OTXO3EazQvDKiSRv
wyuuQR7g1cUJmux9aVd2CDjHWopCeBmnrnaCa5DQcwAJI7nNA5pQDgd6UDHsPagBNo7UBS3IGBUqDnPUUvAb60WC5GvHbFM65BqWQjIPak2AA/WpY0ylqPmL
aO0YIwDgjrn0HvXlnxUtf7F8BSWse1Jr10Nw46yMeSM+gxgV68ybjg9PSvIf2h5sabYQA/KZXY8+gx/WnCPvJlSnaJ4i1vvhDDBGOKqKuHGemfWrbTMiMuSP
THaqrNvYncc16COA1bBbQEM0Zcg568GrU07NJ2ARcADoB7VmWbFBgk4q9aAyLLIR8qIzH8BUtG1MybuZvNcg98UkUodTv5PaoJ2yxPempTsYyepZaE9uaJ7d
4FBbIyM1b0aPzrpUI3ZPT2rY8bWqwW0JClTkipcrOx0RpPkcij4H1x9B8SWt9k+QWCTrj70ZOGH5c19Z+HLhZYtu7dtUAN2Zf4T78V8XEnaK+o/gtq39p+Ed
Pm3bnjh+zyEnnchA/l/OufELW5rQldcrPR1zng1IoAHTNRxZK+lSr8oBPNYpmz2FZ8IT/OpbRgwz6dagYhmwehq1EoUHHFWtTFi3Dfuj19Krlz0p08vO0HnI
zUY+7WkEQ2A608DmmgU9etaIRIqnrmnMdkZcnAApFYN0zVXVJCkBUHGaYjDv5RNcsxOecCqkrLGhY1Nsyxz1pskQZSrjitEI0dq9e9MINPcEE+tNAyvNcLNR
Vbr6CpGwUBHQ1HsAGQMGnAZ4NAD4+mKeQCcVH8w5FOjLNnI5FNMBJF6Hg0i9ak6rj0pq9KloaEcfMfpXkf7Q9mTZaZdqPlEkkbD1yAR/I162c4rnfHvh+HxH
4fk0+VzG2d8Ug/5ZuOh9x6j0qoaMUtY2Pkq5XLkBjioiPL6Hmupi0R7TxPdaXdxpLcQRsUIzsLYDA/lnrW/4i0CwtrBYvKa4vPKV5HiQKsWfugnv9K61NXsK
lhJThz3OG0i0lvJsDhVBZj6Ct67gSy0G6YDDSbIgT1OeTS+HYYUS4CfLLJ+58tuh3cZU/wBD68VX8aNHC62kTlgrFjn1AA/xo5k3YFDkhzM5WU/vDzxmhCWb
jqaFRpJQoGSa6TRPDN1PZ/bZFdQzbY1A5PqaqUklqYUaM6srJGh4D0t7jUJG2EiJRuPbJNXvirGkKRRqR8rHFdP8O9Na3hdNpLly78fl+grlPHcM2r6w0cO3
CMVXJx0PNYXvK57UqPJQ5VucIoDIoHU17d+zFfkpqulO3McqzKpPTKkHH4qK89s/D8ZEvlMkrwRncAepweAfWuk/Z/lNn8SVtvMBS8tXXr1ZQHx9fvUTkpRs
ef7OVOSufTMf3M8UpcFMjoKRflTHakUjHHesC5MVGy61dHQVRQjeBnvV9DhRVIyZSmybjOehqRMEUyYAykDrmnRrjpWsERId0NOX71Jg0JuB5FaEkykKKyNV
l3yEZ4HetGf5EJzWNON7EnvTQmVQScMRSt1FP8raPWkK96tAWC/bHX9KQHBpy9TmnbQFzXAbCp7mk6N6ikHA/SkZsZ9qAJVIycCnA846VFGeM4p6jdzQA5eK
dgUiAmpMZU8c0AQtzVDWS0doxXkngfU8f1rRUEPyOKpa1H/o4cFtqSxs2B0UNz+lFio7njmt+Ep7nQ08UWJaa+dpJbhF6yr5h24+igDFT3WhpP4Sl8R2c8k8
bIDFISCmEBJDr2ZQCD7iu/8AA6SQ+F7W3lBElu8kbD6Owz+lc/8AFqzki8HXUWlIII5GZ544zhWJXk49cDqPWqT11OmhV5LrueZiwhsLfS0nADNmSYk9SBuP
864DW5/Pv5JM/eYnA7V6f4s097fTIb9X+0xGRJfMJ++kigbvbtn8a8va1kl1r7M4xI8mGHpzzXTBrcxxOqUYnT/Djwt/bryK0crSsCY0VTlgOu3HWvQo/Cup
wwQ6dBckOjN5skw3gg4wqgEY28885+lbvwz0MrpCLFIYG2EI69QSPUV2fiKWCztWfylkYrxs6msZpvVs9ihQjSiodTltLtLbTIUQKPMXKgomBIcZxgfQ1g3n
gzTbvVJQ0YllQM4V0xyCOG5zjn+XrXR6eLe6vLH7ddW9u2RIULgOR22jqT/Kk8X3unprS3lg7pLwJCRyyYxye/QdfSsJqS1RrGClLUyYdBj0ySEDBe7fYwC4
UZ9AOAMnpXB6jbLofxsik05sQWuoQsu0YGAUWReO43EGvTNQv7loI75o2S3s8yiVxgE4OMZ/zxXC/DjQLzxX4ybVLiVhY2snmOw/5aMW3AD6lMn2rSGibZ52
Ps5JR6H0TdMFJUdAcVEjDpnFQykmXczEkn0odiozipZwtFpAPOBq+mao265cNngVfU8Va2IZBKp8wkdMUo4FPuF3EemKRQCuRzWsCJDdx61Iq8ZxSA84xUhO
1MYqySnfsSMD6VniIjtWg6E8cnmozEfSqQjPZGAqF1IPetGQFVJI6VQZg2Tzk00A9CcZPWnhvWkzwMDikODxmuE2Fzknnih8HgU1QS2BxTygwfQUAIGxxT1P
HBqPbhsUqkiTGDzQgLAcKMU4NxnNNC7l56dqANqD0oAZI3IIpjMWVlYHLcU9mG4g01xk4FDdhowLSP8AsnWpIn3nT9RfzIGbkQz4w0fsGCgjPGcj0q5qlss0
bAqHIfcA3Rh3zV6e1juIHhmRZI5PvK1RpFLHiOT96gGAxPP0P+NFrlKVjl5/C0L6TNpDoZbcRvFB2Ij6qh+gJAPoBXg+saZcaJ40jF6m1d6qzkffU/KH/QZ9
Dmvqi3iZxuAP7td5z2UH/wCvXBfFTwfHrFss0KL58LF0z/ECOVz6HitYOxpFOav2L/hmc22ggwRb5EXOw8ZqvNeRxyJd6pZ36Fxnb5OUH0Iz+tZHgS/urd49
H1NS06LiKXHEqe/ow6Ee2a9AEP2lPIKjaRyHXIIraCTPSVRvU8y1rxJ4b3OiWDu2dwLWu0r75xkfWrnhu3uPFjJDa6eYbR5Ock7nA9T2XPU963tQ8LaO04Pk
ou7+BScH8M4rX1KaLwp4TeGyRY7qRRHGF4+duBgd8dfqK553k7GuIrQpQvBavucZ4rVZ7WPSTcb7OK4mmbyuN0cZwpPrkpn6Z9q6n4eaT/Y/hyEND5U04Eso
xypbkKfcDA+uaz/DXhO+v5IY2gYwrs813O3fGPuqT7kZwO2eMYr0ptFaOHE9xHGB2Qbif6UKnJnj1al3ruZkYJXLgfU0x/u81tQaGtzGcXEsQxw0ijafyrLu
LKe0n2zKChHyuDlW+lOVOUVdoxjNMfZvWgnSs+EYJ29KvJkkClYTFlKiTHPSkUqoGOhonGH+Y8jrUIbe+B2rWGxMiwMDmmliW9hTZGwAB2pEqyBcZNCrzzTl
xnNKRznIpiM/VD5ce1R97rWWpyCDV/UX3SFSelU2GBmrS0BuxPjFNbjkjmn/AExTJCSK4bGwAndxSO7g47UKfyprt60hkqANgk8mn/dHXNRI3Y04ZJ55oAso
QEPPT1pCeMcEVErevFBdR3Ap3ACBvzilYZJ5pgYtzjipF4XFADlxyDSjjoOlNOQ2TT7SKW6nWCCN5JXOFRRkn6U12B6Gh4YgFzq6xMu6NonEg/2SMfzxVPxN
ol7YGRjE01oASsyjO0ejDqP5V3nh3w4dNtDJPJumcq8m3oMfwj1qe/4kGzOGPXHH0rupUYyjaW5gsTKnO61PnvWtNWdkuYJkE0bbldDtP5ioI/EGvRv5L+RM
F4y6fN+YxXtms+HtE1Bt93p8Rk6GSPMb/iVxn8c1x2q/D1MltK1IqST+6ulyB7Bl5/MVjVwlWPwanqUMxoyfvqx5D8RPEGtWWkedaTpA+8eZsXLbO4yemfau
rt2v9ZurO/lQNbQwoYWdcpvKgliO5A4A6c5rH8ceEvESSDTLnTRtvpY7aC5Vw0JdumW6j8QOhr0G30kaVp9tYxN5oghjiZj/ABYUDNZ06TUWpF4urFtOLui7
pt5DaWkSW80iSKPmeTkO/diR3P8AnpXQ6Z9vnj866gglhZfmMc4OB1zggVy0dsA24cD0b+Rro9Ckjitp4ZGZI/KYsCegx2PpXdTXLE8ier0KuleInumb7VA0
Vq0nBHXbniul1S2tr7TikcqAt80TD5sH8PauAtjbwJ9mhuCwVQfLV9xwRxjPY1JpUs3mpskkWHkYycqa4qmK9mrSV0b+wUndaF+W3ntJWhmQo684Pp61YR8F
TnBq3IEljRpMv8uVLHkVj3l5HE5iXczKpY8cKPeuSeIgmWqUmXJ2ZpSoySemKroxUsUYbgeRWFq11dSxbNzQxsOnQP8Aj/Sm+FjJFpjJIOWmYjB4x61vCT3J
lTsrnQiTJ61JGw9aorIFJz0qdWyOPrXQmmYNFsN6UjuAjEnGBUYfgcVWv5SsQQHaTVozZTmyWzz1qNiAOaeWyMZyaiB5+YVoLrqWmHy8GmE4NLzyM0h6V5rO
sYx4xnFNUY6808ANTJMAgUAPU8YBp6tg5qIcKDTg3PFAD9x3EUyVuBzSAndkmlI3HHY0ATWgaRgiIzMTgADJP5V0Gg+Gr/U7ggo1tAp+eSRCPwAPU/pXX+Cv
Di6JZ/abra19KBuP/PJf7o9/U1uS3WOFBPNddOg2rs551dbI57VvBVhNaqtgTbzIuA7ZYN7t/wDWq14f0/SdHP2aGRHun4eR8bm9vYe1ayyO6NuY4Ixism7g
sLCM3UsbMQcg4y2fatXSUdUjNVG1Zs2SzZ54x1FZmrw+XGZF5ic/MvoaWwvZriMm4g8lweAWySvYmriYkDRseo70RbuTY5qRGcDAZjjjtu/+vVO5gu0G5I93
cA9xXW+ShUoVHB6e9QSWkJBJiUg9Rjoa2VVoVjz6/kF1GEkhyVdWXP8ACynINQw2/mykOCzPxgeldxfaZZz4EkKhh3Xg1Ti0q2t5fNTeeOhNCnFvU0u0tDno
NBldywZEwOrfxfWh7J1YrA4dgOQOgrqHgiaPlB9aypZI4pHdWAY8AewrGtJxiy6d2zloLe43zi7tJQS5CbpAVYeuB936VBPHNGzTFRHHlVO3PfgCte/uJpov
Mt3hUFsKXPBIrzLTviNqEviA6bq2giGGZ41FzEWVC+/ATDDBORg4ORzxxXiyhKpo3sejFpbI7sXRZ2jEmVVOnoT2rFvFaUYm3S27E7vLHPBxTf7VtLSU3s0b
rEzAqpGDnJJz9P6Vz+mfEnT9S1yLQ7DSbqYJtQSCVVyX5B2+h9c9OcVl7GUk/I05uVo3Lh7G1MMNneIxkODDJJ8zD/dApg1rTrUx2txdW1tLsU+U0gUgHpx2
rZg0/T7hEe6t0WXqQVwRXhv7TnhI2eqW3iSyt2EE6iG5YHIDr90+2Rx+FdOHqObtI567tHQ9rjvLaYZjljcHptcGrOXEgK5x6CvieG7vbbDwXNxF3BV2X+Vb
eneOvF9jg23iG/A9GlLD9a7vZM4vao+xBKV5JNZ15OZZj2x2r5v074yeMrZdk81peD0lhwfzFa9n8bb7P+m6LC57mKYr+hFaRUkw5os9037enX0pyuMV5PZf
GfQZcC7s723PqFDj9K6Cw+Jng67wF1ZYm9JkKfzrZO5LaPQmO4+lJyB9aHPPHWm76886REwD1qOXO7GT9akPrUZbOTSGOBwuDQvyjk+9MGe5pGJOeD0oAlH1
qe2kEcySkZCMGI+hzVbGMHHJ7VInNCB6ns6Tm5gSaI7kcBgfY804AgjIrF+Ht8LrRVhdsvAfLPrjqP0/lXRtHk9BivVjJNI8+Ss7FSVmQZAqtfRx3LxM4LCI
5Azxn1PrWhJET6YrPusIxI4P86q3MhJ6iSAjDLVqJ96K4+90P1qksu5SCOtJG+yRXydvRh61i42ZdzUfDgSqfrQwGdw5B60yBtsjJ/C3IqRBglD07UWArTRZ
GB16r71RuFwhJJBrUcZBB9eKo38ZaPI49ah3RS1ZSnbbatz/AA1zt35Mbhpi20rgccE1r6tM0VodvJPy1zP2uDULFk8zc6EqQTjGDWFZ81kb0otK5X1S60+7
QxRAFoQBsXgD8Kp2ukafcSPcz6ZaveRJvS5ZBvBHcHoTx15PvWdcRTWupm4DsQPlZeg+h9eKvXevIsi3EIwHJAjLEA8Y7nGK53R5mmjoVRpWJ9f0q2ntbdZI
kk88iGRAMbdwOf04rn/7E0XRLlE02z+z+XmNHMhbZnjAJPHHHsOBiqunPb6PqMl1PZsFXctmFud6W6sOcD1Oe+cDgYrR1O7abT1EZKyNwk2BtXnuD/KlVp9h
xlYsO0qLHGz+ZjIwOuPSs3xrZf8ACReBNR0xVJkZMojDBDLyMetR2Vre7VAkcED5yGyCPbuP1+ta1vco13Haq4eUfeAOTXNJez1RrueK634fsNK+H07ywjz4
rPqR/ER/9evPvhh4cg8Ra1Nb3IzFFEWIyRznivdPjvYN/wAIRfzwxuS20SBew3DJrzf4B27CTVJ1HOUQH8zXsYasqqjI8ytT5HY5D4m+H7Xw7rkNhaH5Xg8w
5bPUkVO/gK+TQhqvn/J5PmkFO2M9asfF+X7V8Q2hyG8uOKL+v9a9J8WSix+HV2pwCLPyx9SAK6Ek220Y7HgthaXF9cC3tYzJIQTt9hS31jd2LhLuB4i3TcOt
dr8FLZZPENzKVDBLcgZHqatfHIRJqmnwRIqARMxA+opcq5bhc+kPvHrig4zTVI9OtIWNeWegSdR71Htx0pA3y9adwR16igCPqfU5xUvTjPamKijA9O9ObrnP
FAABubr0qYHaOtQowzt9aeSDx2FNAaXh/V7jTLzz7ZlOcK6t0YZr1W21KGWX7M5EU4/hY8H3B714sCBk5wPUdq9SsIrfVrGATExXflKwz15Gcg124V810zlr
xtqjfn8zZ8tZtxM24hwD9aSG6u9PIhv0Z4xwJgOMe9XZDbzoOUYH9a6vh0MTNBTkhxUbShMsTwDk5qW5totx8v5M1XNoscEhdy2Qc5OamSuNGpAflU55Q8e4
q2/IDDtWJpcxa1jcnJA2t+FbCMTF0pcgAzDOaikIIPSht3pUbBqmUdBpnP6+RECrcBs7Sa8s1+Wex1y1ksLGS4nnYgKjBcKOrHPYenU16/qqxnb5yoyrzz1/
CuF8WmESw6haWpa4ts4hJ2mRDjcBnv3H0x3rycRJwndM9PC6qxhm+tdVJtY5zFcf8tIn4ZB7jrzVDUtOju5iGuWUImAQ23jNNXVdI8TXPmBUguC3kK5XymjH
Qhj1Fcxf+G/tWos76teTmCRkPl3B2Ng+g4YU41E1qb/VtbJmvClojkRakk5HyspYMAfrV43hjiaPz4XbGQiKBnjFZS6VpnleWqqjqOwxWlbWZkso4IowHWUs
zBeW6d6pt20CdHlAS34ZoHuZghAwtvw34n9MVp6FpYjuxJMwjiH8PmAA/h2ptppMzPtkkuEVWwp/2cZpY0ktZSqtHLE0gDNnlB2JGOc1w1r9hx0WhY8SaPaa
zpF5pcbssU0RQb13qD2INeU/CvRZNIsdRjkU5F40ZP8Au8V7lugghWFZMDGQO9cr4rhis0e5ijEYlBdsLjce54712ZZU5anK+pyYuN4XPmfWSNT+Kkw4Ia/C
jjsCB/SvRPi/ILfwFKity8safXn/AOtXmvgwvdfECKf7xNy8hP512XxvvCdCsbbu8+4/gK9lfC2eaVvgRB/yEbkjnciA/maxfjPP5vjPygciGBFPP1NdV8Eo
/K8PzScZlnJ/IYrg/H0n2vx9f4Of36xj8ABSlpAD6siOcimuWyeKeOFwBzSoCB2zXknoDApAAJ5qVQAcD060sSncSwyPWlcYIOMU0IaTyc8UyVsA4ocFSWzk
k9KilbnkYNDGhEkIbJzipA+SeRUCt69aecbeMc0DFk3MMA9a9l0u3t5dH064Rv8AWW0eGz0O0f1zXi+4gDFd78Ntet/s7aFfvtBbdbM3GD1K5+vI/Gt8PK0r
GNeN43O2EsyKVdt69CDyDVNzGsu2KNkHoBxVg742KMSw7N60o2lT616RxFdWwecH61DqmZLOWFWKNIuwMOozxVgpj61HPbSvhn/dRgg7j1NSykUtBgktrTyp
Dl0OxvTI71sW5ZvvMTjpmqgKRuqKflbOT6nFTRuQ2aFqgZcJGKjZ1qvNdRglVDkg4JxgVXkuOM5pOIJkesKkkkZPJAOKwdagt7mIwzwhwfb+tW76/X+0IYWP
yyZXPv2qG+RTht5PoCP1rxsdTaZ6GGkeIfEa3Gg36yxSmFZWCu2AevQ89WHTNVtDs5GuTJZajczmQg7Hxgcc4Ars/jBpUepeGpY1hE04K+V6ls8da830vRNZ
06OK5jsbmAr97yjxn1xmuOnU5ND2KTjKF3udtDZF5CWHz46tW7osH2aVWkbePVegrldN1TUXUb8Ng8787vxBrbttRZTlgBnqK7oSTMqqdzszPE0QjbGW6Gsv
WrAGyea1Gy4QbkZe+OSPeqMes24T52wR0zWbrni62tbRzuH3fWs6sVKJlCLTNvRLLzoYry/m855FyqsOg7VnfFKOK28HX9zFGEMETPgHjp+laelzQ3OmRXCE
SM6g4ViRn6+lGu2a6xoF/pLQrm6t5IcA9yuB1965qDVKomY1VzJo+T/g5bGfxX5h58uIk/ia1PjxKF1LTrQHO2JnOPrin/Bu0lstc1IXELRywHynVhypB5H6
Vi/GS8+1+MmUdIoFQfqa+iUv3dzyGrSsd58MIxa+D4HP8Ss/515bbM2o+N933vOvSf8Ax7/61epaXcfYPB6KRjyrPPp/DXmfw3h+0eMbRjkhS0hx9DRPVID6
yxg03OM/WhG3DNKBk9a8o7x4YBM9KXeXbr0qOIuHORkU5VPIwapCCTG0sx+btVY4JqaQDoOR3qAqAcDpSkhoaVw+RT064ppwBnNNEnXHbrRYCR+pp9rO1vcx
3EeGeJwwDdD7VWV9wLDOT0pSGUFupIpxdmD1Vj2Hw/NNdWUTwMZoHUMu7qo9M1sJAoPzyAZ7LzXE+CtTnu7CGFRHFFD8nlxDaox3/HOfxrqzdBWC7gDjIxXs
JtxTPNejaLck8cP3IgMfxNyapXFysv3jk571P8sy81Xmtcn7vWpZSKEpaN/vcZyDVqS4CrlCCaq6nBKlrLz0UkVlWd5uiG45OO9KD11G0arS1BPIxU4qu10M
ZyKgnvlRDkitGJGXrLSxTxXEZ+aOUNwM8d62r14TECzcOAc/WshQLx3ckbT0GavR23nWKDzMMq7Sp5rycQ/aNrsdlNctjG1SIXUZJJO0ZHGB7VNpaxFBHMq4
9+9P8uOM+Wsnz5yTng/UUyAEksQB646V5vLZnY5XE1fwtpd/bsrQ7N2RvX5WUn0x0rz6/wBBlsb2LT72S4LMxWG4hkZWOBkZI4PA716tZz5Ta2QP4SR1qLWL
NLizZlRC4GVOM49/wrqTVjNVJJnhfiKx8SaW0jR6kbq3OSBNCA6e24dfyrzzUtWvbncjs0nbk19HahALiBUkVJJF4ZsdR/jXCeLfA9pPuubR1hn67dvysf6V
zSk0ztpVk1qaPwR1mW98OG0mikzbS+WGxwQRkDPrXoq7FLMiEH03V5h8FNO1CzbVYLqN9jSIVbGFQgHj6969LFzh2VgDjqMfyotfU5qjSk0jyK/0xNJ8f6/c
7NqXcqTpgZzuXJ/XNeDeMZft3ji7xyGuAg/Ovo/4l3tnB4gObuKN5bVcKxweCa+bbEC98cqeCHvCfwBr26f8JHm1fiPSPFMjWvhK9yACINg/lXJ/BqDzNenn
I5ihwDnpk1vfE+42eFnQcB5FX681B8ELYGy1G5Ycs6ID+BNbSVmkZnv0RI57U8sQOOtRIzAe2Ka7/hXlI7WTeYcdac83PFU3Y4zTVZmzTuFi0X96jZsHJpi8
DGefWk5zmkMccEHOKaNimlZdw64xTWGDQA5HGWBHXpRcSgKB0JpilSTzTLkbgFTHHegZ1Pw11BodXNqQDHNGxGeu4DivR4dOkdCzr16CvE9G1GXTtRt7yJVZ
4XBweh7EflmvYrLxSLiwguY7Z8yjIWvSws3KHL1Rx4iFpXLD299CcRLuUetKLm+jH722bHqKlj1m9ccae2KU3epTD5LNEHq1bO73MkY+pypNG5juGhl7BzhT
7Vz1vv3bZl8tx1xyPzrqNThunif7RZwSrjnC5rFsTYwqyXCyrhuPkJXHbmsZOz0No2sQXEcoGQp56Gsu5sb27cQ72VW67euK65LmwWMrb2Ekv1XiqV+0ihp4
DHGejBRzSxGJjCm31HTpuUjITTWtFSGGZoz0AYHP50+w1CSK4NnMTGTlg3rj1q4sjXtkTI4JU8EHn6j0rK1a3EpSRTmVM4OeleHCs+a/c75RTVi1LcPJPIp2
t3EhHAx61XtHLqoAznrWRqL3HmwDczptwzdMn6VrWMkaKnUE4ByKc5JysgUeWNzUSaSNzBCjM4GeBxirYaNz85VG6BR+tOhSMZkUbnIHXg4qAwRR3LzRoQxH
Y9TW2yMnqNlsYUDeXGOeTkYrkde028Mks0dxCQ38GcY/OuqneUguSwHoDWHqO6SKZAwV9pIBGTWE5KWhcE1qcP4avvsPjRbS5uDFDcZjdCcKXx8uffNeh3Bd
32tEUXOA2e1fM/xT1O8s1kkwYphKFV1GBkHIIH4V22i/GnwzdaLZ/wBoz3Fndqg+0RlGdWcDkhh1B64/CtqFFyhcK80pLuYn7VllJNqWjXGnxPKI4JFldOo+
YY/DrXhdnc3On3i3EeUmQ5G4V6l4z+KVrrGvuy6cZLCMbISThiPXHbPpWJdan4Z1RdhIh3DlZU6H616sIxUFrqedJ3kzmdc8S3+sWEdpd+WVRgwZRg5FdX8M
PFGk6PpUlneSNHK828ttyMYrNHhW0vDutpQQeQY2BrL1Lwve2jMYj5ij14NPVMVrH1iwJGBxVcgBuTnFTl8kcDFV/vckY5rzmjuuBwOnSgYBzzyKCcZ4oQgk
Fs/LkkDvQkK48AAYxz6Uh68dajWQZ46UMx64pgSnnjuaZJkIwHWk3KMEmk3ZB54ouA1Py4pcKo75pGIK46UxXyQDQMiK4kJBzk16D8NNRt1t2guF3yQZKr1y
rH/GuAbGcj7xq/oWoHTNVgu2OEB2yD1U8H8uv4Vth6ns5oyrR5oNHtKalcsMQ2ShexY4oMmoTffljiHogqCxuVnjVldSCOK0YWSNGncZCDj3PpXpyVjjRXuw
LaAedKzyPwqY5NUbyN4tJYwQ7JpWyoZcnOepH4Vq2luZ5/Pn5kblj/dHoKLv95dFpUxgbYFB5A/ic/oB+NYVC0czFcX3kt9okTYOMRriq0YiZsxvkHhlatGR
oonKArnvWNrAWHE0OcsT8o9cV4eLqdT0aCIAxhlkjVcIWIGPWmupeQkBgyggseg9qgtpWkt5GH3yedxxyKlZJ2hMZO3fj24zXJTfVG8uxUu2jnliBl2g5jVc
c/L3qxpVsPPIdlbA547066t45tqJtVo+Qw61LbWUyMZEdSzD5s11RV3czbsjVdyuBjK0TMqqCe/p1qC3LSxskqYZTjGetRO7SxsxXaVUjbnBB96ubMokc6u0
jsHYLjbj0Nct4olbTbSS7aVMxkFlZgCB9a6wzwBXKqNrD5lB61xHxE+y3vhHVLZ5AT9ncI2fmGBnBrBRTkjdSaPDfE/xMWPXrpF0PRNWsWbaYdSshJ+TAgj8
K8z168tb3UZLm002302OQ58iAsUX/d3EkD2qveAtOzMST3JqDaM17MFyxUTy5u8nIRiuOOvtTMnvUrAAU3BqhN3Y+2up7Zw8E8kTeqtit2z8Y6tBhLho7xPS
Zcn8654+9HUdOKd7CTsf/9k=

					]]
local B64_REV={}
do
local chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
for i=1,#chars do B64_REV[chars:sub(i,i)]=i-1 end
end
local function avatarB64Decode(data)
data=tostring(data or""):gsub("[^A-Za-z0-9%+%/%=]","")
local out={}
for i=1,#data,4 do
local ca,cb,cc,cd=data:sub(i,i),data:sub(i+1,i+1),data:sub(i+2,i+2),data:sub(i+3,i+3)
local va,vb=B64_REV[ca]or 0,B64_REV[cb]or 0
local vc=(cc~="="and cc~="")and(B64_REV[cc]or 0)or 0
local vd=(cd~="="and cd~="")and(B64_REV[cd]or 0)or 0
local n=va*262144+vb*4096+vc*64+vd
out[#out+1]=string.char(math.floor(n/65536)%256)
if cc~="="and cc~=""then out[#out+1]=string.char(math.floor(n/256)%256)end
if cd~="="and cd~=""then out[#out+1]=string.char(n%256)end
end
return table.concat(out)
end
local function avatarEmbeddedAsset(customAsset)
if type(writefile)~="function"or type(customAsset)~="function"then return nil,"writefile/getcustomasset unavailable"end
local ok,bytes=pcall(avatarB64Decode,ADMIN_AVATAR_EMBEDDED_B64)
if not ok or type(bytes)~="string"or#bytes<64 then return nil,"embedded decode failed"end
if bytes:sub(1,3)~="\255\216\255"then return nil,"embedded bytes invalid"end
local path="xNgotLibrary/Avatars/AdminAvatar_embed.jpg"
if not pcall(writefile,path,bytes)then return nil,"writefile embedded failed"end
local okAsset,asset=pcall(customAsset,path)
if okAsset and type(asset)=="string"and asset~=""then return asset,path end
return nil,"getcustomasset embedded failed"
end
local function deleteAvatarFile(path)
if type(delfile)~="function"or type(path)~="string"then return end
local allowed=path==avatarLegacyPath
or path:match("^xNgotStudio_AdminAvatar_[%w]+%.png$")
or path:match("^xNgotStudio_AdminAvatar_[%w]+%.jpg$")
or path:match("^xNgotStudio_AdminAvatar_[%w]+%.webp$")
or path:match("^xNgotLibrary/Avatars/AdminAvatar_[%w]+%.png$")
or path:match("^xNgotLibrary/Avatars/AdminAvatar_[%w]+%.jpg$")
or path:match("^xNgotLibrary/Avatars/AdminAvatar_[%w]+%.webp$")
if not allowed then return end
local exists=true
if type(isfile)=="function"then
local ok,result=pcall(isfile,path)
if ok then exists=result==true end
end
if exists then pcall(delfile,path)end
end
local function avatarFetchRaw(url)
local reqFn=nil
if type(request)=="function"then reqFn=request
elseif type(http_request)=="function"then reqFn=http_request
elseif type(syn_request)=="function"then reqFn=syn_request
elseif type(syn)=="table"and type(syn.request)=="function"then reqFn=syn.request
elseif type(http)=="table"and type(http.request)=="function"then reqFn=http.request
elseif type(fluxus)=="table"and type(fluxus.request)=="function"then reqFn=fluxus.request end
if reqFn then
local current=url
for _=1,4 do
local ok,res=pcall(reqFn,{
Url=current,Method="GET",
Headers={["Accept"]="image/*,*/*",["User-Agent"]="Mozilla/5.0 (xNgotStudio)"},
})
if not ok or type(res)~="table"then break end
local status=tonumber(res.StatusCode or res.Status or res.status_code or res.status or 0)or 0
local body=res.Body or res.body
if status>=300 and status<400 then
local location=nil
for key,value in pairs(type(res.Headers)=="table"and res.Headers or{})do
if tostring(key):lower()=="location"then location=tostring(value)end
end
if location and location~=""then current=location else break end
elseif type(body)=="string"and#body>0 and(status==200 or status==0)then
return body
else break end
end
end
local ok,data=pcall(function()return game:HttpGet(url)end)
if ok and type(data)=="string"and#data>0 then return data end
local okN,dataN=pcall(function()return game:HttpGet(url,true)end)
if okN and type(dataN)=="string"and#dataN>0 then return dataN end
local ok2,data2=pcall(function()return avatarHttpService:GetAsync(url)end)
if ok2 and type(data2)=="string"and#data2>0 then return data2 end
return nil
end
local function avatarDownloadBytes(url)
local nonce=avatarHttpService:GenerateGUID(false):gsub("%-","")
local separator=url:find("?",1,true)and"&"or"?"
local function isImage(body)
if type(body)~="string"or#body<64 then return false end
return body:sub(1,8)=="\137PNG\r\n\26\n"
or body:sub(1,3)=="\255\216\255"
or(body:sub(1,4)=="RIFF"and body:sub(9,12)=="WEBP")
end
local candidates={}
candidates[#candidates+1]=url..separator.."xngot_refresh="..nonce
candidates[#candidates+1]=url
local user=url:match("^https://github%.com/([%w%-]+)%.png")
local directUrl=nil
if user then
local apiBody=avatarFetchRaw("https://api.github.com/users/"..user)
if type(apiBody)=="string"then
directUrl=apiBody:match('"avatar_url"%s*:%s*"(https://[^"]+)"')
if directUrl then
directUrl=directUrl:gsub("\\/","/")
candidates[#candidates+1]=directUrl
end
end
end
if user then candidates[#candidates+1]="https://images.weserv.nl/?url=github.com/"..user..".png"end
if directUrl then candidates[#candidates+1]="https://images.weserv.nl/?url="..directUrl:gsub("^https://","")end
for _,candidate in ipairs(candidates)do
local body=avatarFetchRaw(candidate)
if isImage(body)then return body end
end
return nil
end
function Window:RefreshAdminAvatar()
if self.AdminInfoCard~=adminCard then return false end
avatarURL=Window.AdminAvatarURL or avatarURL
if type(avatarURL)~="string"or not avatarURL:match("^https://")then return false end
local customAsset=getcustomasset or getsynasset
if type(customAsset)~="function"then return false end
avatarRefreshSerial=avatarRefreshSerial+1
local currentSerial=avatarRefreshSerial
task.spawn(function()
local cachedPath=nil
if type(readfile)=="function"then
local ok,previous=pcall(readfile,avatarManifest)
if ok and type(previous)=="string"then cachedPath=previous:gsub("%s+$",""):gsub("^%s+","")end
end
local cachedApplied=false
local function keepAvatarApplied(asset)
task.spawn(function()
for _,delayTime in ipairs({4,5,6})do
task.wait(delayTime)
if currentSerial~=avatarRefreshSerial or self.AdminInfoCard~=adminCard then return end
pcall(adminCard.SetAvatar,adminCard,asset)
end
end)
end
for _,candidate in ipairs({cachedPath,avatarLegacyPath})do
if not cachedApplied and type(candidate)=="string"and candidate~=""
and(type(isfile)~="function"or isfile(candidate))then
local okAsset,asset=pcall(customAsset,candidate)
if okAsset and type(asset)=="string"and asset~=""then
pcall(adminCard.SetAvatar,adminCard,asset)
cachedApplied=true
cachedPath=candidate
keepAvatarApplied(asset)
end
end
end
if not cachedApplied then
local embeddedAsset,embeddedPath=avatarEmbeddedAsset(customAsset)
if embeddedAsset then
pcall(adminCard.SetAvatar,adminCard,embeddedAsset)
cachedApplied=true
cachedPath=embeddedPath
pcall(writefile,avatarManifest,embeddedPath)
keepAvatarApplied(embeddedAsset)
end
if not embeddedAsset then warn("[xNgotStudio] Admin avatar: embedded fallback failed - "..tostring(embeddedPath))end
end
if type(writefile)~="function"then return end
local lastError="khong tai duoc avatar"
for attempt=1,4 do
if currentSerial~=avatarRefreshSerial or self.AdminInfoCard~=adminCard then return end
local ok,result=pcall(function()
local response=avatarDownloadBytes(avatarURL)
if type(response)~="string"or#response<64 then
error("Avatar response is empty or too short")
end
local ext
if response:sub(1,8)=="\137PNG\r\n\26\n"then ext="png"
elseif response:sub(1,3)=="\255\216\255"then ext="jpg"
elseif response:sub(1,4)=="RIFF"and response:sub(9,12)=="WEBP"then ext="webp"
else error("Avatar URL did not return a supported image")end
local nonce=avatarHttpService:GenerateGUID(false):gsub("%-","")
local path="xNgotLibrary/Avatars/AdminAvatar_"..nonce.."."..ext
if not pcall(writefile,path,response)then error("writefile avatar failed")end
local asset=customAsset(path)
if type(asset)~="string"or asset==""then error("Local avatar asset is unavailable")end
return{Asset=asset,Path=path}
end)
if ok and currentSerial==avatarRefreshSerial and self.AdminInfoCard==adminCard then
pcall(adminCard.SetAvatar,adminCard,result.Asset)
keepAvatarApplied(result.Asset)
pcall(writefile,avatarManifest,result.Path)
if cachedPath and cachedPath~=result.Path then deleteAvatarFile(cachedPath)end
if avatarLegacyPath~=result.Path then deleteAvatarFile(avatarLegacyPath)end
return
elseif not ok then
lastError=tostring(result)
end
if attempt<4 then task.wait(attempt*1.5)end
end
warn("[xNgotStudio] Admin avatar auto-load failed (da thu lai 4 lan): "..lastError..(cachedApplied and" - dang dung avatar cache/nhung san"or""))
end)
return true
end
Window:RefreshAdminAvatar()
end
SettingsTab:Paragraph({
Title="UI / UX Customization",
Desc="Customize only what you choose. The original NgotStudio layout, cards, spacing and controls stay unchanged.",
})
function Window:GetUILanguage()return"en"end
function Window:SetUILanguage()
if self.DynamicIsland and type(self.DynamicIsland.SetLanguage)=="function"then
pcall(self.DynamicIsland.SetLanguage,self.DynamicIsland,"en")
end
return"en"
end
SettingsTab:Section({Title="Theme & Appearance",Default=true})
local presetNames=Window:GetUIPresets()
local presetDropdown
presetDropdown=SettingsTab:Dropdown({
Title="Theme Preset",
Desc="Default restores the exact original UI. Presets intentionally change multiple appearance settings; individual controls below change only themselves.",
Values=presetNames,
Value=table.find(presetNames,UISettings.Preset)and UISettings.Preset or"Default",
Callback=function(value)
if settingsBuilding then return end
applyPreset(value,true)
end,
})
settingsControls.Preset=presetDropdown
settingsControls.Font=SettingsTab:Dropdown({
Title="Font Family",
Desc="Changes only the font family and preserves the original Regular / Medium / Bold hierarchy.",
Values={"Original","Gotham","SourceSans","Arial","Code","Cartoon","SciFi"},
Value=UISettings.Font,
Callback=function(value)setUISetting("Font",value)end,
})
settingsControls.TextScale=SettingsTab:Slider({
Title="Text Scale",Desc="Scale text without resizing the whole window.",Step=0.05,
Value={Min=0.7,Max=1.5,Default=UISettings.TextScale},
Callback=function(value)setUISetting("TextScale",value)end,
})
settingsControls.UIScale=SettingsTab:Slider({
Title="UI Scale (Zoom)",Desc="Zoom the whole UI without changing the saved window width/height.",Step=0.05,
Value={Min=0.65,Max=1.5,Default=UISettings.UIScale},
Callback=function(value)setUISetting("UIScale",value)end,
})
SettingsTab:Section({Title="Window Size",Default=true})
settingsControls.WindowWidth=SettingsTab:Slider({
Title="Window Width",
Desc="Changes only the window width. Original layout/style is preserved.",
Step=10,
Value={Min=420,Max=1000,Default=UISettings.WindowWidth},
Callback=function(value)
if settingsBuilding then return end
value=math.floor((tonumber(value)or originalWindowWidth)+0.5)
if value==originalWindowWidth then
Window:ClearUIOverride("WindowWidth",true)
else
setUISetting("WindowWidth",value)
end
end,
})
settingsControls.WindowHeight=SettingsTab:Slider({
Title="Window Height",
Desc="Changes only the window height. Original layout/style is preserved.",
Step=10,
Value={Min=300,Max=800,Default=UISettings.WindowHeight},
Callback=function(value)
if settingsBuilding then return end
value=math.floor((tonumber(value)or originalWindowHeight)+0.5)
if value==originalWindowHeight then
Window:ClearUIOverride("WindowHeight",true)
else
setUISetting("WindowHeight",value)
end
end,
})
SettingsTab:Button({
Title="Reset Window Size",
Desc="Restore the exact Size passed to CreateWindow without resetting other customizations.",
Callback=function()Window:ResetUISize(true)end,
})
SettingsTab:Section({Title="Theme Details",Default=true})
settingsControls.CornerRadius=SettingsTab:Slider({
Title="Corner Radius",Desc="Global rounded corner amount.",Step=1,
Value={Min=0,Max=28,Default=UISettings.CornerRadius},
Callback=function(value)setUISetting("CornerRadius",value)end,
})
settingsControls.AccentColor=SettingsTab:Colorpicker({
Title="Accent Color",Desc="Buttons, highlights and selected states.",Default=UISettings.AccentColor,
Callback=function(value)setUISetting("AccentColor",value)end,
})
settingsControls.TextColor=SettingsTab:Colorpicker({
Title="Text Color",Default=UISettings.TextColor,
Callback=function(value)setUISetting("TextColor",value)end,
})
settingsControls.MutedTextColor=SettingsTab:Colorpicker({
Title="Muted Text",Default=UISettings.MutedTextColor,
Callback=function(value)setUISetting("MutedTextColor",value)end,
})
SettingsTab:Section({Title="Background & Glass",Default=true})
settingsControls.BackgroundMode=SettingsTab:Dropdown({
Title="Background Mode",Values={"Color","Image","Liquid Glass"},Value=UISettings.BackgroundMode,
Callback=function(value)setUISetting("BackgroundMode",value)end,
})
settingsControls.BackgroundColor=SettingsTab:Colorpicker({
Title="Background Color",Default=UISettings.BackgroundColor,
Callback=function(value)setUISetting("BackgroundColor",value)end,
})
settingsControls.SurfaceColor=SettingsTab:Colorpicker({
Title="Box / Surface Color",Default=UISettings.SurfaceColor,
Callback=function(value)setUISetting("SurfaceColor",value)end,
})
settingsControls.WindowOpacity=SettingsTab:Slider({
Title="Window Opacity",Desc="100 = opaque, lower values = more transparent.",Step=1,
Value={Min=15,Max=100,Default=UISettings.WindowOpacity},
Callback=function(value)setUISetting("WindowOpacity",value)end,
})
settingsControls.BoxOpacity=SettingsTab:Slider({
Title="Box Opacity",Desc="Opacity of cards, controls and panels.",Step=1,
Value={Min=10,Max=100,Default=UISettings.BoxOpacity},
Callback=function(value)setUISetting("BoxOpacity",value)end,
})
local backgroundImageValue=UISettings.BackgroundImage
settingsControls.BackgroundImage=SettingsTab:Input({
Title="Background Image",Desc="Asset ID or rbxassetid:// URL.",Placeholder="rbxassetid://123456789",
Default=backgroundImageValue,
Callback=function(value)
backgroundImageValue=tostring(value or"")
setUISetting("BackgroundImage",backgroundImageValue)
end,
})
settingsControls.BackgroundImageScale=SettingsTab:Dropdown({
Title="Image Scale",Values={"Crop","Fit","Stretch","Tile"},Value=UISettings.BackgroundImageScale,
Callback=function(value)setUISetting("BackgroundImageScale",value)end,
})
settingsControls.BackgroundImageTransparency=SettingsTab:Slider({
Title="Image Transparency",Step=1,
Value={Min=0,Max=100,Default=UISettings.BackgroundImageTransparency},
Callback=function(value)setUISetting("BackgroundImageTransparency",value)end,
})
settingsControls.Blur=SettingsTab:Slider({
Title="Glass Blur",Desc="BlurEffect strength used by Liquid Glass.",Step=1,
Value={Min=0,Max=32,Default=UISettings.Blur},
Callback=function(value)setUISetting("Blur",value)end,
})
settingsControls.LiquidGlassStrength=SettingsTab:Slider({
Title="Liquid Glass Strength",Desc="Controls panel translucency and highlight intensity.",Step=1,
Value={Min=0,Max=100,Default=UISettings.LiquidGlassStrength},
Callback=function(value)setUISetting("LiquidGlassStrength",value)end,
})
SettingsTab:Section({Title="Motion & Controls",Default=false})
settingsControls.AnimationSpeed=SettingsTab:Slider({
Title="Animation Speed",Desc="1.0 = normal. Higher = faster.",Step=0.05,
Value={Min=0.2,Max=3,Default=UISettings.AnimationSpeed},
Callback=function(value)setUISetting("AnimationSpeed",value)end,
})
settingsControls.ReduceMotion=SettingsTab:Toggle({
Title="Reduce Motion",Desc="Makes most UI transitions nearly instant.",Default=UISettings.ReduceMotion,
Callback=function(value)setUISetting("ReduceMotion",value==true)end,
})
settingsControls.ShowFloatingButtonText=SettingsTab:Toggle({
Title="Floating Button Text",Desc="Show the window title on the floating open button.",Default=UISettings.ShowFloatingButtonText,
Callback=function(value)setUISetting("ShowFloatingButtonText",value==true)end,
})
SettingsTab:Section({Title="Save Management",Default=false})
SettingsTab:Toggle({
Title="Auto Save",Desc="Automatically save element config and UI settings.",Default=Window.AutoSave,
Callback=function(value)
Window.AutoSave=value==true
if Window.AutoSave and not settingsBuilding then storeUISettings(true)end
end,
})
SettingsTab:Button({
Title="Save Now",Desc="Immediately write all current settings to disk.",
Callback=function()
storeUISettings(true)
LIB:Notify({Title="Settings Ui",Content="Config saved.",Icon="save",Duration=2.5})
end,
})
local profileName="My Theme"
local selectedProfile=nil
SettingsTab:Input({
Title="Profile Name",Placeholder="My Theme",Default=profileName,
Callback=function(value)profileName=tostring(value or"")end,
})
local function profileValues()
local values=Window:GetUIProfileNames()
if#values==0 then return{"None"}end
return values
end
local profileDropdown=SettingsTab:Dropdown({
Title="Saved Profiles",Values=profileValues(),Value="None",AllowNone=true,
Callback=function(value)
selectedProfile=value~=""and value~="None"and value or nil
end,
})
SettingsTab:Button({
Title="Save Profile",Desc="Save the current UI appearance as a named profile.",
Callback=function()
local ok,err=Window:SaveUIProfile(profileName)
profileDropdown:Refresh(profileValues())
if ok then profileDropdown:Select(profileName)end
LIB:Notify({Title="UI Profile",Content=ok and("Saved: "..profileName)or tostring(err),Icon=ok and"circle-check"or"triangle-alert",Duration=3})
end,
})
SettingsTab:Button({
Title="Load Profile",Desc="Apply the selected saved profile.",
Callback=function()
if not selectedProfile then return end
local ok,err=Window:LoadUIProfile(selectedProfile,true)
LIB:Notify({Title="UI Profile",Content=ok and("Loaded: "..selectedProfile)or tostring(err),Icon=ok and"circle-check"or"triangle-alert",Duration=3})
end,
})
SettingsTab:Button({
Title="Delete Profile",Desc="Delete the selected UI profile.",
Callback=function()
if not selectedProfile then return end
local deleted=Window:DeleteUIProfile(selectedProfile)
if deleted then selectedProfile=nil;profileDropdown:Refresh(profileValues())end
end,
})
local importJSON=""
SettingsTab:Button({
Title="Copy UI JSON",Desc="Copy current UI settings as JSON.",
Callback=function()
local json=Window:ExportUISettings()
if json and CopyText(json)then
LIB:Notify({Title="Settings Ui",Content="UI JSON copied.",Icon="copy",Duration=2.5})
end
end,
})
SettingsTab:Input({
Title="Import UI JSON",Desc="Paste exported UI JSON, then press Import.",Placeholder="{ ... }",MultiLine=true,
Callback=function(value)importJSON=tostring(value or"")end,
})
SettingsTab:Button({
Title="Import JSON",
Callback=function()
local ok,err=Window:ImportUISettings(importJSON,true)
LIB:Notify({Title="Settings Ui",Content=ok and"UI settings imported."or tostring(err),Icon=ok and"circle-check"or"triangle-alert",Duration=3})
end,
})
SettingsTab:Button({
Title="Copy Config Path",Desc=Window:GetConfigPath(),
Callback=function()CopyText(Window:GetConfigPath())end,
})
SettingsTab:Button({
Title="Reset UI Settings",Desc="Restore NgotStudio default appearance.",
Callback=function()
Window:Dialog({
Title="Reset UI Settings",Content="Reset all UI/UX customization to defaults?",Icon="rotate-ccw",
Buttons={
{Title="Cancel"},
{Title="Reset",Callback=function()
Window:ResetUISettings(true)
LIB:Notify({Title="Settings Ui",Content="UI settings reset.",Icon="circle-check",Duration=2.5})
end},
},
})
end,
})
SettingsTab:Button({
Title="Delete Config File",Desc="Delete the saved config from the executor filesystem.",
Callback=function()
Window:Dialog({
Title="Delete Config",Content="Delete the saved config file? Current runtime values stay active until re-execute.",Icon="trash-2",
Buttons={
{Title="Cancel"},
{Title="Delete",Callback=function()
local ok,err=Window:DeleteConfig()
LIB:Notify({Title="Config",Content=ok and"Config file deleted."or tostring(err),Icon=ok and"circle-check"or"triangle-alert",Duration=3})
end},
},
})
end,
})
syncSettingsControls=function()
if not Window.SettingsUI then return end
local previous=settingsBuilding
settingsBuilding=true
local function setControl(key,method,value)
local control=settingsControls[key]
if control and type(control[method])=="function"then
pcall(control[method],control,value)
end
end
if UISettings.Preset then setControl("Preset","Select",UISettings.Preset)end
setControl("Font","Select",UISettings.Font)
setControl("TextScale","Set",UISettings.TextScale)
setControl("UIScale","Set",UISettings.UIScale)
setControl("WindowWidth","Set",UISettings.WindowWidth)
setControl("WindowHeight","Set",UISettings.WindowHeight)
setControl("CornerRadius","Set",UISettings.CornerRadius)
setControl("AccentColor","Set",UISettings.AccentColor)
setControl("TextColor","Set",UISettings.TextColor)
setControl("MutedTextColor","Set",UISettings.MutedTextColor)
setControl("BackgroundMode","Select",UISettings.BackgroundMode)
setControl("BackgroundColor","Set",UISettings.BackgroundColor)
setControl("SurfaceColor","Set",UISettings.SurfaceColor)
setControl("WindowOpacity","Set",UISettings.WindowOpacity)
setControl("BoxOpacity","Set",UISettings.BoxOpacity)
setControl("BackgroundImage","Set",UISettings.BackgroundImage)
setControl("BackgroundImageScale","Select",UISettings.BackgroundImageScale)
setControl("BackgroundImageTransparency","Set",UISettings.BackgroundImageTransparency)
setControl("Blur","Set",UISettings.Blur)
setControl("LiquidGlassStrength","Set",UISettings.LiquidGlassStrength)
setControl("AnimationSpeed","Set",UISettings.AnimationSpeed)
setControl("ReduceMotion","Set",UISettings.ReduceMotion)
setControl("ShowFloatingButtonText","Set",UISettings.ShowFloatingButtonText)
settingsBuilding=previous
end
settingsBuilding=false
applyUITheme()
CONFIG.__NgotUISettings=serializeUISettings(UISettings)
local islandSettings=type(CONFIG.__NgotIslandSettings)=="table"and CONFIG.__NgotIslandSettings or{}
CONFIG.__NgotIslandSettings=islandSettings
if LIB.ActiveDynamicIsland then
pcall(LIB.ActiveDynamicIsland.Destroy,LIB.ActiveDynamicIsland)
LIB.ActiveDynamicIsland=nil
end
local created,islandAPI=xpcall(function()
return createIntegratedDynamicIsland(Gui,Window)
end,function(err)
if debug and type(debug.traceback)=="function"then
return debug.traceback(tostring(err),2)
end
return tostring(err)
end)
if created and type(islandAPI)=="table"then
Window.DynamicIsland=islandAPI
do
local function getApi()
return Window and Window.DynamicIsland or nil
end
local function cfg(key,fallback)
local api=_G.xNgotMusicConfig
if api and type(api.Get)=="function"then
local v=api:Get(key)
if v~=nil then return v end
end
return fallback
end
local function debugLog(...)
if cfg("debug",false)then
warn("[xNgotUI] "..table.concat({...}," "))
end
end
local notifyGate={}
local function throttledNotify(channel,title,text,kind,duration)
local now=os.clock()
local last=notifyGate[channel]
if last and now-last<3 then return false end
notifyGate[channel]=now
if type(notify)=="function"then
pcall(notify,title,text,kind or"info",duration or 3,true)
return true
end
return false
end
_G.xNgotThrottledNotify=throttledNotify
local searchQueue={pending=nil,running=false}
local function queueSearch(prompt)
searchQueue.pending=tostring(prompt or"")
if searchQueue.running then return end
searchQueue.running=true
task.spawn(function()
while searchQueue.pending do
local nextPrompt=searchQueue.pending
searchQueue.pending=nil
local api=getApi()
if api and type(api.MusicSearch)=="function"then
debugLog("search:",nextPrompt)
pcall(function()api:MusicSearch(nextPrompt)end)
end
task.wait(0.35)
end
searchQueue.running=false
end)
end
_G.xNgotQueueMusicSearch=queueSearch
local coverQueue,coverRunning={},false
local COVER_BUDGET=2
local function pumpCovers()
if coverRunning then return end
coverRunning=true
task.spawn(function()
while#coverQueue>0 do
local batch={}
for _=1,COVER_BUDGET do
local item=table.remove(coverQueue,1)
if not item then break end
batch[#batch+1]=item
end
for _,item in ipairs(batch)do
task.spawn(function()
local engine=_G.CrossAIMusic
if engine and type(engine.thumbAsset)=="function"then
local ok,asset=pcall(engine.thumbAsset,item.track)
if ok and type(asset)=="string"and asset~=""then
item.track.CoverAsset=asset
end
end
end)
end
task.wait(0.15)
end
coverRunning=false
end)
end
local function prefetch(tracks)
if cfg("coverArt",true)~=true then return end
for _,track in ipairs(tracks or{})do
coverQueue[#coverQueue+1]={track=track}
end
pumpCovers()
end
local function tooltip(button,text)
if not button or not text or text==""then return end
pcall(function()
if button:FindFirstChild("xNgotTip")then return end
local tip=Instance.new("TextLabel")
tip.Name="xNgotTip"
tip.BackgroundColor3=Color3 .fromRGB(24,26,32)
tip.BackgroundTransparency=0.05
tip.TextColor3=Color3 .fromRGB(230,234,242)
tip.Font=Enum.Font.GothamMedium
tip.TextSize=12
tip.TextWrapped=true
tip.TextXAlignment=Enum.TextXAlignment.Left
tip.Visible=false
tip.ZIndex=50
tip.Size=UDim2 .fromOffset(230,34)
tip.Position=UDim2 .new(1,8,0,0)
tip.Text=tostring(text)
local c=Instance.new("UICorner",tip)
c.CornerRadius=UDim.new(0,6)
tip.Parent=button
button.MouseEnter:Connect(function()tip.Visible=true end)
button.MouseLeave:Connect(function()tip.Visible=false end)
end)
end
_G.xNgotMusicTooltip=tooltip
local lastCatalogCount=-1
local function onCatalogChanged()
local api=getApi()
if not api or type(api.MusicCatalog)~="function"then return end
local catalog=api:MusicCatalog()
if#catalog==lastCatalogCount then return end
lastCatalogCount=#catalog
debugLog("catalog:",tostring(#catalog))
pcall(function()
local list={}
for _,item in ipairs(catalog)do
if item.Thumbnail and item.Thumbnail~=""and(item.CoverAsset or"")==""then
list[#list+1]={
name=item.Name,
thumbnail=item.Thumbnail,
source=item.Source or"",
id=item.Value or item.Name,
}
end
end
if#list>0 then prefetch(list)end
end)
end
local function boot()
local api=getApi()
if not api then return false end
if type(api.MusicAiOnline)=="function"then
pcall(function()
local st=api:MusicAiOnlineState()
debugLog("ai:",tostring(st and st.mode))
end)
end
if type(api.OnMusicCatalogChanged)=="function"then
pcall(function()api:OnMusicCatalogChanged(function()
task.defer(onCatalogChanged)
end)end)
end
_G.xNgotUIReady=true
return true
end
if not boot()then
task.spawn(function()
for _=1,20 do
task.wait(0.5)
if boot()then return end
end
warn("[xNgotUI] không tìm thấy Window.DynamicIsland sau 10s")
end)
end
local function attach()
local api=getApi()
if not api then return false end
api.MusicQueue=function(_,prompt)queueSearch(prompt)end
api.MusicPreset=function(_,name)
local c=_G.xNgotMusicConfig
return c and c:Preset(name)or false
end
api.MusicConfig=function()
local c=_G.xNgotMusicConfig
return c and c:Get()or{}
end
return true
end
if not attach()then
task.spawn(function()
for _=1,20 do
task.wait(0.5)
if attach()then return end
end
end)
end
end
do
local function has(fn)
local ok,value=pcall(function()return _G[fn]end)
return ok and type(value)=="function"
end
local function folderExists(path)
if not has("isfolder")then return nil end
local ok,res=pcall(isfolder,path)
return ok and res==true
end
local function fileCount(folder)
if not has("listfiles")then return nil end
local ok,list=pcall(listfiles,folder)
if not ok or type(list)~="table"then return nil end
local n=0
for _,f in ipairs(list)do
if tostring(f):lower():match("%.mp3$")then n=n+1 end
end
return n
end
function _G.xNgotMusicDoctor()
local engine=_G.CrossAIMusic
local api=_G.xNgotMusicConfig
local island=(Window and Window.DynamicIsland)or nil
local report={
version="xNgot Audio v4",
checks={},
}
local function add(name,status,detail)
report.checks[#report.checks+1]={name=name,status=status,detail=detail}
end
local function out(message)
local logApi=_G.xNgotLog
if logApi and type(logApi.info)=="function"then pcall(logApi.info,"doctor",message)end
end
add("writefile",has("writefile")and"ok"or"fail",
"required to cache mp3 files")
add("readfile",has("readfile")and"ok"or"warn","read back cache files (ID3)")
add("isfile",has("isfile")and"ok"or"warn","check cache")
add("makefolder",has("makefolder")and"ok"or"warn","create the music folder")
add("listfiles",has("listfiles")and"ok"or"warn","count files in cache")
local assetFn=has("getcustomasset")and"getcustomasset"
or(has("getsynasset")and"getsynasset")or nil
add("getcustomasset",assetFn and"ok"or"fail","required to play mp3 files")
add("request/POST",(has("request")or has("http_request")or has("syn_request"))
and"ok"or"warn","PoW music download; falls back to HttpService")
if engine then
local st=type(engine.llmStatus)=="function"and engine.llmStatus()or{mode="local"}
add("engine","ok","Config.Folder = "..tostring(engine.Config and engine.Config.Folder))
add("parser offline",engine.parse and"ok"or"fail",
engine.parse and("\""..tostring(engine.parse("nhạc lofi buổi tối").query).."\"")or"")
add("PoW/SHA-256",engine.sha256 and"ok"or"fail",
engine.sha256 and engine.sha256("abc"):sub(1,8)or"")
add("AI local",st.mode=="local"and"ok"or"warn",
"offline, no network needed - learns from skipped tracks")
else
add("engine","fail","CrossAIMusic is not initialized")
end
if api then
local c=api:Get()
add("config","ok",string.format("topN=%s · raceTracks=%s · sources=%d",
tostring(c.topN),tostring(c.raceTracks),#(c.sources or{})))
else
add("config","fail","_G.xNgotMusicConfig is missing")
end
local need={"MusicSearch","MusicCatalog","MusicSelectValue","MusicQueue","MusicPreset"}
local missing={}
for _,fn in ipairs(need)do
if not island or type(island[fn])~="function"then missing[#missing+1]=fn end
end
add("Island API",#missing==0 and"ok"or"warn",
#missing==0 and"complete"or("missing: "..table.concat(missing,", ")))
local folder=engine and engine.Config and engine.Config.Folder or"xNgotLibrary/Music"
add("cache folder",folderExists(folder)==false and"not created yet (will be created)"or"ok",folder)
local n=fileCount(folder)
add("cached mp3 files",n and"ok"or"n/a",n and(tostring(n).." tracks")or"executor does not support listfiles")
local fails,warns=0,0
for _,c in ipairs(report.checks)do
local icon=c.status=="ok"and"OK"or(c.status=="fail"and"FAIL"or"!!")
if c.status=="fail"then fails=fails+1
elseif c.status~="ok"then warns=warns+1 end
out(string.format("[%s] %s · %s",icon,tostring(c.name),tostring(c.detail or"")))
end
out(string.format("doctor: %d errors, %d warnings",fails,warns))
if fails>0 then
out("thiếu writefile/getcustomasset -> không phát được nhạc (đổi executor).")
end
report.fails,report.warns=fails,warns
return report
end
local function attach()
local island=Window and Window.DynamicIsland
if not island then return false end
island.MusicDoctor=function()return _G.xNgotMusicDoctor()end
return true
end
if not attach()then
task.spawn(function()
for _=1,20 do
task.wait(0.5)
if attach()then return end
end
end)
end
end
LIB.ActiveDynamicIsland=islandAPI
else
Window.DynamicIslandError=tostring(islandAPI)
LIB.LastDynamicIslandError=Window.DynamicIslandError
local environment=type(getgenv)=="function"and getgenv()or _G
environment.xNgotStudioLastStartupError=Window.DynamicIslandError
warn("[xNgotStudio] Dynamic Island startup failed: "..Window.DynamicIslandError)
local partial=Gui:FindFirstChild("xNgotStudio_FullDynamicIsland")
if partial then partial:Destroy()end
end
local function islandCall(method,...)
local api=Window.DynamicIsland
if not api then return false end
local fn=api[method]
if type(fn)~="function"then return false end
local ok,result=pcall(fn,api,...)
if not ok then warn("[NgotStudio/Island] "..method..": "..tostring(result))end
return ok
end
local function changeIsland(key,value,method)
islandSettings[key]=value
if method=="Enable"then
islandCall("Enable",value)
elseif method=="Theme"or method=="Accent"then
islandCall(method,value)
else
islandCall("Set",key,value)
end
SAVECONFIG()
end
local defaults={
Enabled=true,Fps=false,Ping=false,Clock=false,
Expand=true,Split=true,RimLight=true,Ring=true,
Breathe=true,AutoHide=true,Sound=true,
Reverb=true,Language="en",Accent=1,Theme=1,
Volume=40,Duration=2.5,Blur=false,
}
for key,defaultValue in pairs(defaults)do
if islandSettings[key]==nil then islandSettings[key]=defaultValue end
end
if islandSettings.__fpsPingAutoOffV1~=true then
islandSettings.Fps=false
islandSettings.Ping=false
islandSettings.__fpsPingAutoOffV1=true
pcall(SAVECONFIG)
end
islandSettings.Language="en"
for key,value in pairs(islandSettings)do
if key=="Enabled"then islandCall("Enable",value)
elseif key=="Theme"or key=="Accent"then islandCall(key,value)
elseif defaults[key]~=nil then islandCall("Set",key,value)end
end
local IslandTab=Window:Tab({Title="Dynamic Island",Icon="audio-lines",__System=true})
Window.DynamicIslandTab=IslandTab
if Window.DynamicIslandError then
IslandTab:Paragraph({Title="Dynamic Island startup error",Desc=Window.DynamicIslandError})
end
SettingsTab:Section({Title="Dynamic Island",Default=true})
SettingsTab:Paragraph({Title="Integrated Dynamic Island",Desc="Music, Cross AI, alerts and timers are built into this library. No second UI library is loaded."})
SettingsTab:Button({Title="Open Dynamic Island Settings",Icon="audio-lines",Callback=function()Window:SelectTab("Dynamic Island")end})
IslandTab:Paragraph({Title="Dynamic Island v3",Desc="All controls are native to NgotStudio UI. Tap the island to toggle the window; hold for island controls."})
local function addToggle(title,key,desc)
IslandTab:Toggle({Title=title,Desc=desc or"",Default=islandSettings[key],Callback=function(value)
changeIsland(key,value,key=="Enabled"and"Enable"or nil)
end})
end
local function addSlider(title,key,minV,maxV)
IslandTab:Slider({Title=title,Value={Min=minV,Max=maxV,Default=islandSettings[key]},Callback=function(value)
changeIsland(key,tonumber(value)or minV)
end})
end
IslandTab:Section({Title="Display",Default=true})
addToggle("Enable Dynamic Island","Enabled")
addToggle("Show FPS","Fps")
addToggle("Show Clock","Clock")
addToggle("Auto Hide Notifications","AutoHide")
addToggle("Expand on Interaction","Expand")
addSlider("Notification Duration","Duration",1,12)
IslandTab:Button({Title="Send Test Notification",Callback=function()
Window:NotifyIsland("xNgot Library","Notification sent from the built-in library","success",3.5)
end})
IslandTab:Section({Title="Appearance",Default=false})
local themeLabels={"Dark","Light","Midnight","Ocean","Forest","Coffee","Sakura"}
IslandTab:Dropdown({Title="Island Theme",Values=themeLabels,Value=themeLabels[islandSettings.Theme]or"Dark",Callback=function(v)
local i=table.find(themeLabels,v)or 1
changeIsland("Theme",i,"Theme")
end})
local accentLabels={"Blue","Purple","Pink","Orange","Green","Cyan"}
IslandTab:Dropdown({Title="Island Accent",Values=accentLabels,Value=accentLabels[islandSettings.Accent]or"Blue",Callback=function(v)
local i=table.find(accentLabels,v)or 1
changeIsland("Accent",i,"Accent")
end})
IslandTab:Section({Title="Sound",Default=false})
addToggle("UI Sound","Sound")
addSlider("Sound Volume","Volume",0,100)
IslandTab:Section({Title="Music",Default=true})
do
local musicOptionIndexes={}
local musicOptionForIndex={}
local changingMusicOption=false
local refreshMusicOptions
local songSelector=IslandTab:Dropdown({
Title="Select Track",
Desc="Tracks from your music library; select one to play it instantly.",
Values={"Loading track list..."},
Value="Loading track list...",
Callback=function(label)
if changingMusicOption then return end
local trackIndex=musicOptionIndexes[label]
if trackIndex and islandCall("MusicSelect",trackIndex,true)then
islandSettings.SelectedMusicValue=label
SAVECONFIG()
end
end,
})
Window._MusicRowDecorate=function(value,button)
local rows=Window._MusicRowsByValue
local row=rows and rows[value]
if not row or type(row)~="table"then return end
local okKind=false
pcall(function()okKind=button:IsA("ImageButton")or button:IsA("TextButton")end)
if not okKind and type(button)~="table"then return end
if not button.Frame then return end
pcall(function()
local frame=button.Frame
if not frame or frame:GetAttribute("MusicRow")then return end
frame:SetAttribute("MusicRow",true)
local meta={}
if row.Artist~=""then table.insert(meta,row.Artist)end
if row.Duration~=""then table.insert(meta,row.Duration)end
if row.Source~=""then table.insert(meta,row.Source)end
local metaText=table.concat(meta," · ")
frame.Title.Text=row.Title
frame.Title.TextTruncate=Enum.TextTruncate.AtEnd
frame.Description.Text=metaText
frame.Description.Visible=metaText~=""
frame.Description.TextSize=13
frame.Description.TextXAlignment=Enum.TextXAlignment.Left
for _,child in ipairs(frame:GetChildren())do
if child:IsA("UIPadding")then child.PaddingLeft=UDim.new(0,48)end
end
local holder=Instance.new("Frame")
holder.Name="MusicThumb"
holder.AnchorPoint=Vector2 .new(0,0.5)
holder.Position=UDim2 .new(0,10,0.5,0)
holder.Size=UDim2 .fromOffset(28,28)
holder.BackgroundColor3=Color3 .fromRGB(72,76,88)
holder.BorderSizePixel=0
holder.ZIndex=3
holder.Parent=button
local round=Instance.new("UICorner",holder)
round.CornerRadius=UDim.new(0,7)
local asset=row.CoverAsset
if type(asset)=="string"and asset~=""then
local img=Instance.new("ImageLabel")
img.Name="Cover"
img.BackgroundTransparency=1
img.Size=UDim2 .fromScale(1,1)
img.ScaleType=Enum.ScaleType.Crop
img.Image=asset
img.ZIndex=4
img.Parent=holder
local imgRound=Instance.new("UICorner",img)
imgRound.CornerRadius=UDim.new(0,7)
else
local note=Instance.new("TextLabel")
note.BackgroundTransparency=1
note.Size=UDim2 .fromScale(1,1)
note.Font=Enum.Font.GothamBold
note.TextSize=14
note.TextColor3=Color3 .fromRGB(255,255,255)
note.Text="♪"
note.ZIndex=4
note.Parent=holder
end
end)
end
refreshMusicOptions=function()
local api=Window.DynamicIsland
if not api or type(api.MusicCatalog)~="function"then return end
local catalog,state=api:MusicCatalog()
local rowsApi=type(api.MusicRows)=="function"and select(1,api:MusicRows())or nil
local choices,byValue,byIndex,byValueRow,seen={},{},{},{},{}
for _,track in ipairs(catalog)do
local row=(rowsApi and rowsApi[track.Index])or track.Row or{}
local title=tostring(row.Title or track.Name or"Unknown track")
local artist=tostring(row.Artist or track.Artist or"")
local duration=tostring(row.Duration or track.Duration or"")
local source=tostring(row.Source or"")
local label=tostring(row.Value or track.Value or"")
if label==""then
label=string.format("%02d. %s",track.Index,title)
end
local base,dup=label,2
while seen[label]do
label=base.." ("..dup..")"
dup=dup+1
end
seen[label]=true
choices[#choices+1]=label
byValue[label]=track.Index
byIndex[track.Index]=label
byValueRow[label]={
Title=title,
Artist=artist,
Duration=duration,
Source=source,
CoverAsset=tostring(row.CoverAsset or track.CoverAsset or""),
Thumbnail=tostring(row.Thumbnail or track.Thumbnail or""),
}
end
if#choices==0 then
choices={
state=="failed"and"Network error, no music found"
or state=="localempty"and"No downloaded music yet — search and download your first track"
or state=="empty"and"No track matched"
or"Music AI is searching...",
}
end
musicOptionIndexes=byValue
musicOptionForIndex=byIndex
Window._MusicRowsByValue=byValueRow
Window._MusicTriggerLabels=Window._MusicTriggerLabels or{}
for value,info in pairs(byValueRow)do
local bits={info.Title}
if info.Artist~=""then bits[#bits+1]=info.Artist end
if info.Duration~=""then bits[#bits+1]=info.Duration end
Window._MusicTriggerLabels[value]=table.concat(bits," · ")
end
changingMusicOption=true
songSelector:Refresh(choices)
local function prettyTrigger()
local labels=Window._MusicTriggerLabels
local value=songSelector.Value
local text=value and labels and labels[value]
if not text then return end
local title=songSelector.Title
local box=title and title.BoxFrame
local trigger=box and box.Trigger
if trigger and trigger.Title then trigger.Title.Text=text end
end
Window._MusicPrettyTrigger=prettyTrigger
task.defer(prettyTrigger)
if#catalog>0 then
local currentChoice=musicOptionForIndex[api:State().MusicIndex]
local savedChoice=islandSettings.SelectedMusicValue or islandSettings.SelectedMusicSong
local selected=currentChoice or(byValue[savedChoice]and savedChoice)or choices[1]
songSelector:Select(selected)
if not api:State().Playing then
api:MusicSelect(byValue[selected],false)
end
else
songSelector:Select(choices[1])
end
changingMusicOption=false
end
Window._RefreshMusicLanguage=refreshMusicOptions
if Window.DynamicIsland then
Window.DynamicIsland:OnMusicCatalogChanged(function()
task.defer(refreshMusicOptions)
end)
Window.DynamicIsland:OnMusicChanged(function()
if changingMusicOption then return end
local api=Window.DynamicIsland
if not api then return end
local state=api:State()
local nextSong=musicOptionForIndex[state.MusicIndex]
if nextSong and songSelector.Value~=nextSong then
changingMusicOption=true
songSelector:Select(nextSong)
changingMusicOption=false
end
end)
refreshMusicOptions()
end
end
IslandTab:Button({Title="Play / Pause",Callback=function()islandCall("PlayMusic")end})
IslandTab:Button({Title="Next Track",Callback=function()islandCall("NextMusic",1)end})
IslandTab:Button({Title="Previous Track",Callback=function()islandCall("NextMusic",-1)end})
IslandTab:Slider({Title="Volume",Value={Min=0,Max=100,Default=40},Callback=function(v)islandCall("MusicVolume",v)end})
local aiMusicPrompt=""
IslandTab:Input({Title="Music description (AI)",
Placeholder="e.g. chill lofi music for the evening",
Callback=function(v)aiMusicPrompt=tostring(v or"")end})
IslandTab:Button({Title="Search with AI",
Callback=function()islandCall("MusicSearch",aiMusicPrompt)end})
local function cfgSet(key,value)
local c=_G.xNgotMusicConfig
if c and type(c.Set)=="function"then return c:Set(key,value)end
return false
end
local musicConfig=_G.xNgotMusicConfig
local regionLabels={auto="Auto",global="Global",VN="Vietnam",US="United States",KR="Korea",JP="Japan"}
local regionCodes={Auto="auto",Global="global",Vietnam="VN",["United States"]="US",Korea="KR",Japan="JP"}
local initialRegion=musicConfig and musicConfig:Get("region")or"auto"
IslandTab:Dropdown({Title="Music region",Desc="Auto uses Roblox region / locale. Region is a search preference, not a guaranteed language filter.",
Values={"Auto","Global","Vietnam","United States","Korea","Japan"},Value=regionLabels[initialRegion]or"Auto",
Callback=function(label)cfgSet("region",regionCodes[tostring(label)]or"auto")end})
local sourceLabels={youtube="YouTube",soundcloud="SoundCloud",audius="Audius"}
local sourceCodes={YouTube="youtube",SoundCloud="soundcloud",Audius="audius"}
local initialSources=musicConfig and musicConfig:Get("sources")or{}
local initialSource=#initialSources==1 and sourceLabels[initialSources[1]]or"All"
IslandTab:Dropdown({Title="Music platform",Desc="All searches YouTube, SoundCloud and Audius. Availability depends on the search service.",
Values={"All","YouTube","SoundCloud","Audius"},Value=initialSource or"All",
Callback=function(label)
local code=sourceCodes[tostring(label)]
cfgSet("sources",code and{code}or{"youtube","soundcloud","audius"})
end})
IslandTab:Toggle({Title="Preload next track",Desc="Prepare the next track from the current results at 50%; Auto play must be on.",
Default=not musicConfig or musicConfig:Get("prefetchNext")~=false,
Callback=function(v)cfgSet("prefetchNext",v)end})
IslandTab:Slider({Title="Results per search",Value={Min=4,Max=30,Default=12},
Callback=function(v)cfgSet("topN",v)end})
IslandTab:Slider({Title="Parallel downloads",Value={Min=1,Max=4,Default=2},
Callback=function(v)cfgSet("raceTracks",v)end})
IslandTab:Toggle({Title="Cover art in lists",Default=true,
Callback=function(v)cfgSet("coverArt",v)end})
IslandTab:Dropdown({Title="Quick preset",Values={"Default","Fast","Quality","Low data","Vietnamese"},
Value="Default",
Callback=function(label)
local map={Fast="fast",Quality="quality",["Low data"]="lowdata",Vietnamese="vietnamese"}
local name=map[tostring(label)]
if name and _G.xNgotMusicConfig then _G.xNgotMusicConfig:Preset(name)end
end})
IslandTab:Button({Title="Open Player in Island",Callback=function()islandCall("Expand","Music")end})
IslandTab:Section({Title="Storage & File Manager",Default=true})
IslandTab:Paragraph({Title="Downloaded music is loaded first",Desc="Every time the script starts, Select Track is filled from the mp3 files already downloaded in the cache folder. The script no longer auto-searches new 'lofi chill' music; it only searches when you type a description in the Music section and press Search with AI."})
local fmFiles,fmByLabel,fmSelectedPath,fmChanging={},{},nil,false
local fmStorage=IslandTab:Paragraph({Title="Downloaded Music Storage",Desc="Waiting to scan the cache folder..."})
local fmSelector=IslandTab:Dropdown({
Title="Downloaded Music Files",Desc="Select a file to play or delete it.",
Values={"No files yet"},Value="No files yet",
Callback=function(label)
if fmChanging then return end
fmSelectedPath=fmByLabel[tostring(label or"")]
end,
})
local function fmNotify(message,kind)
pcall(function()Window:NotifyIsland("File Manager",tostring(message),kind or"info",3)end)
end
local fmRefresh
fmRefresh=function(withSizes)
local api=Window.DynamicIsland
if not api or type(api.MusicFiles)~="function"then
fmStorage:SetDesc("Dynamic Island is not ready yet.")
return
end
local files,stats=api:MusicFiles(withSizes~=false)
files=type(files)=="table"and files or{}
stats=type(stats)=="table"and stats or{}
fmFiles,fmByLabel=files,{}
if stats.Supported==false then
fmStorage:SetDesc("This executor does not support listfiles, so the music folder cannot be scanned. An executor with listfiles / readfile / delfile is required.")
else
fmStorage:SetDesc(string.format("%d tracks · Total %s · MP3 %s · Covers %s (%d files) · Folder: %s",
tonumber(stats.Count)or#files,tostring(stats.TotalText or"0 B"),tostring(stats.Mp3Text or"0 B"),
tostring(stats.CoversText or"0 B"),tonumber(stats.CoversCount)or 0,tostring(stats.Folder or"xNgotLibrary/Music")))
end
local labels,seen={},{}
for index,file in ipairs(files)do
local label=string.format("%02d. %s",index,tostring(file.Title or file.FileName or"Downloaded track"))
if file.Artist and tostring(file.Artist)~=""then label=label.." — "..tostring(file.Artist)end
if file.SizeText and file.SizeText~=""then label=label.." · "..file.SizeText end
local base,dup=label,2
while seen[label]do label=base.." ("..dup..")";dup=dup+1 end
seen[label]=true
labels[#labels+1]=label
fmByLabel[label]=file.Path
end
if#labels==0 then labels={"No files yet"}end
fmChanging=true
fmSelector:Refresh(labels)
if files[1]then
fmSelector:Select(labels[1])
fmSelectedPath=files[1].Path
else
fmSelectedPath=nil
end
fmChanging=false
end
IslandTab:Button({Title="Rescan Storage & Files",Desc="Re-read the cache folder and total up MP3 + cover sizes.",Callback=function()
fmRefresh(true)
fmNotify("Downloaded music folder rescanned","success")
end})
IslandTab:Button({Title="Load Downloaded into Select Track",Desc="Replace the current track list with music downloaded on this device.",Callback=function()
local api=Window.DynamicIsland
local count=0
if api and type(api.MusicLoadDownloaded)=="function"then count=api:MusicLoadDownloaded()or 0 end
fmRefresh(true)
fmNotify(count>0 and("Loaded "..count.." downloaded tracks")or"No downloaded music files yet",count>0 and"success"or"warn")
end})
IslandTab:Button({Title="Play Selected File",Callback=function()
if not fmSelectedPath then fmNotify("Select a file first","warn");return end
local api=Window.DynamicIsland
local ok=api and type(api.MusicPlayFile)=="function"and api:MusicPlayFile(fmSelectedPath)
fmNotify(ok and"Playing the selected file"or"Could not play the selected file",ok and"success"or"warn")
end})
IslandTab:Button({Title="Delete Selected File",Callback=function()
if not fmSelectedPath then fmNotify("Select a file first","warn");return end
local path=fmSelectedPath
Window:Dialog({
Title="Delete Music File",Content="Delete this file from the cache folder?\n"..tostring(path),Icon="trash-2",
Buttons={
{Title="Cancel"},
{Title="Delete",Callback=function()
local api=Window.DynamicIsland
local ok,err=false,"Dynamic Island is not ready yet"
if api and type(api.MusicDeleteFile)=="function"then ok,err=api:MusicDeleteFile(path)end
if ok then
if api and type(api.MusicLoadDownloaded)=="function"then pcall(function()api:MusicLoadDownloaded()end)end
fmNotify("Selected file deleted","success")
else
fmNotify(tostring(err or"Could not delete the file"),"warn")
end
fmRefresh(true)
end},
},
})
end})
IslandTab:Button({Title="Delete All Downloaded Music",Desc="Only deletes .mp3 files in the music cache folder; config is kept.",Callback=function()
Window:Dialog({
Title="Delete All Downloaded Music",Content=string.format("Delete all %d downloaded mp3 files? Covers and config will be kept.",#fmFiles),Icon="trash-2",
Buttons={
{Title="Cancel"},
{Title="Delete all",Callback=function()
local api=Window.DynamicIsland
local deleted,failed=0,0
if api and type(api.MusicClearDownloaded)=="function"then deleted,failed=api:MusicClearDownloaded()end
if api and type(api.MusicLoadDownloaded)=="function"then pcall(function()api:MusicLoadDownloaded()end)end
fmRefresh(true)
fmNotify(string.format("Deleted %d files, %d failed",deleted,failed),failed==0 and"success"or"warn")
end},
},
})
end})
task.spawn(function()
for _=1,10 do
if Window.DynamicIsland and type(Window.DynamicIsland.MusicFiles)=="function"then break end
task.wait(0.5)
end
fmRefresh(true)
end)
Window:SetUILanguage()
end
if windowDestroyed then return Window end
WindowByTitle[Window.Title]=Window
startupMenuBuilt=true
releaseStartupIsland()
return Window
end
function LIB:Notify(data)
data=data or{}
if data.Native~=true and self.ActiveDynamicIsland and self.ActiveDynamicIsland.Enabled then
local api=self.ActiveDynamicIsland
local kind=data.Kind or"info"
if data.Icon=="circle-check"or data.Icon=="check"then kind="success"end
if data.Icon=="triangle-alert"then kind="warn"end
local ok,handled=pcall(api.Notify,api,
tostring(data.Title or"Notification"),tostring(data.Content or""),
kind,tonumber(data.Duration)or 4)
if ok and handled then return{Close=function()end}end
end
local Notification={}
local Notif={
Title=tostring(data.Title or"Notification"),
Content=tostring(data.Content or""),
Icon=data.Icon or"info",
Duration=math.max(0.1,tonumber(data.Duration)or 5)
}
local new=Templates.Notification:Clone()
local notificationParent=Gui.NotificationList
for i=#Windows,1,-1 do
local win=Windows[i]
if win and win.Parent and win.Visible and win.Tabs.Visible then
notificationParent=win.NotificationFrame.NotificationList
break
end
end
new.Parent=notificationParent
new.Items.Frame.Title.Text=Notif.Title
new.Items.Frame.Content.Text=Notif.Content
ApplyIcon(new.Items.Frame.Title.Icon,Notif.Icon)
new.Items.Position=UDim2 .new(0.75,0,0,0)
new.Visible=true
local closing=false
local function Close()
if new and not closing then
closing=true
local close=Tween(new.Items,{Position=UDim2 .new(0.75,0,0,0)},TweenConfigs.Notification)
task.wait(TweenConfigs.Notification.Duration-(TweenConfigs.Notification.Duration/2))
if new then
new:Destroy()
end
new=nil
end
end
new.Items.Frame.Title.Close.MouseButton1Click:Connect(Close)
local open=Tween(new.Items,{Position=UDim2 .new(0,0,0,0)},TweenConfigs.Notification)
open.Completed:Connect(function()
Tween(new.Items.TimerBarFill.Bar,{Size=UDim2 .new(0,0,1,0)},{Duration=Notif.Duration})
task.delay(Notif.Duration,Close)
end)
function Notification:Close()
Close()
end
return Notification
end
return LIB
end;
};
NgotStudio_MODULES[NgotStudio["3f"]]={
Closure=function()
local script=NgotStudio["3f"];
local Icons={
["lucide"]=require(script.Lucide),
}
local IconModule={
IconsType="lucide"
}
function IconModule.SetIconsType(iconType)
IconModule.IconsType=iconType
end
function IconModule.Icon(Icon,Type)
local iconType=Icons[Type or IconModule.IconsType]
if not iconType or type(iconType.Icons)~="table"or type(Icon)~="string"then return nil end
local iconData=iconType.Icons[Icon]
if iconData then
return{iconType.Spritesheets[tostring(iconData.Image)],iconData}
end
return nil
end
return IconModule
end;
};
NgotStudio_MODULES[NgotStudio["40"]]={
Closure=function()
local script=NgotStudio["40"];
return{Spritesheets={
["1"]="rbxassetid://131526378523863",
["10"]="rbxassetid://98656588890340",
["11"]="rbxassetid://122516128999742",
["12"]="rbxassetid://136045238860745",
["13"]="rbxassetid://138056954680929",
["14"]="rbxassetid://139241675471365",
["15"]="rbxassetid://120281540002144",
["16"]="rbxassetid://122481504913348",
["2"]="rbxassetid://125136326597802",
["3"]="rbxassetid://132619645919851",
["4"]="rbxassetid://124546836680911",
["5"]="rbxassetid://138714413596023",
["6"]="rbxassetid://95318701976229",
["7"]="rbxassetid://87465848394141",
["8"]="rbxassetid://77771201330939",
["9"]="rbxassetid://126006375824005",
},Icons={
["a-arrow-down"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["a-arrow-up"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["a-large-small"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["accessibility"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["activity"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["air-vent"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["airplay"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["alarm-clock-check"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["alarm-clock-minus"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["alarm-clock-off"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["alarm-clock-plus"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["alarm-clock"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["alarm-smoke"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["album"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-center-horizontal"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-center-vertical"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-center"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-end-horizontal"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-end-vertical"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-horizontal-distribute-center"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-horizontal-distribute-end"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-horizontal-distribute-start"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-horizontal-justify-center"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-horizontal-justify-end"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-horizontal-justify-start"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-horizontal-space-around"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-horizontal-space-between"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-justify"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-left"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-right"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-start-horizontal"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-start-vertical"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-vertical-distribute-center"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-vertical-distribute-end"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-vertical-distribute-start"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-vertical-justify-center"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-vertical-justify-end"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-vertical-justify-start"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-vertical-space-around"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["align-vertical-space-between"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["ambulance"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["ampersand"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["ampersands"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["amphora"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["anchor"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["angry"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["annoyed"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["antenna"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["anvil"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["aperture"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["app-window-mac"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["app-window"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["apple"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["archive-restore"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["archive-x"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["archive"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["armchair"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-big-down-dash"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-big-down"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-big-left-dash"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-big-left"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-big-right-dash"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-big-right"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-big-up-dash"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-big-up"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-0-1"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-1-0"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-a-z"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-from-line"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-left"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-narrow-wide"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-right"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-to-dot"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-to-line"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-up"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-wide-narrow"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down-z-a"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-down"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-left-from-line"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-left-right"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-left-to-line"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-left"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-right-from-line"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-right-left"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-right-to-line"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-right"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-0-1"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-1-0"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-a-z"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-down"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-from-dot"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-from-line"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-left"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-narrow-wide"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-right"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-to-line"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-wide-narrow"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up-z-a"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrow-up"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["arrows-up-from-line"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=1,
},
["asterisk"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["at-sign"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["atom"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["audio-lines"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["audio-waveform"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["award"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["axe"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["axis-3d"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["baby"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["backpack"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-alert"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-cent"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-check"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-dollar-sign"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-euro"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-help"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-indian-rupee"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-info"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-japanese-yen"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-minus"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-percent"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-plus"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-pound-sterling"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-russian-ruble"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-swiss-franc"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge-x"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["badge"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["baggage-claim"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["ban"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["banana"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bandage"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["banknote"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["barcode"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["baseline"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bath"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["battery-charging"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["battery-full"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["battery-low"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["battery-medium"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["battery-plus"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["battery-warning"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["battery"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["beaker"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bean-off"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bean"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bed-double"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bed-single"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bed"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["beef"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["beer-off"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["beer"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bell-dot"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bell-electric"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bell-minus"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bell-off"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bell-plus"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bell-ring"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bell"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["between-horizontal-end"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["between-horizontal-start"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["between-vertical-end"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["between-vertical-start"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["biceps-flexed"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bike"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["binary"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["binoculars"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["biohazard"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bird"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bitcoin"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["blend"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["blinds"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["blocks"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bluetooth-connected"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bluetooth-off"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bluetooth-searching"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bluetooth"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bold"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bolt"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bomb"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["bone"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-a"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-audio"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-check"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-copy"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-dashed"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-down"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-headphones"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-heart"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-image"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-key"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-lock"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-marked"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-minus"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-open-check"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-open-text"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-open"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-plus"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-text"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-type"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-up-2"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=2,
},
["book-up"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["book-user"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["book-x"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["book"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bookmark-check"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bookmark-minus"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bookmark-plus"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bookmark-x"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bookmark"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["boom-box"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bot-message-square"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bot-off"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bot"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["box"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["boxes"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["braces"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["brackets"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["brain-circuit"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["brain-cog"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["brain"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["brick-wall"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["briefcase-business"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["briefcase-conveyor-belt"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["briefcase-medical"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["briefcase"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bring-to-front"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["brush"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bug-off"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bug-play"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bug"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["building-2"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["building"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bus-front"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["bus"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["cable-car"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["cable"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["cake-slice"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["cake"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calculator"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-1"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-arrow-down"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-arrow-up"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-check-2"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-check"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-clock"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-cog"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-days"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-fold"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-heart"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-minus-2"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-minus"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-off"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-plus-2"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-plus"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-range"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-search"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-sync"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-x-2"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar-x"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["calendar"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["camera-off"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["camera"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["candy-cane"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["candy-off"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["candy"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["cannabis"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["captions-off"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["captions"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["car-front"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["car-taxi-front"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["car"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["caravan"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["carrot"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["case-lower"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["case-sensitive"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["case-upper"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["cassette-tape"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["cast"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["castle"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["cat"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["cctv"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-area"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-bar-big"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-bar-decreasing"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-bar-increasing"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-bar-stacked"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-bar"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-candlestick"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-column-big"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-column-decreasing"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-column-increasing"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-column-stacked"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-column"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-gantt"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-line"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-network"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-no-axes-column-decreasing"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-no-axes-column-increasing"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-no-axes-column"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-no-axes-combined"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=3,
},
["chart-no-axes-gantt"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chart-pie"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chart-scatter"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chart-spline"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["check-check"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["check"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chef-hat"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["cherry"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevron-down"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevron-first"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevron-last"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevron-left"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevron-right"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevron-up"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevrons-down-up"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevrons-down"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevrons-left-right-ellipsis"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevrons-left-right"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevrons-left"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevrons-right-left"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevrons-right"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevrons-up-down"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chevrons-up"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["chrome"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["church"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["cigarette-off"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["cigarette"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-alert"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-arrow-down"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-arrow-left"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-arrow-out-down-left"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-arrow-out-down-right"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-arrow-out-up-left"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-arrow-out-up-right"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-arrow-right"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-arrow-up"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-check-big"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-check"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-chevron-down"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-chevron-left"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-chevron-right"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-chevron-up"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-dashed"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-divide"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-dollar-sign"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-dot-dashed"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-dot"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-ellipsis"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-equal"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-fading-arrow-up"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-fading-plus"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-gauge"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-help"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-minus"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-off"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-parking-off"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-parking"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-pause"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-percent"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-play"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-plus"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-power"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-slash-2"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-slash"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-stop"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-user-round"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-user"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle-x"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circle"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["circuit-board"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["citrus"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clapperboard"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard-check"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard-copy"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard-list"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard-minus"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard-paste"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard-pen-line"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard-pen"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard-plus"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard-type"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard-x"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clipboard"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-1"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-10"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-11"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-12"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-2"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-3"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-4"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-5"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-6"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-7"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-8"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-9"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-alert"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-arrow-down"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock-arrow-up"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["clock"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["cloud-alert"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=4,
},
["cloud-cog"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-download"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-drizzle"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-fog"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-hail"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-lightning"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-moon-rain"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-moon"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-off"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-rain-wind"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-rain"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-snow"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-sun-rain"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-sun"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud-upload"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloud"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cloudy"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["clover"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["club"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["code-xml"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["code"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["codepen"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["codesandbox"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["coffee"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cog"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["coins"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["columns-2"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["columns-3"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["columns-4"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["combine"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["command"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["compass"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["component"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["computer"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["concierge-bell"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cone"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["construction"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["contact-round"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["contact"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["container"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["contrast"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cookie"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cooking-pot"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["copy-check"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["copy-minus"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["copy-plus"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["copy-slash"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["copy-x"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["copy"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["copyleft"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["copyright"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["corner-down-left"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["corner-down-right"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["corner-left-down"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["corner-left-up"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["corner-right-down"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["corner-right-up"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["corner-up-left"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["corner-up-right"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cpu"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["creative-commons"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["credit-card"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["croissant"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["crop"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cross"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["crosshair"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["crown"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cuboid"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cup-soda"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["currency"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["cylinder"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dam"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["database-backup"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["database-zap"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["database"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["delete"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dessert"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["diameter"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["diamond-minus"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["diamond-percent"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["diamond-plus"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["diamond"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dice-1"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dice-2"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dice-3"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dice-4"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dice-5"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dice-6"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dices"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["diff"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["disc-2"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["disc-3"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["disc-album"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["disc"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["divide"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dna-off"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dna"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dock"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dog"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["dollar-sign"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=5,
},
["donut"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["door-closed"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["door-open"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["dot"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["download"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["drafting-compass"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["drama"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["dribbble"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["drill"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["droplet-off"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["droplet"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["droplets"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["drum"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["drumstick"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["dumbbell"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["ear-off"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["ear"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["earth-lock"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["earth"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["eclipse"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["egg-fried"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["egg-off"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["egg"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["ellipsis-vertical"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["ellipsis"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["equal-approximately"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["equal-not"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["equal"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["eraser"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["ethernet-port"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["euro"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["expand"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["external-link"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["eye-closed"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["eye-off"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["eye"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["facebook"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["factory"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["fan"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["fast-forward"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["feather"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["fence"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["ferris-wheel"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["figma"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-archive"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-audio-2"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-audio"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-axis-3d"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-badge-2"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-badge"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-box"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-chart-column-increasing"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-chart-column"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-chart-line"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-chart-pie"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-check-2"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-check"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-clock"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-code-2"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-code"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-cog"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-diff"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-digit"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-down"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-heart"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-image"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-input"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-json-2"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-json"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-key-2"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-key"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-lock-2"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-lock"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-minus-2"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-minus"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-music"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-output"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-pen-line"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-pen"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-plus-2"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-plus"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-question"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-scan"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-search-2"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-search"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-sliders"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-spreadsheet"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-stack"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-symlink"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-terminal"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-text"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-type-2"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-type"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-up"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-user"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-video-2"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-video"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-volume-2"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-volume"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-warning"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=6,
},
["file-x-2"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["file-x"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["file"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["files"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["film"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["filter-x"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["filter"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["fingerprint"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["fire-extinguisher"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["fish-off"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["fish-symbol"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["fish"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flag-off"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flag-triangle-left"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flag-triangle-right"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flag"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flame-kindling"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flame"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flashlight-off"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flashlight"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flask-conical-off"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flask-conical"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flask-round"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flip-horizontal-2"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flip-horizontal"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flip-vertical-2"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flip-vertical"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flower-2"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["flower"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["focus"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["fold-horizontal"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["fold-vertical"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-archive"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-check"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-clock"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-closed"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-code"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-cog"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-dot"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-down"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-git-2"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-git"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-heart"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-input"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-kanban"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-key"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-lock"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-minus"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-open-dot"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-open"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-output"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-pen"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-plus"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-root"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-search-2"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-search"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-symlink"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-sync"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-tree"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-up"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder-x"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folder"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["folders"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["footprints"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["forklift"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["forward"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["frame"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["framer"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["frown"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["fuel"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["fullscreen"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gallery-horizontal-end"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gallery-horizontal"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gallery-thumbnails"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gallery-vertical-end"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gallery-vertical"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gamepad-2"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gamepad"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gauge"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gavel"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gem"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["ghost"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gift"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-branch-plus"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-branch"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-commit-horizontal"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-commit-vertical"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-compare-arrows"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-compare"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-fork"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-graph"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-merge"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-pull-request-arrow"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-pull-request-closed"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-pull-request-create-arrow"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-pull-request-create"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-pull-request-draft"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["git-pull-request"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["github"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["gitlab"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=7,
},
["glass-water"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["glasses"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["globe-lock"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["globe"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["goal"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["grab"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["graduation-cap"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["grape"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["grid-2x2-check"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["grid-2x2-plus"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["grid-2x2-x"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["grid-2x2"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["grid-3x3"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["grip-horizontal"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["grip-vertical"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["grip"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["group"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["guitar"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["ham"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hammer"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hand-coins"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hand-heart"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hand-helping"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hand-metal"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hand-platter"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hand"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["handshake"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hard-drive-download"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hard-drive-upload"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hard-drive"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hard-hat"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hash"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["haze"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hdmi-port"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heading-1"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heading-2"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heading-3"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heading-4"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heading-5"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heading-6"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heading"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["headphone-off"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["headphones"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["headset"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heart-crack"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heart-handshake"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heart-off"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heart-pulse"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heart"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["heater"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hexagon"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["highlighter"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["history"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hop-off"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hop"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hospital"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hotel"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["hourglass"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["house-plug"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["house-plus"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["house-wifi"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["house"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["ice-cream-bowl"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["ice-cream-cone"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["id-card"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["image-down"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["image-minus"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["image-off"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["image-play"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["image-plus"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["image-up"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["image-upscale"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["image"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["images"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["import"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["inbox"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["indent-decrease"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["indent-increase"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["indian-rupee"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["infinity"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["info"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["inspection-panel"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["instagram"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["italic"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["iteration-ccw"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["iteration-cw"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["japanese-yen"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["joystick"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["kanban"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["key-round"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["key-square"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["key"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["keyboard-music"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["keyboard-off"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["keyboard"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["lamp-ceiling"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["lamp-desk"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["lamp-floor"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["lamp-wall-down"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["lamp-wall-up"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=8,
},
["lamp"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["land-plot"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["landmark"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["languages"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["laptop-minimal-check"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["laptop-minimal"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["laptop"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["lasso-select"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["lasso"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["laugh"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["layers-2"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["layers"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["layout-dashboard"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["layout-grid"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["layout-list"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["layout-panel-left"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["layout-panel-top"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["layout-template"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["leaf"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["leafy-green"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["lectern"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["letter-text"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["library-big"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["library"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["life-buoy"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["ligature"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["lightbulb-off"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["lightbulb"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["link-2-off"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["link-2"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["link"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["linkedin"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-check"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-checks"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-collapse"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-end"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-filter-plus"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-filter"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-minus"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-music"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-ordered"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-plus"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-restart"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-start"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-todo"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-tree"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-video"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list-x"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["list"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["loader-circle"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["loader-pinwheel"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["loader"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["locate-fixed"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["locate-off"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["locate"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["lock-keyhole-open"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["lock-keyhole"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["lock-open"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["lock"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["log-in"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["log-out"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["logs"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["lollipop"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["luggage"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["magnet"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mail-check"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mail-minus"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mail-open"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mail-plus"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mail-question"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mail-search"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mail-warning"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mail-x"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mail"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mailbox"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["mails"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin-check-inside"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin-check"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin-house"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin-minus-inside"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin-minus"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin-off"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin-plus-inside"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin-plus"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin-x-inside"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin-x"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pin"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-pinned"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map-plus"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["map"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["martini"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["maximize-2"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["maximize"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["medal"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["megaphone-off"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["megaphone"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["meh"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["memory-stick"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["menu"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["merge"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=9,
},
["message-circle-code"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-circle-dashed"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-circle-heart"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-circle-more"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-circle-off"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-circle-plus"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-circle-question"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-circle-reply"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-circle-warning"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-circle-x"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-circle"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-code"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-dashed"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-diff"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-dot"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-heart"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-lock"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-more"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-off"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-plus"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-quote"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-reply"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-share"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-text"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-warning"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square-x"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["message-square"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["messages-square"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mic-off"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mic-vocal"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mic"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["microchip"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["microscope"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["microwave"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["milestone"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["milk-off"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["milk"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["minimize-2"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["minimize"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["minus"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-check"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-cog"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-dot"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-down"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-off"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-pause"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-play"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-smartphone"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-speaker"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-stop"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-up"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor-x"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["monitor"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["moon-star"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["moon"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mountain-snow"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mountain"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mouse-off"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mouse-pointer-2"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mouse-pointer-ban"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mouse-pointer-click"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mouse-pointer"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["mouse"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-3d"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-diagonal-2"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-diagonal"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-down-left"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-down-right"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-down"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-horizontal"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-left"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-right"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-up-left"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-up-right"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-up"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move-vertical"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["move"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["music-2"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["music-3"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["music-4"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["music"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["navigation-2-off"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["navigation-2"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["navigation-off"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["navigation"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["network"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["newspaper"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["nfc"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["notebook-pen"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["notebook-tabs"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["notebook-text"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["notebook"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["notepad-text-dashed"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["notepad-text"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["nut-off"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["nut"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["octagon-alert"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["octagon-minus"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["octagon-pause"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["octagon-x"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=10,
},
["octagon"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["omega"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["option"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["orbit"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["origami"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["package-2"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["package-check"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["package-minus"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["package-open"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["package-plus"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["package-search"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["package-x"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["package"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["paint-bucket"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["paint-roller"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["paintbrush-vertical"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["paintbrush"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["palette"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-bottom-close"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-bottom-dashed"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-bottom-open"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-bottom"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-left-close"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-left-dashed"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-left-open"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-left"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-right-close"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-right-dashed"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-right-open"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-right"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-top-close"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-top-dashed"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-top-open"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panel-top"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panels-left-bottom"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panels-right-bottom"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["panels-top-left"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["paperclip"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["parentheses"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["parking-meter"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["party-popper"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pause"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["paw-print"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pc-case"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pen-line"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pen-off"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pen-tool"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pen"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pencil-line"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pencil-off"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pencil-ruler"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pencil"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pentagon"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["percent"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["person-standing"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["philippine-peso"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["phone-call"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["phone-forwarded"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["phone-incoming"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["phone-missed"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["phone-off"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["phone-outgoing"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["phone"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pi"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["piano"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pickaxe"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["picture-in-picture-2"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["picture-in-picture"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["piggy-bank"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pilcrow-left"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pilcrow-right"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pilcrow"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pill-bottle"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pill"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pin-off"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pin"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pipette"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pizza"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["plane-landing"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["plane-takeoff"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["plane"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["play"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["plug-2"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["plug-zap"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["plug"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["plus"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pocket-knife"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pocket"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["podcast"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pointer-off"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pointer"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["popcorn"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["popsicle"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["pound-sterling"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["power-off"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["power"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["presentation"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["printer-check"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["printer"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["projector"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=11,
},
["proportions"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["puzzle"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["pyramid"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["qr-code"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["quote"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rabbit"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["radar"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["radiation"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["radical"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["radio-receiver"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["radio-tower"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["radio"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["radius"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rail-symbol"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rainbow"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rat"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["ratio"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["receipt-cent"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["receipt-euro"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["receipt-indian-rupee"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["receipt-japanese-yen"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["receipt-pound-sterling"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["receipt-russian-ruble"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["receipt-swiss-franc"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["receipt-text"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["receipt"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rectangle-ellipsis"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rectangle-horizontal"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rectangle-vertical"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["recycle"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["redo-2"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["redo-dot"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["redo"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["refresh-ccw-dot"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["refresh-ccw"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["refresh-cw-off"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["refresh-cw"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["refrigerator"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["regex"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["remove-formatting"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["repeat-1"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["repeat-2"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["repeat"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["replace-all"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["replace"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["reply-all"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["reply"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rewind"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["ribbon"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rocket"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rocking-chair"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["roller-coaster"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rotate-3d"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rotate-ccw-square"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rotate-ccw"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rotate-cw-square"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rotate-cw"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["route-off"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["route"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["router"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rows-2"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rows-3"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rows-4"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["rss"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["ruler"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["russian-ruble"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["sailboat"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["salad"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["sandwich"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["satellite-dish"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["satellite"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["save-all"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["save-off"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["save"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scale-3d"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scale"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scaling"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scan-barcode"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scan-eye"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scan-face"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scan-heart"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scan-line"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scan-qr-code"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scan-search"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scan-text"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scan"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["school"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scissors-line-dashed"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scissors"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["screen-share-off"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["screen-share"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scroll-text"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["scroll"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["search-check"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["search-code"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["search-slash"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["search-x"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["search"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["section"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["send-horizontal"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=12,
},
["send-to-back"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["send"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["separator-horizontal"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["separator-vertical"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["server-cog"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["server-crash"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["server-off"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["server"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["settings-2"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["settings"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shapes"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["share-2"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["share"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["sheet"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shell"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield-alert"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield-ban"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield-check"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield-ellipsis"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield-half"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield-minus"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield-off"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield-plus"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield-question"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield-x"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shield"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["ship-wheel"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["ship"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shirt"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shopping-bag"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shopping-basket"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shopping-cart"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shovel"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shower-head"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shrink"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shrub"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["shuffle"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["sigma"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["signal-high"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["signal-low"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["signal-medium"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["signal-zero"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["signal"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["signature"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["signpost-big"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["signpost"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["siren"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["skip-back"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["skip-forward"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["skull"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["slack"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["slash"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["slice"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["sliders-horizontal"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["sliders-vertical"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["smartphone-charging"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["smartphone-nfc"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["smartphone"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["smile-plus"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["smile"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["snail"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["snowflake"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["sofa"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["soup"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["space"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["spade"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["sparkle"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["sparkles"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["speaker"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["speech"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["spell-check-2"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["spell-check"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["spline"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["split"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["spray-can"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["sprout"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-activity"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-down-left"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-down-right"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-down"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-left"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-out-down-left"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-out-down-right"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-out-up-left"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-out-up-right"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-right"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-up-left"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-up-right"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-arrow-up"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-asterisk"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-bottom-dashed-scissors"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-chart-gantt"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-check-big"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-check"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-chevron-down"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-chevron-left"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-chevron-right"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-chevron-up"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-code"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-dashed-bottom-code"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=13,
},
["square-dashed-bottom"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-dashed-kanban"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-dashed-mouse-pointer"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-dashed"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-divide"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-dot"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-equal"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-function"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-kanban"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-library"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-m"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-menu"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-minus"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-mouse-pointer"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-parking-off"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-parking"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-pen"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-percent"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-pi"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-pilcrow"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-play"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-plus"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-power"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-radical"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-scissors"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-sigma"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-slash"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-split-horizontal"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-split-vertical"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-square"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-stack"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-terminal"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-user-round"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-user"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square-x"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["square"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["squircle"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["squirrel"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["stamp"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["star-half"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["star-off"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["star"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["step-back"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["step-forward"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["stethoscope"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["sticker"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["sticky-note"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["store"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["stretch-horizontal"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["stretch-vertical"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["strikethrough"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["subscript"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["sun-dim"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["sun-medium"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["sun-moon"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["sun-snow"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["sun"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["sunrise"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["sunset"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["superscript"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["swatch-book"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["swiss-franc"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["switch-camera"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["sword"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["swords"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["syringe"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["table-2"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["table-cells-merge"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["table-cells-split"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["table-columns-split"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["table-of-contents"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["table-properties"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["table-rows-split"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["table"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tablet-smartphone"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tablet"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tablets"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tag"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tags"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tally-1"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tally-2"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tally-3"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tally-4"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tally-5"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tangent"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["target"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["telescope"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tent-tree"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["tent"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["terminal"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["test-tube-diagonal"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["test-tube"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["test-tubes"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["text-cursor-input"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["text-cursor"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["text-quote"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["text-search"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["text-select"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["text"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["theater"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=14,
},
["thermometer-snowflake"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["thermometer-sun"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["thermometer"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["thumbs-down"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["thumbs-up"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["ticket-check"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["ticket-minus"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["ticket-percent"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["ticket-plus"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["ticket-slash"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["ticket-x"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["ticket"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tickets-plane"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tickets"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["timer-off"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["timer-reset"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["timer"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["toggle-left"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["toggle-right"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["toilet"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tornado"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["torus"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["touchpad-off"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["touchpad"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tower-control"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["toy-brick"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tractor"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["traffic-cone"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["train-front-tunnel"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["train-front"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["train-track"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tram-front"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["trash-2"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["trash"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tree-deciduous"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tree-palm"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tree-pine"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["trees"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["trello"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["trending-down"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["trending-up-down"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["trending-up"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["triangle-alert"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["triangle-dashed"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["triangle-right"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["triangle"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["trophy"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["truck"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["turtle"]={
ImageRectPosition=Vector2 .new(768,384),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tv-minimal-play"]={
ImageRectPosition=Vector2 .new(864,384),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tv-minimal"]={
ImageRectPosition=Vector2 .new(0,480),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["tv"]={
ImageRectPosition=Vector2 .new(96,480),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["twitch"]={
ImageRectPosition=Vector2 .new(192,480),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["twitter"]={
ImageRectPosition=Vector2 .new(288,480),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["type-outline"]={
ImageRectPosition=Vector2 .new(384,480),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["type"]={
ImageRectPosition=Vector2 .new(480,480),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["umbrella-off"]={
ImageRectPosition=Vector2 .new(576,480),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["umbrella"]={
ImageRectPosition=Vector2 .new(672,480),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["underline"]={
ImageRectPosition=Vector2 .new(768,480),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["undo-2"]={
ImageRectPosition=Vector2 .new(864,480),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["undo-dot"]={
ImageRectPosition=Vector2 .new(0,576),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["undo"]={
ImageRectPosition=Vector2 .new(96,576),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["unfold-horizontal"]={
ImageRectPosition=Vector2 .new(192,576),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["unfold-vertical"]={
ImageRectPosition=Vector2 .new(288,576),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["ungroup"]={
ImageRectPosition=Vector2 .new(384,576),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["university"]={
ImageRectPosition=Vector2 .new(480,576),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["unlink-2"]={
ImageRectPosition=Vector2 .new(576,576),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["unlink"]={
ImageRectPosition=Vector2 .new(672,576),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["unplug"]={
ImageRectPosition=Vector2 .new(768,576),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["upload"]={
ImageRectPosition=Vector2 .new(864,576),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["usb"]={
ImageRectPosition=Vector2 .new(0,672),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-check"]={
ImageRectPosition=Vector2 .new(96,672),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-cog"]={
ImageRectPosition=Vector2 .new(192,672),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-minus"]={
ImageRectPosition=Vector2 .new(288,672),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-pen"]={
ImageRectPosition=Vector2 .new(384,672),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-plus"]={
ImageRectPosition=Vector2 .new(480,672),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-round-check"]={
ImageRectPosition=Vector2 .new(576,672),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-round-cog"]={
ImageRectPosition=Vector2 .new(672,672),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-round-minus"]={
ImageRectPosition=Vector2 .new(768,672),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-round-pen"]={
ImageRectPosition=Vector2 .new(864,672),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-round-plus"]={
ImageRectPosition=Vector2 .new(0,768),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-round-search"]={
ImageRectPosition=Vector2 .new(96,768),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-round-x"]={
ImageRectPosition=Vector2 .new(192,768),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-round"]={
ImageRectPosition=Vector2 .new(288,768),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-search"]={
ImageRectPosition=Vector2 .new(384,768),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user-x"]={
ImageRectPosition=Vector2 .new(480,768),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["user"]={
ImageRectPosition=Vector2 .new(576,768),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["users-round"]={
ImageRectPosition=Vector2 .new(672,768),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["users"]={
ImageRectPosition=Vector2 .new(768,768),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["utensils-crossed"]={
ImageRectPosition=Vector2 .new(864,768),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["utensils"]={
ImageRectPosition=Vector2 .new(0,864),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["utility-pole"]={
ImageRectPosition=Vector2 .new(96,864),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["variable"]={
ImageRectPosition=Vector2 .new(192,864),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["vault"]={
ImageRectPosition=Vector2 .new(288,864),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["vegan"]={
ImageRectPosition=Vector2 .new(384,864),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["venetian-mask"]={
ImageRectPosition=Vector2 .new(480,864),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["vibrate-off"]={
ImageRectPosition=Vector2 .new(576,864),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["vibrate"]={
ImageRectPosition=Vector2 .new(672,864),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["video-off"]={
ImageRectPosition=Vector2 .new(768,864),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["video"]={
ImageRectPosition=Vector2 .new(864,864),
ImageRectSize=Vector2 .new(96,96),
Image=15,
},
["videotape"]={
ImageRectPosition=Vector2 .new(0,0),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["view"]={
ImageRectPosition=Vector2 .new(96,0),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["voicemail"]={
ImageRectPosition=Vector2 .new(192,0),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["volleyball"]={
ImageRectPosition=Vector2 .new(288,0),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["volume-1"]={
ImageRectPosition=Vector2 .new(384,0),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["volume-2"]={
ImageRectPosition=Vector2 .new(480,0),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["volume-off"]={
ImageRectPosition=Vector2 .new(576,0),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["volume-x"]={
ImageRectPosition=Vector2 .new(672,0),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["volume"]={
ImageRectPosition=Vector2 .new(768,0),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["vote"]={
ImageRectPosition=Vector2 .new(864,0),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wallet-cards"]={
ImageRectPosition=Vector2 .new(0,96),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wallet-minimal"]={
ImageRectPosition=Vector2 .new(96,96),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wallet"]={
ImageRectPosition=Vector2 .new(192,96),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wallpaper"]={
ImageRectPosition=Vector2 .new(288,96),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wand-sparkles"]={
ImageRectPosition=Vector2 .new(384,96),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wand"]={
ImageRectPosition=Vector2 .new(480,96),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["warehouse"]={
ImageRectPosition=Vector2 .new(576,96),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["washing-machine"]={
ImageRectPosition=Vector2 .new(672,96),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["watch"]={
ImageRectPosition=Vector2 .new(768,96),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["waves-ladder"]={
ImageRectPosition=Vector2 .new(864,96),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["waves"]={
ImageRectPosition=Vector2 .new(0,192),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["waypoints"]={
ImageRectPosition=Vector2 .new(96,192),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["webcam"]={
ImageRectPosition=Vector2 .new(192,192),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["webhook-off"]={
ImageRectPosition=Vector2 .new(288,192),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["webhook"]={
ImageRectPosition=Vector2 .new(384,192),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["weight"]={
ImageRectPosition=Vector2 .new(480,192),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wheat-off"]={
ImageRectPosition=Vector2 .new(576,192),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wheat"]={
ImageRectPosition=Vector2 .new(672,192),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["whole-word"]={
ImageRectPosition=Vector2 .new(768,192),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wifi-high"]={
ImageRectPosition=Vector2 .new(864,192),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wifi-low"]={
ImageRectPosition=Vector2 .new(0,288),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wifi-off"]={
ImageRectPosition=Vector2 .new(96,288),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wifi-zero"]={
ImageRectPosition=Vector2 .new(192,288),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wifi"]={
ImageRectPosition=Vector2 .new(288,288),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wind-arrow-down"]={
ImageRectPosition=Vector2 .new(384,288),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wind"]={
ImageRectPosition=Vector2 .new(480,288),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wine-off"]={
ImageRectPosition=Vector2 .new(576,288),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wine"]={
ImageRectPosition=Vector2 .new(672,288),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["workflow"]={
ImageRectPosition=Vector2 .new(768,288),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["worm"]={
ImageRectPosition=Vector2 .new(864,288),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wrap-text"]={
ImageRectPosition=Vector2 .new(0,384),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["wrench"]={
ImageRectPosition=Vector2 .new(96,384),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["x"]={
ImageRectPosition=Vector2 .new(192,384),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["youtube"]={
ImageRectPosition=Vector2 .new(288,384),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["zap-off"]={
ImageRectPosition=Vector2 .new(384,384),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["zap"]={
ImageRectPosition=Vector2 .new(480,384),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["zoom-in"]={
ImageRectPosition=Vector2 .new(576,384),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
["zoom-out"]={
ImageRectPosition=Vector2 .new(672,384),
ImageRectSize=Vector2 .new(96,96),
Image=16,
},
}
}
end;
};
LIB=require(NgotStudio["3e"])
local function __xNgotShowStartupError(message)
local details=tostring(message or"Unknown error")
local environment=type(getgenv)=="function"and getgenv()or _G
environment.xNgotStudioLastStartupError=details
warn("[xNgotStudio] Startup error: "..details)
pcall(function()
local players=game:GetService("Players")
local player=players.LocalPlayer
local parent=player and(player:FindFirstChildOfClass("PlayerGui")or player:WaitForChild("PlayerGui",5))
if not parent then parent=game:GetService("CoreGui")end
local old=parent:FindFirstChild("xNgotStudio_StartupError")
if old then old:Destroy()end
local screen=Instance.new("ScreenGui")
screen.Name="xNgotStudio_StartupError"
screen.ResetOnSpawn=false
screen.IgnoreGuiInset=true
screen.DisplayOrder=2147483000
screen.Parent=parent
local panel=Instance.new("Frame")
panel.Name="ErrorPanel"
panel.AnchorPoint=Vector2 .new(0.5,0)
panel.Position=UDim2 .new(0.5,0,0,52)
panel.Size=UDim2 .new(0.9,0,0,220)
panel.BackgroundColor3=Color3 .fromRGB(24,29,40)
panel.BorderSizePixel=0
panel.Parent=screen
local limit=Instance.new("UISizeConstraint")
limit.MaxSize=Vector2 .new(480,220)
limit.Parent=panel
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,12)
local heading=Instance.new("TextLabel")
heading.BackgroundTransparency=1
heading.Position=UDim2 .fromOffset(14,8)
heading.Size=UDim2 .new(1,-28,0,28)
heading.Text="xNgotStudio | Startup Error"
heading.TextColor3=Color3 .fromRGB(255,185,173)
heading.TextSize=15
heading.Font=Enum.Font.GothamBold
heading.TextXAlignment=Enum.TextXAlignment.Left
heading.Parent=panel
local body=Instance.new("TextBox")
body.Name="ErrorDetails"
body.Position=UDim2 .fromOffset(14,40)
body.Size=UDim2 .new(1,-28,1,-89)
body.BackgroundColor3=Color3 .fromRGB(16,20,29)
body.BorderSizePixel=0
body.TextColor3=Color3 .fromRGB(243,216,210)
body.Font=Enum.Font.Code
body.TextSize=12
body.TextWrapped=true
body.TextXAlignment=Enum.TextXAlignment.Left
body.TextYAlignment=Enum.TextYAlignment.Top
body.MultiLine=true
body.TextEditable=false
body.ClearTextOnFocus=false
body.Text=details
body.Parent=panel
Instance.new("UICorner",body).CornerRadius=UDim.new(0,7)
local copy=Instance.new("TextButton")
copy.Text="Copy Error"
copy.Font=Enum.Font.GothamSemibold
copy.TextSize=12
copy.BackgroundColor3=Color3 .fromRGB(46,115,203)
copy.TextColor3=Color3 .new(1,1,1)
copy.Position=UDim2 .new(1,-120,1,-40)
copy.Size=UDim2 .fromOffset(105,28)
copy.Parent=panel
Instance.new("UICorner",copy).CornerRadius=UDim.new(0,7)
copy.MouseButton1Click:Connect(function()
local clipboard=setclipboard or toclipboard
if type(clipboard)=="function"then
local ok=pcall(clipboard,details)
copy.Text=ok and"Copied"or"Copy failed"
end
end)
local close=Instance.new("TextButton")
close.Text="Close"
close.Font=Enum.Font.Gotham
close.TextSize=12
close.BackgroundTransparency=1
close.TextColor3=Color3 .new(0.85,0.88,0.95)
close.Position=UDim2 .new(0,14,1,-40)
close.Size=UDim2 .fromOffset(75,28)
close.Parent=panel
close.MouseButton1Click:Connect(function()screen:Destroy()end)
end)
end
if type(LIB)=="table"and type(LIB.CreateWindow)=="function"then
local originalCreateWindow=LIB.CreateWindow
function LIB:CreateWindow(data)
local ok,result=xpcall(function()
return originalCreateWindow(self,data)
end,function(err)
if debug and type(debug.traceback)=="function"then
return debug.traceback(tostring(err),2)
end
return tostring(err)
end)
if not ok then
__xNgotShowStartupError(result)
error(result,0)
end
return result
end
LIB.ShowStartupError=__xNgotShowStartupError
end
local Log={}
Log.Version="1.0.0"
Log.entries={}
Log.levels={trace=1,debug=2,info=3,warn=4,error=5}
Log.minLevel=2
Log.maxEntries=1200
Log.listeners={}
Log.counts={trace=0,debug=0,info=0,warn=0,error=0}
Log.dropped=0
Log.api={}
Log.seq=0
local COLORS={
trace=Color3 .fromRGB(140,150,170),
debug=Color3 .fromRGB(120,170,230),
info=Color3 .fromRGB(150,220,170),
warn=Color3 .fromRGB(240,200,110),
error=Color3 .fromRGB(255,140,130),
}
local MAX_TEXT=800
local MAX_TAG=120
local MAX_TABLE=40
local function trimText(text,limit)
text=tostring(text or"")
if#text<=limit then return text end
return text:sub(1,limit)..string.format(" …(+%d ký tự)",#text-limit)
end
local function looksLikeSelf(text)
if#text<400 then return false end
return text:find('"maxEntries"',1,true)~=nil
or text:find('"minLevel"',1,true)~=nil
or text:find('"_hooked"',1,true)~=nil
end
local function safe(value)
if type(value)=="table"then
local keys=0
local huge=rawget(value,"entries")~=nil
for _ in pairs(value)do
keys=keys+1
if keys>MAX_TABLE then break end
end
if huge or keys>MAX_TABLE then
return string.format("<bảng %d+ khoá>",keys)
end
local okJson,text=pcall(function()
return game:GetService("HttpService"):JSONEncode(value)
end)
if okJson and type(text)=="string"then
if looksLikeSelf(text)then return"<bảng Log — đã lọc>"end
return trimText(text,MAX_TEXT*2)
end
local pieces={}
for key,item in pairs(value)do
pieces[#pieces+1]=tostring(key).."="..tostring(item)
if#pieces>MAX_TABLE then break end
end
return trimText("{"..table.concat(pieces,", ").."}",MAX_TEXT*2)
end
local ok,text=pcall(tostring,value)
text=ok and text or"<không đọc được>"
if looksLikeSelf(text)then return"<bảng Log — đã lọc>"end
return text
end
Log.safe=safe
function Log.level(name)
return Log.levels[name]or 3
end
function Log.format(entry)
return trimText(string.format("%s [%s] %s: %s",tostring(entry.time),string.upper(tostring(entry.level)),
tostring(entry.tag),tostring(entry.message)),MAX_TEXT+MAX_TAG+40)
end
local function trimMessage(text)
return trimText(text,MAX_TEXT)
end
function Log.add(level,tag,message,data)
level=Log.levels[level]and level or"info"
Log.counts[level]=(Log.counts[level]or 0)+1
if Log.levels[level]<Log.minLevel then return nil end
if(Log.depth or 0)>2 then
Log.suppressed=(Log.suppressed or 0)+1
return nil
end
if type(tag)=="table"then
tag,message=message,data
if type(tag)=="table"then tag="log"end
Log.misuse=(Log.misuse or 0)+1
end
Log.depth=(Log.depth or 0)+1
Log.seq=Log.seq+1
local now=os.clock()
local entry={
level=level,
tag=trimText(safe(tag),MAX_TAG),
message=trimMessage(safe(message)),
data=data,
at=now,
stamp=now,
time=string.format("%6.2fs",now),
count=Log.seq,
id=Log.seq,
}
Log.entries[#Log.entries+1]=entry
if#Log.entries>Log.maxEntries then
table.remove(Log.entries,1)
Log.dropped=Log.dropped+1
end
if level=="error"and Log.traceErrors~=false and debug and type(debug.traceback)=="function"then
local okTrace,stack=pcall(debug.traceback,"",3)
if okTrace and type(stack)=="string"then
entry.trace=stack:sub(1,1500)
end
end
if(level=="error"or level=="warn")and(Log.depth or 0)<=1 then
pcall(print,"[xNgot "..string.upper(level).."] "..tostring(entry.tag).." · "
..tostring(entry.message):sub(1,400))
end
pcall(function()
for _,listener in ipairs(Log.listeners)do pcall(listener,entry)end
end)
Log.depth=(Log.depth or 1)-1
if Log.depth<0 then Log.depth=0 end
return entry
end
for name in pairs(Log.levels)do
Log[name]=function(tag,message,data)
if type(tag)=="table"then
tag,message,data=message,data,nil
end
local ok,entry=pcall(Log.add,name,tag,message,data)
if not ok then
Log.depth=0
Log.failures=(Log.failures or 0)+1
return nil
end
return entry
end
end
Log.trimMessage=trimMessage
Log.trimText=trimText
Log.MAX_TEXT=MAX_TEXT
Log.MAX_TAG=MAX_TAG
function Log.fromPrint(...)
local pieces={}
for index=1,select("#",...)do pieces[#pieces+1]=safe((select(index,...)))end
return Log.add("info","print",table.concat(pieces," "))
end
function Log.onEntry(callback)
Log.listeners[#Log.listeners+1]=callback
return function()
for index=#Log.listeners,1,-1 do
if Log.listeners[index]==callback then table.remove(Log.listeners,index)end
end
end
end
function Log.clear()
Log.entries={}
Log.counts={trace=0,debug=0,info=0,warn=0,error=0}
Log.dropped=0
end
function Log.filter(level,tag,search)
local wanted=level and Log.levels[level]or 0
local needle=search and string.lower(safe(search))or nil
local out={}
for index=#Log.entries,1,-1 do
local entry=Log.entries[index]
local ok=Log.levels[entry.level]>=wanted
if ok and tag and tag~=""and tag~="all"then ok=entry.tag==tag end
if ok and needle and needle~=""then
ok=string.lower(entry.message):find(needle,1,true)~=nil
or string.lower(entry.tag):find(needle,1,true)~=nil
end
if ok then out[#out+1]=entry end
end
return out
end
function Log.tags()
local seen,list={},{}
for _,entry in ipairs(Log.entries)do
if not seen[entry.tag]then
seen[entry.tag]=true
list[#list+1]=entry.tag
end
end
table.sort(list)
return list
end
function Log.export()
local lines={}
for _,entry in ipairs(Log.entries)do lines[#lines+1]=Log.format(entry)end
return table.concat(lines,"\n")
end
function Log.download()
local clipboard=setclipboard or toclipboard
if type(clipboard)=="function"then
local ok=pcall(clipboard,Log.export())
return ok
end
return false
end
function Log.apiCall(fields)
fields=fields or{}
local message=string.format("%s %s -> %s · %sms · %s",
tostring(fields.method or"GET"),tostring(fields.url or"?"),
tostring(fields.status or"?"),tostring(fields.ms or"?"),
tostring(fields.bytes and(fields.bytes.."B")or(fields.note or"")))
local level="info"
if fields.ok==false then level="error"
elseif fields.status and tonumber(fields.status)and tonumber(fields.status)>=400 then level="warn"end
local entry=Log.add(level,"api",message,fields)
Log.api[#Log.api+1]=fields
if#Log.api>300 then table.remove(Log.api,1)end
return entry
end
function Log.measure(label)
local started=os.clock()
return function(extra)
local ms=(os.clock()-started)*1000
local entry=Log.add(ms>1500 and"warn"or"debug","perf",
string.format("%s · %.1f ms%s",tostring(label),ms,extra and(" · "..tostring(extra))or""))
return ms,entry
end
end
function Log.countsByTag()
local out={}
for _,entry in ipairs(Log.entries)do
out[entry.tag]=(out[entry.tag]or 0)+1
end
return out
end
function Log.stats()
local stats={total=#Log.entries,dropped=Log.dropped,api=#Log.api,tags=0}
for _ in pairs(Log.countsByTag())do stats.tags=stats.tags+1 end
for level,count in pairs(Log.counts)do stats[level]=count end
stats.minLevel=Log.minLevel
return stats
end
function Log.hookConsole()
if Log._hooked then return end
Log._hooked=true
local realPrint,realWarn=print,warn
Log.realPrint,Log.realWarn=realPrint,realWarn
print=function(...)
Log.fromPrint(...)
if realPrint then realPrint(...)end
end
warn=function(...)
local pieces={}
for index=1,select("#",...)do pieces[#pieces+1]=safe((select(index,...)))end
Log.add("warn","warn",table.concat(pieces," "))
if realWarn and(Log.depth or 0)<=1 then realWarn(...)end
end
end
Log.COLORS=COLORS
local env=type(getgenv)=="function"and getgenv()or _G
if _G~=env then _G.xNgotLog=Log end
local DevTools={}
DevTools.Version="3.0.0-stub"
DevTools.suite={}
DevTools.results={}
DevTools.notes={}
function DevTools.note()return DevTools.notes end
function DevTools.vars()return{}end
function DevTools.executors()return{}end
function DevTools.run(code)return loadstring and loadstring(tostring(code or""))~=nil end
function DevTools.add()return nil end
function DevTools.check()return true end
function DevTools.selftest()return{results={},fails=0,passed=0,skipped=true}end
function DevTools.report()return{fails=0,warns=0,results={},skipped=true}end
env.xNgotDevTools=DevTools
if _G~=env then _G.xNgotDevTools=DevTools end
local __xNgotHttpLog=function()
return false
end
__xNgotHttpLog()
local env=type(getgenv)=="function"and getgenv()or _G
local Bridge={}
Bridge.Version="3.0.0-stub"
Bridge.stub=true
local function noop()return nil end
Bridge.open=noop
Bridge.close=noop
Bridge.show=noop
Bridge.notify=noop
Bridge.playMusic=noop
Bridge.timer=noop
Bridge.state=function()return{stub=true}end
Bridge.report=function()return{stub=true}end
Bridge.copyLog=noop
Bridge.copyReport=noop
local __xNgotDebugBridge=function()
env.xNgotDebugBridge=Bridge
if _G~=env then _G.xNgotDebugBridge=Bridge end
return Bridge
end
__xNgotDebugBridge()
local Debug={}
Debug.Version="3.0.0-stub"
Debug.stub=true
Debug.hotkey="RightShift"
Debug.cycles=0
local function noop()return false end
function Debug.getLogPanel()
local lines={}
local api=type(Log)=="table"and Log or nil
if api and type(api.entries)=="table"then
for _,entry in ipairs(api.entries)do
lines[#lines+1]=string.format("%s [%s] %s: %s",tostring(entry.time),tostring(entry.level),
tostring(entry.tag),tostring(entry.message))
end
end
return table.concat(lines,"\n")
end
Debug.exportLog=Debug.getLogPanel
Debug.openPanel=noop
Debug.closePanel=noop
Debug.toggle=noop
Debug.open=noop
Debug.mode=function()return"stub"end
Debug.report=function()return{stub=true,cycles=0}end
local env=type(getgenv)=="function"and getgenv()or _G
env.xNgotDebug=Debug
if _G~=env then
pcall(function()_G.xNgotDebug=Debug end)
end
_G.__xNgotEmbeddedLibrary=LIB
_G.__xNgotEmbeddedLibrary=LIB
local __xNgotEmbeddedLibrary=LIB
local __xNgotBoot={}
__xNgotBoot.Version="3.0.0"
__xNgotBoot.Opts={
localFile="main.lua",
configFile="xNgotLibrary/Config/xNgotMusic.config.lua",
remoteUrl="https://raw.githubusercontent.com/xngotzume123/xNgotLibrary/refs/heads/main/dist/main.lua",
title="xNgọt Studio",
author="Dynamic Island · AI Music · Assistant",
icon="music-2",
autoRun=true,
debug=true,
openPanel=false,
theme="dark",
loading={
Text="Starting",
Steps={"Preparing interface","Loading icons","Almost there"},
Duration=1.6,
},
keySystem={
Enabled=true,
Keys={"XNGOT-2026"},
KeyFile="xNgotLibrary/Keys/key.txt",
GetKeyUrl="",
},
}
__xNgotBoot.Log={}
__xNgotBoot.Stage="init"
__xNgotBoot.Window=nil
__xNgotBoot.Library=nil
__xNgotBoot.Island=nil
__xNgotBoot.StartedAt=os.clock()
local function bootEnv()
return type(getgenv)=="function"and getgenv()or _G
end
local function bootSafe(value)
local ok,text=pcall(tostring,value)
return ok and text or"<không đọc được>"
end
local function bootTrace(err)
if debug and type(debug.traceback)=="function"then
return debug.traceback(bootSafe(err),2)
end
return bootSafe(err)
end
function __xNgotBoot.log(level,message)
local line=bootSafe(message)
__xNgotBoot.Log[#__xNgotBoot.Log+1]=string.format("[%s] %s",bootSafe(level),line)
local logApi=_G.xNgotLog
if logApi and type(logApi[level])=="function"then
pcall(logApi[level],"boot",line)
elseif bootSafe(level)=="error"then
pcall(warn,"[xNgotStudio] "..line)
end
if __xNgotBoot.Opts and __xNgotBoot.Opts.verbose==true then
pcall(print,"[xNgotStudio] ["..bootSafe(level).."] "..line)
end
return line
end
function __xNgotBoot.info(message)return __xNgotBoot.log("info",message)end
function __xNgotBoot.warn(message)return __xNgotBoot.log("warn",message)end
function __xNgotBoot.error(message)return __xNgotBoot.log("error",message)end
function __xNgotBoot.recordError(phase,reason)
local message="["..bootSafe(phase).."] "..bootSafe(reason)
bootEnv().xNgotStudioLastStartupError=message
__xNgotBoot.Stage="error:"..bootSafe(phase)
__xNgotBoot.error(message)
return message
end
local function bootUserGui()
local ok,parent=pcall(function()
local players=game:GetService("Players")
local user=players.LocalPlayer
return user:FindFirstChildOfClass("PlayerGui")or user:WaitForChild("PlayerGui",8)
end)
return ok and parent or nil
end
local function bootRead(path)
if type(isfile)~="function"or type(readfile)~="function"then return nil end
local okFile,exists=pcall(isfile,path)
if not okFile or not exists then return nil end
local okRead,data=pcall(readfile,path)
if okRead and type(data)=="string"and#data>10 then return data end
return nil
end
local function bootFetch(url)
local ok,data=pcall(function()return game:HttpGet(url,true)end)
if ok and type(data)=="string"and#data>100 then return data end
local okSvc,svc=pcall(function()return game:GetService("HttpService")end)
if okSvc and svc then
ok,data=pcall(function()return svc:GetAsync(url)end)
if ok and type(data)=="string"and#data>100 then return data end
end
return nil
end
local function bootClean(text)
local out,index,length={},1,#text
while index<=length do
local two=text:sub(index,index+1)
if two=="--"then
local eq=text:match("^%-%-%[(=*)%[",index)
if eq then
local close="]"..eq.."]"
local found=text:find(close,index,true)
index=found and(found+#close)or(length+1)
else
local nl=text:find("\n",index,true)
index=nl or(length+1)
end
elseif two:sub(1,1)=='"'or two:sub(1,1)=="'"then
local quote=two:sub(1,1)
local cursor=index+1
while cursor<=length do
local char=text:sub(cursor,cursor)
if char=="\\"then
cursor=cursor+2
elseif char==quote then
cursor=cursor+1
break
else
cursor=cursor+1
end
end
out[#out+1]=text:sub(index,cursor-1)
index=cursor
else
out[#out+1]=text:sub(index,index)
index=index+1
end
end
return(table.concat(out):gsub("\n\n\n+","\n\n"))
end
__xNgotBoot.clean=bootClean
local function bootSources()
local opts=__xNgotBoot.Opts
local env=bootEnv()
local userOpts=type(env.xNgotLoaderConfig)=="table"and env.xNgotLoaderConfig or{}
for key,value in pairs(userOpts)do opts[key]=value end
local list={}
local function add(name,kind,path,code)
list[#list+1]={name=name,kind=kind,path=path,code=code}
end
add("built-in (thư viện nhúng trong tệp này)","builtin",nil,nil)
local localCode=bootRead(opts.localFile)
if localCode then
add("local: "..tostring(opts.localFile),"local",opts.localFile,localCode)
end
if opts.remoteUrl then
add("GitHub raw "..tostring(opts.remoteUrl):gsub("^https?://",""),"remote",tostring(opts.remoteUrl))
end
return list
end
function __xNgotBoot.openDebug()
local debugApi=_G.xNgotDebug
if debugApi and type(debugApi.openPanel)=="function"then
if debugApi.Build=="release"then
if type(debugApi.getLogPanel)=="function"then
local okLog=pcall(debugApi.getLogPanel)
__xNgotBoot.info(okLog
and"bản phát hành không có panel — đã xuất log thật (clipboard + F9)"
or"bản phát hành không có panel — chạy _G.xNgotDebug.getLogPanel() để lấy log")
return false
end
return nil
end
local ok,opened=pcall(debugApi.openPanel)
if ok then
if opened~=true then
__xNgotBoot.warn("không mở được panel: "..tostring(debugApi.error or"?"))
end
return opened
end
end
__xNgotBoot.warn("panel debug không khả dụng (Iris chưa nạp)")
return nil
end
function __xNgotBoot.attachDebug()
local debugApi=_G.xNgotDebug
if not debugApi or type(debugApi.attach)~="function"then
__xNgotBoot.warn("không thấy xNgotDebug — bỏ qua panel")
return false
end
if debugApi.Build=="release"then
pcall(debugApi.attach)
pcall(function()
local env=bootEnv()
env.xNgotPanel=function()
if type(debugApi.getLogPanel)=="function"then pcall(debugApi.getLogPanel)end
return debugApi.panel and debugApi.panel()or{build="release"}
end
if _G~=env then _G.xNgotPanel=env.xNgotPanel end
end)
__xNgotBoot.info("bản phát hành: không có panel Iris · lấy log bằng _G.xNgotDebug.getLogPanel()")
return false
end
local ok=pcall(debugApi.attach)
if ok then
pcall(function()
local env=bootEnv()
debugApi.place=debugApi.place or function()end
debugApi.panel=debugApi.panel or function()
return{
open=debugApi.isOpen==true,
iris=debugApi.Iris~=nil,
cycles=debugApi.cycles or 0,
error=debugApi.error,
lastMs=debugApi.lastMs,
hotkey=tostring(debugApi.hotkey),
}
end
env.xNgotPanel=function(tab)
debugApi.toggle(true)
if type(debugApi.setTab)=="function"then pcall(debugApi.setTab,tab)end
return debugApi.panel()
end
if _G~=env then _G.xNgotPanel=env.xNgotPanel end
end)
__xNgotBoot.info("panel debug Iris đã gắn · RightShift bật/tắt · _G.xNgotDebug.openPanel() / _G.xNgotPanel()")
else
__xNgotBoot.warn("gắn panel lỗi")
end
return ok
end
function __xNgotBoot.performance()
local env=bootEnv()
local window=env.Window or _G.Window
local api=window and window.DynamicIsland or nil
if not api then return nil end
if type(api.State)=="function"then
local ok,stats=pcall(api.State,api)
if ok then return stats end
end
return nil
end
function __xNgotBoot.lowPower(on)
local window=__xNgotBoot.Window or bootEnv().Window or _G.Window
local island=type(window)=="table"and window.DynamicIsland or nil
if type(island)~="table"then return false end
local ok=pcall(function()
if island.Set then
island:Set("Ring",not on)
island:Set("RimLight",not on)
island:Set("Fps",not on)
end
end)
__xNgotBoot.log(ok and"info"or"warn","low power mode: "..tostring(on))
return ok
end
function __xNgotBoot.confirmRun(row)
return true
end
function __xNgotBoot.start()
local opts=__xNgotBoot.Opts
local env=bootEnv()
local logApi=env.xNgotLog or _G.xNgotLog
if logApi then
pcall(logApi.hookConsole)
pcall(logApi.info,"boot","xNgotStudio boot "..__xNgotBoot.Version)
end
if opts.debug~=false then
__xNgotBoot.attachDebug()
if opts.openPanel==true then
local debugApi=_G.xNgotDebug
local okPanel,opened=pcall(function()return debugApi.toggle(true)end)
__xNgotBoot.log(okPanel and opened and"info"or"warn",
"mở panel lúc khởi động: "..(okPanel and tostring(opened)or"lỗi"))
end
end
do
local rootFolders={"xNgotLibrary","xNgotLibrary/Config","xNgotLibrary/Music","xNgotLibrary/Music/Covers","xNgotLibrary/Avatars","xNgotLibrary/Keys"}
if type(makefolder)=="function"then
for _,folderPath in ipairs(rootFolders)do pcall(makefolder,folderPath)end
end
local function migrateFile(oldPath,newPath)
if type(isfile)~="function"or type(readfile)~="function"or type(writefile)~="function"then return end
pcall(function()
if isfile(oldPath)and not isfile(newPath)then writefile(newPath,readfile(oldPath))end
end)
end
local function migrateFolder(oldFolder,newFolder)
if type(listfiles)~="function"then return end
pcall(function()
for _,filePath in ipairs(listfiles(oldFolder))do
local name=tostring(filePath):gsub("\\","/"):match("([^/]+)$")
if name then migrateFile(filePath,newFolder.."/"..name)end
end
end)
end
migrateFile("xNgotStudio/DynamicIsland_AI.json","xNgotLibrary/Config/DynamicIsland_AI.json")
migrateFile("xNgotMusic.config.lua","xNgotLibrary/Config/xNgotMusic.config.lua")
migrateFile("xNgotStudio/xNgotStudio_Key.txt","xNgotLibrary/Keys/key.txt")
migrateFile("xNgotStudio_Key.txt","xNgotLibrary/Keys/key.txt")
migrateFolder("xNgotStudioMusic","xNgotLibrary/Music")
migrateFolder("xNgotStudioMusic/Covers","xNgotLibrary/Music/Covers")
end
local cfgCode=bootRead(opts.configFile)
if cfgCode then
local okCfg,errCfg=pcall(function()
local chunk=(loadstring or load)(cfgCode)
assert(type(chunk)=="function","loadstring thất bại")
chunk()
end)
if okCfg then
__xNgotBoot.info("nạp cấu hình: "..tostring(opts.configFile))
else
__xNgotBoot.warn("cấu hình lỗi, bỏ qua: "..bootSafe(errCfg))
end
else
__xNgotBoot.info("không có "..tostring(opts.configFile).." · dùng CONFIG trong tệp")
end
local window,failure
local function createWindow(library,label)
local loadingCfg=opts.loading
if type(loadingCfg)=="table"and loadingCfg.Title==nil then loadingCfg.Title=opts.title end
local okWindow,built=xpcall(function()
return library:CreateWindow({
Title=opts.title,
Author=opts.author,
Icon=opts.icon or"music-2",
Folder="xNgotLibrary/Config",
Size=UDim2 .fromOffset(650,470),
FileSaveName="DynamicIsland_AI.json",
AutoSave=true,
SettingsUI=true,
Loading=loadingCfg,
KeySystem=opts.keySystem,
})
end,bootTrace)
if okWindow then
__xNgotBoot.info("cửa sổ đã tạo từ "..label)
return built
end
failure=bootSafe(built)
__xNgotBoot.error("CreateWindow lỗi ("..label.."): "..failure)
return nil
end
for _,source in ipairs(bootSources())do
if window then break end
__xNgotBoot.log("debug","thử nguồn: "..source.name)
if source.kind=="builtin"then
local builtIn=__xNgotEmbeddedLibrary or _G.__xNgotEmbeddedLibrary
if type(builtIn)=="table"and type(builtIn.CreateWindow)=="function"then
__xNgotBoot.Library=builtIn
window=createWindow(builtIn,"thư viện nhúng")
else
__xNgotBoot.warn("không thấy thư viện nhúng")
end
elseif source.kind=="local"then
local loader=loadstring or load
local chunk,compileError=loader(source.code,"=xNgotLocalSource")
if not chunk then
failure=bootSafe(compileError)
__xNgotBoot.warn("bản local lỗi biên dịch: "..failure)
else
local okLib,result=xpcall(chunk,bootTrace)
if okLib and type(result)=="table"and type(result.CreateWindow)=="function"then
__xNgotBoot.Library=result
window=createWindow(result,"bản local")
else
failure=bootSafe(result)
__xNgotBoot.warn("bản local không trả về Library: "..failure)
end
end
elseif source.kind=="remote"and source.path then
local code=bootFetch(source.path)
if code then
local clean=bootClean(code)
local snippet='local __b = loadstring or load\nlocal __s = __b([====['..clean
..']====], "=xNgotRemoteTry")\nif not __s then return nil end\n'
..'local __ok, __lib = pcall(__s)\n'
..'if __ok and type(__lib) == "table" and type(__lib.CreateWindow) == "function" then return __lib end\nreturn nil'
local loader=loadstring or load
local chunk=loader(snippet,"=xNgotRemotePlane")
if chunk then
local okLib,result=pcall(chunk)
if okLib and type(result)=="table"and type(result.CreateWindow)=="function"then
__xNgotBoot.Library=result
window=createWindow(result,"GitHub raw")
else
failure=bootSafe(result)
__xNgotBoot.warn("bản GitHub raw không dùng được: "..failure)
end
else
__xNgotBoot.warn("không biên dịch được snapshot từ GitHub")
end
else
__xNgotBoot.warn("không tải được "..tostring(source.path))
end
end
end
if not window then
local reason=__xNgotBoot.recordError("Load",failure or"không nguồn nào nạp được")
__xNgotBoot.Stage="failed"
__xNgotBoot.attachDebug()
local debugApi=_G.xNgotDebug
__xNgotBoot.warn(debugApi and debugApi.Build=="release"
and"boot lỗi — chạy _G.xNgotDebug.getLogPanel() để lấy log chẩn đoán"
or"boot lỗi — bấm RightShift hoặc _G.xNgotDebug.openPanel() để mở panel chẩn đoán")
return false,reason
end
__xNgotBoot.Window=window
__xNgotBoot.Stage="ready"
env.Window=window
_G.Window=window
env.xNgotStudio=__xNgotBoot
_G.xNgotStudio=__xNgotBoot
local island=type(window.GetDynamicIsland)=="function"and window:GetDynamicIsland()or nil
__xNgotBoot.Island=island
__xNgotBoot.info("Dynamic Island: "..(island and"sẵn sàng"or"chưa tạo"))
pcall(function()
local cfgApi=env.xNgotMusicConfig or _G.xNgotMusicConfig
if cfgApi and type(cfgApi.Apply)=="function"then cfgApi:Apply()end
local preset=env.xNgotMusicPreset
if preset and cfgApi and type(cfgApi.Preset)=="function"then cfgApi:Preset(preset)end
end)
if opts.autoRun~=false then
pcall(function()window:SelectTab(window.SettingsTitle or"Settings Ui")end)
end
if type(_G.xNgotMusicDoctor)=="function"then
local okReport,report=pcall(_G.xNgotMusicDoctor)
if okReport and type(report)=="table"then
__xNgotBoot.log(report.fails and report.fails>0 and"warn"or"info",
string.format("doctor: %d lỗi, %d cảnh báo",report.fails or 0,report.warns or 0))
end
end
if env.xNgotDevTools and type(env.xNgotDevTools.selftest)=="function"then
local okTest,summary=pcall(env.xNgotDevTools.selftest)
if okTest and type(summary)=="table"then
__xNgotBoot.log(summary.fails==0 and"info"or"warn",
string.format("selftest: %d test, %d lỗi",#summary.results,summary.fails))
end
end
__xNgotBoot.Stage="ready"
__xNgotBoot.info(string.format("xNgotStudio sẵn sàng · %.2fs · RightShift để mở panel debug",os.clock()-__xNgotBoot.StartedAt))
if opts.openPanel==true then
__xNgotBoot.openDebug()
end
return window
end
LIB.Version=__xNgotBoot.Version
LIB.OpenXNgotHub=function()return __xNgotBoot.start()end
local __xngotEnv=(type(getgenv)=="function"and getgenv())or _G
if __xngotEnv.xNgotLibraryOnly~=true and not __xNgotBoot.Open then
__xNgotBoot.Open=true
__xNgotBoot.start()
end
return LIB
