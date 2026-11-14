--[[ xngot-studio · src/modules/20_lib/020_template_04.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.template.04
     role   : Template: Dropdown list + ô tìm kiếm, Code block
     source : main 2.txt L1562-2007 · 446 dòng · delta +0
--]]

NgotStudio["a1"] = Instance.new("Frame", NgotStudio["9a"]);
NgotStudio["a1"]["ZIndex"] = 0;
NgotStudio["a1"]["BorderSizePixel"] = 0;
NgotStudio["a1"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["a1"]["Size"] = UDim2.new(1, 0, 0, 25);
NgotStudio["a1"]["Name"] = [[BoxFrame]];
NgotStudio["a1"]["LayoutOrder"] = 2;
NgotStudio["a1"]["BackgroundTransparency"] = 1;

NgotStudio["a2"] = Instance.new("ImageLabel", NgotStudio["a1"]);
NgotStudio["a2"]["ZIndex"] = 0;
NgotStudio["a2"]["BorderSizePixel"] = 0;
NgotStudio["a2"]["SliceCenter"] = Rect.new(49, 49, 450, 450);
NgotStudio["a2"]["ScaleType"] = Enum.ScaleType.Slice;
NgotStudio["a2"]["ImageTransparency"] = 0.75;

NgotStudio["a2"]["ImageColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["a2"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["a2"]["Image"] = [[rbxassetid://6014261993]];
NgotStudio["a2"]["Size"] = UDim2.new(1, 35, 1, 30);
NgotStudio["a2"]["BackgroundTransparency"] = 1;
NgotStudio["a2"]["Name"] = [[DropShadow]];
NgotStudio["a2"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

NgotStudio["a3"] = Instance.new("Frame", NgotStudio["a1"]);
NgotStudio["a3"]["BorderSizePixel"] = 0;
NgotStudio["a3"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["a3"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["a3"]["Size"] = UDim2.new(1, 0, 0, 25);
NgotStudio["a3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);

NgotStudio["a4"] = Instance.new("UICorner", NgotStudio["a3"]);
NgotStudio["a4"]["CornerRadius"] = UDim.new(0, 5);

NgotStudio["a5"] = Instance.new("UIStroke", NgotStudio["a3"]);
NgotStudio["a5"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["a5"]["Thickness"] = 1.5;
NgotStudio["a5"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["a6"] = Instance.new("UIListLayout", NgotStudio["a3"]);
NgotStudio["a6"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
NgotStudio["a6"]["Padding"] = UDim.new(0, 5);
NgotStudio["a6"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
NgotStudio["a6"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["a7"] = Instance.new("TextBox", NgotStudio["a3"]);
NgotStudio["a7"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["a7"]["PlaceholderColor3"] = Color3.fromRGB(140, 140, 140);
NgotStudio["a7"]["BorderSizePixel"] = 0;
NgotStudio["a7"]["TextWrapped"] = true;
NgotStudio["a7"]["TextTruncate"] = Enum.TextTruncate.AtEnd;
NgotStudio["a7"]["TextSize"] = 14;
NgotStudio["a7"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["a7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["a7"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["a7"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["a7"]["ClipsDescendants"] = true;
NgotStudio["a7"]["PlaceholderText"] = [[Input here...]];
NgotStudio["a7"]["Size"] = UDim2.new(1, 0, 0, 25);
NgotStudio["a7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["a7"]["Text"] = [[]];
NgotStudio["a7"]["BackgroundTransparency"] = 1;

NgotStudio["a8"] = Instance.new("UIPadding", NgotStudio["a7"]);
NgotStudio["a8"]["PaddingTop"] = UDim.new(0, 5);
NgotStudio["a8"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["a8"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["a8"]["PaddingBottom"] = UDim.new(0, 5);

NgotStudio["a9"] = Instance.new("ImageButton", NgotStudio["41"]);
NgotStudio["a9"]["BorderSizePixel"] = 0;
NgotStudio["a9"]["AutoButtonColor"] = false;
NgotStudio["a9"]["Visible"] = false;
NgotStudio["a9"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["a9"]["Selectable"] = false;
NgotStudio["a9"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["a9"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["a9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["a9"]["Name"] = [[Dropdown]];
NgotStudio["a9"]["Position"] = UDim2.new(-0.0375, 0, 0.38434, 0);

NgotStudio["aa"] = Instance.new("UICorner", NgotStudio["a9"]);
NgotStudio["aa"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["ab"] = Instance.new("UIStroke", NgotStudio["a9"]);
NgotStudio["ab"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["ab"]["Thickness"] = 1.5;
NgotStudio["ab"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["ac"] = Instance.new("TextLabel", NgotStudio["a9"]);
NgotStudio["ac"]["TextWrapped"] = true;
NgotStudio["ac"]["BorderSizePixel"] = 0;
NgotStudio["ac"]["TextSize"] = 16;
NgotStudio["ac"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["ac"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["ac"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["ac"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["ac"]["BackgroundTransparency"] = 1;
NgotStudio["ac"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["ac"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["ac"]["Text"] = [[Dropdown]];
NgotStudio["ac"]["Name"] = [[Title]];
NgotStudio["ac"]["Position"] = UDim2.new(0.03135, 0, 0, 0);

NgotStudio["ad"] = Instance.new("ImageButton", NgotStudio["ac"]);
NgotStudio["ad"]["BorderSizePixel"] = 0;
NgotStudio["ad"]["AutoButtonColor"] = false;
NgotStudio["ad"]["BackgroundTransparency"] = 1;

NgotStudio["ad"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["ad"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["ad"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["ad"]["Image"] = [[rbxassetid://77563793724007]];
NgotStudio["ad"]["Size"] = UDim2.new(0, 23, 0, 23);
NgotStudio["ad"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["ad"]["Name"] = [[ClickIcon]];
NgotStudio["ad"]["Position"] = UDim2.new(1, 0, 0.5, 0);

NgotStudio["ae"] = Instance.new("ImageButton", NgotStudio["ac"]);
NgotStudio["ae"]["Active"] = false;
NgotStudio["ae"]["BorderSizePixel"] = 0;
NgotStudio["ae"]["BackgroundTransparency"] = 1;
NgotStudio["ae"]["Selectable"] = false;
NgotStudio["ae"]["ZIndex"] = 0;
NgotStudio["ae"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["ae"]["AutomaticSize"] = Enum.AutomaticSize.X;
NgotStudio["ae"]["Size"] = UDim2.new(0, 20, 0, 20);
NgotStudio["ae"]["Name"] = [[BoxFrame]];
NgotStudio["ae"]["Position"] = UDim2.new(1, -33, 0.5, 0);

NgotStudio["af"] = Instance.new("ImageLabel", NgotStudio["ae"]);
NgotStudio["af"]["Interactable"] = false;
NgotStudio["af"]["ZIndex"] = 0;
NgotStudio["af"]["BorderSizePixel"] = 0;
NgotStudio["af"]["SliceCenter"] = Rect.new(49, 49, 450, 450);
NgotStudio["af"]["ScaleType"] = Enum.ScaleType.Slice;
NgotStudio["af"]["ImageTransparency"] = 0.75;
NgotStudio["af"]["AutomaticSize"] = Enum.AutomaticSize.X;

NgotStudio["af"]["ImageColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["af"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["af"]["Image"] = [[rbxassetid://6014261993]];
NgotStudio["af"]["Size"] = UDim2.new(1, 28, 1, 28);
NgotStudio["af"]["Visible"] = false;
NgotStudio["af"]["BackgroundTransparency"] = 1;
NgotStudio["af"]["Name"] = [[DropShadow]];
NgotStudio["af"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

NgotStudio["b0"] = Instance.new("ImageButton", NgotStudio["ae"]);
NgotStudio["b0"]["BorderSizePixel"] = 0;
NgotStudio["b0"]["AutoButtonColor"] = false;
NgotStudio["b0"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["b0"]["Selectable"] = false;
NgotStudio["b0"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["b0"]["AutomaticSize"] = Enum.AutomaticSize.X;
NgotStudio["b0"]["Size"] = UDim2.new(0, 20, 0, 20);
NgotStudio["b0"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["b0"]["Name"] = [[Trigger]];
NgotStudio["b0"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

NgotStudio["b1"] = Instance.new("UICorner", NgotStudio["b0"]);
NgotStudio["b1"]["CornerRadius"] = UDim.new(0, 5);

NgotStudio["b2"] = Instance.new("UIStroke", NgotStudio["b0"]);
NgotStudio["b2"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["b2"]["Thickness"] = 1.5;
NgotStudio["b2"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["b3"] = Instance.new("UIListLayout", NgotStudio["b0"]);
NgotStudio["b3"]["Padding"] = UDim.new(0, 5);
NgotStudio["b3"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
NgotStudio["b3"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["b4"] = Instance.new("TextLabel", NgotStudio["b0"]);
NgotStudio["b4"]["TextWrapped"] = true;
NgotStudio["b4"]["Interactable"] = false;
NgotStudio["b4"]["BorderSizePixel"] = 0;
NgotStudio["b4"]["TextSize"] = 16;
NgotStudio["b4"]["TextScaled"] = true;
NgotStudio["b4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["b4"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["b4"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["b4"]["BackgroundTransparency"] = 1;
NgotStudio["b4"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["b4"]["Size"] = UDim2.new(0, 15, 0, 14);
NgotStudio["b4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["b4"]["Text"] = [[]];
NgotStudio["b4"]["AutomaticSize"] = Enum.AutomaticSize.X;
NgotStudio["b4"]["Name"] = [[Title]];
NgotStudio["b4"]["Position"] = UDim2.new(-0.00345, 0, 0.5, 0);

NgotStudio["b5"] = Instance.new("UIPadding", NgotStudio["b0"]);
NgotStudio["b5"]["PaddingRight"] = UDim.new(0, 5);
NgotStudio["b5"]["PaddingLeft"] = UDim.new(0, 5);

NgotStudio["b6"] = Instance.new("UIPadding", NgotStudio["a9"]);
NgotStudio["b6"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["b6"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["b6"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["b6"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["b7"] = Instance.new("UIListLayout", NgotStudio["a9"]);
NgotStudio["b7"]["Padding"] = UDim.new(0, 5);
NgotStudio["b7"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["b8"] = Instance.new("TextLabel", NgotStudio["a9"]);
NgotStudio["b8"]["TextWrapped"] = true;
NgotStudio["b8"]["Interactable"] = false;
NgotStudio["b8"]["BorderSizePixel"] = 0;
NgotStudio["b8"]["TextSize"] = 16;
NgotStudio["b8"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["b8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["b8"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["b8"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["b8"]["BackgroundTransparency"] = 1;
NgotStudio["b8"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["b8"]["Visible"] = false;
NgotStudio["b8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["b8"]["Text"] = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["b8"]["LayoutOrder"] = 1;
NgotStudio["b8"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["b8"]["Name"] = [[Description]];

NgotStudio["b9"] = Instance.new("UIGradient", NgotStudio["a9"]);
NgotStudio["b9"]["Enabled"] = false;
NgotStudio["b9"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["ba"] = Instance.new("UIGradient", NgotStudio["a9"]);
NgotStudio["ba"]["Enabled"] = false;
NgotStudio["ba"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["bb"] = Instance.new("UIGradient", NgotStudio["a9"]);
NgotStudio["bb"]["Enabled"] = false;
NgotStudio["bb"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["bc"] = Instance.new("Folder", NgotStudio["41"]);
NgotStudio["bc"]["Name"] = [[DropdownList]];

NgotStudio["bd"] = Instance.new("ScrollingFrame", NgotStudio["bc"]);
NgotStudio["bd"]["Visible"] = false;
NgotStudio["bd"]["Active"] = true;
NgotStudio["bd"]["ScrollingDirection"] = Enum.ScrollingDirection.Y;
NgotStudio["bd"]["BorderSizePixel"] = 0;
NgotStudio["bd"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
NgotStudio["bd"]["ElasticBehavior"] = Enum.ElasticBehavior.Never;
NgotStudio["bd"]["TopImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["bd"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["bd"]["Name"] = [[DropdownItems]];
NgotStudio["bd"]["Selectable"] = false;
NgotStudio["bd"]["BottomImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["bd"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;
NgotStudio["bd"]["Size"] = UDim2.new(1, 0, 1, -50);
NgotStudio["bd"]["ScrollBarImageColor3"] = Color3.fromRGB(99, 106, 122);
NgotStudio["bd"]["Position"] = UDim2.new(0, 0, 0, 50);
NgotStudio["bd"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["bd"]["ScrollBarThickness"] = 5;
NgotStudio["bd"]["BackgroundTransparency"] = 1;

NgotStudio["be"] = Instance.new("UIListLayout", NgotStudio["bd"]);
NgotStudio["be"]["Padding"] = UDim.new(0, 15);
NgotStudio["be"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["bf"] = Instance.new("UIPadding", NgotStudio["bd"]);
NgotStudio["bf"]["PaddingTop"] = UDim.new(0, 2);
NgotStudio["bf"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["bf"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["bf"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["c0"] = Instance.new("ScrollingFrame", NgotStudio["bc"]);
NgotStudio["c0"]["Visible"] = false;
NgotStudio["c0"]["Active"] = true;
NgotStudio["c0"]["ScrollingDirection"] = Enum.ScrollingDirection.Y;
NgotStudio["c0"]["BorderSizePixel"] = 0;
NgotStudio["c0"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
NgotStudio["c0"]["ElasticBehavior"] = Enum.ElasticBehavior.Never;
NgotStudio["c0"]["TopImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["c0"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["c0"]["Name"] = [[DropdownItemsSearch]];
NgotStudio["c0"]["Selectable"] = false;
NgotStudio["c0"]["BottomImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
NgotStudio["c0"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;
NgotStudio["c0"]["Size"] = UDim2.new(1, 0, 1, -50);
NgotStudio["c0"]["ScrollBarImageColor3"] = Color3.fromRGB(99, 106, 122);
NgotStudio["c0"]["Position"] = UDim2.new(0, 0, 0, 50);
NgotStudio["c0"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["c0"]["ScrollBarThickness"] = 5;
NgotStudio["c0"]["BackgroundTransparency"] = 1;

NgotStudio["c1"] = Instance.new("UIListLayout", NgotStudio["c0"]);
NgotStudio["c1"]["Padding"] = UDim.new(0, 15);
NgotStudio["c1"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["c2"] = Instance.new("UIPadding", NgotStudio["c0"]);
NgotStudio["c2"]["PaddingTop"] = UDim.new(0, 2);
NgotStudio["c2"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["c2"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["c2"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["c3"] = Instance.new("ImageButton", NgotStudio["41"]);
NgotStudio["c3"]["BorderSizePixel"] = 0;
NgotStudio["c3"]["AutoButtonColor"] = false;
NgotStudio["c3"]["Visible"] = false;
NgotStudio["c3"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["c3"]["Selectable"] = false;
NgotStudio["c3"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["c3"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["c3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["c3"]["Name"] = [[DropdownButton]];
NgotStudio["c3"]["Position"] = UDim2.new(0, 0, 0.384, 0);

NgotStudio["c4"] = Instance.new("UICorner", NgotStudio["c3"]);
NgotStudio["c4"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["c5"] = Instance.new("Frame", NgotStudio["c3"]);
NgotStudio["c5"]["BorderSizePixel"] = 0;
NgotStudio["c5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["c5"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["c5"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["c5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["c5"]["BackgroundTransparency"] = 1;

NgotStudio["c6"] = Instance.new("UIListLayout", NgotStudio["c5"]);
NgotStudio["c6"]["Padding"] = UDim.new(0, 5);
NgotStudio["c6"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["c7"] = Instance.new("UIPadding", NgotStudio["c5"]);
NgotStudio["c7"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["c7"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["c7"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["c7"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["c8"] = Instance.new("TextLabel", NgotStudio["c5"]);
NgotStudio["c8"]["TextWrapped"] = true;
NgotStudio["c8"]["Interactable"] = false;
NgotStudio["c8"]["BorderSizePixel"] = 0;
NgotStudio["c8"]["TextSize"] = 16;
NgotStudio["c8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["c8"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["c8"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["c8"]["BackgroundTransparency"] = 1;
NgotStudio["c8"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["c8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["c8"]["Text"] = [[Button]];
NgotStudio["c8"]["Name"] = [[Title]];

NgotStudio["c9"] = Instance.new("TextLabel", NgotStudio["c5"]);
NgotStudio["c9"]["TextWrapped"] = true;
NgotStudio["c9"]["Interactable"] = false;
NgotStudio["c9"]["BorderSizePixel"] = 0;
NgotStudio["c9"]["TextSize"] = 16;
NgotStudio["c9"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["c9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["c9"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["c9"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["c9"]["BackgroundTransparency"] = 1;
NgotStudio["c9"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["c9"]["Visible"] = false;
NgotStudio["c9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["c9"]["Text"] = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["c9"]["LayoutOrder"] = 1;
NgotStudio["c9"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["c9"]["Name"] = [[Description]];

NgotStudio["ca"] = Instance.new("UIGradient", NgotStudio["c5"]);
NgotStudio["ca"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["cb"] = Instance.new("UIGradient", NgotStudio["c5"]);
NgotStudio["cb"]["Enabled"] = false;
NgotStudio["cb"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["cc"] = Instance.new("UIGradient", NgotStudio["c5"]);
NgotStudio["cc"]["Enabled"] = false;
NgotStudio["cc"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["cd"] = Instance.new("UICorner", NgotStudio["c5"]);
NgotStudio["cd"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["ce"] = Instance.new("UIStroke", NgotStudio["c3"]);
NgotStudio["ce"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["ce"]["Thickness"] = 1.5;
NgotStudio["ce"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["cf"] = Instance.new("Frame", NgotStudio["41"]);
NgotStudio["cf"]["Visible"] = false;
NgotStudio["cf"]["BorderSizePixel"] = 0;
NgotStudio["cf"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["cf"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["cf"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["cf"]["Position"] = UDim2.new(-0.0375, 0, 0.38434, 0);
NgotStudio["cf"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["cf"]["Name"] = [[Code]];

NgotStudio["d0"] = Instance.new("UICorner", NgotStudio["cf"]);
NgotStudio["d0"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["d1"] = Instance.new("UIStroke", NgotStudio["cf"]);
NgotStudio["d1"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["d1"]["Thickness"] = 1.5;
NgotStudio["d1"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["d2"] = Instance.new("TextLabel", NgotStudio["cf"]);
NgotStudio["d2"]["TextWrapped"] = true;
NgotStudio["d2"]["Interactable"] = false;
NgotStudio["d2"]["BorderSizePixel"] = 0;
NgotStudio["d2"]["TextSize"] = 16;
NgotStudio["d2"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["d2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["d2"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
NgotStudio["d2"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["d2"]["BackgroundTransparency"] = 1;
NgotStudio["d2"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["d2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["d2"]["Text"] = [[Title]];
NgotStudio["d2"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["d2"]["Name"] = [[Title]];

NgotStudio["d3"] = Instance.new("UIPadding", NgotStudio["cf"]);
NgotStudio["d3"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["d3"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["d3"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["d3"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["d4"] = Instance.new("UIListLayout", NgotStudio["cf"]);
NgotStudio["d4"]["Padding"] = UDim.new(0, 5);
NgotStudio["d4"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["d5"] = Instance.new("TextBox", NgotStudio["cf"]);
NgotStudio["d5"]["Name"] = [[Code]];
NgotStudio["d5"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["d5"]["BorderSizePixel"] = 0;
NgotStudio["d5"]["TextEditable"] = false;
NgotStudio["d5"]["TextWrapped"] = true;
NgotStudio["d5"]["TextSize"] = 16;
NgotStudio["d5"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["d5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["d5"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["d5"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["d5"]["Selectable"] = false;
NgotStudio["d5"]["MultiLine"] = true;
NgotStudio["d5"]["ClearTextOnFocus"] = false;
NgotStudio["d5"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["d5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["d5"]["Text"] = [[print("Hello World!")]];
NgotStudio["d5"]["LayoutOrder"] = 1;
NgotStudio["d5"]["BackgroundTransparency"] = 1;
