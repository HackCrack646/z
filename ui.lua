--[[
    SimpleUI v1.0
    UI Library mínima e funcional
]]

local SimpleUI = {}
SimpleUI.__index = SimpleUI

-- Serviços
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Cores padrão (fácil de modificar)
local Colors = {
    Bg = Color3.fromRGB(30, 30, 30),
    Bar = Color3.fromRGB(45, 45, 45),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Border = Color3.fromRGB(60, 60, 60)
}

-- Função auxiliar para criar objetos
local function new(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

-- Função para tornar arrastável
local function makeDraggable(frame, area)
    local dragging, startPos, startMouse
    
    area.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = frame.Position
            startMouse = input.Position
            input:Capture()
        end
    end)
    
    area.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    area.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Cria uma janela
function SimpleUI:Window(title, size)
    size = size or UDim2.new(0, 500, 0, 350)
    
    local win = {
        Title = title,
        Size = size,
        Tabs = {},
        CurrentTab = nil,
        Elements = {},
        Connections = {}
    }
    setmetatable(win, self)
    
    -- GUI Principal
    win.Gui = new("ScreenGui", {
        Name = "SimpleUI_" .. title,
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Janela
    win.Main = new("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = Colors.Bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = win.Gui
    })
    
    -- Barra de título
    win.TitleBar = new("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Colors.Bar,
        BorderSizePixel = 0,
        Parent = win.Main
    })
    
    win.TitleLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "  " .. title,
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.SourceSansBold,
        Size = UDim2.new(1, -30, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = win.TitleBar
    })
    
    -- Botão fechar
    win.CloseBtn = new("TextButton", {
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Colors.Text,
        TextSize = 18,
        Font = Enum.Font.SourceSansBold,
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        Parent = win.TitleBar
    })
    
    win.CloseBtn.MouseButton1Click:Connect(function()
        win.Gui:Destroy()
    end)
    
    -- Tornar arrastável
    makeDraggable(win.Main, win.TitleBar)
    
    -- Container de abas
    win.TabContainer = new("Frame", {
        BackgroundColor3 = Colors.Bar,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 30),
        Parent = win.Main
    })
    
    win.TabList = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Parent = win.TabContainer
    })
    
    -- Layout horizontal para abas
    win.TabLayout = new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = win.TabList
    })
    
    -- Container de conteúdo
    win.Content = new("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 5, 0, 65),
        Size = UDim2.new(1, -10, 1, -70),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        Parent = win.Main
    })
    
    win.ContentLayout = new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = win.Content
    })
    
    win.ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        win.Content.CanvasSize = UDim2.new(0, 0, 0, win.ContentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    return win
end

-- Cria uma aba
function SimpleUI:Tab(name)
    local win = self
    local tab = {
        Window = win,
        Name = name,
        Sections = {}
    }
    
    -- Botão da aba
    tab.Button = new("TextButton", {
        BackgroundColor3 = Colors.Bg,
        Text = "  " .. name .. "  ",
        TextColor3 = Colors.TextDisabled,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Size = UDim2.new(0, #name * 10 + 20, 1, -5),
        Position = UDim2.new(0, 0, 0, 2),
        Parent = win.TabList
    })
    
    -- Container da aba
    tab.Container = new("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        Parent = win.Content
    })
    
    tab.Layout = new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = tab.Container
    })
    
    tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.Container.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Selecionar aba
    tab.Button.MouseButton1Click:Connect(function()
        if win.CurrentTab then
            win.CurrentTab.Button.TextColor3 = Colors.TextDisabled
            win.CurrentTab.Container.Visible = false
        end
        win.CurrentTab = tab
        tab.Button.TextColor3 = Colors.Accent
        tab.Container.Visible = true
    end)
    
    -- Primeira aba fica selecionada
    if #win.Tabs == 0 then
        win.CurrentTab = tab
        tab.Button.TextColor3 = Colors.Accent
        tab.Container.Visible = true
    end
    
    table.insert(win.Tabs, tab)
    return tab
end

-- Cria uma seção
function SimpleUI:Section(title)
    local tab = self
    local win = tab.Window
    
    local section = {
        Tab = tab,
        Window = win,
        Title = title
    }
    
    -- Frame da seção
    section.Frame = new("Frame", {
        BackgroundColor3 = Colors.Bar,
        Size = UDim2.new(1, -10, 0, 40),
        Parent = tab.Container
    })
    
    -- Título
    section.TitleLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "  " .. title,
        TextColor3 = Colors.Accent,
        TextSize = 14,
        Font = Enum.Font.SourceSansBold,
        Size = UDim2.new(1, 0, 0, 30),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section.Frame
    })
    
    -- Container de elementos
    section.ElementContainer = new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 30),
        Size = UDim2.new(1, -10, 0, 0),
        Parent = section.Frame
    })
    
    section.ElementLayout = new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = section.ElementContainer
    })
    
    section.ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.ElementContainer.Size = UDim2.new(1, -10, 0, section.ElementLayout.AbsoluteContentSize.Y)
        section.Frame.Size = UDim2.new(1, -10, 0, section.ElementLayout.AbsoluteContentSize.Y + 40)
    end)
    
    return section
end

-- Botão
function SimpleUI:Button(text, callback)
    local section = self
    
    local btn = new("TextButton", {
        BackgroundColor3 = Colors.Accent,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = section.ElementContainer
    })
    
    btn.MouseButton1Click:Connect(function()
        local success, err = pcall(callback or function() end)
        if not success then warn("Button error:", err) end
    end)
    
    return btn
end

-- Toggle
function SimpleUI:Toggle(text, default, callback)
    local section = self
    local value = default or false
    
    local frame = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = section.ElementContainer
    })
    
    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Size = UDim2.new(1, -40, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local toggle = new("Frame", {
        BackgroundColor3 = value and Colors.Accent or Colors.Border,
        Size = UDim2.new(0, 30, 0, 15),
        Position = UDim2.new(1, -30, 0.5, -7.5),
        Parent = frame
    })
    
    local circle = new("Frame", {
        BackgroundColor3 = Colors.Text,
        Size = UDim2.new(0, 11, 0, 11),
        Position = value and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5),
        Parent = toggle
    })
    
    local hitbox = new("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Parent = frame
    })
    
    local function set(newValue)
        value = newValue
        toggle.BackgroundColor3 = value and Colors.Accent or Colors.Border
        circle.Position = value and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5)
        if callback then
            local success, err = pcall(callback, value)
            if not success then warn("Toggle error:", err) end
        end
    end
    
    hitbox.MouseButton1Click:Connect(function()
        set(not value)
    end)
    
    return {Set = set, Get = function() return value end}
end

-- Slider
function SimpleUI:Slider(text, min, max, default, callback)
    local section = self
    local value = default or min
    local dragging = false
    
    local frame = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 35),
        Parent = section.ElementContainer
    })
    
    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = text .. ": " .. value,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Size = UDim2.new(1, 0, 0, 15),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local bar = new("Frame", {
        BackgroundColor3 = Colors.Border,
        Size = UDim2.new(1, 0, 0, 5),
        Position = UDim2.new(0, 0, 1, -10),
        Parent = frame
    })
    
    local fill = new("Frame", {
        BackgroundColor3 = Colors.Accent,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        Parent = bar
    })
    
    local button = new("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Parent = bar
    })
    
    local function update(input)
        local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * percent)
        fill.Size = UDim2.new(percent, 0, 1, 0)
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
    
    return {Set = function(v) value = math.clamp(v, min, max); fill.Size = UDim2.new((value-min)/(max-min),0,1,0); label.Text = text..": "..value end}
end

-- Dropdown
function SimpleUI:Dropdown(text, options, default, callback)
    local section = self
    local open = false
    local selected = default or options[1]
    
    local frame = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = section.ElementContainer
    })
    
    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Size = UDim2.new(0.4, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local btn = new("TextButton", {
        BackgroundColor3 = Colors.Border,
        Text = selected,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Position = UDim2.new(0.4, 5, 0, 0),
        Size = UDim2.new(0.6, -5, 1, 0),
        Parent = frame
    })
    
    local list = new("ScrollingFrame", {
        BackgroundColor3 = Colors.Bg,
        BorderSizePixel = 0,
        Visible = false,
        Size = UDim2.new(0.6, -5, 0, 80),
        Position = UDim2.new(0.4, 5, 1, 5),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        Parent = frame
    })
    
    local listLayout = new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = list
    })
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    
    for _, opt in ipairs(options) do
        local optBtn = new("TextButton", {
            BackgroundColor3 = Colors.Border,
            Text = opt,
            TextColor3 = Colors.Text,
            TextSize = 14,
            Font = Enum.Font.SourceSans,
            Size = UDim2.new(1, 0, 0, 20),
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
    
    return {Set = function(v) selected = v; btn.Text = v end, Get = function() return selected end}
end

-- Textbox
function SimpleUI:Textbox(text, placeholder, callback)
    local section = self
    
    local frame = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = section.ElementContainer
    })
    
    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Size = UDim2.new(0.4, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local box = new("TextBox", {
        BackgroundColor3 = Colors.Border,
        PlaceholderText = placeholder or "Digite...",
        PlaceholderColor3 = Color3.fromRGB(150,150,150),
        Text = "",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Position = UDim2.new(0.4, 5, 0, 0),
        Size = UDim2.new(0.6, -5, 1, 0),
        ClearTextOnFocus = false,
        Parent = frame
    })
    
    box.FocusLost:Connect(function(enter)
        if enter and callback then
            local success, err = pcall(callback, box.Text)
            if not success then warn("Textbox error:", err) end
        end
    end)
    
    return {Set = function(t) box.Text = t end, Get = function() return box.Text end}
end

-- Label
function SimpleUI:Label(text)
    local section = self
    
    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section.ElementContainer
    })
    
    return {Set = function(t) label.Text = t end}
end

-- Keybind
function SimpleUI:Keybind(text, default, callback)
    local section = self
    local key = default or Enum.KeyCode.F
    local listening = false
    
    local frame = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = section.ElementContainer
    })
    
    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Size = UDim2.new(0.4, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local btn = new("TextButton", {
        BackgroundColor3 = Colors.Border,
        Text = key.Name,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        Position = UDim2.new(0.4, 5, 0, 0),
        Size = UDim2.new(0.6, -5, 1, 0),
        Parent = frame
    })
    
    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "..."
    end)
    
    local conn = UserInputService.InputBegan:Connect(function(input)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            key = input.KeyCode
            btn.Text = key.Name
            if callback then
                local success, err = pcall(callback, key)
                if not success then warn("Keybind error:", err) end
            end
        end
    end)
    
    return {Set = function(k) key = k; btn.Text = k.Name end}
end

return SimpleUI
