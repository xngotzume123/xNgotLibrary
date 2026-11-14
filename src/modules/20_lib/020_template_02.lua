--[[ xngot-studio · src/modules/20_lib/020_template_02.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.template.02
     role   : Template: nút Hide, Tabs, NotificationFrame/List, folder Library/IconModule
     source : main 2.txt L652-1103 · 452 dòng · delta +0
--]]

NgotStudio["2f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["2f"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["2f"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["2f"]["Image"] = [[rbxassetid://128209591224511]];
NgotStudio["2f"]["Size"] = UDim2.new(0, 20, 0, 20);
NgotStudio["2f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["2f"]["Name"] = [[Hide]];
NgotStudio["2f"]["Position"] = UDim2.new(1, -90, 0.5, 0);

NgotStudio["30"] = Instance.new("UICorner", NgotStudio["29"]);
NgotStudio["30"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["31"] = Instance.new("Frame", NgotStudio["29"]);
NgotStudio["31"]["ZIndex"] = 2;
NgotStudio["31"]["BorderSizePixel"] = 0;
NgotStudio["31"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["31"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["31"]["Size"] = UDim2.new(1, 0, 0, 2);
NgotStudio["31"]["Position"] = UDim2.new(0, 0, 1, 0);
NgotStudio["31"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["31"]["Name"] = [[Border]];

NgotStudio["32"] = Instance.new("UIStroke", NgotStudio["2"]);
NgotStudio["32"]["Transparency"] = 0.5;
NgotStudio["32"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["32"]["Color"] = Color3.fromRGB(95, 95, 117);

NgotStudio["33"] = Instance.new("Frame", NgotStudio["2"]);
NgotStudio["33"]["BorderSizePixel"] = 0;
NgotStudio["33"]["BackgroundColor3"] = Color3.fromRGB(32, 35, 41);
NgotStudio["33"]["Size"] = UDim2.new(1, -165, 1, -35);
NgotStudio["33"]["Position"] = UDim2.new(0, 165, 0, 35);
NgotStudio["33"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["33"]["Name"] = [[Tabs]];

NgotStudio["34"] = Instance.new("UICorner", NgotStudio["33"]);
NgotStudio["34"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["35"] = Instance.new("Frame", NgotStudio["33"]);
NgotStudio["35"]["Visible"] = false;
NgotStudio["35"]["BorderSizePixel"] = 0;
NgotStudio["35"]["BackgroundColor3"] = Color3.fromRGB(32, 35, 41);
NgotStudio["35"]["Size"] = UDim2.new(0, 5, 1, 0);
NgotStudio["35"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["35"]["Name"] = [[AntiCornerLeft]];

NgotStudio["36"] = Instance.new("Frame", NgotStudio["33"]);
NgotStudio["36"]["BorderSizePixel"] = 0;
NgotStudio["36"]["BackgroundColor3"] = Color3.fromRGB(32, 35, 41);
NgotStudio["36"]["Size"] = UDim2.new(1, 0, 0, 5);
NgotStudio["36"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["36"]["Name"] = [[AntiCornerTop]];

NgotStudio["37"] = Instance.new("TextLabel", NgotStudio["33"]);
NgotStudio["37"]["TextWrapped"] = true;
NgotStudio["37"]["Interactable"] = false;
NgotStudio["37"]["BorderSizePixel"] = 0;
NgotStudio["37"]["TextSize"] = 14;
NgotStudio["37"]["TextScaled"] = true;
NgotStudio["37"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["37"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["37"]["TextColor3"] = Color3.fromRGB(135, 140, 150);
NgotStudio["37"]["BackgroundTransparency"] = 1;
NgotStudio["37"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["37"]["Size"] = UDim2.new(1, 0, 0, 16);
NgotStudio["37"]["Visible"] = false;
NgotStudio["37"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["37"]["Text"] = [[This tab is empty :(]];
NgotStudio["37"]["Name"] = [[NoObjectFoundText]];
NgotStudio["37"]["Position"] = UDim2.new(0.5, 0, 0.45, 0);

NgotStudio["38"] = Instance.new("Frame", NgotStudio["2"]);
NgotStudio["38"]["BorderSizePixel"] = 0;
NgotStudio["38"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["38"]["ClipsDescendants"] = true;
NgotStudio["38"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["38"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["38"]["Name"] = [[NotificationFrame]];
NgotStudio["38"]["BackgroundTransparency"] = 1;

NgotStudio["39"] = Instance.new("Frame", NgotStudio["38"]);
NgotStudio["39"]["ZIndex"] = 5;
NgotStudio["39"]["BorderSizePixel"] = 0;
NgotStudio["39"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["39"]["AnchorPoint"] = Vector2.new(0.5, 0);
NgotStudio["39"]["ClipsDescendants"] = true;
NgotStudio["39"]["Size"] = UDim2.new(0, 630, 1, -35);
NgotStudio["39"]["Position"] = UDim2.new(1, 0, 0, 35);
NgotStudio["39"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["39"]["Name"] = [[NotificationList]];
NgotStudio["39"]["BackgroundTransparency"] = 1;

NgotStudio["3a"] = Instance.new("UIListLayout", NgotStudio["39"]);
NgotStudio["3a"]["Padding"] = UDim.new(0, 12);
NgotStudio["3a"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["3b"] = Instance.new("UIPadding", NgotStudio["39"]);
NgotStudio["3b"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["3b"]["PaddingRight"] = UDim.new(0, 40);
NgotStudio["3b"]["PaddingLeft"] = UDim.new(0, 40);

NgotStudio["3c"] = Instance.new("Frame", NgotStudio["2"]);
NgotStudio["3c"]["Visible"] = false;
NgotStudio["3c"]["BorderSizePixel"] = 0;
NgotStudio["3c"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["3c"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["3c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["3c"]["Name"] = [[DarkOverlay]];
NgotStudio["3c"]["BackgroundTransparency"] = 0.6;

NgotStudio["3d"] = Instance.new("UICorner", NgotStudio["3c"]);
NgotStudio["3d"]["CornerRadius"] = UDim.new(0, 10);

NgotStudio["3e"] = Instance.new("ModuleScript", NgotStudio["1"]);
NgotStudio["3e"]["Name"] = [[Library]];

NgotStudio["3f"] = Instance.new("ModuleScript", NgotStudio["3e"]);
NgotStudio["3f"]["Name"] = [[IconModule]];

NgotStudio["40"] = Instance.new("ModuleScript", NgotStudio["3f"]);
NgotStudio["40"]["Name"] = [[Lucide]];

NgotStudio["41"] = Instance.new("Folder", NgotStudio["1"]);
NgotStudio["41"]["Name"] = [[Templates]];

NgotStudio["42"] = Instance.new("Frame", NgotStudio["41"]);
NgotStudio["42"]["Visible"] = false;
NgotStudio["42"]["BorderSizePixel"] = 0;
NgotStudio["42"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["42"]["Size"] = UDim2.new(1, 0, 0, 1);
NgotStudio["42"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["42"]["Name"] = [[Divider]];

NgotStudio["43"] = Instance.new("ScrollingFrame", NgotStudio["41"]);
NgotStudio["43"]["Visible"] = false;
NgotStudio["43"]["Active"] = true;
NgotStudio["43"]["ScrollingDirection"] = Enum.ScrollingDirection.Y;
NgotStudio["43"]["BorderSizePixel"] = 0;
NgotStudio["43"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
NgotStudio["43"]["ElasticBehavior"] = Enum.ElasticBehavior.Never;
NgotStudio["43"]["TopImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["43"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["43"]["Name"] = [[Tab]];
NgotStudio["43"]["Selectable"] = false;
NgotStudio["43"]["BottomImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["43"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;
NgotStudio["43"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["43"]["ScrollBarImageColor3"] = Color3.fromRGB(99, 106, 122);
NgotStudio["43"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["43"]["ScrollBarThickness"] = 5;
NgotStudio["43"]["BackgroundTransparency"] = 1;

NgotStudio["44"] = Instance.new("UIListLayout", NgotStudio["43"]);
NgotStudio["44"]["Padding"] = UDim.new(0, 15);
NgotStudio["44"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["45"] = Instance.new("UIPadding", NgotStudio["43"]);
NgotStudio["45"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["45"]["PaddingRight"] = UDim.new(0, 14);
NgotStudio["45"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["45"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["46"] = Instance.new("ImageButton", NgotStudio["41"]);
NgotStudio["46"]["BorderSizePixel"] = 0;
NgotStudio["46"]["AutoButtonColor"] = false;
NgotStudio["46"]["Visible"] = false;
NgotStudio["46"]["BackgroundTransparency"] = 1;
NgotStudio["46"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["46"]["Selectable"] = false;
NgotStudio["46"]["Size"] = UDim2.new(1, 0, 0, 36);
NgotStudio["46"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["46"]["Name"] = [[TabButton]];

NgotStudio["47"] = Instance.new("ImageButton", NgotStudio["46"]);
NgotStudio["47"]["BorderSizePixel"] = 0;
NgotStudio["47"]["ImageTransparency"] = 0.5;
NgotStudio["47"]["BackgroundTransparency"] = 1;

NgotStudio["47"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["47"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["47"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["47"]["Image"] = [[rbxassetid://113216930555884]];
NgotStudio["47"]["Size"] = UDim2.new(0, 20, 0, 20);
NgotStudio["47"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["47"]["Position"] = UDim2.new(0, 12, 0, 18);

NgotStudio["48"] = Instance.new("UIAspectRatioConstraint", NgotStudio["47"]);

NgotStudio["49"] = Instance.new("TextLabel", NgotStudio["46"]);
NgotStudio["49"]["TextWrapped"] = true;
NgotStudio["49"]["BorderSizePixel"] = 0;
NgotStudio["49"]["TextSize"] = 14;
NgotStudio["49"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["49"]["TextTransparency"] = 0.5;
NgotStudio["49"]["TextScaled"] = true;
NgotStudio["49"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["49"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["49"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["49"]["BackgroundTransparency"] = 1;
NgotStudio["49"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["49"]["Size"] = UDim2.new(0, 103, 0, 16);
NgotStudio["49"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["49"]["Text"] = [[]];
NgotStudio["49"]["Position"] = UDim2.new(0, 42, 0.5, 0);

NgotStudio["4a"] = Instance.new("Frame", NgotStudio["46"]);
NgotStudio["4a"]["BorderSizePixel"] = 0;
NgotStudio["4a"]["BackgroundColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["4a"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["4a"]["Size"] = UDim2.new(0, 5, 0, 0);
NgotStudio["4a"]["Position"] = UDim2.new(0, 8, 0, 18);
NgotStudio["4a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["4a"]["Name"] = [[Bar]];
NgotStudio["4a"]["BackgroundTransparency"] = 1;

NgotStudio["4b"] = Instance.new("UICorner", NgotStudio["4a"]);
NgotStudio["4b"]["CornerRadius"] = UDim.new(0, 100);

NgotStudio["4c"] = Instance.new("ImageButton", NgotStudio["41"]);
NgotStudio["4c"]["BorderSizePixel"] = 0;
NgotStudio["4c"]["AutoButtonColor"] = false;
NgotStudio["4c"]["Visible"] = false;
NgotStudio["4c"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["4c"]["Selectable"] = false;
NgotStudio["4c"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["4c"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["4c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["4c"]["Name"] = [[Button]];
NgotStudio["4c"]["Position"] = UDim2.new(0, 0, 0.384, 0);

NgotStudio["4d"] = Instance.new("UICorner", NgotStudio["4c"]);
NgotStudio["4d"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["4e"] = Instance.new("Frame", NgotStudio["4c"]);
NgotStudio["4e"]["BorderSizePixel"] = 0;
NgotStudio["4e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["4e"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["4e"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["4e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["4e"]["BackgroundTransparency"] = 1;

NgotStudio["4f"] = Instance.new("UIListLayout", NgotStudio["4e"]);
NgotStudio["4f"]["Padding"] = UDim.new(0, 5);
NgotStudio["4f"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["50"] = Instance.new("UIPadding", NgotStudio["4e"]);
NgotStudio["50"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["50"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["50"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["50"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["51"] = Instance.new("TextLabel", NgotStudio["4e"]);
NgotStudio["51"]["TextWrapped"] = true;
NgotStudio["51"]["Interactable"] = false;
NgotStudio["51"]["BorderSizePixel"] = 0;
NgotStudio["51"]["TextSize"] = 16;
NgotStudio["51"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["51"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["51"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["51"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["51"]["BackgroundTransparency"] = 1;
NgotStudio["51"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["51"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["51"]["Text"] = [[Button]];
NgotStudio["51"]["Name"] = [[Title]];

NgotStudio["52"] = Instance.new("ImageButton", NgotStudio["51"]);
NgotStudio["52"]["BorderSizePixel"] = 0;
NgotStudio["52"]["AutoButtonColor"] = false;
NgotStudio["52"]["BackgroundTransparency"] = 1;

NgotStudio["52"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["52"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["52"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["52"]["Image"] = [[rbxassetid://91877599529856]];
NgotStudio["52"]["Size"] = UDim2.new(0, 23, 0, 23);
NgotStudio["52"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["52"]["Name"] = [[ClickIcon]];
NgotStudio["52"]["Position"] = UDim2.new(1, 0, 0.5, 0);

NgotStudio["53"] = Instance.new("TextLabel", NgotStudio["4e"]);
NgotStudio["53"]["TextWrapped"] = true;
NgotStudio["53"]["Interactable"] = false;
NgotStudio["53"]["BorderSizePixel"] = 0;
NgotStudio["53"]["TextSize"] = 16;
NgotStudio["53"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["53"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["53"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["53"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["53"]["BackgroundTransparency"] = 1;
NgotStudio["53"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["53"]["Visible"] = false;
NgotStudio["53"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["53"]["Text"] = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["53"]["LayoutOrder"] = 1;
NgotStudio["53"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["53"]["Name"] = [[Description]];

NgotStudio["54"] = Instance.new("UIGradient", NgotStudio["4e"]);
NgotStudio["54"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["55"] = Instance.new("UIGradient", NgotStudio["4e"]);
NgotStudio["55"]["Enabled"] = false;
NgotStudio["55"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["56"] = Instance.new("UIGradient", NgotStudio["4e"]);
NgotStudio["56"]["Enabled"] = false;
NgotStudio["56"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["57"] = Instance.new("UICorner", NgotStudio["4e"]);
NgotStudio["57"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["58"] = Instance.new("UIStroke", NgotStudio["4c"]);
NgotStudio["58"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["58"]["Thickness"] = 1.5;
NgotStudio["58"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["59"] = Instance.new("Frame", NgotStudio["41"]);
NgotStudio["59"]["Visible"] = false;
NgotStudio["59"]["BorderSizePixel"] = 0;
NgotStudio["59"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["59"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["59"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["59"]["Position"] = UDim2.new(-0.0375, 0, 0.38434, 0);
NgotStudio["59"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["59"]["Name"] = [[Paragraph]];

NgotStudio["5a"] = Instance.new("UICorner", NgotStudio["59"]);
NgotStudio["5a"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["5b"] = Instance.new("UIStroke", NgotStudio["59"]);
NgotStudio["5b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["5b"]["Thickness"] = 1.5;
NgotStudio["5b"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["5c"] = Instance.new("TextLabel", NgotStudio["59"]);
NgotStudio["5c"]["TextWrapped"] = true;
NgotStudio["5c"]["Interactable"] = false;
NgotStudio["5c"]["BorderSizePixel"] = 0;
NgotStudio["5c"]["TextSize"] = 16;
NgotStudio["5c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["5c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["5c"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
NgotStudio["5c"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["5c"]["BackgroundTransparency"] = 1;
NgotStudio["5c"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["5c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["5c"]["Text"] = [[Title]];
NgotStudio["5c"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["5c"]["Name"] = [[Title]];

NgotStudio["5d"] = Instance.new("UIPadding", NgotStudio["59"]);
NgotStudio["5d"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["5d"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["5d"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["5d"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["5e"] = Instance.new("UIListLayout", NgotStudio["59"]);
NgotStudio["5e"]["Padding"] = UDim.new(0, 5);
NgotStudio["5e"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["5f"] = Instance.new("TextLabel", NgotStudio["59"]);
NgotStudio["5f"]["TextWrapped"] = true;
NgotStudio["5f"]["Interactable"] = false;
NgotStudio["5f"]["BorderSizePixel"] = 0;
NgotStudio["5f"]["TextSize"] = 16;
NgotStudio["5f"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["5f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["5f"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["5f"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["5f"]["BackgroundTransparency"] = 1;
NgotStudio["5f"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["5f"]["Visible"] = false;
NgotStudio["5f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["5f"]["Text"] = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["5f"]["LayoutOrder"] = 1;
NgotStudio["5f"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["5f"]["Name"] = [[Description]];

NgotStudio["60"] = Instance.new("ImageButton", NgotStudio["41"]);
NgotStudio["60"]["BorderSizePixel"] = 0;
NgotStudio["60"]["AutoButtonColor"] = false;
NgotStudio["60"]["Visible"] = false;
NgotStudio["60"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["60"]["Selectable"] = false;
NgotStudio["60"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["60"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["60"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["60"]["Name"] = [[Toggle]];
NgotStudio["60"]["Position"] = UDim2.new(-0.0375, 0, 0.38434, 0);

NgotStudio["61"] = Instance.new("UICorner", NgotStudio["60"]);
NgotStudio["61"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["62"] = Instance.new("UIStroke", NgotStudio["60"]);
NgotStudio["62"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["62"]["Thickness"] = 1.5;
NgotStudio["62"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["63"] = Instance.new("UIPadding", NgotStudio["60"]);
NgotStudio["63"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["63"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["63"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["63"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["64"] = Instance.new("UIListLayout", NgotStudio["60"]);
NgotStudio["64"]["Padding"] = UDim.new(0, 5);
NgotStudio["64"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["65"] = Instance.new("TextLabel", NgotStudio["60"]);
NgotStudio["65"]["TextWrapped"] = true;
NgotStudio["65"]["Interactable"] = false;
NgotStudio["65"]["BorderSizePixel"] = 0;
NgotStudio["65"]["TextSize"] = 16;
NgotStudio["65"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["65"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["65"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["65"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["65"]["BackgroundTransparency"] = 1;
NgotStudio["65"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["65"]["Visible"] = false;
NgotStudio["65"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["65"]["Text"] = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["65"]["LayoutOrder"] = 1;
NgotStudio["65"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["65"]["Name"] = [[Description]];

NgotStudio["66"] = Instance.new("TextLabel", NgotStudio["60"]);
NgotStudio["66"]["TextWrapped"] = true;
NgotStudio["66"]["BorderSizePixel"] = 0;
NgotStudio["66"]["TextSize"] = 16;
NgotStudio["66"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["66"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["66"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["66"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["66"]["BackgroundTransparency"] = 1;
NgotStudio["66"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["66"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["66"]["Text"] = [[Toggle]];
NgotStudio["66"]["Name"] = [[Title]];

NgotStudio["67"] = Instance.new("ImageButton", NgotStudio["66"]);
NgotStudio["67"]["BorderSizePixel"] = 0;
NgotStudio["67"]["AutoButtonColor"] = false;
NgotStudio["67"]["BackgroundColor3"] = Color3.fromRGB(54, 57, 63);
NgotStudio["67"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["67"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["67"]["Size"] = UDim2.new(0, 45, 0, 25);
NgotStudio["67"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["67"]["Name"] = [[Fill]];
NgotStudio["67"]["Position"] = UDim2.new(1, 0, 0.5, 0);
