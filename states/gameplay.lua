-- Main Gameplay State
-- Handles the core game loop, player movement, and world interactions with area system

local gameplay = {}

function gameplay:enter()
    -- Initialize gameplay systems
    local areas = require("systems/areas")
    areas.load()
    print("🎮 Entering gameplay state - Area system loaded")
end

function gameplay:update(dt)
    -- Update area system (handles current area logic)
    local areas = require("systems/areas")
    areas.update(dt)
    
    -- Update other systems
    local playerSystem = require("systems/player")
    playerSystem.update(dt)
    
    local daynightSystem = require("systems/daynight")
    daynightSystem.update(dt)
end

function gameplay:draw()
    -- Draw current area
    local areas = require("systems/areas")
    areas.draw()
    
    -- Draw player
    local playerSystem = require("systems/player")
    playerSystem.draw()
    
    -- Draw interaction prompts
    gameplay:drawInteractionPrompts()
end

function gameplay:drawInteractionPrompts()
    local areas = require("systems/areas")
    local playerSystem = require("systems/player")
    local currentArea = areas.getCurrentArea()
    
    if not currentArea then return end
    
    -- Check for area exits
    local nearExit = areas.getPlayerNearExit(playerSystem.x, playerSystem.y)
    if nearExit then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print(nearExit.prompt, 10, love.graphics.getHeight() - 60)
    end
    
    -- Check for hunting zones (circular areas on map)
    if currentArea.type == "overworld" and currentArea.huntingZones then
        local nearHuntingZone = areas.getPlayerNearHuntingZone(playerSystem.x, playerSystem.y)
        if nearHuntingZone then
            love.graphics.setColor(0.9, 0.7, 0.3)
            love.graphics.print("🎯 " .. nearHuntingZone.name .. ": Press ENTER to hunt", 10, love.graphics.getHeight() - 20)
        end
    end
    
    -- Check for main world structures (railway station, etc.)
    if currentArea.type == "overworld" then
        local worldSystem = require("systems/world")
        local nearStructure, structureName = worldSystem.getPlayerStructure(playerSystem.x, playerSystem.y)
        if nearStructure then
            local prompt = ""
            if nearStructure.interaction == "railway_shop" then
                prompt = "🚂 Railway Station: Press B to BUY/SELL | Press E to examine"
            elseif nearStructure.interaction == "fishing" then
                prompt = "🎣 Pond: Press F to fish | Press G to get FREE water (5x)"
            elseif nearStructure.interaction == "farming" then
                prompt = "🌾 Farm Plot: Press E to plant/harvest | Press Q to water"
            end
            
            if prompt ~= "" then
                love.graphics.setColor(0.8, 0.8, 1)
                love.graphics.print(prompt, 10, love.graphics.getHeight() - 100)
            end
        end
        
        -- Check for foraging opportunities
        local foragingSystem = require("systems/foraging")
        local nearCrop = foragingSystem.getPlayerNearCrop(playerSystem.x, playerSystem.y)
        if nearCrop then
            love.graphics.setColor(0.6, 1, 0.6)
            love.graphics.print("Wild " .. nearCrop.type.name .. ": Press R to forage", 10, love.graphics.getHeight() - 120)
        end
    end
    
    -- Check furniture interactions (interior areas)
    if currentArea.type == "interior" and currentArea.furniture then
        local nearFurniture = gameplay:getPlayerNearFurniture(playerSystem.x, playerSystem.y, currentArea.furniture)
        if nearFurniture then
            local prompt = ""
            if nearFurniture.interaction == "sleep" then
                prompt = "Press Z to sleep and restore health"
            elseif nearFurniture.interaction == "storage" then
                prompt = "Press C to access storage chest"
            elseif nearFurniture.interaction == "shop" then
                prompt = "Press S to trade with merchant"
            elseif nearFurniture.interaction == "examine" then
                prompt = "Press E to examine"
            elseif nearFurniture.interaction == "warmth" then
                prompt = "Press F to warm up by the fire"
            end
            
            if prompt ~= "" then
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(prompt, 10, love.graphics.getHeight() - 80)
            end
        end
    end
    
    -- Area-specific prompts
    if currentArea.type == "hunting_area" then
        love.graphics.setColor(1, 0.6, 0.6)
        love.graphics.print("Press H to hunt animals in this area", 10, love.graphics.getHeight() - 100)
    end
    
    -- Always show movement controls
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("WASD to move | I for inventory | R to forage | T to spawn crops (debug)", 10, love.graphics.getHeight() - 140)
    
    love.graphics.setColor(1, 1, 1)
end

function gameplay:getPlayerNearFurniture(playerX, playerY, furniture)
    for _, item in ipairs(furniture) do
        if playerX >= item.x - 10 and playerX <= item.x + item.width + 10 and
           playerY >= item.y - 10 and playerY <= item.y + item.height + 10 then
            return item
        end
    end
    return nil
end

function gameplay:keypressed(key)
    local areas = require("systems/areas")
    local playerSystem = require("systems/player")
    local playerEntity = require("entities/player")
    local daynightSystem = require("systems/daynight")
    local gamestate = require("states/gamestate")
    
    local currentArea = areas.getCurrentArea()
    
    -- Universal controls
    if key == "escape" then
        -- Pause or return to menu
        print("⏸️ Game paused")
    elseif key == "i" then
        -- Open inventory
        gamestate.switch("inventory")
        return
    end
    
    -- Area transitions
    local nearExit = areas.getPlayerNearExit(playerSystem.x, playerSystem.y)
    if key == "return" and nearExit then
        areas.transitionToArea(nearExit.target, nearExit.targetPos)
        return
    end
    
    -- Hunting zone entries (main world only) - Use NEW first-person hunting!
    local nearHuntingZone = areas.getPlayerNearHuntingZone(playerSystem.x, playerSystem.y)
    if key == "return" and nearHuntingZone then
        print("🎯 Entering " .. nearHuntingZone.name .. " - First-Person Hunting!")
        -- Go to NEW first-person hunting state (NOT old hunting_area)
        gamestate.switch("hunting")
        return
    end
    
    -- Interior interactions
    if currentArea.type == "interior" and currentArea.furniture then
        local nearFurniture = gameplay:getPlayerNearFurniture(playerSystem.x, playerSystem.y, currentArea.furniture)
        if nearFurniture then
            if key == "z" and nearFurniture.interaction == "sleep" then
                gameplay:sleepInBed(playerEntity, daynightSystem)
            elseif key == "c" and nearFurniture.interaction == "storage" then
                gameplay:accessStorage()
            elseif key == "s" and nearFurniture.interaction == "shop" then
                gamestate.switch("shop")
            elseif key == "e" and nearFurniture.interaction == "examine" then
                gameplay:examineItem(nearFurniture)
            elseif key == "f" and nearFurniture.interaction == "warmth" then
                gameplay:warmUpByFire(playerEntity)
            end
            return
        end
    end
    
    -- Hunting area actions
    if currentArea.type == "hunting_area" and key == "h" then
        gameplay:huntInCurrentArea()
        return
    end
    
    -- Main world interactions (legacy support for existing systems)
    if currentArea.type == "overworld" then
        local worldSystem = require("systems/world")
        local nearStructure, structureName = worldSystem.getPlayerStructure(playerSystem.x, playerSystem.y)
        
        if nearStructure then
            if key == "f" and nearStructure.interaction == "fishing" then
                gameplay:goFishing(playerEntity)
            elseif key == "g" and nearStructure.interaction == "fishing" then
                gameplay:waterFromPond()
            elseif key == "e" and nearStructure.interaction == "farming" then
                print("🌾 E pressed at farm! Player at (" .. playerSystem.x .. ", " .. playerSystem.y .. ")")
                gameplay:farmingAction(playerSystem.x, playerSystem.y)
            elseif key == "q" and nearStructure.interaction == "farming" then
                print("💧 Q pressed at farm! Player at (" .. playerSystem.x .. ", " .. playerSystem.y .. ")")
                gameplay:waterCrops(playerSystem.x, playerSystem.y)
            elseif key == "b" and nearStructure.interaction == "railway_shop" then
                print("🛒 Opening shop...")
                local gamestate = require("states/gamestate")
                gamestate.switch("shop")
            elseif key == "e" and nearStructure.interaction == "railway_shop" then
                gameplay:examineRailwayStation(nearStructure)
            end
        elseif key == "return" then
            -- Check if near hunting zone - go directly to NEW hunting state
            -- Do NOT use areas.transitionToArea - go straight to hunting state!
            local nearHuntingZone = areas.getPlayerNearHuntingZone(playerSystem.x, playerSystem.y)
            if nearHuntingZone then
                print("🎯 Entering " .. nearHuntingZone.name .. " - First-Person Hunting!")
                -- Switch directly to NEW first-person hunting state (bypasses area system)
                local gamestate = require("states/gamestate")
                gamestate.switch("hunting")
                return -- Important: Don't let areas.lua handle this
            else
                print("⚠️  Find a hunting zone (circular areas) to hunt!")
            end
        elseif key == "r" then
            -- Try to forage wild crops
            gameplay:forageCrop(playerSystem.x, playerSystem.y)
        elseif key == "t" then
            -- Debug: Force spawn wild crops for testing
            local foragingSystem = require("systems/foraging")
            foragingSystem.forceSpawn()
        end
    end
end

function gameplay:sleepInCabin(playerEntity, daynightSystem)
    -- Restore health and stamina
    playerEntity.heal(50)
    playerEntity.rest(100)
    
    -- Advance to next day
    daynightSystem.time = 0.25 -- Set to morning
    
    print("💤 You sleep peacefully. Health and stamina restored!")
    print("🌅 A new day begins...")
end

function gameplay:goFishing(playerEntity)
    -- Simple fishing mechanic
    local success = math.random() < 0.6 -- 60% success rate
    
    if success then
        local fishCaught = math.random(1, 3)
        playerEntity.addItem("fish", fishCaught)
        print("🐟 Caught " .. fishCaught .. " fish")
    else
        print("🎣 Fish got away")
    end
end

function gameplay:waterFromPond()
    local playerEntity = require("entities/player")
    playerEntity.addItem("water", 5)
    print("💧 Collected 5 water from pond")
end

function gameplay:farmingAction(x, y)
    local farmingSystem = require("systems/farming")
    local playerEntity = require("entities/player")
    
    -- Try to harvest first (if crop is ready)
    local cropType, yield, message = farmingSystem.harvestCrop(x, y)
    if cropType then
        playerEntity.addItem(cropType, yield)
        return
    end
    
    -- No ready crop, try to plant
    if playerEntity.hasItem("seeds", 1) then
        local success, msg = farmingSystem.plantSeed(x, y, "carrot")
        if success then
            playerEntity.removeItem("seeds", 1)
        end
    end
end

function gameplay:waterCrops(x, y)
    local farmingSystem = require("systems/farming")
    local playerEntity = require("entities/player")
    
    -- Water is now a finite resource
    if playerEntity.hasItem("water", 1) then
        local success, message = farmingSystem.waterCrop(x, y)
        if success then
            playerEntity.removeItem("water", 1)
            print("💧 " .. message)
        else
            print("❌ " .. message)
        end
    else
        print("❌ No water (Get from pond or buy from shop for 5 coins)")
    end
end

function gameplay:enterHuntingZone(zoneName)
    local worldSystem = require("systems/world")
    
    if worldSystem.enterHuntingZone(zoneName) then
        print("🌲 Entering " .. zoneName .. "...")
        print("🦌 You can hear animals moving in the dense forest")
    end
end

function gameplay:exitHuntingZone(zoneName)
    local worldSystem = require("systems/world")
    worldSystem.exitHuntingZone(zoneName)
end

function gameplay:huntInActiveZone(zone, zoneName)
    local playerSystem = require("systems/player")
    local playerEntity = require("entities/player")
    local animalsEntity = require("entities/animals")
    
    -- Find animals near player in active hunting zone
    local nearbyAnimals = {}
    for _, animal in ipairs(zone.animals) do
        local distance = math.sqrt((animal.x - playerSystem.x)^2 + (animal.y - playerSystem.y)^2)
        if distance <= 60 and animal.alive then
            table.insert(nearbyAnimals, animal)
        end
    end
    
    if #nearbyAnimals > 0 then
        local animal = nearbyAnimals[1]
        local result, value = animalsEntity.huntAnimal(animal)
        
        if result == "success" then
            playerEntity.addItem("meat", value)
            print("🏹 Successfully hunted " .. animal.type .. "! Gained " .. value .. " meat")
            
            -- Remove from zone animals
            for i, zoneAnimal in ipairs(zone.animals) do
                if zoneAnimal == animal then
                    table.remove(zone.animals, i)
                    break
                end
            end
        elseif result == "flee" then
            print("🐅 DANGER! Tiger spotted - you flee from the hunting zone!")
            -- Exit hunting zone immediately
            gameplay:exitHuntingZone(zoneName)
        end
    else
        print("🔍 No animals nearby to hunt in this area")
    end
end

function gameplay:huntWorldAnimals(playerX, playerY)
    local worldSystem = require("systems/world")
    local playerEntity = require("entities/player")
    local animalsEntity = require("entities/animals")
    
    -- Find nearby world animals
    local nearbyAnimals = {}
    for _, animal in ipairs(worldSystem.worldAnimals) do
        local distance = math.sqrt((animal.x - playerX)^2 + (animal.y - playerY)^2)
        if distance <= 60 and animal.alive then
            table.insert(nearbyAnimals, animal)
        end
    end
    
    if #nearbyAnimals > 0 then
        local animal = nearbyAnimals[1]
        local result, value = animalsEntity.huntAnimal(animal)
        
        if result == "success" then
            playerEntity.addItem("meat", value)
            print("🏹 Successfully hunted a wild " .. animal.type .. "! Gained " .. value .. " meat")
            
            -- Remove from world animals
            for i, worldAnimal in ipairs(worldSystem.worldAnimals) do
                if worldAnimal == animal then
                    table.remove(worldSystem.worldAnimals, i)
                    break
                end
            end
        end
    else
        print("🔍 No wild animals nearby. Try entering a hunting zone for better luck!")
    end
end

-- New area-specific functions

function gameplay:sleepInBed(playerEntity, daynightSystem)
    -- Enhanced sleep function for cabin
    playerEntity.heal(100) -- Full heal in bed
    playerEntity.rest(100) -- Full stamina restore
    
    -- Advance to next day
    daynightSystem.time = 0.25 -- Set to morning
    
    print("💤 You sleep comfortably in your uncle's bed")
    print("❤️  Health and stamina fully restored!")
    print("🌅 Dawn breaks - a new day begins...")
end

function gameplay:accessStorage()
    print("📦 Storage chest opened")
    print("💡 Storage system coming soon - for now items are in your inventory")
end

function gameplay:examineItem(furniture)
    if furniture.type == "table" then
        print("📋 An old wooden table with scratches and notes")
        print("📝 'Gone to find answers - back soon' - Uncle's handwriting")
    elseif furniture.type == "shelves" then
        print("📚 Old shelves with dusty books and supplies")
        print("📖 Most books are about forest survival and local history")
    else
        print("🔍 " .. furniture.type .. " - Nothing unusual here")
    end
end

function gameplay:warmUpByFire(playerEntity)
    -- Restore some health and stamina by the fire
    playerEntity.heal(20)
    playerEntity.rest(30)
    print("🔥 You warm yourself by the crackling fire")
    print("❤️  The warmth restores some health and energy")
end

function gameplay:huntInCurrentArea()
    local areas = require("systems/areas")
    local playerSystem = require("systems/player")
    local playerEntity = require("entities/player")
    local animalsEntity = require("entities/animals")
    
    local areaData = areas.getCurrentAreaData()
    
    if not areaData or not areaData.animals then
        print("🔍 No animals in this area")
        return
    end
    
    -- Find animals near player
    local nearbyAnimals = {}
    for _, animal in ipairs(areaData.animals) do
        local distance = math.sqrt((animal.x - playerSystem.x)^2 + (animal.y - playerSystem.y)^2)
        if distance <= 80 and animal.alive then
            table.insert(nearbyAnimals, animal)
        end
    end
    
    if #nearbyAnimals > 0 then
        local animal = nearbyAnimals[1]
        local result, value = animalsEntity.huntAnimal(animal)
        
        if result == "success" then
            playerEntity.addItem("meat", value)
            print("🏹 Successfully hunted " .. animal.type .. "! Gained " .. value .. " meat")
            
            -- Remove from area animals
            for i, areaAnimal in ipairs(areaData.animals) do
                if areaAnimal == animal then
                    table.remove(areaData.animals, i)
                    break
                end
            end
        elseif result == "flee" then
            -- For dangerous animals like tigers
            print("🐅 DANGER! " .. animal.type .. " attacks - you quickly flee!")
            local areas = require("systems/areas")
            areas.transitionToArea("main_world", {x = 500, y = 300})
        end
    else
        print("🔍 No animals nearby. Move around the hunting area to find prey")
    end
end

function gameplay:tradeAtRailwayStation(structure)
    if structure.shopkeeper then
        print("🚂 " .. structure.shopkeeper.name .. ": " .. structure.shopkeeper.dialogue)
        print("🛒 Railway Station Shop - Available items:")
        for i, item in ipairs(structure.shopkeeper.inventory) do
            print("  " .. i .. ". " .. item.item .. " - $" .. item.price .. " (Stock: " .. item.stock .. ")")
        end
        print("💡 Full trading system coming soon! For now, enjoy browsing.")
    else
        print("🚂 The old station seems abandoned...")
    end
end

function gameplay:examineRailwayStation(structure)
    print("🚂 An old railway station, weathered but still standing")
    print("🛤️  Rusty train tracks stretch into the dark forest")
    print("📋 A faded schedule shows the last train was years ago...")
    if structure.shopkeeper then
        print("👤 You notice someone moving inside - " .. structure.shopkeeper.name)
        print("💡 Press S to talk to the station master")
    end
end

function gameplay:forageCrop(playerX, playerY)
    local foragingSystem = require("systems/foraging")
    local nearCrop = foragingSystem.getPlayerNearCrop(playerX, playerY)
    
    if nearCrop then
        if foragingSystem.collectCrop(nearCrop) then
            -- Successfully collected
            local playerEntity = require("entities/player")
            -- Health/nutrition bonus from wild food
            if nearCrop.type.nutrition then
                playerEntity.heal(nearCrop.type.nutrition)
            end
        end
    else
        print("🔍 No wild crops nearby to forage")
    end
end

function gameplay:exit()
    -- Cleanup when leaving gameplay
end

return gameplay