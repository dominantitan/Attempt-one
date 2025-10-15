-- Day/Night Cycle System
-- Manages time progression, lighting, and atmospheric effects

local daynight = {}

-- Time properties
daynight.time = 0.5 -- 0 = midnight, 0.5 = noon, 1 = midnight again
daynight.dayLength = 300 -- 5 minutes per day cycle
daynight.dayCount = 0 -- Track total days passed
daynight.isDay = true
daynight.isDusk = false
daynight.isDawn = false
daynight.isNight = false

-- Lighting properties
daynight.ambientLight = 1.0
daynight.dangerLevel = 0 -- Increases at night

function daynight.load()
    -- Initialize day/night system
end

function daynight.update(dt)
    local previousTime = daynight.time
    
    -- Progress time
    daynight.time = daynight.time + (dt / daynight.dayLength)
    
    -- Keep time within 0-1 range and track day changes
    if daynight.time >= 1.0 then
        daynight.time = daynight.time - 1.0
        daynight.dayCount = daynight.dayCount + 1
        print("🌅 Day " .. daynight.dayCount .. " begins!")
    end
    
    -- Determine time of day
    if daynight.time >= 0.25 and daynight.time < 0.75 then
        daynight.isDay = true
        daynight.isNight = false
        daynight.isDawn = (daynight.time >= 0.2 and daynight.time < 0.3)
        daynight.isDusk = (daynight.time >= 0.7 and daynight.time < 0.8)
    else
        daynight.isDay = false
        daynight.isNight = true
        daynight.isDawn = false
        daynight.isDusk = false
    end
    
    -- Calculate ambient light level
    if daynight.isDay then
        daynight.ambientLight = 1.0
        daynight.dangerLevel = 0
    elseif daynight.isDawn or daynight.isDusk then
        daynight.ambientLight = 0.7
        daynight.dangerLevel = 0.3
    else
        daynight.ambientLight = 0.3
        daynight.dangerLevel = 0.8
    end
end

function daynight.draw()
    -- Apply day/night overlay
    local overlayColor = {0, 0, 0, 1 - daynight.ambientLight}
    
    if daynight.isDusk then
        overlayColor = {0.3, 0.1, 0, 0.4} -- Orange tint for dusk
    elseif daynight.isDawn then
        overlayColor = {0.2, 0.2, 0.4, 0.3} -- Blue tint for dawn
    elseif daynight.isNight then
        overlayColor = {0, 0, 0.2, 0.7} -- Dark blue for night
    end
    
    -- Draw overlay
    love.graphics.setColor(overlayColor)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function daynight.getTimeString()
    local hour = math.floor(daynight.time * 24)
    if hour == 0 then hour = 24 end
    
    if daynight.isDay then
        return hour .. ":00 (Day)"
    else
        return hour .. ":00 (Night)"
    end
end

function daynight.isDangerous()
    return daynight.dangerLevel > 0.5
end

return daynight