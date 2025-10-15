-- Area System
-- Manages different areas/rooms like Stardew Valley (main world, cabin interior, hunting areas, etc.)

local areas = {}

-- Current area state
areas.currentArea = "main_world"
areas.previousArea = nil
areas.transitionData = {}

-- Area definitions
areas.definitions = {
    main_world = {
        name = "Dark Forest",
        width = 960,
        height = 540,
        type = "overworld",
        music = "forest_ambient",
        lighting = "day_night_cycle",
        exits = {
            {x = 460, y = 310, width = 80, height = 80, target = "cabin_interior", prompt = "Press ENTER to enter cabin"},
            {x = 190, y = 620, width = 80, height = 60, target = "shop_interior", prompt = "Press ENTER to enter shop"}
        },
        huntingZones = {
            {x = 130, y = 130, radius = 80, target = "hunting_northwest", name = "Northwestern Woods"},
            {x = 830, y = 130, radius = 80, target = "hunting_northeast", name = "Northeastern Grove"},
            {x = 830, y = 410, radius = 80, target = "hunting_southeast", name = "Southeastern Wilderness"}
        },
        structures = {
            {x = 130, y = 410, width = 120, height = 80, type = "railway_station", interaction = "mystery", name = "Old Railway Station"}
        }
    },
    
    cabin_interior = {
        name = "Uncle's Cabin",
        width = 480,
        height = 320,
        type = "interior",
        music = "cabin_cozy",
        lighting = "warm_interior",
        playerSpawn = {x = 240, y = 280}, -- Center bottom
        exits = {
            {x = 220, y = 300, width = 40, height = 20, target = "main_world", targetPos = {x = 500, y = 350}, prompt = "Press ENTER to go outside"}
        },
        furniture = {
            {type = "bed", x = 100, y = 80, width = 80, height = 40, interaction = "sleep"},
            {type = "chest", x = 300, y = 100, width = 32, height = 32, interaction = "storage"},
            {type = "fireplace", x = 200, y = 50, width = 60, height = 40, interaction = "warmth"},
            {type = "table", x = 250, y = 150, width = 60, height = 40, interaction = "examine"}
        }
    },
    
    shop_interior = {
        name = "Merchant's Shop",
        width = 320,
        height = 240,
        type = "interior",
        music = "shop_theme",
        lighting = "shop_interior",
        playerSpawn = {x = 160, y = 200},
        exits = {
            {x = 140, y = 220, width = 40, height = 20, target = "main_world", targetPos = {x = 230, y = 660}, prompt = "Press ENTER to go outside"}
        },
        furniture = {
            {type = "counter", x = 120, y = 80, width = 80, height = 40, interaction = "shop"},
            {type = "shelves", x = 50, y = 60, width = 40, height = 60, interaction = "examine"},
            {type = "shelves", x = 230, y = 60, width = 40, height = 60, interaction = "examine"}
        }
    },
    
    hunting_northwest = {
        name = "Northwestern Woods",
        width = 400,
        height = 400,
        type = "hunting_area",
        music = "forest_deep",
        lighting = "forest_dim",
        playerSpawn = {x = 200, y = 350}, -- Bottom center (entry point)
        exits = {
            {x = 180, y = 380, width = 40, height = 20, target = "main_world", targetPos = {x = 130, y = 130}, prompt = "Press ENTER to leave hunting area"}
        },
        animalTypes = {"rabbit", "deer"},
        animalCount = {min = 6, max = 10},
        dangerLevel = 0.2,
        boundaries = {x = 200, y = 200, radius = 180} -- Circular boundary
    },
    
    hunting_northeast = {
        name = "Northeastern Grove",
        width = 400,
        height = 400,
        type = "hunting_area",
        music = "forest_deep",
        lighting = "forest_dim",
        playerSpawn = {x = 200, y = 350},
        exits = {
            {x = 180, y = 380, width = 40, height = 20, target = "main_world", targetPos = {x = 830, y = 130}, prompt = "Press ENTER to leave hunting area"}
        },
        animalTypes = {"rabbit", "boar"},
        animalCount = {min = 5, max = 8},
        dangerLevel = 0.4,
        boundaries = {x = 200, y = 200, radius = 180}
    },
    
    hunting_southeast = {
        name = "Southeastern Wilderness",
        width = 400,
        height = 400,
        type = "hunting_area",
        music = "forest_danger",
        lighting = "forest_dark",
        playerSpawn = {x = 200, y = 350},
        exits = {
            {x = 180, y = 380, width = 40, height = 20, target = "main_world", targetPos = {x = 830, y = 410}, prompt = "Press ENTER to leave hunting area"}
        },
        animalTypes = {"boar", "tiger"},
        animalCount = {min = 4, max = 6},
        dangerLevel = 0.8,
        boundaries = {x = 200, y = 200, radius = 180}
    }
}

-- Area-specific data
areas.areaData = {}

-- Initialize area system
function areas.load()
    -- Initialize data for each area
    for areaId, areaDef in pairs(areas.definitions) do
        areas.areaData[areaId] = {
            animals = {},
            objects = {},
            visited = false
        }
    end
    
    areas.currentArea = "main_world"
    print("🏠 Area system initialized - " .. #areas.definitions .. " areas loaded")
end

-- Get current area definition
function areas.getCurrentArea()
    return areas.definitions[areas.currentArea]
end

-- Get current area data
function areas.getCurrentAreaData()
    return areas.areaData[areas.currentArea]
end

-- Check if player is near an exit
function areas.getPlayerNearExit(playerX, playerY)
    local currentArea = areas.getCurrentArea()
    if not currentArea or not currentArea.exits then return nil end
    
    for _, exit in ipairs(currentArea.exits) do
        if playerX >= exit.x and playerX <= exit.x + exit.width and
           playerY >= exit.y and playerY <= exit.y + exit.height then
            return exit
        end
    end
    
    return nil
end

-- Check if player is near hunting zone (main world only)
function areas.getPlayerNearHuntingZone(playerX, playerY)
    if areas.currentArea ~= "main_world" then return nil end
    
    local currentArea = areas.getCurrentArea()
    if not currentArea.huntingZones then return nil end
    
    for _, zone in ipairs(currentArea.huntingZones) do
        local distance = math.sqrt((playerX - zone.x)^2 + (playerY - zone.y)^2)
        if distance <= zone.radius + 30 and distance >= zone.radius - 20 then
            return zone
        end
    end
    
    return nil
end

-- Transition to new area
function areas.transitionToArea(targetAreaId, targetPos)
    local targetArea = areas.definitions[targetAreaId]
    if not targetArea then
        print("❌ Area '" .. targetAreaId .. "' not found!")
        return false
    end
    
    -- Store previous area
    areas.previousArea = areas.currentArea
    areas.currentArea = targetAreaId
    
    -- Set player position
    local playerSystem = require("systems/player")
    if targetPos then
        playerSystem.x = targetPos.x
        playerSystem.y = targetPos.y
    elseif targetArea.playerSpawn then
        playerSystem.x = targetArea.playerSpawn.x
        playerSystem.y = targetArea.playerSpawn.y
    end
    
    -- Mark area as visited
    areas.areaData[targetAreaId].visited = true
    
    -- Handle area-specific initialization
    if targetArea.type == "hunting_area" then
        areas.spawnHuntingAreaAnimals(targetAreaId)
    elseif targetArea.type == "interior" then
        areas.initializeInterior(targetAreaId)
    end
    
    print("🚪 Entered " .. targetArea.name)
    return true
end

-- Spawn animals in hunting area
function areas.spawnHuntingAreaAnimals(areaId)
    local areaDef = areas.definitions[areaId]
    local areaData = areas.areaData[areaId]
    
    if areaDef.type ~= "hunting_area" then return end
    
    -- Clear existing animals
    areaData.animals = {}
    
    -- Spawn new animals
    local animalCount = math.random(areaDef.animalCount.min, areaDef.animalCount.max)
    local animalsEntity = require("entities/animals")
    
    for i = 1, animalCount do
        -- Random position within boundaries
        local angle = math.random() * 2 * math.pi
        local distance = math.random(30, areaDef.boundaries.radius - 30)
        local x = areaDef.boundaries.x + math.cos(angle) * distance
        local y = areaDef.boundaries.y + math.sin(angle) * distance
        
        -- Pick random animal type
        local animalType = areaDef.animalTypes[math.random(1, #areaDef.animalTypes)]
        local animal = animalsEntity.create(animalType, x, y)
        
        if animal then
            animal.huntingArea = areaId
            table.insert(areaData.animals, animal)
        end
    end
    
    print("🦌 " .. #areaData.animals .. " animals spawned in " .. areaDef.name)
end

-- Initialize interior area
function areas.initializeInterior(areaId)
    local areaDef = areas.definitions[areaId]
    local areaData = areas.areaData[areaId]
    
    if areaDef.type ~= "interior" then return end
    
    -- Initialize furniture interactions, etc.
    print("🏠 " .. areaDef.name .. " prepared")
end

-- Update current area
function areas.update(dt)
    local currentArea = areas.getCurrentArea()
    local areaData = areas.getCurrentAreaData()
    
    if not currentArea or not areaData then return end
    
    -- Update area-specific logic
    if currentArea.type == "hunting_area" then
        areas.updateHuntingArea(dt, currentArea, areaData)
    elseif currentArea.type == "overworld" then
        areas.updateOverworld(dt, currentArea, areaData)
    end
end

-- Update hunting area
function areas.updateHuntingArea(dt, areaDef, areaData)
    local animalsEntity = require("entities/animals")
    
    -- Update animals
    for i = #areaData.animals, 1, -1 do
        local animal = areaData.animals[i]
        
        if not animal.alive then
            table.remove(areaData.animals, i)
        else
            animalsEntity.updateAnimal(animal, dt)
            
            -- Check boundaries
            local distance = math.sqrt((animal.x - areaDef.boundaries.x)^2 + (animal.y - areaDef.boundaries.y)^2)
            if distance > areaDef.boundaries.radius then
                -- Animal wandered too far - move back towards center
                local angle = math.atan2(areaDef.boundaries.y - animal.y, areaDef.boundaries.x - animal.x)
                animal.x = animal.x + math.cos(angle) * 50 * dt
                animal.y = animal.y + math.sin(angle) * 50 * dt
            end
        end
    end
end

-- Update overworld (main world)
function areas.updateOverworld(dt, areaDef, areaData)
    -- Update world animals, crops, etc.
    -- This would integrate with existing world system
end

-- Draw current area
function areas.draw()
    local currentArea = areas.getCurrentArea()
    local areaData = areas.getCurrentAreaData()
    
    if not currentArea then return end
    
    -- Draw area-specific elements
    if currentArea.type == "hunting_area" then
        areas.drawHuntingArea(currentArea, areaData)
    elseif currentArea.type == "interior" then
        areas.drawInterior(currentArea, areaData)
    elseif currentArea.type == "overworld" then
        areas.drawOverworld(currentArea, areaData)
    end
    
    -- Area name removed to prevent overlap with main.lua UI
    love.graphics.setColor(1, 1, 1)
end

-- Draw hunting area
function areas.drawHuntingArea(areaDef, areaData)
    -- Draw boundary circle
    love.graphics.setColor(0.3, 0.6, 0.3, 0.3)
    love.graphics.circle("fill", areaDef.boundaries.x, areaDef.boundaries.y, areaDef.boundaries.radius)
    
    love.graphics.setColor(0.2, 0.5, 0.2, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", areaDef.boundaries.x, areaDef.boundaries.y, areaDef.boundaries.radius)
    
    -- Draw animals
    local animalsEntity = require("entities/animals")
    for _, animal in ipairs(areaData.animals) do
        if animal.alive then
            animalsEntity.drawAnimal(animal)
        end
    end
    
    -- Draw exits
    for _, exit in ipairs(areaDef.exits) do
        love.graphics.setColor(1, 1, 0, 0.5)
        love.graphics.rectangle("fill", exit.x, exit.y, exit.width, exit.height)
    end
    
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
end

-- Draw interior area
function areas.drawInterior(areaDef, areaData)
    -- Draw room background
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.rectangle("fill", 0, 0, areaDef.width, areaDef.height)
    
    -- Draw furniture
    if areaDef.furniture then
        for _, furniture in ipairs(areaDef.furniture) do
            areas.drawFurniture(furniture)
        end
    end
    
    -- Draw exits
    for _, exit in ipairs(areaDef.exits) do
        love.graphics.setColor(0.6, 0.4, 0.2)
        love.graphics.rectangle("fill", exit.x, exit.y, exit.width, exit.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", exit.x, exit.y, exit.width, exit.height)
    end
    
    love.graphics.setColor(1, 1, 1)
end

-- Draw furniture
function areas.drawFurniture(furniture)
    if furniture.type == "bed" then
        love.graphics.setColor(0.6, 0.3, 0.1) -- Brown bed
    elseif furniture.type == "chest" then
        love.graphics.setColor(0.4, 0.2, 0.1) -- Dark brown chest
    elseif furniture.type == "fireplace" then
        love.graphics.setColor(0.5, 0.2, 0.2) -- Red fireplace
    elseif furniture.type == "table" then
        love.graphics.setColor(0.5, 0.3, 0.1) -- Wood table
    elseif furniture.type == "counter" then
        love.graphics.setColor(0.4, 0.4, 0.4) -- Gray counter
    elseif furniture.type == "shelves" then
        love.graphics.setColor(0.3, 0.2, 0.1) -- Dark wood shelves
    else
        love.graphics.setColor(0.5, 0.5, 0.5) -- Default gray
    end
    
    love.graphics.rectangle("fill", furniture.x, furniture.y, furniture.width, furniture.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", furniture.x, furniture.y, furniture.width, furniture.height)
end

-- Draw overworld
function areas.drawOverworld(areaDef, areaData)
    -- This would integrate with existing world drawing
    -- Draw hunting zone circles, structures, etc.
    if areaDef.huntingZones then
        for _, zone in ipairs(areaDef.huntingZones) do
            love.graphics.setColor(0.6, 0.6, 0.6, 0.4)
            love.graphics.setLineWidth(1)
            love.graphics.circle("line", zone.x, zone.y, zone.radius)
            
            -- Zone name removed to reduce clutter (shown in prompts when near)
        end
    end
    
    -- Draw structures (railway station, etc.)
    if areaDef.structures then
        for _, structure in ipairs(areaDef.structures) do
            if structure.type == "railway_station" then
                -- Draw railway station building
                love.graphics.setColor(0.4, 0.3, 0.2) -- Dark brown for old wood
                love.graphics.rectangle("fill", structure.x, structure.y, structure.width, structure.height)
                
                -- Draw roof
                love.graphics.setColor(0.3, 0.2, 0.1) -- Darker roof
                love.graphics.rectangle("fill", structure.x - 5, structure.y - 10, structure.width + 10, 15)
                
                -- Draw door
                love.graphics.setColor(0.2, 0.1, 0.05) -- Very dark door
                love.graphics.rectangle("fill", structure.x + structure.width/2 - 10, structure.y + structure.height - 25, 20, 25)
                
                -- Draw windows
                love.graphics.setColor(0.8, 0.8, 0.6) -- Yellowish windows
                love.graphics.rectangle("fill", structure.x + 15, structure.y + 15, 20, 15)
                love.graphics.rectangle("fill", structure.x + structure.width - 35, structure.y + 15, 20, 15)
                
                -- Draw railway tracks
                love.graphics.setColor(0.5, 0.5, 0.5) -- Gray tracks
                love.graphics.setLineWidth(3)
                love.graphics.line(structure.x - 20, structure.y + structure.height + 5, structure.x + structure.width + 20, structure.y + structure.height + 5)
                love.graphics.line(structure.x - 20, structure.y + structure.height + 15, structure.x + structure.width + 20, structure.y + structure.height + 15)
                
                -- Draw structure outline
                love.graphics.setColor(1, 1, 1)
                love.graphics.setLineWidth(1)
                love.graphics.rectangle("line", structure.x, structure.y, structure.width, structure.height)
                
                -- Structure name (simplified - only shown when near)
                -- Removed to reduce visual clutter
            end
        end
    end
    
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
end

return areas