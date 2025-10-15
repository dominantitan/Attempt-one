-- Inventory State
-- Manages player inventory display and item management

local inventory = {}

function inventory:enter()
    print("Opening inventory")
end

function inventory:update(dt)
    -- Handle inventory interactions
end

function inventory:draw()
    -- Draw inventory grid, items, and UI
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("INVENTORY", 50, 50)
    love.graphics.print("Press ESC to close", 50, 100)
end

function inventory:keypressed(key)
    if key == "escape" or key == "i" then
        -- Return to gameplay
        local gamestate = require("states/gamestate")
        gamestate.switch("gameplay")
    end
end

function inventory:exit()
    -- Cleanup inventory state
end

return inventory