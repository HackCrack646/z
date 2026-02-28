--[[
    UI Library v2.0
    Organizada, sem bugs e fácil de usar
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- Configurações padrão
local DEFAULT_THEME = {
    Background = Color3.fromRGB(25, 25, 25),
    Surface = Color3.fromRGB(35, 35, 35),
    Primary = Color3.fromRGB(0, 120, 255),
    Secondary = Color3.fromRGB(60, 60, 60),
    Text = Color3.fromRGB(255, 255, 255),
    TextDisabled = Color3.fromRGB(150, 150, 150),
    Success = Color3.fromRGB(0, 200, 0),
    Danger = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 200, 0),
    Border = Color3.fromRGB(45, 45, 45),
    Shadow = Color3.fromRGB(0, 0, 0),
}

-- Utilitários internos
local Utility = {}

function Utility:Create(class, properties)
    local obj = Instance.new(class)
    for prop, value in pairs(properties) do
        obj[prop] = value
    end
    return obj
end

function Utility:ApplyShadow(parent, transparency)
    local shadow = self:Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261999",
        ImageColor3 = DEFAULT_THEME.Shadow,
        ImageTransparency = transparency or 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        Parent = parent,
    })
    return shadow
end

function Utility:MakeDraggable(frame, dragArea)
    dragArea = dragArea or frame
    
    local dragging = false
    local dragStart = Vector2.new()
    local frameStart = Vector2.new()
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            frameStart = Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y)
            input:Capture()
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            local newPos = frameStart + delta
            frame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end)
    
    dragArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Classe Window
function UILibrary:CreateWindow(config)
    config = config or {}
    
    local window = {
        Title = config.Title or "UI Library",
        Size = config.Size or UDim2.new(0, 600, 0, 400),
        Theme = config.Theme or DEFAULT_THEME,
        Position = config.Position or UDim2.new(0.5, -300, 0.5, -200),
        Tabs = {},
        CurrentTab = nil,
        Elements = {},
        Connections = {},
        Draggable = config.Draggable ~= false,
        Minimized = false,
    }
    
    setmetatable(window, self)
    
    -- Criar GUI principal
    window.ScreenGui = Utility:Create("ScreenGui", {
        Name = "UILibrary_" .. tostring(math.random(1000, 9999)),
        Parent = gethui and gethui() or game:GetService("CoreGui"),
        DisplayOrder = 1000,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Frame principal
    window.MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = window.Theme.Background,
        BorderSizePixel = 0,
        Position = window.Position,
        Size = window.Size,
        ClipsDescendants = true,
        Parent = window.ScreenGui,
    })
    
    -- Sombra
    Utility:ApplyShadow(window.MainFrame, 0.5)
    
    -- Barra de título
    window.TitleBar = Utility:Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = window.MainFrame,
    })
    
    -- Título
    window.TitleLabel = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = window.Title,
        TextColor3 = window.Theme.Text,
        TextSize = 16,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = window.TitleBar,
    })
    
    -- Botões da barra de título
    window.MinimizeBtn = Utility:Create("TextButton", {
        Name = "MinimizeBtn",
        BackgroundColor3 = window.Theme.Secondary,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = window.Theme.Text,
        TextSize = 18,
        Position = UDim2.new(1, -60, 0, 5),
        Size = UDim2.new(0, 25, 0, 20),
        Parent = window.TitleBar,
    })
    
    window.CloseBtn = Utility:Create("TextButton", {
        Name = "CloseBtn",
        BackgroundColor3 = window.Theme.Danger,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = window.Theme.Text,
        TextSize = 20,
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 25, 0, 20),
        Parent = window.TitleBar,
    })
    
    -- Container de abas
    window.TabContainer = Utility:Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 30),
        Parent = window.MainFrame,
    })
    
    -- Lista de abas
    window.TabList = Utility:Create("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        Parent = window.TabContainer,
    })
    
    local tabListLayout = Utility:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = window.TabList,
    })
    
    -- Container de conteúdo
    window.ContentContainer = Utility:Create("Frame", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 70),
        Size = UDim2.new(1, -10, 1, -80),
        Parent = window.MainFrame,
    })
    
    -- Tornar arrastável
    if window.Draggable then
        Utility:MakeDraggable(window.MainFrame, window.TitleBar)
    end
    
    -- Eventos dos botões
    window.Connections[#window.Connections+1] = window.MinimizeBtn.MouseButton1Click:Connect(function()
        window:ToggleMinimize()
    end)
    
    window.Connections[#window.Connections+1] = window.CloseBtn.MouseButton1Click:Connect(function()
        window:Destroy()
    end)
    
    -- Funções da janela
    function window:AddTab(name)
        return self:CreateTab(name)
    end
    
    function window:ToggleMinimize()
        self.Minimized = not self.Minimized
        if self.Minimized then
            self.MainFrame:TweenSize(UDim2.new(0, 200, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            self.MinimizeBtn.Text = "□"
        else
            self.MainFrame:TweenSize(self.Size, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            self.MinimizeBtn.Text = "−"
        end
    end
    
    function window:Destroy()
        for _, conn in ipairs(self.Connections) do
            conn:Disconnect()
        end
        self.ScreenGui:Destroy()
    end
    
    function window:SetTheme(theme)
        self.Theme = theme
        -- Atualizar cores aqui
    end
    
    return window
end

-- Classe Tab
function UILibrary:CreateTab(name)
    local window = self
    local tab = {
        Name = name,
        Window = window,
        Elements = {},
        Sections = {},
    }
    
    -- Botão da tab
    local tabButton = Utility:Create("TextButton", {
        Name = "Tab_" .. name,
        BackgroundColor3 = window.Theme.Background,
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = window.Theme.TextDisabled,
        TextSize = 14,
        Size = UDim2.new(0, 80, 1, 0),
        Parent = window.TabList,
    })
    
    tab.Button = tabButton
    
    -- Container da tab
    local tabContainer = Utility:Create("ScrollingFrame", {
        Name = "Content_" .. name,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = window.Theme.Primary,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = window.ContentContainer,
    })
    
    tab.Container = tabContainer
    
    -- Layout do container
    local containerLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabContainer,
    })
    
    containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, containerLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Evento de clique na tab
    window.Connections[#window.Connections+1] = tabButton.MouseButton1Click:Connect(function()
        if window.CurrentTab then
            window.CurrentTab.Button.TextColor3 = window.Theme.TextDisabled
            window.CurrentTab.Container.Visible = false
        end
        
        window.CurrentTab = tab
        tabButton.TextColor3 = window.Theme.Primary
        tabContainer.Visible = true
    end)
    
    -- Selecionar primeira tab automaticamente
    if not window.CurrentTab then
        window.CurrentTab = tab
        tabButton.TextColor3 = window.Theme.Primary
        tabContainer.Visible = true
    end
    
    -- Funções da tab
    function tab:AddSection(name)
        return self:CreateSection(name)
    end
    
    table.insert(window.Tabs, tab)
    
    return tab
end

-- Classe Section
function UILibrary:CreateSection(name)
    local tab = self
    local section = {
        Name = name,
        Tab = tab,
        Elements = {},
    }
    
    local container = Utility:Create("Frame", {
        Name = "Section_" .. name,
        BackgroundColor3 = tab.Window.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 30),
        Parent = tab.Container,
    })
    
    -- Título da seção
    local title = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = name,
        TextColor3 = tab.Window.Theme.Primary,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    -- Container de elementos
    local elementsContainer = Utility:Create("Frame", {
        Name = "Elements",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 25),
        Size = UDim2.new(1, -10, 0, 0),
        Parent = container,
    })
    
    local elementsLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = elementsContainer,
    })
    
    elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        elementsContainer.Size = UDim2.new(1, -10, 0, elementsLayout.AbsoluteContentSize.Y)
        container.Size = UDim2.new(1, -10, 0, elementsLayout.AbsoluteContentSize.Y + 30)
    end)
    
    section.Container = elementsContainer
    
    -- Funções da seção
    function section:AddButton(text, callback)
        return self:CreateButton(text, callback)
    end
    
    function section:AddToggle(text, default, callback)
        return self:CreateToggle(text, default, callback)
    end
    
    function section:AddSlider(text, min, max, default, callback)
        return self:CreateSlider(text, min, max, default, callback)
    end
    
    function section:AddDropdown(text, options, default, callback)
        return self:CreateDropdown(text, options, default, callback)
    end
    
    function section:AddTextbox(text, placeholder, callback)
        return self:CreateTextbox(text, placeholder, callback)
    end
    
    function section:AddLabel(text)
        return self:CreateLabel(text)
    end
    
    function section:AddColorPicker(text, default, callback)
        return self:CreateColorPicker(text, default, callback)
    end
    
    table.insert(tab.Sections, section)
    
    return section
end

-- Elementos da UI

function UILibrary:CreateButton(text, callback)
    local section = self
    local window = section.Tab.Window
    
    local button = Utility:Create("TextButton", {
        Name = "Button_" .. text,
        BackgroundColor3 = window.Theme.Primary,
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = window.Theme.Text,
        TextSize = 14,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = section.Container,
    })
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = window.Theme.Primary:lerp(Color3.new(1, 1, 1), 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = window.Theme.Primary
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then
            local success, err = pcall(callback)
            if not success then
                warn("Erro no callback do botão:", err)
            end
        end
    end)
    
    return button
end

function UILibrary:CreateToggle(text, default, callback)
    local section = self
    local window = section.Tab.Window
    local value = default or false
    
    local container = Utility:Create("Frame", {
        Name = "Toggle_" .. text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = section.Container,
    })
    
    local label = Utility:Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = window.Theme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -35, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local toggleBtn = Utility:Create("Frame", {
        Name = "Toggle",
        BackgroundColor3 = value and window.Theme.Success or window.Theme.Secondary,
        Size = UDim2.new(0, 30, 0, 20),
        Position = UDim2.new(1, -30, 0.5, -10),
        Parent = container,
    })
    
    local toggleIndicator = Utility:Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = window.Theme.Text,
        Position = value and UDim2.new(1, -16, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        Size = UDim2.new(0, 14, 0, 14),
        Parent = toggleBtn,
    })
    
    -- Interatividade
    local function setState(newValue)
        value = newValue
        toggleBtn.BackgroundColor3 = value and window.Theme.Success or window.Theme.Secondary
        toggleIndicator.Position = value and UDim2.new(1, -16, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        
        if callback then
            local success, err = pcall(callback, value)
            if not success then
                warn("Erro no callback do toggle:", err)
            end
        end
    end
    
    local button = Utility:Create("TextButton", {
        Name = "Hitbox",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Parent = container,
    })
    
    button.MouseButton1Click:Connect(function()
        setState(not value)
    end)
    
    -- Funções do toggle
    local toggleObj = {
        SetValue = setState,
        GetValue = function() return value end,
        Container = container,
    }
    
    return toggleObj
end

function UILibrary:CreateSlider(text, min, max, default, callback)
    local section = self
    local window = section.Tab.Window
    local value = default or min
    local dragging = false
    
    local container = Utility:Create("Frame", {
        Name = "Slider_" .. text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = section.Container,
    })
    
    local label = Utility:Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = window.Theme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.7, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local valueLabel = Utility:Create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(value),
        TextColor3 = window.Theme.Primary,
        TextSize = 14,
        Position = UDim2.new(0.7, 0, 0, 0),
        Size = UDim2.new(0.3, -5, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container,
    })
    
    local sliderBg = Utility:Create("Frame", {
        Name = "Background",
        BackgroundColor3 = window.Theme.Secondary,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(1, 0, 0, 5),
        Parent = container,
    })
    
    local sliderFill = Utility:Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = window.Theme.Primary,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        Parent = sliderBg,
    })
    
    local sliderButton = Utility:Create("TextButton", {
        Name = "Hitbox",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Parent = sliderBg,
    })
    
    local function updateFromMouse(input)
        local pos = input.Position.X - sliderBg.AbsolutePosition.X
        local percent = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
        local newValue = min + (max - min) * percent
        newValue = math.round(newValue * 100) / 100 -- Arredondar para 2 casas
        
        value = newValue
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(value)
        
        if callback then
            local success, err = pcall(callback, value)
            if not success then
                warn("Erro no callback do slider:", err)
            end
        end
    end
    
    sliderButton.MouseButton1Down:Connect(function(input)
        dragging = true
        updateFromMouse(input)
    end)
    
    sliderButton.MouseButton1Up:Connect(function()
        dragging = false
    end)
    
    sliderButton.MouseMoved:Connect(function(input)
        if dragging then
            updateFromMouse(input)
        end
    end)
    
    local sliderObj = {
        SetValue = function(newValue)
            newValue = math.clamp(newValue, min, max)
            value = newValue
            local percent = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = tostring(value)
        end,
        GetValue = function() return value end,
    }
    
    return sliderObj
end

function UILibrary:CreateDropdown(text, options, default, callback)
    local section = self
    local window = section.Tab.Window
    local open = false
    local selected = default or (options[1] and options[1].value or options[1])
    
    local container = Utility:Create("Frame", {
        Name = "Dropdown_" .. text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        ClipsDescendants = false,
        Parent = section.Container,
    })
    
    local label = Utility:Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = window.Theme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local dropdownBtn = Utility:Create("TextButton", {
        Name = "Dropdown",
        BackgroundColor3 = window.Theme.Secondary,
        Font = Enum.Font.Gotham,
        Text = type(selected) == "table" and selected.name or tostring(selected),
        TextColor3 = window.Theme.Text,
        TextSize = 14,
        Position = UDim2.new(0.4, 5, 0, 0),
        Size = UDim2.new(0.6, -5, 1, 0),
        Parent = container,
    })
    
    local dropdownList = Utility:Create("ScrollingFrame", {
        Name = "List",
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = window.Theme.Primary,
        Size = UDim2.new(0.6, -5, 0, 100),
        Position = UDim2.new(0.4, 5, 1, 5),
        ZIndex = 10,
        Parent = container,
    })
    
    local listLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = dropdownList,
    })
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    
    -- Preencher opções
    for _, option in ipairs(options) do
        local optionName = type(option) == "table" and option.name or tostring(option)
        local optionValue = type(option) == "table" and option.value or option
        
        local optionBtn = Utility:Create("TextButton", {
            Name = "Option_" .. optionName,
            BackgroundColor3 = window.Theme.Secondary,
            Font = Enum.Font.Gotham,
            Text = optionName,
            TextColor3 = window.Theme.Text,
            TextSize = 14,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = dropdownList,
        })
        
        optionBtn.MouseButton1Click:Connect(function()
            selected = optionValue
            dropdownBtn.Text = optionName
            dropdownList.Visible = false
            open = false
            
            if callback then
                local success, err = pcall(callback, selected)
                if not success then
                    warn("Erro no callback do dropdown:", err)
                end
            end
        end)
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        open = not open
        dropdownList.Visible = open
    end)
    
    -- Fechar ao clicar fora
    window.Connections[#window.Connections+1] = window.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = input.Position
            local absPos = dropdownList.AbsolutePosition
            local absSize = dropdownList.AbsoluteSize
            
            if open and not (pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and
               pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y) and
               not (pos.X >= dropdownBtn.AbsolutePosition.X and pos.X <= dropdownBtn.AbsolutePosition.X + dropdownBtn.AbsoluteSize.X and
               pos.Y >= dropdownBtn.AbsolutePosition.Y and pos.Y <= dropdownBtn.AbsolutePosition.Y + dropdownBtn.AbsoluteSize.Y) then
                dropdownList.Visible = false
                open = false
            end
        end
    end)
    
    local dropdownObj = {
        SetValue = function(value)
            selected = value
            for _, option in ipairs(options) do
                local optionValue = type(option) == "table" and option.value or option
                if optionValue == value then
                    dropdownBtn.Text = type(option) == "table" and option.name or tostring(option)
                    break
                end
            end
        end,
        GetValue = function() return selected end,
    }
    
    return dropdownObj
end

function UILibrary:CreateTextbox(text, placeholder, callback)
    local section = self
    local window = section.Tab.Window
    local focus = false
    
    local container = Utility:Create("Frame", {
        Name = "Textbox_" .. text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = section.Container,
    })
    
    local label = Utility:Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = window.Theme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local textbox = Utility:Create("TextBox", {
        Name = "Input",
        BackgroundColor3 = window.Theme.Secondary,
        Font = Enum.Font.Gotham,
        PlaceholderText = placeholder or "Digite algo...",
        PlaceholderColor3 = window.Theme.TextDisabled,
        Text = "",
        TextColor3 = window.Theme.Text,
        TextSize = 14,
        Position = UDim2.new(0.4, 5, 0, 0),
        Size = UDim2.new(0.6, -5, 1, 0),
        ClearTextOnFocus = false,
        Parent = container,
    })
    
    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            local success, err = pcall(callback, textbox.Text)
            if not success then
                warn("Erro no callback do textbox:", err)
            end
        end
    end)
    
    local textboxObj = {
        SetText = function(newText)
            textbox.Text = newText
        end,
        GetText = function() return textbox.Text end,
    }
    
    return textboxObj
end

function UILibrary:CreateLabel(text)
    local section = self
    local window = section.Tab.Window
    
    local label = Utility:Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = window.Theme.Text,
        TextSize = 14,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = section.Container,
    })
    
    local labelObj = {
        SetText = function(newText)
            label.Text = newText
        end,
    }
    
    return labelObj
end

function UILibrary:CreateColorPicker(text, default, callback)
    local section = self
    local window = section.Tab.Window
    local color = default or Color3.new(1, 0, 0)
    local open = false
    
    local container = Utility:Create("Frame", {
        Name = "ColorPicker_" .. text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        ClipsDescendants = false,
        Parent = section.Container,
    })
    
    local label = Utility:Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = window.Theme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local colorBtn = Utility:Create("Frame", {
        Name = "ColorButton",
        BackgroundColor3 = color,
        Position = UDim2.new(0.4, 5, 5, 0),
        Size = UDim2.new(0, 20, 0, 15),
        Parent = container,
    })
    
    local hitbox = Utility:Create("TextButton", {
        Name = "Hitbox",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(0, 20, 0, 15),
        Parent = colorBtn,
    })
    
    local pickerContainer = Utility:Create("Frame", {
        Name = "Picker",
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Visible = false,
        Size = UDim2.new(0, 150, 0, 150),
        Position = UDim2.new(0.4, 5, 1, 5),
        ZIndex = 10,
        Parent = container,
    })
    
    Utility:ApplyShadow(pickerContainer, 0.5)
    
    -- Área de seleção de cor (gradiente simplificado)
    local hueGradient = Utility:Create("ImageLabel", {
        Name = "HueGradient",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Image = "rbxassetid://10955786730", -- Gradiente de matiz
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        Parent = pickerContainer,
    })
    
    local selector = Utility:Create("Frame", {
        Name = "Selector",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 2,
        BorderColor3 = Color3.new(0, 0, 0),
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0.5, -5, 0.5, -5),
        Parent = hueGradient,
    })
    
    hitbox.MouseButton1Click:Connect(function()
        open = not open
        pickerContainer.Visible = open
    end)
    
    -- Fechar ao clicar fora
    window.Connections[#window.Connections+1] = window.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = input.Position
            local absPos = pickerContainer.AbsolutePosition
            local absSize = pickerContainer.AbsoluteSize
            
            if open and not (pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and
               pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y) and
               not (pos.X >= colorBtn.AbsolutePosition.X and pos.X <= colorBtn.AbsolutePosition.X + colorBtn.AbsoluteSize.X and
               pos.Y >= colorBtn.AbsolutePosition.Y and pos.Y <= colorBtn.AbsolutePosition.Y + colorBtn.AbsoluteSize.Y) then
                pickerContainer.Visible = false
                open = false
            end
        end
    end)
    
    local colorPickerObj = {
        SetColor = function(newColor)
            color = newColor
            colorBtn.BackgroundColor3 = color
        end,
        GetColor = function() return color end,
    }
    
    return colorPickerObj
end

-- Notificação
function UILibrary:Notify(config)
    config = config or {}
    
    local notification = {
        Title = config.Title or "Notificação",
        Content = config.Content or "",
        Duration = config.Duration or 3,
        Type = config.Type or "info", -- info, success, error, warning
    }
    
    local colors = {
        info = self.Theme.Primary,
        success = self.Theme.Success,
        error = self.Theme.Danger,
        warning = self.Theme.Warning,
    }
    
    local frame = Utility:Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -310, 1, -80),
        Size = UDim2.new(0, 300, 0, 70),
        Parent = self.ScreenGui,
    })
    
    Utility:ApplyShadow(frame, 0.5)
    
    local colorBar = Utility:Create("Frame", {
        Name = "ColorBar",
        BackgroundColor3 = colors[notification.Type] or colors.info,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 5, 1, 0),
        Parent = frame,
    })
    
    local title = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = notification.Title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    
    local content = Utility:Create("TextLabel", {
        Name = "Content",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = notification.Content,
        TextColor3 = self.Theme.TextDisabled,
        TextSize = 12,
        Position = UDim2.new(0, 10, 0, 25),
        Size = UDim2.new(1, -20, 0, 35),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = frame,
    })
    
    -- Animação de entrada
    frame.Position = UDim2.new(1, 10, 1, -80)
    frame:TweenPosition(UDim2.new(1, -310, 1, -80), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    
    -- Auto destruir
    task.wait(notification.Duration)
    
    frame:TweenPosition(UDim2.new(1, 10, 1, -80), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true, function()
        frame:Destroy()
    end)
end

return UILibrary
