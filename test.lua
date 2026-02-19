-- esp.lua - ESP rendering with world-to-screen projection
-- Luau version for Roblox script execution

local ESP = {}
local settings = {
    enabled = false,
    showBox = true,
    showNames = true,
    showHealth = true,
    showDistance = true,
    showSnapline = false,
    showDead = false,
    maxDistance = 1000,
    espCol = {1, 1, 1} -- RGB from 0-1
}

ESP.settings = settings

-- World to Screen using ViewMatrix (assumes you have a function to get view matrix)
local function worldToScreen(pos, vm, screenW, screenH)
    local x = pos[1] * vm[1] + pos[2] * vm[2] + pos[3] * vm[3] + vm[4]
    local y = pos[1] * vm[5] + pos[2] * vm[6] + pos[3] * vm[7] + vm[8]
    local w = pos[1] * vm[13] + pos[2] * vm[14] + pos[3] * vm[15] + vm[16]
    
    if w < 0.1 then return false end
    
    local invW = 1 / w
    x = x * invW
    y = y * invW
    
    local outX = (screenW * 0.5) + (x * screenW * 0.5)
    local outY = (screenH * 0.5) - (y * screenH * 0.5)
    
    -- Basic screen clipping
    if outX > -1000 and outX < screenW + 1000 and outY > -1000 and outY < screenH + 1000 then
        return true, outX, outY
    end
    return false
end

-- Distance between two 3D points
local function distance3D(a, b)
    local dx = a[1] - b[1]
    local dy = a[2] - b[2]
    local dz = a[3] - b[3]
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

-- Get color from health percentage (returns RGB values 0-1)
local function healthColor(health, maxHealth)
    if maxHealth <= 0 then return 1, 1, 1 end
    local pct = math.clamp(health / maxHealth, 0, 1)
    
    -- Green to red gradient
    local r = (1 - pct)
    local g = pct
    return r, g, 0
end

-- Main render function
function ESP:render()
    if not settings.enabled then return end
    
    -- Get required data from your Roblox wrapper functions
    local vm = getViewMatrix() -- You need to implement this
    local players = getPlayers() -- You need to implement this
    local screenW, screenH = getScreenSize() -- You need to implement this
    
    if screenW <= 0 or screenH <= 0 then return end
    
    -- Get local player position
    local localPos = {0, 0, 0}
    local localID = nil
    
    for _, player in ipairs(players) do
        if player.isLocalPlayer then
            localPos = {player.rootPos[1], player.rootPos[2], player.rootPos[3]}
            localID = player.ptr
            break
        end
    end
    
    for _, player in ipairs(players) do
        -- Skip self and invalid players
        if player.isLocalPlayer or player.ptr == localID then continue end
        if not player.valid then continue end
        
        -- Filter dead players
        if not settings.showDead and (player.health or 0) <= 0.1 then continue end
        
        -- Filter garbage positions
        local rootPos = player.rootPos or {0, 0, 0}
        if rootPos[1] == 0 and rootPos[2] == 0 and rootPos[3] == 0 then continue end
        if math.abs(rootPos[1]) > 50000 or math.abs(rootPos[2]) > 50000 or math.abs(rootPos[3]) > 50000 then continue end
        
        local dist = distance3D(localPos, rootPos)
        if dist > settings.maxDistance then continue end
        
        -- Select color
        local colorR, colorG, colorB = settings.espCol[1], settings.espCol[2], settings.espCol[3]
        
        local boxX, boxY, boxW, boxH
        local headScreenX, headScreenY, feetScreenX, feetScreenY
        
        if player.hasLimbs then
            -- Dynamic Box from Limbs
            local screenPoints = {}
            local validPoints = {}
            local validCount = 0
            
            local worldPoints = {
                player.headPos or rootPos,
                rootPos,
                player.lFoot or rootPos,
                player.rFoot or rootPos,
                player.lHand or rootPos,
                player.rHand or rootPos
            }
            
            -- Project all available points
            for i = 1, 6 do
                local wp = {worldPoints[i][1], worldPoints[i][2], worldPoints[i][3]}
                if i == 1 then wp[2] = wp[2] + 0.8 end -- Head top padding
                if i == 3 or i == 4 then wp[2] = wp[2] - 0.5 end -- Feet bottom padding
                
                local success, sx, sy = worldToScreen(wp, vm, screenW, screenH)
                validPoints[i] = success
                if success then
                    screenPoints[i] = {sx, sy}
                    validCount = validCount + 1
                end
            end
            
            -- Strict clipping check
            if not validPoints[1] or not validPoints[2] or validCount < 4 then continue end
            
            local minX, minY = 10000, 10000
            local maxX, maxY = -10000, -10000
            
            for i = 1, 6 do
                if not validPoints[i] then continue end
                minX = math.min(minX, screenPoints[i][1])
                maxX = math.max(maxX, screenPoints[i][1])
                minY = math.min(minY, screenPoints[i][2])
                maxY = math.max(maxY, screenPoints[i][2])
            end
            
            -- Add padding
            local padX = (maxX - minX) * 0.15
            local padY = (maxY - minY) * 0.05
            
            boxX = minX - padX
            boxY = minY - padY
            boxW = (maxX - minX) + (padX * 2)
            boxH = (maxY - minY) + (padY * 2)
            
            -- Set head/feet screen positions
            headScreenX = boxX + boxW * 0.5
            headScreenY = boxY
            feetScreenX = boxX + boxW * 0.5
            feetScreenY = boxY + boxH
        else
            -- Fallback: Static Height-Width
            local feetPos = {rootPos[1], rootPos[2] - 3, rootPos[3]}
            local headTopPos = {rootPos[1], rootPos[2] + 2.5, rootPos[3]}
            
            local headSuccess, headSX, headSY = worldToScreen(headTopPos, vm, screenW, screenH)
            local feetSuccess, feetSX, feetSY = worldToScreen(feetPos, vm, screenW, screenH)
            
            if not headSuccess or not feetSuccess then continue end
            
            headScreenX, headScreenY = headSX, headSY
            feetScreenX, feetScreenY = feetSX, feetSY
            
            boxH = feetSY - headSY
            if math.abs(boxH) < 1 then continue end
            
            boxW = boxH * 0.55
            boxX = headSX - boxW * 0.5
            boxY = headSY
        end
        
        -- Sanity check box dimensions
        if boxW > screenW * 0.9 or boxH > screenH * 0.9 or boxW < 0.1 or boxH < 0.1 then continue end
        if boxX < -screenW or boxX > screenW*2 or boxY < -screenH or boxY > screenH*2 then continue end
        
        -- Bounding Box
        if settings.showBox then
            -- Outline
            drawRect(boxX - 1, boxY - 1, boxW + 2, boxH + 2, 0, 0, 0, 200) -- You need to implement drawing
            -- Main box
            drawRect(boxX, boxY, boxW, boxH, colorR*255, colorG*255, colorB*255, 255)
        end
        
        -- Snapline
        if settings.showSnapline then
            drawLine(screenW * 0.5, screenH, headScreenX, feetScreenY, 255, 255, 255, 255, 1)
        end
        
        -- Player Name
        if settings.showNames and player.name and player.name ~= "" then
            local textWidth = getTextWidth(player.name) -- You need to implement text metrics
            local textHeight = getTextHeight(player.name)
            local textX = headScreenX - textWidth * 0.5
            local textY = boxY - textHeight - 4
            
            -- Shadow
            drawText(textX + 1, textY + 1, player.name, 0, 0, 0, 200)
            drawText(textX, textY, player.name, 255, 255, 255, 255)
        end
        
        -- Health Bar
        if settings.showHealth then
            local barW = 3
            local barX = boxX - barW - 3
            local healthPct = (player.maxHealth and player.maxHealth > 0.1) and math.clamp(player.health / player.maxHealth, 0, 1) or 0
            
            local filledH = boxH * healthPct
            
            -- Background
            drawRectFilled(barX, boxY, barW, boxH, 0, 0, 0, 180)
            -- Health fill
            local hR, hG, hB = healthColor(player.health or 100, player.maxHealth or 100)
            drawRectFilled(barX, boxY + boxH - filledH, barW, filledH, hR*255, hG*255, hB*255, 255)
            -- Outline
            drawRect(barX, boxY, barW, boxH, 0, 0, 0, 255)
        end
        
        -- Distance
        if settings.showDistance then
            local distText = string.format("[%.0fm]", dist)
            local textWidth = getTextWidth(distText)
            local textHeight = getTextHeight(distText)
            local textX = headScreenX - textWidth * 0.5
            local textY = boxY + boxH + 2
            
            -- Shadow
            drawText(textX + 1, textY + 1, distText, 0, 0, 0, 200)
            drawText(textX, textY, distText, 200, 200, 200, 255)
        end
    end
    
    -- Aimbot FOV Circle (if you have aimbot settings)
    if aimbotSettings and aimbotSettings.enabled and aimbotSettings.drawFov then
        local mouseX, mouseY = getMousePosition() -- You need to implement mouse position
        drawCircle(mouseX, mouseY, aimbotSettings.fov, 255, 255, 255, 255, 64, 1)
    end
end

-- Helper function to clamp values (if not already defined)
if not math.clamp then
    function math.clamp(value, min, max)
        return math.max(min, math.min(max, value))
    end
end

return ESP
