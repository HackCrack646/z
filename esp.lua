-- ================= RAYFIELD =================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ================= ESP LIB (LOADSTRING) =================
local ESP = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/HackCrack646/z/refs/heads/main/esp.lua"
))()

-- ================= WINDOW =================
local Window = Rayfield:CreateWindow({
    Name = "ESP Controller",
    LoadingTitle = "ESP",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ESP_UI",
        FileName = "ESP_Config"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

-- ================= TAB =================
local Tab = Window:CreateTab("ESP", 4483362458)

-- ================= TOGGLES =================

-- ESP ON/OFF
Tab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = ESP.Enabled,
    Flag = "ESPEnabled",
    Callback = function(v)
        ESP.SetEnabled(v)
    end
})

-- OUTLINE ON/OFF
Tab:CreateToggle({
    Name = "Outline Enabled",
    CurrentValue = ESP.OutlineEnabled,
    Flag = "ESPOutline",
    Callback = function(v)
        ESP.SetOutlineEnabled(v)
    end
})

-- TEAM CHECK
Tab:CreateToggle({
    Name = "Team Check",
    CurrentValue = ESP.TeamCheck,
    Flag = "ESPTeamCheck",
    Callback = function(v)
        ESP.SetTeamCheck(v)
    end
})

-- ================= COLORS =================

-- FILL COLOR
Tab:CreateColorPicker({
    Name = "ESP Color",
    Color = ESP.Color,
    Flag = "ESPColor",
    Callback = function(c)
        ESP.SetColor(c)
    end
})

-- OUTLINE COLOR
Tab:CreateColorPicker({
    Name = "Outline Color",
    Color = ESP.OutlineColor,
    Flag = "OutlineColor",
    Callback = function(c)
        ESP.OutlineColor = c
        for _,p in ipairs(game:GetService("Players"):GetPlayers()) do
            local hl = p.Character and p.Character:FindFirstChild("ESP_HL")
            if hl and not ESP.TeamCheck then -- só atualiza se TeamCheck não estiver ativo
                hl.OutlineColor = c
            end
        end
    end
})

-- ================= SLIDERS =================

-- TRANSPARENCY
Tab:CreateSlider({
    Name = "ESP Transparency",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = ESP.Transparency,
    Flag = "ESPTransparency",
    Callback = function(v)
        ESP.SetTransparency(v)
    end
})
