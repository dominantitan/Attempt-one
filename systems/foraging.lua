-- Foraging System
-- Manages daily spawning of wild crops/forage items throughout the forest

local foraging = {}

-- Wild crop types and their properties
foraging.wildCropTypes = {
    {
        name = "Wild Berries",
        icon = "🫐",
        value = 3,
        rarity = 0.4, -- 40% chance when spawning
        nutrition = 15,
        description = "Sweet berries found on wild bushes"
    },
    {
        name = "Mushrooms",
        icon = "🍄",
        value = 5,
        rarity = 0.3, -- 30% chance when spawning
        nutrition = 20,
        description = "Earthy mushrooms growing near trees"
    },
    {
        name = "Wild Herbs",
        icon = "🌿",
        value = 8,
        rarity = 0.2, -- 20% chance when spawning
        nutrition = 10,
        description = "Medicinal herbs with healing properties"
    },
    {
        name = "Pine Nuts",
        icon = "🌰",
        value = 6,
        rarity = 0.1, -- 10% chance when spawning
        nutrition = 25,
        description = "Nutritious nuts from pine cones"
    }
}

-- Current wild crops on the map
foraging.activeCrops = {}

-- Spawn settings
foraging.dailySpawnCount = {min = 1, max = 2}
foraging.lastSpawnDay = -1

-- Forest boundaries (avoid spawning on structures)
foraging.forestBounds = {
    x = 50,
    y = 50,
    width = 860,
    height = 440
}

-- Areas to avoid (structures, etc.)
foraging.avoidAreas = {
    {x = 450, y = 300, width = 100, height = 100}, -- Cabin area
    {x = 555, y = 315, width = 140, height = 100}, -- Farm area
    {x = 570, y = 535, width = 120, height = 80},  -- Pond area
    {x = 180, y = 610, width = 100, height = 80},  -- Shop area
    {x = 120, y = 400, width = 140, height = 100}, -- Railway station area
    {x = 120, y = 120, radius = 90},               -- NW hunting zone
    {x = 820, y = 120, radius = 90},               -- NE hunting zone
    {x = 820, y = 400, radius = 90}                -- SE hunting zone
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
        
        -- Add to player inventory
        local playerEntity = require("entities/player")
        playerEntity.addItem(crop.type.name, 1)
        
        print("🌿 Collected " .. crop.type.icon .. " " .. crop.type.name .. "!")
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
            -- Set color based on crop type
            local r, g, b = 1, 1, 1
            if crop.type.name == "Wild Berries" then
                r, g, b = 0.4, 0.1, 0.8 -- Purple berries
            elseif crop.type.name == "Mushrooms" then
                r, g, b = 0.6, 0.4, 0.2 -- Brown mushrooms
            elseif crop.type.name == "Wild Herbs" then
                r, g, b = 0.2, 0.8, 0.3 -- Green herbs
            elseif crop.type.name == "Pine Nuts" then
                r, g, b = 0.5, 0.3, 0.1 -- Brown nuts
            end
            
            -- Draw outer glow ring (pulsing)
            love.graphics.setColor(r, g, b, pulse * 0.4)
            love.graphics.circle("fill", crop.x, crop.y, 12)
            
            -- Draw middle glow
            love.graphics.setColor(r, g, b, pulse * 0.7)
            love.graphics.circle("fill", crop.x, crop.y, 9)
            
            -- Draw main crop circle
            love.graphics.setColor(r, g, b, 1.0)
            love.graphics.circle("fill", crop.x, crop.y, 6)
            
            -- Draw bright highlight circle (pulsing)
            love.graphics.setColor(1, 1, 1, glowPulse)
            love.graphics.circle("line", crop.x, crop.y, 8)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", crop.x, crop.y, 10)
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