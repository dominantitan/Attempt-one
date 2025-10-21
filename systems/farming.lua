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

-- Crop definitions - Takes 2-3 in-game days to grow (1 day = 300 seconds)
farming.cropTypes = {
    carrot = { 
        growTime = 600, -- 2 in-game days (10 real minutes)
        waterNeeded = 1, -- Needs watering once per day
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
        growTime = 750, -- 2.5 in-game days (12.5 real minutes)
        waterNeeded = 1, -- Needs watering once per day
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
        growTime = 900, -- 3 in-game days (15 real minutes)
        waterNeeded = 1, -- Needs watering once per day
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
                wateredRecently = false, -- Visual indicator flag
                wateredTime = 0, -- Time since last watered (for sparkle effect)
                lastWateredDay = -1, -- Track which day it was last watered
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
    -- Get current day for daily watering check
    local daynightSystem = require("systems/daynight")
    local currentDay = math.floor(daynightSystem.dayCount or 0)
    
    -- Harder crop growth system - punishes under-watering more
    for i, plot in ipairs(farming.plots) do
        if plot.crop then
            local crop = plot.crop
            local cropType = farming.cropTypes[crop.type]
            
            -- SIMPLIFIED DAILY WATERING: Just check if watered today
            local wateredToday = (plot.lastWateredDay == currentDay)
            
            -- Growth speed calculation (simple: watered = grow, not watered = stop)
            local growthSpeed = 0
            
            if wateredToday then
                -- Watered today - normal growth at full speed
                growthSpeed = 1.0
                crop.needsWater = false
            else
                -- NOT watered today - crop stops growing completely!
                growthSpeed = 0.0
                crop.needsWater = true -- Flag for visual indicator
            end
            
            -- Add growth with debug output every 5 seconds
            if not crop.lastDebugTime then crop.lastDebugTime = 0 end
            crop.lastDebugTime = crop.lastDebugTime + dt
            
            if crop.lastDebugTime >= 5 then
                print(string.format("🌱 Crop growth: %.1fs/%.0fs (%.1f%%), Speed: %.1fx, Day: %d, Watered: %s",
                    crop.growthTime, cropType.growTime, (crop.growthTime/cropType.growTime)*100,
                    growthSpeed, currentDay, tostring(wateredToday)))
                crop.lastDebugTime = 0
            end
            
            crop.growthTime = crop.growthTime + (dt * growthSpeed)
            
            -- Check if crop is ready to harvest
            if crop.growthTime >= cropType.growTime then
                crop.ready = true
            end
        end
        
        -- Update watered sparkle effect timer
        if plot.wateredRecently then
            plot.wateredTime = plot.wateredTime + dt
            if plot.wateredTime > 2.0 then -- Sparkle lasts 2 seconds
                plot.wateredRecently = false
                plot.wateredTime = 0
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
            
            -- Calculate growth stage (0-3) based on progress
            local progress = crop.growthTime / cropType.growTime
            local stage = math.floor(progress * 4) -- 0 = seed, 1 = sprout, 2 = growing, 3 = harvestable
            if crop.ready then stage = 3 end
            
            if stage == 0 then
                -- STAGE 1: Seed (brown dot)
                love.graphics.setColor(0.4, 0.25, 0.1)
                love.graphics.circle("fill", centerX, centerY, 3)
            elseif stage == 1 then
                -- STAGE 2: Sprout (small green with stem)
                love.graphics.setColor(0.5, 0.7, 0.3)
                love.graphics.circle("fill", centerX, centerY, 5)
                -- Tiny stem
                love.graphics.setColor(0.3, 0.5, 0.2)
                love.graphics.rectangle("fill", centerX - 1, centerY, 2, 4)
            elseif stage == 2 then
                -- STAGE 3: Growing (larger green plant)
                love.graphics.setColor(0.3, 0.7, 0.3)
                love.graphics.circle("fill", centerX, centerY - 2, 8)
                -- Leaves
                love.graphics.setColor(0.2, 0.6, 0.2)
                love.graphics.circle("fill", centerX - 4, centerY, 4)
                love.graphics.circle("fill", centerX + 4, centerY, 4)
            elseif stage == 3 then
                -- STAGE 4: Harvestable (full plant with glow)
                -- Outer glow
                love.graphics.setColor(0.6, 1.0, 0.4, 0.3)
                love.graphics.circle("fill", centerX, centerY, 14)
                -- Main plant
                love.graphics.setColor(0.2, 0.9, 0.2)
                love.graphics.circle("fill", centerX, centerY - 3, 10)
                -- Fruit/produce indicators
                love.graphics.setColor(0.9, 0.3, 0.2) -- Red fruits
                love.graphics.circle("fill", centerX - 5, centerY - 2, 3)
                love.graphics.circle("fill", centerX + 5, centerY - 2, 3)
                love.graphics.circle("fill", centerX, centerY - 6, 3)
            end
            
            -- NEEDS WATER WARNING (if not watered today)
            if crop.needsWater then
                local time = love.timer.getTime()
                local pulse = 0.5 + (math.sin(time * 4) * 0.5) -- Pulse between 0 and 1
                love.graphics.setColor(1, 0.2, 0.2, pulse) -- Red warning
                love.graphics.circle("line", centerX, centerY, 16)
                love.graphics.setLineWidth(2)
                love.graphics.circle("line", centerX, centerY, 18)
                love.graphics.setLineWidth(1)
            end
            
            -- Watered sparkle effect (blue sparkles for 2 seconds after watering)
            if plot.wateredRecently then
                local sparkleAlpha = 1.0 - (plot.wateredTime / 2.0) -- Fades over 2 seconds
                love.graphics.setColor(0.3, 0.7, 1.0, sparkleAlpha * 0.8)
                local time = love.timer.getTime()
                -- Animated sparkles
                for i = 1, 4 do
                    local angle = (time * 3 + i * math.pi / 2) % (math.pi * 2)
                    local dist = 8 + math.sin(time * 5 + i) * 3
                    local sx = centerX + math.cos(angle) * dist
                    local sy = centerY + math.sin(angle) * dist
                    love.graphics.circle("fill", sx, sy, 2)
                end
            end
            
            -- Water indicator ONLY for planted crops
            local statusY = y + farming.plotSize + 2
            local daynightSystem = require("systems/daynight")
            local currentDay = math.floor(daynightSystem.dayCount or 0)
            local wateredToday = (plot.lastWateredDay == currentDay)
            
            -- DEBUG: Print water status for debugging
            if plot.crop and not plot.crop._debugPrinted then
                print(string.format("🔍 VISUAL DEBUG: Plot lastWateredDay=%d, currentDay=%d, wateredToday=%s", 
                    plot.lastWateredDay or -999, currentDay, tostring(wateredToday)))
                plot.crop._debugPrinted = true
            end
            
            -- Only show water bar if there's actually a crop planted
            if plot.crop then
                if wateredToday then
                    love.graphics.setColor(0.2, 0.8, 1) -- Blue for watered today
                else
                    love.graphics.setColor(1, 0.4, 0.2) -- Orange for needs watering
                end
                love.graphics.rectangle("fill", x, statusY, farming.plotSize, 3)
            end
        else
            -- Empty plot - no visual indicator
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
        ready = false,
        needsWater = true -- Needs water immediately after planting
    }
    
    -- Initialize watering tracking for this plot (NOT watered yet!)
    print("🔍 DEBUG: Planting - Setting lastWateredDay to -1 (Day is " .. (require("systems/daynight").dayCount or 0) .. ")")
    plot.lastWateredDay = -1 -- Force to -1 so it needs watering
    
    print("🌱 Planted " .. seedType)
    print("💧 Water it now or it won't grow!")
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
    
    -- Better yields with different amounts per crop type
    local yield
    if crop.type == "carrot" then
        yield = math.random(2, 4) -- 2-4 carrots
    elseif crop.type == "potato" then
        yield = math.random(3, 5) -- 3-5 potatoes (slow but good yield)
    elseif crop.type == "mushroom" then
        yield = math.random(2, 3) -- 2-3 mushrooms (valuable but slow)
    else
        yield = math.random(1, 2) -- Default for unknown types
    end
    
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
    
    -- Get current day
    local daynightSystem = require("systems/daynight")
    local currentDay = math.floor(daynightSystem.dayCount or 0)
    
    -- Check if already watered today
    if plot.lastWateredDay == currentDay then
        return false, "Already watered today! (Day " .. currentDay .. ")"
    end
    
    -- Track that this plot was watered today
    print("🔍 DEBUG: Setting lastWateredDay from " .. (plot.lastWateredDay or "nil") .. " to " .. currentDay)
    plot.lastWateredDay = currentDay
    
    -- Clear the needs water flag
    if plot.crop then
        plot.crop.needsWater = false
    end
    
    -- Trigger sparkle effect
    plot.wateredRecently = true
    plot.wateredTime = 0
    
    -- Debug output
    print("💧 Watered plot on Day " .. currentDay .. "! Crop will now grow.")
    
    return true, "✓ Watered for today! (Day " .. currentDay .. ")"
    
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