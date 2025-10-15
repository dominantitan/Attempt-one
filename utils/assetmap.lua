-- Asset Map Visualization
-- Shows where assets need to be placed with symbols
-- Press F4 to toggle this overlay

local assetMap = {}

assetMap.visible = false

function assetMap.toggle()
    assetMap.visible = not assetMap.visible
end

function assetMap.draw()
    if not assetMap.visible then return end
    
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    
    -- Title
    love.graphics.print("ASSET MAP - Press F4 to toggle", 10, 10)
    love.graphics.print("Symbols show where assets are needed", 10, 30)
    
    -- Draw structure markers with symbols
    
    -- Cabin
    love.graphics.setColor(0.6, 0.3, 0.1)
    love.graphics.rectangle("line", 220, 150, 80, 60)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("🏠 CABIN", 225, 155)
    love.graphics.print("80x60px", 225, 170)
    love.graphics.print("(220,150)", 225, 185)
    
    -- Pond
    love.graphics.setColor(0.2, 0.5, 0.8)
    love.graphics.ellipse("line", 310, 470, 30, 20)
    love.graphics.setColor(0.5, 0.8, 1)
    love.graphics.print("💧 POND", 285, 450)
    love.graphics.print("60x40px", 285, 465)
    
    -- Farm plots
    love.graphics.setColor(0.8, 0.6, 0.4)
    for row = 0, 1 do
        for col = 0, 2 do
            local x = 575 + col * 40
            local y = 325 + row * 40
            love.graphics.rectangle("line", x, y, 32, 32)
        end
    end
    love.graphics.setColor(1, 1, 0.5)
    love.graphics.print("🌾 FARM GRID", 580, 305)
    love.graphics.print("2x3 plots", 580, 318)
    love.graphics.print("32x32px each", 580, 405)
    
    -- Railway Station
    love.graphics.setColor(0.6, 0.4, 0.3)
    love.graphics.rectangle("line", 750, 400, 100, 80)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("🚂 STATION", 755, 405)
    love.graphics.print("100x80px", 755, 420)
    
    -- Hunting zones (circles)
    love.graphics.setColor(0.3, 0.8, 0.3, 0.3)
    
    -- Northern Thicket
    love.graphics.circle("line", 300, 200, 80)
    love.graphics.setColor(0.5, 1, 0.5)
    love.graphics.print("⭕ N.Thicket", 270, 180)
    love.graphics.print("r=80", 280, 195)
    
    -- Eastern Grove
    love.graphics.setColor(0.3, 0.8, 0.3, 0.3)
    love.graphics.circle("line", 700, 250, 80)
    love.graphics.setColor(0.5, 1, 0.5)
    love.graphics.print("⭕ E.Grove", 670, 230)
    
    -- Western Meadow
    love.graphics.setColor(0.3, 0.8, 0.3, 0.3)
    love.graphics.circle("line", 150, 400, 80)
    love.graphics.setColor(0.5, 1, 0.5)
    love.graphics.print("⭕ W.Meadow", 120, 380)
    
    -- Tree placement suggestions
    love.graphics.setColor(0.3, 0.6, 0.3)
    local treePositions = {
        {50, 50}, {150, 80}, {400, 100}, {800, 80}, {850, 120},
        {100, 300}, {450, 320}, {880, 280},
        {60, 500}, {500, 520}, {900, 480}
    }
    for _, pos in ipairs(treePositions) do
        love.graphics.print("🌲", pos[1], pos[2])
    end
    
    -- Player position marker
    local playerSystem = require("systems/player")
    love.graphics.setColor(0.2, 1, 0.2)
    love.graphics.circle("fill", playerSystem.x, playerSystem.y, 8)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("👤 YOU", playerSystem.x + 10, playerSystem.y - 5)
    
    -- Legend
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 10, love.graphics.getHeight() - 140, 300, 130)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("LEGEND:", 20, love.graphics.getHeight() - 130)
    love.graphics.print("🏠 = Structure (needs sprite)", 20, love.graphics.getHeight() - 110)
    love.graphics.print("🌾 = Farm plots (needs soil texture)", 20, love.graphics.getHeight() - 90)
    love.graphics.print("⭕ = Hunting zones (boundaries)", 20, love.graphics.getHeight() - 70)
    love.graphics.print("🌲 = Tree placement suggestions", 20, love.graphics.getHeight() - 50)
    love.graphics.print("👤 = Player (needs character sprite)", 20, love.graphics.getHeight() - 30)
    
    -- Asset priority list
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", love.graphics.getWidth() - 310, 50, 300, 180)
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("PRIORITY ASSETS NEEDED:", love.graphics.getWidth() - 300, 60)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("1. Player sprite (32x32)", love.graphics.getWidth() - 300, 80)
    love.graphics.print("2. Cabin sprite (80x60)", love.graphics.getWidth() - 300, 100)
    love.graphics.print("3. Crop stages (16x16 x4)", love.graphics.getWidth() - 300, 120)
    love.graphics.print("4. Farm soil (32x32)", love.graphics.getWidth() - 300, 140)
    love.graphics.print("5. Trees (40x60)", love.graphics.getWidth() - 300, 160)
    love.graphics.print("6. Pond water (60x40)", love.graphics.getWidth() - 300, 180)
    love.graphics.print("7. Railway station (100x80)", love.graphics.getWidth() - 300, 200)
    
    love.graphics.setColor(1, 1, 1)
end

return assetMap
