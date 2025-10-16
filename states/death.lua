-- Death Screen State
-- Shown when player is caught by tiger

local death = {}

function death:enter()
    print("💀 Death screen entered")
    
    -- Get day counter for score
    local daynightSystem = require("systems/daynight")
    death.daysSurvived = daynightSystem.dayCount or 1
end

function death:update(dt)
    -- Check for restart
    if love.keyboard.isDown("return") or love.keyboard.isDown("space") then
        death:restart()
    end
end

function death:draw()
    -- Black background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, 960, 540)
    
    -- Red title
    love.graphics.setColor(1, 0, 0)
    love.graphics.setNewFont(48)
    love.graphics.printf("YOU DIED", 0, 100, 960, "center")
    
    -- Tiger emoji and message
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(32)
    love.graphics.printf("🐅", 0, 180, 960, "center")
    love.graphics.setNewFont(24)
    love.graphics.printf("The tiger caught you!", 0, 240, 960, "center")
    
    -- Days survived
    love.graphics.setColor(1, 1, 0.5)
    love.graphics.setNewFont(28)
    love.graphics.printf("You survived " .. death.daysSurvived .. " days", 0, 300, 960, "center")
    
    -- Restart prompt (flashing)
    local flash = math.sin(love.timer.getTime() * 3) > 0
    if flash then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setNewFont(20)
        love.graphics.printf("Press ENTER or SPACE to restart", 0, 400, 960, "center")
    end
    
    -- Reset font
    love.graphics.setNewFont(12)
end

function death:restart()
    print("♻️  Restarting game...")
    
    -- Reset game state
    if Game then
        Game.tigerChasing = false
        Game.tigerWarning = false
    end
    
    -- Reset world
    local worldSystem = require("systems/world")
    worldSystem.tigerChase = nil
    
    -- Reset player
    local playerSystem = require("systems/player")
    playerSystem.x = 460 + 40 -- Center of cabin
    playerSystem.y = 310 + 40
    
    -- Reset player entity (inventory, health, etc.) - use load() for proper initialization
    local playerEntity = require("entities/player")
    playerEntity.load() -- This properly initializes inventory with starting items
    
    -- Reset day/night cycle
    local daynightSystem = require("systems/daynight")
    daynightSystem.time = 0.25 -- Morning
    daynightSystem.dayCount = 1
    
    -- Switch back to gameplay
    local gamestate = require("states/gamestate")
    gamestate.switch("gameplay")
end

function death:keypressed(key)
    if key == "return" or key == "space" then
        death:restart()
    end
end

return death
