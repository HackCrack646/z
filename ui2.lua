--[[
    UI Library v1.0
    Uso: local UI = loadstring(game:HttpGet("sua_url_aqui"))()
]]

local UI = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Variáveis internas
local Library = {
    Flags = {},
    Toggles = {},
    Dragging = {},
    ColorPickers = {},
    Themes = {},
    CurrentTheme = "Dark"
}

-- Sistema de temas
Library.Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Surface = Color3.fromRGB(35, 35, 35),
        Primary = Color3.fromRGB(45, 45, 45),
        Secondary = Color3.fromRGB(55, 55, 55),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(40, 170, 40),
        Danger = Color3.fromRGB(215, 40, 40),
        Warning = Color3.fromRGB(240, 180, 40),
        Border = Color3.fromRGB(70, 70, 70)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Surface = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(230, 230, 230),
        Secondary = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(0, 100, 200),
        Text = Color3.fromRGB(30, 30, 30),
        TextSecondary = Color3.fromRGB(100, 100, 100),
        Shadow = Color3.fromRGB(150, 150, 150),
        Success = Color3.fromRGB(30, 140, 30),
        Danger = Color3.fromRGB(190, 30, 30),
        Warning = Color3.fromRGB(210, 140, 0),
        Border = Color3.fromRGB(200, 200, 200)
    }
}

-- Funções de utilidade
local function Create(class, properties)
    local obj = Instance.new(class)
    for prop, value in pairs(properties) do
        if prop == "Parent" then
            obj.Parent = value
        else
            obj[prop] = value
        end
    end
    return obj
end

local function AddShadow(parent, size, transparency)
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(5, 5),
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://6015897843",
        ImageColor3 = Library.Themes[Library.CurrentTheme].Shadow,
        ImageTransparency = transparency or 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118)
    })
    return shadow
end

local function MakeDraggable(frame, dragArea)
    dragArea = dragArea or frame
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local obj = Library.Dragging[frame]
            if not obj then
                Library.Dragging[frame] = {
                    dragging = true,
                    dragInput = nil,
                    dragStart = input.Position,
                    startPos = frame.Position
                }
            else
                obj.dragging = true
                obj.dragStart = input.Position
                obj.startPos = frame.Position
            end
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if Library.Dragging[frame] then
                        Library.Dragging[frame].dragging = false
                    end
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local obj = Library.Dragging[frame]
            if obj and obj.dragging then
                obj.dragInput = input
            end
        end
    end)
    
    RunService.Heartbeat:Connect(function()
        local obj = Library.Dragging[frame]
        if obj and obj.dragging and obj.dragInput then
            local delta = obj.dragInput.Position - obj.dragStart
            frame.Position = UDim2.new(
                obj.startPos.X.Scale,
                obj.startPos.X.Offset + delta.X,
                obj.startPos.Y.Scale,
                obj.startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Criação do GUI principal
function UI:CreateWindow(config)
    config = config or {}
    config.Title = config.Title or "UI Library"
    config.Size = config.Size or UDim2.fromOffset(600, 400)
    config.Position = config.Position or UDim2.fromOffset(200, 100)
    config.Theme = config.Theme or "Dark"
    config.Keybind = config.Keybind or Enum.KeyCode.RightShift
    
    Library.CurrentTheme = config.Theme
    local theme = Library.Themes[config.Theme]
    
    -- Container principal
    local ScreenGui = Create("ScreenGui", {
        Name = "UILibrary",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Background blur
    local Blur = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        Size = UDim2.fromScale(1, 1),
        Visible = false
    })
    
    -- Main Window
    local Main = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Size = config.Size,
        Position = config.Position,
        ClipsDescendants = true
    })
    
    -- Sombra
    AddShadow(Main, nil, 0.5)
    
    -- Borda arredondada
    local Corner = Create("UICorner", {
        Parent = Main,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Barra de título
    local TitleBar = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.fromOffset(0, 0)
    })
    
    Create("UICorner", {
        Parent = TitleBar,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Título
    local Title = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        Text = config.Title,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16
    })
    
    -- Botão fechar
    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundColor3 = theme.Danger,
        AutoButtonColor = false,
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextScaled = true
    })
    
    Create("UICorner", {
        Parent = CloseBtn,
        CornerRadius = UDim.new(0, 4)
    })
    
    -- Botão minimizar
    local MinBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundColor3 = theme.Warning,
        AutoButtonColor = false,
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        Text = "−",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextScaled = true
    })
    
    Create("UICorner", {
        Parent = MinBtn,
        CornerRadius = UDim.new(0, 4)
    })
    
    -- Conteúdo principal
    local Content = Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.fromOffset(10, 35)
    })
    
    -- Abas (esquerda)
    local TabContainer = Create("Frame", {
        Parent = Content,
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.fromOffset(0, 0)
    })
    
    Create("UICorner", {
        Parent = TabContainer,
        CornerRadius = UDim.new(0, 4)
    })
    
    local TabList = Create("ScrollingFrame", {
        Parent = TabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.fromOffset(5, 5),
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 3
    })
    
    local TabListLayout = Create("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Área de conteúdo das abas
    local TabContent = Create("Frame", {
        Parent = Content,
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.fromOffset(130, 0)
    })
    
    Create("UICorner", {
        Parent = TabContent,
        CornerRadius = UDim.new(0, 4)
    })
    
    local Pages = Create("Frame", {
        Parent = TabContent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.fromOffset(5, 5)
    })
    
    -- Funcionalidade de arrastar
    MakeDraggable(Main, TitleBar)
    
    -- Fechar/Minimizar
    local minimized = false
    local originalSize = Main.Size
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            originalSize = Main.Size
            Main:TweenSize(UDim2.new(0, 200, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            Content.Visible = false
            MinBtn.Text = "□"
        else
            Main:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            Content.Visible = true
            MinBtn.Text = "−"
        end
    end)
    
    -- Sistema de tecla para mostrar/esconder
    local visible = true
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == config.Keybind then
            visible = not visible
            Main.Visible = visible
            Blur.Visible = not visible
        end
    end)
    
    -- Sistema de abas
    local Tabs = {}
    
    function Tabs:AddTab(name)
        -- Botão da aba
        local TabButton = Create("TextButton", {
            Parent = TabList,
            BackgroundColor3 = theme.Secondary,
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 30),
            Text = "",
            LayoutOrder = #Tabs + 1
        })
        
        Create("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 4)
        })
        
        local TabLabel = Create("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = name,
            TextColor3 = theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        
        -- Página da aba
        local Page = Create("ScrollingFrame", {
            Parent = Pages,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0, 0),
            Visible = #Tabs == 0,
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Accent
        })
        
        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.fromOffset(0, PageLayout.AbsoluteContentSize.Y)
        end)
        
        -- Selecionar aba
        TabButton.MouseButton1Click:Connect(function()
            for _, child in pairs(Pages:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            Page.Visible = true
            
            -- Atualizar cores dos botões
            for _, btn in pairs(TabList:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = theme.Secondary
                end
            end
            TabButton.BackgroundColor3 = theme.Accent
        end)
        
        -- Retorna a página para adicionar elementos
        return Page
    end
    
    -- Elementos da UI
    local Elements = {}
    
    function Elements:AddButton(parent, config)
        config = config or {}
        config.Text = config.Text or "Button"
        config.Callback = config.Callback or function() end
        
        local Button = Create("TextButton", {
            Parent = parent,
            BackgroundColor3 = theme.Secondary,
            AutoButtonColor = false,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.fromOffset(5, 0),
            Text = "",
            LayoutOrder = config.Order or 1
        })
        
        Create("UICorner", {
            Parent = Button,
            CornerRadius = UDim.new(0, 4)
        })
        
        local Label = Create("TextLabel", {
            Parent = Button,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = config.Text,
            TextColor3 = theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        
        -- Hover effect
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = theme.Accent}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = theme.Secondary}):Play()
        end)
        
        Button.MouseButton1Click:Connect(config.Callback)
        
        return Button
    end
    
    function Elements:AddToggle(parent, config)
        config = config or {}
        config.Text = config.Text or "Toggle"
        config.Default = config.Default or false
        config.Flag = config.Flag or "Toggle" .. tostring(math.random(1000, 9999))
        config.Callback = config.Callback or function() end
        
        local state = config.Default
        Library.Flags[config.Flag] = state
        
        local Toggle = Create("Frame", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.fromOffset(5, 0),
            LayoutOrder = config.Order or 1
        })
        
        local Label = Create("TextLabel", {
            Parent = Toggle,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.fromOffset(0, 0),
            Text = config.Text,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        
        local ToggleBtn = Create("TextButton", {
            Parent = Toggle,
            BackgroundColor3 = state and theme.Success or theme.Danger,
            AutoButtonColor = false,
            Size = UDim2.fromOffset(40, 20),
            Position = UDim2.new(1, -45, 0.5, -10),
            Text = state and "ON" or "OFF",
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold,
            TextSize = 12
        })
        
        Create("UICorner", {
            Parent = ToggleBtn,
            CornerRadius = UDim.new(0, 4)
        })
        
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            Library.Flags[config.Flag] = state
            
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = state and theme.Success or theme.Danger
            }):Play()
            
            ToggleBtn.Text = state and "ON" or "OFF"
            config.Callback(state)
        end)
        
        return Toggle
    end
    
    function Elements:AddSlider(parent, config)
        config = config or {}
        config.Text = config.Text or "Slider"
        config.Min = config.Min or 0
        config.Max = config.Max or 100
        config.Default = config.Default or 0
        config.Suffix = config.Suffix or ""
        config.Flag = config.Flag or "Slider" .. tostring(math.random(1000, 9999))
        config.Callback = config.Callback or function() end
        
        local value = math.clamp(config.Default, config.Min, config.Max)
        Library.Flags[config.Flag] = value
        
        local Slider = Create("Frame", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 50),
            Position = UDim2.fromOffset(5, 0),
            LayoutOrder = config.Order or 1
        })
        
        local Label = Create("TextLabel", {
            Parent = Slider,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -50, 0, 20),
            Position = UDim2.fromOffset(0, 0),
            Text = config.Text,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        
        local ValueLabel = Create("TextLabel", {
            Parent = Slider,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(50, 20),
            Position = UDim2.new(1, -55, 0, 0),
            Text = tostring(value) .. config.Suffix,
            TextColor3 = theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.GothamBold,
            TextSize = 14
        })
        
        local SliderBg = Create("Frame", {
            Parent = Slider,
            BackgroundColor3 = theme.Secondary,
            Size = UDim2.new(1, -20, 0, 10),
            Position = UDim2.fromOffset(0, 30)
        })
        
        Create("UICorner", {
            Parent = SliderBg,
            CornerRadius = UDim.new(0, 4)
        })
        
        local SliderFill = Create("Frame", {
            Parent = SliderBg,
            BackgroundColor3 = theme.Accent,
            Size = UDim2.new((value - config.Min) / (config.Max - config.Min), 0, 1, 0),
            Position = UDim2.fromOffset(0, 0)
        })
        
        Create("UICorner", {
            Parent = SliderFill,
            CornerRadius = UDim.new(0, 4)
        })
        
        local SliderButton = Create("TextButton", {
            Parent = SliderBg,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
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
                value = math.floor(value * 100) / 100 -- Arredondar
                
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                ValueLabel.Text = tostring(value) .. config.Suffix
                Library.Flags[config.Flag] = value
                config.Callback(value)
            end
        end)
        
        return Slider
    end
    
    function Elements:AddDropdown(parent, config)
        config = config or {}
        config.Text = config.Text or "Dropdown"
        config.Options = config.Options or {"Option 1", "Option 2", "Option 3"}
        config.Default = config.Default or config.Options[1]
        config.Flag = config.Flag or "Dropdown" .. tostring(math.random(1000, 9999))
        config.Callback = config.Callback or function() end
        
        local expanded = false
        local selected = config.Default
        Library.Flags[config.Flag] = selected
        
        local Dropdown = Create("Frame", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.fromOffset(5, 0),
            LayoutOrder = config.Order or 1,
            ClipsDescendants = true
        })
        
        local Label = Create("TextLabel", {
            Parent = Dropdown,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -100, 1, 0),
            Position = UDim2.fromOffset(0, 0),
            Text = config.Text,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        
        local Selector = Create("TextButton", {
            Parent = Dropdown,
            BackgroundColor3 = theme.Secondary,
            AutoButtonColor = false,
            Size = UDim2.new(0, 90, 0, 25),
            Position = UDim2.new(1, -95, 0.5, -12.5),
            Text = selected,
            TextColor3 = theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 12
        })
        
        Create("UICorner", {
            Parent = Selector,
            CornerRadius = UDim.new(0, 4)
        })
        
        local DropdownList = Create("ScrollingFrame", {
            Parent = Dropdown,
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 90, 0, 0),
            Position = UDim2.new(1, -95, 0, 27),
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
        
        -- Adicionar opções
        for _, option in ipairs(config.Options) do
            local OptionBtn = Create("TextButton", {
                Parent = DropdownList,
                BackgroundColor3 = theme.Secondary,
                Size = UDim2.new(1, -4, 0, 20),
                Position = UDim2.fromOffset(2, 0),
                Text = option,
                TextColor3 = theme.Text,
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
                Selector.Text = option
                Library.Flags[config.Flag] = option
                config.Callback(option)
                
                expanded = false
                DropdownList.Visible = false
                Dropdown.Size = UDim2.new(1, -10, 0, 30)
            end)
        end
        
        Selector.MouseButton1Click:Connect(function()
            expanded = not expanded
            DropdownList.Visible = expanded
            
            if expanded then
                local height = math.min(#config.Options * 22, 100)
                Dropdown.Size = UDim2.new(1, -10, 0, 30 + height)
                DropdownList.Size = UDim2.new(0, 90, 0, height)
            else
                Dropdown.Size = UDim2.new(1, -10, 0, 30)
            end
        end)
        
        return Dropdown
    end
    
    function Elements:AddTextbox(parent, config)
        config = config or {}
        config.Text = config.Text or "Textbox"
        config.Placeholder = config.Placeholder or "Type here..."
        config.Default = config.Default or ""
        config.Flag = config.Flag or "Textbox" .. tostring(math.random(1000, 9999))
        config.Callback = config.Callback or function() end
        
        Library.Flags[config.Flag] = config.Default
        
        local Textbox = Create("Frame", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 50),
            Position = UDim2.fromOffset(5, 0),
            LayoutOrder = config.Order or 1
        })
        
        local Label = Create("TextLabel", {
            Parent = Textbox,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.fromOffset(0, 0),
            Text = config.Text,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        
        local Box = Create("TextBox", {
            Parent = Textbox,
            BackgroundColor3 = theme.Secondary,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.fromOffset(0, 25),
            PlaceholderText = config.Placeholder,
            Text = config.Default,
            TextColor3 = theme.Text,
            PlaceholderColor3 = theme.TextSecondary,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            ClearTextOnFocus = false
        })
        
        Create("UICorner", {
            Parent = Box,
            CornerRadius = UDim.new(0, 4)
        })
        
        Box.FocusLost:Connect(function()
            Library.Flags[config.Flag] = Box.Text
            config.Callback(Box.Text)
        end)
        
        return Textbox
    end
    
    function Elements:AddColorPicker(parent, config)
        config = config or {}
        config.Text = config.Text or "Color"
        config.Default = config.Default or Color3.fromRGB(255, 255, 255)
        config.Flag = config.Flag or "Color" .. tostring(math.random(1000, 9999))
        config.Callback = config.Callback or function() end
        
        local color = config.Default
        local expanded = false
        Library.Flags[config.Flag] = color
        
        local Picker = Create("Frame", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.fromOffset(5, 0),
            LayoutOrder = config.Order or 1,
            ClipsDescendants = true
        })
        
        local Label = Create("TextLabel", {
            Parent = Picker,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.fromOffset(0, 0),
            Text = config.Text,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        
        local ColorBtn = Create("TextButton", {
            Parent = Picker,
            BackgroundColor3 = color,
            AutoButtonColor = false,
            Size = UDim2.fromOffset(50, 25),
            Position = UDim2.new(1, -55, 0.5, -12.5),
            Text = ""
        })
        
        Create("UICorner", {
            Parent = ColorBtn,
            CornerRadius = UDim.new(0, 4)
        })
        
        local ColorPickerContainer = Create("Frame", {
            Parent = Picker,
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 150),
            Position = UDim2.fromOffset(0, 35),
            Visible = false,
            ZIndex = 10
        })
        
        Create("UICorner", {
            Parent = ColorPickerContainer,
            CornerRadius = UDim.new(0, 4)
        })
        
        -- Hue slider
        local HueSlider = Create("Frame", {
            Parent = ColorPickerContainer,
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.new(1, -20, 0, 15),
            Position = UDim2.fromOffset(10, 10)
        })
        
        -- Sat/Value square
        local SVSquare = Create("Frame", {
            Parent = ColorPickerContainer,
            BackgroundColor3 = Color3.new(1, 0, 0),
            Size = UDim2.new(0, 120, 0, 120),
            Position = UDim2.fromOffset(10, 35)
        })
        
        ColorBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            ColorPickerContainer.Visible = expanded
            
            if expanded then
                Picker.Size = UDim2.new(1, -10, 0, 190)
            else
                Picker.Size = UDim2.new(1, -10, 0, 30)
            end
        end)
        
        -- Implementação simplificada do color picker
        -- (Para uma implementação completa, adicionar lógica de HSV)
        
        return Picker
    end
    
    function Elements:AddLabel(parent, config)
        config = config or {}
        config.Text = config.Text or "Label"
        config.Size = config.Size or 30
        
        local Label = Create("TextLabel", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, config.Size),
            Position = UDim2.fromOffset(5, 0),
            Text = config.Text,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            LayoutOrder = config.Order or 1
        })
        
        return Label
    end
    
    function Elements:AddDivider(parent)
        local Divider = Create("Frame", {
            Parent = parent,
            BackgroundColor3 = theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 1),
            Position = UDim2.fromOffset(10, 0),
            LayoutOrder = 999
        })
        
        return Divider
    end
    
    -- Funções de utilidade pública
    UI.Flags = Library.Flags
    
    function UI:SetTheme(themeName)
        if Library.Themes[themeName] then
            Library.CurrentTheme = themeName
            -- Atualizar cores da UI (implementar se necessário)
        end
    end
    
    function UI:Destroy()
        ScreenGui:Destroy()
    end
    
    -- Retorna a interface
    return {
        AddTab = Tabs.AddTab,
        AddButton = Elements.AddButton,
        AddToggle = Elements.AddToggle,
        AddSlider = Elements.AddSlider,
        AddDropdown = Elements.AddDropdown,
        AddTextbox = Elements.AddTextbox,
        AddColorPicker = Elements.AddColorPicker,
        AddLabel = Elements.AddLabel,
        AddDivider = Elements.AddDivider,
        SetTheme = UI.SetTheme,
        Destroy = UI.Destroy,
        Flags = Library.Flags
    }
end

return UI
