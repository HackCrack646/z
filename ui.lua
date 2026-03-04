--[[
    ModernUI v1.0 - Versão Simplificada e Garantida
]]

local ModernUI = {}
ModernUI.__index = ModernUI

-- Serviços
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Cores
local Colors = {
    Background = Color3.fromRGB(26, 26, 34),
    Darker = Color3.fromRGB(21, 21, 28),
    Sidebar = Color3.fromRGB(22, 22, 29),
    Card = Color3.fromRGB(38, 38, 51),
    Button = Color3.fromRGB(42, 42, 54),
    Primary = Color3.fromRGB(79, 124, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(170, 170, 170),
}

-- Criar instância
local function New(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

-- Criar Window
function ModernUI:CreateWindow(title, size)
    size = size or UDim2.new(0, 900, 0, 550)
    
    local window = {
        Title = title,
        Size = size,
        Pages = {},
        CurrentPage = nil,
        Gui = New("ScreenGui", {
            Name = "ModernUI_" .. title,
            Parent = CoreGui,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
    }
    setmetatable(window, self)
    
    -- Main Frame
    window.Main = New("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Parent = window.Gui
    })
    
    -- Topbar
    local topbar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.Darker,
        BorderSizePixel = 0,
        Parent = window.Main
    })
    
    -- Título
    New("TextLabel", {
        BackgroundTransparency = 1,
        Text = "  " .. title,
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, -90, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar
    })
    
    -- Botão fechar
    local closeBtn = New("TextButton", {
        BackgroundColor3 = Colors.Button,
        Text = "✕",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -35, 0.5, -14),
        Parent = topbar
    })
    closeBtn.MouseButton1Click:Connect(function()
        window.Gui:Destroy()
    end)
    
    -- Sidebar
    window.Sidebar = New("Frame", {
        Size = UDim2.new(0, 200, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Colors.Sidebar,
        BorderSizePixel = 0,
        Parent = window.Main
    })
    
    -- Container dos botões da sidebar
    window.MenuContainer = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        Parent = window.Sidebar
    })
    
    local menuLayout = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        Parent = window.MenuContainer
    })
    
    menuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.MenuContainer.CanvasSize = UDim2.new(0, 0, 0, menuLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Área de conteúdo
    window.Content = New("ScrollingFrame", {
        Size = UDim2.new(1, -200, 1, -50),
        Position = UDim2.new(0, 200, 0, 50),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Colors.Primary,
        Parent = window.Main
    })
    
    local contentLayout = New("UIListLayout", {
        Padding = UDim.new(0, 20),
        Parent = window.Content
    })
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Método para criar página
    function window:CreatePage(name)
        local page = {
            Name = name,
            Window = window,
            Elements = {}
        }
        
        -- Botão da página na sidebar
        page.Button = New("TextButton", {
            Text = "  " .. name,
            BackgroundColor3 = Colors.Button,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, -10, 0, 40),
            Position = UDim2.new(0, 5, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = window.MenuContainer
        })
        
        -- Container da página
        page.Container = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Visible = false,
            Parent = window.Content
        })
        
        page.Layout = New("UIListLayout", {
            Padding = UDim.new(0, 20),
            Parent = page.Container
        })
        
        page.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.Container.Size = UDim2.new(1, -20, 0, page.Layout.AbsoluteContentSize.Y)
        end)
        
        -- Clique no botão
        page.Button.MouseButton1Click:Connect(function()
            if window.CurrentPage then
                window.CurrentPage.Button.TextColor3 = Colors.TextMuted
                window.CurrentPage.Container.Visible = false
            end
            window.CurrentPage = page
            page.Button.TextColor3 = Colors.Primary
            page.Container.Visible = true
        end)
        
        -- Método para criar card (AGORA DENTRO DA PAGE)
        function page:CreateCard(title)
            local card = {
                Title = title,
                Page = page,
                Elements = {}
            }
            
            -- Frame do card
            card.Frame = New("Frame", {
                BackgroundColor3 = Colors.Card,
                Size = UDim2.new(1, 0, 0, 0),
                Parent = page.Container
            })
            
            -- Título do card
            New("TextLabel", {
                BackgroundTransparency = 1,
                Text = "  " .. title,
                TextColor3 = Colors.Text,
                TextSize = 18,
                Font = Enum.Font.GothamBold,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 10),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card.Frame
            })
            
            -- Container dos elementos
            card.ElementContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 45),
                Parent = card.Frame
            })
            
            card.ElementLayout = New("UIListLayout", {
                Padding = UDim.new(0, 10),
                Parent = card.ElementContainer
            })
            
            card.ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                card.ElementContainer.Size = UDim2.new(1, -20, 0, card.ElementLayout.AbsoluteContentSize.Y)
                card.Frame.Size = UDim2.new(1, 0, 0, card.ElementLayout.AbsoluteContentSize.Y + 60)
            end)
            
            -- MÉTODOS DOS ELEMENTOS
            
            function card:Label(text)
                return New("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, 0, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = self.ElementContainer
                })
            end
            
            function card:Button(text, callback)
                local btn = New("TextButton", {
                    Text = text,
                    BackgroundColor3 = Colors.Button,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, 0, 0, 35),
                    Parent = self.ElementContainer
                })
                
                btn.MouseButton1Click:Connect(function()
                    pcall(callback or function() end)
                end)
                
                return btn
            end
            
            function card:PrimaryButton(text, callback)
                local btn = New("TextButton", {
                    Text = text,
                    BackgroundColor3 = Colors.Primary,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, 0, 0, 35),
                    Parent = self.ElementContainer
                })
                
                btn.MouseButton1Click:Connect(function()
                    pcall(callback or function() end)
                end)
                
                return btn
            end
            
            function card:Toggle(text, default, callback)
                local value = default or false
                
                local frame = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = self.ElementContainer
                })
                
                local label = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, -60, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                
                local toggleBg = New("Frame", {
                    BackgroundColor3 = value and Colors.Primary or Colors.Button,
                    Size = UDim2.new(0, 50, 0, 25),
                    Position = UDim2.new(1, -50, 0.5, -12.5),
                    Parent = frame
                })
                
                local toggleCircle = New("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Size = UDim2.new(0, 21, 0, 21),
                    Position = value and UDim2.new(1, -24, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5),
                    Parent = toggleBg
                })
                
                local hitbox = New("TextButton", {
                    BackgroundTransparency = 1,
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = frame
                })
                
                hitbox.MouseButton1Click:Connect(function()
                    value = not value
                    toggleBg.BackgroundColor3 = value and Colors.Primary or Colors.Button
                    toggleCircle.Position = value and UDim2.new(1, -24, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
                    pcall(callback, value)
                end)
                
                return {
                    Get = function() return value end,
                    Set = function(v) 
                        value = v
                        toggleBg.BackgroundColor3 = value and Colors.Primary or Colors.Button
                        toggleCircle.Position = value and UDim2.new(1, -24, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
                    end
                }
            end
            
            function card:Slider(text, min, max, default, callback)
                local value = default or min
                
                local frame = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 45),
                    Parent = self.ElementContainer
                })
                
                local label = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = text .. ": " .. value,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, 0, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                
                local sliderBg = New("Frame", {
                    BackgroundColor3 = Colors.Button,
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 1, -8),
                    Parent = frame
                })
                
                local sliderFill = New("Frame", {
                    BackgroundColor3 = Colors.Primary,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    Parent = sliderBg
                })
                
                local button = New("TextButton", {
                    BackgroundTransparency = 1,
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = sliderBg
                })
                
                local dragging = false
                
                button.MouseButton1Down:Connect(function(input)
                    dragging = true
                end)
                
                button.MouseButton1Up:Connect(function()
                    dragging = false
                end)
                
                button.MouseMoved:Connect(function(input)
                    if dragging then
                        local pos = input.Position.X - sliderBg.AbsolutePosition.X
                        local percent = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
                        value = min + (max - min) * percent
                        value = math.floor(value * 10) / 10
                        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                        label.Text = text .. ": " .. value
                        pcall(callback, value)
                    end
                end)
            end
            
            function card:Input(placeholder, callback)
                local box = New("TextBox", {
                    BackgroundColor3 = Colors.Button,
                    PlaceholderText = placeholder or "Digite...",
                    PlaceholderColor3 = Colors.TextMuted,
                    Text = "",
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, 0, 0, 35),
                    ClearTextOnFocus = false,
                    Parent = self.ElementContainer
                })
                
                box.FocusLost:Connect(function(enter)
                    if enter then
                        pcall(callback, box.Text)
                    end
                end)
                
                return box
            end
            
            function card:Dropdown(text, options, default, callback)
                local selected = default or options[1]
                local open = false
                
                local frame = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35),
                    ClipsDescendants = false,
                    Parent = self.ElementContainer
                })
                
                local label = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(0.3, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                
                local btn = New("TextButton", {
                    BackgroundColor3 = Colors.Button,
                    Text = selected,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Position = UDim2.new(0.3, 5, 0, 0),
                    Size = UDim2.new(0.7, -5, 1, 0),
                    Parent = frame
                })
                
                local list = New("ScrollingFrame", {
                    BackgroundColor3 = Colors.Darker,
                    Visible = false,
                    Size = UDim2.new(0.7, -5, 0, 100),
                    Position = UDim2.new(0.3, 5, 1, 5),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 4,
                    Parent = frame
                })
                
                local listLayout = New("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = list
                })
                
                listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
                end)
                
                for _, opt in ipairs(options) do
                    local optBtn = New("TextButton", {
                        Text = opt,
                        BackgroundColor3 = Colors.Button,
                        TextColor3 = Colors.Text,
                        TextSize = 14,
                        Font = Enum.Font.Gotham,
                        Size = UDim2.new(1, 0, 0, 25),
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
            end
            
            table.insert(page.Elements, card)
            return card
        end
        
        -- Primeira página fica ativa
        if #window.Pages == 0 then
            window.CurrentPage = page
            page.Button.TextColor3 = Colors.Primary
            page.Container.Visible = true
        end
        
        table.insert(window.Pages, page)
        return page
    end
    
    return window
end

return ModernUI--[[
    ModernUI v1.0 - Versão Simplificada e Garantida
]]

local ModernUI = {}
ModernUI.__index = ModernUI

-- Serviços
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Cores
local Colors = {
    Background = Color3.fromRGB(26, 26, 34),
    Darker = Color3.fromRGB(21, 21, 28),
    Sidebar = Color3.fromRGB(22, 22, 29),
    Card = Color3.fromRGB(38, 38, 51),
    Button = Color3.fromRGB(42, 42, 54),
    Primary = Color3.fromRGB(79, 124, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(170, 170, 170),
}

-- Criar instância
local function New(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

-- Criar Window
function ModernUI:CreateWindow(title, size)
    size = size or UDim2.new(0, 900, 0, 550)
    
    local window = {
        Title = title,
        Size = size,
        Pages = {},
        CurrentPage = nil,
        Gui = New("ScreenGui", {
            Name = "ModernUI_" .. title,
            Parent = CoreGui,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
    }
    setmetatable(window, self)
    
    -- Main Frame
    window.Main = New("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Parent = window.Gui
    })
    
    -- Topbar
    local topbar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.Darker,
        BorderSizePixel = 0,
        Parent = window.Main
    })
    
    -- Título
    New("TextLabel", {
        BackgroundTransparency = 1,
        Text = "  " .. title,
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, -90, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar
    })
    
    -- Botão fechar
    local closeBtn = New("TextButton", {
        BackgroundColor3 = Colors.Button,
        Text = "✕",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -35, 0.5, -14),
        Parent = topbar
    })
    closeBtn.MouseButton1Click:Connect(function()
        window.Gui:Destroy()
    end)
    
    -- Sidebar
    window.Sidebar = New("Frame", {
        Size = UDim2.new(0, 200, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Colors.Sidebar,
        BorderSizePixel = 0,
        Parent = window.Main
    })
    
    -- Container dos botões da sidebar
    window.MenuContainer = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        Parent = window.Sidebar
    })
    
    local menuLayout = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        Parent = window.MenuContainer
    })
    
    menuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.MenuContainer.CanvasSize = UDim2.new(0, 0, 0, menuLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Área de conteúdo
    window.Content = New("ScrollingFrame", {
        Size = UDim2.new(1, -200, 1, -50),
        Position = UDim2.new(0, 200, 0, 50),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Colors.Primary,
        Parent = window.Main
    })
    
    local contentLayout = New("UIListLayout", {
        Padding = UDim.new(0, 20),
        Parent = window.Content
    })
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Método para criar página
    function window:CreatePage(name)
        local page = {
            Name = name,
            Window = window,
            Elements = {}
        }
        
        -- Botão da página na sidebar
        page.Button = New("TextButton", {
            Text = "  " .. name,
            BackgroundColor3 = Colors.Button,
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, -10, 0, 40),
            Position = UDim2.new(0, 5, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = window.MenuContainer
        })
        
        -- Container da página
        page.Container = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Visible = false,
            Parent = window.Content
        })
        
        page.Layout = New("UIListLayout", {
            Padding = UDim.new(0, 20),
            Parent = page.Container
        })
        
        page.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.Container.Size = UDim2.new(1, -20, 0, page.Layout.AbsoluteContentSize.Y)
        end)
        
        -- Clique no botão
        page.Button.MouseButton1Click:Connect(function()
            if window.CurrentPage then
                window.CurrentPage.Button.TextColor3 = Colors.TextMuted
                window.CurrentPage.Container.Visible = false
            end
            window.CurrentPage = page
            page.Button.TextColor3 = Colors.Primary
            page.Container.Visible = true
        end)
        
        -- Método para criar card (AGORA DENTRO DA PAGE)
        function page:CreateCard(title)
            local card = {
                Title = title,
                Page = page,
                Elements = {}
            }
            
            -- Frame do card
            card.Frame = New("Frame", {
                BackgroundColor3 = Colors.Card,
                Size = UDim2.new(1, 0, 0, 0),
                Parent = page.Container
            })
            
            -- Título do card
            New("TextLabel", {
                BackgroundTransparency = 1,
                Text = "  " .. title,
                TextColor3 = Colors.Text,
                TextSize = 18,
                Font = Enum.Font.GothamBold,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 10),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card.Frame
            })
            
            -- Container dos elementos
            card.ElementContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 45),
                Parent = card.Frame
            })
            
            card.ElementLayout = New("UIListLayout", {
                Padding = UDim.new(0, 10),
                Parent = card.ElementContainer
            })
            
            card.ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                card.ElementContainer.Size = UDim2.new(1, -20, 0, card.ElementLayout.AbsoluteContentSize.Y)
                card.Frame.Size = UDim2.new(1, 0, 0, card.ElementLayout.AbsoluteContentSize.Y + 60)
            end)
            
            -- MÉTODOS DOS ELEMENTOS
            
            function card:Label(text)
                return New("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, 0, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = self.ElementContainer
                })
            end
            
            function card:Button(text, callback)
                local btn = New("TextButton", {
                    Text = text,
                    BackgroundColor3 = Colors.Button,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, 0, 0, 35),
                    Parent = self.ElementContainer
                })
                
                btn.MouseButton1Click:Connect(function()
                    pcall(callback or function() end)
                end)
                
                return btn
            end
            
            function card:PrimaryButton(text, callback)
                local btn = New("TextButton", {
                    Text = text,
                    BackgroundColor3 = Colors.Primary,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, 0, 0, 35),
                    Parent = self.ElementContainer
                })
                
                btn.MouseButton1Click:Connect(function()
                    pcall(callback or function() end)
                end)
                
                return btn
            end
            
            function card:Toggle(text, default, callback)
                local value = default or false
                
                local frame = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = self.ElementContainer
                })
                
                local label = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, -60, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                
                local toggleBg = New("Frame", {
                    BackgroundColor3 = value and Colors.Primary or Colors.Button,
                    Size = UDim2.new(0, 50, 0, 25),
                    Position = UDim2.new(1, -50, 0.5, -12.5),
                    Parent = frame
                })
                
                local toggleCircle = New("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Size = UDim2.new(0, 21, 0, 21),
                    Position = value and UDim2.new(1, -24, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5),
                    Parent = toggleBg
                })
                
                local hitbox = New("TextButton", {
                    BackgroundTransparency = 1,
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = frame
                })
                
                hitbox.MouseButton1Click:Connect(function()
                    value = not value
                    toggleBg.BackgroundColor3 = value and Colors.Primary or Colors.Button
                    toggleCircle.Position = value and UDim2.new(1, -24, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
                    pcall(callback, value)
                end)
                
                return {
                    Get = function() return value end,
                    Set = function(v) 
                        value = v
                        toggleBg.BackgroundColor3 = value and Colors.Primary or Colors.Button
                        toggleCircle.Position = value and UDim2.new(1, -24, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
                    end
                }
            end
            
            function card:Slider(text, min, max, default, callback)
                local value = default or min
                
                local frame = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 45),
                    Parent = self.ElementContainer
                })
                
                local label = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = text .. ": " .. value,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, 0, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                
                local sliderBg = New("Frame", {
                    BackgroundColor3 = Colors.Button,
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 1, -8),
                    Parent = frame
                })
                
                local sliderFill = New("Frame", {
                    BackgroundColor3 = Colors.Primary,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    Parent = sliderBg
                })
                
                local button = New("TextButton", {
                    BackgroundTransparency = 1,
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = sliderBg
                })
                
                local dragging = false
                
                button.MouseButton1Down:Connect(function(input)
                    dragging = true
                end)
                
                button.MouseButton1Up:Connect(function()
                    dragging = false
                end)
                
                button.MouseMoved:Connect(function(input)
                    if dragging then
                        local pos = input.Position.X - sliderBg.AbsolutePosition.X
                        local percent = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
                        value = min + (max - min) * percent
                        value = math.floor(value * 10) / 10
                        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                        label.Text = text .. ": " .. value
                        pcall(callback, value)
                    end
                end)
            end
            
            function card:Input(placeholder, callback)
                local box = New("TextBox", {
                    BackgroundColor3 = Colors.Button,
                    PlaceholderText = placeholder or "Digite...",
                    PlaceholderColor3 = Colors.TextMuted,
                    Text = "",
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, 0, 0, 35),
                    ClearTextOnFocus = false,
                    Parent = self.ElementContainer
                })
                
                box.FocusLost:Connect(function(enter)
                    if enter then
                        pcall(callback, box.Text)
                    end
                end)
                
                return box
            end
            
            function card:Dropdown(text, options, default, callback)
                local selected = default or options[1]
                local open = false
                
                local frame = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35),
                    ClipsDescendants = false,
                    Parent = self.ElementContainer
                })
                
                local label = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(0.3, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                
                local btn = New("TextButton", {
                    BackgroundColor3 = Colors.Button,
                    Text = selected,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Position = UDim2.new(0.3, 5, 0, 0),
                    Size = UDim2.new(0.7, -5, 1, 0),
                    Parent = frame
                })
                
                local list = New("ScrollingFrame", {
                    BackgroundColor3 = Colors.Darker,
                    Visible = false,
                    Size = UDim2.new(0.7, -5, 0, 100),
                    Position = UDim2.new(0.3, 5, 1, 5),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 4,
                    Parent = frame
                })
                
                local listLayout = New("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = list
                })
                
                listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
                end)
                
                for _, opt in ipairs(options) do
                    local optBtn = New("TextButton", {
                        Text = opt,
                        BackgroundColor3 = Colors.Button,
                        TextColor3 = Colors.Text,
                        TextSize = 14,
                        Font = Enum.Font.Gotham,
                        Size = UDim2.new(1, 0, 0, 25),
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
            end
            
            table.insert(page.Elements, card)
            return card
        end
        
        -- Primeira página fica ativa
        if #window.Pages == 0 then
            window.CurrentPage = page
            page.Button.TextColor3 = Colors.Primary
            page.Container.Visible = true
        end
        
        table.insert(window.Pages, page)
        return page
    end
    
    return window
end

return ModernUI
