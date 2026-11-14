--[[ xngot-studio · src/modules/20_lib/020_template_05.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.template.05
     role   : Template: Section, Button, Dialog, Notification, TabButton cuối
     source : main 2.txt L2008-2452 · 445 dòng · delta +0
--]]

NgotStudio["d6"] = Instance.new("Frame", NgotStudio["41"]);
NgotStudio["d6"]["Visible"] = false;
NgotStudio["d6"]["BorderSizePixel"] = 0;
NgotStudio["d6"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["d6"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["d6"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["d6"]["Position"] = UDim2.new(0, 0, 0.43728, 0);
NgotStudio["d6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["d6"]["Name"] = [[Section]];
NgotStudio["d6"]["BackgroundTransparency"] = 1;

NgotStudio["d7"] = Instance.new("ImageButton", NgotStudio["d6"]);
NgotStudio["d7"]["BorderSizePixel"] = 0;
NgotStudio["d7"]["AutoButtonColor"] = false;
NgotStudio["d7"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["d7"]["Selectable"] = false;
NgotStudio["d7"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["d7"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["d7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["d7"]["Name"] = [[Button]];

NgotStudio["d8"] = Instance.new("UICorner", NgotStudio["d7"]);
NgotStudio["d8"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["d9"] = Instance.new("UIStroke", NgotStudio["d7"]);
NgotStudio["d9"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["d9"]["Thickness"] = 1.5;
NgotStudio["d9"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["da"] = Instance.new("TextLabel", NgotStudio["d7"]);
NgotStudio["da"]["TextWrapped"] = true;
NgotStudio["da"]["Interactable"] = false;
NgotStudio["da"]["BorderSizePixel"] = 0;
NgotStudio["da"]["TextSize"] = 16;
NgotStudio["da"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["da"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["da"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["da"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["da"]["BackgroundTransparency"] = 1;
NgotStudio["da"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["da"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["da"]["Text"] = [[Section]];
NgotStudio["da"]["Name"] = [[Title]];

NgotStudio["db"] = Instance.new("ImageButton", NgotStudio["da"]);
NgotStudio["db"]["BorderSizePixel"] = 0;
NgotStudio["db"]["AutoButtonColor"] = false;
NgotStudio["db"]["BackgroundTransparency"] = 1;

NgotStudio["db"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["db"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["db"]["AnchorPoint"] = Vector2.new(1, 0.5);
NgotStudio["db"]["Image"] = [[rbxassetid://120292618616139]];
NgotStudio["db"]["Size"] = UDim2.new(0, 23, 0, 23);
NgotStudio["db"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["db"]["Name"] = [[Arrow]];
NgotStudio["db"]["Position"] = UDim2.new(1, 0, 0.5, 0);

NgotStudio["dc"] = Instance.new("UIPadding", NgotStudio["d7"]);
NgotStudio["dc"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["dc"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["dc"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["dc"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["dd"] = Instance.new("UIListLayout", NgotStudio["d7"]);
NgotStudio["dd"]["Padding"] = UDim.new(0, 5);
NgotStudio["dd"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["de"] = Instance.new("TextLabel", NgotStudio["d7"]);
NgotStudio["de"]["TextWrapped"] = true;
NgotStudio["de"]["Interactable"] = false;
NgotStudio["de"]["BorderSizePixel"] = 0;
NgotStudio["de"]["TextSize"] = 16;
NgotStudio["de"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["de"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["de"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["de"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["de"]["BackgroundTransparency"] = 1;
NgotStudio["de"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["de"]["Visible"] = false;
NgotStudio["de"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["de"]["Text"] = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["de"]["LayoutOrder"] = 1;
NgotStudio["de"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["de"]["Name"] = [[Description]];

NgotStudio["df"] = Instance.new("UIGradient", NgotStudio["d7"]);
NgotStudio["df"]["Enabled"] = false;
NgotStudio["df"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["e0"] = Instance.new("UIGradient", NgotStudio["d7"]);
NgotStudio["e0"]["Enabled"] = false;
NgotStudio["e0"]["Transparency"] = NumberSequence.new{NumberSequenceKeypoint.new(0.000, 1),NumberSequenceKeypoint.new(1.000, 1)};
NgotStudio["e0"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["e1"] = Instance.new("UIGradient", NgotStudio["d7"]);
NgotStudio["e1"]["Enabled"] = false;
NgotStudio["e1"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["e2"] = Instance.new("UIStroke", NgotStudio["d7"]);
NgotStudio["e2"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["e2"]["Thickness"] = 1.5;
NgotStudio["e2"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["e3"] = Instance.new("Frame", NgotStudio["d6"]);
NgotStudio["e3"]["Visible"] = false;
NgotStudio["e3"]["BorderSizePixel"] = 0;
NgotStudio["e3"]["BackgroundColor3"] = Color3.fromRGB(207, 222, 255);
NgotStudio["e3"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["e3"]["Size"] = UDim2.new(1, 0, 0, 30);
NgotStudio["e3"]["Position"] = UDim2.new(0, 0, 0, 35);
NgotStudio["e3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["e3"]["BackgroundTransparency"] = 1;

NgotStudio["e4"] = Instance.new("UIListLayout", NgotStudio["e3"]);
NgotStudio["e4"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
NgotStudio["e4"]["Padding"] = UDim.new(0, 10);
NgotStudio["e4"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["e5"] = Instance.new("UIPadding", NgotStudio["e3"]);
NgotStudio["e5"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["e5"]["PaddingRight"] = UDim.new(0, 8);
NgotStudio["e5"]["PaddingLeft"] = UDim.new(0, 8);

NgotStudio["e6"] = Instance.new("Frame", NgotStudio["e3"]);
NgotStudio["e6"]["BorderSizePixel"] = 0;
NgotStudio["e6"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["e6"]["Size"] = UDim2.new(1, 0, 0, 3);
NgotStudio["e6"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["e6"]["Name"] = [[Divider]];

NgotStudio["e7"] = Instance.new("Folder", NgotStudio["41"]);
NgotStudio["e7"]["Name"] = [[DialogElements]];

NgotStudio["e8"] = Instance.new("Frame", NgotStudio["e7"]);
NgotStudio["e8"]["Visible"] = false;
NgotStudio["e8"]["BorderSizePixel"] = 0;
NgotStudio["e8"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["e8"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["e8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["e8"]["Name"] = [[DarkOverlayDialog]];
NgotStudio["e8"]["BackgroundTransparency"] = 0.6;

NgotStudio["e9"] = Instance.new("UICorner", NgotStudio["e8"]);
NgotStudio["e9"]["CornerRadius"] = UDim.new(0, 10);

NgotStudio["ea"] = Instance.new("Frame", NgotStudio["e7"]);
NgotStudio["ea"]["Visible"] = false;
NgotStudio["ea"]["ZIndex"] = 4;
NgotStudio["ea"]["BorderSizePixel"] = 0;
NgotStudio["ea"]["BackgroundColor3"] = Color3.fromRGB(32, 35, 41);
NgotStudio["ea"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["ea"]["ClipsDescendants"] = true;
NgotStudio["ea"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["ea"]["Size"] = UDim2.new(0, 250, 0, 0);
NgotStudio["ea"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
NgotStudio["ea"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["ea"]["Name"] = [[Dialog]];

NgotStudio["eb"] = Instance.new("UICorner", NgotStudio["ea"]);
NgotStudio["eb"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["ec"] = Instance.new("UIStroke", NgotStudio["ea"]);
NgotStudio["ec"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["ec"]["Thickness"] = 1.5;
NgotStudio["ec"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["ed"] = Instance.new("Frame", NgotStudio["ea"]);
NgotStudio["ed"]["BorderSizePixel"] = 0;
NgotStudio["ed"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["ed"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["ed"]["Size"] = UDim2.new(1, 0, 0, 25);
NgotStudio["ed"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["ed"]["Name"] = [[Title]];
NgotStudio["ed"]["BackgroundTransparency"] = 1;

NgotStudio["ee"] = Instance.new("TextLabel", NgotStudio["ed"]);
NgotStudio["ee"]["Interactable"] = false;
NgotStudio["ee"]["ZIndex"] = 0;
NgotStudio["ee"]["BorderSizePixel"] = 0;
NgotStudio["ee"]["TextSize"] = 20;
NgotStudio["ee"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["ee"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["ee"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["ee"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["ee"]["BackgroundTransparency"] = 1;
NgotStudio["ee"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["ee"]["Size"] = UDim2.new(0, 0, 0, 20);
NgotStudio["ee"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["ee"]["Text"] = [[]];
NgotStudio["ee"]["LayoutOrder"] = 1;
NgotStudio["ee"]["AutomaticSize"] = Enum.AutomaticSize.XY;
NgotStudio["ee"]["Position"] = UDim2.new(-0.05455, 12, 0.5, 0);

NgotStudio["ef"] = Instance.new("UIListLayout", NgotStudio["ed"]);
NgotStudio["ef"]["Padding"] = UDim.new(0, 10);
NgotStudio["ef"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
NgotStudio["ef"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
NgotStudio["ef"]["FillDirection"] = Enum.FillDirection.Horizontal;

NgotStudio["f0"] = Instance.new("UIPadding", NgotStudio["ed"]);
NgotStudio["f0"]["PaddingTop"] = UDim.new(0, 5);
NgotStudio["f0"]["PaddingRight"] = UDim.new(0, 15);
NgotStudio["f0"]["PaddingLeft"] = UDim.new(0, 15);
NgotStudio["f0"]["PaddingBottom"] = UDim.new(0, 5);

NgotStudio["f1"] = Instance.new("ImageButton", NgotStudio["ed"]);
NgotStudio["f1"]["BorderSizePixel"] = 0;
NgotStudio["f1"]["Visible"] = false;
NgotStudio["f1"]["BackgroundTransparency"] = 1;
NgotStudio["f1"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["f1"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["f1"]["Size"] = UDim2.new(0, 33, 0, 25);
NgotStudio["f1"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["f1"]["Name"] = [[Icon]];
NgotStudio["f1"]["Position"] = UDim2.new(0, 0, 0.2125, 0);

NgotStudio["f2"] = Instance.new("UIAspectRatioConstraint", NgotStudio["f1"]);

NgotStudio["f3"] = Instance.new("UIListLayout", NgotStudio["ea"]);
NgotStudio["f3"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
NgotStudio["f3"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["f4"] = Instance.new("Frame", NgotStudio["ea"]);
NgotStudio["f4"]["Visible"] = false;
NgotStudio["f4"]["ZIndex"] = 2;
NgotStudio["f4"]["BorderSizePixel"] = 0;
NgotStudio["f4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["f4"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["f4"]["Size"] = UDim2.new(1, 0, 0, 0);
NgotStudio["f4"]["Position"] = UDim2.new(0, 0, 0.21886, 0);
NgotStudio["f4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["f4"]["Name"] = [[Content]];
NgotStudio["f4"]["BackgroundTransparency"] = 1;

NgotStudio["f5"] = Instance.new("UIListLayout", NgotStudio["f4"]);
NgotStudio["f5"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
NgotStudio["f5"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["f6"] = Instance.new("UIPadding", NgotStudio["f4"]);
NgotStudio["f6"]["PaddingTop"] = UDim.new(0, 5);
NgotStudio["f6"]["PaddingRight"] = UDim.new(0, 15);
NgotStudio["f6"]["PaddingLeft"] = UDim.new(0, 15);
NgotStudio["f6"]["PaddingBottom"] = UDim.new(0, 5);

NgotStudio["f7"] = Instance.new("TextLabel", NgotStudio["f4"]);
NgotStudio["f7"]["TextWrapped"] = true;
NgotStudio["f7"]["Interactable"] = false;
NgotStudio["f7"]["BorderSizePixel"] = 0;
NgotStudio["f7"]["TextSize"] = 15;
NgotStudio["f7"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["f7"]["TextYAlignment"] = Enum.TextYAlignment.Top;
NgotStudio["f7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["f7"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["f7"]["TextColor3"] = Color3.fromRGB(145, 154, 173);
NgotStudio["f7"]["BackgroundTransparency"] = 1;
NgotStudio["f7"]["Size"] = UDim2.new(1, 0, 0, 0);
NgotStudio["f7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["f7"]["Text"] = [[]];
NgotStudio["f7"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["f7"]["Position"] = UDim2.new(0, 0, 0.125, 0);

NgotStudio["f8"] = Instance.new("UIPadding", NgotStudio["ea"]);
NgotStudio["f8"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["f8"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["f9"] = Instance.new("Frame", NgotStudio["ea"]);
NgotStudio["f9"]["ZIndex"] = 3;
NgotStudio["f9"]["BorderSizePixel"] = 0;
NgotStudio["f9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["f9"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["f9"]["Size"] = UDim2.new(1, 0, 0, 0);
NgotStudio["f9"]["Position"] = UDim2.new(0, 0, 0.53017, 0);
NgotStudio["f9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["f9"]["Name"] = [[Buttons]];
NgotStudio["f9"]["BackgroundTransparency"] = 1;

NgotStudio["fa"] = Instance.new("UIListLayout", NgotStudio["f9"]);
NgotStudio["fa"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
NgotStudio["fa"]["Padding"] = UDim.new(0, 10);
NgotStudio["fa"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["fb"] = Instance.new("UIPadding", NgotStudio["f9"]);
NgotStudio["fb"]["PaddingTop"] = UDim.new(0, 5);
NgotStudio["fb"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["fb"]["PaddingLeft"] = UDim.new(0, 10);

NgotStudio["fc"] = Instance.new("Frame", NgotStudio["e7"]);
NgotStudio["fc"]["Visible"] = false;
NgotStudio["fc"]["BorderSizePixel"] = 0;
NgotStudio["fc"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["fc"]["AnchorPoint"] = Vector2.new(0.5, 1);
NgotStudio["fc"]["Size"] = UDim2.new(1, 0, 0, 30);
NgotStudio["fc"]["Position"] = UDim2.new(0.5, 0, 0.327, 0);
NgotStudio["fc"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["fc"]["Name"] = [[DialogButton]];
NgotStudio["fc"]["BackgroundTransparency"] = 1;

NgotStudio["fd"] = Instance.new("TextButton", NgotStudio["fc"]);
NgotStudio["fd"]["BorderSizePixel"] = 0;
NgotStudio["fd"]["AutoButtonColor"] = false;
NgotStudio["fd"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["fd"]["Selectable"] = false;
NgotStudio["fd"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["fd"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["fd"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["fd"]["Name"] = [[Button]];
NgotStudio["fd"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

NgotStudio["fe"] = Instance.new("UICorner", NgotStudio["fd"]);
NgotStudio["fe"]["CornerRadius"] = UDim.new(0, 5);

NgotStudio["ff"] = Instance.new("UIStroke", NgotStudio["fd"]);
NgotStudio["ff"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["ff"]["Thickness"] = 1.5;
NgotStudio["ff"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["100"] = Instance.new("UIListLayout", NgotStudio["fd"]);
NgotStudio["100"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
NgotStudio["100"]["Padding"] = UDim.new(0, 5);
NgotStudio["100"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
NgotStudio["100"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["101"] = Instance.new("TextLabel", NgotStudio["fd"]);
NgotStudio["101"]["TextWrapped"] = true;
NgotStudio["101"]["Interactable"] = false;
NgotStudio["101"]["BorderSizePixel"] = 0;
NgotStudio["101"]["TextSize"] = 14;
NgotStudio["101"]["TextScaled"] = true;
NgotStudio["101"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["101"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
NgotStudio["101"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["101"]["BackgroundTransparency"] = 1;
NgotStudio["101"]["Size"] = UDim2.new(1, 0, 0.45, 0);
NgotStudio["101"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["101"]["Text"] = [[]];
NgotStudio["101"]["Name"] = [[Label]];
NgotStudio["101"]["Position"] = UDim2.new(0, 45, 0.083, 0);

NgotStudio["102"] = Instance.new("Frame", NgotStudio["1"]);
NgotStudio["102"]["ZIndex"] = 10;
NgotStudio["102"]["BorderSizePixel"] = 0;
NgotStudio["102"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["102"]["AnchorPoint"] = Vector2.new(0.5, 0);
NgotStudio["102"]["Size"] = UDim2.new(0, 630, 1, 0);
NgotStudio["102"]["Position"] = UDim2.new(1, 0, 0, 0);
NgotStudio["102"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["102"]["Name"] = [[NotificationList]];
NgotStudio["102"]["BackgroundTransparency"] = 1;

NgotStudio["103"] = Instance.new("UIListLayout", NgotStudio["102"]);
NgotStudio["103"]["Padding"] = UDim.new(0, 12);
NgotStudio["103"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["104"] = Instance.new("UIPadding", NgotStudio["102"]);
NgotStudio["104"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["104"]["PaddingRight"] = UDim.new(0, 40);
NgotStudio["104"]["PaddingLeft"] = UDim.new(0, 40);

NgotStudio["105"] = Instance.new("Frame", NgotStudio["1"]);
NgotStudio["105"]["Visible"] = false;
NgotStudio["105"]["ZIndex"] = 0;
NgotStudio["105"]["BorderSizePixel"] = 2;
NgotStudio["105"]["BackgroundColor3"] = Color3.fromRGB(37, 40, 47);
NgotStudio["105"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["105"]["ClipsDescendants"] = true;
NgotStudio["105"]["AutomaticSize"] = Enum.AutomaticSize.X;
NgotStudio["105"]["Size"] = UDim2.new(0, 85, 0, 45);
NgotStudio["105"]["Position"] = UDim2.new(0.5, 0, 0, 45);
NgotStudio["105"]["BorderColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["105"]["Name"] = [[FloatIcon]];

NgotStudio["106"] = Instance.new("UICorner", NgotStudio["105"]);
NgotStudio["106"]["CornerRadius"] = UDim.new(0, 10);

NgotStudio["107"] = Instance.new("UIStroke", NgotStudio["105"]);
NgotStudio["107"]["Transparency"] = 0.5;
NgotStudio["107"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["107"]["Thickness"] = 1.5;
NgotStudio["107"]["Color"] = Color3.fromRGB(95, 95, 117);

NgotStudio["108"] = Instance.new("UIPadding", NgotStudio["105"]);
NgotStudio["108"]["PaddingTop"] = UDim.new(0, 8);
NgotStudio["108"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["108"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["108"]["PaddingBottom"] = UDim.new(0, 8);

NgotStudio["109"] = Instance.new("UIListLayout", NgotStudio["105"]);
NgotStudio["109"]["Padding"] = UDim.new(0, 8);
NgotStudio["109"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
NgotStudio["109"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
NgotStudio["109"]["FillDirection"] = Enum.FillDirection.Horizontal;

NgotStudio["10a"] = Instance.new("ImageButton", NgotStudio["105"]);
NgotStudio["10a"]["Active"] = false;
NgotStudio["10a"]["Interactable"] = false;
NgotStudio["10a"]["BorderSizePixel"] = 0;
NgotStudio["10a"]["AutoButtonColor"] = false;
NgotStudio["10a"]["BackgroundTransparency"] = 1;

NgotStudio["10a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["10a"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["10a"]["Image"] = [[rbxassetid://113216930555884]];
NgotStudio["10a"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["10a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["10a"]["Name"] = [[Icon]];
NgotStudio["10a"]["Position"] = UDim2.new(0, 10, 0.5, 0);

NgotStudio["10b"] = Instance.new("UIAspectRatioConstraint", NgotStudio["10a"]);

NgotStudio["10c"] = Instance.new("TextLabel", NgotStudio["105"]);
NgotStudio["10c"]["Interactable"] = false;
NgotStudio["10c"]["BorderSizePixel"] = 0;
NgotStudio["10c"]["TextSize"] = 16;
NgotStudio["10c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["10c"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
NgotStudio["10c"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["10c"]["BackgroundTransparency"] = 1;
NgotStudio["10c"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["10c"]["Size"] = UDim2.new(0, 20, 0, 20);
NgotStudio["10c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["10c"]["Text"] = [[NgotStudio]];
NgotStudio["10c"]["AutomaticSize"] = Enum.AutomaticSize.X;
NgotStudio["10c"]["Position"] = UDim2.new(0.38615, 0, 0.53448, -1);

NgotStudio["10d"] = Instance.new("ImageButton", NgotStudio["105"]);
NgotStudio["10d"]["BorderSizePixel"] = 0;
NgotStudio["10d"]["AutoButtonColor"] = false;
NgotStudio["10d"]["BackgroundTransparency"] = 1;

NgotStudio["10d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["10d"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["10d"]["Selectable"] = false;
NgotStudio["10d"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["10d"]["Image"] = [[rbxassetid://122219713887461]];
NgotStudio["10d"]["Size"] = UDim2.new(0, 20, 0, 20);
NgotStudio["10d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["10d"]["Name"] = [[Open]];
NgotStudio["10d"]["Position"] = UDim2.new(0, 128, 0.5, 0);

NgotStudio["10e"] = Instance.new("UIAspectRatioConstraint", NgotStudio["10d"]);

NgotStudio["10f"] = Instance.new("UICorner", NgotStudio["10d"]);

