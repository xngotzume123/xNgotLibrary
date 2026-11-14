--[[ xngot-studio · src/modules/20_lib/020_template_01.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.template.01
     role   : Template: ScreenGui gốc, Window, TopBar, TabButtons, khung dropdown
     source : main 2.txt L207-651 · 445 dòng · delta +0
--]]
-- XN-GUI-CLEANUP: dọn MỌI bản UI còn sót của lần chạy trước (kể cả bản cũ
-- chưa có cờ _G.__xNgotStudioGui). Sau CreateWindow, ScreenGui được đổi tên
-- theo Window.Title nên quét theo tên "NgotStudio" là không đủ; ở đây nhận
-- diện theo cấu trúc do template này dựng ra: NotificationList, ModuleScript
-- "3e", hoặc Folder chứa cửa sổ có TopFrame + TabButtons.
local __xNgotIsInstance = function(value)
	if value == nil then return false end
	if type(typeof) ~= "function" then return type(value) == "table" or type(value) == "userdata" end
	local ok, kind = pcall(typeof, value)
	return ok and kind == "Instance"
end

local __xNgotIsOurGui = function(inst)
	if not __xNgotIsInstance(inst) then return false end
	local okGui, isGui = pcall(function() return inst:IsA("ScreenGui") end)
	if not okGui or not isGui then return false end
	local okName, name = pcall(function() return tostring(inst.Name) end)
	if not okName then return false end
	if name == "NgotStudio" or name == "xNgotStudio_FullDynamicIsland" or name == "xNgotStudio_FullIsland" then
		return true
	end
	local okLook, looks = pcall(function()
		if inst:FindFirstChild("NotificationList") ~= nil then return true end
		if inst:FindFirstChild("3e") ~= nil then return true end
		for _, child in ipairs(inst:GetChildren()) do
			if child:IsA("Folder") then
				for _, win in ipairs(child:GetChildren()) do
					if win:FindFirstChild("TopFrame") and win:FindFirstChild("TabButtons") then return true end
				end
			end
		end
		return false
	end)
	return okLook and looks == true
end

local __xNgotGuiParents = function()
	local parents = {}
	local function push(inst)
		if __xNgotIsInstance(inst) then parents[#parents + 1] = inst end
	end
	pcall(function() if gethui then push(gethui()) end end)
	pcall(function() push(game:GetService("CoreGui")) end)
	pcall(function() push(game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")) end)
	return parents
end

local __xNgotDestroyGui = function(inst, keep)
	if inst == nil or inst == keep then return false end
	if not __xNgotIsOurGui(inst) then return false end
	local ok = pcall(function() inst:Destroy() end)
	return ok
end

pcall(function()
	local tracked = _G.__xNgotStudioGuis
	if type(tracked) == "table" then
		for inst in pairs(tracked) do __xNgotDestroyGui(inst, nil) end
	end
	__xNgotDestroyGui(_G.__xNgotStudioGui, nil)
	_G.__xNgotStudioGui = nil
	_G.__xNgotStudioGuis = setmetatable({}, { __mode = "k" })
end)

pcall(function()
	for _, parent in ipairs(__xNgotGuiParents()) do
		pcall(function()
			for _, child in ipairs(parent:GetChildren()) do
				__xNgotDestroyGui(child, nil)
			end
		end)
	end
	local okLight, Lighting = pcall(function() return game:GetService("Lighting") end)
	if okLight and Lighting then
		pcall(function()
			local blur = Lighting:FindFirstChild("xNgotStudio_FullIslandBlur")
			if blur then blur:Destroy() end
		end)
	end
end)

NgotStudio["1"] = Instance.new("ScreenGui");
NgotStudio["1"]["Name"] = [[NgotStudio]];
NgotStudio["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
NgotStudio["1"]["ResetOnSpawn"] = false;

NgotStudio["1"].IgnoreGuiInset = true
pcall(function()
    NgotStudio["1"].ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
end)

local cloneref = cloneref or function(...) return ... end


if protect_gui then
	protect_gui(NgotStudio["1"])
elseif gethui then
	NgotStudio["1"].Parent = gethui()
elseif pcall(function() game.CoreGui:GetChildren() end) then
	NgotStudio["1"].Parent = cloneref(game:GetService("CoreGui"))
else
	NgotStudio["1"].Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

pcall(function()
	_G.__xNgotStudioGui = NgotStudio["1"]
	local tracked = _G.__xNgotStudioGuis
	if type(tracked) == "table" then tracked[NgotStudio["1"]] = true end
end)

NgotStudio["2"] = Instance.new("Frame", NgotStudio["1"]);
NgotStudio["2"]["ZIndex"] = 0;
NgotStudio["2"]["BorderSizePixel"] = 2;
NgotStudio["2"]["BackgroundColor3"] = Color3.fromRGB(37, 40, 47);
NgotStudio["2"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["2"]["Size"] = UDim2.new(0, 528, 0, 334);
NgotStudio["2"]["Position"] = UDim2.new(0.5278, 0, 0.5, 0);
NgotStudio["2"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["2"]["Name"] = [[Window]];

NgotStudio["3"] = Instance.new("UICorner", NgotStudio["2"]);
NgotStudio["3"]["CornerRadius"] = UDim.new(0, 10);

NgotStudio["4"] = Instance.new("Frame", NgotStudio["2"]);
NgotStudio["4"]["Visible"] = false;
NgotStudio["4"]["ZIndex"] = 4;
NgotStudio["4"]["BorderSizePixel"] = 0;
NgotStudio["4"]["BackgroundColor3"] = Color3.fromRGB(32, 35, 41);
NgotStudio["4"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["4"]["ClipsDescendants"] = true;
NgotStudio["4"]["Size"] = UDim2.new(0.7281, 0, 0.68367, 0);
NgotStudio["4"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
NgotStudio["4"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["4"]["Name"] = [[DropdownSelection]];

NgotStudio["5"] = Instance.new("UICorner", NgotStudio["4"]);
NgotStudio["5"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["6"] = Instance.new("UIStroke", NgotStudio["4"]);
NgotStudio["6"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["6"]["Thickness"] = 1.5;
NgotStudio["6"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["7"] = Instance.new("Frame", NgotStudio["4"]);
NgotStudio["7"]["BorderSizePixel"] = 0;
NgotStudio["7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["7"]["Size"] = UDim2.new(1, 0, 0, 50);
NgotStudio["7"]["Position"] = UDim2.new(0, 0, 0, 0);
NgotStudio["7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["7"]["Name"] = [[TopBar]];
NgotStudio["7"]["BackgroundTransparency"] = 1;

NgotStudio["8"] = Instance.new("Frame", NgotStudio["7"]);
NgotStudio["8"]["BorderSizePixel"] = 0;
NgotStudio["8"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["8"]["Size"] = UDim2.new(0, 120, 0, 25);
NgotStudio["8"]["Position"] = UDim2.new(1, -50, 0.5, 0);
NgotStudio["8"]["Name"] = [[BoxFrame]];
NgotStudio["8"]["BackgroundTransparency"] = 1;

NgotStudio["9"] = Instance.new("ImageLabel", NgotStudio["8"]);
NgotStudio["9"]["ZIndex"] = 0;
NgotStudio["9"]["BorderSizePixel"] = 0;
NgotStudio["9"]["SliceCenter"] = Rect.new(49, 49, 450, 450);
NgotStudio["9"]["ScaleType"] = Enum.ScaleType.Slice;
NgotStudio["9"]["ImageTransparency"] = 0.75;

NgotStudio["9"]["ImageColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["9"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["9"]["Image"] = [[rbxassetid://6014261993]];
NgotStudio["9"]["Size"] = UDim2.new(1, 30, 1, 30);
NgotStudio["9"]["BackgroundTransparency"] = 1;
NgotStudio["9"]["Name"] = [[DropShadow]];
NgotStudio["9"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

NgotStudio["a"] = Instance.new("Frame", NgotStudio["8"]);
NgotStudio["a"]["BorderSizePixel"] = 0;
NgotStudio["a"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["a"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["a"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);

NgotStudio["b"] = Instance.new("UICorner", NgotStudio["a"]);
NgotStudio["b"]["CornerRadius"] = UDim.new(0, 5);

NgotStudio["c"] = Instance.new("UIStroke", NgotStudio["a"]);
NgotStudio["c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["c"]["Thickness"] = 1.5;
NgotStudio["c"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["d"] = Instance.new("TextBox", NgotStudio["a"]);
NgotStudio["d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["d"]["BorderSizePixel"] = 0;
NgotStudio["d"]["TextWrapped"] = true;
NgotStudio["d"]["TextTruncate"] = Enum.TextTruncate.AtEnd;
NgotStudio["d"]["TextSize"] = 14;
NgotStudio["d"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["d"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["d"]["ClipsDescendants"] = true;
NgotStudio["d"]["PlaceholderText"] = [[Input here...]];
NgotStudio["d"]["Size"] = UDim2.new(1, -25, 1, 0);
NgotStudio["d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["d"]["Text"] = [[]];
NgotStudio["d"]["BackgroundTransparency"] = 1;

NgotStudio["e"] = Instance.new("UIPadding", NgotStudio["d"]);
NgotStudio["e"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["e"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["e"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["e"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["f"] = Instance.new("ImageButton", NgotStudio["a"]);
NgotStudio["f"]["BorderSizePixel"] = 0;
NgotStudio["f"]["BackgroundTransparency"] = 1;

NgotStudio["f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["f"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["f"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["f"]["Image"] = [[rbxassetid://86928976705683]];
NgotStudio["f"]["Size"] = UDim2.new(0, 15, 0, 15);
NgotStudio["f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["f"]["Position"] = UDim2.new(1, -5, 0.5, 0);

NgotStudio["10"] = Instance.new("ImageButton", NgotStudio["7"]);
NgotStudio["10"]["BorderSizePixel"] = 0;
NgotStudio["10"]["BackgroundTransparency"] = 1;

NgotStudio["10"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["10"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["10"]["ZIndex"] = 0;
NgotStudio["10"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["10"]["Image"] = [[rbxassetid://132453323679056]];
NgotStudio["10"]["Size"] = UDim2.new(0, 25, 0, 25);
NgotStudio["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["10"]["Name"] = [[Close]];
NgotStudio["10"]["Position"] = UDim2.new(1, -12, 0.5, 0);

NgotStudio["11"] = Instance.new("TextLabel", NgotStudio["7"]);
NgotStudio["11"]["TextWrapped"] = true;
NgotStudio["11"]["Interactable"] = false;
NgotStudio["11"]["ZIndex"] = 0;
NgotStudio["11"]["BorderSizePixel"] = 0;
NgotStudio["11"]["TextSize"] = 18;
NgotStudio["11"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["11"]["TextScaled"] = true;
NgotStudio["11"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["11"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["11"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["11"]["BackgroundTransparency"] = 1;
NgotStudio["11"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["11"]["Size"] = UDim2.new(0.5, 0, 0, 18);
NgotStudio["11"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["11"]["Text"] = [[Dropdown]];
NgotStudio["11"]["Name"] = [[Title]];
NgotStudio["11"]["Position"] = UDim2.new(0, 12, 0.5, 0);

NgotStudio["12"] = Instance.new("Folder", NgotStudio["4"]);
NgotStudio["12"]["Name"] = [[Dropdowns]];

NgotStudio["13"] = Instance.new("Frame", NgotStudio["2"]);
NgotStudio["13"]["BorderSizePixel"] = 0;
NgotStudio["13"]["BackgroundColor3"] = Color3.fromRGB(37, 40, 47);
NgotStudio["13"]["ClipsDescendants"] = true;
NgotStudio["13"]["Size"] = UDim2.new(0, 165, 1, -35);
NgotStudio["13"]["Position"] = UDim2.new(0, 0, 0, 35);
NgotStudio["13"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["13"]["Name"] = [[TabButtons]];
NgotStudio["13"]["SelectionGroup"] = true;

NgotStudio["14"] = Instance.new("ScrollingFrame", NgotStudio["13"]);
NgotStudio["14"]["Active"] = true;
NgotStudio["14"]["ScrollingDirection"] = Enum.ScrollingDirection.Y;
NgotStudio["14"]["BorderSizePixel"] = 0;
NgotStudio["14"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
NgotStudio["14"]["ElasticBehavior"] = Enum.ElasticBehavior.Never;
NgotStudio["14"]["TopImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["14"]["BackgroundColor3"] = Color3.fromRGB(37, 40, 47);
NgotStudio["14"]["Name"] = [[Lists]];
NgotStudio["14"]["Selectable"] = false;
NgotStudio["14"]["BottomImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["14"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;
NgotStudio["14"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["14"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["14"]["ScrollBarThickness"] = 4;
NgotStudio["14"]["BackgroundTransparency"] = 1;

NgotStudio["15"] = Instance.new("UIListLayout", NgotStudio["14"]);
NgotStudio["15"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["16"] = Instance.new("Frame", NgotStudio["14"]);
NgotStudio["16"]["Visible"] = false;
NgotStudio["16"]["BorderSizePixel"] = 0;
NgotStudio["16"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["16"]["Size"] = UDim2.new(1, 0, 0, 36);
NgotStudio["16"]["Position"] = UDim2.new(-0.0375, 0, 0.38434, 0);
NgotStudio["16"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["16"]["Name"] = [[TabButton]];
NgotStudio["16"]["BackgroundTransparency"] = 1;

NgotStudio["17"] = Instance.new("Frame", NgotStudio["16"]);
NgotStudio["17"]["BorderSizePixel"] = 0;
NgotStudio["17"]["BackgroundColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["17"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["17"]["Size"] = UDim2.new(0, 5, 0, 25);
NgotStudio["17"]["Position"] = UDim2.new(0, 8, 0, 18);
NgotStudio["17"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["17"]["Name"] = [[Bar]];

NgotStudio["18"] = Instance.new("UIGradient", NgotStudio["17"]);
NgotStudio["18"]["Enabled"] = false;
NgotStudio["18"]["Rotation"] = 90;
NgotStudio["18"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(110, 212, 255)),ColorSequenceKeypoint.new(0.978, Color3.fromRGB(0, 124, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 218, 255))};

NgotStudio["19"] = Instance.new("UICorner", NgotStudio["17"]);
NgotStudio["19"]["CornerRadius"] = UDim.new(0, 100);

NgotStudio["1a"] = Instance.new("ImageButton", NgotStudio["16"]);
NgotStudio["1a"]["BorderSizePixel"] = 0;
NgotStudio["1a"]["BackgroundTransparency"] = 1;

NgotStudio["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["1a"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["1a"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["1a"]["Image"] = [[rbxassetid://113216930555884]];
NgotStudio["1a"]["Size"] = UDim2.new(0, 31, 0, 30);
NgotStudio["1a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["1a"]["Position"] = UDim2.new(0, 21, 0, 18);

NgotStudio["1b"] = Instance.new("UIAspectRatioConstraint", NgotStudio["1a"]);

NgotStudio["1c"] = Instance.new("TextLabel", NgotStudio["16"]);
NgotStudio["1c"]["TextWrapped"] = true;
NgotStudio["1c"]["BorderSizePixel"] = 0;
NgotStudio["1c"]["TextSize"] = 14;
NgotStudio["1c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["1c"]["TextScaled"] = true;
NgotStudio["1c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["1c"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["1c"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["1c"]["BackgroundTransparency"] = 1;
NgotStudio["1c"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["1c"]["Size"] = UDim2.new(0, 88, 0, 16);
NgotStudio["1c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["1c"]["Text"] = [[NgotStudio]];
NgotStudio["1c"]["Position"] = UDim2.new(0, 57, 0.5, 0);

NgotStudio["1d"] = Instance.new("UIPadding", NgotStudio["14"]);
NgotStudio["1d"]["PaddingTop"] = UDim.new(0, 8);

NgotStudio["1e"] = Instance.new("Frame", NgotStudio["14"]);
NgotStudio["1e"]["Visible"] = false;
NgotStudio["1e"]["BorderSizePixel"] = 0;
NgotStudio["1e"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["1e"]["Size"] = UDim2.new(1, 0, 0, 1);
NgotStudio["1e"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["1e"]["Name"] = [[Divider]];

NgotStudio["1f"] = Instance.new("ImageButton", NgotStudio["14"]);
NgotStudio["1f"]["Active"] = false;
NgotStudio["1f"]["BorderSizePixel"] = 0;
NgotStudio["1f"]["AutoButtonColor"] = false;
NgotStudio["1f"]["Visible"] = false;
NgotStudio["1f"]["BackgroundTransparency"] = 1;
NgotStudio["1f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["1f"]["Selectable"] = false;
NgotStudio["1f"]["Size"] = UDim2.new(1, 0, 0, 36);
NgotStudio["1f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["1f"]["Name"] = [[TabButton]];

NgotStudio["20"] = Instance.new("ImageButton", NgotStudio["1f"]);
NgotStudio["20"]["BorderSizePixel"] = 0;
NgotStudio["20"]["ImageTransparency"] = 0.5;
NgotStudio["20"]["BackgroundTransparency"] = 1;

NgotStudio["20"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["20"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["20"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["20"]["Image"] = [[rbxassetid://113216930555884]];
NgotStudio["20"]["Size"] = UDim2.new(0, 31, 0, 30);
NgotStudio["20"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["20"]["Position"] = UDim2.new(0, 6, 0, 18);

NgotStudio["21"] = Instance.new("UIAspectRatioConstraint", NgotStudio["20"]);

NgotStudio["22"] = Instance.new("TextLabel", NgotStudio["1f"]);
NgotStudio["22"]["TextWrapped"] = true;
NgotStudio["22"]["BorderSizePixel"] = 0;
NgotStudio["22"]["TextSize"] = 14;
NgotStudio["22"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["22"]["TextTransparency"] = 0.5;
NgotStudio["22"]["TextScaled"] = true;
NgotStudio["22"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["22"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["22"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["22"]["BackgroundTransparency"] = 1;
NgotStudio["22"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["22"]["Size"] = UDim2.new(0, 103, 0, 16);
NgotStudio["22"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["22"]["Text"] = [[NgotStudio]];
NgotStudio["22"]["Position"] = UDim2.new(0, 42, 0.5, 0);

NgotStudio["23"] = Instance.new("Frame", NgotStudio["1f"]);
NgotStudio["23"]["BorderSizePixel"] = 0;
NgotStudio["23"]["BackgroundColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["23"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["23"]["Size"] = UDim2.new(0, 5, 0, 0);
NgotStudio["23"]["Position"] = UDim2.new(0, 8, 0, 18);
NgotStudio["23"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["23"]["Name"] = [[Bar]];
NgotStudio["23"]["BackgroundTransparency"] = 1;

NgotStudio["24"] = Instance.new("UICorner", NgotStudio["23"]);
NgotStudio["24"]["CornerRadius"] = UDim.new(0, 100);

NgotStudio["25"] = Instance.new("UICorner", NgotStudio["13"]);
NgotStudio["25"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["26"] = Instance.new("Frame", NgotStudio["13"]);
NgotStudio["26"]["BorderSizePixel"] = 0;
NgotStudio["26"]["BackgroundColor3"] = Color3.fromRGB(37, 40, 47);
NgotStudio["26"]["Size"] = UDim2.new(1, 0, 0, 5);
NgotStudio["26"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["26"]["Name"] = [[AntiCornerTop]];

NgotStudio["27"] = Instance.new("Frame", NgotStudio["13"]);
NgotStudio["27"]["BorderSizePixel"] = 0;
NgotStudio["27"]["BackgroundColor3"] = Color3.fromRGB(37, 40, 47);
NgotStudio["27"]["AnchorPoint"] = Vector2.new(0.5, 0);
NgotStudio["27"]["Size"] = UDim2.new(0, 2, 1, 0);
NgotStudio["27"]["Position"] = UDim2.new(1, 1, 0, 0);
NgotStudio["27"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["27"]["Name"] = [[AntiCornerRight]];

NgotStudio["28"] = Instance.new("Frame", NgotStudio["13"]);
NgotStudio["28"]["ZIndex"] = 2;
NgotStudio["28"]["BorderSizePixel"] = 0;
NgotStudio["28"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["28"]["AnchorPoint"] = Vector2.new(1, 0);
NgotStudio["28"]["Size"] = UDim2.new(0, 2, 1, 0);
NgotStudio["28"]["Position"] = UDim2.new(1, 0, 0, 0);
NgotStudio["28"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["28"]["Name"] = [[Border]];

NgotStudio["29"] = Instance.new("Frame", NgotStudio["2"]);
NgotStudio["29"]["BorderSizePixel"] = 0;
NgotStudio["29"]["BackgroundColor3"] = Color3.fromRGB(37, 40, 47);
NgotStudio["29"]["ClipsDescendants"] = true;
NgotStudio["29"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["29"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["29"]["Name"] = [[TopFrame]];

NgotStudio["2a"] = Instance.new("ImageButton", NgotStudio["29"]);
NgotStudio["2a"]["Active"] = false;
NgotStudio["2a"]["Interactable"] = false;
NgotStudio["2a"]["BorderSizePixel"] = 0;
NgotStudio["2a"]["BackgroundTransparency"] = 1;

NgotStudio["2a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["2a"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["2a"]["Image"] = [[rbxassetid://113216930555884]];
NgotStudio["2a"]["Size"] = UDim2.new(0, 25, 0, 25);
NgotStudio["2a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["2a"]["Name"] = [[Icon]];
NgotStudio["2a"]["Position"] = UDim2.new(0, 10, 0.5, 0);

NgotStudio["2b"] = Instance.new("UIAspectRatioConstraint", NgotStudio["2a"]);

NgotStudio["2c"] = Instance.new("TextLabel", NgotStudio["29"]);
NgotStudio["2c"]["TextWrapped"] = true;
NgotStudio["2c"]["Interactable"] = false;
NgotStudio["2c"]["BorderSizePixel"] = 0;
NgotStudio["2c"]["TextSize"] = 14;
NgotStudio["2c"]["TextScaled"] = true;
NgotStudio["2c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["2c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["2c"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["2c"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["2c"]["BackgroundTransparency"] = 1;
NgotStudio["2c"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["2c"]["Size"] = UDim2.new(1, -150, 0, 16);
NgotStudio["2c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["2c"]["Text"] = [[NgotStudio - v1.2.3]];
NgotStudio["2c"]["Position"] = UDim2.new(0, 45, 0.5, -1);

NgotStudio["2d"] = Instance.new("ImageButton", NgotStudio["29"]);
NgotStudio["2d"]["BorderSizePixel"] = 0;
NgotStudio["2d"]["BackgroundTransparency"] = 1;

NgotStudio["2d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["2d"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["2d"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["2d"]["Image"] = [[rbxassetid://132453323679056]];
NgotStudio["2d"]["Size"] = UDim2.new(0, 20, 0, 20);
NgotStudio["2d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["2d"]["Name"] = [[Close]];
NgotStudio["2d"]["Position"] = UDim2.new(1, -15, 0.5, 0);

NgotStudio["2e"] = Instance.new("ImageButton", NgotStudio["29"]);
NgotStudio["2e"]["BorderSizePixel"] = 0;
NgotStudio["2e"]["BackgroundTransparency"] = 1;

NgotStudio["2e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["2e"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["2e"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["2e"]["Image"] = [[rbxassetid://108285848026510]];
NgotStudio["2e"]["Size"] = UDim2.new(0, 15, 0, 15);
NgotStudio["2e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["2e"]["Name"] = [[Maximize]];
NgotStudio["2e"]["Position"] = UDim2.new(1, -55, 0.5, 0);

NgotStudio["2f"] = Instance.new("ImageButton", NgotStudio["29"]);
NgotStudio["2f"]["BorderSizePixel"] = 0;
NgotStudio["2f"]["BackgroundTransparency"] = 1;
