-- Clean Highlight ESP (Legit Style + Tool + TeamCheck + NameToggle)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESP = {}

ESP.Enabled = true
ESP.Names = true -- NOVA OPÇÃO: Ativar/Desativar nomes
ESP.Color = Color3.fromRGB(255, 255, 255)
ESP.OutlineColor = Color3.fromRGB(255, 255, 255)
ESP.Transparency = 0.9
ESP.OutlineEnabled = true
ESP.TeamCheck = false 

-- ================= UTILS =================

local function getEquippedTool(char)
    for _,v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then
            return v.Name
        end
    end
    return nil
end

local function getTeamColor(player)
    if player.Team then
        return player.Team.TeamColor.Color
    else
        return ESP.Color
    end
end

local function clear(player)
    if not player.Character then return end

    local char = player.Character

    local hl = char:FindFirstChild("ESP_HL")
    if hl then hl:Destroy() end

    local head = char:FindFirstChild("Head")
    if head then
        local tag = head:FindFirstChild("ESP_Tag")
        if tag then tag:Destroy() end
    end
end

-- ================= CREATE =================

local function create(player)
    if not ESP.Enabled then return end
    if player == LocalPlayer then return end
    if not player.Character then return end
    if player.Character:FindFirstChild("ESP_HL") then return end

    -- Highlight
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_HL"
    hl.Adornee = player.Character

    local fillColor = ESP.TeamCheck and getTeamColor(player) or ESP.Color
    local outlineColor = ESP.TeamCheck and getTeamColor(player) or ESP.OutlineColor

    hl.FillColor = fillColor
    hl.OutlineColor = outlineColor
    hl.FillTransparency = ESP.Transparency
    hl.OutlineTransparency = ESP.OutlineEnabled and 0 or 1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = player.Character

    -- NameTag
    local head = player.Character:FindFirstChild("Head")
    if head and not head:FindFirstChild("ESP_Tag") then
        local gui = Instance.new("BillboardGui")
        gui.Name = "ESP_Tag"
        gui.Adornee = head
        gui.Size = UDim2.fromOffset(140, 32)
        gui.StudsOffset = Vector3.new(0, 2.4, 0)
        gui.AlwaysOnTop = true
        gui.Enabled = ESP.Names -- Define visibilidade inicial
        gui.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.TextWrapped = true
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.TextStrokeTransparency = 0.85
        label.TextColor3 = fillColor
        label.Text = ""
        label.Parent = gui
    end
end

-- ================= UPDATE =================

local function update(player)
    if not ESP.Enabled then return end
    if player == LocalPlayer then return end
    if not player.Character then return end

    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    if not root or not hum or not head then return end

    -- NameTag
    local tag = head:FindFirstChild("ESP_Tag")
    if tag then
        tag.Enabled = ESP.Names -- Atualiza se o nome deve aparecer
        
        local label = tag:FindFirstChildOfClass("TextLabel")
        if label and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            local dist = (LocalPlayer.Character.PrimaryPart.Position - root.Position).Magnitude
            local tool = getEquippedTool(char)

            if tool then
                label.Text = string.format("%s [%dm]\n%s", player.Name, math.floor(dist), tool)
            else
                label.Text = string.format("%s [%dm]", player.Name, math.floor(dist))
            end

            local color = ESP.TeamCheck and getTeamColor(player) or ESP.Color
            label.TextColor3 = color
        end
    end

    -- Highlight
    local hl = char:FindFirstChild("ESP_HL")
    if hl then
        hl.Enabled = hum.Health > 0
        hl.FillColor = ESP.TeamCheck and getTeamColor(player) or ESP.Color
        hl.OutlineColor = ESP.TeamCheck and getTeamColor(player) or ESP.OutlineColor
        hl.OutlineTransparency = ESP.OutlineEnabled and 0 or 1
    end
end

-- ================= PLAYER HOOK =================

local function setup(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.1)
        create(player)
    end)
    if player.Character then create(player) end
end

for _,p in ipairs(Players:GetPlayers()) do setup(p) end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(clear)

-- ================= LOOP =================

task.spawn(function()
    while true do
        for _,p in ipairs(Players:GetPlayers()) do
            update(p)
        end
        task.wait(0.35)
    end
end)

-- ================= API =================

function ESP.SetEnabled(v)
    ESP.Enabled = v
    for _,p in ipairs(Players:GetPlayers()) do
        if v then create(p) else clear(p) end
    end
end

function ESP.SetNames(v) -- NOVA FUNÇÃO DA API
    ESP.Names = v
end

function ESP.SetColor(c) ESP.Color = c end

function ESP.SetTransparency(v)
    ESP.Transparency = v
    for _,p in ipairs(Players:GetPlayers()) do
        local hl = p.Character and p.Character:FindFirstChild("ESP_HL")
        if hl then hl.FillTransparency = v end
    end
end

function ESP.SetOutlineEnabled(v)
    ESP.OutlineEnabled = v
    for _,p in ipairs(Players:GetPlayers()) do
        local hl = p.Character and p.Character:FindFirstChild("ESP_HL")
        if hl then hl.OutlineTransparency = v and 0 or 1 end
    end
end

function ESP.SetTeamCheck(v)
    ESP.TeamCheck = v
    for _,p in ipairs(Players:GetPlayers()) do
        local hl = p.Character and p.Character:FindFirstChild("ESP_HL")
        local head = p.Character and p.Character:FindFirstChild("Head")
        if hl then
            hl.FillColor = v and getTeamColor(p) or ESP.Color
            hl.OutlineColor = v and getTeamColor(p) or ESP.OutlineColor
        end
        if head then
            local tag = head:FindFirstChild("ESP_Tag")
            local label = tag and tag:FindFirstChildOfClass("TextLabel")
            if label then label.TextColor3 = v and getTeamColor(p) or ESP.Color end
        end
    end
end

return ESP
