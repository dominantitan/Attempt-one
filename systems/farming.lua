-- Simple Farming System (MVP)
-- Basic plant -> water -> harvest loop
-- Complex features commented out for future expansion

local farming = {}

-- Simple crop data
farming.crops = {}

--[[ HARDCORE MODE - COMMENTED OUT FOR MVP
farming.weather = "normal" -- normal, drought, storm, frost, heat
farming.weatherTimer = 0
farming.soilQuality = 0.3
farming.pestLevel = 0.4
--]]

-- Crop definitions - HARDER for risk/reward balance (hunting should be more appealing)
farming.cropTypes = {
    carrot = { 
        growTime = 60, -- 1 minute (slower)
        waterNeeded = 3, -- Needs watering 3 times (more work)
        value = 4, -- Lower value (less profit)
        --[[ HARDCORE MODE - COMMENTED OUT
        droughtTolerance = 0.2,
        frostTolerance = 0.1,
        pestResistance = 0.3,
        soilRequirement = 0.4,
        failureRate = 0.4
        --]]
    },
    potato = { 
        growTime = 90, -- 1.5 minutes (much slower)
        waterNeeded = 4, -- Needs even more water
        value = 7, -- Lower value
        --[[ HARDCORE MODE - COMMENTED OUT
        droughtTolerance = 0.4,
        frostTolerance = 0.6,
        pestResistance = 0.2,
        soilRequirement = 0.6,
        failureRate = 0.3
        --]]
    },
    mushroom = { 
        growTime = 120, -- 2 minutes (very slow)
        waterNeeded = 3,
        value = 10, -- Lower value
        --[[ HARDCORE MODE - COMMENTED OUT
        droughtTolerance = 0.1,
        frostTolerance = 0.8,
        pestResistance = 0.7,
        soilRequirement = 0.2,
        failureRate = 0.5
        --]]
    }
}

-- Farming plots in 2x3 grid
farming.plotSize = 32
farming.plotSpacing = 8
farming.farmX = 575  -- Match world.lua farm structure at (565, 325)
farming.farmY = 335
farming.plots = {}

function farming.load()
    -- Initialize simple farming system
    
    -- Create 2x3 farm grid (6 plots total)
    farming.plots = {}
    for row = 0, 1 do
        for col = 0, 2 do
            local plotIndex = row * 3 + col + 1
            farming.plots[plotIndex] = {
                x = farming.farmX + col * (farming.plotSize + farming.plotSpacing),
                y = farming.farmY + row * (farming.plotSize + farming.plotSpacing),
                crop = nil,
                waterLevel = 0,
                --[[ HARDCORE MODE - COMMENTED OUT
                soilQuality = 0.1 + math.random() * 0.2,
                pestDamage = 0,
                diseased = false,
                lastWatered = 0
                --]]
            }
        end
    end
    
    print("🌾 Farming system initialized with 6 plots at (" .. farming.farmX .. ", " .. farming.farmY .. ")")
    print("   Plot size: " .. farming.plotSize .. "x" .. farming.plotSize)
end

function farming.update(dt)
    -- Harder crop growth system - punishes under-watering more
    for i, plot in ipairs(farming.plots) do
        if plot.crop then
            local crop = plot.crop
            local cropType = farming.cropTypes[crop.type]
            
            -- Harsh growth penalty without enough water
            local growthSpeed = 1.0
            if plot.waterLevel < cropType.waterNeeded then
                growthSpeed = 0.1 -- MUCH slower without full water (was 0.3)
            end
            
            crop.growthTime = crop.growthTime + (dt * growthSpeed)
            
            -- Check if crop is ready to harvest
            if crop.growthTime >= cropType.growTime then
                crop.ready = true
            end
        end
    end
    
    --[[ HARDCORE MODE - COMMENTED OUT FOR MVP
    -- Weather system
    farming.weatherTimer = farming.weatherTimer - dt
    if farming.weatherTimer <= 0 then
        farming.changeWeather()
        farming.weatherTimer = math.random(20, 40)
    end
    
    -- Complex growth modifiers
    local growthMultiplier = 1.0
    if plot.waterLevel < cropType.waterNeeded then
        growthMultiplier = growthMultiplier * 0.3
        crop.stress = (crop.stress or 0) + dt * 2
    end
    if plot.soilQuality < cropType.soilRequirement then
        growthMultiplier = growthMultiplier * (plot.soilQuality / cropType.soilRequirement)
    end
    
    -- Weather effects
    if farming.weather == "drought" and cropType.droughtTolerance < 0.5 then
        growthMultiplier = growthMultiplier * 0.1
        crop.stress = (crop.stress or 0) + dt * 3
    end
    
    -- Pest attacks
    if math.random() < farming.pestLevel * dt * 0.5 then
        plot.pestDamage = plot.pestDamage + math.random(5, 15)
        if plot.pestDamage > 50 then
            crop.dead = true
        end
    end
    
    -- Disease outbreaks
    if not plot.diseased and math.random() < 0.002 * dt then
        plot.diseased = true
        crop.stress = (crop.stress or 0) + 20
    end
    
    -- Crop death from stress
    if (crop.stress or 0) > 100 then
        crop.dead = true
    end
    
    -- Water evaporation
    plot.waterLevel = math.max(0, plot.waterLevel - dt * 2)
    
    -- Soil degradation
    plot.soilQuality = math.max(0.05, plot.soilQuality - dt * 0.001)
    --]]
end

function farming.draw()
    -- Draw farming plots with clear visual feedback
    
    if #farming.plots == 0 then
        return -- Silently skip if not initialized
    end
    
    for i, plot in ipairs(farming.plots) do
        local x, y = plot.x, plot.y
        
        -- Plot background (brown soil) - MORE VISIBLE
        love.graphics.setColor(0.5, 0.3, 0.15)
        love.graphics.rectangle("fill", x, y, farming.plotSize, farming.plotSize)
        
        -- Plot border (visible but clean)
        love.graphics.setColor(0.7, 0.5, 0.3)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, farming.plotSize, farming.plotSize)
        love.graphics.setLineWidth(1)
        
        -- Draw crop if present
        if plot.crop then
            local crop = plot.crop
            local cropType = farming.cropTypes[crop.type]
            local centerX = x + farming.plotSize / 2
            local centerY = y + farming.plotSize / 2
            
            if crop.ready then
                -- Ready to harvest - bright green
                love.graphics.setColor(0.2, 0.9, 0.2)
                love.graphics.circle("fill", centerX, centerY, 12)
            else
                -- Growing - size shows progress
                local progress = crop.growthTime / cropType.growTime
                local size = 4 + (progress * 8)
                love.graphics.setColor(0.3, 0.6, 0.2)
                love.graphics.circle("fill", centerX, centerY, size)
            end
            
            -- Simple water level indicator
            local statusY = y + farming.plotSize + 2
            local waterPercent = math.min(1.0, plot.waterLevel / cropType.waterNeeded)
            if waterPercent >= 1.0 then
                love.graphics.setColor(0.2, 0.8, 1) -- Blue for watered
            else
                love.graphics.setColor(1, 0.4, 0.2) -- Orange for dry
            end
            love.graphics.rectangle("fill", x, statusY, farming.plotSize * waterPercent, 3)
        else
            -- Empty plot
            love.graphics.setColor(0.5, 0.5, 0.5, 0.3)
            love.graphics.circle("line", x + farming.plotSize/2, y + farming.plotSize/2, 8)
        end
    end
    
    love.graphics.setColor(1, 1, 1) -- Reset color
    
    --[[ HARDCORE MODE - COMMENTED OUT FOR MVP
    -- Complex visual indicators
    love.graphics.print("Weather: " .. farming.weather, 10, 50)
    love.graphics.print("Soil Quality: " .. string.format("%.1f%%", farming.soilQuality * 100), 10, 70)
    love.graphics.print("Pest Level: " .. string.format("%.1f%%", farming.pestLevel * 100), 10, 90)
    
    -- Soil quality coloring
    local soilColor = plot.soilQuality
    love.graphics.setColor(0.2 + soilColor * 0.3, 0.1 + soilColor * 0.2, 0.05)
    
    -- Dead crop indicator
    if crop.dead then
        love.graphics.setColor(0.2, 0.1, 0.1)
        love.graphics.circle("fill", centerX, centerY, 8)
        love.graphics.print("�", centerX - 8, centerY - 8)
    end
    
    -- Health-based coloring
    local health = 1.0 - math.min(1.0, (crop.stress or 0) / 100)
    love.graphics.setColor(0.2 * health, 0.8 * health, 0.2 * health)
    
    -- Disease indicator
    if plot.diseased then
        love.graphics.print("🦠", x + farming.plotSize - 15, y + 2)
    end
    
    -- Pest damage indicator
    if plot.pestDamage > 10 then
        love.graphics.print("🐛", x + 2, y + 2)
    end
    --]]
end

function farming.getPlotAt(x, y)
    -- Find which plot the player is standing at (with more lenient detection)
    for i, plot in ipairs(farming.plots) do
        -- Add 10 pixel buffer for easier interaction
        if x >= plot.x - 10 and x <= plot.x + farming.plotSize + 10 and 
           y >= plot.y - 10 and y <= plot.y + farming.plotSize + 10 then
            return i, plot
        end
    end
    return nil
end

function farming.plantSeed(x, y, seedType)
    local plotIndex, plot = farming.getPlotAt(x, y)
    
    if not plot then
        return false, "Not on a farm plot"
    end
    
    if plot.crop then
        return false, "Plot already has a crop"
    end
    
    local cropType = farming.cropTypes[seedType]
    if not cropType then
        return false, "Unknown seed type: " .. tostring(seedType)
    end
    
    -- Plant the crop
    plot.crop = {
        type = seedType,
        growthTime = 0,
        planted = true,
        ready = false
    }
    
    print("🌱 Planted " .. seedType)
    return true, "Planted " .. seedType
    
    --[[ HARDCORE MODE - COMMENTED OUT FOR MVP
    -- Soil quality check
    if plot.soilQuality < cropType.soilRequirement then
        return false, "Soil too poor for " .. seedType
    end
    
    -- Initial stress
    plot.crop.stress = math.random(0, 20)
    plot.crop.dead = false
    
    -- Environmental stress
    if farming.weather == "drought" then
        plot.crop.stress = plot.crop.stress + 30
    elseif farming.weather == "frost" then
        plot.crop.stress = plot.crop.stress + 20
    end
    
    return true, "Planted " .. seedType .. " (survival chance: " .. 
           string.format("%.0f%%", (1 - cropType.failureRate) * 100) .. ")"
    --]]
end

function farming.harvestCrop(x, y)
    local plotIndex, plot = farming.getPlotAt(x, y)
    if not plot then
        return nil, 0, "Not on a farm plot"
    end
    
    if not plot.crop then
        return nil, 0, "Nothing planted here"
    end
    
    local crop = plot.crop
    local cropType = farming.cropTypes[crop.type]
    
    if not crop.ready then
        local timeLeft = cropType.growTime - crop.growthTime
        local waterStatus = plot.waterLevel >= cropType.waterNeeded and "(fully watered)" or "(needs water!)"
        return nil, 0, "Not ready - " .. string.format("%.0f", timeLeft) .. "s left " .. waterStatus
    end
    
    -- Low yields (farming is barely profitable)
    local yield = math.random(1, 2) -- Only 1-2 crops per harvest
    local totalValue = yield * cropType.value
    
    -- Clear plot for next planting
    plot.crop = nil
    plot.waterLevel = 0
    
    print("🌾 Harvested " .. yield .. " " .. crop.type .. " (worth $" .. totalValue .. ")")
    return crop.type, yield, "Harvested " .. yield .. " " .. crop.type
    
    --[[ HARDCORE MODE - COMMENTED OUT FOR MVP
    -- Dead crop check
    if crop.dead then
        plot.crop = nil
        return nil, 0, "Crop died - harvest failed!"
    end
    
    -- Complex yield calculation
    local baseYield = math.random(cropType.yield.min, cropType.yield.max)
    local health = 1.0 - math.min(1.0, (crop.stress or 0) / 100)
    local actualYield = math.max(1, math.floor(baseYield * health * plot.soilQuality))
    
    -- Random failure at harvest
    if math.random() < cropType.failureRate then
        plot.crop = nil
        plot.soilQuality = plot.soilQuality - 0.1
        return nil, 0, "Crop failed at harvest!"
    end
    
    -- Soil degradation
    plot.soilQuality = plot.soilQuality - 0.05
    plot.pestDamage = 0
    plot.diseased = false
    --]]
end

function farming.waterCrop(x, y)
    local plotIndex, plot = farming.getPlotAt(x, y)
    if not plot then
        return false, "Not on a farm plot"
    end
    
    if not plot.crop then
        return false, "No crop to water"
    end
    
    local cropType = farming.cropTypes[plot.crop.type]
    
    -- Add water to plot
    plot.waterLevel = plot.waterLevel + 1
    
    local status = plot.waterLevel >= cropType.waterNeeded and "✓ Fully watered!" or "Needs more"
    return true, "Watered (" .. plot.waterLevel .. "/" .. cropType.waterNeeded .. ") " .. status
    
    --[[ HARDCORE MODE - COMMENTED OUT FOR MVP
    -- Weather-affected watering
    local waterAmount = 2
    if farming.weather == "drought" then
        waterAmount = 1
    elseif farming.weather == "storm" then
        waterAmount = 3
    end
    
    plot.waterLevel = math.min(cropType.waterNeeded, plot.waterLevel + waterAmount)
    plot.lastWatered = 0
    
    -- Stress reduction
    if plot.waterLevel >= cropType.waterNeeded * 0.8 then
        plot.crop.stress = math.max(0, (plot.crop.stress or 0) - 5)
    end
    --]]
end

function farming.getInfo()
    return {
        weather = farming.weather,
        weatherTimer = farming.weatherTimer,
        soilQuality = farming.soilQuality,
        pestLevel = farming.pestLevel,
        plotCount = #farming.plots,
        activeCrops = farming.getActiveCropCount()
    }
end

function farming.getActiveCropCount()
    local count = 0
    for _, plot in ipairs(farming.plots) do
        if plot.crop and not plot.crop.dead then
            count = count + 1
        end
    end
    return count
end

return farming