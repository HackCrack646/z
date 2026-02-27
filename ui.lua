-- ═══════════════════════════════════════════════════════════════
--  KEY SYSTEM GLASS - Jaozin Edition (Refinado)
-- ═══════════════════════════════════════════════════════════════

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- CONFIG
local Keys = {
    "transparent2026",
    "jaozinvidro",
    "glasskeyvip",
}

local C = {
    bg = Color3.fromRGB(8, 6, 18),
    glass = Color3.fromRGB(25, 20, 50),
    glassDark = Color3.fromRGB(18, 14, 38),
    accent = Color3.fromRGB(130, 100, 255),
    accentLight = Color3.fromRGB(160, 130, 280),
    text = Color3.fromRGB(225, 225, 255),
    textMuted = Color3.fromRGB(140, 140, 190),
    success = Color3.fromRGB(100, 240, 130),
    error = Color3.fromRGB(255, 90, 100),
    warning = Color3.fromRGB(255, 200, 100),
}

-- CLEANUP & SETUP
for _, v in gui:GetChildren() do
    if v.Name == "KeySystemGlass" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeySystemGlass"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = gui

-- Background
local BG = Instance.new("Frame")
BG.Size = UDim2.new(1, 0, 1, 0)
BG.BackgroundColor3 = C.bg
BG.BackgroundTransparency = 1 -- Começa invisível para animação
BG.BorderSizePixel = 0
BG.Parent = ScreenGui

local BGGradient = Instance.new("UIGradient")
BGGradient.Rotation = 45
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 10, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 4, 12))
})
BGGradient.Parent = BG

-- MAIN FRAME
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 520)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = C.glass
Main.BackgroundTransparency = 0.88
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 28)
MainCorner.Parent = Main

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = C.accent
MainBorder.Thickness = 1.8
MainBorder.Transparency = 0.5
MainBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainBorder.Parent = Main

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 38, 0, 38)
CloseBtn.Position = UDim2.new(1, -54, 0, 14)
CloseBtn.BackgroundColor3 = C.glassDark
CloseBtn.BackgroundTransparency = 0.6
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 90, 110)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = CloseBtn

-- LOCK ICON
local IconFrame = Instance.new("Frame")
IconFrame.Size = UDim2.new(0, 60, 0, 60)
IconFrame.Position = UDim2.new(0.5, 0, 0, 45)
IconFrame.AnchorPoint = Vector2.new(0.5, 0)
IconFrame.BackgroundColor3 = C.glassDark
IconFrame.BackgroundTransparency = 0.7
IconFrame.BorderSizePixel = 0
IconFrame.Parent = Main

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 16)
IconCorner.Parent = IconFrame

local LockIcon = Instance.new("TextLabel")
LockIcon.Size = UDim2.new(1, 0, 1, 0)
LockIcon.BackgroundTransparency = 1
LockIcon.Text = "🔐"
LockIcon.TextSize = 28
LockIcon.Parent = IconFrame

-- TITLE & SUBTITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 115)
Title.BackgroundTransparency = 1
Title.Text = "KEY ACCESS"
Title.TextColor3 = C.text
Title.TextSize = 28
Title.Font = Enum.Font.GothamBlack
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 25)
Subtitle.Position = UDim2.new(0, 0, 0, 150) -- Corrigido erro de variável
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Digite sua key para continuar"
Subtitle.TextColor3 = C.textMuted
Subtitle.TextSize = 14
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = Main

-- INPUT CONTAINER
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(0.82, 0, 0, 56)
InputFrame.Position = UDim2.new(0.09, 0, 0, 205)
InputFrame.BackgroundColor3 = C.glassDark
InputFrame.BackgroundTransparency = 0.75
InputFrame.BorderSizePixel = 0
InputFrame.Parent = Main

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 14)
InputCorner.Parent = InputFrame

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = C.accent
InputStroke.Thickness = 1.2
InputStroke.Transparency = 0.6
InputStroke.Parent = InputFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 15, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = "Sua key aqui..."
KeyInput.PlaceholderColor3 = C.textMuted
KeyInput.TextColor3 = C.text
KeyInput.TextSize = 16
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextXAlignment = Enum.TextXAlignment.Center
KeyInput.Parent = InputFrame
KeyInput.ZIndex = 5

-- VERIFY BUTTON
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.82, 0, 0, 54)
VerifyBtn.Position = UDim2.new(0.09, 0, 0, 280)
VerifyBtn.BackgroundColor3 = C.accent
VerifyBtn.BackgroundTransparency = 0.4
VerifyBtn.Text = "VERIFICAR"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.TextSize = 17
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = Main

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 16)
VerifyCorner.Parent = VerifyBtn

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.82, 0, 0, 45)
Status.Position = UDim2.new(0.09, 0, 0, 385)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextColor3 = C.textMuted
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.Parent = Main

-- ANIMATIONS
local function entryAnim()
    Main.Position = UDim2.new(0.5, 0, 0.6, 0)
    Main.GroupTransparency = 1 -- Se usar CanvasGroup, senão animamos individual
    
    TweenService:Create(Main, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    
    TweenService:Create(BG, TweenInfo.new(0.5), {BackgroundTransparency = 0.65}):Play()
end

-- BUTTON LOGIC
VerifyBtn.MouseEnter:Connect(function()
    TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
end)

VerifyBtn.MouseLeave:Connect(function()
    TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
end)

local function shake()
    local originalPos = UDim2.new(0.09, 0, 0, 205)
    for i = 1, 6 do
        local xOffset = (i % 2 == 0 and 0.01 or -0.01)
        InputFrame.Position = originalPos + UDim2.new(xOffset, 0, 0, 0)
        task.wait(0.05)
    end
    InputFrame.Position = originalPos
end

VerifyBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text:gsub("%s+", "")
    
    if key == "" then
        Status.Text = "Digite uma key!"
        Status.TextColor3 = C.warning
        shake()
        return
    end
    
    VerifyBtn.Text = "VERIFICANDO..."
    task.wait(0.7)
    
    if table.find(Keys, key) then
        Status.Text = "Acesso Permitido!"
        Status.TextColor3 = C.success
        TweenService:Create(MainBorder, TweenInfo.new(0.3), {Color = C.success, Transparency = 0}):Play()
        task.wait(1)
        ScreenGui:Destroy()
        print("Sucesso!")
    else
        Status.Text = "Key Inválida!"
        Status.TextColor3 = C.error
        shake()
        VerifyBtn.Text = "VERIFICAR"
        KeyInput.Text = ""
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

entryAnim()
