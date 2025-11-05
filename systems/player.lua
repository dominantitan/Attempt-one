-- Player System
-- Handles player movement, input, and state management

local player = {}

-- Player properties (scaled 3x for expanded world)
-- Spawn at center of railway station
player.x = 570  -- Railway station center (was 400)
player.y = 1350 -- Railway station center (was 300)
player.speed = 300  -- Was 200 (scaled 1.5x for better feel)
player.width = 48   -- Was 32 (scaled 1.5x)
player.height = 48  -- Was 32 (scaled 1.5x)
player.health = 100
player.stamina = 100

-- Movement state
player.isMoving = false
player.direction = "down"

function player.load()
    -- Initialize player sprites and animations
end

function player.update(dt)
    -- Don't update if game is paused
    if Game and Game.paused then
        return
    end
    
    local dx, dy = 0, 0
    
    -- WASD movement
    if love.keyboard.isDown("w", "up") then
        dy = -1
        player.direction = "up"
        player.isMoving = true
    elseif love.keyboard.isDown("s", "down") then
        dy = 1
        player.direction = "down"
        player.isMoving = true
    end
    
    if love.keyboard.isDown("a", "left") then
        dx = -1
        player.direction = "left"
        player.isMoving = true
    elseif love.keyboard.isDown("d", "right") then
        dx = 1
        player.direction = "right"
        player.isMoving = true
    end
    
    -- Normalize diagonal movement
    if dx ~= 0 and dy ~= 0 then
        dx = dx * 0.707
        dy = dy * 0.707
    end
    
    -- Update position
    player.x = player.x + dx * player.speed * dt
    player.y = player.y + dy * player.speed * dt
    
    -- ENFORCE BOUNDARIES (area-specific)
    local areas = require("systems/areas")
    local currentArea = areas.getCurrentArea()
    
    if currentArea and currentArea.type == "interior" and currentArea.name == "Uncle's Cabin" then
        -- CABIN INTERIOR BOUNDARIES (larger - full floor rectangle - scaled 3x)
        player.x = math.max(60, math.min(1380, player.x))  -- Scaled 3x
        player.y = math.max(60, math.min(900, player.y))   -- Scaled 3x
    else
        -- OVERWORLD BOUNDARIES - Keep player within playable area
        local world = require("systems/world")
        player.x = math.max(world.bounds.left, math.min(world.bounds.right, player.x))
        player.y = math.max(world.bounds.top, math.min(world.bounds.bottom, player.y))
    end
    
    -- Check if player is moving
    player.isMoving = dx ~= 0 or dy ~= 0
    
    -- Update animations based on movement and direction
end

function player.draw()
    -- Draw player sprite with better visibility
    -- Body (bright green)
    love.graphics.setColor(0.2, 0.9, 0.3) -- Brighter green
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
    -- Outline (white border for visibility)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", player.x, player.y, player.width, player.height)
    
    -- Direction indicator (small circle showing facing direction)
    love.graphics.setColor(1, 1, 0) -- Yellow indicator
    local centerX = player.x + player.width / 2
    local centerY = player.y + player.height / 2
    local indicatorOffset = 8
    
    if player.direction == "up" then
        love.graphics.circle("fill", centerX, centerY - indicatorOffset, 4)
    elseif player.direction == "down" then
        love.graphics.circle("fill", centerX, centerY + indicatorOffset, 4)
    elseif player.direction == "left" then
        love.graphics.circle("fill", centerX - indicatorOffset, centerY, 4)
    elseif player.direction == "right" then
        love.graphics.circle("fill", centerX + indicatorOffset, centerY, 4)
    end
    
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
end

function player.getPosition()
    return player.x, player.y
end

function player.getBounds()
    return player.x, player.y, player.width, player.height
end

return player