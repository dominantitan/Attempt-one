-- Foraging System
-- Manages daily spawning of wild crops/forage items throughout the forest

local foraging = {}

-- Wild crop types and their properties
-- NOTE: itemType must match shop.buyPrices in shop.lua for selling!
foraging.wildCropTypes = {
    {
        name = "Wild Berries",
        itemType = "berries", -- Used for inventory/shop (shop buys at $6)
        icon = "🫐",
        sellValue = 6, -- What shop pays
        rarity = 0.4, -- 40% chance when spawning
        nutrition = 15,
        description = "Sweet berries found on wild bushes"
    },
    {
        name = "Mushrooms",
        itemType = "mushroom", -- Matches crop type too (shop buys at $10)
        icon = "🍄",
        sellValue = 10,
        rarity = 0.25, -- 25% chance
        nutrition = 20,
        description = "Earthy mushrooms growing near trees"
    },
    {
        name = "Wild Herbs",
        itemType = "herbs", -- Used for inventory/shop (shop buys at $8)
        icon = "🌿",
        sellValue = 8,
        rarity = 0.25, -- 25% chance
        nutrition = 10,
        description = "Medicinal herbs with healing properties"
    },
    {
        name = "Pine Nuts",
        itemType = "nuts", -- Used for inventory/shop (shop buys at $5)
        icon = "🌰",
        sellValue = 5,
        rarity = 0.1, -- 10% chance (rare!)
        nutrition = 25,
        description = "Nutritious nuts from pine cones"
    }
}

-- Current wild crops on the map
foraging.activeCrops = {}

-- Spawn settings (MVP BALANCE)
foraging.dailySpawnCount = {min = 3, max = 5} -- More items to make foraging viable
foraging.lastSpawnDay = -1

-- Forest boundaries (avoid spawning on structures - scaled 3x)
foraging.forestBounds = {
    x = 150,    -- Was 50
    y = 150,    -- Was 50
    width = 2580,  -- Was 860
    height = 1320  -- Was 440
}

-- Areas to avoid (structures, etc. - scaled 3x)
foraging.avoidAreas = {
    {x = 1350, y = 900, width = 300, height = 300},  -- Cabin area (was 450,300,100,100)
    {x = 1665, y = 945, width = 420, height = 300},  -- Farm area (was 555,315,140,100)
    {x = 1710, y = 1605, width = 360, height = 240}, -- Pond area (was 570,535,120,80)
    {x = 540, y = 1830, width = 300, height = 240},  -- Shop area (was 180,610,100,80)
    {x = 360, y = 1200, width = 420, height = 300},  -- Railway station area (was 120,400,140,100)
    {x = 360, y = 360, radius = 270},                -- NW hunting zone (was 120,120,90)
    {x = 2460, y = 360, radius = 270},               -- NE hunting zone (was 820,120,90)
    {x = 2460, y = 1200, radius = 270}               -- SE hunting zone (was 820,400,90)
}

-- Initialize foraging system
function foraging.load()
    foraging.activeCrops = {}
    print("🌿 Foraging system initialized")
end

-- Update foraging system (check for daily spawns)
function foraging.update(dt)
    local daynightSystem = require("systems/daynight")
    local currentDay = math.floor(daynightSystem.dayCount or 0)
    
    -- Check if we need to spawn new crops for today
    if currentDay > foraging.lastSpawnDay then
        foraging.spawnDailyCrops()
        foraging.lastSpawnDay = currentDay
    end
end

-- Spawn daily wild crops
function foraging.spawnDailyCrops()
    local spawnCount = math.random(foraging.dailySpawnCount.min, foraging.dailySpawnCount.max)
    
    for i = 1, spawnCount do
        local position = foraging.findValidSpawnPosition()
        if position then
            local cropType = foraging.selectRandomCropType()
            if cropType then
                local wildCrop = {
                    x = position.x,
                    y = position.y,
                    type = cropType,
                    spawnDay = foraging.lastSpawnDay + 1,
                    collected = false,
                    id = #foraging.activeCrops + 1
                }
                table.insert(foraging.activeCrops, wildCrop)
            end
        end
    end
    
    print("🌱 " .. spawnCount .. " wild crops spawned around the forest")
end

-- Find a valid spawn position that doesn't overlap with structures
function foraging.findValidSpawnPosition()
    local maxAttempts = 50
    local attempts = 0
    
    while attempts < maxAttempts do
        local x = math.random(foraging.forestBounds.x, foraging.forestBounds.x + foraging.forestBounds.width)
        local y = math.random(foraging.forestBounds.y, foraging.forestBounds.y + foraging.forestBounds.height)
        
        if foraging.isValidPosition(x, y) then
            return {x = x, y = y}
        end
        
        attempts = attempts + 1
    end
    
    return nil -- Couldn't find valid position
end

-- Check if position is valid (not overlapping with structures)
function foraging.isValidPosition(x, y)
    for _, area in ipairs(foraging.avoidAreas) do
        if area.radius then
            -- Circular area (hunting zones)
            local distance = math.sqrt((x - area.x)^2 + (y - area.y)^2)
            if distance < area.radius then
                return false
            end
        else
            -- Rectangular area
            if x >= area.x and x <= area.x + area.width and
               y >= area.y and y <= area.y + area.height then
                return false
            end
        end
    end
    return true
end

-- Select random crop type based on rarity
function foraging.selectRandomCropType()
    local random = math.random()
    local cumulativeChance = 0
    
    for _, cropType in ipairs(foraging.wildCropTypes) do
        cumulativeChance = cumulativeChance + cropType.rarity
        if random <= cumulativeChance then
            return cropType
        end
    end
    
    -- Fallback to first type
    return foraging.wildCropTypes[1]
end

-- Check if player is near any wild crops
function foraging.getPlayerNearCrop(playerX, playerY)
    for _, crop in ipairs(foraging.activeCrops) do
        if not crop.collected then
            local distance = math.sqrt((playerX - crop.x)^2 + (playerY - crop.y)^2)
            if distance <= 25 then -- 25 pixel collection radius
                return crop
            end
        end
    end
    return nil
end

-- Collect a wild crop
function foraging.collectCrop(crop)
    if crop and not crop.collected then
        crop.collected = true
        
        -- Add to player inventory using the correct itemType (for shop compatibility)
        local playerEntity = require("entities/player")
        playerEntity.addItem(crop.type.itemType, 1)
        
        print("🌿 Collected " .. crop.type.icon .. " " .. crop.type.name .. "!")
        print("💰 Sells for $" .. crop.type.sellValue .. " at shop")
        print("💡 " .. crop.type.description)
        
        return true
    end
    return false
end

-- Draw wild crops on the map
function foraging.draw()
    -- Pulsing glow effect (sine wave for smooth animation)
    local time = love.timer.getTime()
    local pulse = 0.3 + (math.sin(time * 3) * 0.15) -- Oscillates between 0.15 and 0.45
    local glowPulse = 0.6 + (math.sin(time * 2) * 0.3) -- Glow ring pulse
    
    for _, crop in ipairs(foraging.activeCrops) do
        if not crop.collected then
            -- Set color based on crop type (easier identification)
            local r, g, b = 1, 1, 1
            if crop.type.itemType == "berries" then
                r, g, b = 0.5, 0.2, 0.9 -- Purple/blue berries
            elseif crop.type.itemType == "mushroom" then
                r, g, b = 0.7, 0.5, 0.3 -- Brown mushrooms
            elseif crop.type.itemType == "herbs" then
                r, g, b = 0.3, 0.9, 0.4 -- Bright green herbs
            elseif crop.type.itemType == "nuts" then
                r, g, b = 0.6, 0.4, 0.2 -- Brown nuts
            end
            
            -- Draw outer glow ring (pulsing)
            love.graphics.setColor(r, g, b, pulse * 0.5)
            love.graphics.circle("fill", crop.x, crop.y, 14)
            
            -- Draw middle glow
            love.graphics.setColor(r, g, b, pulse * 0.8)
            love.graphics.circle("fill", crop.x, crop.y, 10)
            
            -- Draw main crop circle
            love.graphics.setColor(r, g, b, 1.0)
            love.graphics.circle("fill", crop.x, crop.y, 7)
            
            -- Draw icon on top
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(crop.type.icon, crop.x - 8, crop.y - 10, 0, 0.8, 0.8)
            
            -- Draw bright highlight circle (pulsing)
            love.graphics.setColor(1, 1, 1, glowPulse * 0.7)
            love.graphics.circle("line", crop.x, crop.y, 10)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", crop.x, crop.y, 13)
            love.graphics.setLineWidth(1)
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

-- Get active crop count
function foraging.getActiveCropCount()
    local count = 0
    for _, crop in ipairs(foraging.activeCrops) do
        if not crop.collected then
            count = count + 1
        end
    end
    return count
end

-- Clean up old collected crops (optional cleanup)
function foraging.cleanup()
    for i = #foraging.activeCrops, 1, -1 do
        if foraging.activeCrops[i].collected then
            table.remove(foraging.activeCrops, i)
        end
    end
end

-- Force spawn crops for testing
function foraging.forceSpawn()
    foraging.spawnDailyCrops()
    print("🧪 Force spawned wild crops for testing")
end

return foraging