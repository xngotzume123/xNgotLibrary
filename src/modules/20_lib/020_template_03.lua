--[[ xngot-studio · src/modules/20_lib/020_template_03.lua
     lang   : lua (Luau / Roblox) · executor
     folder : src/modules/20_lib · lõi thư viện UI (template giao diện + closure 3e)
     module : lib.template.03
     role   : Template: Ball (nút nổi), Notification toast, Slider
     source : main 2.txt L1104-1561 · 458 dòng · delta +0
--]]

NgotStudio["68"] = Instance.new("UICorner", NgotStudio["67"]);
NgotStudio["68"]["CornerRadius"] = UDim.new(100, 0);

NgotStudio["69"] = Instance.new("ImageButton", NgotStudio["67"]);
NgotStudio["69"]["Active"] = false;
NgotStudio["69"]["Interactable"] = false;
NgotStudio["69"]["BorderSizePixel"] = 0;
NgotStudio["69"]["AutoButtonColor"] = false;
NgotStudio["69"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["69"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["69"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["69"]["Size"] = UDim2.new(0, 20, 0, 20);
NgotStudio["69"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["69"]["Name"] = [[Ball]];
NgotStudio["69"]["Position"] = UDim2.new(0, 0, 0.5, 0);

NgotStudio["6a"] = Instance.new("UICorner", NgotStudio["69"]);
NgotStudio["6a"]["CornerRadius"] = UDim.new(100, 0);

NgotStudio["6b"] = Instance.new("ImageLabel", NgotStudio["69"]);
NgotStudio["6b"]["BorderSizePixel"] = 0;
NgotStudio["6b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["6b"]["ImageColor3"] = Color3.fromRGB(54, 57, 63);
NgotStudio["6b"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["6b"]["Size"] = UDim2.new(1, -5, 1, -5);
NgotStudio["6b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["6b"]["BackgroundTransparency"] = 1;
NgotStudio["6b"]["Name"] = [[Icon]];
NgotStudio["6b"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

NgotStudio["6c"] = Instance.new("UIPadding", NgotStudio["67"]);
NgotStudio["6c"]["PaddingTop"] = UDim.new(0, 2);
NgotStudio["6c"]["PaddingRight"] = UDim.new(0, 2);
NgotStudio["6c"]["PaddingLeft"] = UDim.new(0, 2);
NgotStudio["6c"]["PaddingBottom"] = UDim.new(0, 2);

NgotStudio["6d"] = Instance.new("Frame", NgotStudio["41"]);
NgotStudio["6d"]["Visible"] = false;
NgotStudio["6d"]["BorderSizePixel"] = 0;
NgotStudio["6d"]["BackgroundColor3"] = Color3.fromRGB(37, 40, 47);
NgotStudio["6d"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["6d"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["6d"]["Size"] = UDim2.new(1, 0, 0, 65);
NgotStudio["6d"]["Position"] = UDim2.new(0.8244, 0, 0.88221, 0);
NgotStudio["6d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["6d"]["Name"] = [[Notification]];
NgotStudio["6d"]["BackgroundTransparency"] = 1;

NgotStudio["6e"] = Instance.new("CanvasGroup", NgotStudio["6d"]);
NgotStudio["6e"]["ZIndex"] = 2;
NgotStudio["6e"]["BorderSizePixel"] = 0;
NgotStudio["6e"]["BackgroundColor3"] = Color3.fromRGB(37, 40, 47);
NgotStudio["6e"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["6e"]["Size"] = UDim2.new(0, 265, 0, 70);
NgotStudio["6e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["6e"]["Name"] = [[Items]];

NgotStudio["6f"] = Instance.new("Frame", NgotStudio["6e"]);
NgotStudio["6f"]["BorderSizePixel"] = 0;
NgotStudio["6f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["6f"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["6f"]["Size"] = UDim2.new(0, 265, 0, 70);
NgotStudio["6f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["6f"]["BackgroundTransparency"] = 1;

NgotStudio["70"] = Instance.new("UIListLayout", NgotStudio["6f"]);
NgotStudio["70"]["Padding"] = UDim.new(0, 5);
NgotStudio["70"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
NgotStudio["70"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["71"] = Instance.new("UIPadding", NgotStudio["6f"]);
NgotStudio["71"]["PaddingTop"] = UDim.new(0, 15);
NgotStudio["71"]["PaddingLeft"] = UDim.new(0, 15);
NgotStudio["71"]["PaddingBottom"] = UDim.new(0, 15);

NgotStudio["72"] = Instance.new("TextLabel", NgotStudio["6f"]);
NgotStudio["72"]["TextWrapped"] = true;
NgotStudio["72"]["BorderSizePixel"] = 0;
NgotStudio["72"]["TextSize"] = 12;
NgotStudio["72"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["72"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["72"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
NgotStudio["72"]["TextColor3"] = Color3.fromRGB(181, 181, 181);
NgotStudio["72"]["BackgroundTransparency"] = 1;
NgotStudio["72"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["72"]["Size"] = UDim2.new(0, 218, 0, 10);
NgotStudio["72"]["Visible"] = false;
NgotStudio["72"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["72"]["Text"] = [[This is a notification]];
NgotStudio["72"]["LayoutOrder"] = 1;
NgotStudio["72"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["72"]["Name"] = [[SubContent]];
NgotStudio["72"]["Position"] = UDim2.new(0, 0, 0, 19);

NgotStudio["73"] = Instance.new("UIGradient", NgotStudio["72"]);
NgotStudio["73"]["Enabled"] = false;
NgotStudio["73"]["Rotation"] = -90;
NgotStudio["73"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(3, 100, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 226))};

NgotStudio["74"] = Instance.new("TextLabel", NgotStudio["6f"]);
NgotStudio["74"]["TextWrapped"] = true;
NgotStudio["74"]["BorderSizePixel"] = 0;
NgotStudio["74"]["TextSize"] = 16;
NgotStudio["74"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["74"]["TextScaled"] = true;
NgotStudio["74"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["74"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
NgotStudio["74"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["74"]["BackgroundTransparency"] = 1;
NgotStudio["74"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["74"]["Size"] = UDim2.new(0, 235, 0, 18);
NgotStudio["74"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["74"]["Text"] = [[Title]];
NgotStudio["74"]["Name"] = [[Title]];
NgotStudio["74"]["Position"] = UDim2.new(0, 0, 0, 9);

NgotStudio["75"] = Instance.new("ImageButton", NgotStudio["74"]);
NgotStudio["75"]["BorderSizePixel"] = 0;
NgotStudio["75"]["BackgroundTransparency"] = 1;

NgotStudio["75"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["75"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["75"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["75"]["Image"] = [[rbxassetid://132453323679056]];
NgotStudio["75"]["Size"] = UDim2.new(0.09706, 0, 1.33333, 0);
NgotStudio["75"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["75"]["Name"] = [[Close]];
NgotStudio["75"]["Position"] = UDim2.new(0.92, 0, 0.5, 0);

NgotStudio["76"] = Instance.new("UIAspectRatioConstraint", NgotStudio["75"]);

NgotStudio["77"] = Instance.new("UIPadding", NgotStudio["74"]);
NgotStudio["77"]["PaddingLeft"] = UDim.new(0, 30);

NgotStudio["78"] = Instance.new("ImageButton", NgotStudio["74"]);
NgotStudio["78"]["BorderSizePixel"] = 0;
NgotStudio["78"]["BackgroundTransparency"] = 1;

NgotStudio["78"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["78"]["ImageColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["78"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["78"]["Image"] = [[rbxassetid://92049322344253]];
NgotStudio["78"]["Size"] = UDim2.new(0.09706, 0, 1.33333, 0);
NgotStudio["78"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["78"]["Name"] = [[Icon]];
NgotStudio["78"]["Position"] = UDim2.new(0, -30, 0.5, 0);

NgotStudio["79"] = Instance.new("UIAspectRatioConstraint", NgotStudio["78"]);

NgotStudio["7a"] = Instance.new("TextLabel", NgotStudio["6f"]);
NgotStudio["7a"]["TextWrapped"] = true;
NgotStudio["7a"]["BorderSizePixel"] = 0;
NgotStudio["7a"]["TextSize"] = 16;
NgotStudio["7a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["7a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["7a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["7a"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["7a"]["BackgroundTransparency"] = 1;
NgotStudio["7a"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["7a"]["Size"] = UDim2.new(0, 218, 0, 10);
NgotStudio["7a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["7a"]["Text"] = [[Content]];
NgotStudio["7a"]["LayoutOrder"] = 2;
NgotStudio["7a"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["7a"]["Name"] = [[Content]];
NgotStudio["7a"]["Position"] = UDim2.new(0, 0, 0, 19);

NgotStudio["7b"] = Instance.new("UIGradient", NgotStudio["7a"]);
NgotStudio["7b"]["Enabled"] = false;
NgotStudio["7b"]["Rotation"] = -90;
NgotStudio["7b"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(3, 100, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 226))};

NgotStudio["7c"] = Instance.new("Frame", NgotStudio["6e"]);
NgotStudio["7c"]["BorderSizePixel"] = 0;
NgotStudio["7c"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["7c"]["AnchorPoint"] = Vector2.new(0, 1);
NgotStudio["7c"]["Size"] = UDim2.new(1, 0, 0, 5);
NgotStudio["7c"]["Position"] = UDim2.new(0, 0, 1, 0);
NgotStudio["7c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["7c"]["Name"] = [[TimerBarFill]];
NgotStudio["7c"]["BackgroundTransparency"] = 0.7;

NgotStudio["7d"] = Instance.new("UICorner", NgotStudio["7c"]);

NgotStudio["7e"] = Instance.new("Frame", NgotStudio["7c"]);
NgotStudio["7e"]["BorderSizePixel"] = 0;
NgotStudio["7e"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 75);
NgotStudio["7e"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["7e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["7e"]["Name"] = [[Bar]];

NgotStudio["7f"] = Instance.new("UICorner", NgotStudio["7e"]);

NgotStudio["80"] = Instance.new("UIStroke", NgotStudio["6e"]);
NgotStudio["80"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["80"]["Thickness"] = 1.5;
NgotStudio["80"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["81"] = Instance.new("UICorner", NgotStudio["6e"]);

NgotStudio["82"] = Instance.new("Frame", NgotStudio["41"]);
NgotStudio["82"]["Visible"] = false;
NgotStudio["82"]["BorderSizePixel"] = 0;
NgotStudio["82"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["82"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["82"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["82"]["Position"] = UDim2.new(-0.0375, 0, 0.38434, 0);
NgotStudio["82"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["82"]["Name"] = [[Slider]];

NgotStudio["83"] = Instance.new("UICorner", NgotStudio["82"]);
NgotStudio["83"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["84"] = Instance.new("UIStroke", NgotStudio["82"]);
NgotStudio["84"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["84"]["Thickness"] = 1.5;
NgotStudio["84"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["85"] = Instance.new("TextLabel", NgotStudio["82"]);
NgotStudio["85"]["TextWrapped"] = true;
NgotStudio["85"]["Interactable"] = false;
NgotStudio["85"]["BorderSizePixel"] = 0;
NgotStudio["85"]["TextSize"] = 16;
NgotStudio["85"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["85"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["85"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
NgotStudio["85"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["85"]["BackgroundTransparency"] = 1;
NgotStudio["85"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["85"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["85"]["Text"] = [[Slider]];
NgotStudio["85"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["85"]["Name"] = [[Title]];

NgotStudio["86"] = Instance.new("UIPadding", NgotStudio["82"]);
NgotStudio["86"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["86"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["86"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["86"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["87"] = Instance.new("UIListLayout", NgotStudio["82"]);
NgotStudio["87"]["Padding"] = UDim.new(0, 5);
NgotStudio["87"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["88"] = Instance.new("TextLabel", NgotStudio["82"]);
NgotStudio["88"]["TextWrapped"] = true;
NgotStudio["88"]["Interactable"] = false;
NgotStudio["88"]["BorderSizePixel"] = 0;
NgotStudio["88"]["TextSize"] = 16;
NgotStudio["88"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["88"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["88"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["88"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["88"]["BackgroundTransparency"] = 1;
NgotStudio["88"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["88"]["Visible"] = false;
NgotStudio["88"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["88"]["Text"] = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["88"]["LayoutOrder"] = 1;
NgotStudio["88"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["88"]["Name"] = [[Description]];

NgotStudio["89"] = Instance.new("Frame", NgotStudio["82"]);
NgotStudio["89"]["ZIndex"] = 0;
NgotStudio["89"]["BorderSizePixel"] = 0;
NgotStudio["89"]["Size"] = UDim2.new(1, 0, 0, 25);
NgotStudio["89"]["Name"] = [[SliderFrame]];
NgotStudio["89"]["LayoutOrder"] = 2;
NgotStudio["89"]["BackgroundTransparency"] = 1;

NgotStudio["8a"] = Instance.new("Frame", NgotStudio["89"]);
NgotStudio["8a"]["ZIndex"] = 0;
NgotStudio["8a"]["BorderSizePixel"] = 0;
NgotStudio["8a"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["8a"]["Size"] = UDim2.new(1, 0, 0, 20);
NgotStudio["8a"]["Position"] = UDim2.new(0, 0, 0.5, 0);
NgotStudio["8a"]["BackgroundTransparency"] = 1;

NgotStudio["8b"] = Instance.new("ImageLabel", NgotStudio["8a"]);
NgotStudio["8b"]["ZIndex"] = 0;
NgotStudio["8b"]["BorderSizePixel"] = 0;
NgotStudio["8b"]["SliceCenter"] = Rect.new(49, 49, 450, 450);
NgotStudio["8b"]["ScaleType"] = Enum.ScaleType.Slice;
NgotStudio["8b"]["ImageTransparency"] = 0.75;

NgotStudio["8b"]["ImageColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["8b"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["8b"]["Image"] = [[rbxassetid://6014261993]];
NgotStudio["8b"]["Size"] = UDim2.new(1, 25, 1, 25);
NgotStudio["8b"]["BackgroundTransparency"] = 1;
NgotStudio["8b"]["Name"] = [[DropShadow]];
NgotStudio["8b"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

NgotStudio["8c"] = Instance.new("CanvasGroup", NgotStudio["8a"]);
NgotStudio["8c"]["BorderSizePixel"] = 0;
NgotStudio["8c"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["8c"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["8c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["8c"]["Name"] = [[Slider]];

NgotStudio["8d"] = Instance.new("UICorner", NgotStudio["8c"]);
NgotStudio["8d"]["CornerRadius"] = UDim.new(0, 5);

NgotStudio["8e"] = Instance.new("UIStroke", NgotStudio["8c"]);
NgotStudio["8e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["8e"]["Thickness"] = 1.5;
NgotStudio["8e"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["8f"] = Instance.new("UIPadding", NgotStudio["8c"]);
NgotStudio["8f"]["PaddingTop"] = UDim.new(0, 2);
NgotStudio["8f"]["PaddingRight"] = UDim.new(0, 2);
NgotStudio["8f"]["PaddingLeft"] = UDim.new(0, 2);
NgotStudio["8f"]["PaddingBottom"] = UDim.new(0, 2);

NgotStudio["90"] = Instance.new("TextButton", NgotStudio["8c"]);
NgotStudio["90"]["BorderSizePixel"] = 0;
NgotStudio["90"]["TextSize"] = 14;
NgotStudio["90"]["AutoButtonColor"] = false;
NgotStudio["90"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["90"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["90"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
NgotStudio["90"]["BackgroundTransparency"] = 1;
NgotStudio["90"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["90"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["90"]["Text"] = [[]];
NgotStudio["90"]["Name"] = [[Trigger]];

NgotStudio["91"] = Instance.new("ImageButton", NgotStudio["8c"]);
NgotStudio["91"]["Active"] = false;
NgotStudio["91"]["Interactable"] = false;
NgotStudio["91"]["BorderSizePixel"] = 0;
NgotStudio["91"]["AutoButtonColor"] = false;
NgotStudio["91"]["BackgroundTransparency"] = 1;
NgotStudio["91"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["91"]["Selectable"] = false;
NgotStudio["91"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["91"]["Size"] = UDim2.new(0, 0, 1, 0);
NgotStudio["91"]["ClipsDescendants"] = true;
NgotStudio["91"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["91"]["Name"] = [[Fill]];
NgotStudio["91"]["Position"] = UDim2.new(0, 0, 0.5, 0);

NgotStudio["92"] = Instance.new("UICorner", NgotStudio["91"]);
NgotStudio["92"]["CornerRadius"] = UDim.new(0, 4);

NgotStudio["93"] = Instance.new("UIStroke", NgotStudio["91"]);
NgotStudio["93"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["93"]["Thickness"] = 1.5;
NgotStudio["93"]["Color"] = Color3.fromRGB(11, 136, 214);

NgotStudio["94"] = Instance.new("ImageButton", NgotStudio["91"]);
NgotStudio["94"]["Active"] = false;
NgotStudio["94"]["Interactable"] = false;
NgotStudio["94"]["BorderSizePixel"] = 0;
NgotStudio["94"]["AutoButtonColor"] = false;
NgotStudio["94"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["94"]["Selectable"] = false;
NgotStudio["94"]["AnchorPoint"] = Vector2.new(0, 0.5);
NgotStudio["94"]["Size"] = UDim2.new(1, 0, 1, 0);
NgotStudio["94"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["94"]["Name"] = [[BackgroundGradient]];
NgotStudio["94"]["Position"] = UDim2.new(0, 0, 0.5, 0);

NgotStudio["95"] = Instance.new("UICorner", NgotStudio["94"]);
NgotStudio["95"]["CornerRadius"] = UDim.new(0, 4);

NgotStudio["96"] = Instance.new("UIGradient", NgotStudio["94"]);
NgotStudio["96"]["Enabled"] = false;
NgotStudio["96"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["97"] = Instance.new("UIGradient", NgotStudio["94"]);
NgotStudio["97"]["Enabled"] = false;
NgotStudio["97"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 235, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["98"] = Instance.new("UIGradient", NgotStudio["94"]);
NgotStudio["98"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.160, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.320, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(0.540, Color3.fromRGB(0, 5, 255)),ColorSequenceKeypoint.new(0.782, Color3.fromRGB(0, 158, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 158, 255))};

NgotStudio["99"] = Instance.new("TextLabel", NgotStudio["8a"]);
NgotStudio["99"]["TextWrapped"] = true;
NgotStudio["99"]["Interactable"] = false;
NgotStudio["99"]["ZIndex"] = 2;
NgotStudio["99"]["BorderSizePixel"] = 0;
NgotStudio["99"]["TextSize"] = 14;
NgotStudio["99"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["99"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["99"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
NgotStudio["99"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["99"]["BackgroundTransparency"] = 1;
NgotStudio["99"]["RichText"] = true;
NgotStudio["99"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
NgotStudio["99"]["Size"] = UDim2.new(1, -15, 1, 0);
NgotStudio["99"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["99"]["Text"] = [[0]];
NgotStudio["99"]["Name"] = [[ValueText]];
NgotStudio["99"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

NgotStudio["9a"] = Instance.new("Frame", NgotStudio["41"]);
NgotStudio["9a"]["Visible"] = false;
NgotStudio["9a"]["BorderSizePixel"] = 0;
NgotStudio["9a"]["BackgroundColor3"] = Color3.fromRGB(43, 46, 53);
NgotStudio["9a"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["9a"]["Size"] = UDim2.new(1, 0, 0, 35);
NgotStudio["9a"]["Position"] = UDim2.new(-0.0375, 0, 0.38434, 0);
NgotStudio["9a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["9a"]["Name"] = [[TextBox]];

NgotStudio["9b"] = Instance.new("UICorner", NgotStudio["9a"]);
NgotStudio["9b"]["CornerRadius"] = UDim.new(0, 6);

NgotStudio["9c"] = Instance.new("UIStroke", NgotStudio["9a"]);
NgotStudio["9c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
NgotStudio["9c"]["Thickness"] = 1.5;
NgotStudio["9c"]["Color"] = Color3.fromRGB(61, 61, 75);

NgotStudio["9d"] = Instance.new("TextLabel", NgotStudio["9a"]);
NgotStudio["9d"]["TextWrapped"] = true;
NgotStudio["9d"]["Interactable"] = false;
NgotStudio["9d"]["BorderSizePixel"] = 0;
NgotStudio["9d"]["TextSize"] = 16;
NgotStudio["9d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["9d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["9d"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
NgotStudio["9d"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["9d"]["BackgroundTransparency"] = 1;
NgotStudio["9d"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["9d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["9d"]["Text"] = [[Input Textbox]];
NgotStudio["9d"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["9d"]["Name"] = [[Title]];

NgotStudio["9e"] = Instance.new("UIPadding", NgotStudio["9a"]);
NgotStudio["9e"]["PaddingTop"] = UDim.new(0, 10);
NgotStudio["9e"]["PaddingRight"] = UDim.new(0, 10);
NgotStudio["9e"]["PaddingLeft"] = UDim.new(0, 10);
NgotStudio["9e"]["PaddingBottom"] = UDim.new(0, 10);

NgotStudio["9f"] = Instance.new("UIListLayout", NgotStudio["9a"]);
NgotStudio["9f"]["Padding"] = UDim.new(0, 10);
NgotStudio["9f"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

NgotStudio["a0"] = Instance.new("TextLabel", NgotStudio["9a"]);
NgotStudio["a0"]["TextWrapped"] = true;
NgotStudio["a0"]["Interactable"] = false;
NgotStudio["a0"]["BorderSizePixel"] = 0;
NgotStudio["a0"]["TextSize"] = 16;
NgotStudio["a0"]["TextXAlignment"] = Enum.TextXAlignment.Left;
NgotStudio["a0"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
NgotStudio["a0"]["FontFace"] = Font.new([[rbxassetid://11702779517]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
NgotStudio["a0"]["TextColor3"] = Color3.fromRGB(197, 204, 219);
NgotStudio["a0"]["BackgroundTransparency"] = 1;
NgotStudio["a0"]["Size"] = UDim2.new(1, 0, 0, 15);
NgotStudio["a0"]["Visible"] = false;
NgotStudio["a0"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
NgotStudio["a0"]["Text"] = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus placerat lacus in enim congue, fermentum euismod leo ultricies. Nulla sodales. ]];
NgotStudio["a0"]["LayoutOrder"] = 1;
NgotStudio["a0"]["AutomaticSize"] = Enum.AutomaticSize.Y;
NgotStudio["a0"]["Name"] = [[Description]];
