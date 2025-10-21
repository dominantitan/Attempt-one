-- Player System
-- Handles player movement, input, and state management

local player = {}

-- Player properties
player.x = 400
player.y = 300
player.speed = 200
player.width = 32
player.height = 32
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
        -- CABIN INTERIOR BOUNDARIES (larger - full floor rectangle)
        player.x = math.max(20, math.min(460, player.x))
        player.y = math.max(20, math.min(300, player.y))
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
    -- Draw player sprite
    love.graphics.setColor(0.2, 0.8, 0.3) -- Green player color
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    love.graphics.setColor(1, 1, 1)
end

function player.getPosition()
    return player.x, player.y
end

function player.getBounds()
    return player.x, player.y, player.width, player.height
end

return player