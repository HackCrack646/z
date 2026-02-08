--[[
    AirdropLib - Biblioteca modular para detecção de Airdrops e Dropships
    Integra-se com qualquer UI (Rayfield, Kavo, etc)
    Todas as opções são ativáveis/desativáveis e configuráveis
]]

local AirdropLib = {}
AirdropLib.__index = AirdropLib

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- CONSTANTES
-- ============================================
local DEFAULT_CONFIG = {
    airdropModelName = "Airdrop",
    crateName = "Crate",
    dropshipPartName = "dropship",
    detectionEnabled = false,
    espEnabled = false,
    detectionBoxSize = Vector3.new(16, 8, 16),
    distanceUnit = "studs",
    detectionBoxTransparency = 0,
    espUpdateFrequency = "RenderStepped", -- ou "Heartbeat"
    notificationsEnabled = true,
    debugMode = false
}

-- ============================================
-- INICIALIZAÇÃO DA CLASSE
-- ============================================
function AirdropLib.new(config)
    config = config or {}
    
    local self = setmetatable({}, AirdropLib)
    
    -- Mescla configuração padrão com a fornecida
    self.config = {}
    for k, v in pairs(DEFAULT_CONFIG) do
        self.config[k] = config[k] ~= nil and config[k] or v
    end
    
    -- Estados Airdrops
    self.airdropModels = {}
    self.airdropAssignedNames = {}
    self.airdropDetectionBoxes = {}
    self.airdropBillboards = {}
    self.airdropTouchedPlayers = {}
    
    -- Estados Dropships
    self.dropshipParts = {}
    self.dropshipAssignedNames = {}
    self.dropshipDetectionBoxes = {}
    self.dropshipBillboards = {}
    self.dropshipTouchedPlayers = {}
    
    -- Callbacks personalizados
    self.callbacks = {
        onAirdropSpawned = nil,
        onAirdropRemoved = nil,
        onDropshipSpawned = nil,
        onDropshipRemoved = nil,
        onPlayerEntered = nil,
        onPlayerExited = nil,
        onESPToggle = nil,
        onDetectionToggle = nil,
    }
    
    -- Conexões
    self.connections = {}
    
    -- Inicializa monitores
    self:_setupWorkspaceMonitors()
    self:_setupUpdateLoops()
    
    return self
end

-- ============================================
-- CONFIGURAÇÃO
-- ============================================
function AirdropLib:SetConfig(key, value)
    if DEFAULT_CONFIG[key] ~= nil then
        self.config[key] = value
        return true
    end
    warn("Configuração desconhecida: " .. tostring(key))
    return false
end

function AirdropLib:GetConfig(key)
    return self.config[key]
end

function AirdropLib:SetCallback(eventName, callback)
    if self.callbacks[eventName] ~= nil then
        self.callbacks[eventName] = callback
        return true
    end
    warn("Callback desconhecido: " .. tostring(eventName))
    return false
end

-- ============================================
-- UTILITÁRIOS
-- ============================================
local function safeLower(s)
    if type(s) ~= "string" then return s end
    return string.lower(s)
end

function AirdropLib:_log(message, debugOnly)
    if debugOnly and not self.config.debugMode then return end
    print("[AirdropLib] " .. message)
end

function AirdropLib:_notify(title, text, duration)
    if not self.config.notificationsEnabled then return end
    duration = duration or 4
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end)
end

function AirdropLib:_getAirdropCrate(model)
    if not model then return nil end
    return model:FindFirstChild(self.config.crateName, true)
end

function AirdropLib:_getModelPosition(model)
    if not model then return Vector3.new(0, 0, 0) end
    if model.PrimaryPart then return model.PrimaryPart.Position end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            return v.Position
        end
    end
    return Vector3.new(0, 0, 0)
end

-- ============================================
-- NOMEAÇÃO SEQUENCIAL
-- ============================================
function AirdropLib:RefreshAirdropNames()
    self.airdropModels = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == self.config.airdropModelName then
            table.insert(self.airdropModels, obj)
        end
    end

    table.sort(self.airdropModels, function(a, b)
        local pa = self:_getModelPosition(a)
        local pb = self:_getModelPosition(b)
        if pa.X ~= pb.X then return pa.X < pb.X end
        if pa.Y ~= pb.Y then return pa.Y < pb.Y end
        return pa.Z < pb.Z
    end)

    self.airdropAssignedNames = {}
    for i, model in ipairs(self.airdropModels) do
        local label = "airdrop" .. tostring(i)
        self.airdropAssignedNames[model] = label
        
        -- Armazena no model para persistência
        local sv = model:FindFirstChild("AirdropLabel")
        if not sv or not sv:IsA("StringValue") then
            if sv then sv:Destroy() end
            sv = Instance.new("StringValue")
            sv.Name = "AirdropLabel"
            sv.Value = label
            sv.Parent = model
        else
            sv.Value = label
        end
    end
    
    self:_log("Nomes de Airdrops atualizados: " .. #self.airdropModels)
end

function AirdropLib:RefreshDropshipNames()
    self.dropshipParts = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and safeLower(obj.Name) == safeLower(self.config.dropshipPartName) then
            table.insert(self.dropshipParts, obj)
        end
    end

    table.sort(self.dropshipParts, function(a, b)
        local pa = a.Position
        local pb = b.Position
        if pa.X ~= pb.X then return pa.X < pb.X end
        if pa.Y ~= pb.Y then return pa.Y < pb.Y end
        return pa.Z < pb.Z
    end)

    self.dropshipAssignedNames = {}
    for i, part in ipairs(self.dropshipParts) do
        local label = "dropship" .. tostring(i)
        self.dropshipAssignedNames[part] = label
        
        local sv = part:FindFirstChild("DropshipLabel")
        if not sv or not sv:IsA("StringValue") then
            if sv then sv:Destroy() end
            sv = Instance.new("StringValue")
            sv.Name = "DropshipLabel"
            sv.Value = label
            sv.Parent = part
        else
            sv.Value = label
        end
    end
    
    self:_log("Nomes de Dropships atualizados: " .. #self.dropshipParts)
end

function AirdropLib:RefreshAll()
    self:RefreshAirdropNames()
    self:RefreshDropshipNames()
end

-- ============================================
-- DETECTION BOXES
-- ============================================
function AirdropLib:_createAirdropDetectionBox(model)
    if not model or not model.Parent then return end
    local crate = self:_getAirdropCrate(model)
    local pos
    local rot = CFrame.new()
    
    if crate and crate:IsA("BasePart") then
        pos = crate.Position
        rot = crate.CFrame
    else
        pos = self:_getModelPosition(model)
        rot = CFrame.new(pos)
    end

    local box = self.airdropDetectionBoxes[model]
    if not box or not box.Parent then
        box = Instance.new("Part")
        box.Name = "AirdropDetectionBox"
        box.Anchored = true
        box.CanCollide = false
        box.Transparency = self.config.detectionBoxTransparency
        box.Material = Enum.Material.Neon
        box.Color = Color3.fromRGB(255, 60, 60)
        box.Parent = Workspace
        self.airdropDetectionBoxes[model] = box
        self.airdropTouchedPlayers[model] = {}
    end

    box.Size = self.config.detectionBoxSize
    box.CFrame = rot * CFrame.new(0, 0, 0)
end

function AirdropLib:_destroyAirdropDetectionBox(model)
    local box = self.airdropDetectionBoxes[model]
    if box and box.Parent then box:Destroy() end
    self.airdropDetectionBoxes[model] = nil
    self.airdropTouchedPlayers[model] = nil
end

function AirdropLib:_createDropshipDetectionBox(part)
    if not part or not part.Parent then return end
    local pos = part.Position
    local rot = part.CFrame

    local box = self.dropshipDetectionBoxes[part]
    if not box or not box.Parent then
        box = Instance.new("Part")
        box.Name = "DropshipDetectionBox"
        box.Anchored = true
        box.CanCollide = false
        box.Transparency = self.config.detectionBoxTransparency
        box.Material = Enum.Material.Neon
        box.Color = Color3.fromRGB(255, 200, 50)
        box.Parent = Workspace
        self.dropshipDetectionBoxes[part] = box
        self.dropshipTouchedPlayers[part] = {}
    end

    box.Size = self.config.detectionBoxSize
    box.CFrame = rot * CFrame.new(0, 0, 0)
end

function AirdropLib:_destroyDropshipDetectionBox(part)
    local box = self.dropshipDetectionBoxes[part]
    if box and box.Parent then box:Destroy() end
    self.dropshipDetectionBoxes[part] = nil
    self.dropshipTouchedPlayers[part] = nil
end

function AirdropLib:SetDetectionBoxSize(newSize)
    if not newSize or not newSize.X then return false end
    self.config.detectionBoxSize = newSize
    
    for model, box in pairs(self.airdropDetectionBoxes) do
        if box and box.Parent then box.Size = newSize end
    end
    for part, box in pairs(self.dropshipDetectionBoxes) do
        if box and box.Parent then box.Size = newSize end
    end
    return true
end

function AirdropLib:CreateAllDetectionBoxes()
    for _, model in ipairs(self.airdropModels) do
        self:_createAirdropDetectionBox(model)
    end
    for _, part in ipairs(self.dropshipParts) do
        self:_createDropshipDetectionBox(part)
    end
end

function AirdropLib:RemoveAllDetectionBoxes()
    for model, _ in pairs(self.airdropDetectionBoxes) do
        self:_destroyAirdropDetectionBox(model)
    end
    for part, _ in pairs(self.dropshipDetectionBoxes) do
        self:_destroyDropshipDetectionBox(part)
    end
end

-- ============================================
-- ESP (BILLBOARDS)
-- ============================================
function AirdropLib:_createAirdropESP(model)
    if self.airdropBillboards[model] then return end
    local crate = self:_getAirdropCrate(model)
    local targetPart = crate
    local createdTempPart = false
    
    if not targetPart or not targetPart:IsA("BasePart") then
        targetPart = Instance.new("Part")
        targetPart.Name = "AirdropESPTarget"
        targetPart.Anchored = true
        targetPart.CanCollide = false
        targetPart.Transparency = 1
        targetPart.Size = Vector3.new(1, 1, 1)
        targetPart.CFrame = CFrame.new(self:_getModelPosition(model))
        targetPart.Parent = model
        createdTempPart = true
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AirdropESP"
    billboard.Parent = targetPart
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)

    local txt = Instance.new("TextLabel")
    txt.Name = "Label"
    txt.Parent = billboard
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.Font = Enum.Font.SourceSansBold
    txt.TextScaled = true
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextStrokeTransparency = 0.6
    txt.Text = self.airdropAssignedNames[model] or "airdrop"

    self.airdropBillboards[model] = {gui = billboard, targetPart = targetPart, tempPart = createdTempPart}
end

function AirdropLib:_destroyAirdropESP(model)
    local data = self.airdropBillboards[model]
    if data then
        if data.gui and data.gui.Parent then data.gui:Destroy() end
        if data.tempPart and data.targetPart and data.targetPart.Parent then
            data.targetPart:Destroy()
        end
    end
    self.airdropBillboards[model] = nil
end

function AirdropLib:_createDropshipESP(part)
    if self.dropshipBillboards[part] then return end
    if not part or not part.Parent then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DropshipESP"
    billboard.Parent = part
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)

    local txt = Instance.new("TextLabel")
    txt.Name = "Label"
    txt.Parent = billboard
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.Font = Enum.Font.SourceSansBold
    txt.TextScaled = true
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextStrokeTransparency = 0.6
    txt.Text = self.dropshipAssignedNames[part] or "dropship"

    self.dropshipBillboards[part] = {gui = billboard, targetPart = part}
end

function AirdropLib:_destroyDropshipESP(part)
    local data = self.dropshipBillboards[part]
    if data then
        if data.gui and data.gui.Parent then data.gui:Destroy() end
    end
    self.dropshipBillboards[part] = nil
end

function AirdropLib:CreateAllESP()
    for _, model in ipairs(self.airdropModels) do
        self:_createAirdropESP(model)
    end
    for _, part in ipairs(self.dropshipParts) do
        self:_createDropshipESP(part)
    end
end

function AirdropLib:RemoveAllESP()
    for model, _ in pairs(self.airdropBillboards) do
        self:_destroyAirdropESP(model)
    end
    for part, _ in pairs(self.dropshipBillboards) do
        self:_destroyDropshipESP(part)
    end
end

function AirdropLib:_updateESP()
    -- Airdrops
    for model, data in pairs(self.airdropBillboards) do
        if not model.Parent then
            self:_destroyAirdropESP(model)
        else
            local gui = data.gui
            local txt = gui:FindFirstChild("Label")
            if txt then
                local nameLabel = self.airdropAssignedNames[model] or "airdrop"
                local pos = self:_getModelPosition(model)
                local myPos = LocalPlayer.Character and 
                    (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart) and 
                    (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart).Position or 
                    Vector3.new(0, 0, 0)
                local dist = (pos - myPos).Magnitude
                txt.Text = string.format("%s | %.1f %s", nameLabel, dist, self.config.distanceUnit)
            end
        end
    end

    -- Dropships
    for part, data in pairs(self.dropshipBillboards) do
        if not part.Parent then
            self:_destroyDropshipESP(part)
        else
            local gui = data.gui
            local txt = gui:FindFirstChild("Label")
            if txt then
                local nameLabel = self.dropshipAssignedNames[part] or "dropship"
                local pos = part.Position
                local myPos = LocalPlayer.Character and 
                    (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart) and 
                    (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart).Position or 
                    Vector3.new(0, 0, 0)
                local dist = (pos - myPos).Magnitude
                txt.Text = string.format("%s | %.1f %s", nameLabel, dist, self.config.distanceUnit)
            end
        end
    end
end

-- ============================================
-- DETECTION (COLLISION CHECKING)
-- ============================================
function AirdropLib:_updateDetection()
    local myPlayer = LocalPlayer

    -- Airdrops
    for model, box in pairs(self.airdropDetectionBoxes) do
        if not box.Parent or not model.Parent then
            self:_destroyAirdropDetectionBox(model)
            self:_destroyAirdropESP(model)
            self.airdropAssignedNames[model] = nil
            self.airdropTouchedPlayers[model] = nil
        else
            local cpos = box.CFrame.Position
            local size = box.Size
            local min = cpos - (size / 2)
            local max = cpos + (size / 2)
            local currentlyDetected = {}

            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= myPlayer then
                    local char = pl.Character
                    local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
                    if root then
                        local ppos = root.Position
                        if ppos.X >= min.X and ppos.X <= max.X and 
                           ppos.Y >= min.Y and ppos.Y <= max.Y and 
                           ppos.Z >= min.Z and ppos.Z <= max.Z then
                            currentlyDetected[pl] = true
                            if not self.airdropTouchedPlayers[model] then self.airdropTouchedPlayers[model] = {} end
                            if not self.airdropTouchedPlayers[model][pl] then
                                self.airdropTouchedPlayers[model][pl] = true
                                local aName = self.airdropAssignedNames[model] or model.Name
                                local msg = string.format("%s entrou em %s", pl.Name, aName)
                                self:_notify("Jogador detectado", msg, 5)
                                self:_log("⚠️ " .. msg)
                                if self.callbacks.onPlayerEntered then
                                    pcall(self.callbacks.onPlayerEntered, pl, aName, "airdrop")
                                end
                            end
                        else
                            if self.airdropTouchedPlayers[model] and self.airdropTouchedPlayers[model][pl] then
                                self.airdropTouchedPlayers[model][pl] = nil
                                local aName = self.airdropAssignedNames[model] or model.Name
                                local msg = string.format("%s saiu de %s", pl.Name, aName)
                                self:_notify("Jogador saiu", msg, 5)
                                self:_log("ℹ️ " .. msg)
                                if self.callbacks.onPlayerExited then
                                    pcall(self.callbacks.onPlayerExited, pl, aName, "airdrop")
                                end
                            end
                        end
                    end
                end
            end

            if self.airdropTouchedPlayers[model] then
                for existingPl, _ in pairs(self.airdropTouchedPlayers[model]) do
                    if not currentlyDetected[existingPl] then
                        self.airdropTouchedPlayers[model][existingPl] = nil
                        local aName = self.airdropAssignedNames[model] or model.Name
                        local msg = string.format("%s saiu de %s", existingPl.Name, aName)
                        self:_notify("Jogador saiu", msg, 5)
                        self:_log("ℹ️ " .. msg)
                        if self.callbacks.onPlayerExited then
                            pcall(self.callbacks.onPlayerExited, existingPl, aName, "airdrop")
                        end
                    end
                end
            end
        end
    end

    -- Dropships
    for part, box in pairs(self.dropshipDetectionBoxes) do
        if not box.Parent or not part.Parent then
            self:_destroyDropshipDetectionBox(part)
            self:_destroyDropshipESP(part)
            self.dropshipAssignedNames[part] = nil
            self.dropshipTouchedPlayers[part] = nil
        else
            local cpos = box.CFrame.Position
            local size = box.Size
            local min = cpos - (size / 2)
            local max = cpos + (size / 2)
            local currentlyDetected = {}

            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= myPlayer then
                    local char = pl.Character
                    local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
                    if root then
                        local ppos = root.Position
                        if ppos.X >= min.X and ppos.X <= max.X and 
                           ppos.Y >= min.Y and ppos.Y <= max.Y and 
                           ppos.Z >= min.Z and ppos.Z <= max.Z then
                            currentlyDetected[pl] = true
                            if not self.dropshipTouchedPlayers[part] then self.dropshipTouchedPlayers[part] = {} end
                            if not self.dropshipTouchedPlayers[part][pl] then
                                self.dropshipTouchedPlayers[part][pl] = true
                                local dName = self.dropshipAssignedNames[part] or part.Name
                                local msg = string.format("%s entrou em %s", pl.Name, dName)
                                self:_notify("Jogador detectado", msg, 5)
                                self:_log("⚠️ " .. msg)
                                if self.callbacks.onPlayerEntered then
                                    pcall(self.callbacks.onPlayerEntered, pl, dName, "dropship")
                                end
                            end
                        else
                            if self.dropshipTouchedPlayers[part] and self.dropshipTouchedPlayers[part][pl] then
                                self.dropshipTouchedPlayers[part][pl] = nil
                                local dName = self.dropshipAssignedNames[part] or part.Name
                                local msg = string.format("%s saiu de %s", pl.Name, dName)
                                self:_notify("Jogador saiu", msg, 5)
                                self:_log("ℹ️ " .. msg)
                                if self.callbacks.onPlayerExited then
                                    pcall(self.callbacks.onPlayerExited, pl, dName, "dropship")
                                end
                            end
                        end
                    end
                end
            end

            if self.dropshipTouchedPlayers[part] then
                for existingPl, _ in pairs(self.dropshipTouchedPlayers[part]) do
                    if not currentlyDetected[existingPl] then
                        self.dropshipTouchedPlayers[part][existingPl] = nil
                        local dName = self.dropshipAssignedNames[part] or part.Name
                        local msg = string.format("%s saiu de %s", existingPl.Name, dName)
                        self:_notify("Jogador saiu", msg, 5)
                        self:_log("ℹ️ " .. msg)
                        if self.callbacks.onPlayerExited then
                            pcall(self.callbacks.onPlayerExited, existingPl, dName, "dropship")
                        end
                    end
                end
            end
        end
    end
end

function AirdropLib:EnableDetection()
    self.config.detectionEnabled = true
    self:CreateAllDetectionBoxes()
    self:_log("Detecção ATIVADA")
    if self.callbacks.onDetectionToggle then
        pcall(self.callbacks.onDetectionToggle, true)
    end
end

function AirdropLib:DisableDetection()
    self.config.detectionEnabled = false
    self:RemoveAllDetectionBoxes()
    self:_log("Detecção DESATIVADA")
    if self.callbacks.onDetectionToggle then
        pcall(self.callbacks.onDetectionToggle, false)
    end
end

function AirdropLib:ToggleDetection()
    if self.config.detectionEnabled then
        self:DisableDetection()
    else
        self:EnableDetection()
    end
end

function AirdropLib:IsDetectionEnabled()
    return self.config.detectionEnabled
end

-- ============================================
-- ESP TOGGLE
-- ============================================
function AirdropLib:EnableESP()
    self.config.espEnabled = true
    self:CreateAllESP()
    self:_log("ESP ATIVADO")
    if self.callbacks.onESPToggle then
        pcall(self.callbacks.onESPToggle, true)
    end
end

function AirdropLib:DisableESP()
    self.config.espEnabled = false
    self:RemoveAllESP()
    self:_log("ESP DESATIVADO")
    if self.callbacks.onESPToggle then
        pcall(self.callbacks.onESPToggle, false)
    end
end

function AirdropLib:ToggleESP()
    if self.config.espEnabled then
        self:DisableESP()
    else
        self:EnableESP()
    end
end

function AirdropLib:IsESPEnabled()
    return self.config.espEnabled
end

-- ============================================
-- TELEPORT
-- ============================================
function AirdropLib:TeleportToAirdrop(airdropNameOrIndex)
    local target = nil
    
    if type(airdropNameOrIndex) == "string" then
        for model, name in pairs(self.airdropAssignedNames) do
            if name == airdropNameOrIndex then
                target = model
                break
            end
        end
    elseif type(airdropNameOrIndex) == "number" then
        target = self.airdropModels[airdropNameOrIndex]
    end
    
    if not target then
        self:_log("Airdrop não encontrado: " .. tostring(airdropNameOrIndex))
        return false
    end

    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not hrp then return false end

    local pos = self:_getModelPosition(target)
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    self:_log("Teleportado para: " .. (self.airdropAssignedNames[target] or "airdrop"))
    return true
end

function AirdropLib:TeleportToDropship(dropshipNameOrIndex)
    local target = nil
    
    if type(dropshipNameOrIndex) == "string" then
        for part, name in pairs(self.dropshipAssignedNames) do
            if name == dropshipNameOrIndex then
                target = part
                break
            end
        end
    elseif type(dropshipNameOrIndex) == "number" then
        target = self.dropshipParts[dropshipNameOrIndex]
    end
    
    if not target then
        self:_log("Dropship não encontrado: " .. tostring(dropshipNameOrIndex))
        return false
    end

    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not hrp then return false end

    local pos = target.Position
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    self:_log("Teleportado para: " .. (self.dropshipAssignedNames[target] or "dropship"))
    return true
end

-- ============================================
-- WORKSPACE MONITORS
-- ============================================
function AirdropLib:_setupWorkspaceMonitors()
    local onChildAdded = function(child)
        if child:IsA("Model") and child.Name == self.config.airdropModelName then
            task.wait(0.2)
            self:RefreshAirdropNames()
            self:_log("Novo Airdrop: " .. child:GetFullName())
            if self.config.espEnabled then self:_createAirdropESP(child) end
            if self.config.detectionEnabled then self:_createAirdropDetectionBox(child) end
            if self.callbacks.onAirdropSpawned then
                pcall(self.callbacks.onAirdropSpawned, child, self.airdropAssignedNames[child])
            end
        end

        if child:IsA("BasePart") and safeLower(child.Name) == safeLower(self.config.dropshipPartName) then
            task.wait(0.1)
            self:RefreshDropshipNames()
            self:_log("Novo Dropship: " .. child:GetFullName())
            if self.config.espEnabled then self:_createDropshipESP(child) end
            if self.config.detectionEnabled then self:_createDropshipDetectionBox(child) end
            if self.callbacks.onDropshipSpawned then
                pcall(self.callbacks.onDropshipSpawned, child, self.dropshipAssignedNames[child])
            end
        end
    end

    local onChildRemoved = function(child)
        if child:IsA("Model") and child.Name == self.config.airdropModelName then
            self:_destroyAirdropDetectionBox(child)
            self:_destroyAirdropESP(child)
            self.airdropAssignedNames[child] = nil
            self:_log("Airdrop removido: " .. child:GetFullName())
            if self.callbacks.onAirdropRemoved then
                pcall(self.callbacks.onAirdropRemoved, child)
            end
        end

        if child:IsA("BasePart") and safeLower(child.Name) == safeLower(self.config.dropshipPartName) then
            self:_destroyDropshipDetectionBox(child)
            self:_destroyDropshipESP(child)
            self.dropshipAssignedNames[child] = nil
            self:_log("Dropship removido: " .. child:GetFullName())
            if self.callbacks.onDropshipRemoved then
                pcall(self.callbacks.onDropshipRemoved, child)
            end
        end
    end

    local conn1 = Workspace.ChildAdded:Connect(onChildAdded)
    local conn2 = Workspace.ChildRemoved:Connect(onChildRemoved)
    
    table.insert(self.connections, conn1)
    table.insert(self.connections, conn2)
end

function AirdropLib:_setupUpdateLoops()
    local espConn = RunService.RenderStepped:Connect(function()
        if self.config.espEnabled then
            self:_updateESP()
        end
    end)

    local detectionConn = RunService.Heartbeat:Connect(function()
        if self.config.detectionEnabled then
            self:_updateDetection()
        end
    end)
    
    table.insert(self.connections, espConn)
    table.insert(self.connections, detectionConn)
end

-- ============================================
-- GETTERS (para UI)
-- ============================================
function AirdropLib:GetAirdropsList()
    local result = {}
    for i, model in ipairs(self.airdropModels) do
        local name = self.airdropAssignedNames[model]
        local pos = self:_getModelPosition(model)
        table.insert(result, {
            index = i,
            name = name,
            position = pos,
            model = model
        })
    end
    return result
end

function AirdropLib:GetDropshipsList()
    local result = {}
    for i, part in ipairs(self.dropshipParts) do
        local name = self.dropshipAssignedNames[part]
        table.insert(result, {
            index = i,
            name = name,
            position = part.Position,
            part = part
        })
    end
    return result
end

function AirdropLib:GetPlayersInAirdrop(airdropNameOrIndex)
    local model = nil
    if type(airdropNameOrIndex) == "string" then
        for m, name in pairs(self.airdropAssignedNames) do
            if name == airdropNameOrIndex then model = m break end
        end
    else
        model = self.airdropModels[airdropNameOrIndex]
    end
    
    if not model then return {} end
    local result = {}
    if self.airdropTouchedPlayers[model] then
        for player in pairs(self.airdropTouchedPlayers[model]) do
            table.insert(result, player)
        end
    end
    return result
end

function AirdropLib:GetPlayersInDropship(dropshipNameOrIndex)
    local part = nil
    if type(dropshipNameOrIndex) == "string" then
        for p, name in pairs(self.dropshipAssignedNames) do
            if name == dropshipNameOrIndex then part = p break end
        end
    else
        part = self.dropshipParts[dropshipNameOrIndex]
    end
    
    if not part then return {} end
    local result = {}
    if self.dropshipTouchedPlayers[part] then
        for player in pairs(self.dropshipTouchedPlayers[part]) do
            table.insert(result, player)
        end
    end
    return result
end

-- ============================================
-- CLEANUP
-- ============================================
function AirdropLib:Destroy()
    self:DisableDetection()
    self:DisableESP()
    
    for _, conn in ipairs(self.connections) do
        pcall(function() conn:Disconnect() end)
    end
    
    self.connections = {}
    self:_log("Biblioteca destruída")
end

return AirdropLib
