-- Dump Avançado com Interceptação em Múltiplos Níveis (CORRIGIDO)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local InputBox = Instance.new("TextBox")
local OutputBox = Instance.new("ScrollingFrame")
local OutputText = Instance.new("TextLabel")
local Tabs = {}
local CurrentTab = "Loader"

-- Sistema de logging avançado
local DumpLogger = {
    httpRequests = {},
    strings = {},
    functions = {},
    bytecode = {},
    executionFlow = {},
    hooks = {}
}

-- Função segura para hook do HttpGet
local function hookHttpGet()
    -- Verifica se podemos acessar game.HttpGet
    local success, original = pcall(function()
        return game.HttpGet
    end)
    
    if success and original then
        -- Cria um novo metatable para interceptar chamadas
        local httpService = game:GetService("HttpService")
        local oldHttpGet = httpService.HttpGet
        
        -- Hook seguro usando o HttpService
        httpService.HttpGet = function(self, url, ...)
            local result = oldHttpGet(self, url, ...)
            table.insert(DumpLogger.httpRequests, {
                url = url,
                time = tick(),
                resultSize = #result,
                preview = result:sub(1, 500)
            })
            -- Usa pcall para evitar erros na UI
            pcall(function()
                addToOutput("🌐 HTTP Request: " .. url, Color3.new(0, 1, 1))
            end)
            return result
        end
    else
        -- Fallback: hook no HttpService
        local httpService = game:GetService("HttpService")
        local oldHttpGet = httpService.HttpGet
        httpService.HttpGet = function(self, url, ...)
            local result = oldHttpGet(self, url, ...)
            table.insert(DumpLogger.httpRequests, {
                url = url,
                time = tick(),
                resultSize = #result,
                preview = result:sub(1, 500)
            })
            pcall(function()
                addToOutput("🌐 HTTP Request: " .. url, Color3.new(0, 1, 1))
            end)
            return result
        end
    end
end

-- Hook seguro no loadstring
local function hookLoadstring()
    local originalLoadstring = loadstring
    loadstring = function(code, chunkname)
        pcall(function()
            addToOutput("📥 Loadstring intercepted:", Color3.new(1, 1, 0))
            addToOutput("Size: " .. #code .. " bytes", Color3.new(1, 1, 0))
            
            -- Tenta identificar ofuscação
            if code:find("\\x") or code:find("string.char") then
                addToOutput("⚠️ Obfuscation detected (hex/char)", Color3.new(1, 0.5, 0))
            end
            if code:find("loadstring") and code:find("gsub") then
                addToOutput("⚠️ Obfuscation detected (nested loadstring)", Color3.new(1, 0.5, 0))
            end
        end)
        
        table.insert(DumpLogger.strings, {
            code = code,
            chunk = chunkname,
            time = tick()
        })
        
        return originalLoadstring(code, chunkname)
    end
end

-- Hook seguro no pcall
local function hookPcall()
    local originalPcall = pcall
    pcall = function(f, ...)
        pcall(function()
            addToOutput("🔧 pcall executed", Color3.new(0.5, 0.5, 1))
        end)
        return originalPcall(f, ...)
    end
end

-- Inicializar hooks com segurança
local function initializeHooks()
    local success = pcall(function()
        hookHttpGet()
        hookLoadstring()
        hookPcall()
    end)
    
    if not success then
        warn("Alguns hooks não puderam ser inicializados")
    end
end

-- Interface Gráfica Avançada
local function createTab(name, position)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0, 100, 0, 30)
    tab.Position = UDim2.new(0, position, 0, 40)
    tab.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    tab.Text = name
    tab.TextColor3 = Color3.new(1, 1, 1)
    tab.Parent = MainFrame
    
    tab.MouseButton1Click:Connect(function()
        CurrentTab = name
        updateDisplay()
    end)
    
    return tab
end

-- Configuração da GUI
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AdvancedDumper"

MainFrame.Size = UDim2.new(0, 800, 0, 650)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -325)
MainFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Title.Text = "Advanced Loader Dumper - Multiple Interception Points"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Parent = MainFrame

-- Criar abas
createTab("Loader", 10)
createTab("HTTP", 120)
createTab("Strings", 230)
createTab("Functions", 340)
createTab("Bytecode", 450)
createTab("Flow", 560)

InputBox.Size = UDim2.new(1, -20, 0, 80)
InputBox.Position = UDim2.new(0, 10, 0, 80)
InputBox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
InputBox.TextColor3 = Color3.new(1, 1, 0)
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.TextYAlignment = Enum.TextYAlignment.Top
InputBox.TextWrapped = true
InputBox.MultiLine = true
InputBox.Font = Enum.Font.Code
InputBox.Text = 'script_key = "KEY";\nloadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/a29177a0adbed682fcef60d92cc0f805.lua"))()'
InputBox.Parent = MainFrame

OutputBox.Size = UDim2.new(1, -20, 0, 380)
OutputBox.Position = UDim2.new(0, 10, 0, 170)
OutputBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
OutputBox.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputBox.ScrollBarThickness = 10
OutputBox.Parent = MainFrame

OutputText.Size = UDim2.new(1, -10, 0, 0)
OutputText.Position = UDim2.new(0, 5, 0, 5)
OutputText.BackgroundTransparency = 1
OutputText.TextColor3 = Color3.new(0, 1, 0)
OutputText.TextXAlignment = Enum.TextXAlignment.Left
OutputText.TextYAlignment = Enum.TextYAlignment.Top
OutputText.TextWrapped = true
OutputText.RichText = true
OutputText.Font = Enum.Font.Code
OutputText.Parent = OutputBox

-- Botões de ação
local function createButton(text, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 30)
    btn.Position = UDim2.new(0, pos, 0, 560)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createButton("Executar e Dump", 10, Color3.new(0, 0.5, 0), function()
    clearOutput()
    addToOutput("🚀 Iniciando dump avançado...", Color3.new(1, 1, 0))
    
    -- Reset logs
    DumpLogger.httpRequests = {}
    DumpLogger.strings = {}
    DumpLogger.functions = {}
    DumpLogger.bytecode = {}
    DumpLogger.executionFlow = {}
    
    -- Executar o loader
    local success, result = pcall(function()
        local func = loadstring(InputBox.Text)
        if func then
            return func()
        end
    end)
    
    if success then
        addToOutput("✅ Loader executado, capturando dados...", Color3.new(0, 1, 0))
        analyzeDump()
    else
        addToOutput("❌ Erro: " .. tostring(result), Color3.new(1, 0, 0))
    end
end)

createButton("Analisar Estrutura", 140, Color3.new(0, 0, 0.5), function()
    analyzeLoaderStructure(InputBox.Text)
end)

createButton("Exportar Dump", 270, Color3.new(0.5, 0, 0.5), function()
    exportDump()
end)

createButton("Limpar Tudo", 400, Color3.new(0.5, 0, 0), function()
    clearOutput()
    DumpLogger = {
        httpRequests = {},
        strings = {},
        functions = {},
        bytecode = {},
        executionFlow = {},
        hooks = {}
    }
    InputBox.Text = ""
    addToOutput("🧹 Tudo limpo!", Color3.new(1, 1, 1))
end)

-- Funções auxiliares
local function addToOutput(text, color)
    local currentText = OutputText.Text
    if currentText ~= "" then
        OutputText.Text = currentText .. "\n" .. text
    else
        OutputText.Text = text
    end
    updateCanvasSize()
end

local function clearOutput()
    OutputText.Text = ""
    updateCanvasSize()
end

local function updateCanvasSize()
    local textHeight = OutputText.TextBounds.Y + 10
    OutputBox.CanvasSize = UDim2.new(0, 0, 0, math.max(textHeight, OutputBox.AbsoluteSize.Y))
end

local function updateDisplay()
    -- Função para atualizar display baseado na aba atual
    clearOutput()
    if CurrentTab == "HTTP" then
        addToOutput("📡 HTTP Requests Log:", Color3.new(0, 1, 1))
        for i, req in ipairs(DumpLogger.httpRequests) do
            addToOutput(string.format("%d. %s (%d bytes)", i, req.url, req.resultSize), Color3.new(1, 1, 1))
        end
    elseif CurrentTab == "Strings" then
        addToOutput("📝 Strings Intercepted:", Color3.new(0, 1, 0))
        for i, str in ipairs(DumpLogger.strings) do
            addToOutput(string.format("%d. Size: %d bytes", i, #str.code), Color3.new(1, 1, 1))
        end
    end
end

local function analyzeLoaderStructure(code)
    clearOutput()
    addToOutput("🔍 Analisando estrutura do loader:", Color3.new(1, 1, 0))
    
    -- Identificar tipo de proteção
    if code:find("script_key") then
        addToOutput("✓ Script key validation detected", Color3.new(1, 0.5, 0))
    end
    
    if code:find("identifyexecutor") or code:find("executor") then
        addToOutput("✓ Executor detection detected", Color3.new(1, 0.5, 0))
    end
    
    if code:find("crypt") or code:find("decrypt") then
        addToOutput("✓ Encryption/decryption detected", Color3.new(1, 0.5, 0))
    end
    
    if code:find("http%.request") then
        addToOutput("✓ HTTP request detected", Color3.new(1, 0.5, 0))
    end
    
    -- Contar URLs
    local urls = {}
    for url in code:gmatch('https?://[^"\']+') do
        urls[url] = (urls[url] or 0) + 1
    end
    
    addToOutput("\n📡 URLs encontradas:", Color3.new(0, 1, 1))
    for url, count in pairs(urls) do
        addToOutput("  " .. url .. " (" .. count .. "x)", Color3.new(1, 1, 1))
    end
    
    -- Analisar ofuscação
    local obfuscationScore = 0
    if code:find("_G") then obfuscationScore = obfuscationScore + 1 end
    if code:find("getfenv") then obfuscationScore = obfuscationScore + 1 end
    if code:find("setfenv") then obfuscationScore = obfuscationScore + 1 end
    if code:find("dumpstring") then obfuscationScore = obfuscationScore + 2 end
    if code:find("byte") and code:find("char") then obfuscationScore = obfuscationScore + 2 end
    
    addToOutput("\n🎯 Obfuscation Score: " .. obfuscationScore .. "/10", 
        obfuscationScore > 5 and Color3.new(1, 0, 0) or Color3.new(0, 1, 0))
end

local function analyzeDump()
    addToOutput("\n📊 RELATÓRIO DE DUMP:", Color3.new(1, 0, 1))
    
    -- HTTP Requests
    addToOutput("\n🌐 HTTP Requests (" .. #DumpLogger.httpRequests .. "):", Color3.new(0, 1, 1))
    for i, req in ipairs(DumpLogger.httpRequests) do
        addToOutput("  " .. i .. ". " .. req.url, Color3.new(1, 1, 1))
        if req.preview then
            addToOutput("     Preview: " .. req.preview:sub(1, 100) .. "...", Color3.new(0.5, 0.5, 0.5))
        end
    end
    
    -- Strings interceptadas
    addToOutput("\n📝 Strings interceptadas (" .. #DumpLogger.strings .. "):", Color3.new(0, 1, 1))
    for i, str in ipairs(DumpLogger.strings) do
        local size = #str.code
        addToOutput("  " .. i .. ". Size: " .. size .. " bytes", Color3.new(1, 1, 1))
        if size < 1000 then
            addToOutput("     Content: " .. str.code:sub(1, 200), Color3.new(0.5, 1, 0.5))
        end
    end
    
    -- Pontos de interceptação sugeridos
    addToOutput("\n🎯 PONTOS DE INTERCEPTAÇÃO IDENTIFICADOS:", Color3.new(1, 1, 0))
    addToOutput("  A) HttpGet - ✓ CAPTURADO", Color3.new(0, 1, 0))
    addToOutput("  B) Validação key - " .. (InputBox.Text:find("script_key") and "✓ DETECTADO" or "✗ NÃO DETECTADO"), 
        InputBox.Text:find("script_key") and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
    addToOutput("  C) Descriptografia - " .. (#DumpLogger.strings > 0 and "✓ POSSÍVEL" or "✗ NÃO CAPTURADO"),
        #DumpLogger.strings > 0 and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
    addToOutput("  D) Execução VM - ⚠️ REQUER ANÁLISE MANUAL", Color3.new(1, 1, 0))
    
    addToOutput("\n💡 Recomendação:", Color3.new(1, 0.5, 0))
    if #DumpLogger.httpRequests > 0 then
        addToOutput("  • Foco na análise das requisições HTTP", Color3.new(1, 1, 1))
    end
    if #DumpLogger.strings > 0 then
        addToOutput("  • Strings interceptadas podem conter payload", Color3.new(1, 1, 1))
    end
end

local function exportDump()
    local dumpData = {
        timestamp = os.time(),
        loader = InputBox.Text,
        logs = DumpLogger,
        analysis = "Dump realizado em " .. os.date()
    }
    
    local json = game:GetService("HttpService"):JSONEncode(dumpData)
    
    -- Tentar salvar
    local success = pcall(function()
        writefile("loader_dump_" .. os.time() .. ".json", json)
    end)
    
    if success then
        addToOutput("💾 Dump exportado com sucesso!", Color3.new(0, 1, 0))
    else
        -- Fallback para clipboard
        pcall(function()
            setclipboard(json)
            addToOutput("📋 Dump copiado para clipboard!", Color3.new(0, 1, 0))
        end)
    end
end

-- Inicializar hooks
initializeHooks()

addToOutput("=== Advanced Dumper Ready ===", Color3.new(0, 1, 1))
addToOutput("Hooks ativos em múltiplos pontos:", Color3.new(1, 1, 1))
addToOutput("• HttpService - Captura requisições", Color3.new(0.5, 1, 0.5))
addToOutput("• loadstring - Captura código", Color3.new(0.5, 1, 0.5))
addToOutput("• pcall - Monitora execução", Color3.new(0.5, 1, 0.5))
addToOutput("", Color3.new(1, 1, 1))
addToOutput("O ponto mais crítico para defesa é o momento", Color3.new(1, 0.5, 0))
addToOutput("da DESCRIPTOGRAFIA antes da execução final!", Color3.new(1, 0, 0))
