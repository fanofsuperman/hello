local g = getinfo or debug.getinfo 
local d = false 
local h = {} 
local x, y 
setthreadidentity(2) 
for i, v in getgc(true) do 
    if typeof(v) == "table" then 
        local a = rawget(v, "Detected") 
        local b = rawget(v, "Kill") 
        if typeof(a) == "function" and not x then 
            x = a 
            local o 
            o = hookfunction( x, function(c, f, n) 
                if c ~= "_" then 
                    if d then 
                        warn("Adonis AntiCheat flagged\nMethod: " .. tostring(c) .. "\nInfo: " .. tostring(f)) 
                    end 
                end 
                return true 
            end ) 
            table.insert(h, x) 
        end 
        if rawget(v, "Variables") and rawget(v, "Process") and typeof(b) == "function" and not y then 
            y = b 
            local o 
            o = hookfunction( y, function(f) 
                if d then 
                    warn("Adonis AntiCheat tried to kill (fallback): " .. tostring(f)) 
                end 
            end ) 
            table.insert(h, y) 
        end 
    end 
end 
local o 
o = hookfunction( getrenv().debug.info, newcclosure( function(...) 
    local a, f = ... 
    if x and a == x then 
        if d then 
            warn("zins | adonis bypassed") 
        end 
        return coroutine.yield(coroutine.running()) 
    end 
    return o(...) 
end ) ) 
setthreadidentity(7)

-- SINGLE CONFIGURATION OBJECT - ALL SETTINGS IN ONE PLACE
getgenv().FlexedConfig = {
    Vepar = {
        Camlock = {
            Prediction = 0.1678963,
            PredictionMethod = {
                X = 0.11,
                Y = 0.10,
            }
        },
        JumpCheck = {
            Jump = -0.92,
            Fall = -1.91,
            TargetPart = "HumanoidRootPart"
        },
        Silent = {
            FOV = {
                Enabled = true,
                Prediction = 0.165,
                AutoCheckJump = true,
                AntiGroundShot = false,
            },
            AutoAir = {
                AutoAir = true,
                AirMaterial = "Jump",
            }
        }
    },
    
    DaHood = {
        SilentAim = false,
        WallCheck = false,
        FOV = 100,
        SilentPrediction = 0.124,
        SilentTargetPart = "HumanoidRootPart",
        Camlock = {
            Enabled = false,
            TargetPart = "UpperTorso",
            Prediction = 0.1475,
            Smoothness = 0.405,
            SmoothEnabled = true
        },
        Aimlock = {
            Enabled = false,
            TargetPart = "HumanoidRootPart",
            Prediction = 0.188259,
            Horizontal = 0.14664,
            Vertical = 0.07,
            X = 0.14664,
            Y = 0.07
        },
        AutoAir = false,
        TargetNPCs = false,
        AutoShoot = false,
        AutoDisableOnDeath = false,
        AntiLock = false,
        TPWalk = {
            Enabled = false,
            Speed = 4
        },
        TriggerBot = {
            Enabled = false,
            Prediction = 0.09
        },
        Visuals = {
            ShowChams = false,
            ShowTracer = false,
            ShowNameESP = false
        },
        NoclipFly = {
            Enabled = false,
            Speed = 5
        }
    },
    
    ESP = {
        Enabled = true,
        Box = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1.5
        },
        Tracer = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1.5
        },
        Outline = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255)
        },
        Line = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255)
        },
        Name = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Size = 14
        },
        Distance = {
            Enabled = false,
            Color = Color3.fromRGB(200, 200, 200),
            Size = 12
        }
    },
    
    BlacklistedTools = {
        "Knife"
    },
    
    UI = {
        Font = Enum.Font.Code,
        BaseSize = Vector2.new(600, 450),
        MenuKey = Enum.KeyCode.RightShift,
        Colors = {
            Main = Color3.fromRGB(14, 14, 14),
            Secondary = Color3.fromRGB(26, 26, 26),
            Accent = Color3.fromRGB(189, 172, 255),
            Text = Color3.fromRGB(200, 200, 200),
            TextDark = Color3.fromRGB(120, 120, 120),
            Stroke = Color3.fromRGB(40, 40, 40)
        }
    }
}

local Config = getgenv().FlexedConfig

Config.DaHood.Camlock.Prediction = Config.Vepar.Camlock.Prediction
Config.DaHood.Aimlock.Prediction = Config.Vepar.Camlock.Prediction
Config.DaHood.Aimlock.Horizontal = Config.Vepar.Camlock.PredictionMethod.X
Config.DaHood.Aimlock.Vertical = Config.Vepar.Camlock.PredictionMethod.Y
Config.DaHood.Aimlock.X = Config.Vepar.Camlock.PredictionMethod.X
Config.DaHood.Aimlock.Y = Config.Vepar.Camlock.PredictionMethod.Y

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local CFG = {
    MainColor = Config.UI.Colors.Main,
    SecondaryColor = Config.UI.Colors.Secondary,
    AccentColor = Config.UI.Colors.Accent,
    TextColor = Config.UI.Colors.Text,
    TextDark = Config.UI.Colors.TextDark,
    StrokeColor = Config.UI.Colors.Stroke,
    Font = Config.UI.Font,
    BaseSize = Config.UI.BaseSize
}

local Library = {
    Flags = {},
    Connections = {},
    Unloaded = false,
    MenuKey = Config.UI.MenuKey
}

local tpwalking = false
local tpwalkSpeed = Config.DaHood.TPWalk.Speed or 4
local savedTPSpeed = tostring(tpwalkSpeed)

local noclipEnabled = false
local noclipEvent = nil
local noclipPos = nil
local noclipSpeed = Config.DaHood.NoclipFly.Speed or 5
local savedNoclipSpeed = tostring(noclipSpeed)

local antiLockConnection = nil

local ESPBoxes = {}
local ESPTracers = {}

local function Create(class, props, children)
    local inst = Instance.new(class)
    for i, v in pairs(props or {}) do
        inst[i] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function Tween(obj, props, time, style, dir)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function GetTextSize(text, size, font)
    return game:GetService("TextService"):GetTextSize(text, size, font, Vector2.new(10000, 10000))
end

local ScreenGui = Create("ScreenGui", {
    Name = "FlexedUI",
    Parent = game:GetService("CoreGui"),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    IgnoreGuiInset = true
})

local UIScale = Create("UIScale", {Parent = ScreenGui})

local function UpdateScale()
    local vp = workspace.CurrentCamera.ViewportSize
    local widthRatio = (vp.X - 40) / CFG.BaseSize.X
    local heightRatio = (vp.Y - 40) / CFG.BaseSize.Y
    local scale = math.min(widthRatio, heightRatio, 1)
    UIScale.Scale = math.max(scale, 0.6)
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
UpdateScale()

local NotificationContainer = Create("Frame", {
    Parent = ScreenGui,
    Position = UDim2.new(1, -20, 0, 20),
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 300, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 100
})

local UIListNotif = Create("UIListLayout", {
    Parent = NotificationContainer,
    Padding = UDim.new(0, 5),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Top
})

function Library:Notify(msg, type)
    local color = (type == "success" and Color3.fromRGB(100, 255, 100)) or (type == "warning" and Color3.fromRGB(255, 100, 100)) or CFG.AccentColor
    local Frame = Create("Frame", {
        Parent = NotificationContainer,
        Size = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = CFG.MainColor,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, {
        Create("UIStroke", {Color = CFG.AccentColor, Thickness = 1, Transparency = 0.5}),
        Create("Frame", {
            Size = UDim2.new(0, 2, 1, 0),
            BackgroundColor3 = color
        }),
        Create("TextLabel", {
            Text = msg,
            TextColor3 = CFG.TextColor,
            Font = CFG.Font,
            TextSize = 12,
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
    Tween(Frame, {Size = UDim2.new(0, 250, 0, 35)}, 0.5, Enum.EasingStyle.Back)
    task.delay(3, function()
        Tween(Frame, {Size = UDim2.new(0, 250, 0, 0), BackgroundTransparency = 1}, 0.5)
        task.wait(0.5)
        Frame:Destroy()
    end)
end

local TooltipLabel = Create("TextLabel", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 0, 0, 20),
    BackgroundColor3 = CFG.SecondaryColor,
    TextColor3 = CFG.TextColor,
    TextSize = 11,
    Font = CFG.Font,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 200
}, {
    Create("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)}),
    Create("UIStroke", {Color = CFG.StrokeColor})
})

local function AddTooltip(obj, text)
    obj.MouseEnter:Connect(function()
        TooltipLabel.Text = text
        TooltipLabel.Size = UDim2.fromOffset(GetTextSize(text, 11, CFG.Font).X + 12, 20)
        TooltipLabel.Visible = true
    end)
    obj.MouseLeave:Connect(function()
        TooltipLabel.Visible = false
    end)
end

RunService.RenderStepped:Connect(function()
    if TooltipLabel.Visible then
        local m = UserInputService:GetMouseLocation()
        TooltipLabel.Position = UDim2.fromOffset(m.X + 15, m.Y + 15)
    end
end)

local MainFrame = Create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    Size = UDim2.fromOffset(CFG.BaseSize.X, CFG.BaseSize.Y),
    Position = UDim2.new(0.5, -300, 0.5, -225),
    BackgroundColor3 = CFG.MainColor,
    BorderSizePixel = 0
}, {
    Create("UIStroke", {Color = CFG.StrokeColor}),
    Create("UICorner", {CornerRadius = UDim.new(0, 3)})
})

local Dragging, DragInput, DragStart, StartPos = false, nil, nil, nil
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local delta = input.Position - DragStart
        Tween(MainFrame, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)}, 0.05)
    end
end)

local TopBar = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = CFG.MainColor,
    BorderSizePixel = 0
}, {
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = CFG.StrokeColor
    })
})

local TitleLabel = Create("TextLabel", {
    Parent = TopBar,
    Text = "flexed.wtf",
    TextColor3 = CFG.TextDark,
    TextSize = 13,
    Font = CFG.Font,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    RichText = true
})

task.spawn(function()
    local textList = { 
        '', 'f', 'fl', 'fle', 'flex', 'flexe', 'flexed', 'flexed.', 'flexed.w', 'flexed.wt', 'flexed.wtf',
        'flexed.wt', 'flexed.w', 'flexed.', 'flexed', 'flexe', 'flex', 'fle', 'fl', 'f', '' 
    }
    while not Library.Unloaded do
        for _, text in ipairs(textList) do
            if Library.Unloaded then break end
            local display = text
            if string.find(text, "wtf") then
                display = string.gsub(text, "wtf", '<font color="#bdacff">wtf</font>')
            end
            TitleLabel.Text = display
            task.wait(0.2)
        end
    end
end)

local ContentContainer = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 1, -30),
    Position = UDim2.new(0, 0, 0, 30),
    BackgroundTransparency = 1
})

local Sidebar = Create("Frame", {
    Parent = ContentContainer,
    Size = UDim2.new(0, 60, 1, 0),
    BackgroundColor3 = Color3.fromRGB(17, 17, 17),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 0)
}, {
    Create("Frame", {Size = UDim2.new(0, 1, 0, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = CFG.StrokeColor}),
    Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top}),
    Create("UIPadding", {PaddingTop = UDim.new(0, 15)})
})

local PagesContainer = Create("Frame", {
    Parent = ContentContainer,
    Size = UDim2.new(1, -60, 1, 0),
    Position = UDim2.new(0, 60, 0, 0),
    BackgroundTransparency = 1
})

local Tabs = {}
local CurrentTab = nil

function Library:Tab(name, icon)
    local TabButton = Create("TextButton", {
        Parent = Sidebar,
        Size = UDim2.new(0, 40, 0, 40),
        BackgroundColor3 = CFG.MainColor,
        Text = "",
        TextSize = 20,
        TextColor3 = CFG.TextDark,
        Font = CFG.Font,
        AutoButtonColor = false
    }, {
        Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0.6, 0, 0.6, 0),
            Position = UDim2.new(0.2, 0, 0.2, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://" .. icon,
            ImageColor3 = CFG.TextDark
        }),
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    local PageFrame = Create("ScrollingFrame", {
        Parent = PagesContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CFG.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, {
        Create("UIPadding", {PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)}),
        Create("UIGridLayout", { CellSize = UDim2.new(0.48, 0, 0, 0), CellPadding = UDim2.new(0.02, 0, 0, 10), FillDirectionMaxCells = 2 })
    })
    
    PageFrame:ClearAllChildren()
    local LeftCol = Create("Frame", {Parent = PageFrame, Size = UDim2.new(0.48, 0, 1, 0), BackgroundTransparency = 1}, {
        Create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
    })
    local RightCol = Create("Frame", {Parent = PageFrame, Size = UDim2.new(0.48, 0, 1, 0), Position = UDim2.new(0.52, 0, 0, 0), BackgroundTransparency = 1}, {
        Create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
    })
    
    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            Tween(t.Btn, {TextColor3 = CFG.TextDark, BackgroundColor3 = CFG.MainColor}, 0.2)
            t.Page.Visible = false
        end
        Tween(TabButton, {TextColor3 = CFG.AccentColor, BackgroundColor3 = CFG.SecondaryColor}, 0.2)
        PageFrame.Visible = true
        CurrentTab = PageFrame
    end)
    
    table.insert(Tabs, {Btn = TabButton, Page = PageFrame})
    if #Tabs == 1 then
        Tween(TabButton, {TextColor3 = CFG.AccentColor, BackgroundColor3 = CFG.SecondaryColor}, 0.2)
        PageFrame.Visible = true
    end
    
    local GroupFunctions = {}
    local LeftSide = true
    
    function GroupFunctions:Group(title)
        local ParentCol = LeftSide and LeftCol or RightCol
        LeftSide = not LeftSide
        
        local GroupFrame = Create("Frame", {
            Parent = ParentCol,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(17, 17, 17),
            BorderSizePixel = 0
        }, {
            Create("UIStroke", {Color = CFG.StrokeColor}),
            Create("UICorner", {CornerRadius = UDim.new(0, 2)})
        })
        
        Create("Frame", {
            Parent = GroupFrame,
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundColor3 = CFG.SecondaryColor,
            BorderSizePixel = 0
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
            Create("Frame", {
                Size = UDim2.new(1, 0, 0, 5),
                Position = UDim2.new(0, 0, 1, -5),
                BackgroundColor3 = CFG.SecondaryColor,
                BorderSizePixel = 0
            }),
            Create("TextLabel", {
                Text = title,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = CFG.TextColor,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Create("Frame", {
                Size = UDim2.new(0, 4, 0, 4),
                Position = UDim2.new(1, -10, 0.5, -2),
                BackgroundColor3 = CFG.AccentColor,
                BorderSizePixel = 0
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
        })
        
        local Content = Create("Frame", {
            Parent = GroupFrame,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 25),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1
        }, {
            Create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}),
            Create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
        })
        
        local ItemFuncs = {}
        
        function ItemFuncs:Toggle(cfg)
            local Enabled = false
            local Frame = Create("TextButton", {
                Parent = Content,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = ""
            })
            
            local Box = Create("Frame", {
                Parent = Frame,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 0, 0.5, -6),
                BackgroundColor3 = CFG.SecondaryColor,
                BorderSizePixel = 0
            }, {Create("UIStroke", {Color = CFG.StrokeColor})})
            
            local Check = Create("Frame", {
                Parent = Box,
                Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = CFG.AccentColor,
                BackgroundTransparency = 1
            })
            
            local Label = Create("TextLabel", {
                Parent = Frame,
                Text = cfg.Name,
                TextColor3 = CFG.TextDark,
                TextSize = 11,
                Font = CFG.Font,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 18, 0, 0),
                Size = UDim2.new(1, -18, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if cfg.Tooltip then
                AddTooltip(Frame, cfg.Tooltip)
            end
            
            local function Update()
                Enabled = not Enabled
                Tween(Check, {BackgroundTransparency = Enabled and 0 or 1}, 0.1)
                Tween(Label, {TextColor3 = Enabled and CFG.TextColor or CFG.TextDark}, 0.1)
                if cfg.Callback then
                    cfg.Callback(Enabled)
                end
            end
            
            Frame.MouseButton1Click:Connect(Update)
            
            return {
                Set = function(v)
                    if v ~= Enabled then
                        Update()
                    end
                end
            }
        end
        
        function ItemFuncs:Slider(cfg)
            local Value = cfg.Default or cfg.Min
            local DraggingSlider = false
            
            local Frame = Create("Frame", {
                Parent = Content,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1
            })
            
            local Label = Create("TextLabel", {
                Parent = Frame,
                Text = cfg.Name,
                TextColor3 = CFG.TextDark,
                TextSize = 11,
                Font = CFG.Font,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ValueLabel = Create("TextLabel", {
                Parent = Frame,
                Text = Value .. (cfg.Unit or ""),
                TextColor3 = CFG.TextDark,
                TextSize = 11,
                Font = CFG.Font,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local SliderBG = Create("Frame", {
                Parent = Frame,
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundColor3 = CFG.SecondaryColor,
                BorderSizePixel = 0
            }, {
                Create("UIStroke", {Color = CFG.StrokeColor}),
                Create("UICorner", {CornerRadius = UDim.new(1, 0)})
            })
            
            local Fill = Create("Frame", {
                Parent = SliderBG,
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = CFG.AccentColor
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            
            local initialPercent = (Value - cfg.Min) / (cfg.Max - cfg.Min)
            Fill.Size = UDim2.new(initialPercent, 0, 1, 0)
            
            local function Update(input)
                local SizeX = SliderBG.AbsoluteSize.X
                local PosX = SliderBG.AbsolutePosition.X
                local InputX = input.Position.X
                local Percent = math.clamp((InputX - PosX) / SizeX, 0, 1)
                Value = cfg.Min + (cfg.Max - cfg.Min) * Percent
                
                if cfg.Unit == "px" then
                    Value = math.floor(Value + 0.5)
                else
                    Value = math.floor(Value * 100 + 0.5) / 100
                end
                
                Value = math.clamp(Value, cfg.Min, cfg.Max)
                Fill.Size = UDim2.new(Percent, 0, 1, 0)
                ValueLabel.Text = Value .. (cfg.Unit or "")
                if cfg.Callback then
                    cfg.Callback(Value)
                end
            end
            
            Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DraggingSlider = true
                    Update(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if DraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DraggingSlider = false
                end
            end)
            
            if cfg.Tooltip then
                AddTooltip(Frame, cfg.Tooltip)
            end
        end
        
        function ItemFuncs:Dropdown(cfg)
            local Expanded = false
            local Current = cfg.Default or cfg.Options[1]
            
            local Frame = Create("Frame", {
                Parent = Content,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                ZIndex = 20
            })
            
            Create("TextLabel", {
                Parent = Frame,
                Text = cfg.Name,
                TextColor3 = CFG.TextDark,
                TextSize = 11,
                Font = CFG.Font,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local MainBox = Create("TextButton", {
                Parent = Frame,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 16),
                BackgroundColor3 = CFG.SecondaryColor,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false
            }, {
                Create("UIStroke", {Color = CFG.StrokeColor}),
                Create("UICorner", {CornerRadius = UDim.new(0, 3)}),
                Create("TextLabel", {
                    Name = "Val",
                    Text = Current,
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = CFG.TextColor,
                    TextSize = 11,
                    Font = CFG.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                Create("TextLabel", {
                    Text = "▼",
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = CFG.TextDark,
                    TextSize = 10
                })
            })
            
            local ListFrame = Create("ScrollingFrame", {
                Parent = MainBox,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = CFG.SecondaryColor,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 50,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2
            }, {
                Create("UIStroke", {Color = CFG.StrokeColor}),
                Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}),
                Create("UICorner", {CornerRadius = UDim.new(0, 3)})
            })
            
            for _, opt in pairs(cfg.Options) do
                local Btn = Create("TextButton", {
                    Parent = ListFrame,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = opt,
                    TextColor3 = (opt == Current) and CFG.AccentColor or CFG.TextDark,
                    TextSize = 11,
                    Font = CFG.Font
                })
                
                Btn.MouseButton1Click:Connect(function()
                    Current = opt
                    MainBox.Val.Text = opt
                    if cfg.Callback then
                        cfg.Callback(opt)
                    end
                    Expanded = false
                    Tween(ListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.1)
                    task.wait(0.1)
                    ListFrame.Visible = false
                end)
            end
            
            MainBox.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                if Expanded then
                    ListFrame.Visible = true
                    Tween(ListFrame, {Size = UDim2.new(1, 0, 0, math.min(#cfg.Options * 20, 100))}, 0.1)
                else
                    Tween(ListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.1)
                    task.wait(0.1)
                    ListFrame.Visible = false
                end
            end)
            
            if cfg.Tooltip then
                AddTooltip(Frame, cfg.Tooltip)
            end
        end
        
        function ItemFuncs:ColorPicker(cfg)
            local Color = cfg.Default or Color3.fromRGB(255, 255, 255)
            local Opened = false
            
            local Frame = Create("Frame", {
                Parent = Content,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                ZIndex = 15
            })
            
            Create("TextLabel", {
                Parent = Frame,
                Text = cfg.Name,
                TextColor3 = CFG.TextDark,
                TextSize = 11,
                Font = CFG.Font,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.6, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Preview = Create("TextButton", {
                Parent = Frame,
                Size = UDim2.new(0, 30, 0, 14),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                BackgroundColor3 = Color,
                Text = "",
                AutoButtonColor = false
            }, {
                Create("UIStroke", {Color = CFG.StrokeColor}),
                Create("UICorner", {CornerRadius = UDim.new(0, 3)})
            })
            
            local PickerFrame = Create("Frame", {
                Parent = Preview,
                Size = UDim2.new(0, 180, 0, 0),
                Position = UDim2.new(1, 0, 1, 5),
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = CFG.MainColor,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 60
            }, {
                Create("UIStroke", {Color = CFG.StrokeColor}),
                Create("UICorner", {CornerRadius = UDim.new(0, 3)})
            })
            
            local SatValPanel = Create("TextButton", {
                Parent = PickerFrame,
                Size = UDim2.new(1, -20, 0, 100),
                Position = UDim2.new(0, 10, 0, 10),
                BackgroundColor3 = Color3.fromHSV(0, 1, 1),
                Text = "",
                AutoButtonColor = false
            }, {
                Create("ImageLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://4801885019"
                }),
                Create("ImageLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://4801885019",
                    ImageColor3 = Color3.new(0,0,0),
                    Rotation = 90
                })
            })
            
            local Cursor = Create("Frame", {
                Parent = SatValPanel,
                Size = UDim2.new(0, 4, 0, 4),
                BackgroundColor3 = Color3.new(1,1,1),
                AnchorPoint = Vector2.new(0.5, 0.5)
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            
            local HueSlider = Create("TextButton", {
                Parent = PickerFrame,
                Size = UDim2.new(1, -20, 0, 10),
                Position = UDim2.new(0, 10, 0, 120),
                Text = "",
                AutoButtonColor = false
            }, {
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))
                    })
                }),
                Create("UICorner", {CornerRadius = UDim.new(0, 2)})
            })
            
            local H, S, V = 0, 1, 1
            local DraggingHSV, DraggingHue = false, false
            
            local function UpdateColor()
                Color = Color3.fromHSV(H, S, V)
                Preview.BackgroundColor3 = Color
                SatValPanel.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                if cfg.Callback then
                    cfg.Callback(Color)
                end
            end
            
            SatValPanel.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    DraggingHSV = true
                end
            end)
            
            HueSlider.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    DraggingHue = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    DraggingHSV = false; DraggingHue = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    if DraggingHSV then
                        local size = SatValPanel.AbsoluteSize
                        local pos = SatValPanel.AbsolutePosition
                        local x = math.clamp((inp.Position.X - pos.X) / size.X, 0, 1)
                        local y = math.clamp((inp.Position.Y - pos.Y) / size.Y, 0, 1)
                        S = x
                        V = 1 - y
                        UpdateColor()
                    elseif DraggingHue then
                        local size = HueSlider.AbsoluteSize
                        local pos = HueSlider.AbsolutePosition
                        local x = math.clamp((inp.Position.X - pos.X) / size.X, 0, 1)
                        H = x
                        UpdateColor()
                    end
                end
            end)
            
            Preview.MouseButton1Click:Connect(function()
                Opened = not Opened
                if Opened then
                    Tween(PickerFrame, {Size = UDim2.new(0, 180, 0, 170)}, 0.2)
                else
                    Tween(PickerFrame, {Size = UDim2.new(0, 180, 0, 0)}, 0.2)
                end
            end)
            
            if cfg.Tooltip then
                AddTooltip(Frame, cfg.Tooltip)
            end
        end
        
        function ItemFuncs:Textbox(cfg)
            local Frame = Create("Frame", {
                Parent = Content,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1
            })
            
            Create("TextLabel", {
                Parent = Frame,
                Text = cfg.Name,
                TextColor3 = CFG.TextDark,
                TextSize = 11,
                Font = CFG.Font,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Box = Create("TextBox", {
                Parent = Frame,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 15),
                BackgroundColor3 = CFG.SecondaryColor,
                TextColor3 = CFG.TextColor,
                Text = cfg.Default or "",
                Font = CFG.Font,
                TextSize = 11,
                BorderSizePixel = 0
            }, {
                Create("UIStroke", {Color = CFG.StrokeColor}),
                Create("UICorner", {CornerRadius = UDim.new(0, 3)}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 5)})
            })
            
            Box.FocusLost:Connect(function()
                if cfg.Callback then
                    cfg.Callback(Box.Text)
                end
            end)
            
            if cfg.Tooltip then
                AddTooltip(Frame, cfg.Tooltip)
            end
        end
        
        function ItemFuncs:Keybind(cfg)
            local Key = cfg.Default or Enum.KeyCode.Insert
            local Waiting = false
            
            local Frame = Create("Frame", {
                Parent = Content,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1
            })
            
            Create("TextLabel", {
                Parent = Frame,
                Text = cfg.Name,
                TextColor3 = CFG.TextDark,
                TextSize = 11,
                Font = CFG.Font,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.6, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Btn = Create("TextButton", {
                Parent = Frame,
                Size = UDim2.new(0, 60, 1, 0),
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = CFG.SecondaryColor,
                Text = Key.Name,
                TextColor3 = CFG.TextDark,
                TextSize = 10,
                Font = CFG.Font
            }, {
                Create("UIStroke", {Color = CFG.StrokeColor}),
                Create("UICorner", {CornerRadius = UDim.new(0, 3)})
            })
            
            Btn.MouseButton1Click:Connect(function()
                Waiting = true
                Btn.Text = "..."
                Btn.TextColor3 = CFG.AccentColor
            end)
            
            UserInputService.InputBegan:Connect(function(inp)
                if Waiting and inp.UserInputType == Enum.UserInputType.Keyboard then
                    Waiting = false
                    Key = inp.KeyCode
                    Btn.Text = Key.Name
                    Btn.TextColor3 = CFG.TextDark
                    if cfg.Callback then
                        cfg.Callback(Key)
                    end
                end
            end)
            
            if cfg.Tooltip then
                AddTooltip(Frame, cfg.Tooltip)
            end
        end
        
        function ItemFuncs:Button(cfg)
            local Btn = Create("TextButton", {
                Parent = Content,
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = CFG.SecondaryColor,
                Text = cfg.Name,
                TextColor3 = CFG.TextDark,
                Font = Enum.Font.GothamBold,
                TextSize = 10
            }, {
                Create("UIStroke", {Color = CFG.StrokeColor}),
                Create("UICorner", {CornerRadius = UDim.new(0, 3)})
            })
            
            if cfg.Variant == "Primary" then
                Btn.BackgroundColor3 = CFG.AccentColor
                Btn.TextColor3 = Color3.new(0,0,0)
            elseif cfg.Variant == "Danger" then
                Btn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
                Btn.TextColor3 = Color3.new(0,0,0)
            end
            
            Btn.MouseButton1Click:Connect(function()
                if cfg.Callback then
                    cfg.Callback()
                end
            end)
            
            if cfg.Tooltip then
                AddTooltip(Btn, cfg.Tooltip)
            end
        end
        
        return ItemFuncs
    end
    
    return GroupFunctions
end

-- Create TP Walk Frame
local TpWalkFrame = Create("Frame", {
    Name = "TpWalkFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 120, 0, 95),
    Position = UDim2.new(0.5, -60, 0.5, 0),
    BackgroundColor3 = CFG.MainColor,
    BorderSizePixel = 0,
    ZIndex = 20,
    Visible = false
}, {
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
    Create("UIStroke", {Thickness = 2, Color = CFG.StrokeColor}),
    Create("TextLabel", {
        Name = "TopLabel",
        Size = UDim2.new(1, 0, 0.25, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = CFG.TextColor,
        Text = "TP Walk",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ZIndex = 21
    }),
    Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(0.8, 0, 0.35, 0),
        Position = UDim2.new(0.1, 0, 0.28, 0),
        BackgroundColor3 = Color3.fromRGB(160, 80, 80),
        TextColor3 = CFG.TextColor,
        Text = "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        ZIndex = 21
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})}),
    Create("TextBox", {
        Name = "SpeedBox",
        Size = UDim2.new(0.8, 0, 0.25, 0),
        Position = UDim2.new(0.1, 0, 0.65, 0),
        BackgroundColor3 = CFG.SecondaryColor,
        TextColor3 = CFG.TextColor,
        PlaceholderText = "Speed",
        Text = savedTPSpeed,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        BorderSizePixel = 0,
        ZIndex = 21
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})}),
    Create("TextLabel", {
        Name = "BottomLabel",
        Size = UDim2.new(1, 0, 0.18, 0),
        Position = UDim2.new(0, 0, 0.85, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(189, 172, 255),
        Text = ".gg/flexed",
        Font = Enum.Font.Gotham,
        TextSize = 9,
        ZIndex = 21
    })
})

-- Create Noclip/Cframe Fly Frame with Speed Control
local NoclipFrame = Create("Frame", {
    Name = "NoclipFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 120, 0, 95),
    Position = UDim2.new(0.5, -60, 0.5, 0),
    BackgroundColor3 = CFG.MainColor,
    BorderSizePixel = 0,
    ZIndex = 20,
    Visible = false
}, {
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
    Create("UIStroke", {Thickness = 2, Color = CFG.StrokeColor}),
    Create("TextLabel", {
        Name = "TopLabel",
        Size = UDim2.new(1, 0, 0.25, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = CFG.TextColor,
        Text = "Cframe Fly",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ZIndex = 21
    }),
    Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(0.8, 0, 0.35, 0),
        Position = UDim2.new(0.1, 0, 0.28, 0),
        BackgroundColor3 = Color3.fromRGB(160, 80, 80),
        TextColor3 = CFG.TextColor,
        Text = "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        ZIndex = 21
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})}),
    Create("TextBox", {
        Name = "SpeedBox",
        Size = UDim2.new(0.8, 0, 0.25, 0),
        Position = UDim2.new(0.1, 0, 0.65, 0),
        BackgroundColor3 = CFG.SecondaryColor,
        TextColor3 = CFG.TextColor,
        PlaceholderText = "Speed",
        Text = savedNoclipSpeed,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        BorderSizePixel = 0,
        ZIndex = 21
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})}),
    Create("TextLabel", {
        Name = "BottomLabel",
        Size = UDim2.new(1, 0, 0.18, 0),
        Position = UDim2.new(0, 0, 0.85, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(189, 172, 255),
        Text = ".gg/flexed",
        Font = Enum.Font.Gotham,
        TextSize = 9,
        ZIndex = 21
    })
})

-- ESP Box Functions - COMPLETELY EXCLUDES LOCAL PLAYER
local function createBoxESP(player)
    if player == LocalPlayer then return end
    
    ESPBoxes[player] = {
        lines = {}
    }
    
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Color = Config.ESP.Box.Color
        line.Thickness = Config.ESP.Box.Thickness
        line.Transparency = 1
        table.insert(ESPBoxes[player].lines, line)
    end
end

local function removeBoxESP(player)
    if ESPBoxes[player] then
        for _, line in pairs(ESPBoxes[player].lines) do
            line:Remove()
        end
        ESPBoxes[player] = nil
    end
end

-- ESP Tracer Functions - COMPLETELY EXCLUDES LOCAL PLAYER
local function createTracerESP(player)
    if player == LocalPlayer then return end
    
    local line = Drawing.new("Line")
    line.Color = Config.ESP.Tracer.Color
    line.Thickness = Config.ESP.Tracer.Thickness
    line.Transparency = 1
    
    ESPTracers[player] = line
end

local function removeTracerESP(player)
    if ESPTracers[player] then
        ESPTracers[player]:Remove()
        ESPTracers[player] = nil
    end
end

-- Initialize ESP for existing players - STRICTLY SKIP LOCAL PLAYER
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createBoxESP(player)
        createTracerESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createBoxESP(player)
        createTracerESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeBoxESP(player)
    removeTracerESP(player)
end)

-- ESP Box Update Loop - STRICTLY EXCLUDES LOCAL PLAYER
RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    local screenSize = camera.ViewportSize
    
    -- Handle Box ESP
    if Config.ESP.Box.Enabled then
        for player, data in pairs(ESPBoxes) do
            if not player or player == LocalPlayer then
                for _, line in pairs(data.lines) do
                    line.Visible = false
                end
            else
                local char = player.Character
                if not char then
                    for _, line in pairs(data.lines) do
                        line.Visible = false
                    end
                else
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then
                        for _, line in pairs(data.lines) do
                            line.Visible = false
                        end
                    else
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then
                            for _, line in pairs(data.lines) do
                                line.Visible = false
                            end
                        else
                            local size = Vector3.new(4, 6, 2)
                            local cf = hrp.CFrame
                            
                            local corners = {
                                cf * Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
                                cf * Vector3.new(size.X/2, size.Y/2, -size.Z/2),
                                cf * Vector3.new(size.X/2, size.Y/2, size.Z/2),
                                cf * Vector3.new(-size.X/2, size.Y/2, size.Z/2),
                                cf * Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
                                cf * Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
                                cf * Vector3.new(size.X/2, -size.Y/2, size.Z/2),
                                cf * Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
                            }
                            
                            local screen = {}
                            for i, corner in ipairs(corners) do
                                local pos, visible = camera:WorldToViewportPoint(corner)
                                screen[i] = {Vector2.new(pos.X, pos.Y), visible}
                            end
                            
                            local lines = data.lines
                            
                            for _, line in pairs(lines) do
                                line.Color = Config.ESP.Box.Color
                                line.Thickness = Config.ESP.Box.Thickness
                            end
                            
                            local function draw(i, a, b)
                                if screen[a][2] and screen[b][2] then
                                    lines[i].From = screen[a][1]
                                    lines[i].To = screen[b][1]
                                    lines[i].Visible = true
                                else
                                    lines[i].Visible = false
                                end
                            end
                            
                            draw(1, 1, 2)
                            draw(2, 2, 3)
                            draw(3, 3, 4)
                            draw(4, 4, 1)
                            draw(5, 5, 6)
                            draw(6, 6, 7)
                            draw(7, 7, 8)
                            draw(8, 8, 5)
                            draw(9, 1, 5)
                            draw(10, 2, 6)
                            draw(11, 3, 7)
                            draw(12, 4, 8)
                        end
                    end
                end
            end
        end
    else
        for player, data in pairs(ESPBoxes) do
            for _, line in pairs(data.lines) do
                line.Visible = false
            end
        end
    end
    
    -- Handle Tracer ESP
    if Config.ESP.Tracer.Enabled then
        for player, line in pairs(ESPTracers) do
            if not player or player == LocalPlayer then
                if line then line.Visible = false end
            else
                local char = player.Character
                if not char then
                    if line then line.Visible = false end
                else
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then
                        if line then line.Visible = false end
                    else
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then
                            if line then line.Visible = false end
                        else
                            local pos, visible = camera:WorldToViewportPoint(hrp.Position)
                            
                            if visible then
                                line.Color = Config.ESP.Tracer.Color
                                line.Thickness = Config.ESP.Tracer.Thickness
                                line.From = Vector2.new(screenSize.X/2, screenSize.Y)
                                line.To = Vector2.new(pos.X, pos.Y)
                                line.Visible = true
                            else
                                line.Visible = false
                            end
                        end
                    end
                end
            end
        end
    else
        for player, line in pairs(ESPTracers) do
            if line then line.Visible = false end
        end
    end
end)

-- TP Walk Functions
local function startTPWalk(speed)
    tpwalking = true
    tpwalkSpeed = speed or Config.DaHood.TPWalk.Speed or 4
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    task.spawn(function()
        while tpwalking and char and hum and hum.Parent do
            local delta = RunService.Heartbeat:Wait()
            if hum.MoveDirection.Magnitude > 0 then
                pcall(function()
                    char:TranslateBy(hum.MoveDirection * tpwalkSpeed * delta * 10)
                end)
            end
            if not LocalPlayer.Character or LocalPlayer.Character ~= char then
                tpwalking = false
            end
        end
    end)
end

local function stopTPWalk()
    tpwalking = false
end

local function updateTPWalkButton(state)
    local button = TpWalkFrame:FindFirstChild("Button")
    if button then
        if state then
            button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
            button.Text = "ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
            button.Text = "OFF"
        end
    end
end

-- Noclip/Cframe Fly Functions with Speed Control
local function updateNoclipSpeed(speed)
    noclipSpeed = math.clamp(speed, 1, 50)
    Config.DaHood.NoclipFly.Speed = noclipSpeed
    savedNoclipSpeed = tostring(noclipSpeed)
    
    local speedBox = NoclipFrame:FindFirstChild("SpeedBox")
    if speedBox then
        speedBox.Text = savedNoclipSpeed
    end
end

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    local button = NoclipFrame.Button
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if noclipEnabled then
        button.Text = "ON"
        button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
        Config.DaHood.NoclipFly.Enabled = true
        
        if root then
            noclipPos = root.Position
        end
        
        if noclipEvent then noclipEvent:Disconnect() end
        
        noclipEvent = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local cam = workspace.CurrentCamera
            
            if not char or not root or not humanoid then return end
            
            local cf = cam.CFrame.Rotation
            local dir = cf:VectorToObjectSpace(humanoid.MoveDirection * noclipSpeed)
            
            local direction
            if dir.Magnitude == 0 then
                direction = Vector3.new(0,0,0)
            else
                direction = cf:VectorToWorldSpace(Vector3.new(dir.X, 0, dir.Z).Unit * dir.Magnitude)
            end
            
            noclipPos = noclipPos + direction
            root.CFrame = CFrame.new(noclipPos, cam.CFrame.Position + (noclipPos - cam.CFrame.Position) * 2)
            root.Velocity = Vector3.new(0,0,0)
            root.RotVelocity = Vector3.new(0,0,0)
        end)
    else
        button.Text = "OFF"
        button.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
        Config.DaHood.NoclipFly.Enabled = false
        
        if noclipEvent then
            noclipEvent:Disconnect()
            noclipEvent = nil
        end
    end
end

local function updateNoclipButton(state)
    local button = NoclipFrame:FindFirstChild("Button")
    if button then
        if state then
            button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
            button.Text = "ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
            button.Text = "OFF"
        end
    end
end

-- Anti-Lock Function
local function toggleAntiLock(state)
    Config.DaHood.AntiLock = state
    
    if antiLockConnection then
        antiLockConnection:Disconnect()
        antiLockConnection = nil
    end
    
    if state then
        antiLockConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            
            if not hrp or not hum or hum.Health <= 0 then return end
            
            local oldVel = hrp.Velocity
            local skyAmount = 800
            
            hrp.Velocity = Vector3.new(oldVel.X, skyAmount, oldVel.Z)
            
            RunService.RenderStepped:Wait()
            
            if hrp then
                hrp.Velocity = oldVel
            end
        end)
    end
end

-- Variables for dragging frames
local draggingTpWalk = false
local tpWalkDragInput, tpWalkDragStart, tpWalkStartPos
local draggingNoclip = false
local noclipDragInput, noclipDragStart, noclipStartPos

TpWalkFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTpWalk = true
        tpWalkDragStart = input.Position
        tpWalkStartPos = TpWalkFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingTpWalk = false
            end
        end)
    end
end)

TpWalkFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        tpWalkDragInput = input
    end
end)

NoclipFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingNoclip = true
        noclipDragStart = input.Position
        noclipStartPos = NoclipFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingNoclip = false
            end
        end)
    end
end)

NoclipFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        noclipDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == tpWalkDragInput and draggingTpWalk then
        local delta = input.Position - tpWalkDragStart
        TpWalkFrame.Position = UDim2.new(tpWalkStartPos.X.Scale, tpWalkStartPos.X.Offset + delta.X, tpWalkStartPos.Y.Scale, tpWalkStartPos.Y.Offset + delta.Y)
    elseif input == noclipDragInput and draggingNoclip then
        local delta = input.Position - noclipDragStart
        NoclipFrame.Position = UDim2.new(noclipStartPos.X.Scale, noclipStartPos.X.Offset + delta.X, noclipStartPos.Y.Scale, noclipStartPos.Y.Offset + delta.Y)
    end
end)

-- TP Walk button click handler
TpWalkFrame.Button.MouseButton1Click:Connect(function()
    local speedBox = TpWalkFrame:FindFirstChild("SpeedBox")
    local speed = tonumber(speedBox.Text)
    if not speed or speed <= 0 then
        speedBox.Text = savedTPSpeed
        speed = Config.DaHood.TPWalk.Speed or 4
    end
    speed = math.clamp(speed, 1, 20)
    
    if tpwalking then
        stopTPWalk()
        tpwalking = false
        updateTPWalkButton(false)
        Config.DaHood.TPWalk.Enabled = false
        if TPWalkUIToggle then
            TPWalkUIToggle:Set(false)
        end
    else
        startTPWalk(speed)
        tpwalking = true
        tpwalkSpeed = speed
        Config.DaHood.TPWalk.Speed = speed
        Config.DaHood.TPWalk.Enabled = true
        savedTPSpeed = tostring(speed)
        updateTPWalkButton(true)
        if TPWalkUIToggle then
            TPWalkUIToggle:Set(true)
        end
    end
end)

-- Noclip button click handler
NoclipFrame.Button.MouseButton1Click:Connect(function()
    toggleNoclip()
    if NoclipUIToggle then
        NoclipUIToggle:Set(noclipEnabled)
    end
    updateNoclipButton(noclipEnabled)
end)

-- Speed box handlers
local tpSpeedBox = TpWalkFrame:FindFirstChild("SpeedBox")
if tpSpeedBox then
    tpSpeedBox.FocusLost:Connect(function()
        local speed = tonumber(tpSpeedBox.Text)
        if speed and speed > 0 then
            speed = math.clamp(speed, 1, 20)
            tpwalkSpeed = speed
            Config.DaHood.TPWalk.Speed = speed
            savedTPSpeed = tostring(speed)
            if tpwalking then
                stopTPWalk()
                startTPWalk(speed)
            end
        else
            tpSpeedBox.Text = savedTPSpeed
        end
    end)
end

local noclipSpeedBox = NoclipFrame:FindFirstChild("SpeedBox")
if noclipSpeedBox then
    noclipSpeedBox.FocusLost:Connect(function()
        local speed = tonumber(noclipSpeedBox.Text)
        if speed and speed > 0 then
            speed = math.clamp(speed, 1, 50)
            updateNoclipSpeed(speed)
        else
            noclipSpeedBox.Text = savedNoclipSpeed
        end
    end)
end

local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CurrentCamera = Workspace.CurrentCamera

-- ESP Drawing Objects
local ESPObjects = {
    Outlines = {},
    Lines = {},
    Names = {},
    Distances = {}
}

-- Function to create outline ESP - COMPLETELY EXCLUDES LOCAL PLAYER
local function createOutlineESP(character, color)
    if not character or character == LocalPlayer.Character then return {} end
    
    local existingHighlight = character:FindFirstChild("ESPOutline")
    if existingHighlight then
        existingHighlight.OutlineColor = color
        return {existingHighlight}
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPOutline"
    highlight.Adornee = character
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.Parent = character
    
    return {highlight}
end

local function updateOutlineColor(outlines, color)
    if outlines then
        for _, outline in ipairs(outlines) do
            if outline and outline:IsA("Highlight") then
                outline.OutlineColor = color
            end
        end
    end
end

local function setOutlineVisible(outlines, visible)
    if outlines then
        for _, outline in ipairs(outlines) do
            if outline and outline:IsA("Highlight") then
                outline.Enabled = visible
            end
        end
    end
end

local function destroyOutlines(outlines)
    if outlines then
        for _, outline in ipairs(outlines) do
            if outline then
                outline:Destroy()
            end
        end
    end
end

local function createLineESP(color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = color
    line.Thickness = 2
    line.Transparency = 0.7
    return line
end

local function createNameESP(color, size)
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Color = color
    nameText.Size = size
    nameText.Center = true
    nameText.Outline = true
    nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameText.Font = 2
    return nameText
end

local function createDistanceESP(color, size)
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = color
    distanceText.Size = size
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.OutlineColor = Color3.fromRGB(0, 0, 0)
    distanceText.Font = 2
    return distanceText
end

local function cleanupESPForCharacter(character)
    if ESPObjects.Outlines[character] then
        destroyOutlines(ESPObjects.Outlines[character])
        ESPObjects.Outlines[character] = nil
    end
    if ESPObjects.Lines[character] then
        ESPObjects.Lines[character]:Remove()
        ESPObjects.Lines[character] = nil
    end
    if ESPObjects.Names[character] then
        ESPObjects.Names[character]:Remove()
        ESPObjects.Names[character] = nil
    end
    if ESPObjects.Distances[character] then
        ESPObjects.Distances[character]:Remove()
        ESPObjects.Distances[character] = nil
    end
end

local function cleanupAllESP()
    for character, _ in pairs(ESPObjects.Outlines) do
        cleanupESPForCharacter(character)
    end
    ESPObjects.Outlines = {}
    ESPObjects.Lines = {}
    ESPObjects.Names = {}
    ESPObjects.Distances = {}
end

-- Update ESP for all players - Names properly disappear when players die
local function updateESP()
    if not Config.ESP.Enabled then
        cleanupAllESP()
        return
    end
    
    local camera = CurrentCamera
    local viewport = camera.ViewportSize
    local bottomCenter = Vector2.new(viewport.X / 2, viewport.Y)
    
    local activeCharacters = {}
    local deadCharacters = {}
    
    -- First pass: identify alive characters and track dead ones
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local isAlive = false
            
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local state = humanoid:GetState()
                    if state ~= Enum.HumanoidStateType.Dead then
                        local bodyEffects = character:FindFirstChild("BodyEffects")
                        local isKnocked = bodyEffects and bodyEffects:FindFirstChild("K.O") and bodyEffects["K.O"].Value == true
                        if not isKnocked then
                            isAlive = true
                            activeCharacters[character] = true
                        end
                    end
                end
            end
            
            if not isAlive and character then
                deadCharacters[character] = true
            end
        end
    end
    
    -- Clean up ESP for dead characters immediately
    for character, _ in pairs(deadCharacters) do
        cleanupESPForCharacter(character)
    end
    
    -- Clean up any ESP objects for characters that no longer exist
    for character, _ in pairs(ESPObjects.Names) do
        if not character or not character.Parent then
            cleanupESPForCharacter(character)
        end
    end
    
    -- Update ESP for alive characters only
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and activeCharacters[character] then
                local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
                if rootPart then
                    local screenPoint, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                    local headPos = character:FindFirstChild("Head") and character.Head.Position or rootPart.Position + Vector3.new(0, 2, 0)
                    local headScreen, headOnScreen = camera:WorldToViewportPoint(headPos)
                    local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
                    
                    -- Outline ESP
                    if Config.ESP.Outline.Enabled then
                        if not ESPObjects.Outlines[character] then
                            ESPObjects.Outlines[character] = createOutlineESP(character, Config.ESP.Outline.Color)
                        else
                            updateOutlineColor(ESPObjects.Outlines[character], Config.ESP.Outline.Color)
                            setOutlineVisible(ESPObjects.Outlines[character], onScreen)
                        end
                    elseif ESPObjects.Outlines[character] then
                        cleanupESPForCharacter(character)
                    end
                    
                    -- Line ESP (Tracer)
                    if Config.ESP.Line.Enabled and onScreen then
                        if not ESPObjects.Lines[character] then
                            ESPObjects.Lines[character] = createLineESP(Config.ESP.Line.Color)
                        end
                        ESPObjects.Lines[character].Color = Config.ESP.Line.Color
                        ESPObjects.Lines[character].From = bottomCenter
                        ESPObjects.Lines[character].To = Vector2.new(screenPoint.X, screenPoint.Y)
                        ESPObjects.Lines[character].Visible = true
                    elseif ESPObjects.Lines[character] then
                        ESPObjects.Lines[character].Visible = false
                    end
                    
                    -- Name ESP - ONLY shows for alive players
                    if Config.ESP.Name.Enabled and onScreen then
                        if not ESPObjects.Names[character] then
                            ESPObjects.Names[character] = createNameESP(Config.ESP.Name.Color, Config.ESP.Name.Size)
                        end
                        ESPObjects.Names[character].Color = Config.ESP.Name.Color
                        ESPObjects.Names[character].Size = Config.ESP.Name.Size
                        ESPObjects.Names[character].Text = player.DisplayName or player.Name
                        ESPObjects.Names[character].Position = Vector2.new(headScreen.X, headScreen.Y - 20)
                        ESPObjects.Names[character].Visible = true
                    elseif ESPObjects.Names[character] then
                        ESPObjects.Names[character].Visible = false
                    end
                    
                    -- Distance ESP - ONLY shows for alive players
                    if Config.ESP.Distance.Enabled and onScreen then
                        if not ESPObjects.Distances[character] then
                            ESPObjects.Distances[character] = createDistanceESP(Config.ESP.Distance.Color, Config.ESP.Distance.Size)
                        end
                        ESPObjects.Distances[character].Color = Config.ESP.Distance.Color
                        ESPObjects.Distances[character].Size = Config.ESP.Distance.Size
                        ESPObjects.Distances[character].Text = string.format("%.1fm", distance)
                        ESPObjects.Distances[character].Position = Vector2.new(headScreen.X, headScreen.Y - 5)
                        ESPObjects.Distances[character].Visible = true
                    elseif ESPObjects.Distances[character] then
                        ESPObjects.Distances[character].Visible = false
                    end
                end
            else
                if character then
                    cleanupESPForCharacter(character)
                end
            end
        end
    end
    
    -- Clean up ESP for any characters that are no longer in activeCharacters
    for character, _ in pairs(ESPObjects.Names) do
        if not activeCharacters[character] then
            cleanupESPForCharacter(character)
        end
    end
    for character, _ in pairs(ESPObjects.Lines) do
        if not activeCharacters[character] then
            cleanupESPForCharacter(character)
        end
    end
    for character, _ in pairs(ESPObjects.Distances) do
        if not activeCharacters[character] then
            cleanupESPForCharacter(character)
        end
    end
    for character, _ in pairs(ESPObjects.Outlines) do
        if not activeCharacters[character] then
            cleanupESPForCharacter(character)
        end
    end
end

-- Use settings from Config
local Aimlock = {
    Enabled = false,
    TargetPart = Config.DaHood.Aimlock.TargetPart,
    Prediction = Config.DaHood.Aimlock.Prediction,
    CurrentTarget = nil,
    IsLocked = false,
    HasSearchedForTarget = false
}

local CamlockState = false
local PredictionCamlock = Config.DaHood.Camlock.Prediction
local Smoothness = Config.DaHood.Camlock.Smoothness
local SmoothEnabled = Config.DaHood.Camlock.SmoothEnabled
local enemy = nil

local Visuals = {
    ChamsFolder = nil,
    TracerLine = nil,
    NameESP = nil,
    LastTargetCharacter = nil
}

local AutoAirState = false
local toolActivated = false
local AutoShootActive = false
local LastAutoShootCheck = 0
local AutoShootCooldown = 0.1
local TriggerBotLastActivation = 0
local TriggerBotActivationDelay = 0.1
local BlacklistedTools = Config.BlacklistedTools

local function isActuallyAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Dead then return false end
    local bodyEffects = character:FindFirstChild("BodyEffects")
    if bodyEffects then
        local ko = bodyEffects:FindFirstChild("K.O")
        if ko and ko.Value == true then return false end
    end
    return true
end

local function isValidTarget(character)
    if not character then return false end
    if not Config.DaHood.AutoDisableOnDeath then
        return true
    end
    return isActuallyAlive(character)
end

local function isLocalPlayerAlive()
    if not LocalPlayer.Character then return false end
    return isActuallyAlive(LocalPlayer.Character)
end

local function getTargetPart(character, mode)
    if not character then return nil end
    local targetPartName
    
    if mode == "camlock" then
        targetPartName = Config.DaHood.Camlock.TargetPart
    elseif mode == "aimlock" then
        targetPartName = Config.DaHood.Aimlock.TargetPart
    else
        targetPartName = Config.DaHood.Aimlock.TargetPart
    end
    
    local targetPart = character:FindFirstChild(targetPartName)
    if targetPart and targetPart:IsA("BasePart") then
        return targetPart
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        return humanoidRootPart
    end
    
    local head = character:FindFirstChild("Head")
    if head then
        return head
    end
    return nil
end

local function isVisible(targetPart)
    if not Config.DaHood.WallCheck then return true end
    local character = LocalPlayer.Character
    if not character then return false end
    local origin = CurrentCamera.CFrame.Position
    local targetPos = targetPart.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    local raycastResult = Workspace:Raycast(origin, direction * distance, raycastParams)
    return raycastResult == nil
end

function FindNearestEnemy()
    local ClosestDistance, ClosestPlayer = math.huge, nil
    local CenterPosition = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character and isValidTarget(Character) then
                local targetPart = getTargetPart(Character, "camlock")
                if targetPart then
                    local Position, IsVisibleOnViewport = CurrentCamera:WorldToViewportPoint(targetPart.Position)
                    
                    if IsVisibleOnViewport then
                        local isVisibleToCamera = true
                        if Config.DaHood.WallCheck then
                            local ray = Ray.new(CurrentCamera.CFrame.Position, (targetPart.Position - CurrentCamera.CFrame.Position).Unit * (CurrentCamera.CFrame.Position - targetPart.Position).Magnitude)
                            local part, hitPosition = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
                            isVisibleToCamera = (part == nil or part:IsDescendantOf(Character))
                        end
                        
                        if isVisibleToCamera then
                            local Distance = (CenterPosition - Vector2.new(Position.X, Position.Y)).Magnitude
                            if Distance < ClosestDistance then
                                ClosestPlayer = targetPart
                                ClosestDistance = Distance
                            end
                        end
                    end
                end
            end
        end
    end
    
    return ClosestPlayer
end

function getNearestPlayer()
    return FindNearestEnemy()
end

local FOVContainerFull = Create("Frame", {
    Name = "FOVContainerFull",
    Parent = ScreenGui,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 5
})

local FOVCircle = Create("Frame", {
    Name = "FOVCircle",
    Parent = FOVContainerFull,
    Size = UDim2.new(0, 200, 0, 200),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 10,
    Visible = false
}, {
    Create("UIStroke", {
        Thickness = 2,
        Color = Color3.fromRGB(255, 255, 255),
        LineJoinMode = Enum.LineJoinMode.Round
    }),
    Create("UICorner", {CornerRadius = UDim.new(1, 0)})
})

-- Camlock Frame
local CamlockFrame = Create("Frame", {
    Name = "CamlockFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 120, 0, 70),
    Position = UDim2.new(0.5, -60, 0.1, 0),
    BackgroundColor3 = CFG.MainColor,
    BorderSizePixel = 0,
    ZIndex = 20,
    Visible = false
}, {
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
    Create("UIStroke", {Thickness = 2, Color = CFG.StrokeColor}),
    Create("TextLabel", {
        Name = "TopLabel",
        Size = UDim2.new(1, 0, 0.3, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = CFG.TextColor,
        Text = "Camlock",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ZIndex = 21
    }),
    Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(0.8, 0, 0.5, 0),
        Position = UDim2.new(0.1, 0, 0.35, 0),
        BackgroundColor3 = Color3.fromRGB(160, 80, 80),
        TextColor3 = CFG.TextColor,
        Text = "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        ZIndex = 21
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})}),
    Create("TextLabel", {
        Name = "BottomLabel",
        Size = UDim2.new(1, 0, 0.2, 0),
        Position = UDim2.new(0, 0, 0.85, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(189, 172, 255),
        Text = ".gg/flexed",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        ZIndex = 21
    })
})

-- AutoShoot Frame
local AutoShootFrame = Create("Frame", {
    Name = "AutoShootFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 120, 0, 70),
    Position = UDim2.new(0.5, -60, 0.2, 0),
    BackgroundColor3 = CFG.MainColor,
    BorderSizePixel = 0,
    ZIndex = 20,
    Visible = false
}, {
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
    Create("UIStroke", {Thickness = 2, Color = CFG.StrokeColor}),
    Create("TextLabel", {
        Name = "TopLabel",
        Size = UDim2.new(1, 0, 0.3, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = CFG.TextColor,
        Text = "AutoShoot",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ZIndex = 21
    }),
    Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(0.8, 0, 0.5, 0),
        Position = UDim2.new(0.1, 0, 0.35, 0),
        BackgroundColor3 = Color3.fromRGB(160, 80, 80),
        TextColor3 = CFG.TextColor,
        Text = "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        ZIndex = 21
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})}),
    Create("TextLabel", {
        Name = "BottomLabel",
        Size = UDim2.new(1, 0, 0.2, 0),
        Position = UDim2.new(0, 0, 0.85, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(189, 172, 255),
        Text = ".gg/flexed",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        ZIndex = 21
    })
})

-- Aimlock Frame
local AimlockFrame = Create("Frame", {
    Name = "AimlockFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 120, 0, 70),
    Position = UDim2.new(0.5, -60, 0.3, 0),
    BackgroundColor3 = CFG.MainColor,
    BorderSizePixel = 0,
    ZIndex = 20,
    Visible = false
}, {
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
    Create("UIStroke", {Thickness = 2, Color = CFG.StrokeColor}),
    Create("TextLabel", {
        Name = "TopLabel",
        Size = UDim2.new(1, 0, 0.3, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = CFG.TextColor,
        Text = "Aimlock",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ZIndex = 21
    }),
    Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(0.8, 0, 0.5, 0),
        Position = UDim2.new(0.1, 0, 0.35, 0),
        BackgroundColor3 = Color3.fromRGB(160, 80, 80),
        TextColor3 = CFG.TextColor,
        Text = "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        ZIndex = 21
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})}),
    Create("TextLabel", {
        Name = "BottomLabel",
        Size = UDim2.new(1, 0, 0.2, 0),
        Position = UDim2.new(0, 0, 0.85, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(189, 172, 255),
        Text = ".gg/flexed",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        ZIndex = 21
    })
})

-- AutoAir Frame
local AutoAirFrame = Create("Frame", {
    Name = "AutoAirFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 120, 0, 70),
    Position = UDim2.new(0.5, -60, 0.4, 0),
    BackgroundColor3 = CFG.MainColor,
    BorderSizePixel = 0,
    ZIndex = 20,
    Visible = false
}, {
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
    Create("UIStroke", {Thickness = 2, Color = CFG.StrokeColor}),
    Create("TextLabel", {
        Name = "TopLabel",
        Size = UDim2.new(1, 0, 0.3, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = CFG.TextColor,
        Text = "Auto Air",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ZIndex = 21
    }),
    Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(0.8, 0, 0.5, 0),
        Position = UDim2.new(0.1, 0, 0.35, 0),
        BackgroundColor3 = Color3.fromRGB(160, 80, 80),
        TextColor3 = CFG.TextColor,
        Text = "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        ZIndex = 21
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})}),
    Create("TextLabel", {
        Name = "BottomLabel",
        Size = UDim2.new(1, 0, 0.2, 0),
        Position = UDim2.new(0, 0, 0.85, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(189, 172, 255),
        Text = ".gg/flexed",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        ZIndex = 21
    })
})

local function updateCamlockButton()
    local button = CamlockFrame:FindFirstChild("Button")
    if button then
        if CamlockState then
            button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
            button.Text = "ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
            button.Text = "OFF"
        end
    end
end

local function updateAutoShootButton()
    local button = AutoShootFrame:FindFirstChild("Button")
    if button then
        if Config.DaHood.AutoShoot then
            button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
            button.Text = "ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
            button.Text = "OFF"
        end
    end
end

local function updateAimlockButton()
    local button = AimlockFrame:FindFirstChild("Button")
    if button then
        if Aimlock.Enabled then
            button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
            button.Text = "ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
            button.Text = "OFF"
        end
    end
end

local function updateAutoAirButton()
    local button = AutoAirFrame:FindFirstChild("Button")
    if button then
        if Config.DaHood.AutoAir then
            button.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
            button.Text = "ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
            button.Text = "OFF"
        end
    end
end

local function toggleAimlock(state)
    if state == nil then
        Aimlock.Enabled = not Aimlock.Enabled
    else
        Aimlock.Enabled = state
    end
    
    if Aimlock.Enabled then
        Aimlock.IsLocked = false
        Aimlock.CurrentTarget = nil
        Aimlock.HasSearchedForTarget = false
        local newTarget = getNearestPlayer()
        if newTarget and isValidTarget(newTarget.Parent) then
            Aimlock.CurrentTarget = newTarget
            Aimlock.IsLocked = true
            Aimlock.HasSearchedForTarget = true
        end
        updateAimlockButton()
    else
        Aimlock.CurrentTarget = nil
        Aimlock.IsLocked = false
        Aimlock.HasSearchedForTarget = false
        updateAimlockButton()
    end
end

CamlockFrame.Button.MouseButton1Click:Connect(function()
    CamlockState = not CamlockState
    if CamlockState then
        enemy = FindNearestEnemy()
    else
        enemy = nil
    end
    updateCamlockButton()
end)

AutoShootFrame.Button.MouseButton1Click:Connect(function()
    Config.DaHood.AutoShoot = not Config.DaHood.AutoShoot
    updateAutoShootButton()
end)

AimlockFrame.Button.MouseButton1Click:Connect(function()
    toggleAimlock()
end)

AutoAirFrame.Button.MouseButton1Click:Connect(function()
    Config.DaHood.AutoAir = not Config.DaHood.AutoAir
    if not Config.DaHood.AutoAir then
        toolActivated = false
    end
    updateAutoAirButton()
end)

local draggingCamlock, draggingAutoShoot, draggingAimlock, draggingAutoAir
local dragInput, dragStart, startPos

CamlockFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingCamlock = true
        dragStart = input.Position
        startPos = CamlockFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingCamlock = false
            end
        end)
    end
end)

CamlockFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

AutoShootFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingAutoShoot = true
        dragStart = input.Position
        startPos = AutoShootFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingAutoShoot = false
            end
        end)
    end
end)

AutoShootFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

AimlockFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingAimlock = true
        dragStart = input.Position
        startPos = AimlockFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingAimlock = false
            end
        end)
    end
end)

AimlockFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

AutoAirFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingAutoAir = true
        dragStart = input.Position
        startPos = AutoAirFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingAutoAir = false
            end
        end)
    end
end)

AutoAirFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and draggingCamlock then
        local delta = input.Position - dragStart
        CamlockFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    elseif input == dragInput and draggingAutoShoot then
        local delta = input.Position - dragStart
        AutoShootFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    elseif input == dragInput and draggingAimlock then
        local delta = input.Position - dragStart
        AimlockFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    elseif input == dragInput and draggingAutoAir then
        local delta = input.Position - dragStart
        AutoAirFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function setupVisuals()
    Visuals.ChamsFolder = Instance.new("Folder")
    Visuals.ChamsFolder.Name = "AimlockChams"
    Visuals.ChamsFolder.Parent = ScreenGui
    
    Visuals.TracerLine = Drawing.new("Line")
    Visuals.TracerLine.Visible = false
    Visuals.TracerLine.Color = Color3.fromRGB(255, 255, 255)
    Visuals.TracerLine.Thickness = 1.5
    Visuals.TracerLine.Transparency = 0.8
    
    Visuals.NameESP = Drawing.new("Text")
    Visuals.NameESP.Visible = false
    Visuals.NameESP.Color = Color3.fromRGB(255, 255, 255)
    Visuals.NameESP.Size = 18
    Visuals.NameESP.Center = true
    Visuals.NameESP.Outline = true
    Visuals.NameESP.OutlineColor = Color3.fromRGB(0, 0, 0)
    Visuals.NameESP.Font = 2
end

local function hideAllVisuals()
    if Visuals.ChamsFolder then
        for _, cham in ipairs(Visuals.ChamsFolder:GetChildren()) do
            cham:Destroy()
        end
    end
    if Visuals.TracerLine then
        Visuals.TracerLine.Visible = false
    end
    if Visuals.NameESP then
        Visuals.NameESP.Visible = false
    end
    Visuals.LastTargetCharacter = nil
end

local function updateVisuals()
    if not Aimlock.Enabled or not Aimlock.IsLocked or not Aimlock.CurrentTarget then
        hideAllVisuals()
        return
    end
    
    local targetPart = Aimlock.CurrentTarget
    local character = targetPart and targetPart.Parent
    if not character then
        hideAllVisuals()
        return
    end
    
    if Config.DaHood.Visuals.ShowChams then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local cham = Instance.new("BoxHandleAdornment")
                cham.Name = "Cham_" .. part.Name
                cham.Adornee = part
                cham.AlwaysOnTop = true
                cham.ZIndex = 10
                cham.Size = part.Size
                cham.Transparency = 0.7
                cham.Color3 = Color3.fromRGB(255, 255, 255)
                cham.Parent = Visuals.ChamsFolder
            end
        end
    else
        if Visuals.ChamsFolder then
            for _, cham in ipairs(Visuals.ChamsFolder:GetChildren()) do
                cham:Destroy()
            end
        end
    end
    
    if Config.DaHood.Visuals.ShowTracer then
        local rootPart = character:FindFirstChild("HumanoidRootPart") or targetPart
        if rootPart then
            local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local viewport = CurrentCamera.ViewportSize
                Visuals.TracerLine.From = Vector2.new(viewport.X / 2, viewport.Y)
                Visuals.TracerLine.To = Vector2.new(screenPoint.X, screenPoint.Y)
                Visuals.TracerLine.Visible = true
            else
                Visuals.TracerLine.Visible = false
            end
        else
            Visuals.TracerLine.Visible = false
        end
    else
        Visuals.TracerLine.Visible = false
    end
    
    if Config.DaHood.Visuals.ShowNameESP then
        local rootPart = character:FindFirstChild("HumanoidRootPart") or targetPart
        if rootPart then
            local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                if Visuals.LastTargetCharacter ~= character then
                    local player = Players:GetPlayerFromCharacter(character)
                    Visuals.NameESP.Text = player and player.DisplayName or character.Name
                    Visuals.LastTargetCharacter = character
                end
                local head = character:FindFirstChild("Head")
                if head then
                    local headScreenPoint = CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
                    Visuals.NameESP.Position = Vector2.new(headScreenPoint.X, headScreenPoint.Y)
                else
                    Visuals.NameESP.Position = Vector2.new(screenPoint.X, screenPoint.Y - 40)
                end
                Visuals.NameESP.Visible = true
            else
                Visuals.NameESP.Visible = false
            end
        else
            Visuals.NameESP.Visible = false
        end
    else
        Visuals.NameESP.Visible = false
        Visuals.LastTargetCharacter = nil
    end
end

setupVisuals()

local function updateFOVValue(value)
    Config.DaHood.FOV = math.clamp(value, 50, 200)
    FOVCircle.Size = UDim2.new(0, Config.DaHood.FOV * 2, 0, Config.DaHood.FOV * 2)
end

local function updateFOVCircle()
    FOVCircle.Visible = Config.DaHood.SilentAim
end

local function IsPlayerAirborne(humanoid)
    if not humanoid then return false end
    local rootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local velocityY = rootPart.Velocity.Y
        local groundedStates = {
            Enum.HumanoidStateType.Landed,
            Enum.HumanoidStateType.Running,
            Enum.HumanoidStateType.Climbing,
            Enum.HumanoidStateType.Swimming
        }
        local isAirborne = math.abs(velocityY) > 2
        local isGrounded = table.find(groundedStates, humanoid:GetState()) ~= nil
        return isAirborne and not isGrounded
    end
    return false
end

local function AutoAir()
    if Config.DaHood.AutoAir and CamlockState and enemy then
        local enemyHumanoid = enemy.Parent and enemy.Parent:FindFirstChild("Humanoid")
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if enemyHumanoid and tool and isValidTarget(enemy.Parent) then
            if IsPlayerAirborne(enemyHumanoid) and not toolActivated then
                wait(0.1)
                pcall(function()
                    tool:Activate()
                end)
                toolActivated = true
            elseif not IsPlayerAirborne(enemyHumanoid) then
                toolActivated = false
            end
        end
    elseif Config.DaHood.AutoAir and Aimlock.Enabled and Aimlock.IsLocked and Aimlock.CurrentTarget then
        local targetCharacter = Aimlock.CurrentTarget.Parent
        local enemyHumanoid = targetCharacter and targetCharacter:FindFirstChild("Humanoid")
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if enemyHumanoid and tool and isValidTarget(targetCharacter) then
            if IsPlayerAirborne(enemyHumanoid) and not toolActivated then
                wait(0.1)
                pcall(function()
                    tool:Activate()
                end)
                toolActivated = true
            elseif not IsPlayerAirborne(enemyHumanoid) then
                toolActivated = false
            end
        end
    end
end

local function getNearestPointOfView()
    local nearestPart = nil
    local nearestDistance = Config.DaHood.FOV
    local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and isValidTarget(character) and isLocalPlayerAlive() then
                local targetPart = getTargetPart(character, "silent")
                if targetPart then
                    local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                        local distance = (screenPos - screenCenter).Magnitude
                        if distance <= Config.DaHood.FOV and distance < nearestDistance then
                            if isVisible(targetPart) then
                                nearestDistance = distance
                                nearestPart = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nearestPart
end

local function findAndLockTarget()
    if not Aimlock.Enabled then return false end
    if not Aimlock.HasSearchedForTarget then
        local newTarget = getNearestPlayer()
        if newTarget and isValidTarget(newTarget.Parent) then
            Aimlock.CurrentTarget = newTarget
            Aimlock.IsLocked = true
            Aimlock.HasSearchedForTarget = true
            Visuals.LastTargetCharacter = nil
            return true
        else
            Aimlock.HasSearchedForTarget = true
            return false
        end
    end
    return Aimlock.IsLocked
end

local function validateLockedTarget()
    if not Aimlock.IsLocked or not Aimlock.CurrentTarget then return false end
    if not isValidTarget(Aimlock.CurrentTarget.Parent) then
        Aimlock.CurrentTarget = nil
        Aimlock.IsLocked = false
        hideAllVisuals()
        return false
    end
    return true
end

local function updateAimlock()
    if not Aimlock.Enabled then
        Aimlock.CurrentTarget = nil
        Aimlock.IsLocked = false
        Aimlock.HasSearchedForTarget = false
        hideAllVisuals()
        return
    end
    if not isLocalPlayerAlive() then
        Aimlock.CurrentTarget = nil
        Aimlock.IsLocked = false
        Aimlock.HasSearchedForTarget = false
        hideAllVisuals()
        return
    end
    if Aimlock.IsLocked then
        if not validateLockedTarget() then
            Aimlock.CurrentTarget = nil
            Aimlock.IsLocked = false
        end
    else
        if not Aimlock.HasSearchedForTarget then
            findAndLockTarget()
        end
    end
    updateVisuals()
end

local function checkAutoShoot()
    if not Config.DaHood.AutoShoot then return end
    local character = LocalPlayer.Character
    local currentTool = character and character:FindFirstChildOfClass("Tool")
    if currentTool then
        pcall( function() currentTool:Activate() end )
    end
end

local function isHittablePlayer(part)
    local model = part:FindFirstAncestorOfClass("Model")
    if not model or model == LocalPlayer.Character then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local bodyEffects = model:FindFirstChild("BodyEffects")
    local isKnocked = bodyEffects and bodyEffects:FindFirstChild("K.O") and bodyEffects["K.O"].Value
    local isGrabbed = model:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
    if isKnocked or isGrabbed then return false end
    if model:FindFirstChildOfClass("ForceField") then return false end
    return true
end

local function triggerBotLoop()
    if not Config.DaHood.TriggerBot.Enabled then return end
    local now = tick()
    if now - TriggerBotLastActivation < TriggerBotActivationDelay then return end
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local toolName = tool.Name:lower()
    local isBlacklisted = false
    for _, blacklistedTool in ipairs(BlacklistedTools) do
        if toolName:find(blacklistedTool:lower()) then
            isBlacklisted = true
            break
        end
    end
    if isBlacklisted then return end
    
    local rayOrigin = CurrentCamera.CFrame.Position
    local rayDirection = CurrentCamera.CFrame.LookVector * 1000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if result and result.Instance and isHittablePlayer(result.Instance) then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        local hitPlayer = hitModel and Players:GetPlayerFromCharacter(hitModel)
        if hitPlayer and hitPlayer ~= LocalPlayer then
            local targetHRP = hitPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local predictedPos = targetHRP.Position + targetHRP.Velocity * Config.DaHood.TriggerBot.Prediction
                local direction = (predictedPos - rayOrigin).Unit * 1000
                local predictionResult = Workspace:Raycast(rayOrigin, direction, raycastParams)
                if predictionResult and isHittablePlayer(predictionResult.Instance) then
                    pcall( function() tool:Activate() end )
                    TriggerBotLastActivation = now
                end
            end
        end
    end
end

-- MAIN AIMING LOOPS
RunService.RenderStepped:Connect(function()
    if CamlockState then
        if enemy and isValidTarget(enemy.Parent) then
            local camera = workspace.CurrentCamera
            local enemyPart = getTargetPart(enemy.Parent, "camlock")
            if enemyPart then
                local targetCFrame = CFrame.new(camera.CFrame.p, enemyPart.Position + enemyPart.Velocity * PredictionCamlock)
                if SmoothEnabled then
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame, Smoothness)
                else
                    camera.CFrame = targetCFrame
                end
            end
        elseif enemy and Config.DaHood.AutoDisableOnDeath then
            CamlockState = false
            enemy = nil
            updateCamlockButton()
        end
    end
    
    if Aimlock.Enabled and Aimlock.IsLocked and Aimlock.CurrentTarget then
        if not isValidTarget(Aimlock.CurrentTarget.Parent) and Config.DaHood.AutoDisableOnDeath then
            Aimlock.CurrentTarget = nil
            Aimlock.IsLocked = false
            Aimlock.HasSearchedForTarget = false
            hideAllVisuals()
        end
    end
    
    if CamlockState and enemy == nil then
        enemy = FindNearestEnemy()
    end
    
    updateESP()
end)

local originalIndex
local function safeHookFunction()
    if originalIndex then return originalIndex end
    originalIndex = hookmetamethod( game, "__index", function(t, k)
        if t:IsA("Mouse") and (k == "Hit" or k == "Target") then
            if Config.DaHood.SilentAim then
                local target = getNearestPointOfView()
                if target then
                    if not Config.DaHood.AutoDisableOnDeath or isValidTarget(target.Parent) then
                        if k == "Hit" then
                            return CFrame.new(target.Position)
                        elseif k == "Target" then
                            return target
                        end
                    end
                end
            elseif Aimlock.Enabled and Aimlock.IsLocked then
                if Aimlock.CurrentTarget and not isValidTarget(Aimlock.CurrentTarget.Parent) then
                    Aimlock.CurrentTarget = nil
                    Aimlock.IsLocked = false
                    hideAllVisuals()
                end
                if Aimlock.CurrentTarget then
                    if not Config.DaHood.AutoDisableOnDeath or isValidTarget(Aimlock.CurrentTarget.Parent) then
                        if k == "Hit" then
                            return CFrame.new(Aimlock.CurrentTarget.Position)
                        elseif k == "Target" then
                            return Aimlock.CurrentTarget
                        end
                    end
                end
            end
        end
        return originalIndex(t, k)
    end)
    return originalIndex
end

safeHookFunction()

Players.PlayerRemoving:Connect(function(player)
    if Aimlock.CurrentTarget and Aimlock.CurrentTarget.Parent == player.Character then
        Aimlock.CurrentTarget = nil
        Aimlock.IsLocked = false
        Aimlock.HasSearchedForTarget = true
        hideAllVisuals()
    end
    cleanupESPForCharacter(player.Character)
end)

Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    if Aimlock.CurrentTarget and Aimlock.CurrentTarget.Parent == player.Character then
        Aimlock.CurrentTarget = nil
        Aimlock.IsLocked = false
        Aimlock.HasSearchedForTarget = false
        hideAllVisuals()
    end
    if enemy and enemy.Parent == player.Character then
        enemy = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    stopTPWalk()
    updateTPWalkButton(false)
    Config.DaHood.TPWalk.Enabled = false
    if tpSpeedBox then
        tpSpeedBox.Text = savedTPSpeed
    end
    
    if noclipEnabled then
        toggleNoclip()
    end
end)

local Legit = Library:Tab("Legit", "108835283925971")
local VisualsTab = Library:Tab("Visuals", "10455603612")
local Misc = Library:Tab("Misc", "11888734334")
local Cfg = Library:Tab("Cfg", "12403097620")

-- CAMLOCK GROUP
local CamlockGroup = Legit:Group("Camlock")

CamlockGroup:Toggle({Name = "Camlock", Tooltip = "Enable camera lock functionality", Callback = function(v)
    CamlockState = v
    Config.DaHood.Camlock.Enabled = v
    if v then
        enemy = FindNearestEnemy()
    else
        enemy = nil
    end
    CamlockFrame.Visible = v
    updateCamlockButton()
end})

CamlockGroup:Dropdown({Name = "Camlock Part", Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftHand", "RightHand", "LeftFoot", "RightFoot"}, Default = Config.DaHood.Camlock.TargetPart, Callback = function(v)
    Config.DaHood.Camlock.TargetPart = v
    if CamlockState then
        enemy = FindNearestEnemy()
    end
end})

CamlockGroup:Textbox({Name = "Camlock Prediction", Default = tostring(Config.DaHood.Camlock.Prediction), Tooltip = "Set custom prediction value", Callback = function(v)
    local num = tonumber(v)
    if num then
        Config.DaHood.Camlock.Prediction = num
        PredictionCamlock = num
    else
        Library:Notify("Invalid number entered", "warning")
    end
end})

-- SILENT AIM GROUP
local SilentAimGroup = Legit:Group("Silent Aim")

SilentAimGroup:Toggle({Name = "Silent Aim", Tooltip = "Enable silent aim functionality", Callback = function(v)
    Config.DaHood.SilentAim = v
    updateFOVCircle()
end})

SilentAimGroup:Dropdown({Name = "Silent Aim Part", Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftHand", "RightHand", "LeftFoot", "RightFoot"}, Default = Config.DaHood.SilentTargetPart, Callback = function(v)
    Config.DaHood.SilentTargetPart = v
end})

SilentAimGroup:Slider({Name = "FOV Radius", Min = 50, Max = 200, Default = Config.DaHood.FOV, Unit = "px", Callback = function(v)
    updateFOVValue(v)
end})

SilentAimGroup:Textbox({Name = "Silent Prediction", Default = tostring(Config.DaHood.SilentPrediction), Tooltip = "Set custom prediction value (0.05 - 0.25)", Callback = function(v)
    local num = tonumber(v)
    if num then
        num = math.clamp(num, 0.05, 0.25)
        Config.DaHood.SilentPrediction = num
    else
        Library:Notify("Invalid number entered", "warning")
    end
end})

-- AIMLOCK GROUP
local AimlockGroup = Legit:Group("Aimlock")

AimlockGroup:Toggle({Name = "Aimlock", Tooltip = "Lock onto one target until toggled off", Callback = function(v)
    toggleAimlock(v)
    AimlockFrame.Visible = v
end})

AimlockGroup:Dropdown({Name = "Aimlock Part", Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftHand", "RightHand", "LeftFoot", "RightFoot"}, Default = Config.DaHood.Aimlock.TargetPart, Callback = function(v)
    Config.DaHood.Aimlock.TargetPart = v
    Aimlock.TargetPart = v
    if Aimlock.Enabled and Aimlock.CurrentTarget then
        Aimlock.IsLocked = false
        Aimlock.CurrentTarget = nil
        Aimlock.HasSearchedForTarget = false
        findAndLockTarget()
    end
end})

AimlockGroup:Textbox({Name = "Aimlock Prediction", Default = tostring(Config.DaHood.Aimlock.Prediction), Tooltip = "Set custom prediction value (0.05 - 0.35)", Callback = function(v)
    local num = tonumber(v)
    if num then
        num = math.clamp(num, 0.05, 0.35)
        Config.DaHood.Aimlock.Prediction = num
    else
        Library:Notify("Invalid number entered", "warning")
    end
end})

AimlockGroup:Textbox({Name = "Smoothness", Default = tostring(Config.DaHood.Camlock.Smoothness), Tooltip = "Set custom smoothness value (0.1 - 0.9)", Callback = function(v)
    local num = tonumber(v)
    if num then
        num = math.clamp(num, 0.1, 0.9)
        Config.DaHood.Camlock.Smoothness = num
        Smoothness = num
    else
        Library:Notify("Invalid number entered", "warning")
    end
end})

AimlockGroup:Toggle({Name = "Show Chams", Tooltip = "Show chams on aimlock target", Callback = function(v)
    Config.DaHood.Visuals.ShowChams = v
    if not v then
        if Visuals.ChamsFolder then
            for _, cham in ipairs(Visuals.ChamsFolder:GetChildren()) do
                cham:Destroy()
            end
        end
    end
end})

AimlockGroup:Toggle({Name = "Show Tracer", Tooltip = "Show tracer line to aimlock target", Callback = function(v)
    Config.DaHood.Visuals.ShowTracer = v
    if not v and Visuals.TracerLine then
        Visuals.TracerLine.Visible = false
    end
end})

AimlockGroup:Toggle({Name = "Show Name ESP", Tooltip = "Show target's name above head", Callback = function(v)
    Config.DaHood.Visuals.ShowNameESP = v
    if not v then
        if Visuals.NameESP then
            Visuals.NameESP.Visible = false
        end
        Visuals.LastTargetCharacter = nil
    end
end})

-- TRIGGERBOT GROUP
local TriggerGroup = Legit:Group("TriggerBot")

TriggerGroup:Toggle({Name = "TriggerBot", Tooltip = "Automatically shoot when crosshair is on target", Callback = function(v)
    Config.DaHood.TriggerBot.Enabled = v
end})

TriggerGroup:Textbox({Name = "Prediction", Default = tostring(Config.DaHood.TriggerBot.Prediction), Tooltip = "Set custom triggerbot prediction (0.01 - 0.15)", Callback = function(v)
    local num = tonumber(v)
    if num then
        num = math.clamp(num, 0.01, 0.15)
        Config.DaHood.TriggerBot.Prediction = num
    else
        Library:Notify("Invalid number entered", "warning")
    end
end})

-- VISUALS TAB - ESP SECTION
local ESPGroup = VisualsTab:Group("ESP")

ESPGroup:Toggle({Name = "ESP Box", Tooltip = "Show 3D box around players (excludes yourself)", Callback = function(v)
    Config.ESP.Box.Enabled = v
end})

ESPGroup:ColorPicker({Name = "Box Color", Default = Config.ESP.Box.Color, Callback = function(v)
    Config.ESP.Box.Color = v
    for player, data in pairs(ESPBoxes) do
        for _, line in pairs(data.lines) do
            line.Color = v
        end
    end
end})

ESPGroup:Toggle({Name = "ESP Line", Tooltip = "Draw line from bottom center to player (excludes yourself)", Callback = function(v)
    Config.ESP.Line.Enabled = v
    if not v then
        for player, line in pairs(ESPObjects.Lines) do
            if line then line.Visible = false end
        end
    end
end})

ESPGroup:ColorPicker({Name = "Line Color", Default = Config.ESP.Line.Color, Callback = function(v)
    Config.ESP.Line.Color = v
    for character, line in pairs(ESPObjects.Lines) do
        if line then line.Color = v end
    end
end})

ESPGroup:Toggle({Name = "ESP Outline", Tooltip = "Show wireframe outline around players (no fill, excludes yourself)", Callback = function(v)
    Config.ESP.Outline.Enabled = v
    if not v then
        for character, outlines in pairs(ESPObjects.Outlines) do
            destroyOutlines(outlines)
            ESPObjects.Outlines[character] = nil
        end
    end
end})

ESPGroup:ColorPicker({Name = "Outline Color", Default = Config.ESP.Outline.Color, Callback = function(v)
    Config.ESP.Outline.Color = v
    for character, outlines in pairs(ESPObjects.Outlines) do
        updateOutlineColor(outlines, v)
    end
end})

ESPGroup:Toggle({Name = "ESP Name", Tooltip = "Show player names above heads (excludes yourself)", Callback = function(v)
    Config.ESP.Name.Enabled = v
    if not v then
        for character, nameText in pairs(ESPObjects.Names) do
            if nameText then nameText.Visible = false end
        end
    end
end})

ESPGroup:ColorPicker({Name = "Name Color", Default = Config.ESP.Name.Color, Callback = function(v)
    Config.ESP.Name.Color = v
    for character, nameText in pairs(ESPObjects.Names) do
        if nameText then nameText.Color = v end
    end
end})

ESPGroup:Toggle({Name = "ESP Distance", Tooltip = "Show distance to player (excludes yourself)", Callback = function(v)
    Config.ESP.Distance.Enabled = v
    if not v then
        for character, distText in pairs(ESPObjects.Distances) do
            if distText then distText.Visible = false end
        end
    end
end})

ESPGroup:ColorPicker({Name = "Distance Color", Default = Config.ESP.Distance.Color, Callback = function(v)
    Config.ESP.Distance.Color = v
    for character, distText in pairs(ESPObjects.Distances) do
        if distText then distText.Color = v end
    end
end})

-- MISC TAB - FEATURES GROUP 1
local MiscGroup = Misc:Group("Misc Features")

MiscGroup:Toggle({Name = "Auto Air", Tooltip = "Auto shoot when target is in the air", Callback = function(v)
    Config.DaHood.AutoAir = v
    AutoAirFrame.Visible = v
    if not v then
        toolActivated = false
    end
    updateAutoAirButton()
end})

MiscGroup:Toggle({Name = "Auto Shoot", Tooltip = "Continuously activate tool when enabled", Callback = function(v)
    Config.DaHood.AutoShoot = v
    AutoShootFrame.Visible = v
    updateAutoShootButton()
end})

MiscGroup:Toggle({Name = "Wall Check", Tooltip = "Only target visible players", Callback = function(v)
    Config.DaHood.WallCheck = v
    if CamlockState then
        enemy = FindNearestEnemy()
    end
    if Aimlock.Enabled and Aimlock.CurrentTarget then
        Aimlock.IsLocked = false
        Aimlock.CurrentTarget = nil
        Aimlock.HasSearchedForTarget = false
        findAndLockTarget()
    end
end})

MiscGroup:Toggle({Name = "Dead Check", Tooltip = "When ON: Stops targeting dead players", Callback = function(v)
    Config.DaHood.AutoDisableOnDeath = v
    if v then
        if CamlockState and enemy and not isValidTarget(enemy.Parent) then
            CamlockState = false
            enemy = nil
            updateCamlockButton()
        end
        if Aimlock.Enabled and Aimlock.IsLocked and Aimlock.CurrentTarget and not isValidTarget(Aimlock.CurrentTarget.Parent) then
            Aimlock.CurrentTarget = nil
            Aimlock.IsLocked = false
            Aimlock.HasSearchedForTarget = false
            hideAllVisuals()
        end
    else
        if CamlockState then
            enemy = FindNearestEnemy()
        end
        if Aimlock.Enabled then
            Aimlock.IsLocked = false
            Aimlock.CurrentTarget = nil
            Aimlock.HasSearchedForTarget = false
            findAndLockTarget()
        end
    end
end})

-- MISC TAB - FEATURES GROUP 2
local MiscGroup2 = Misc:Group("Misc Features 2")

local TPWalkUIToggle = nil
local NoclipUIToggle = nil

MiscGroup2:Toggle({Name = "Anti-Lock", Tooltip = "Prevents you from being locked onto by enemies", Callback = function(v)
    toggleAntiLock(v)
end})

MiscGroup2:Toggle({Name = "Target NPCs", Tooltip = "Enable targeting of NPC bots", Callback = function(v)
    Config.DaHood.TargetNPCs = v
    if CamlockState then
        enemy = FindNearestEnemy()
    end
    if Aimlock.Enabled and Aimlock.CurrentTarget then
        Aimlock.IsLocked = false
        Aimlock.CurrentTarget = nil
        Aimlock.HasSearchedForTarget = false
        findAndLockTarget()
    end
end})

TPWalkUIToggle = MiscGroup2:Toggle({Name = "TP Walk", Tooltip = "Teleport walk - moves you forward faster", Callback = function(v)
    Config.DaHood.TPWalk.Enabled = v
    TpWalkFrame.Visible = v
    if v then
        local speed = Config.DaHood.TPWalk.Speed or 4
        startTPWalk(speed)
        updateTPWalkButton(true)
    else
        stopTPWalk()
        updateTPWalkButton(false)
    end
end})

NoclipUIToggle = MiscGroup2:Toggle({Name = "Cframe Fly", Tooltip = "Fly through walls with CFrame movement", Callback = function(v)
    if v ~= noclipEnabled then
        toggleNoclip()
    end
    NoclipFrame.Visible = v
    updateNoclipButton(noclipEnabled)
end})

local ConfigGroup = Cfg:Group("Configuration")

ConfigGroup:Keybind({Name = "Menu Key", Default = Config.UI.MenuKey, Callback = function(k)
    Library.MenuKey = k
    Config.UI.MenuKey = k
end})

ConfigGroup:Button({Name = "Unload", Variant = "Danger", Callback = function()
    Library.Unloaded = true
    stopTPWalk()
    if noclipEvent then noclipEvent:Disconnect() end
    if antiLockConnection then antiLockConnection:Disconnect() end
    cleanupAllESP()
    for player, data in pairs(ESPBoxes) do
        for _, line in pairs(data.lines) do
            line:Remove()
        end
    end
    for player, line in pairs(ESPTracers) do
        if line then line:Remove() end
    end
    ScreenGui:Destroy()
    if Visuals.TracerLine then Visuals.TracerLine:Remove() end
    if Visuals.NameESP then Visuals.NameESP:Remove() end
end})

updateFOVValue(Config.DaHood.FOV)
updateFOVCircle()

RunService.RenderStepped:Connect(function()
    updateAimlock()
    AutoAir()
    triggerBotLoop()
end)

RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    if currentTime - LastAutoShootCheck >= AutoShootCooldown then
        checkAutoShoot()
        LastAutoShootCheck = currentTime
    end
end)

CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if Config.DaHood.SilentAim then
        updateFOVCircle()
    end
end)

local MobileToggle = Create("ImageButton", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0.5, 0, 0, 10),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = CFG.MainColor,
    Image = "rbxassetid://137151097003056",
    AutoButtonColor = false
}, {
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
    Create("UIStroke", {Color = CFG.AccentColor, Thickness = 2})
})

local Visible = true
MobileToggle.MouseButton1Click:Connect(function()
    Visible = not Visible
    MainFrame.Visible = Visible
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Library.MenuKey then
        Visible = not Visible
        MainFrame.Visible = Visible
    end
end)

Library:Notify("Flexed Loaded Successfully", "success")
