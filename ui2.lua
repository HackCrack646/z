--[[
    UI Library para Executor Roblox
    Estilo: Moderno / Clean
    Versão: 1.0
]]

local UILib = {}
local Running = true

-- Configurações padrão
local DefaultTheme = {
    Background = Color3.fromRGB(25, 25, 25),
    Surface = Color3.fromRGB(35, 35, 35),
    Primary = Color3.fromRGB(0, 120, 255),
    Secondary = Color3.fromRGB(60, 60, 60),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(0, 200, 100),
    Danger = Color3.fromRGB(255, 70, 70),
    Warning = Color3.fromRGB(255, 170, 0),
    Border = Color3.fromRGB(45, 45, 45),
    Shadow = Color3.fromRGB(0, 0, 0)
}

local CurrentTheme = DefaultTheme
local Dragging = {Object = nil, Type = nil, Offset = Vector2.new()}
local Connections = {}
local Libraries = {}

-- Funções auxiliares
local function Create(class, properties)
    local obj = Instance.new(class)
    for prop, value in pairs(properties) do
        obj[prop] = value
    end
    return obj
end

local function AddConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

-- Sistema de temas
function UILib:SetTheme(theme)
    CurrentTheme = theme or DefaultTheme
end

function UILib:GetTheme()
    return CurrentTheme
end

--[[
    Cria uma janela principal
    Exemplo: local window = UILib:CreateWindow("Meu Executor", "1.0.0")
]]
function UILib:CreateWindow(title, subtitle, size)
    size = size or Vector2.new(600, 400)
    
    -- ScreenGui principal
    local gui = Create("ScreenGui", {
        Name = "UILibrary",
        DisplayOrder = 999,
        IgnoreGuiInset = true,
        Parent = gethui and gethui() or game:GetService("CoreGui")
    })
    
    -- Frame principal com sombra
    local mainFrame = Create("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, size.X, 0, size.Y),
        Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2),
        BackgroundColor3 = CurrentTheme.Background,
        BorderSizePixel = 0,
        Parent = gui
    })
    
    -- Sombra
    Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 20, 20),
        Parent = mainFrame,
        ZIndex = -1
    })
    
    -- Barra de título
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    -- Linha decorativa
    Create("Frame", {
        Name = "Accent",
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Parent = titleBar
    })
    
    -- Título
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = CurrentTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        Parent = titleBar
    })
    
    -- Subtítulo
    if subtitle then
        Create("TextLabel", {
            Name = "Subtitle",
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = subtitle,
            TextColor3 = CurrentTheme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            Parent = titleBar
        })
    end
    
    -- Botões da janela
    local buttonFrame = Create("Frame", {
        Name = "WindowButtons",
        Size = UDim2.new(0, 70, 1, 0),
        Position = UDim2.new(1, -70, 0, 0),
        BackgroundTransparency = 1,
        Parent = titleBar
    })
    
    -- Botão minimizar
    local minBtn = Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10),
        BackgroundColor3 = CurrentTheme.Secondary,
        Text = "−",
        TextColor3 = CurrentTheme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        AutoButtonColor = false,
        Parent = buttonFrame
    })
    
    -- Botão fechar
    local closeBtn = Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 40, 0.5, -10),
        BackgroundColor3 = CurrentTheme.Danger,
        Text = "×",
        TextColor3 = CurrentTheme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        AutoButtonColor = false,
        Parent = buttonFrame
    })
    
    -- Conteúdo principal
    local content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -20, 1, -45),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        Parent = mainFrame
    })
    
    -- Tabs container
    local tabBar = Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Parent = content
    })
    
    -- Linha dos tabs
    Create("Frame", {
        Name = "TabLine",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = CurrentTheme.Border,
        BorderSizePixel = 0,
        Parent = tabBar
    })
    
    -- Tabs container
    local tabs = Create("Frame", {
        Name = "Tabs",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = tabBar
    })
    
    -- Pages container
    local pages = Create("Frame", {
        Name = "Pages",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = content
    })
    
    -- Sistema de arrastar
    AddConnection(titleBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging.Object = mainFrame
            Dragging.Type = "Window"
            Dragging.Offset = Vector2.new(input.Position.X - mainFrame.AbsolutePosition.X, 
                                           input.Position.Y - mainFrame.AbsolutePosition.Y)
        end
    end)
    
    -- Botões da janela
    AddConnection(minBtn.MouseButton1Click, function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    AddConnection(closeBtn.MouseButton1Click, function()
        Running = false
        gui:Destroy()
        for _, conn in ipairs(Connections) do
            conn:Disconnect()
        end
    end)
    
    -- Efeitos hover
    local function SetupHover(btn, normalColor, hoverColor)
        AddConnection(btn.MouseEnter, function()
            btn.BackgroundColor3 = hoverColor
        end)
        AddConnection(btn.MouseLeave, function()
            btn.BackgroundColor3 = normalColor
        end)
    end
    
    SetupHover(minBtn, CurrentTheme.Secondary, CurrentTheme.Primary)
    SetupHover(closeBtn, CurrentTheme.Danger, Color3.fromRGB(200, 50, 50))
    
    -- Sistema de input global
    AddConnection(game:GetService("UserInputService").InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging.Object = nil
        end
    end)
    
    AddConnection(game:GetService("RunService").RenderStepped, function()
        if Dragging.Object and Dragging.Type == "Window" then
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            Dragging.Object.Position = UDim2.new(0, mouse.X - Dragging.Offset.X, 0, mouse.Y - Dragging.Offset.Y)
        end
    end)
    
    -- Retorna a API da janela
    local WindowAPI = {
        Gui = gui,
        MainFrame = mainFrame,
        Content = content,
        Tabs = tabs,
        Pages = pages,
        CurrentTab = nil,
        
        -- Adiciona uma nova tab
        AddTab = function(self, name, icon)
            local tabButton = Create("TextButton", {
                Name = "Tab_" .. name,
                Size = UDim2.new(0, 100, 1, -2),
                Position = UDim2.new(0, #self.Tabs:GetChildren() * 100, 0, 1),
                BackgroundColor3 = CurrentTheme.Background,
                Text = icon and icon .. " " .. name or name,
                TextColor3 = CurrentTheme.TextSecondary,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                AutoButtonColor = false,
                Parent = self.Tabs,
                ZIndex = 2
            })
            
            local page = Create("ScrollingFrame", {
                Name = "Page_" .. name,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = CurrentTheme.Primary,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Visible = false,
                Parent = self.Pages
            })
            
            -- Efeitos hover/select
            local function SelectTab()
                if self.CurrentTab then
                    self.CurrentTab.Button.BackgroundColor3 = CurrentTheme.Background
                    self.CurrentTab.Button.TextColor3 = CurrentTheme.TextSecondary
                    self.CurrentTab.Page.Visible = false
                end
                
                tabButton.BackgroundColor3 = CurrentTheme.Surface
                tabButton.TextColor3 = CurrentTheme.Text
                page.Visible = true
                
                self.CurrentTab = {
                    Button = tabButton,
                    Page = page
                }
            end
            
            AddConnection(tabButton.MouseButton1Click, SelectTab)
            
            -- Se for a primeira tab, seleciona automaticamente
            if not self.CurrentTab then
                SelectTab()
            end
            
            return {
                Button = tabButton,
                Page = page,
                
                -- Adiciona seção à página
                AddSection = function(self, sectionName)
                    local section = Create("Frame", {
                        Name = "Section_" .. sectionName,
                        Size = UDim2.new(1, -20, 0, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        BackgroundColor3 = CurrentTheme.Surface,
                        BorderSizePixel = 0,
                        Parent = page
                    })
                    
                    -- Título da seção
                    local title = Create("TextLabel", {
                        Name = "Title",
                        Size = UDim2.new(1, -20, 0, 30),
                        Position = UDim2.new(0, 10, 0, 5),
                        BackgroundTransparency = 1,
                        Text = sectionName,
                        TextColor3 = CurrentTheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Font = Enum.Font.GothamSemibold,
                        TextSize = 16,
                        Parent = section
                    })
                    
                    -- Linha decorativa
                    Create("Frame", {
                        Name = "Line",
                        Size = UDim2.new(1, -20, 0, 1),
                        Position = UDim2.new(0, 10, 0, 35),
                        BackgroundColor3 = CurrentTheme.Primary,
                        BorderSizePixel = 0,
                        Parent = section
                    })
                    
                    -- Container para elementos
                    local container = Create("Frame", {
                        Name = "Container",
                        Size = UDim2.new(1, -20, 0, 0),
                        Position = UDim2.new(0, 10, 0, 45),
                        BackgroundTransparency = 1,
                        Parent = section,
                        ClipsDescendants = true
                    })
                    
                    -- Atualiza tamanhos
                    local function UpdateSize()
                        local totalHeight = 0
                        for _, child in ipairs(container:GetChildren()) do
                            if child:IsA("Frame") or child:IsA("TextButton") then
                                totalHeight = totalHeight + child.Size.Y.Offset + 5
                            end
                        end
                        container.Size = UDim2.new(1, -20, 0, totalHeight)
                        section.Size = UDim2.new(1, -20, 0, totalHeight + 55)
                        
                        -- Atualiza canvas do page
                        local pageHeight = 10
                        for _, child in ipairs(page:GetChildren()) do
                            if child:IsA("Frame") then
                                pageHeight = pageHeight + child.Size.Y.Offset + 10
                            end
                        end
                        page.CanvasSize = UDim2.new(0, 0, 0, pageHeight)
                    end
                    
                    -- API da seção
                    local SectionAPI = {
                        Container = container,
                        
                        -- Adiciona botão
                        AddButton = function(self, buttonText, callback)
                            local button = Create("TextButton", {
                                Name = "Button_" .. buttonText,
                                Size = UDim2.new(1, 0, 0, 35),
                                BackgroundColor3 = CurrentTheme.Background,
                                Text = buttonText,
                                TextColor3 = CurrentTheme.Text,
                                Font = Enum.Font.Gotham,
                                TextSize = 14,
                                AutoButtonColor = false,
                                Parent = container
                            })
                            
                            AddConnection(button.MouseButton1Click, callback)
                            
                            AddConnection(button.MouseEnter, function()
                                button.BackgroundColor3 = CurrentTheme.Primary
                            end)
                            
                            AddConnection(button.MouseLeave, function()
                                button.BackgroundColor3 = CurrentTheme.Background
                            end)
                            
                            UpdateSize()
                            return button
                        end,
                        
                        -- Adiciona toggle
                        AddToggle = function(self, toggleText, default, callback)
                            local frame = Create("Frame", {
                                Name = "Toggle_" .. toggleText,
                                Size = UDim2.new(1, 0, 0, 35),
                                BackgroundTransparency = 1,
                                Parent = container
                            })
                            
                            local label = Create("TextLabel", {
                                Name = "Label",
                                Size = UDim2.new(1, -45, 1, 0),
                                BackgroundTransparency = 1,
                                Text = toggleText,
                                TextColor3 = CurrentTheme.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Font = Enum.Font.Gotham,
                                TextSize = 14,
                                Parent = frame
                            })
                            
                            local toggle = Create("Frame", {
                                Name = "Toggle",
                                Size = UDim2.new(0, 40, 0, 20),
                                Position = UDim2.new(1, -40, 0.5, -10),
                                BackgroundColor3 = CurrentTheme.Background,
                                Parent = frame
                            })
                            
                            local knob = Create("Frame", {
                                Name = "Knob",
                                Size = UDim2.new(0, 16, 0, 16),
                                Position = UDim2.new(0, 2, 0.5, -8),
                                BackgroundColor3 = CurrentTheme.TextSecondary,
                                Parent = toggle
                            })
                            
                            local state = default or false
                            
                            local function UpdateToggle()
                                if state then
                                    toggle.BackgroundColor3 = CurrentTheme.Primary
                                    knob.Position = UDim2.new(0, 22, 0.5, -8)
                                    knob.BackgroundColor3 = CurrentTheme.Text
                                else
                                    toggle.BackgroundColor3 = CurrentTheme.Background
                                    knob.Position = UDim2.new(0, 2, 0.5, -8)
                                    knob.BackgroundColor3 = CurrentTheme.TextSecondary
                                end
                            end
                            
                            UpdateToggle()
                            
                            local button = Create("TextButton", {
                                Name = "Hitbox",
                                Size = UDim2.new(1, 0, 1, 0),
                                BackgroundTransparency = 1,
                                Text = "",
                                Parent = frame
                            })
                            
                            AddConnection(button.MouseButton1Click, function()
                                state = not state
                                UpdateToggle()
                                if callback then
                                    callback(state)
                                end
                            end)
                            
                            UpdateSize()
                            return {
                                Set = function(_, newState)
                                    state = newState
                                    UpdateToggle()
                                end,
                                Get = function() return state end
                            }
                        end,
                        
                        -- Adiciona slider
                        AddSlider = function(self, sliderText, min, max, default, callback)
                            local frame = Create("Frame", {
                                Name = "Slider_" .. sliderText,
                                Size = UDim2.new(1, 0, 0, 50),
                                BackgroundTransparency = 1,
                                Parent = container
                            })
                            
                            local label = Create("TextLabel", {
                                Name = "Label",
                                Size = UDim2.new(1, 0, 0, 20),
                                BackgroundTransparency = 1,
                                Text = sliderText,
                                TextColor3 = CurrentTheme.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Font = Enum.Font.Gotham,
                                TextSize = 14,
                                Parent = frame
                            })
                            
                            local value = default or min
                            local valueLabel = Create("TextLabel", {
                                Name = "Value",
                                Size = UDim2.new(0, 40, 0, 20),
                                Position = UDim2.new(1, -40, 0, 0),
                                BackgroundTransparency = 1,
                                Text = tostring(value),
                                TextColor3 = CurrentTheme.Primary,
                                TextXAlignment = Enum.TextXAlignment.Right,
                                Font = Enum.Font.GothamBold,
                                TextSize = 14,
                                Parent = frame
                            })
                            
                            local bar = Create("Frame", {
                                Name = "Bar",
                                Size = UDim2.new(1, 0, 0, 4),
                                Position = UDim2.new(0, 0, 0, 25),
                                BackgroundColor3 = CurrentTheme.Background,
                                Parent = frame
                            })
                            
                            local fill = Create("Frame", {
                                Name = "Fill",
                                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                                BackgroundColor3 = CurrentTheme.Primary,
                                Parent = bar
                            })
                            
                            local knob = Create("Frame", {
                                Name = "Knob",
                                Size = UDim2.new(0, 12, 0, 12),
                                Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                                BackgroundColor3 = CurrentTheme.Text,
                                Parent = bar
                            })
                            
                            local dragging = false
                            
                            local function UpdateSlider(input)
                                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                                value = math.round(min + (max - min) * pos)
                                fill.Size = UDim2.new(pos, 0, 1, 0)
                                knob.Position = UDim2.new(pos, -6, 0.5, -6)
                                valueLabel.Text = tostring(value)
                                if callback then
                                    callback(value)
                                end
                            end
                            
                            AddConnection(bar.InputBegan, function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    dragging = true
                                    UpdateSlider(input)
                                end
                            end)
                            
                            AddConnection(frame.InputEnded, function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    dragging = false
                                end
                            end)
                            
                            AddConnection(game:GetService("UserInputService").InputChanged, function(input)
                                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                    UpdateSlider(input)
                                end
                            end)
                            
                            UpdateSize()
                            return {
                                Set = function(_, newValue)
                                    value = math.clamp(newValue, min, max)
                                    local pos = (value - min) / (max - min)
                                    fill.Size = UDim2.new(pos, 0, 1, 0)
                                    knob.Position = UDim2.new(pos, -6, 0.5, -6)
                                    valueLabel.Text = tostring(value)
                                end,
                                Get = function() return value end
                            }
                        end,
                        
                        -- Adiciona dropdown
                        AddDropdown = function(self, dropdownText, options, default, callback)
                            local frame = Create("Frame", {
                                Name = "Dropdown_" .. dropdownText,
                                Size = UDim2.new(1, 0, 0, 35),
                                BackgroundTransparency = 1,
                                Parent = container,
                                ClipsDescendants = true
                            })
                            
                            local button = Create("TextButton", {
                                Name = "Button",
                                Size = UDim2.new(1, 0, 0, 35),
                                BackgroundColor3 = CurrentTheme.Background,
                                Text = dropdownText .. ": " .. (default or options[1] or "Selecione"),
                                TextColor3 = CurrentTheme.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Font = Enum.Font.Gotham,
                                TextSize = 14,
                                Parent = frame
                            })
                            
                            local arrow = Create("TextLabel", {
                                Name = "Arrow",
                                Size = UDim2.new(0, 20, 1, 0),
                                Position = UDim2.new(1, -20, 0, 0),
                                BackgroundTransparency = 1,
                                Text = "▼",
                                TextColor3 = CurrentTheme.TextSecondary,
                                Font = Enum.Font.Gotham,
                                TextSize = 12,
                                Parent = button
                            })
                            
                            local expanded = false
                            local selected = default or options[1]
                            
                            local dropdownFrame = Create("Frame", {
                                Name = "Options",
                                Size = UDim2.new(1, 0, 0, 0),
                                Position = UDim2.new(0, 0, 0, 35),
                                BackgroundTransparency = 1,
                                Parent = frame,
                                ClipsDescendants = true
                            })
                            
                            local function UpdateDropdown()
                                local height = expanded and (#options * 30) or 0
                                dropdownFrame.Size = UDim2.new(1, 0, 0, height)
                                frame.Size = UDim2.new(1, 0, 0, 35 + height)
                                arrow.Text = expanded and "▲" or "▼"
                                UpdateSize()
                            end
                            
                            for i, option in ipairs(options) do
                                local optionBtn = Create("TextButton", {
                                    Name = "Option_" .. option,
                                    Size = UDim2.new(1, -10, 0, 25),
                                    Position = UDim2.new(0, 5, 0, (i-1) * 30),
                                    BackgroundColor3 = CurrentTheme.Surface,
                                    Text = option,
                                    TextColor3 = option == selected and CurrentTheme.Primary or CurrentTheme.TextSecondary,
                                    Font = Enum.Font.Gotham,
                                    TextSize = 14,
                                    Parent = dropdownFrame
                                })
                                
                                AddConnection(optionBtn.MouseButton1Click, function()
                                    selected = option
                                    button.Text = dropdownText .. ": " .. selected
                                    expanded = false
                                    UpdateDropdown()
                                    if callback then
                                        callback(selected)
                                    end
                                end)
                            end
                            
                            AddConnection(button.MouseButton1Click, function()
                                expanded = not expanded
                                UpdateDropdown()
                            end)
                            
                            UpdateSize()
                            return {
                                Set = function(_, newValue)
                                    selected = newValue
                                    button.Text = dropdownText .. ": " .. selected
                                end,
                                Get = function() return selected end
                            }
                        end,
                        
                        -- Adiciona campo de texto
                        AddTextbox = function(self, boxText, placeholder, callback)
                            local frame = Create("Frame", {
                                Name = "Textbox_" .. boxText,
                                Size = UDim2.new(1, 0, 0, 50),
                                BackgroundTransparency = 1,
                                Parent = container
                            })
                            
                            local label = Create("TextLabel", {
                                Name = "Label",
                                Size = UDim2.new(1, 0, 0, 20),
                                BackgroundTransparency = 1,
                                Text = boxText,
                                TextColor3 = CurrentTheme.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Font = Enum.Font.Gotham,
                                TextSize = 14,
                                Parent = frame
                            })
                            
                            local box = Create("TextBox", {
                                Name = "Box",
                                Size = UDim2.new(1, 0, 0, 30),
                                Position = UDim2.new(0, 0, 0, 20),
                                BackgroundColor3 = CurrentTheme.Background,
                                Text = placeholder or "",
                                TextColor3 = CurrentTheme.Text,
                                PlaceholderText = placeholder or "Digite...",
                                PlaceholderColor3 = CurrentTheme.TextSecondary,
                                Font = Enum.Font.Gotham,
                                TextSize = 14,
                                ClearTextOnFocus = false,
                                Parent = frame
                            })
                            
                            AddConnection(box.FocusLost, function(enterPressed)
                                if enterPressed and callback then
                                    callback(box.Text)
                                end
                            end)
                            
                            UpdateSize()
                            return box
                        end,
                        
                        -- Adiciona label
                        AddLabel = function(self, labelText)
                            local label = Create("TextLabel", {
                                Name = "Label",
                                Size = UDim2.new(1, 0, 0, 25),
                                BackgroundTransparency = 1,
                                Text = labelText,
                                TextColor3 = CurrentTheme.TextSecondary,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Font = Enum.Font.Gotham,
                                TextSize = 13,
                                Parent = container
                            })
                            
                            UpdateSize()
                            return label
                        end
                    }
                    
                    return SectionAPI
                end
            }
        end
    }
    
    return WindowAPI
end

--[[
    Cria uma notificação
    Exemplo: UILib:Notify("Sucesso", "Script injetado!", 3)
]]
function UILib:Notify(title, message, duration, type)
    duration = duration or 3
    type = type or "info"
    
    local colors = {
        info = CurrentTheme.Primary,
        success = CurrentTheme.Success,
        warning = CurrentTheme.Warning,
        error = CurrentTheme.Danger
    }
    
    local gui = Create("ScreenGui", {
        Name = "Notification",
        DisplayOrder = 1000,
        IgnoreGuiInset = true,
        Parent = gethui and gethui() or game:GetService("CoreGui")
    })
    
    local frame = Create("Frame", {
        Name = "Notify",
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -320, 1, -100),
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        Parent = gui
    })
    
    -- Barra de cor
    Create("Frame", {
        Name = "Bar",
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = colors[type] or CurrentTheme.Primary,
        BorderSizePixel = 0,
        Parent = frame
    })
    
    -- Título
    Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 15, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = CurrentTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        Parent = frame
    })
    
    -- Mensagem
    Create("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 15, 0, 35),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = CurrentTheme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Parent = frame
    })
    
    -- Timer bar
    local timer = Create("Frame", {
        Name = "Timer",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = colors[type] or CurrentTheme.Primary,
        BorderSizePixel = 0,
        Parent = frame
    })
    
    -- Animação
    local startTime = tick()
    local connection
    
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local progress = 1 - (elapsed / duration)
        
        if progress <= 0 then
            connection:Disconnect()
            gui:Destroy()
        else
            timer.Size = UDim2.new(progress, 0, 0, 2)
        end
    end)
    
    -- Fechar ao clicar
    local closeBtn = Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0, 5),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = CurrentTheme.TextSecondary,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Parent = frame
    })
    
    AddConnection(closeBtn.MouseButton1Click, function()
        connection:Disconnect()
        gui:Destroy()
    end)
    
    return gui
end

--[[
    Cria um loading screen
]]
function UILib:CreateLoading(message)
    local gui = Create("ScreenGui", {
        Name = "Loading",
        DisplayOrder = 1001,
        IgnoreGuiInset = true,
        Parent = gethui and gethui() or game:GetService("CoreGui")
    })
    
    local overlay = Create("Frame", {
        Name = "Overlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        Parent = gui
    })
    
    local frame = Create("Frame", {
        Name = "Loader",
        Size = UDim2.new(0, 200, 0, 100),
        Position = UDim2.new(0.5, -100, 0.5, -50),
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        Parent = gui
    })
    
    -- Spinner
    local spinner = Create("Frame", {
        Name = "Spinner",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0.5, -20, 0.5, -30),
        BackgroundTransparency = 1,
        Parent = frame
    })
    
    for i = 1, 8 do
        local dot = Create("Frame", {
            Name = "Dot" .. i,
            Size = UDim2.new(0, 6, 0, 6),
            Position = UDim2.new(0.5, -3, 0.5, -3),
            BackgroundColor3 = CurrentTheme.Primary,
            BackgroundTransparency = 0.8,
            Parent = spinner
        })
        
        local angle = (i / 8) * math.pi * 2
        local connection
        
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            local time = tick() * 2
            local offset = 15 * math.cos(angle + time)
            dot.Position = UDim2.new(0.5, -3 + offset * math.cos(angle), 0.5, -3 + offset * math.sin(angle))
        end)
        
        table.insert(Connections, connection)
    end
    
    -- Texto
    Create("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundTransparency = 1,
        Text = message or "Carregando...",
        TextColor3 = CurrentTheme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = frame
    })
    
    return {
        Gui = gui,
        Destroy = function()
            gui:Destroy()
        end
    }
end

-- Sistema de input global
AddConnection(game:GetService("UserInputService").InputBegan, function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        -- Toggle UI visibility (pode ser customizado)
        for _, gui in ipairs(Libraries) do
            gui.MainFrame.Visible = not gui.MainFrame.Visible
        end
    end
end)

--[[
    Exemplo de uso:
]]
local function Example()
    local window = UILib:CreateWindow("Meu Executor", "v1.0.0", Vector2.new(700, 500))
    
    local tab1 = window:AddTab("Home", "🏠")
    local section1 = tab1:AddSection("Scripts")
    
    section1:AddButton("Injetar Script", function()
        UILib:Notify("Sucesso", "Script injetado!", 2, "success")
    end)
    
    local toggle = section1:AddToggle("Auto Execute", false, function(state)
        print("Auto execute:", state)
    end)
    
    local slider = section1:AddSlider("Velocidade", 0, 100, 50, function(value)
        print("Velocidade:", value)
    end)
    
    local dropdown = section1:AddDropdown("Opções", {"Opção 1", "Opção 2", "Opção 3"}, "Opção 1", function(selected)
        print("Selecionado:", selected)
    end)
    
    local textbox = section1:AddTextbox("Comando", "Digite um comando...", function(text)
        print("Comando:", text)
    end)
    
    local tab2 = window:AddTab("Config", "⚙️")
    local section2 = tab2:AddSection("Configurações")
    
    section2:AddLabel("Configurações do executor")
    section2:AddButton("Limpar cache", function()
        UILib:Notify("Info", "Cache limpo!", 1.5, "info")
    end)
    
    -- Loading screen exemplo
    local loading = UILib:CreateLoading("Inicializando...")
    task.wait(2)
    loading:Destroy()
end

-- Executa exemplo se não estiver sendo usado como lib
if not ... then
    Example()
end

return UILib
