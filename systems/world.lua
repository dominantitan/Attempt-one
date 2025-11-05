-- World Map System
-- Defines all game areas, structures, and interaction zones

local world = {}

-- World dimensions and layout (3x expanded for camera system)
world.width = 2880  -- Was 960
world.height = 1620 -- Was 540
world.SCALE_FACTOR = 3 -- For reference

-- EXPANDED BOUNDARIES (scaled 3x)
world.bounds = {
    left = 150,    -- Was 50
    right = 2730,  -- Was 910 - 32
    top = 150,     -- Was 50
    bottom = 1560  -- Was 520 - 32
}

-- Structure positions (scaled 3x for expanded world)
world.structures = {
    cabin = {
        x = 1380,  -- Was 460
        y = 930,   -- Was 310
        width = 240,  -- Was 80
        height = 240, -- Was 80
        name = "Uncle's Cabin",
        interaction = "sleep"
    },
    
    farm = {
        x = 1695,  -- Was 565
        y = 975,   -- Was 325
        width = 360,  -- Was 120
        height = 240, -- Was 80
        name = "Farm",
        interaction = "farming",
        plots = {} -- Will contain individual plot positions
    },
    
    pond = {
        x = 1740,  -- Was 580
        y = 1350,  -- Was 450
        width = 300,  -- Was 100
        height = 180, -- Was 60
        name = "Pond",
        interaction = "fishing"
    },
    
    shop = {
        x = 570,   -- Was 190
        y = 1860,  -- Was 620
        width = 240,  -- Was 80
        height = 180, -- Was 60
        name = "Shop",
        interaction = "trading"
    },
    
    railway = {
        x = 390,   -- Was 130
        y = 1230,  -- Was 410
        width = 360,  -- Was 120
        height = 240, -- Was 80
        name = "Old Railway Station",
        interaction = "railway_shop",
        shopkeeper = {
            name = "Station Master Ellis",
            x = 570,   -- Was 190
            y = 1350,  -- Was 450
            dialogue = "Welcome to the old station! I've got supplies for travelers.",
            inventory = {
                {item = "seeds", price = 5, stock = 10},
                {item = "water", price = 2, stock = 20},
                {item = "meat", price = 8, stock = 5},
                {item = "tools", price = 15, stock = 3}
            }
        }
    }
}

-- Hunting zones (circular areas in corners - scaled 3x)
world.huntingZones = {
    -- bottomLeft removed - railway station occupies this area
    -- topLeft = {
    --     x = 390,
    --     y = 390,
    --     radius = 240,
    --     name = "Northwestern Woods",
    --     animalTypes = {"rabbit", "deer","tiger"},
    --     dangerLevel = 0.2,
    --     active = false,  -- Whether player is currently in this hunting instance
    --     animals = {}     -- Animals specific to this hunting zone instance
    -- },
    
    topRight = {
        x = 2490,  -- Was 830
        y = 390,   -- Was 130
        radius = 240, -- Was 80
        name = "Northeastern Grove",
        animalTypes = {"rabbit", "boar","tiger"},
        dangerLevel = 0.4,
        active = false,
        animals = {}
    },

    
    bottomRight = {
        x = 2490,  -- Was 830
        y = 1230,  -- Was 410
        radius = 240, -- Was 80
        name = "Southeastern Wilderness",
        animalTypes = {"deer","boar", "tiger"},
        dangerLevel = 0.8,
        active = false,
        animals = {}
    }
}

-- World animals (rare spawns in main world)
world.worldAnimals = {}
world.animalSpawnTimer = 0
world.animalSpawnInterval = 45 -- Spawn animal every 45 seconds on average
world.maxWorldAnimals = 3      -- Maximum animals in main world at once

-- Farm plot positions (3x2 grid - scaled 3x)
world.generateFarmPlots = function()
    local farm = world.structures.farm
    local plotSize = 96  -- Was 32
    local spacing = 24   -- Was 8
    
    world.structures.farm.plots = {}
    
    for row = 0, 1 do
        for col = 0, 2 do
            local plot = {
                x = farm.x + 60 + (col * (plotSize + spacing)),  -- Was 20
                y = farm.y + 60 + (row * (plotSize + spacing)),  -- Was 20
                width = plotSize,
                height = plotSize,
                planted = false,
                cropType = nil
            }
            table.insert(world.structures.farm.plots, plot)
        end
    end
end

-- Check if player is near (but not in) a hunting zone
function world.getPlayerNearHuntingZone(playerX, playerY)
    for name, zone in pairs(world.huntingZones) do
        local distance = math.sqrt((playerX - zone.x)^2 + (playerY - zone.y)^2)
        if distance <= zone.radius + 30 and distance > zone.radius - 20 then -- Near the edge
            return zone, name
        end
    end
    return nil
end

-- Check if player is in active hunting zone
function world.getActiveHuntingZone()
    for name, zone in pairs(world.huntingZones) do
        if zone.active then
            return zone, name
        end
    end
    return nil
end

-- Enter hunting zone (creates hunting instance)
function world.enterHuntingZone(zoneName)
    local zone = world.huntingZones[zoneName]
    if not zone then return false end
    
    -- Activate zone
    zone.active = true
    
    -- Spawn animals in this hunting zone
    zone.animals = {}
    local animalCount = math.random(5, 8) -- Dense spawning in hunting zones
    
    for i = 1, animalCount do
        -- Random position within the zone
        local angle = math.random() * 2 * math.pi
        local distance = math.random(20, zone.radius - 30)
        local x = zone.x + math.cos(angle) * distance
        local y = zone.y + math.sin(angle) * distance
        
        -- Pick random animal type for this zone
        local animalType = zone.animalTypes[math.random(1, #zone.animalTypes)]
        
        local animalsEntity = require("entities/animals")
        local animal = animalsEntity.create(animalType, x, y)
        if animal then
            animal.huntingZone = zoneName -- Mark which zone this animal belongs to
            table.insert(zone.animals, animal)
        end
    end
    
    print("🏹 Entered " .. zone.name .. " - " .. #zone.animals .. " animals spotted!")
    return true
end

-- Exit hunting zone
function world.exitHuntingZone(zoneName)
    local zone = world.huntingZones[zoneName]
    if not zone then return end
    
    zone.active = false
    zone.animals = {} -- Clear zone animals
    print("🚪 Left hunting area")
end

-- Update world animals (rare spawns in main world)
function world.updateWorldAnimals(dt)
    -- Spawn timer
    world.animalSpawnTimer = world.animalSpawnTimer + dt
    
    -- Rarely spawn animals in main world
    if world.animalSpawnTimer >= world.animalSpawnInterval and #world.worldAnimals < world.maxWorldAnimals then
        world.animalSpawnTimer = 0
        
        -- Only spawn if not in any hunting zone
        local activeZone = world.getActiveHuntingZone()
        if not activeZone then
            world.spawnRandomWorldAnimal()
        end
    end
    
    -- Update existing world animals
    local animalsEntity = require("entities/animals")
    for i = #world.worldAnimals, 1, -1 do
        local animal = world.worldAnimals[i]
        if not animal.alive then
            table.remove(world.worldAnimals, i)
        else
            animalsEntity.updateAnimal(animal, dt)
        end
    end
end

-- Spawn a rare animal in the main world
function world.spawnRandomWorldAnimal()
    -- Avoid spawning too close to structures or hunting zones
    local attempts = 0
    local maxAttempts = 10
    
    while attempts < maxAttempts do
        local x = math.random(100, world.width - 100)
        local y = math.random(100, world.height - 100)
        
        -- Check if position is valid (not too close to structures or hunting zones)
        local validPosition = true
        
        -- Check distance from hunting zones
        for _, zone in pairs(world.huntingZones) do
            local distance = math.sqrt((x - zone.x)^2 + (y - zone.y)^2)
            if distance < zone.radius + 50 then
                validPosition = false
                break
            end
        end
        
        -- Check distance from structures
        if validPosition then
            for _, structure in pairs(world.structures) do
                local distance = math.sqrt((x - structure.x)^2 + (y - structure.y)^2)
                if distance < 100 then
                    validPosition = false
                    break
                end
            end
        end
        
        if validPosition then
            -- Spawn a common animal (no tigers in main world)
            local animalTypes = {"rabbit", "deer"}
            local animalType = animalTypes[math.random(1, #animalTypes)]
            
            local animalsEntity = require("entities/animals")
            local animal = animalsEntity.create(animalType, x, y)
            if animal then
                animal.worldAnimal = true -- Mark as world animal
                table.insert(world.worldAnimals, animal)
                print("🐰 A " .. animalType .. " appears in the distance...")
            end
            break
        end
        
        attempts = attempts + 1
    end
end

-- Check if player is near a structure
function world.getPlayerStructure(playerX, playerY, interactionRange)
    interactionRange = interactionRange or 50
    
    for name, structure in pairs(world.structures) do
        -- Special handling for farm - check if inside farm bounds (not center distance)
        if name == "farm" then
            if playerX >= structure.x - 10 and playerX <= structure.x + structure.width + 10 and
               playerY >= structure.y - 10 and playerY <= structure.y + structure.height + 10 then
                return structure, name
            end
        else
            -- For other structures, use center distance check
            local distance = math.sqrt((playerX - structure.x)^2 + (playerY - structure.y)^2)
            if distance <= interactionRange then
                return structure, name
            end
        end
    end
    return nil
end

-- Get farm plot at position
function world.getFarmPlot(x, y)
    if not world.structures.farm.plots then
        world.generateFarmPlots()
    end
    
    for _, plot in ipairs(world.structures.farm.plots) do
        if x >= plot.x and x <= plot.x + plot.width and
           y >= plot.y and y <= plot.y + plot.height then
            return plot
        end
    end
    return nil
end

-- Draw world elements
function world.draw()
    -- DRAW WORLD BOUNDARIES (Visual indicators - scaled 3x)
    love.graphics.setColor(0.8, 0.2, 0.2, 0.6) -- Red boundaries
    love.graphics.setLineWidth(6) -- Was 3
    
    -- Top boundary
    love.graphics.line(150, 150, 2730, 150)
    -- Bottom boundary
    love.graphics.line(150, 1560, 2730, 1560)
    -- Left boundary
    love.graphics.line(150, 150, 150, 1560)
    -- Right boundary
    love.graphics.line(2730, 150, 2730, 1560)
    
    -- Draw corner markers for visibility
    love.graphics.setColor(1, 0, 0, 0.8)
    love.graphics.rectangle("line", 150, 150, 60, 60) -- Top-left (was 20x20)
    love.graphics.rectangle("line", 2670, 150, 60, 60) -- Top-right
    love.graphics.rectangle("line", 150, 1500, 60, 60) -- Bottom-left
    love.graphics.rectangle("line", 2670, 1500, 60, 60) -- Bottom-right
    
    love.graphics.setLineWidth(1) -- Reset line width
    
    -- DRAW TIGER CHASE (high priority - draw first so it's behind player - scaled 3x)
    if Game and Game.tigerChasing and world.tigerChase then
        local tiger = world.tigerChase
        love.graphics.setColor(1, 0.5, 0, 1) -- Orange for tiger
        love.graphics.circle("fill", tiger.x, tiger.y, 60) -- Was 20
        
        -- Draw tiger face
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", tiger.x - 21, tiger.y - 15, 9) -- Eye (scaled 3x)
        love.graphics.circle("fill", tiger.x + 21, tiger.y - 15, 9) -- Eye (scaled 3x)
        love.graphics.arc("line", "open", tiger.x, tiger.y + 15, 24, math.pi * 0.2, math.pi * 0.8) -- Mouth (scaled 3x)
        
        -- Warning text
        love.graphics.setColor(1, 0, 0, math.abs(math.sin(love.timer.getTime() * 5)))
        love.graphics.print("🐅 TIGER CHASING! RUN TO HOUSE!", 300, 20)
    end
    
    -- Always draw hunting zone boundaries (visible circles)
    for name, zone in pairs(world.huntingZones) do
        if zone.active then
            -- Active hunting zone - thicker, colored border
            love.graphics.setColor(1, 0.5, 0, 0.8) -- Orange for active
            love.graphics.setLineWidth(3)
        else
            -- Inactive hunting zone - thin, gray border
            love.graphics.setColor(0.6, 0.6, 0.6, 0.4) -- Gray for inactive
            love.graphics.setLineWidth(1)
        end
        
        love.graphics.circle("line", zone.x, zone.y, zone.radius)
        
        -- Zone name removed to reduce clutter
    end
    
    -- Draw world animals (rare spawns)
    local animalsEntity = require("entities/animals")
    for _, animal in ipairs(world.worldAnimals) do
        if animal.alive then
            animalsEntity.drawAnimal(animal)
        end
    end
    
    -- Draw active hunting zone animals
    local activeZone, activeZoneName = world.getActiveHuntingZone()
    if activeZone then
        for _, animal in ipairs(activeZone.animals) do
            if animal.alive then
                animalsEntity.drawAnimal(animal)
            end
        end
        
        -- Draw hunting zone overlay
        love.graphics.setColor(0.2, 0.4, 0.2, 0.1) -- Dark green tint
        love.graphics.circle("fill", activeZone.x, activeZone.y, activeZone.radius)
    end
    
    -- Draw structure labels and shapes
    love.graphics.setColor(1, 1, 1)
    for name, structure in pairs(world.structures) do
        -- Draw structure placeholder shapes (scaled 3x)
        if name == "cabin" then
            love.graphics.setColor(0.6, 0.3, 0.1) -- Brown cabin
            love.graphics.rectangle("fill", structure.x, structure.y, structure.width, structure.height)
            love.graphics.setColor(0.4, 0.2, 0.1) -- Darker roof
            love.graphics.rectangle("fill", structure.x - 15, structure.y - 30, structure.width + 30, 45) -- Scaled 3x
            
            -- BOUNDARY OUTLINE for cabin
            love.graphics.setColor(1, 1, 0, 0.7) -- Yellow outline
            love.graphics.setLineWidth(6) -- Was 2
            love.graphics.rectangle("line", structure.x - 6, structure.y - 6, structure.width + 12, structure.height + 12) -- Scaled 3x
            love.graphics.setLineWidth(1)
            
        elseif name == "pond" then
            love.graphics.setColor(0.2, 0.4, 0.8) -- Blue pond
            love.graphics.ellipse("fill", structure.x + structure.width/2, structure.y + structure.height/2, structure.width/2, structure.height/2)
            -- Draw pond outline as ellipse
            love.graphics.setColor(0.1, 0.3, 0.6) -- Darker blue outline
            love.graphics.ellipse("line", structure.x + structure.width/2, structure.y + structure.height/2, structure.width/2, structure.height/2)
        -- Farm structure is NOT drawn here - handled by farming.draw() instead to avoid duplicate
        -- elseif name == "farm" then
        --     love.graphics.setColor(0.4, 0.2, 0.1) -- Brown farm plots
        --     love.graphics.rectangle("fill", structure.x, structure.y, structure.width, structure.height)
        -- Shop structure removed - outside visible screen area (y=620 > 540)
        -- elseif name == "shop" then
        --     love.graphics.setColor(0.5, 0.5, 0.5) -- Gray shop
        --     love.graphics.rectangle("fill", structure.x, structure.y, structure.width, structure.height)
        elseif name == "railway" then
            -- Draw railway station building (scaled 3x)
            love.graphics.setColor(0.4, 0.3, 0.2) -- Dark brown for old wood
            love.graphics.rectangle("fill", structure.x, structure.y, structure.width, structure.height)
            
            -- Draw roof
            love.graphics.setColor(0.3, 0.2, 0.1) -- Darker roof
            love.graphics.rectangle("fill", structure.x - 15, structure.y - 30, structure.width + 30, 45) -- Scaled 3x
            
            -- Draw door
            love.graphics.setColor(0.2, 0.1, 0.05) -- Very dark door
            love.graphics.rectangle("fill", structure.x + structure.width/2 - 30, structure.y + structure.height - 75, 60, 75) -- Scaled 3x
            
            -- Draw windows
            love.graphics.setColor(0.8, 0.8, 0.6) -- Yellowish windows
            love.graphics.rectangle("fill", structure.x + 45, structure.y + 45, 60, 45) -- Scaled 3x
            love.graphics.rectangle("fill", structure.x + structure.width - 105, structure.y + 45, 60, 45) -- Scaled 3x
            
            -- Draw railway tracks
            love.graphics.setColor(0.5, 0.5, 0.5) -- Gray tracks
            love.graphics.setLineWidth(9) -- Was 3
            love.graphics.line(structure.x - 60, structure.y + structure.height + 15, structure.x + structure.width + 60, structure.y + structure.height + 15) -- Scaled 3x
            love.graphics.line(structure.x - 60, structure.y + structure.height + 45, structure.x + structure.width + 60, structure.y + structure.height + 45) -- Scaled 3x
            love.graphics.setLineWidth(1) -- Reset line width
        end
        
        -- Draw structure outline (except for pond, farm, and shop)
        if name ~= "pond" and name ~= "farm" and name ~= "shop" then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", structure.x, structure.y, structure.width, structure.height)
        end
        
        -- Structure name removed to reduce clutter (shown in areas.lua instead)
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1) -- Reset line width
end

-- Update world systems
function world.update(dt, playerX, playerY)
    world.updateWorldAnimals(dt)
    
    -- Safety check: if no player position provided, skip tiger chase
    if not playerX or not playerY then
        return
    end
    
    -- TIGER CHASE SYSTEM
    if Game and Game.tigerChasing and world.tigerChase then
        local tiger = world.tigerChase
        
        -- CRITICAL FIX: Check if tiger is dead (health tracking if linked to hunting state)
        if tiger.health and tiger.health <= 0 then
            print("═══════════════════════════════════════")
            print("🐅 The tiger collapsed from its wounds!")
            print("✅ You survived the chase!")
            print("═══════════════════════════════════════")
            
            Game.tigerChasing = false
            Game.tigerWarning = false
            world.tigerChase = nil
            return
        end
        
        -- Move tiger toward player
        local dx = playerX - tiger.x
        local dy = playerY - tiger.y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        if distance > 0 then
            -- Normalize and move
            tiger.x = tiger.x + (dx / distance) * tiger.speed * dt
            tiger.y = tiger.y + (dy / distance) * tiger.speed * dt
        end
        
        -- Check if tiger caught player
        if distance < 30 then
            print("═══════════════════════════════════════")
            print("💀 THE TIGER CAUGHT YOU!")
            print("☠️  GAME OVER")
            print("═══════════════════════════════════════")
            
            -- Switch to death screen
            local gamestate = require("states/gamestate")
            gamestate.switch("death")
            return
        end
        
        -- Check if player reached house (safe zone)
        local houseX = world.structures.cabin.x + world.structures.cabin.width/2
        local houseY = world.structures.cabin.y + world.structures.cabin.height/2
        local distanceToHouse = math.sqrt((playerX - houseX)^2 + (playerY - houseY)^2)
        
        if distanceToHouse < 50 then
            print("═══════════════════════════════════════")
            print("🏠 YOU MADE IT HOME SAFELY!")
            print("✅ The tiger gives up and runs away")
            print("═══════════════════════════════════════")
            
            -- Remove tiger chase
            Game.tigerChasing = false
            Game.tigerWarning = false
            world.tigerChase = nil
        end
    end
    
    -- Initialize tiger chase if triggered
    if Game and Game.tigerChasing and not world.tigerChase then
        -- Spawn tiger behind player
        world.tigerChase = {
            x = playerX - 100,
            y = playerY,
            speed = 85 -- Slightly slower than player (player = ~100) - gives reaction time!
        }
        print("🐅 Tiger chase started! Run to your house!")
    end
    
    -- Update active hunting zone animals
    local activeZone = world.getActiveHuntingZone()
    if activeZone then
        local animalsEntity = require("entities/animals")
        
        for i = #activeZone.animals, 1, -1 do
            local animal = activeZone.animals[i]
            
            if not animal.alive then
                table.remove(activeZone.animals, i)
            else
                animalsEntity.updateAnimal(animal, dt)
                
                -- Check if animal left hunting zone boundaries
                local distance = math.sqrt((animal.x - activeZone.x)^2 + (animal.y - activeZone.y)^2)
                if distance > activeZone.radius then
                    -- Animal left zone - despawn it
                    table.remove(activeZone.animals, i)
                    print("🦌 An animal wandered away and disappeared...")
                end
            end
        end
    end
end

-- Initialize world
function world.load()
    world.generateFarmPlots()
    world.worldAnimals = {}
    world.animalSpawnTimer = 0
    
    -- Start with one rare animal in the world
    world.spawnRandomWorldAnimal()
    
    print("🗺️  World map loaded with " .. #world.structures.farm.plots .. " farm plots")
    print("🌲  Forest atmosphere active - animals appear rarely in the wild")
end

return world