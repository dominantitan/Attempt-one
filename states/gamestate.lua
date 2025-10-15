-- Game State Management
-- Handles switching between different game states (menu, gameplay, inventory, etc.)

local gamestate = {}

-- State variables
gamestate.current = nil
gamestate.states = {}

-- Register a new state
function gamestate.register(name, state)
    gamestate.states[name] = state
end

-- Switch to a different state
function gamestate.switch(name, ...)
    if gamestate.current and gamestate.current.exit then
        gamestate.current:exit()
    end
    
    gamestate.current = gamestate.states[name]
    
    if gamestate.current and gamestate.current.enter then
        gamestate.current:enter(...)
    end
end

-- Update current state
function gamestate.update(dt)
    if gamestate.current and gamestate.current.update then
        gamestate.current:update(dt)
    end
end

-- Draw current state
function gamestate.draw()
    if gamestate.current and gamestate.current.draw then
        gamestate.current:draw()
    end
end

-- Handle input for current state
function gamestate.keypressed(key)
    if gamestate.current and gamestate.current.keypressed then
        gamestate.current:keypressed(key)
    end
end

-- Handle mouse press for current state
function gamestate.mousepressed(x, y, button)
    if gamestate.current and gamestate.current.mousepressed then
        gamestate.current:mousepressed(x, y, button)
    end
end

return gamestate