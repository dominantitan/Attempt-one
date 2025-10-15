-- Crops Entity
-- Defines crop types, growth stages, and farming mechanics

local crops = {}

-- Crop type definitions
crops.types = {
    carrot = {
        name = "Carrot",
        growthStages = {"seed", "sprout", "growing", "mature"},
        growthTime = 45, -- seconds to fully grow
        waterNeeded = 3,
        yield = {min = 1, max = 3},
        nutrition = 15,
        value = 5,
        color = {1, 0.5, 0} -- Orange
    },
    potato = {
        name = "Potato",
        growthStages = {"seed", "sprout", "growing", "mature"},
        growthTime = 60,
        waterNeeded = 4,
        yield = {min = 2, max = 4},
        nutrition = 25,
        value = 8,
        color = {0.8, 0.7, 0.4} -- Tan
    },
    mushroom = {
        name = "Mushroom",
        growthStages = {"spore", "mycelium", "budding", "mature"},
        growthTime = 30,
        waterNeeded = 2,
        yield = {min = 1, max = 2},
        nutrition = 10,
        value = 12,
        color = {0.6, 0.4, 0.3} -- Brown
    },
    berry = {
        name = "Berry",
        growthStages = {"seed", "vine", "flowering", "fruiting"},
        growthTime = 75,
        waterNeeded = 5,
        yield = {min = 3, max = 6},
        nutrition = 8,
        value = 4,
        color = {0.8, 0.2, 0.4} -- Red
    }
}

-- Active crops in the world
crops.planted = {}

function crops.create(cropType, x, y)
    local cropData = crops.types[cropType]
    if not cropData then return nil end
    
    local crop = {
        type = cropType,
        x = x,
        y = y,
        stage = 1, -- Growth stage (1-4)
        growthProgress = 0,
        waterLevel = 0,
        ready = false,
        withered = false,
        lastWatered = 0
    }
    
    return crop
end

function crops.plant(cropType, x, y)
    local crop = crops.create(cropType, x, y)
    if crop then
        table.insert(crops.planted, crop)
        return crop
    end
    return nil
end

function crops.update(dt)
    for i = #crops.planted, 1, -1 do
        local crop = crops.planted[i]
        
        if crop.withered then
            table.remove(crops.planted, i)
        else
            crops.updateCrop(crop, dt)
        end
    end
end

function crops.updateCrop(crop, dt)
    local cropData = crops.types[crop.type]
    
    -- Check if crop needs water
    crop.lastWatered = crop.lastWatered + dt
    
    if crop.lastWatered > 120 and crop.waterLevel < cropData.waterNeeded then
        -- Crop withers if not watered for 2 minutes and needs water
        crop.withered = true
        return
    end
    
    -- Grow crop if conditions are met
    if crop.waterLevel >= cropData.waterNeeded and not crop.ready then
        crop.growthProgress = crop.growthProgress + dt
        
        -- Calculate current growth stage
        local stageProgress = crop.growthProgress / cropData.growthTime
        crop.stage = math.min(4, math.floor(stageProgress * 4) + 1)
        
        -- Check if crop is fully grown
        if crop.growthProgress >= cropData.growthTime then
            crop.ready = true
            crop.stage = 4
        end
    end
end

function crops.draw()
    for _, crop in ipairs(crops.planted) do
        local cropData = crops.types[crop.type]
        
        -- Draw soil plot
        love.graphics.setColor(0.4, 0.2, 0.1) -- Brown soil
        love.graphics.rectangle("fill", crop.x, crop.y, 32, 32)
        
        -- Draw crop based on growth stage
        if crop.withered then
            love.graphics.setColor(0.3, 0.2, 0.1) -- Withered brown
            love.graphics.rectangle("fill", crop.x + 8, crop.y + 8, 16, 16)
        elseif crop.stage > 1 then
            -- Adjust color based on growth stage
            local intensity = crop.stage / 4
            local color = cropData.color
            love.graphics.setColor(color[1] * intensity, color[2] * intensity, color[3] * intensity)
            
            -- Size increases with growth
            local size = 8 + (crop.stage * 4)
            local offset = (32 - size) / 2
            love.graphics.rectangle("fill", crop.x + offset, crop.y + offset, size, size)
        end
        
        -- Draw water indicator
        if crop.waterLevel > 0 then
            love.graphics.setColor(0.2, 0.4, 0.8) -- Blue water
            local waterBars = math.min(4, crop.waterLevel)
            for i = 1, waterBars do
                love.graphics.rectangle("fill", crop.x + (i * 6), crop.y + 2, 4, 2)
            end
        end
    end
    
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function crops.waterCrop(x, y)
    for _, crop in ipairs(crops.planted) do
        local distance = math.sqrt((crop.x - x)^2 + (crop.y - y)^2)
        if distance < 40 then
            crop.waterLevel = crop.waterLevel + 1
            crop.lastWatered = 0
            return true
        end
    end
    return false
end

function crops.harvestCrop(x, y)
    for i, crop in ipairs(crops.planted) do
        local distance = math.sqrt((crop.x - x)^2 + (crop.y - y)^2)
        if distance < 40 and crop.ready then
            local cropData = crops.types[crop.type]
            local yield = math.random(cropData.yield.min, cropData.yield.max)
            
            table.remove(crops.planted, i)
            return crop.type, yield
        end
    end
    return nil, 0
end

function crops.getCropAt(x, y)
    for _, crop in ipairs(crops.planted) do
        local distance = math.sqrt((crop.x - x)^2 + (crop.y - y)^2)
        if distance < 40 then
            return crop
        end
    end
    return nil
end

function crops.canPlantAt(x, y)
    -- Check if location is suitable for planting
    local crop = crops.getCropAt(x, y)
    return crop == nil -- Can plant if no crop exists at location
end

function crops.clearAll()
    crops.planted = {}
end

return crops