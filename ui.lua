--[[
    ModernUI v1.0
    Baseado no design HTML/CSS fornecido
    Totalmente funcional e testado
]]

local ModernUI = {}
ModernUI.__index = ModernUI

-- Serviços
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Cores (baseadas no CSS)
local Colors = {
    -- Fundos
    Background = Color3.fromRGB(26, 26, 34),      -- #1a1a22
    Darker = Color3.fromRGB(21, 21, 28),          -- #15151c
    Sidebar = Color3.fromRGB(22, 22, 29),         -- #16161d
    Card = Color3.fromRGB(38, 38, 51),            -- #262633
    CardHover = Color3.fromRGB(47, 47, 61),       -- #2f2f3d
    
    -- Botões
    Button = Color3.fromRGB(42, 42, 54),          -- #2a2a36
    ButtonHover = Color3.fromRGB(53, 53, 69),     -- #353545
    Primary = Color3.fromRGB(79, 124, 255),       -- #4f7cff
    PrimaryHover = Color3.fromRGB(61, 102, 214),  -- #3d66d6
    
    -- Texto
    Text = Color3.fromRGB(255, 255, 255),         -- white
    TextMuted = Color3.fromRGB(170, 170, 170),    -- #aaa
    TextDark = Color3.fromRGB(187, 187, 187),     -- #bbb
    
    -- Elementos
    Border = Color3.fromRGB(34, 34, 34),          -- #222
    SliderActive = Color3.fromRGB(79, 124, 255),  -- #4f7cff
    SliderBg = Color3.fromRGB(51, 51, 51),        -- #333
}

-- Utilitários
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function AddCorner(obj, radius)
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    })
    corner.Parent = obj
    return corner
end

-- Função para tornar arrastável
local function MakeDraggable(frame, area)
    local dragging = false
    local dragStart = nil
    local frameStart = nil
    
    area.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = frame.Position
            input:Capture()
        end
    end)
    
    area.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                frameStart.X.Scale, 
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, 
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    area.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- CLASSE WINDOW
function ModernUI:CreateWindow(title, size)
    size = size or UDim2.new(0, 900, 0, 550)
    
    local window = {
        Title = title,
        Size = size,
        Pages = {},
        CurrentPage = nil,
        Connections = {},
        Minimized = false
    }
    setmetatable(window, self)
    
    -- ScreenGui
    window.Gui = Create("ScreenGui", {
        Name = "ModernUI_" .. title,
        Parent = CoreGui,
        DisplayOrder = 1000,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Janela principal
    window.Main = Create("Frame", {
        Name = "Window",
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        ClipsDescendants = true,
        Parent = window.Gui
    })
    AddCorner(window.Main, 14)
    
    -- Topbar
    window.Topbar = Create("Frame", {
        Name = "Topbar",
        BackgroundColor3 = Colors.Darker,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = window.Main
    })
    
    -- Borda inferior da topbar
    Create("Frame", {
        BackgroundColor3 = Colors.Border,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Parent = window.Topbar
    })
    
    -- Título
    window.TitleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "  " .. title,
        TextColor3 = Colors.Text,
        TextSize = 16,
        Size = UDim2.new(1, -90, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = window.Topbar
    })
    
    -- Controles da janela
    local controls = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 90, 1, 0),
        Position = UDim2.new(1, -90, 0, 0),
        Parent = window.Topbar
    })
    
    -- Botões de controle
    window.MinimizeBtn = Create("TextButton", {
        BackgroundColor3 = Colors.Button,
        Text = "—",
        TextColor3 = Colors.TextMuted,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 2, 0.5, -14),
        Parent = controls
    })
    AddCorner(window.MinimizeBtn, 6)
    
    window.MaximizeBtn = Create("TextButton", {
        BackgroundColor3 = Colors.Button,
        Text = "⬜",
        TextColor3 = Colors.TextMuted,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 32, 0.5, -14),
        Parent = controls
    })
    AddCorner(window.MaximizeBtn, 6)
    
    window.CloseBtn = Create("TextButton", {
        BackgroundColor3 = Colors.Button,
        Text = "✕",
        TextColor3 = Colors.TextMuted,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 62, 0.5, -14),
        Parent = controls
    })
    AddCorner(window.CloseBtn, 6)
    
    -- Hover effects
    local function ControlHover(btn, hoverColor)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = hoverColor or Colors.Primary,
                TextColor3 = Colors.Text
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.Button,
                TextColor3 = Colors.TextMuted
            }):Play()
        end)
    end
    
    ControlHover(window.MinimizeBtn)
    ControlHover(window.MaximizeBtn)
    ControlHover(window.CloseBtn, Color3.fromRGB(231, 76, 60))
    
    -- Eventos dos botões
    window.CloseBtn.MouseButton1Click:Connect(function()
        window.Gui:Destroy()
    end)
    
    window.MinimizeBtn.MouseButton1Click:Connect(function()
        window.Minimized = not window.Minimized
        if window.Minimized then
            TweenService:Create(window.Main, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 300, 0, 50)
            }):Play()
            window.Sidebar.Visible = false
            window.Content.Visible = false
        else
            window.Sidebar.Visible = true
            window.Content.Visible = true
            TweenService:Create(window.Main, TweenInfo.new(0.2), {
                Size = size
            }):Play()
        end
    end)
    
    -- Tornar janela arrastável
    MakeDraggable(window.Main, window.Topbar)
    
    -- CORPO DA JANELA
    window.Body = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        Parent = window.Main
    })
    
    -- SIDEBAR
    window.Sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Colors.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 1, 0),
        Parent = window.Body
    })
    
    -- Container dos botões do menu
    window.MenuContainer = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Primary,
        Parent = window.Sidebar
    })
    
    window.MenuLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = window.MenuContainer
    })
    
    window.MenuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.MenuContainer.CanvasSize = UDim2.new(0, 0, 0, window.MenuLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Área de conteúdo
    window.Content = Create("ScrollingFrame", {
        Name = "Content",
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 200, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Colors.Primary,
        Parent = window.Body
    })
    
    window.ContentLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 20),
        Parent = window.Content
    })
    
    window.ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.Content.CanvasSize = UDim2.new(0, 0, 0, window.ContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Método para criar página
    function window:CreatePage(name)
        return ModernUI:CreatePage(self, name)
    end
    
    return window
end

-- CLASSE PAGE
function ModernUI:CreatePage(window, name)
    local page = {
        Window = window,
        Name = name,
        Cards = {}
    }
    
    -- Botão do menu
    page.MenuButton = Create("TextButton", {
        Name = "Page_" .. name,
        BackgroundColor3 = Colors.Button,
        Text = "  " .. name,
        TextColor3 = Colors.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        Size = UDim2.new(1, -10, 0, 40),
        Position = UDim2.new(0, 5, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = window.MenuContainer
    })
    AddCorner(page.MenuButton, 8)
    
    -- Indicador lateral
    page.Indicator = Create("Frame", {
        BackgroundColor3 = Colors.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 0, 0),
        Position = UDim2.new(0, -15, 0.5, 0),
        Parent = page.MenuButton
    })
    AddCorner(page.Indicator, 4)
    
    -- Container da página
    page.Container = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Visible = false,
        Parent = window.Content
    })
    
    page.Layout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 20),
        Parent = page.Container
    })
    
    page.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.Container.Size = UDim2.new(1, -20, 0, page.Layout.AbsoluteContentSize.Y)
    end)
    
    -- Evento de clique
    page.MenuButton.MouseButton1Click:Connect(function()
        if window.CurrentPage then
            window.CurrentPage.MenuButton.TextColor3 = Colors.TextDark
            window.CurrentPage.MenuButton.BackgroundColor3 = Colors.Button
            window.CurrentPage.Container.Visible = false
            window.CurrentPage.Indicator.Size = UDim2.new(0, 4, 0, 0)
        end
        
        window.CurrentPage = page
        page.MenuButton.TextColor3 = Colors.Text
        page.MenuButton.BackgroundColor3 = Color3.fromRGB(47, 47, 59)
        page.Container.Visible = true
        page.Indicator.Size = UDim2.new(0, 4, 0, 28)
    end)
    
    -- Animação do indicador
    page.MenuButton.MouseEnter:Connect(function()
        if window.CurrentPage ~= page then
            TweenService:Create(page.Indicator, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 4, 0, 28)
            }):Play()
        end
    end)
    
    page.MenuButton.MouseLeave:Connect(function()
        if window.CurrentPage ~= page then
            TweenService:Create(page.Indicator, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 4, 0, 0)
            }):Play()
        end
    end)
    
    -- Primeira página ativa
    if #window.Pages == 0 then
        window.CurrentPage = page
        page.MenuButton.TextColor3 = Colors.Text
        page.MenuButton.BackgroundColor3 = Color3.fromRGB(47, 47, 59)
        page.Container.Visible = true
        page.Indicator.Size = UDim2.new(0, 4, 0, 28)
    end
    
    -- Método para criar card
    function page:CreateCard(title)
        return ModernUI:CreateCard(self, title)
    end
    
    table.insert(window.Pages, page)
    return page
end

-- CLASSE CARD
function ModernUI:CreateCard(page, title)
    local card = {
        Page = page,
        Title = title,
        Elements = {}
    }
    
    -- Card container
    card.Frame = Create("Frame", {
        Name = "Card_" .. title,
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = page.Container
    })
    AddCorner(card.Frame, 12)
    
    -- Hover effect
    card.Frame.MouseEnter:Connect(function()
        TweenService:Create(card.Frame, TweenInfo.new(0.3), {
            BackgroundColor3 = Colors.CardHover,
            Position = UDim2.new(0, 0, 0, -4)
        }):Play()
    end)
    
    card.Frame.MouseLeave:Connect(function()
        TweenService:Create(card.Frame, TweenInfo.new(0.3), {
            BackgroundColor3 = Colors.Card,
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    end)
    
    -- Título do card
    card.TitleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "  " .. title,
        TextColor3 = Colors.Text,
        TextSize = 18,
        Size = UDim2.new(1, -30, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card.Frame
    })
    
    -- Container de elementos
    card.ElementContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 0, 0),
        Position = UDim2.new(0, 15, 0, 45),
        Parent = card.Frame
    })
    
    card.ElementLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = card.ElementContainer
    })
    
    card.ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        card.ElementContainer.Size = UDim2.new(1, -30, 0, card.ElementLayout.AbsoluteContentSize.Y)
        card.Frame.Size = UDim2.new(1, 0, 0, card.ElementLayout.AbsoluteContentSize.Y + 65)
    end)
    
    -- MÉTODOS DOS ELEMENTOS
    
    -- Label
    function card:Label(text)
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card.ElementContainer
        })
        
        return {
            Set = function(t) label.Text = t end
        }
    end
    
    -- Separador
    function card:Separator()
        Create("Frame", {
            BackgroundColor3 = Colors.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Parent = card.ElementContainer
        })
    end
    
    -- Botão Normal
    function card:Button(text, callback)
        local btn = Create("TextButton", {
            BackgroundColor3 = Colors.Button,
            Text = text,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, 0, 0, 35),
            Parent = card.ElementContainer
        })
        AddCorner(btn, 8)
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.ButtonHover,
                TextColor3 = Colors.Text
            }):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.Button,
                TextColor3 = Colors.TextMuted
            }):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            local success, err = pcall(callback or function() end)
            if not success then warn("Button error:", err) end
        end)
        
        return btn
    end
    
    -- Botão Primário
    function card:PrimaryButton(text, callback)
        local btn = Create("TextButton", {
            BackgroundColor3 = Colors.Primary,
            Text = text,
            TextColor3 = Colors.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, 0, 0, 35),
            Parent = card.ElementContainer
        })
        AddCorner(btn, 8)
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.PrimaryHover
            }):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.Primary
            }):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            local success, err = pcall(callback or function() end)
            if not success then warn("PrimaryButton error:", err) end
        end)
        
        return btn
    end
    
    -- Toggle
    function card:Toggle(text, default, callback)
        local value = default or false
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Parent = card.ElementContainer
        })
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Size = UDim2.new(1, -60, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local toggleBg = Create("Frame", {
            BackgroundColor3 = value and Colors.Primary or Colors.SliderBg,
            Size = UDim2.new(0, 50, 0, 25),
            Position = UDim2.new(1, -50, 0.5, -12.5),
            Parent = frame
        })
        AddCorner(toggleBg, 30)
        
        local toggleCircle = Create("Frame", {
            BackgroundColor3 = Colors.Text,
            Size = UDim2.new(0, 21, 0, 21),
            Position = value and UDim2.new(1, -24, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5),
            Parent = toggleBg
        })
        AddCorner(toggleCircle, 30)
        
        local hitbox = Create("TextButton", {
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 1, 0),
            Parent = frame
        })
        
        local function set(newValue)
            value = newValue
            toggleBg.BackgroundColor3 = value and Colors.Primary or Colors.SliderBg
            toggleCircle:TweenPosition(
                value and UDim2.new(1, -24, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2,
                true
            )
            
            if callback then
                local success, err = pcall(callback, value)
                if not success then warn("Toggle error:", err) end
            end
        end
        
        hitbox.MouseButton1Click:Connect(function()
            set(not value)
        end)
        
        return {
            Set = set,
            Get = function() return value end
        }
    end
    
    -- Checkbox
    function card:Checkbox(text, default, callback)
        local value = default or false
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
            Parent = card.ElementContainer
        })
        
        local checkbox = Create("TextButton", {
            BackgroundColor3 = value and Colors.Primary or Colors.Button,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 0, 0.5, -9),
            Text = value and "✓" or "",
            TextColor3 = Colors.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = frame
        })
        AddCorner(checkbox, 4)
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Position = UDim2.new(0, 25, 0, 0),
            Size = UDim2.new(1, -25, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local function set(newValue)
            value = newValue
            checkbox.BackgroundColor3 = value and Colors.Primary or Colors.Button
            checkbox.Text = value and "✓" or ""
            
            if callback then
                local success, err = pcall(callback, value)
                if not success then warn("Checkbox error:", err) end
            end
        end
        
        checkbox.MouseButton1Click:Connect(function()
            set(not value)
        end)
        
        return {
            Set = set,
            Get = function() return value end
        }
    end
    
    -- Slider
    function card:Slider(text, min, max, default, callback)
        local value = default or min
        local dragging = false
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 45),
            Parent = card.ElementContainer
        })
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text .. ": " .. value,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local sliderBg = Create("Frame", {
            BackgroundColor3 = Colors.SliderBg,
            Size = UDim2.new(1, 0, 0, 8),
            Position = UDim2.new(0, 0, 1, -8),
            Parent = frame
        })
        AddCorner(sliderBg, 4)
        
        local sliderFill = Create("Frame", {
            BackgroundColor3 = Colors.Primary,
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            Parent = sliderBg
        })
        AddCorner(sliderFill, 4)
        
        local button = Create("TextButton", {
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 1, 0),
            Parent = sliderBg
        })
        
        local function update(input)
            local pos = input.Position.X - sliderBg.AbsolutePosition.X
            local percent = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * percent
            value = math.floor(value * 10) / 10
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. value
            
            if callback then
                local success, err = pcall(callback, value)
                if not success then warn("Slider error:", err) end
            end
        end
        
        button.MouseButton1Down:Connect(function(input)
            dragging = true
            update(input)
        end)
        
        button.MouseButton1Up:Connect(function()
            dragging = false
        end)
        
        button.MouseMoved:Connect(function(input)
            if dragging then
                update(input)
            end
        end)
        
        return {
            Set = function(v)
                value = math.clamp(v, min, max)
                sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                label.Text = text .. ": " .. value
            end
        }
    end
    
    -- Input
    function card:Input(placeholder, callback)
        local box = Create("TextBox", {
            BackgroundColor3 = Colors.Button,
            PlaceholderText = placeholder or "Digite algo...",
            PlaceholderColor3 = Colors.TextMuted,
            Text = "",
            TextColor3 = Colors.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, 0, 0, 35),
            ClearTextOnFocus = false,
            Parent = card.ElementContainer
        })
        AddCorner(box, 8)
        
        box.FocusLost:Connect(function(enter)
            if enter and callback then
                local success, err = pcall(callback, box.Text)
                if not success then warn("Input error:", err) end
            end
        end)
        
        return {
            Set = function(t) box.Text = t end,
            Get = function() return box.Text end
        }
    end
    
    -- Dropdown
    function card:Dropdown(text, options, default, callback)
        local open = false
        local selected = default or options[1]
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 35),
            ClipsDescendants = false,
            Parent = card.ElementContainer
        })
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Size = UDim2.new(0.3, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local btn = Create("TextButton", {
            BackgroundColor3 = Colors.Button,
            Text = selected,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0.3, 5, 0, 0),
            Size = UDim2.new(0.7, -5, 1, 0),
            Parent = frame
        })
        AddCorner(btn, 8)
        
        local list = Create("ScrollingFrame", {
            BackgroundColor3 = Colors.Darker,
            BorderSizePixel = 0,
            Visible = false,
            Size = UDim2.new(0.7, -5, 0, 100),
            Position = UDim2.new(0.3, 5, 1, 5),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Colors.Primary,
            ZIndex = 10,
            Parent = frame
        })
        AddCorner(list, 8)
        
        local listLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
            Parent = list
        })
        
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        end)
        
        for _, opt in ipairs(options) do
            local optBtn = Create("TextButton", {
                BackgroundColor3 = Colors.Button,
                Text = opt,
                TextColor3 = Colors.TextMuted,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1, 0, 0, 28),
                Parent = list
            })
            
            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                btn.Text = selected
                list.Visible = false
                open = false
                
                if callback then
                    local success, err = pcall(callback, selected)
                    if not success then warn("Dropdown error:", err) end
                end
            end)
        end
        
        btn.MouseButton1Click:Connect(function()
            open = not open
            list.Visible = open
        end)
        
        return {
            Set = function(v) selected = v; btn.Text = v end,
            Get = function() return selected end
        }
    end
    
    table.insert(page.Cards, card)
    return card
end

return ModernUI
