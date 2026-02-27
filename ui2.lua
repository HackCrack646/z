--[[
    Optimizer UI Library v1.0
    Design inspirado no Optimizer da imagem
]]

local OptimizerUI = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Sistema de cores
local Colors = {
    Background = Color3.fromRGB(20, 22, 27),
    Surface = Color3.fromRGB(30, 33, 40),
    SurfaceLight = Color3.fromRGB(40, 44, 52),
    Primary = Color3.fromRGB(50, 55, 65),
    Accent = Color3.fromRGB(0, 120, 255),
    AccentDark = Color3.fromRGB(0, 90, 200),
    Success = Color3.fromRGB(40, 200, 100),
    Warning = Color3.fromRGB(255, 180, 40),
    Danger = Color3.fromRGB(255, 80, 80),
    Text = Color3.fromRGB(220, 220, 230),
    TextSecondary = Color3.fromRGB(150, 155, 165),
    Border = Color3.fromRGB(60, 65, 75),
    Category1 = Color3.fromRGB(75, 85, 105),
    Category2 = Color3.fromRGB(95, 85, 115),
    Category3 = Color3.fromRGB(85, 105, 95),
    Category4 = Color3.fromRGB(105, 85, 95)
}

-- Sistema de flags
local Flags = {}

-- Funções utilitárias
local function Create(class, props)
    local obj = Instance.new(class)
    for prop, value in pairs(props) do
        if prop == "Parent" then
            obj.Parent = value
        else
            obj[prop] = value
        end
    end
    return obj
end

local function AddShadow(parent, size, intensity)
    intensity = intensity or 0.5
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = intensity,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = -1
    })
    return shadow
end

local function MakeDraggable(frame, area)
    area = area or frame
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()
    
    area.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    area.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Função principal para criar janela
function OptimizerUI:CreateWindow(config)
    config = config or {}
    config.Title = config.Title or "Optimizer"
    config.Size = config.Size or UDim2.fromOffset(900, 600)
    config.Position = config.Position or UDim2.fromOffset(200, 100)
    config.Keybind = config.Keybind or Enum.KeyCode.RightShift
    config.Subtitle = config.Subtitle or "System Optimization Tool"
    
    -- GUI Principal
    local ScreenGui = Create("ScreenGui", {
        Name = "OptimizerUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Window
    local Main = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Size = config.Size,
        Position = config.Position,
        ClipsDescendants = true
    })
    
    -- Sombras
    AddShadow(Main, nil, 0.8)
    
    -- Bordas arredondadas
    local Corner = Create("UICorner", {
        Parent = Main,
        CornerRadius = UDim.new(0, 10)
    })
    
    -- Header
    local Header = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.fromOffset(0, 0)
    })
    
    Create("UICorner", {
        Parent = Header,
        CornerRadius = UDim.new(0, 10)
    })
    
    -- Título
    local Title = Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 0, 30),
        Position = UDim2.fromOffset(20, 10),
        Text = config.Title,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBlack,
        TextSize = 24
    })
    
    local Subtitle = Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 0, 20),
        Position = UDim2.fromOffset(20, 35),
        Text = config.Subtitle,
        TextColor3 = Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    -- Botões da janela
    local WindowControls = Create("Frame", {
        Parent = Header,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(100, 30),
        Position = UDim2.new(1, -110, 0, 15)
    })
    
    local CloseBtn = Create("TextButton", {
        Parent = WindowControls,
        BackgroundColor3 = Colors.Danger,
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(70, 0),
        Text = "×",
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        AutoButtonColor = false
    })
    
    local MinBtn = Create("TextButton", {
        Parent = WindowControls,
        BackgroundColor3 = Colors.Warning,
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(35, 0),
        Text = "−",
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        AutoButtonColor = false
    })
    
    local MaxBtn = Create("TextButton", {
        Parent = WindowControls,
        BackgroundColor3 = Colors.Success,
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(0, 0),
        Text = "□",
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        AutoButtonColor = false
    })
    
    for _, btn in pairs({CloseBtn, MinBtn, MaxBtn}) do
        Create("UICorner", {
            Parent = btn,
            CornerRadius = UDim.new(0, 6)
        })
    end
    
    -- Conteúdo principal
    local Content = Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, -80),
        Position = UDim2.fromOffset(20, 70)
    })
    
    -- Sidebar com categorias
    local Sidebar = Create("Frame", {
        Parent = Content,
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.fromOffset(0, 0)
    })
    
    Create("UICorner", {
        Parent = Sidebar,
        CornerRadius = UDim.new(0, 8)
    })
    
    local SidebarContent = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.fromOffset(5, 5),
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.Accent
    })
    
    local SidebarLayout = Create("UIListLayout", {
        Parent = SidebarContent,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Área de conteúdo principal
    local MainContent = Create("Frame", {
        Parent = Content,
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -220, 1, 0),
        Position = UDim2.fromOffset(220, 0)
    })
    
    Create("UICorner", {
        Parent = MainContent,
        CornerRadius = UDim.new(0, 8)
    })
    
    local PageContainer = Create("Frame", {
        Parent = MainContent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.fromOffset(10, 10)
    })
    
    -- Status bar
    local StatusBar = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Colors.SurfaceLight,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -30)
    })
    
    Create("UICorner", {
        Parent = StatusBar,
        CornerRadius = UDim.new(0, 10)
    })
    
    local StatusText = Create("TextLabel", {
        Parent = StatusBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        Text = "✅ System ready • 0 optimizations applied",
        TextColor3 = Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 13
    })
    
    -- Funcionalidade de arrastar
    MakeDraggable(Main, Header)
    
    -- Controles da janela
    local windowState = "normal" -- normal, minimized, maximized
    local normalSize = Main.Size
    local normalPos = Main.Position
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MinBtn.MouseButton1Click:Connect(function()
        if windowState == "normal" then
            windowState = "minimized"
            normalSize = Main.Size
            normalPos = Main.Position
            Main:TweenSize(UDim2.new(0, 300, 0, 60), "Out", "Quad", 0.2, true)
            Content.Visible = false
            StatusBar.Visible = false
        elseif windowState == "minimized" then
            windowState = "normal"
            Main:TweenSize(normalSize, "Out", "Quad", 0.2, true)
            Main:TweenPosition(normalPos, "Out", "Quad", 0.2, true)
            Content.Visible = true
            StatusBar.Visible = true
        end
    end)
    
    MaxBtn.MouseButton1Click:Connect(function()
        if windowState == "normal" then
            windowState = "maximized"
            normalSize = Main.Size
            normalPos = Main.Position
            Main.Size = UDim2.fromScale(1, 1)
            Main.Position = UDim2.fromOffset(0, 0)
        else
            windowState = "normal"
            Main.Size = normalSize
            Main.Position = normalPos
        end
    end)
    
    -- Sistema de categorias/páginas
    local Categories = {}
    local CurrentPage = nil
    
    function Categories:AddCategory(name, icon)
        icon = icon or "📁"
        
        -- Botão da categoria
        local CategoryBtn = Create("TextButton", {
            Parent = SidebarContent,
            BackgroundColor3 = Colors.Primary,
            Size = UDim2.new(1, 0, 0, 40),
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #Categories + 1
        })
        
        Create("UICorner", {
            Parent = CategoryBtn,
            CornerRadius = UDim.new(0, 6)
        })
        
        -- Ícone
        local Icon = Create("TextLabel", {
            Parent = CategoryBtn,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(30, 40),
            Position = UDim2.fromOffset(5, 0),
            Text = icon,
            TextColor3 = Colors.Text,
            Font = Enum.Font.Gotham,
            TextSize = 20
        })
        
        -- Nome
        local Name = Create("TextLabel", {
            Parent = CategoryBtn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.fromOffset(40, 0),
            Text = name,
            TextColor3 = Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 15
        })
        
        -- Badge com contador
        local Badge = Create("Frame", {
            Parent = CategoryBtn,
            BackgroundColor3 = Colors.Accent,
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(1, -30, 0.5, -10),
            Visible = false
        })
        
        Create("UICorner", {
            Parent = Badge,
            CornerRadius = UDim.new(1, 0)
        })
        
        local BadgeText = Create("TextLabel", {
            Parent = Badge,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "0",
            TextColor3 = Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 12
        })
        
        -- Página da categoria
        local Page = Create("ScrollingFrame", {
            Parent = PageContainer,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0, 0),
            Visible = false,
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Colors.Accent
        })
        
        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.fromOffset(0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Header da página
        local PageHeader = Create("Frame", {
            Parent = Page,
            BackgroundColor3 = Colors.SurfaceLight,
            Size = UDim2.new(1, 0, 0, 50),
            LayoutOrder = 1
        })
        
        Create("UICorner", {
            Parent = PageHeader,
            CornerRadius = UDim.new(0, 8)
        })
        
        local PageTitle = Create("TextLabel", {
            Parent = PageHeader,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.fromOffset(10, 0),
            Text = name,
            TextColor3 = Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBlack,
            TextSize = 20
        })
        
        local PageIcon = Create("TextLabel", {
            Parent = PageHeader,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(40, 50),
            Position = UDim2.new(1, -45, 0, 0),
            Text = icon,
            TextColor3 = Colors.Text,
            Font = Enum.Font.Gotham,
            TextSize = 30
        })
        
        -- Selecionar categoria
        CategoryBtn.MouseButton1Click:Connect(function()
            if CurrentPage then
                CurrentPage.Visible = false
            end
            Page.Visible = true
            CurrentPage = Page
            
            -- Atualizar estilo dos botões
            for _, btn in pairs(SidebarContent:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Colors.Primary
                end
            end
            CategoryBtn.BackgroundColor3 = Colors.Accent
            
            -- Atualizar status
            StatusText.Text = "📁 Category: " .. name
        end)
        
        -- Se for a primeira categoria, selecionar automaticamente
        if #Categories == 0 then
            CategoryBtn.BackgroundColor3 = Colors.Accent
            Page.Visible = true
            CurrentPage = Page
        end
        
        -- Elementos da página
        local PageElements = {}
        
        function PageElements:AddSection(title)
            local Section = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Colors.SurfaceLight,
                Size = UDim2.new(1, 0, 0, 0),
                LayoutOrder = #Page:GetChildren() + 1,
                ClipsDescendants = true
            })
            
            Create("UICorner", {
                Parent = Section,
                CornerRadius = UDim.new(0, 8)
            })
            
            local SectionHeader = Create("TextLabel", {
                Parent = Section,
                BackgroundColor3 = Colors.Primary,
                Size = UDim2.new(1, 0, 0, 35),
                Position = UDim2.fromOffset(0, 0),
                Text = "   " .. title,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.GothamBold,
                TextSize = 16
            })
            
            Create("UICorner", {
                Parent = SectionHeader,
                CornerRadius = UDim.new(0, 8)
            })
            
            local SectionContent = Create("Frame", {
                Parent = Section,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, -45),
                Position = UDim2.fromOffset(10, 40)
            })
            
            local ContentLayout = Create("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 55)
            end)
            
            return SectionContent
        end
        
        function PageElements:AddToggle(parent, config)
            config = config or {}
            config.Text = config.Text or "Toggle"
            config.Desc = config.Desc or ""
            config.Default = config.Default or false
            config.Flag = config.Flag or "Toggle" .. tostring(math.random(10000, 99999))
            config.Callback = config.Callback or function() end
            
            local state = config.Default
            Flags[config.Flag] = state
            
            local Toggle = Create("Frame", {
                Parent = parent,
                BackgroundColor3 = Colors.Primary,
                Size = UDim2.new(1, 0, 0, 50),
                LayoutOrder = #parent:GetChildren() + 1
            })
            
            Create("UICorner", {
                Parent = Toggle,
                CornerRadius = UDim.new(0, 6)
            })
            
            local TextLabel = Create("TextLabel", {
                Parent = Toggle,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -70, 0, 25),
                Position = UDim2.fromOffset(10, 5),
                Text = config.Text,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 15
            })
            
            local DescLabel = Create("TextLabel", {
                Parent = Toggle,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -70, 0, 20),
                Position = UDim2.fromOffset(10, 25),
                Text = config.Desc,
                TextColor3 = Colors.TextSecondary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 12
            })
            
            local ToggleBtn = Create("TextButton", {
                Parent = Toggle,
                BackgroundColor3 = state and Colors.Success or Colors.Danger,
                Size = UDim2.fromOffset(50, 25),
                Position = UDim2.new(1, -60, 0.5, -12.5),
                Text = state and "ON" or "OFF",
                TextColor3 = Colors.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                AutoButtonColor = false
            })
            
            Create("UICorner", {
                Parent = ToggleBtn,
                CornerRadius = UDim.new(0, 4)
            })
            
            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                Flags[config.Flag] = state
                
                TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and Colors.Success or Colors.Danger
                }):Play()
                
                ToggleBtn.Text = state and "ON" or "OFF"
                config.Callback(state)
            end)
            
            return Toggle
        end
        
        function PageElements:AddButton(parent, config)
            config = config or {}
            config.Text = config.Text or "Button"
            config.Icon = config.Icon or "⚡"
            config.Callback = config.Callback or function() end
            
            local Button = Create("TextButton", {
                Parent = parent,
                BackgroundColor3 = Colors.Accent,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = #parent:GetChildren() + 1
            })
            
            Create("UICorner", {
                Parent = Button,
                CornerRadius = UDim.new(0, 6)
            })
            
            local Icon = Create("TextLabel", {
                Parent = Button,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(30, 40),
                Position = UDim2.fromOffset(5, 0),
                Text = config.Icon,
                TextColor3 = Colors.Text,
                Font = Enum.Font.Gotham,
                TextSize = 18
            })
            
            local Label = Create("TextLabel", {
                Parent = Button,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -45, 1, 0),
                Position = UDim2.fromOffset(40, 0),
                Text = config.Text,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.GothamBold,
                TextSize = 14
            })
            
            Button.MouseButton1Click:Connect(config.Callback)
            
            -- Hover effect
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Colors.AccentDark
                }):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Colors.Accent
                }):Play()
            end)
            
            return Button
        end
        
        function PageElements:AddSlider(parent, config)
            config = config or {}
            config.Text = config.Text or "Slider"
            config.Min = config.Min or 0
            config.Max = config.Max or 100
            config.Default = config.Default or 50
            config.Suffix = config.Suffix or ""
            config.Flag = config.Flag or "Slider" .. tostring(math.random(10000, 99999))
            config.Callback = config.Callback or function() end
            
            local value = math.clamp(config.Default, config.Min, config.Max)
            Flags[config.Flag] = value
            
            local Slider = Create("Frame", {
                Parent = parent,
                BackgroundColor3 = Colors.Primary,
                Size = UDim2.new(1, 0, 0, 60),
                LayoutOrder = #parent:GetChildren() + 1
            })
            
            Create("UICorner", {
                Parent = Slider,
                CornerRadius = UDim.new(0, 6)
            })
            
            local Label = Create("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -100, 0, 25),
                Position = UDim2.fromOffset(10, 5),
                Text = config.Text,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 15
            })
            
            local ValueLabel = Create("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(80, 25),
                Position = UDim2.new(1, -90, 0, 5),
                Text = tostring(value) .. config.Suffix,
                TextColor3 = Colors.Accent,
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.GothamBold,
                TextSize = 15
            })
            
            local SliderBg = Create("Frame", {
                Parent = Slider,
                BackgroundColor3 = Colors.SurfaceLight,
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.fromOffset(10, 40)
            })
            
            Create("UICorner", {
                Parent = SliderBg,
                CornerRadius = UDim.new(1, 0)
            })
            
            local SliderFill = Create("Frame", {
                Parent = SliderBg,
                BackgroundColor3 = Colors.Accent,
                Size = UDim2.new((value - config.Min) / (config.Max - config.Min), 0, 1, 0),
                Position = UDim2.fromOffset(0, 0)
            })
            
            Create("UICorner", {
                Parent = SliderFill,
                CornerRadius = UDim.new(1, 0)
            })
            
            local SliderButton = Create("TextButton", {
                Parent = SliderBg,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 2),
                Text = "",
                AutoButtonColor = false
            })
            
            local dragging = false
            
            SliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            Mouse.Move:Connect(function()
                if dragging then
                    local mouseX = Mouse.X - SliderBg.AbsolutePosition.X
                    local percent = math.clamp(mouseX / SliderBg.AbsoluteSize.X, 0, 1)
                    value = config.Min + (config.Max - config.Min) * percent
                    value = math.floor(value * 100) / 100
                    
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    ValueLabel.Text = tostring(value) .. config.Suffix
                    Flags[config.Flag] = value
                    config.Callback(value)
                end
            end)
            
            return Slider
        end
        
        function PageElements:AddDropdown(parent, config)
            config = config or {}
            config.Text = config.Text or "Dropdown"
            config.Options = config.Options or {"Option 1", "Option 2", "Option 3"}
            config.Default = config.Default or config.Options[1]
            config.Flag = config.Flag or "Dropdown" .. tostring(math.random(10000, 99999))
            config.Callback = config.Callback or function() end
            
            local expanded = false
            local selected = config.Default
            Flags[config.Flag] = selected
            
            local Dropdown = Create("Frame", {
                Parent = parent,
                BackgroundColor3 = Colors.Primary,
                Size = UDim2.new(1, 0, 0, 50),
                LayoutOrder = #parent:GetChildren() + 1,
                ClipsDescendants = true
            })
            
            Create("UICorner", {
                Parent = Dropdown,
                CornerRadius = UDim.new(0, 6)
            })
            
            local Label = Create("TextLabel", {
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -120, 0, 25),
                Position = UDim2.fromOffset(10, 5),
                Text = config.Text,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 15
            })
            
            local Selector = Create("TextButton", {
                Parent = Dropdown,
                BackgroundColor3 = Colors.SurfaceLight,
                Size = UDim2.fromOffset(100, 30),
                Position = UDim2.new(1, -110, 0.5, -15),
                Text = selected .. "  ▼",
                TextColor3 = Colors.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                AutoButtonColor = false
            })
            
            Create("UICorner", {
                Parent = Selector,
                CornerRadius = UDim.new(0, 4)
            })
            
            local DropdownList = Create("ScrollingFrame", {
                Parent = Dropdown,
                BackgroundColor3 = Colors.SurfaceLight,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 100, 0, 0),
                Position = UDim2.new(1, -110, 0, 35),
                Visible = false,
                CanvasSize = UDim2.fromOffset(0, 0),
                ScrollBarThickness = 3,
                ZIndex = 10
            })
            
            Create("UICorner", {
                Parent = DropdownList,
                CornerRadius = UDim.new(0, 4)
            })
            
            local ListLayout = Create("UIListLayout", {
                Parent = DropdownList,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })
            
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownList.CanvasSize = UDim2.fromOffset(0, ListLayout.AbsoluteContentSize.Y)
            end)
            
            for _, option in ipairs(config.Options) do
                local OptionBtn = Create("TextButton", {
                    Parent = DropdownList,
                    BackgroundColor3 = Colors.Primary,
                    Size = UDim2.new(1, -4, 0, 25),
                    Position = UDim2.fromOffset(2, 0),
                    Text = option,
                    TextColor3 = Colors.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    ZIndex = 11
                })
                
                Create("UICorner", {
                    Parent = OptionBtn,
                    CornerRadius = UDim.new(0, 4)
                })
                
                OptionBtn.MouseButton1Click:Connect(function()
                    selected = option
                    Selector.Text = option .. "  ▼"
                    Flags[config.Flag] = option
                    config.Callback(option)
                    
                    expanded = false
                    DropdownList.Visible = false
                    Dropdown.Size = UDim2.new(1, 0, 0, 50)
                end)
            end
            
            Selector.MouseButton1Click:Connect(function()
                expanded = not expanded
                DropdownList.Visible = expanded
                
                if expanded then
                    local height = math.min(#config.Options * 27, 150)
                    Dropdown.Size = UDim2.new(1, 0, 0, 50 + height)
                    DropdownList.Size = UDim2.new(0, 100, 0, height)
                else
                    Dropdown.Size = UDim2.new(1, 0, 0, 50)
                end
            end)
            
            return Dropdown
        end
        
        function PageElements:AddDivider(parent)
            local Divider = Create("Frame", {
                Parent = parent,
                BackgroundColor3 = Colors.Border,
                Size = UDim2.new(1, 0, 0, 1),
                LayoutOrder = #parent:GetChildren() + 1
            })
            
            return Divider
        end
        
        function PageElements:AddLabel(parent, config)
            config = config or {}
            config.Text = config.Text or "Label"
            config.Size = config.Size or 30
            
            local Label = Create("TextLabel", {
                Parent = parent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, config.Size),
                Text = config.Text,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                LayoutOrder = #parent:GetChildren() + 1
            })
            
            return Label
        end
        
        table.insert(Categories, {
            Name = name,
            Page = Page,
            Elements = PageElements,
            Badge = Badge,
            BadgeText = BadgeText,
            Button = CategoryBtn
        })
        
        return PageElements
    end
    
    -- Funções públicas
    local PublicAPI = {
        AddCategory = Categories.AddCategory,
        Flags = Flags,
        SetStatus = function(text)
            StatusText.Text = text
        end,
        Destroy = function()
            ScreenGui:Destroy()
        end,
        GetTheme = function()
            return Colors
        end
    }
    
    return PublicAPI
end

return OptimizerUI
