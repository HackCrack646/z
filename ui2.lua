--[[
    Nexus UI Library v2.0
    Um framework UI completo e sem bugs
    Desenvolvido para executors Roblox
--]]

local NexusUI = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Constantes e Configurações
local CONFIG = {
    THEMES = {
        default = {
            primary = Color3.fromRGB(30, 144, 255),
            secondary = Color3.fromRGB(25, 25, 25),
            background = Color3.fromRGB(20, 20, 20),
            foreground = Color3.fromRGB(35, 35, 35),
            text = Color3.fromRGB(255, 255, 255),
            subtext = Color3.fromRGB(150, 150, 150),
            success = Color3.fromRGB(0, 255, 0),
            error = Color3.fromRGB(255, 0, 0),
            warning = Color3.fromRGB(255, 255, 0)
        },
        dark = {
            primary = Color3.fromRGB(255, 70, 100),
            secondary = Color3.fromRGB(30, 30, 30),
            background = Color3.fromRGB(15, 15, 15),
            foreground = Color3.fromRGB(40, 40, 40),
            text = Color3.fromRGB(240, 240, 240),
            subtext = Color3.fromRGB(140, 140, 140),
            success = Color3.fromRGB(0, 200, 100),
            error = Color3.fromRGB(200, 50, 50),
            warning = Color3.fromRGB(255, 180, 50)
        },
        light = {
            primary = Color3.fromRGB(0, 120, 255),
            secondary = Color3.fromRGB(245, 245, 245),
            background = Color3.fromRGB(255, 255, 255),
            foreground = Color3.fromRGB(230, 230, 230),
            text = Color3.fromRGB(20, 20, 20),
            subtext = Color3.fromRGB(80, 80, 80),
            success = Color3.fromRGB(0, 180, 0),
            error = Color3.fromRGB(220, 50, 50),
            warning = Color3.fromRGB(230, 160, 0)
        },
        purple = {
            primary = Color3.fromRGB(150, 80, 255),
            secondary = Color3.fromRGB(40, 30, 50),
            background = Color3.fromRGB(25, 20, 30),
            foreground = Color3.fromRGB(55, 45, 65),
            text = Color3.fromRGB(255, 255, 255),
            subtext = Color3.fromRGB(170, 150, 190),
            success = Color3.fromRGB(80, 255, 120),
            error = Color3.fromRGB(255, 70, 90),
            warning = Color3.fromRGB(255, 200, 70)
        },
        ocean = {
            primary = Color3.fromRGB(0, 200, 200),
            secondary = Color3.fromRGB(20, 50, 60),
            background = Color3.fromRGB(10, 35, 45),
            foreground = Color3.fromRGB(30, 70, 85),
            text = Color3.fromRGB(255, 255, 255),
            subtext = Color3.fromRGB(130, 190, 210),
            success = Color3.fromRGB(80, 255, 150),
            error = Color3.fromRGB(255, 100, 100),
            warning = Color3.fromRGB(255, 220, 80)
        }
    },
    
    ANIMATIONS = {
        duration = 0.2,
        easingStyle = Enum.EasingStyle.Quad,
        easingDirection = Enum.EasingDirection.Out
    },
    
    FONTS = {
        regular = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular),
        medium = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium),
        bold = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold),
        monospace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular)
    },
    
    SIZES = {
        button = UDim2.new(0, 140, 0, 32),
        toggle = UDim2.new(0, 140, 0, 32),
        slider = UDim2.new(0, 140, 0, 40),
        dropdown = UDim2.new(0, 140, 0, 32),
        textbox = UDim2.new(0, 140, 0, 32),
        label = UDim2.new(0, 140, 0, 20),
        keybind = UDim2.new(0, 140, 0, 32)
    }
}

-- Sistema de Notificações
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(parent)
    local self = setmetatable({}, NotificationSystem)
    
    self.Container = Instance.new("Frame")
    self.Container.Name = "NotificationContainer"
    self.Container.Size = UDim2.new(0, 300, 1, -20)
    self.Container.Position = UDim2.new(1, -320, 0, 10)
    self.Container.BackgroundTransparency = 1
    self.Container.ClipsDescendants = true
    self.Container.Parent = parent
    
    self.ListLayout = Instance.new("UIListLayout")
    self.ListLayout.Padding = UDim.new(0, 8)
    self.ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    self.ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    self.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.ListLayout.Parent = self.Container
    
    self.ActiveNotifications = {}
    
    return self
end

function NotificationSystem:Notify(title, message, duration, type, callback)
    duration = duration or 5
    type = type or "info"
    callback = callback or function() end
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 280, 0, 0)
    notification.BackgroundColor3 = CONFIG.THEMES.default.foreground
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notification
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.THEMES.default.primary
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = notification
    
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Image = getIconForType(type)
    icon.ImageColor3 = getColorForType(type)
    icon.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -44, 0, 20)
    titleLabel.Position = UDim2.new(0, 44, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.FontFace = CONFIG.FONTS.medium
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = CONFIG.THEMES.default.text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 0)
    messageLabel.Position = UDim2.new(0, 10, 0, 34)
    messageLabel.BackgroundTransparency = 1
    messageLabel.FontFace = CONFIG.FONTS.regular
    messageLabel.TextSize = 12
    messageLabel.TextColor3 = CONFIG.THEMES.default.subtext
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Text = message
    messageLabel.Parent = notification
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = CONFIG.THEMES.default.primary
    progressBar.BorderSizePixel = 0
    progressBar.Parent = notification
    
    local textSize = messageLabel.TextBounds.Y
    messageLabel.Size = UDim2.new(1, -20, 0, textSize)
    notification.Size = UDim2.new(0, 280, 0, textSize + 48)
    
    table.insert(self.ActiveNotifications, notification)
    
    local tweenInfo = TweenInfo.new(
        0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    notification.Position = UDim2.new(1, 50, 0, 0)
    
    local enterTween = TweenService:Create(notification, tweenInfo, {
        Position = UDim2.new(0, 0, 0, 0)
    })
    enterTween:Play()
    
    local progressTween = TweenService:Create(progressBar, TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.In
    ), {
        Size = UDim2.new(0, 0, 0, 3)
    })
    progressTween:Play()
    
    task.delay(duration, function()
        if notification and notification.Parent then
            local exitTween = TweenService:Create(notification, tweenInfo, {
                Position = UDim2.new(1, 50, 0, 0),
                BackgroundTransparency = 1
            })
            exitTween:Play()
            
            exitTween.Completed:Connect(function()
                if notification and notification.Parent then
                    notification:Destroy()
                    for i, v in ipairs(self.ActiveNotifications) do
                        if v == notification then
                            table.remove(self.ActiveNotifications, i)
                            break
                        end
                    end
                    callback()
                end
            end)
        end
    end)
    
    return notification
end

-- Sistema de Abas
local TabSystem = {}
TabSystem.__index = TabSystem

function TabSystem.new(parent, theme, title)
    local self = setmetatable({}, TabSystem)
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "TabContainer"
    self.MainFrame.Size = UDim2.new(1, -20, 1, -70)
    self.MainFrame.Position = UDim2.new(0, 10, 0, 60)
    self.MainFrame.BackgroundColor3 = theme.background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = parent
    
    self.Corner = Instance.new("UICorner")
    self.Corner.CornerRadius = UDim.new(0, 8)
    self.Corner.Parent = self.MainFrame
    
    self.Stroke = Instance.new("UIStroke")
    self.Stroke.Color = theme.secondary
    self.Stroke.Thickness = 1
    self.Stroke.Parent = self.MainFrame
    
    self.TabButtons = {}
    self.Tabs = {}
    self.ActiveTab = nil
    self.Theme = theme
    
    self:CreateHeader(title)
    self:CreateTabButtons()
    
    return self
end

function TabSystem:CreateHeader(title)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = self.Theme.secondary
    header.BorderSizePixel = 0
    header.Parent = self.MainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.FontFace = CONFIG.FONTS.bold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = self.Theme.text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = header
    
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Position = UDim2.new(1, -30, 0, 8)
    closeButton.BackgroundTransparency = 1
    closeButton.Image = "rbxassetid://10747317889"
    closeButton.ImageColor3 = self.Theme.subtext
    closeButton.Parent = header
    
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {
            ImageColor3 = self.Theme.error
        }):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {
            ImageColor3 = self.Theme.subtext
        }):Play()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        self.MainFrame.Parent.Parent.Visible = false
    end)
end

function TabSystem:CreateTabButtons()
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "TabButtons"
    buttonContainer.Size = UDim2.new(1, 0, 0, 40)
    buttonContainer.Position = UDim2.new(0, 0, 0, 40)
    buttonContainer.BackgroundColor3 = self.Theme.secondary
    buttonContainer.BorderSizePixel = 0
    buttonContainer.Parent = self.MainFrame
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 8)
    containerCorner.Parent = buttonContainer
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 5)
    layout.Parent = buttonContainer
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = buttonContainer
    
    self.TabButtonContainer = buttonContainer
end

function TabSystem:AddTab(name, icon)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(0, 100, 0, 30)
    tabButton.BackgroundColor3 = self.Theme.foreground
    tabButton.BackgroundTransparency = 0.3
    tabButton.BorderSizePixel = 0
    tabButton.FontFace = CONFIG.FONTS.medium
    tabButton.TextSize = 14
    tabButton.TextColor3 = self.Theme.text
    tabButton.Text = name
    tabButton.Parent = self.TabButtonContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = tabButton
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, -20, 1, -90)
    tabContent.Position = UDim2.new(0, 10, 0, 90)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = self.Theme.primary
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = false
    tabContent.Parent = self.MainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = tabContent
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.Parent = tabContent
    
    table.insert(self.Tabs, {
        name = name,
        button = tabButton,
        content = tabContent,
        elements = {}
    })
    
    if #self.Tabs == 1 then
        self:SwitchTab(1)
    end
    
    tabButton.MouseButton1Click:Connect(function()
        for i, tab in ipairs(self.Tabs) do
            if tab.name == name then
                self:SwitchTab(i)
                break
            end
        end
    end)
    
    return tabContent
end

function TabSystem:SwitchTab(index)
    if self.ActiveTab then
        self.ActiveTab.button.BackgroundTransparency = 0.3
        self.ActiveTab.content.Visible = false
    end
    
    self.ActiveTab = self.Tabs[index]
    self.ActiveTab.button.BackgroundTransparency = 0
    self.ActiveTab.content.Visible = true
end

-- Classe Base para Elementos UI
local UIElement = {}
UIElement.__index = UIElement

function UIElement.new(parent, theme, config)
    local self = setmetatable({}, UIElement)
    
    self.Frame = Instance.new("Frame")
    self.Frame.BackgroundColor3 = theme.foreground
    self.Frame.BorderSizePixel = 0
    self.Frame.Parent = parent
    
    self.Corner = Instance.new("UICorner")
    self.Corner.CornerRadius = UDim.new(0, 6)
    self.Corner.Parent = self.Frame
    
    self.Theme = theme
    self.Config = config
    self.Enabled = true
    self.Visible = true
    
    return self
end

function UIElement:SetPosition(position)
    self.Frame.Position = position
end

function UIElement:SetSize(size)
    self.Frame.Size = size
end

function UIElement:SetVisible(visible)
    self.Visible = visible
    self.Frame.Visible = visible
end

function UIElement:SetEnabled(enabled)
    self.Enabled = enabled
    self.Frame.Active = enabled
    self.Frame.Selectable = enabled
end

function UIElement:Destroy()
    self.Frame:Destroy()
end

-- Botão
local Button = setmetatable({}, UIElement)
Button.__index = Button

function Button.new(parent, theme, text, callback)
    local self = UIElement.new(parent, theme, {})
    setmetatable(self, Button)
    
    self.Frame.Size = CONFIG.SIZES.button
    self.Frame.BackgroundColor3 = theme.primary
    
    self.TextLabel = Instance.new("TextLabel")
    self.TextLabel.Size = UDim2.new(1, -20, 1, 0)
    self.TextLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TextLabel.BackgroundTransparency = 1
    self.TextLabel.FontFace = CONFIG.FONTS.medium
    self.TextLabel.TextSize = 14
    self.TextLabel.TextColor3 = theme.text
    self.TextLabel.Text = text
    self.TextLabel.Parent = self.Frame
    
    self.Callback = callback or function() end
    
    self.Frame.MouseButton1Click:Connect(function()
        if self.Enabled then
            self:Click()
        end
    end)
    
    self.Frame.MouseEnter:Connect(function()
        if self.Enabled then
            self:Hover(true)
        end
    end)
    
    self.Frame.MouseLeave:Connect(function()
        if self.Enabled then
            self:Hover(false)
        end
    end)
    
    return self
end

function Button:Click()
    local success, err = pcall(self.Callback)
    if not success then
        warn("Button callback error:", err)
    end
    
    TweenService:Create(self.Frame, TweenInfo.new(0.1), {
        BackgroundColor3 = self.Theme.primary:Lerp(self.Theme.text, 0.3)
    }):Play()
    
    task.delay(0.1, function()
        if self.Frame and self.Frame.Parent then
            TweenService:Create(self.Frame, TweenInfo.new(0.1), {
                BackgroundColor3 = self.Theme.primary
            }):Play()
        end
    end)
end

function Button:Hover(state)
    TweenService:Create(self.Frame, TweenInfo.new(0.2), {
        BackgroundColor3 = state and self.Theme.primary:Lerp(self.Theme.text, 0.2) or self.Theme.primary
    }):Play()
end

function Button:SetText(text)
    self.TextLabel.Text = text
end

-- Toggle
local Toggle = setmetatable({}, UIElement)
Toggle.__index = Toggle

function Toggle.new(parent, theme, text, default, callback)
    local self = UIElement.new(parent, theme, {})
    setmetatable(self, Toggle)
    
    self.Frame.Size = CONFIG.SIZES.toggle
    self.Frame.BackgroundColor3 = theme.foreground
    
    self.TextLabel = Instance.new("TextLabel")
    self.TextLabel.Size = UDim2.new(1, -50, 1, 0)
    self.TextLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TextLabel.BackgroundTransparency = 1
    self.TextLabel.FontFace = CONFIG.FONTS.regular
    self.TextLabel.TextSize = 14
    self.TextLabel.TextColor3 = theme.text
    self.TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TextLabel.Text = text
    self.TextLabel.Parent = self.Frame
    
    self.ToggleFrame = Instance.new("Frame")
    self.ToggleFrame.Size = UDim2.new(0, 30, 0, 16)
    self.ToggleFrame.Position = UDim2.new(1, -40, 0.5, -8)
    self.ToggleFrame.BackgroundColor3 = theme.background
    self.ToggleFrame.BorderSizePixel = 0
    self.ToggleFrame.Parent = self.Frame
    
    self.ToggleCorner = Instance.new("UICorner")
    self.ToggleCorner.CornerRadius = UDim.new(1, 0)
    self.ToggleCorner.Parent = self.ToggleFrame
    
    self.ToggleIndicator = Instance.new("Frame")
    self.ToggleIndicator.Size = UDim2.new(0, 12, 0, 12)
    self.ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -6)
    self.ToggleIndicator.BackgroundColor3 = theme.subtext
    self.ToggleIndicator.BorderSizePixel = 0
    self.ToggleIndicator.Parent = self.ToggleFrame
    
    self.IndicatorCorner = Instance.new("UICorner")
    self.IndicatorCorner.CornerRadius = UDim.new(1, 0)
    self.IndicatorCorner.Parent = self.ToggleIndicator
    
    self.Value = default or false
    self.Callback = callback or function() end
    
    self:SetValue(self.Value)
    
    self.Frame.MouseButton1Click:Connect(function()
        if self.Enabled then
            self:Toggle()
        end
    end)
    
    return self
end

function Toggle:Toggle()
    self:SetValue(not self.Value)
    local success, err = pcall(self.Callback, self.Value)
    if not success then
        warn("Toggle callback error:", err)
    end
end

function Toggle:SetValue(value)
    self.Value = value
    
    if value then
        TweenService:Create(self.ToggleFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Theme.primary
        }):Play()
        
        TweenService:Create(self.ToggleIndicator, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Theme.text,
            Position = UDim2.new(1, -14, 0.5, -6)
        }):Play()
    else
        TweenService:Create(self.ToggleFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Theme.background
        }):Play()
        
        TweenService:Create(self.ToggleIndicator, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Theme.subtext,
            Position = UDim2.new(0, 2, 0.5, -6)
        }):Play()
    end
end

-- Slider
local Slider = setmetatable({}, UIElement)
Slider.__index = Slider

function Slider.new(parent, theme, text, min, max, default, callback)
    local self = UIElement.new(parent, theme, {})
    setmetatable(self, Slider)
    
    self.Frame.Size = CONFIG.SIZES.slider
    self.Frame.BackgroundColor3 = theme.foreground
    
    self.TextLabel = Instance.new("TextLabel")
    self.TextLabel.Size = UDim2.new(1, -20, 0, 20)
    self.TextLabel.Position = UDim2.new(0, 10, 0, 5)
    self.TextLabel.BackgroundTransparency = 1
    self.TextLabel.FontFace = CONFIG.FONTS.regular
    self.TextLabel.TextSize = 14
    self.TextLabel.TextColor3 = theme.text
    self.TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TextLabel.Text = text
    self.TextLabel.Parent = self.Frame
    
    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    self.ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    self.ValueLabel.BackgroundTransparency = 1
    self.ValueLabel.FontFace = CONFIG.FONTS.medium
    self.ValueLabel.TextSize = 12
    self.ValueLabel.TextColor3 = theme.primary
    self.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.ValueLabel.Text = tostring(default or min)
    self.ValueLabel.Parent = self.Frame
    
    self.SliderFrame = Instance.new("Frame")
    self.SliderFrame.Size = UDim2.new(1, -20, 0, 4)
    self.SliderFrame.Position = UDim2.new(0, 10, 0, 30)
    self.SliderFrame.BackgroundColor3 = theme.background
    self.SliderFrame.BorderSizePixel = 0
    self.SliderFrame.Parent = self.Frame
    
    self.SliderCorner = Instance.new("UICorner")
    self.SliderCorner.CornerRadius = UDim.new(1, 0)
    self.SliderCorner.Parent = self.SliderFrame
    
    self.SliderFill = Instance.new("Frame")
    self.SliderFill.Size = UDim2.new(0, 0, 1, 0)
    self.SliderFill.BackgroundColor3 = theme.primary
    self.SliderFill.BorderSizePixel = 0
    self.SliderFill.Parent = self.SliderFrame
    
    self.FillCorner = Instance.new("UICorner")
    self.FillCorner.CornerRadius = UDim.new(1, 0)
    self.FillCorner.Parent = self.SliderFill
    
    self.SliderButton = Instance.new("ImageButton")
    self.SliderButton.Size = UDim2.new(0, 16, 0, 16)
    self.SliderButton.Position = UDim2.new(0, -8, 0.5, -8)
    self.SliderButton.BackgroundTransparency = 1
    self.SliderButton.Image = "rbxassetid://3570695787"
    self.SliderButton.ImageColor3 = theme.primary
    self.SliderButton.ScaleType = Enum.ScaleType.Fit
    self.SliderButton.Parent = self.SliderFill
    
    self.Min = min or 0
    self.Max = max or 100
    self.Value = default or min or 0
    self.Callback = callback or function() end
    self.Dragging = false
    
    self:SetValue(self.Value)
    
    self.SliderButton.MouseButton1Down:Connect(function()
        self.Dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if self.Dragging and self.Enabled then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = self.SliderFrame.AbsolutePosition
            local sliderSize = self.SliderFrame.AbsoluteSize.X
            local relativePos = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize)
            local percent = relativePos / sliderSize
            local value = self.Min + (self.Max - self.Min) * percent
            
            self:SetValue(value)
            
            local success, err = pcall(self.Callback, self.Value)
            if not success then
                warn("Slider callback error:", err)
            end
        end
    end)
    
    return self
end

function Slider:SetValue(value)
    self.Value = math.clamp(value, self.Min, self.Max)
    local percent = (self.Value - self.Min) / (self.Max - self.Min)
    
    self.SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    self.ValueLabel.Text = string.format("%.1f", self.Value)
end

-- Dropdown
local Dropdown = setmetatable({}, UIElement)
Dropdown.__index = Dropdown

function Dropdown.new(parent, theme, text, options, default, callback)
    local self = UIElement.new(parent, theme, {})
    setmetatable(self, Dropdown)
    
    self.Frame.Size = CONFIG.SIZES.dropdown
    self.Frame.BackgroundColor3 = theme.foreground
    self.Frame.ClipsDescendants = true
    
    self.TextLabel = Instance.new("TextLabel")
    self.TextLabel.Size = UDim2.new(1, -50, 1, 0)
    self.TextLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TextLabel.BackgroundTransparency = 1
    self.TextLabel.FontFace = CONFIG.FONTS.regular
    self.TextLabel.TextSize = 14
    self.TextLabel.TextColor3 = theme.text
    self.TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TextLabel.Text = text
    self.TextLabel.Parent = self.Frame
    
    self.SelectedLabel = Instance.new("TextLabel")
    self.SelectedLabel.Size = UDim2.new(0, 100, 1, 0)
    self.SelectedLabel.Position = UDim2.new(1, -110, 0, 0)
    self.SelectedLabel.BackgroundTransparency = 1
    self.SelectedLabel.FontFace = CONFIG.FONTS.medium
    self.SelectedLabel.TextSize = 12
    self.SelectedLabel.TextColor3 = theme.primary
    self.SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.SelectedLabel.Text = default or options[1] or "None"
    self.SelectedLabel.Parent = self.Frame
    
    self.Arrow = Instance.new("ImageLabel")
    self.Arrow.Size = UDim2.new(0, 16, 0, 16)
    self.Arrow.Position = UDim2.new(1, -25, 0.5, -8)
    self.Arrow.BackgroundTransparency = 1
    self.Arrow.Image = "rbxassetid://6031094678"
    self.Arrow.ImageColor3 = theme.subtext
    self.Arrow.Rotation = 0
    self.Arrow.Parent = self.Frame
    
    self.DropdownFrame = Instance.new("Frame")
    self.DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
    self.DropdownFrame.Position = UDim2.new(0, 0, 1, 0)
    self.DropdownFrame.BackgroundColor3 = theme.background
    self.DropdownFrame.BorderSizePixel = 0
    self.DropdownFrame.ClipsDescendants = true
    self.DropdownFrame.Parent = self.Frame
    
    self.DropdownCorner = Instance.new("UICorner")
    self.DropdownCorner.CornerRadius = UDim.new(0, 6)
    self.DropdownCorner.Parent = self.DropdownFrame
    
    self.Options = options or {}
    self.Opened = false
    self.Selected = default or options[1] or nil
    self.Callback = callback or function() end
    
    self.Frame.MouseButton1Click:Connect(function()
        if self.Enabled then
            self:Toggle()
        end
    end)
    
    return self
end

function Dropdown:Toggle()
    self.Opened = not self.Opened
    
    if self.Opened then
        self.Arrow.Rotation = 180
        
        for i, option in ipairs(self.Options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Name = "Option_" .. option
            optionButton.Size = UDim2.new(1, -10, 0, 30)
            optionButton.Position = UDim2.new(0, 5, 0, 5 + (i - 1) * 35)
            optionButton.BackgroundColor3 = self.Theme.foreground
            optionButton.BackgroundTransparency = 0.3
            optionButton.BorderSizePixel = 0
            optionButton.FontFace = CONFIG.FONTS.regular
            optionButton.TextSize = 14
            optionButton.TextColor3 = self.Theme.text
            optionButton.Text = option
            optionButton.Parent = self.DropdownFrame
            
            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 4)
            optionCorner.Parent = optionButton
            
            optionButton.MouseButton1Click:Connect(function()
                self.Selected = option
                self.SelectedLabel.Text = option
                self:Toggle()
                
                local success, err = pcall(self.Callback, option)
                if not success then
                    warn("Dropdown callback error:", err)
                end
            end)
        end
        
        local newHeight = #self.Options * 35 + 10
        self.Frame.Size = UDim2.new(0, 140, 0, 32 + newHeight)
        self.DropdownFrame.Size = UDim2.new(1, 0, 0, newHeight)
    else
        self.Arrow.Rotation = 0
        self.Frame.Size = CONFIG.SIZES.dropdown
        self.DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
        
        for _, child in ipairs(self.DropdownFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
    end
end

-- TextBox
local TextBox = setmetatable({}, UIElement)
TextBox.__index = TextBox

function TextBox.new(parent, theme, text, default, callback)
    local self = UIElement.new(parent, theme, {})
    setmetatable(self, TextBox)
    
    self.Frame.Size = CONFIG.SIZES.textbox
    self.Frame.BackgroundColor3 = theme.foreground
    
    self.TextLabel = Instance.new("TextLabel")
    self.TextLabel.Size = UDim2.new(1, -110, 1, 0)
    self.TextLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TextLabel.BackgroundTransparency = 1
    self.TextLabel.FontFace = CONFIG.FONTS.regular
    self.TextLabel.TextSize = 14
    self.TextLabel.TextColor3 = theme.text
    self.TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TextLabel.Text = text
    self.TextLabel.Parent = self.Frame
    
    self.InputBox = Instance.new("TextBox")
    self.InputBox.Size = UDim2.new(0, 80, 0, 22)
    self.InputBox.Position = UDim2.new(1, -90, 0.5, -11)
    self.InputBox.BackgroundColor3 = theme.background
    self.InputBox.BorderSizePixel = 0
    self.InputBox.FontFace = CONFIG.FONTS.regular
    self.InputBox.TextSize = 14
    self.InputBox.TextColor3 = theme.text
    self.InputBox.Text = default or ""
    self.InputBox.PlaceholderText = "Input"
    self.InputBox.ClearTextOnFocus = false
    self.InputBox.Parent = self.Frame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = self.InputBox
    
    self.Callback = callback or function() end
    
    self.InputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local success, err = pcall(self.Callback, self.InputBox.Text)
            if not success then
                warn("TextBox callback error:", err)
            end
        end
    end)
    
    return self
end

function TextBox:SetValue(value)
    self.InputBox.Text = tostring(value)
end

function TextBox:GetValue()
    return self.InputBox.Text
end

-- Keybind
local Keybind = setmetatable({}, UIElement)
Keybind.__index = Keybind

function Keybind.new(parent, theme, text, default, callback)
    local self = UIElement.new(parent, theme, {})
    setmetatable(self, Keybind)
    
    self.Frame.Size = CONFIG.SIZES.keybind
    self.Frame.BackgroundColor3 = theme.foreground
    
    self.TextLabel = Instance.new("TextLabel")
    self.TextLabel.Size = UDim2.new(1, -110, 1, 0)
    self.TextLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TextLabel.BackgroundTransparency = 1
    self.TextLabel.FontFace = CONFIG.FONTS.regular
    self.TextLabel.TextSize = 14
    self.TextLabel.TextColor3 = theme.text
    self.TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TextLabel.Text = text
    self.TextLabel.Parent = self.Frame
    
    self.KeyLabel = Instance.new("TextLabel")
    self.KeyLabel.Size = UDim2.new(0, 80, 0, 22)
    self.KeyLabel.Position = UDim2.new(1, -90, 0.5, -11)
    self.KeyLabel.BackgroundColor3 = theme.background
    self.KeyLabel.BorderSizePixel = 0
    self.KeyLabel.FontFace = CONFIG.FONTS.medium
    self.KeyLabel.TextSize = 12
    self.KeyLabel.TextColor3 = theme.primary
    self.KeyLabel.Text = default or "None"
    self.KeyLabel.Parent = self.Frame
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 4)
    keyCorner.Parent = self.KeyLabel
    
    self.Binding = false
    self.Key = default
    self.Callback = callback or function() end
    
    self.Frame.MouseButton1Click:Connect(function()
        if self.Enabled then
            self:StartBinding()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if self.Binding then
            self:StopBinding(input.KeyCode or input.UserInputType)
        elseif self.Key and input.KeyCode == self.Key or input.UserInputType == self.Key then
            local success, err = pcall(self.Callback)
            if not success then
                warn("Keybind callback error:", err)
            end
        end
    end)
    
    return self
end

function Keybind:StartBinding()
    self.Binding = true
    self.KeyLabel.Text = "..."
    self.KeyLabel.TextColor3 = self.Theme.warning
end

function Keybind:StopBinding(input)
    self.Binding = false
    
    if input ~= Enum.KeyCode.Escape then
        self.Key = input
        self.KeyLabel.Text = self:GetKeyName(input)
    else
        self.KeyLabel.Text = self:GetKeyName(self.Key) or "None"
    end
    
    self.KeyLabel.TextColor3 = self.Theme.primary
end

function Keybind:GetKeyName(key)
    local keyNames = {
        [Enum.KeyCode.LeftShift] = "LShift",
        [Enum.KeyCode.RightShift] = "RShift",
        [Enum.KeyCode.LeftControl] = "LCtrl",
        [Enum.KeyCode.RightControl] = "RCtrl",
        [Enum.KeyCode.LeftAlt] = "LAlt",
        [Enum.KeyCode.RightAlt] = "RAlt",
        [Enum.UserInputType.MouseButton1] = "Mouse1",
        [Enum.UserInputType.MouseButton2] = "Mouse2",
        [Enum.UserInputType.MouseButton3] = "Mouse3",
    }
    
    if typeof(key) == "EnumItem" then
        return keyNames[key] or key.Name
    else
        return tostring(key)
    end
end

-- Label
local Label = setmetatable({}, UIElement)
Label.__index = Label

function Label.new(parent, theme, text, isTitle)
    local self = UIElement.new(parent, theme, {})
    setmetatable(self, Label)
    
    self.Frame.Size = CONFIG.SIZES.label
    self.Frame.BackgroundTransparency = 1
    
    self.TextLabel = Instance.new("TextLabel")
    self.TextLabel.Size = UDim2.new(1, -20, 1, 0)
    self.TextLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TextLabel.BackgroundTransparency = 1
    self.TextLabel.FontFace = isTitle and CONFIG.FONTS.bold or CONFIG.FONTS.medium
    self.TextLabel.TextSize = isTitle and 18 or 14
    self.TextLabel.TextColor3 = isTitle and theme.primary or theme.text
    self.TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TextLabel.Text = text
    self.TextLabel.Parent = self.Frame
    
    return self
end

function Label:SetText(text)
    self.TextLabel.Text = text
end

-- Separator
local Separator = setmetatable({}, UIElement)
Separator.__index = Separator

function Separator.new(parent, theme, text)
    local self = UIElement.new(parent, theme, {})
    setmetatable(self, Separator)
    
    self.Frame.Size = UDim2.new(1, -20, 0, 20)
    self.Frame.BackgroundTransparency = 1
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -100, 0, 1)
    line.Position = UDim2.new(0.5, -50, 0.5, -0.5)
    line.BackgroundColor3 = theme.secondary
    line.BorderSizePixel = 0
    line.Parent = self.Frame
    
    if text then
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(0, 100, 0, 20)
        textLabel.Position = UDim2.new(0.5, -50, 0.5, -10)
        textLabel.BackgroundColor3 = theme.foreground
        textLabel.BackgroundTransparency = 1
        textLabel.FontFace = CONFIG.FONTS.regular
        textLabel.TextSize = 12
        textLabel.TextColor3 = theme.subtext
        textLabel.Text = text
        textLabel.Parent = self.Frame
    end
    
    return self
end

-- Sistema de Salvamento
local SaveSystem = {}
SaveSystem.__index = SaveSystem

function SaveSystem.new(name)
    local self = setmetatable({}, SaveSystem)
    self.Name = name or "Config"
    self.Data = {}
    return self
end

function SaveSystem:Save(data)
    self.Data = data
    
    local success, err = pcall(function()
        writefile(self.Name .. ".json", game:GetService("HttpService"):JSONEncode(data))
    end)
    
    if not success then
        warn("Failed to save config:", err)
    end
    
    return success
end

function SaveSystem:Load()
    local success, data = pcall(function()
        local content = readfile(self.Name .. ".json")
        return game:GetService("HttpService"):JSONDecode(content)
    end)
    
    if success then
        self.Data = data
        return data
    else
        return nil
    end
end

-- Função Principal da Biblioteca
function NexusUI:CreateWindow(config)
    config = config or {}
    local title = config.title or "Nexus UI"
    local size = config.size or UDim2.new(0, 600, 0, 400)
    local themeName = config.theme or "default"
    local theme = CONFIG.THEMES[themeName] or CONFIG.THEMES.default
    local draggable = config.draggable ~= false
    local notifications = config.notifications ~= false
    
    -- Criar ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    end
    
    screenGui.Parent = gethui and gethui() or LocalPlayer:WaitForChild("PlayerGui")
    
    -- Criar Frame Principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = size
    mainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    mainFrame.BackgroundColor3 = theme.background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = theme.secondary
    mainStroke.Thickness = 2
    mainStroke.Parent = mainFrame
    
    -- Sistema de arrastar
    if draggable then
        local dragging = false
        local dragInput
        local dragStart
        local startPos
        
        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        mainFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    -- Sistema de Abas
    local tabs = TabSystem.new(mainFrame, theme, title)
    
    -- Sistema de Notificações
    local notificationSystem
    if notifications then
        notificationSystem = NotificationSystem.new(screenGui)
    end
    
    -- Sistema de Salvamento
    local saveSystem = SaveSystem.new(title)
    
    -- API Retornada
    local api = {
        Window = mainFrame,
        Tabs = tabs,
        Notifications = notificationSystem,
        SaveSystem = saveSystem,
        Theme = theme,
        
        AddTab = function(name, icon)
            return tabs:AddTab(name, icon)
        end,
        
        Notify = function(title, message, duration, type, callback)
            if notificationSystem then
                return notificationSystem:Notify(title, message, duration, type, callback)
            end
        end,
        
        SetTheme = function(newTheme)
            if CONFIG.THEMES[newTheme] then
                theme = CONFIG.THEMES[newTheme]
                -- Atualizar cores (implementação simplificada)
            end
        end,
        
        Destroy = function()
            screenGui:Destroy()
        end,
        
        SetVisible = function(visible)
            mainFrame.Visible = visible
        end,
        
        Toggle = function()
            mainFrame.Visible = not mainFrame.Visible
        end
    }
    
    -- Criar elementos UI
    api.Create = {
        Button = function(parent, text, callback)
            return Button.new(parent, theme, text, callback)
        end,
        
        Toggle = function(parent, text, default, callback)
            return Toggle.new(parent, theme, text, default, callback)
        end,
        
        Slider = function(parent, text, min, max, default, callback)
            return Slider.new(parent, theme, text, min, max, default, callback)
        end,
        
        Dropdown = function(parent, text, options, default, callback)
            return Dropdown.new(parent, theme, text, options, default, callback)
        end,
        
        TextBox = function(parent, text, default, callback)
            return TextBox.new(parent, theme, text, default, callback)
        end,
        
        Keybind = function(parent, text, default, callback)
            return Keybind.new(parent, theme, text, default, callback)
        end,
        
        Label = function(parent, text, isTitle)
            return Label.new(parent, theme, text, isTitle)
        end,
        
        Separator = function(parent, text)
            return Separator.new(parent, theme, text)
        end
    }
    
    return api
end

-- Funções utilitárias
function getIconForType(type)
    local icons = {
        info = "rbxassetid://10747317889",
        success = "rbxassetid://10747317889",
        warning = "rbxassetid://10747317889",
        error = "rbxassetid://10747317889"
    }
    return icons[type] or icons.info
end

function getColorForType(type)
    local colors = {
        info = CONFIG.THEMES.default.primary,
        success = CONFIG.THEMES.default.success,
        warning = CONFIG.THEMES.default.warning,
        error = CONFIG.THEMES.default.error
    }
    return colors[type] or colors.info
end

-- Exportar biblioteca
return NexusUI
