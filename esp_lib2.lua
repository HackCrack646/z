-- esp_lib_fixed.lua - ESP Library em Luau (CORRIGIDA)

local ESP_Lib = {}
ESP_Lib.__index = ESP_Lib

-- Configurações padrão (criando uma nova tabela ao invés de modificar a existente)
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

-- Cache de jogadores (usando tabela local)
local cached_players = {}
local last_player_update = 0
local local_player = nil

-- Função auxiliar para ler strings
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
    
    -- Usando cache local
    local cache_key = tostring(instance) .. "_children"
    local cache_time_key = tostring(instance) .. "_time"
    
    local now = tick()
    local children = rawget(cached_players, cache_key) or {}
    local last_update = rawget(cached_players, cache_time_key) or 0
    
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
        
        -- Usando rawset para evitar problemas com metatables
        rawset(cached_players, cache_key, children)
        rawset(cached_players, cache_time_key, now)
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
    local children = rawget(cached_players, cache_key) or {}
    local last_update = rawget(cached_players, cache_time_key) or 0
    
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
        
        rawset(cached_players, cache_key, children)
        rawset(cached_players, cache_time_key, now)
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
    
    -- Criando nova tabela para jogadores
    local new_cached_players = {}
    
    -- Atualiza a cada 2 segundos
    if now - last_player_update > 2 or #cached_players == 0 then
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
                        
                        table.insert(new_cached_players, player_data)
                    end
                end
            end
        end
        
        -- Substitui a tabela antiga pela nova
        cached_players = new_cached_players
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
function ESP_Lib:WorldToScreen(worldPos)
    local camera = workspace.CurrentCamera
    local vector, onScreen = camera:WorldToScreenPoint(worldPos)
    
    if onScreen and vector.Z > 0 then
        return true, Vector2.new(vector.X, vector.Y)
    end
    return false, Vector2.new(0, 0)
end

-- Função para criar Drawing objects (compatível com a maioria dos executores)
local function createDrawing(drawType, properties)
    local drawing = Drawing.new(drawType)
    for prop, value in pairs(properties) do
        pcall(function()
            drawing[prop] = value
        end)
    end
    return drawing
end

-- Desenha a caixa do jogador
function ESP_Lib:DrawPlayerBox(player, distance)
    local success1, headPos = self:WorldToScreen(player.head_position)
    local success2, feetPos = self:WorldToScreen(player.feet_position)
    
    if not success1 or not success2 then return end
    
    local height = math.abs(feetPos.Y - headPos.Y)
    local width = height * 0.35
    
    -- Limites mínimos e máximos
    width = math.max(25, math.min(60, width))
    height = math.max(50, math.min(120, height))
    
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
        createDrawing("Square", {
            Position = Vector2.new((topLeft.X + bottomRight.X)/2, (topLeft.Y + bottomRight.Y)/2),
            Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y),
            Color = fillColor,
            Filled = true,
            Transparency = 0.2,
            Visible = true
        })
    end
    
    -- Desenha a caixa principal
    createDrawing("Square", {
        Position = Vector2.new((topLeft.X + bottomRight.X)/2, (topLeft.Y + bottomRight.Y)/2),
        Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y),
        Color = espColor,
        Thickness = self.settings.box_thickness,
        Filled = false,
        Visible = true
    })
    
    -- Cantos decorativos
    local cornerSize = 4
    
    -- Função auxiliar para desenhar linhas
    local function drawLine(from, to, color)
        createDrawing("Line", {
            From = from,
            To = to,
            Color = color,
            Thickness = self.settings.box_thickness,
            Visible = true
        })
    end
    
    -- Canto superior esquerdo
    drawLine(topLeft, Vector2.new(topLeft.X + cornerSize, topLeft.Y), espColor)
    drawLine(topLeft, Vector2.new(topLeft.X, topLeft.Y + cornerSize), espColor)
    
    -- Canto superior direito
    drawLine(Vector2.new(bottomRight.X, topLeft.Y), Vector2.new(bottomRight.X - cornerSize, topLeft.Y), espColor)
    drawLine(Vector2.new(bottomRight.X, topLeft.Y), Vector2.new(bottomRight.X, topLeft.Y + cornerSize), espColor)
    
    -- Canto inferior esquerdo
    drawLine(Vector2.new(topLeft.X, bottomRight.Y), Vector2.new(topLeft.X + cornerSize, bottomRight.Y), espColor)
    drawLine(Vector2.new(topLeft.X, bottomRight.Y), Vector2.new(topLeft.X, bottomRight.Y - cornerSize), espColor)
    
    -- Canto inferior direito
    drawLine(bottomRight, Vector2.new(bottomRight.X - cornerSize, bottomRight.Y), espColor)
    drawLine(bottomRight, Vector2.new(bottomRight.X, bottomRight.Y - cornerSize), espColor)
end

-- Desenha o nome do jogador
function ESP_Lib:DrawPlayerName(player, distance)
    local success, headPos = self:WorldToScreen(player.head_position)
    if not success then return end
    
    local nameOffsetY = 25
    -- Tamanho aproximado do texto (já que não temos GetTextSize confiável)
    local textWidth = #player.name * 8
    local textHeight = 16
    
    local namePos = Vector2.new(
        headPos.X - textWidth / 2,
        headPos.Y - nameOffsetY - textHeight
    )
    
    -- Fundo do texto
    createDrawing("Square", {
        Position = Vector2.new(namePos.X + textWidth/2, namePos.Y + textHeight/2),
        Size = Vector2.new(textWidth + 4, textHeight + 2),
        Color = Color3.new(0, 0, 0),
        Transparency = 0.3,
        Filled = true,
        Visible = true
    })
    
    -- Texto
    createDrawing("Text", {
        Text = player.name,
        Position = namePos,
        Color = self.settings.color,
        Size = 16,
        Center = false,
        Visible = true
    })
end

-- Função principal de renderização
function ESP_Lib:Render()
    if not self.settings.enabled then return end
    
    -- Verifica se está no Roblox
    if not game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return end
    
    local players = self:GetPlayers()
    if #players == 0 then return end
    
    -- Limpa drawings antigos (se necessário)
    for _, player in ipairs(players) do
        if not player.valid then continue end
        
        local success = self:WorldToScreen(player.position)
        if success then
            local distance = self:CalculateDistance(player.position)
            
            if distance <= self.settings.max_distance then
                if self.settings.show_box then
                    self:DrawPlayerBox(player, distance)
                end
                
                if self.settings.show_names then
                    self:DrawPlayerName(player, distance)
                end
            end
        end
    end
end

-- Função para limpar todos os drawings
function ESP_Lib:ClearDrawings()
    -- A maioria dos executores não tem uma função nativa para limpar todos
    -- Você precisará gerenciar isso manualmente no seu código principal
end

-- Retorna a lib
return ESP_Lib
