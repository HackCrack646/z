-- esp_lib.lua - ESP Library em Luau (adaptado do C++)

local ESP_Lib = {}
ESP_Lib.__index = ESP_Lib

-- Configurações padrão
ESP_Lib.settings = {
    enabled = true,
    show_names = true,
    show_box = true,
    color = Color3.new(0, 1, 0), -- Verde
    max_distance = 1000,
    box_thickness = 1.5,
    fill_box = false,
    fill_color = Color3.new(0, 0, 0)
}

-- Cache de jogadores
local cached_players = {}
local last_player_update = 0
local local_player = nil

-- Função auxiliar para ler strings (adaptada para Roblox)
local function readString(instance)
    if not instance then return "???" end
    local success, result = pcall(function()
        return instance.Name
    end)
    return success and result or "???"
end

-- Obtém nome da classe da instância
local function getInstanceClassName(instance)
    if not instance then return "???" end
    local success, result = pcall(function()
        return instance.ClassName
    end)
    return success and result or "???"
end

-- Encontra o primeiro filho por nome
local function findFirstChild(instance, childName)
    if not instance then return nil end
    
    local cache_key = tostring(instance) .. "_children"
    local cache_time_key = tostring(instance) .. "_time"
    
    local now = tick()
    local children = cached_players[cache_key] or {}
    local last_update = cached_players[cache_time_key] or 0
    
    if #children == 0 or now - last_update > 1 then
        children = {}
        
        local success, result = pcall(function()
            local children_list = {}
            for _, child in ipairs(instance:GetChildren()) do
                table.insert(children_list, {child, child.Name})
            end
            return children_list
        end)
        
        if success then
            children = result
        end
        
        cached_players[cache_key] = children
        cached_players[cache_time_key] = now
    end
    
    for _, child_data in ipairs(children) do
        if child_data[2] == childName then
            return child_data[1]
        end
    end
    
    return nil
end

-- Encontra o primeiro filho por classe
local function findFirstChildByClass(instance, className)
    if not instance then return nil end
    
    local cache_key = tostring(instance) .. "_class_" .. className
    local cache_time_key = tostring(instance) .. "_time"
    
    local now = tick()
    local children = cached_players[cache_key] or {}
    local last_update = cached_players[cache_time_key] or 0
    
    if #children == 0 or now - last_update > 1 then
        children = {}
        
        local success, result = pcall(function()
            local children_list = {}
            for _, child in ipairs(instance:GetChildren()) do
                if child.ClassName == className then
                    table.insert(children_list, {child, child.ClassName})
                end
            end
            return children_list
        end)
        
        if success then
            children = result
        end
        
        cached_players[cache_key] = children
        cached_players[cache_time_key] = now
    end
    
    for _, child_data in ipairs(children) do
        if child_data[2] == className then
            return child_data[1]
        end
    end
    
    return nil
end

-- Obtém todos os jogadores
function ESP_Lib:GetPlayers()
    local now = tick()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    -- Atualiza a cada 2 segundos
    if now - last_player_update > 2 or #cached_players == 0 then
        cached_players = {}
        
        for _, player in ipairs(players:GetPlayers()) do
            if player ~= localPlayer then
                local player_data = {
                    address = player,
                    valid = false,
                    name = player.Name
                }
                
                -- Verifica se tem character
                local character = player.Character
                if character then
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        player_data.position = humanoidRootPart.Position
                        player_data.valid = true
                        
                        -- Cabeça
                        local head = character:FindFirstChild("Head")
                        if head then
                            player_data.head_position = head.Position
                        else
                            player_data.head_position = humanoidRootPart.Position + Vector3.new(0, 2.5, 0)
                        end
                        
                        -- Pés
                        player_data.feet_position = humanoidRootPart.Position - Vector3.new(0, 4.5, 0)
                        
                        table.insert(cached_players, player_data)
                    end
                end
            end
        end
        
        last_player_update = now
    end
    
    return cached_players
end

-- Calcula distância até o jogador local
function ESP_Lib:CalculateDistance(targetPos)
    local localPlayer = game:GetService("Players").LocalPlayer
    if not localPlayer or not localPlayer.Character then return 1000 end
    
    local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return 1000 end
    
    return (humanoidRootPart.Position - targetPos).Magnitude
end

-- Obtém matriz de visão da câmera
function ESP_Lib:GetViewMatrix()
    local camera = workspace.CurrentCamera
    return {
        camera.CFrame,
        camera.ViewportSize
    }
end

-- Converte coordenadas 3D para 2D (WorldToScreen)
function ESP_Lib:WorldToScreen(worldPos, viewMatrix)
    local camera = workspace.CurrentCamera
    local vector, onScreen = camera:WorldToScreenPoint(worldPos)
    
    if onScreen and vector.Z > 0 then
        return true, Vector2.new(vector.X, vector.Y)
    end
    return false, Vector2.new(0, 0)
end

-- Desenha a caixa do jogador
function ESP_Lib:DrawPlayerBox(drawList, player, screenPos, distance)
    local headScreen, feetScreen
    local success1, headPos = self:WorldToScreen(player.head_position, nil)
    local success2, feetPos = self:WorldToScreen(player.feet_position, nil)
    
    if not success1 or not success2 then return end
    
    local height = math.abs(feetPos.Y - headPos.Y)
    local width = height * 0.35
    
    -- Limites mínimos e máximos
    width = math.clamp(width, 25, 60)
    height = math.clamp(height, 50, 120)
    
    local verticalOffset = 17
    
    local topLeft = Vector2.new(
        headPos.X - width / 2,
        headPos.Y - verticalOffset
    )
    local bottomRight = Vector2.new(
        headPos.X + width / 2,
        feetPos.Y - verticalOffset
    )
    
    local espColor = self.settings.color
    local fillColor = self.settings.fill_color
    
    if self.settings.fill_box then
        drawList:FilledRect(topLeft, bottomRight, fillColor)
    end
    
    -- Desenha a caixa principal
    drawList:Rect(topLeft, bottomRight, espColor, self.settings.box_thickness)
    
    -- Cantos decorativos
    local cornerSize = 4
    local white = Color3.new(1, 1, 1)
    
    -- Canto superior esquerdo
    drawList:Line(topLeft, Vector2.new(topLeft.X + cornerSize, topLeft.Y), espColor, self.settings.box_thickness)
    drawList:Line(topLeft, Vector2.new(topLeft.X, topLeft.Y + cornerSize), espColor, self.settings.box_thickness)
    
    -- Canto superior direito
    drawList:Line(Vector2.new(bottomRight.X, topLeft.Y), Vector2.new(bottomRight.X - cornerSize, topLeft.Y), espColor, self.settings.box_thickness)
    drawList:Line(Vector2.new(bottomRight.X, topLeft.Y), Vector2.new(bottomRight.X, topLeft.Y + cornerSize), espColor, self.settings.box_thickness)
    
    -- Canto inferior esquerdo
    drawList:Line(Vector2.new(topLeft.X, bottomRight.Y), Vector2.new(topLeft.X + cornerSize, bottomRight.Y), espColor, self.settings.box_thickness)
    drawList:Line(Vector2.new(topLeft.X, bottomRight.Y), Vector2.new(topLeft.X, bottomRight.Y - cornerSize), espColor, self.settings.box_thickness)
    
    -- Canto inferior direito
    drawList:Line(bottomRight, Vector2.new(bottomRight.X - cornerSize, bottomRight.Y), espColor, self.settings.box_thickness)
    drawList:Line(bottomRight, Vector2.new(bottomRight.X, bottomRight.Y - cornerSize), espColor, self.settings.box_thickness)
end

-- Desenha o nome do jogador
function ESP_Lib:DrawPlayerName(drawList, player, screenPos, distance)
    local success, headPos = self:WorldToScreen(player.head_position, nil)
    if not success then return end
    
    local nameOffsetY = 25
    local textSize = drawList:GetTextSize(player.name, 16)
    
    local namePos = Vector2.new(
        headPos.X - textSize.X / 2,
        headPos.Y - nameOffsetY - textSize.Y
    )
    
    -- Fundo do texto
    drawList:FilledRect(
        Vector2.new(namePos.X - 2, namePos.Y - 1),
        Vector2.new(namePos.X + textSize.X + 2, namePos.Y + textSize.Y + 1),
        Color3.new(0, 0, 0),
        0.7
    )
    
    -- Texto
    drawList:Text(namePos, player.name, self.settings.color, 16)
end

-- Função principal de renderização
function ESP_Lib:Render(drawList)
    if not self.settings.enabled then return end
    
    -- Verifica se o jogo atual é Roblox
    if not game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return end
    
    local players = self:GetPlayers()
    if #players == 0 then return end
    
    for _, player in ipairs(players) do
        if not player.valid then continue end
        
        local success, screenPos = self:WorldToScreen(player.position, nil)
        if success then
            local distance = self:CalculateDistance(player.position)
            
            if distance <= self.settings.max_distance then
                if self.settings.show_box then
                    self:DrawPlayerBox(drawList, player, screenPos, distance)
                end
                
                if self.settings.show_names then
                    self:DrawPlayerName(drawList, player, screenPos, distance)
                end
            end
        end
    end
end

-- Função de utilidade
function math.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Retorna a lib
return ESP_Lib
