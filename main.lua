-- Dark Survival-Farming Game
-- Main entry point and game loop

-- Game constants
local GAME_WIDTH = 960
local GAME_HEIGHT = 540
local GAME_TITLE = "Dark Forest Survival"

-- External Libraries (comment out if not installed yet)
local Camera, anim8, bump, lume, json
local librariesLoaded = false

-- Safely try to load libraries
local function loadLibraries()
    local success = true
    
    -- Try to load each library individually
    local libs = {
        {name = "hump.camera", path = "libs/hump/camera"},
        {name = "anim8", path = "libs/anim8"},
        {name = "bump", path = "libs/bump"},
        {name = "lume", path = "libs/lume"},
        {name = "json", path = "libs/json"}
    }
    
    for _, lib in ipairs(libs) do
        local ok, result = pcall(require, lib.path)
        if ok then
            if lib.name == "hump.camera" then Camera = result end
            if lib.name == "anim8" then anim8 = result end
            if lib.name == "bump" then bump = result end
            if lib.name == "lume" then lume = result end
            if lib.name == "json" then json = result end
            print("✓ Loaded " .. lib.name)
        else
            print("✗ Failed to load " .. lib.name .. " (" .. result .. ")")
            success = false
        end
    end
    
    return success
end

-- Game states
local gamestate = require("states/gamestate")

-- Register states
local gameplay = require("states/gameplay")
local inventory = require("states/inventory")
local shop = require("states/shop")

gamestate.register("gameplay", gameplay)
gamestate.register("inventory", inventory)
gamestate.register("shop", shop)

-- Core systems
local worldSystem = require("systems/world")
local playerSystem = require("systems/player")
local farmingSystem = require("systems/farming")
local huntingSystem = require("systems/hunting")
local daynightSystem = require("systems/daynight")
local audioSystem = require("systems/audio")
local foragingSystem = require("systems/foraging")

-- Entities
local playerEntity = require("entities/player")
local animalsEntity = require("entities/animals")
local cropsEntity = require("entities/crops")
local shopkeeperEntity = require("entities/shopkeeper")

-- Utilities
local cameraUtil = require("utils/camera")
local collisionUtil = require("utils/collision")
local saveUtil = require("utils/save")
local assetMap = require("utils/assetmap") -- Asset visualization overlay

-- Global game state
Game = {
    camera = nil,
    world = nil,
    player = playerEntity,
    paused = false,
    debug = false
}

function love.load()
    -- Set up window
    love.window.setTitle(GAME_TITLE)
    love.window.setMode(GAME_WIDTH, GAME_HEIGHT, {
        vsync = true,
        resizable = false,
        minwidth = GAME_WIDTH,
        minheight = GAME_HEIGHT
    })
    
    -- Try to load external libraries
    librariesLoaded = loadLibraries()
    
    -- Initialize camera (use hump.camera if available, otherwise custom)
    if Camera then
        Game.camera = Camera(GAME_WIDTH/2, GAME_HEIGHT/2)
        print("✓ Using hump.camera")
    else
        cameraUtil.load()
        Game.camera = cameraUtil
        print("✓ Using custom camera")
    end
    
    -- Initialize collision world (use bump if available)
    if bump then
        Game.world = bump.newWorld(32)
        print("✓ Using bump.lua collision")
    else
        collisionUtil.grid.init(32)
        Game.world = collisionUtil
        print("✓ Using custom collision")
    end
    
    -- Initialize all systems
    worldSystem.load()
    playerSystem.load()
    farmingSystem.load()
    huntingSystem.load()
    daynightSystem.load()
    audioSystem.load()
    foragingSystem.load()
    
    -- Initialize entities
    playerEntity.load()
    
    -- World system handles animal spawning now
    
    -- Set camera target to player
    if Game.camera.setTarget then
        Game.camera:setTarget({x = playerSystem.x, y = playerSystem.y})
    end
    
    -- Start in gameplay state
    gamestate.switch("gameplay")
    
    print("🎮 Game initialized successfully!")
    if not librariesLoaded then
        print("⚠️  Some libraries missing - run setup_libs.bat to install them")
    end
end

function love.update(dt)
    if Game.paused then return end
    
    -- Cap deltatime to prevent spiral of death
    dt = math.min(dt, 1/30)
    
    -- Update current game state (includes area system)
    gamestate.update(dt)
    
    -- Update global systems that work across all areas
    daynightSystem.update(dt)
    audioSystem.update(dt)
    foragingSystem.update(dt)
    
    -- Area-specific system updates are handled by the area system
    -- Only update world system for main world area
    local areas = require("systems/areas")
    if areas.currentArea == "main_world" then
        worldSystem.update(dt)
        farmingSystem.update(dt)
        cropsEntity.update(dt)
    end
    
    -- Update entities (handled per-area now)
    playerEntity.update(dt)
    
    -- Update camera to follow player
    if Game.camera.update then
        Game.camera:update(dt)
    end
    if Game.camera.setTarget then
        Game.camera:setTarget({x = playerSystem.x, y = playerSystem.y})
    end
end

function love.draw()
    -- Apply camera transformation
    if Game.camera.apply then
        Game.camera:apply()
    end
    
    -- Area system handles drawing area-specific elements
    -- Only draw main world elements if in main world
    local areas = require("systems/areas")
    if areas.currentArea == "main_world" then
        worldSystem.draw()
        farmingSystem.draw()
        cropsEntity.draw()
        foragingSystem.draw()
        -- shopkeeperEntity.draw() -- Removed - shopkeeper position conflicts with hunting zone
    end
    
    -- Remove camera transformation
    if Game.camera.unapply then
        Game.camera:unapply()
    end
    
    -- Draw day/night overlay
    daynightSystem.draw()
    
    -- Draw current game state (includes area rendering)
    gamestate.draw()
    
    -- Draw UI overlay
    love.graphics.setColor(1, 1, 1)
    
    -- Clean UI panel at top-right (less intrusive)
    local rightX = love.graphics.getWidth() - 180
    love.graphics.print("💰 $" .. playerEntity.inventory.money, rightX, 10)
    love.graphics.print("❤️  " .. math.floor(playerEntity.health) .. "/" .. playerEntity.maxHealth, rightX, 30)
    love.graphics.print("🕐 " .. daynightSystem.getTimeString(), rightX, 50)
    
    -- Compact inventory display (top-left, but cleaner)
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print("Inventory:", 10, 10)
    local yOffset = 25
    for _, item in ipairs(playerEntity.inventory.items) do
        love.graphics.print(item.quantity .. "x " .. item.type, 10, yOffset)
        yOffset = yOffset + 15
        if yOffset > 100 then break end -- Limit display to not overlap farm
    end
    
    -- Draw debug info (toggle with F3)
    if Game.debug then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print("DEBUG MODE", love.graphics.getWidth() - 100, 30)
        love.graphics.print("FPS: " .. love.timer.getFPS(), love.graphics.getWidth() - 100, 50)
        love.graphics.print("Player: " .. math.floor(playerSystem.x) .. ", " .. math.floor(playerSystem.y), love.graphics.getWidth() - 100, 70)
        love.graphics.print("Libraries: " .. (librariesLoaded and "✓" or "✗"), love.graphics.getWidth() - 100, 90)
    end
    
    -- Draw asset map overlay (toggle with F4)
    assetMap.draw()
    
    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    -- Global hotkeys
    if key == "f3" then
        Game.debug = not Game.debug
    elseif key == "f4" then
        assetMap.toggle() -- Toggle asset map overlay
        print("Asset Map: " .. (assetMap.visible and "ON" or "OFF"))
    elseif key == "f5" then
        Game.paused = not Game.paused
    elseif key == "escape" then
        if gamestate.current and gamestate.current.name ~= "gameplay" then
            gamestate.switch("gameplay")
        else
            love.event.quit()
        end
    end
    
    -- Pass input to current state
    gamestate.keypressed(key)
end

function love.keyreleased(key)
    if gamestate.current and gamestate.current.keyreleased then
        gamestate.current:keyreleased(key)
    end
end

function love.mousepressed(x, y, button)
    if gamestate.current and gamestate.current.mousepressed then
        gamestate.current:mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if gamestate.current and gamestate.current.mousereleased then
        gamestate.current:mousereleased(x, y, button)
    end
end

function love.focus(focused)
    if not focused then
        Game.paused = true
    end
end

function love.quit()
    -- Auto-save before quitting
    if saveUtil and playerEntity then
        local gameData = {
            player = {
                x = playerSystem.x,
                y = playerSystem.y,
                health = playerEntity.health,
                stamina = playerEntity.stamina,
                hunger = playerEntity.hunger,
                inventory = playerEntity.inventory
            },
            world = {
                time = daynightSystem.time,
                crops = cropsEntity.planted,
                animals = animalsEntity.active
            }
        }
        
        if saveUtil.autoSave(gameData) then
            print("💾 Game auto-saved on exit")
        end
    end
    
    print("👋 Thanks for playing!")
end