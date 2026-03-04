--[[
    HTML2Roblox UI Library
    Tradução exata do design HTML/CSS fornecido
    Cores, tamanhos e estilos 100% fiéis ao original
]]

local UI = {}
UI.__index = UI

-- Serviços
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- CORES EXATAS DO CSS
local Colors = {
    -- Fundos (exatamente do CSS)
    Body = Color3.fromRGB(15, 15, 20),           -- #0f0f14
    Window = Color3.fromRGB(26, 26, 34),         -- #1a1a22
    Topbar = Color3.fromRGB(21, 21, 28),         -- #15151c
    Sidebar = Color3.fromRGB(22, 22, 29),        -- #16161d
    Card = Color3.fromRGB(38, 38, 51),           -- #262633
    Content = Color3.fromRGB(30, 30, 39),        -- #1e1e27
    
    -- Botões e elementos
    Button = Color3.fromRGB(42, 42, 54),          -- #2a2a36
    ButtonHover = Color3.fromRGB(53, 53, 69),     -- #353545
    MenuButton = Color3.fromRGB(34, 34, 43),      -- #22222b
    MenuButtonHover = Color3.fromRGB(45, 45, 56), -- #2d2d38
    MenuButtonActive = Color3.fromRGB(47, 47, 59),-- #2f2f3b
    ControlBtn = Color3.fromRGB(42, 42, 51),      -- #2a2a33
    
    -- Cores primárias
    Primary = Color3.fromRGB(79, 124, 255),       -- #4f7cff
    PrimaryHover = Color3.fromRGB(61, 102, 214),  -- #3d66d6
    
    -- Texto
    Text = Color3.fromRGB(255, 255, 255),         -- white
    TextSecondary = Color3.fromRGB(204, 204, 204),-- #ccc
    TextMuted = Color3.fromRGB(170, 170, 170),    -- #aaa
    TextDark = Color3.fromRGB(187, 187, 187),     -- #bbb
    
    -- Elementos
    Border = Color3.fromRGB(34, 34, 34),          -- #222
    SliderBg = Color3.fromRGB(51, 51, 51),        -- #333
    ToggleBg = Color3.fromRGB(51, 51, 51),        -- #333
    Checkbox = Color3.fromRGB(42, 42, 54),        -- #2a2a36
    Shadow = Color3.fromRGB(0, 0, 0),             -- black
}

-- Utilitário para criar instâncias
local function New(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

-- Criar sombra (box-shadow equivalente)
local function AddShadow(frame, transparency, size)
    local shadow = New("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261999",
        ImageColor3 = Colors.Shadow,
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, size or 20, 1, size or 20),
        Position = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2),
        Parent = frame
    })
    return shadow
end

-- Arredondar cantos
local function AddCorner(obj, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = obj
    })
end

-- Função para tornar arrastável
local function MakeDraggable(frame, area)
    local dragging = false
    local dragStart, frameStart
    
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

-- CLASSE WINDOW (tradução da .window do CSS)
function UI:CreateWindow(title)
    local window = {
        Title = title,
        Pages = {},
        CurrentPage = nil
    }
    setmetatable(window, self)
    
    -- ScreenGui (body do CSS)
    window.Gui = New("ScreenGui", {
        Name = "HTML2Roblox_" .. title,
        Parent = CoreGui,
        DisplayOrder = 1000,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Window principal (exatamente como no CSS: width:900px, height:550px)
    window.Main = New("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 900, 0, 550),
        Position = UDim2.new(0.5, -450, 0.5, -275),
        BackgroundColor3 = Colors.Window,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = window.Gui
    })
    AddCorner(window.Main, 14)  -- border-radius: 14px
    AddShadow(window.Main, 0.4, 20)  -- box-shadow: 0 20px 50px rgba(0,0,0,0.6)
    
    -- Topbar (exatamente como no CSS)
    window.Topbar = New("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.Topbar,
        BorderSizePixel = 0,
        Parent = window.Main
    })
    
    -- Borda inferior da topbar (border-bottom: 1px solid #222)
    New("Frame", {
        BackgroundColor3 = Colors.Border,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Parent = window.Topbar
    })
    
    -- Título (letter-spacing: 1px, font-weight: 600)
    window.TitleLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 16,
        TextTransparency = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Parent = window.Topbar
    })
    
    -- Controles (gap: 10px do CSS)
    local controls = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -100, 0, 0),
        Parent = window.Topbar
    })
    
    -- Botões de controle (exatamente como no CSS: — ⬜ ✕)
    local buttons = {"—", "⬜", "✕"}
    local buttonX = {10, 40, 70}
    
    for i, text in ipairs(buttons) do
        local btn = New("TextButton", {
            Name = "CtrlBtn_" .. i,
            BackgroundColor3 = Colors.ControlBtn,
            Text = text,
            TextColor3 = Colors.TextMuted,
            TextSize = i == 2 and 14 or 16,
            Font = Enum.Font.GothamBold,
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(0, buttonX[i], 0.5, -14),
            Parent = controls
        })
        AddCorner(btn, 6)  -- border-radius: 6px
        
        -- Hover effect (background: #e74c3c no botão X)
        btn.MouseEnter:Connect(function()
            local hoverColor = (i == 3) and Color3.fromRGB(231, 76, 60) or Colors.Primary
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = hoverColor,
                TextColor3 = Colors.Text
            }):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.ControlBtn,
                TextColor3 = Colors.TextMuted
            }):Play()
        end)
        
        -- Ações
        if i == 3 then  -- Botão fechar (✕)
            btn.MouseButton1Click:Connect(function()
                window.Gui:Destroy()
            end)
        elseif i == 1 then  -- Botão minimizar (—)
            btn.MouseButton1Click:Connect(function()
                window.Main.Visible = not window.Main.Visible
            end)
        end
    end
    
    -- Tornar arrastável pela topbar
    MakeDraggable(window.Main, window.Topbar)
    
    -- Body (flex: 1, display: flex)
    window.Body = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        Parent = window.Main
    })
    
    -- Sidebar (width: 200px, background: #16161d)
    window.Sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = Colors.Sidebar,
        BorderSizePixel = 0,
        Parent = window.Body
    })
    
    -- Container dos botões do menu (padding: 15px, gap: 8px)
    window.MenuContainer = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -30, 1, -30),
        Position = UDim2.new(0, 15, 0, 15),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Primary,
        Parent = window.Sidebar
    })
    
    local menuLayout = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),  -- gap: 8px
        Parent = window.MenuContainer
    })
    
    menuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.MenuContainer.CanvasSize = UDim2.new(0, 0, 0, menuLayout.AbsoluteContentSize.Y + 15)
    end)
    
    -- Área de conteúdo (flex: 1, padding: 25px, background: #1e1e27)
    window.Content = New("ScrollingFrame", {
        Name = "Content",
        BackgroundColor3 = Colors.Content,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 200, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Colors.Primary,
        Parent = window.Body
    })
    
    -- Padding do conteúdo (25px)
    local contentPadding = New("UIPadding", {
        PaddingTop = UDim.new(0, 25),
        PaddingLeft = UDim.new(0, 25),
        PaddingRight = UDim.new(0, 25),
        Parent = window.Content
    })
    
    window.ContentLayout = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 20),  -- gap: 20px entre cards
        Parent = window.Content
    })
    
    window.ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.Content.CanvasSize = UDim2.new(0, 0, 0, window.ContentLayout.AbsoluteContentSize.Y + 50)
    end)
    
    -- Método para criar página (menu-btn)
    function window:CreatePage(name)
        local page = {
            Name = name,
            Window = window
        }
        
        -- Botão do menu (exatamente como no CSS)
        page.Button = New("TextButton", {
            Name = "MenuBtn_" .. name,
            BackgroundColor3 = Colors.MenuButton,
            Text = "  " .. name,
            TextColor3 = Colors.TextDark,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, -10, 0, 40),
            Position = UDim2.new(0, 5, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = window.MenuContainer
        })
        AddCorner(page.Button, 8)  -- border-radius: 8px
        
        -- Indicador lateral (::before no CSS)
        page.Indicator = New("Frame", {
            BackgroundColor3 = Colors.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 0, 0),
            Position = UDim2.new(0, -15, 0.5, 0),
            Parent = page.Button
        })
        AddCorner(page.Indicator, 4)  -- border-radius: 4px
        
        -- Container da página
        page.Container = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = window.Content
        })
        
        page.Layout = New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 20),
            Parent = page.Container
        })
        
        page.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.Container.Size = UDim2.new(1, 0, 0, page.Layout.AbsoluteContentSize.Y)
        end)
        
        -- Evento de clique para ativar página
        page.Button.MouseButton1Click:Connect(function()
            if window.CurrentPage then
                window.CurrentPage.Button.BackgroundColor3 = Colors.MenuButton
                window.CurrentPage.Button.TextColor3 = Colors.TextDark
                window.CurrentPage.Container.Visible = false
                
                TweenService:Create(window.CurrentPage.Indicator, TweenInfo.new(0.3), {
                    Size = UDim2.new(0, 4, 0, 0)
                }):Play()
            end
            
            window.CurrentPage = page
            page.Button.BackgroundColor3 = Colors.MenuButtonActive  -- active state
            page.Button.TextColor3 = Colors.Text
            page.Container.Visible = true
            
            TweenService:Create(page.Indicator, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 4, 0, 32)  -- height: 80% do botão (40px * 0.8 = 32px)
            }):Play()
        end)
        
        -- Hover effect (::hover no CSS)
        page.Button.MouseEnter:Connect(function()
            if window.CurrentPage ~= page then
                TweenService:Create(page.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Colors.MenuButtonHover
                }):Play()
                
                TweenService:Create(page.Indicator, TweenInfo.new(0.3), {
                    Size = UDim2.new(0, 4, 0, 28)  -- height: 70% do botão
                }):Play()
            end
        end)
        
        page.Button.MouseLeave:Connect(function()
            if window.CurrentPage ~= page then
                TweenService:Create(page.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Colors.MenuButton
                }):Play()
                
                TweenService:Create(page.Indicator, TweenInfo.new(0.3), {
                    Size = UDim2.new(0, 4, 0, 0)
                }):Play()
            end
        end)
        
        -- Primeira página ativa
        if #window.Pages == 0 then
            window.CurrentPage = page
            page.Button.BackgroundColor3 = Colors.MenuButtonActive
            page.Button.TextColor3 = Colors.Text
            page.Container.Visible = true
            page.Indicator.Size = UDim2.new(0, 4, 0, 32)
        end
        
        -- Método para criar card
        function page:CreateCard(title)
            return UI:CreateCard(self, title)
        end
        
        table.insert(window.Pages, page)
        return page
    end
    
    return window
end

-- CLASSE CARD (tradução da .card do CSS)
function UI:CreateCard(page, title)
    local card = {
        Title = title,
        Page = page
    }
    
    -- Card container (exatamente como no CSS)
    card.Frame = New("Frame", {
        Name = "Card_" .. title,
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = page.Container
    })
    AddCorner(card.Frame, 12)  -- border-radius: 12px
    AddShadow(card.Frame, 0.7, 10)  -- box-shadow: 0 10px 25px rgba(0,0,0,0.3)
    
    -- Padding do card (20px)
    local padding = New("UIPadding", {
        PaddingTop = UDim.new(0, 20),
        PaddingBottom = UDim.new(0, 20),
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
        Parent = card.Frame
    })
    
    -- Layout interno do card (flex-direction: column, gap: 12px)
    card.Layout = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = card.Frame
    })
    
    -- Título do card (h3)
    card.TitleLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = card.Frame
    })
    
    -- Container para elementos (para manter o gap consistente)
    card.ElementContainer = card.Frame  -- vamos usar o próprio frame
    
    -- Hover effect (transform: translateY(-4px))
    card.Frame.MouseEnter:Connect(function()
        TweenService:Create(card.Frame, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(47, 47, 61),  -- #2f2f3d
            Position = UDim2.new(0, 0, 0, -4)
        }):Play()
    end)
    
    card.Frame.MouseLeave:Connect(function()
        TweenService:Create(card.Frame, TweenInfo.new(0.3), {
            BackgroundColor3 = Colors.Card,
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    end)
    
    -- MÉTODOS DOS ELEMENTOS (tradução exata do HTML)
    
    -- Texto simples (p do CSS)
    function card:Text(text)
        return New("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Colors.TextMuted,  -- color: #aaa
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = self.ElementContainer
        })
    end
    
    -- Botão Normal (.btn do CSS)
    function card:Button(text, callback)
        local btn = New("TextButton", {
            BackgroundColor3 = Colors.Button,  -- background: #2a2a36
            Text = text,
            TextColor3 = Colors.TextSecondary,  -- color: #ccc
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, 0, 0, 35),  -- padding: 10px 16px
            Parent = self.ElementContainer
        })
        AddCorner(btn, 8)  -- border-radius: 8px
        
        -- Hover effect (.btn:hover)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.ButtonHover,  -- background: #353545
                TextColor3 = Colors.Text  -- color: white
            }):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.Button,
                TextColor3 = Colors.TextSecondary
            }):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            pcall(callback or function() end)
        end)
        
        return btn
    end
    
    -- Botão Primário (.btn-primary do CSS)
    function card:PrimaryButton(text, callback)
        local btn = New("TextButton", {
            BackgroundColor3 = Colors.Primary,  -- background: #4f7cff
            Text = text,
            TextColor3 = Colors.Text,  -- color: white
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, 0, 0, 35),
            Parent = self.ElementContainer
        })
        AddCorner(btn, 8)
        
        -- Hover effect (.btn-primary:hover)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.PrimaryHover  -- background: #3d66d6
            }):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.Primary
            }):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            pcall(callback or function() end)
        end)
        
        return btn
    end
    
    -- Toggle (tradução exata do HTML)
    function card:Toggle(text, default, callback)
        local value = default or false
        
        local frame = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Parent = self.ElementContainer
        })
        
        -- Label do toggle
        local label = New("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Size = UDim2.new(1, -60, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        -- Toggle switch (exatamente como no CSS)
        local toggleBg = New("Frame", {
            BackgroundColor3 = Colors.ToggleBg,  -- background: #333
            Size = UDim2.new(0, 50, 0, 25),  -- width:50px, height:25px
            Position = UDim2.new(1, -50, 0.5, -12.5),
            Parent = frame
        })
        AddCorner(toggleBg, 30)  -- border-radius: 30px
        
        -- O círculo do toggle (::before)
        local toggleCircle = New("Frame", {
            BackgroundColor3 = Colors.Text,  -- background: white
            Size = UDim2.new(0, 21, 0, 21),  -- width:21px, height:21px
            Position = value and UDim2.new(1, -24, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5),  -- left:2px / right:2px
            Parent = toggleBg
        })
        AddCorner(toggleCircle, 30)  -- border-radius: 50%
        
        -- Hitbox para clique
        local hitbox = New("TextButton", {
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 1, 0),
            Parent = frame
        })
        
        -- Função para atualizar estado
        local function setState(newValue)
            value = newValue
            toggleBg.BackgroundColor3 = value and Colors.Primary or Colors.ToggleBg  -- checked: #4f7cff
            toggleCircle.Position = value and UDim2.new(1, -24, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)  -- translateX(25px)
            
            pcall(callback, value)
        end
        
        hitbox.MouseButton1Click:Connect(function()
            setState(not value)
        end)
        
        return {
            Get = function() return value end,
            Set = setState
        }
    end
    
    -- Checkbox (tradução exata do HTML)
    function card:Checkbox(text, default, callback)
        local value = default or false
        
        local frame = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
            Parent = self.ElementContainer
        })
        
        -- Checkbox (input do CSS)
        local checkbox = New("TextButton", {
            BackgroundColor3 = Colors.Checkbox,  -- background: #2a2a36
            Size = UDim2.new(0, 16, 0, 16),  -- width:16px, height:16px
            Position = UDim2.new(0, 0, 0.5, -8),
            Text = value and "✓" or "",
            TextColor3 = Colors.Text,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            Parent = frame
        })
        AddCorner(checkbox, 4)  -- border-radius: 4px (padrão)
        
        -- Label do checkbox
        local label = New("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Position = UDim2.new(0, 25, 0, 0),  -- gap: 10px
            Size = UDim2.new(1, -25, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local function setState(newValue)
            value = newValue
            checkbox.Text = value and "✓" or ""
            pcall(callback, value)
        end
        
        checkbox.MouseButton1Click:Connect(function()
            setState(not value)
        end)
        
        return {
            Get = function() return value end,
            Set = setState
        }
    end
    
    -- Slider (range input do CSS)
    function card:Slider(text, min, max, default, callback)
        local value = default or min
        local dragging = false
        
        local frame = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 45),
            Parent = self.ElementContainer
        })
        
        -- Label do slider
        local label = New("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text .. ": " .. value,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        -- Barra do slider (range input background)
        local sliderBg = New("Frame", {
            BackgroundColor3 = Colors.Button,  -- #2a2a36
            Size = UDim2.new(1, 0, 0, 5),
            Position = UDim2.new(0, 0, 1, -10),
            Parent = frame
        })
        AddCorner(sliderBg, 3)
        
        -- Preenchimento do slider (accent-color)
        local sliderFill = New("Frame", {
            BackgroundColor3 = Colors.Primary,  -- #4f7cff
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            Parent = sliderBg
        })
        AddCorner(sliderFill, 3)
        
        -- Botão invisível para detectar arrasto
        local dragButton = New("TextButton", {
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 2, 0),
            Position = UDim2.new(0, 0, -0.5, 0),
            Parent = sliderBg
        })
        
        local function updateValue(input)
            local pos = input.Position.X - sliderBg.AbsolutePosition.X
            local percent = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * percent
            value = math.floor(value * 10) / 10  -- arredondar
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. value
            pcall(callback, value)
        end
        
        dragButton.MouseButton1Down:Connect(function(input)
            dragging = true
            updateValue(input)
        end)
        
        dragButton.MouseButton1Up:Connect(function()
            dragging = false
        end)
        
        dragButton.MouseMoved:Connect(function(input)
            if dragging then
                updateValue(input)
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
    
    -- Input (.input do CSS)
    function card:Input(placeholder, callback)
        local input = New("TextBox", {
            BackgroundColor3 = Colors.Button,  -- background: #2a2a36
            PlaceholderText = placeholder or "Digite algo...",
            PlaceholderColor3 = Colors.TextMuted,
            Text = "",
            TextColor3 = Colors.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, 0, 0, 35),  -- padding: 10px
            ClearTextOnFocus = false,
            Parent = self.ElementContainer
        })
        AddCorner(input, 8)  -- border-radius: 8px
        
        input.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                pcall(callback, input.Text)
            end
        end)
        
        return input
    end
    
    -- Dropdown (.select do CSS)
    function card:Dropdown(text, options, default, callback)
        local selected = default or options[1]
        local open = false
        
        local frame = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 35),
            ClipsDescendants = false,
            Parent = self.ElementContainer
        })
        
        -- Label do dropdown
        local label = New("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Size = UDim2.new(0.3, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        -- Botão do dropdown (select)
        local btn = New("TextButton", {
            BackgroundColor3 = Colors.Button,  -- background: #2a2a36
            Text = selected,
            TextColor3 = Colors.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0.3, 5, 0, 0),
            Size = UDim2.new(0.7, -5, 1, 0),
            Parent = frame
        })
        AddCorner(btn, 8)  -- border-radius: 8px
        
        -- Lista dropdown
        local list = New("ScrollingFrame", {
            BackgroundColor3 = Colors.Darker,
            Visible = false,
            Size = UDim2.new(0.7, -5, 0, 120),
            Position = UDim2.new(0.3, 5, 1, 5),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Colors.Primary,
            ZIndex = 10,
            Parent = frame
        })
        AddCorner(list, 8)
        
        local listLayout = New("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = list
        })
        
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        end)
        
        -- Opções do dropdown (option)
        for _, opt in ipairs(options) do
            local optBtn = New("TextButton", {
                BackgroundColor3 = Colors.Button,
                Text = opt,
                TextColor3 = Colors.Text,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1, 0, 0, 30),
                Parent = list
            })
            
            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                btn.Text = selected
                list.Visible = false
                open = false
                pcall(callback, selected)
            end)
        end
        
        btn.MouseButton1Click:Connect(function()
            open = not open
            list.Visible = open
        end)
        
        return {
            Get = function() return selected end,
            Set = function(v) selected = v; btn.Text = v end
        }
    end
    
    -- Tabs (tradução das abas do CSS)
    function card:Tabs(tabNames, default, callback)
        local activeTab = default or tabNames[1]
        
        local frame = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            Parent = self.ElementContainer
        })
        
        -- Container das tabs (display: flex, gap: 10px)
        local tabsContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = frame
        })
        
        local tabsLayout = New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),  -- gap: 10px
            Parent = tabsContainer
        })
        
        local tabButtons = {}
        
        for i, tabName in ipairs(tabNames) do
            local tabBtn = New("TextButton", {
                BackgroundColor3 = Colors.Button,  -- background: #2a2a36
                Text = tabName,
                TextColor3 = (tabName == activeTab) and Colors.Primary or Colors.TextMuted,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(0, #tabName * 10 + 20, 1, -5),
                Position = UDim2.new(0, 0, 0, 2),
                Parent = tabsContainer
            })
            AddCorner(tabBtn, 8)  -- border-radius: 8px
            
            -- Hover effect (.tab:hover)
            tabBtn.MouseEnter:Connect(function()
                if tabName ~= activeTab then
                    TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(58, 58, 74)  -- #3a3a4a
                    }):Play()
                end
            end)
            
            tabBtn.MouseLeave:Connect(function()
                if tabName ~= activeTab then
                    TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Colors.Button
                    }):Play()
                end
            end)
            
            tabBtn.MouseButton1Click:Connect(function()
                if activeTab ~= tabName then
                    -- Desativar tab anterior
                    if tabButtons[activeTab] then
                        tabButtons[activeTab].TextColor3 = Colors.TextMuted
                    end
                    
                    -- Ativar nova tab
                    activeTab = tabName
                    tabBtn.TextColor3 = Colors.Primary  -- .tab.active
                    pcall(callback, tabName)
                end
            end)
            
            tabButtons[tabName] = tabBtn
        end
        
        return {
            Get = function() return activeTab end,
            Set = function(v) activeTab = v end
        }
    end
    
    return card
end

return UI
