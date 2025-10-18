-- Animals Entity
-- Defines different animal types and their behaviors
-- SINGLE SOURCE OF TRUTH for all animal data (used in both overworld and hunting)

local animals = {}

-- Animal definitions (UNIFIED for overworld and hunting)
animals.types = {
    rabbit = {
        name = "Rabbit",
        -- Overworld stats
        size = {16, 12},
        speed = 80,
        health = 20,
        meat = 2,
        aggressive = false,
        spawnChance = 0.7,
        color = {0.8, 0.7, 0.5},
        
        -- Hunting minigame stats
        huntingStats = {
            spawnChance = 0.5,
            maxHealth = 50,
            speed = 150,
            fleeSpeed = 300,
            size = 40,
            meatValue = 15,
            meatCount = 1,
            headshotBonus = 2,
            behavior = "dart",
            hideTime = {min = 2, max = 4},
            showTime = {min = 1, max = 3},
            audioRadius = 100
        }
    },
    deer = {
        name = "Deer",
        -- Overworld stats
        size = {24, 20},
        speed = 100,
        health = 40,
        meat = 5,
        aggressive = false,
        spawnChance = 0.4,
        color = {0.6, 0.4, 0.2},
        
        -- Hunting minigame stats
        huntingStats = {
            spawnChance = 0.3,
            maxHealth = 150,
            speed = 80,
            fleeSpeed = 200,
            size = 80,
            meatValue = 30,
            meatCount = 2,
            headshotBonus = 2,
            behavior = "graze",
            hideTime = {min = 1, max = 2},
            showTime = {min = 4, max = 8},
            audioRadius = 120
        }
    },
    boar = {
        name = "Boar",
        -- Overworld stats
        size = {20, 16},
        speed = 60,
        health = 60,
        meat = 8,
        aggressive = true,
        spawnChance = 0.2,
        color = {0.3, 0.2, 0.1},
        
        -- Hunting minigame stats
        huntingStats = {
            spawnChance = 0.15,
            maxHealth = 250,
            speed = 100,
            fleeSpeed = 180,
            size = 60,
            meatValue = 50,
            meatCount = 3,
            headshotBonus = 1.5,
            behavior = "charge",
            hideTime = {min = 3, max = 5},
            showTime = {min = 2, max = 4},
            audioRadius = 150
        }
    },
    tiger = {
        name = "Tiger",
        -- Overworld stats
        size = {32, 24},
        speed = 110,
        health = 100,
        meat = 0, -- Can't hunt tigers
        aggressive = true,
        dangerous = true,
        spawnChance = 0.2,
        color = {1, 0.5, 0},
        
        -- Hunting minigame stats
        huntingStats = {
            spawnChance = 0.05, -- NORMALIZED: 5% base spawn rate (rare encounter)
            nightSpawnMultiplier = 4, -- 4x more common at night (20% spawn rate)
            maxHealth = 500,
            speed = 120,
            attackSpeed = 250,
            size = 100,
            meatValue = 100,
            meatCount = 5,
            headshotBonus = 2,
            behavior = "passive",
            dangerous = true,
            hideTime = {min = 5, max = 10},
            showTime = {min = 3, max = 6},
            audioRadius = 200
        }
    }
}

-- Active animals in the world
animals.active = {}

function animals.create(animalType, x, y)
    local animalData = animals.types[animalType]
    if not animalData then return nil end
    
    local animal = {
        type = animalType,
        x = x,
        y = y,
        width = animalData.size[1],
        height = animalData.size[2],
        health = animalData.health,
        maxHealth = animalData.health,
        speed = animalData.speed,
        direction = math.random() * math.pi * 2,
        moveTimer = 0,
        alive = true,
        fleeing = false
    }
    
    return animal
end

function animals.spawn(animalType, x, y)
    local animal = animals.create(animalType, x, y)
    if animal then
        table.insert(animals.active, animal)
        return animal
    end
    return nil
end

function animals.update(dt)
    for i = #animals.active, 1, -1 do
        local animal = animals.active[i]
        
        if not animal.alive then
            table.remove(animals.active, i)
        else
            animals.updateAnimal(animal, dt)
        end
    end
end

function animals.updateAnimal(animal, dt)
    local animalData = animals.types[animal.type]
    
    -- Simple AI behavior
    animal.moveTimer = animal.moveTimer + dt
    
    if animal.moveTimer > 2 then
        -- Change direction every 2 seconds
        animal.direction = math.random() * math.pi * 2
        animal.moveTimer = 0
    end
    
    -- Move animal
    local moveSpeed = animal.speed * dt
    if animal.fleeing then
        moveSpeed = moveSpeed * 1.5 -- Move faster when fleeing
    end
    
    animal.x = animal.x + math.cos(animal.direction) * moveSpeed
    animal.y = animal.y + math.sin(animal.direction) * moveSpeed
    
    -- DESPAWN animals that escape boundaries (SIMPLIFIED - no bounce)
    -- World playable area: 50 to 910 width, 50 to 520 height
    if animal.x < 40 or animal.x > 920 or animal.y < 40 or animal.y > 530 then
        animal.alive = false -- Mark for removal
        print("🦌 Animal wandered off and disappeared")
        return
    end
    
    -- Reset fleeing state after some time
    if animal.fleeing then
        animal.fleeTimer = (animal.fleeTimer or 0) + dt
        if animal.fleeTimer > 3 then
            animal.fleeing = false
            animal.fleeTimer = 0
        end
    end
end

function animals.draw()
    for _, animal in ipairs(animals.active) do
        animals.drawAnimal(animal)
    end
end

function animals.drawAnimal(animal)
    local animalData = animals.types[animal.type]
    
    -- Set color based on animal type
    love.graphics.setColor(animalData.color)
    
    -- Draw animal
    love.graphics.rectangle("fill", animal.x, animal.y, animal.width, animal.height)
    
    -- Draw health bar for damaged animals
    if animal.health < animal.maxHealth then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", animal.x, animal.y - 8, animal.width, 4)
        love.graphics.setColor(0, 1, 0)
        local healthPercent = animal.health / animal.maxHealth
        love.graphics.rectangle("fill", animal.x, animal.y - 8, animal.width * healthPercent, 4)
    end
    
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function animals.getNearbyAnimals(x, y, radius)
    local nearby = {}
    
    for _, animal in ipairs(animals.active) do
        local distance = math.sqrt((animal.x - x)^2 + (animal.y - y)^2)
        if distance <= radius then
            table.insert(nearby, animal)
        end
    end
    
    return nearby
end

function animals.huntAnimal(animal)
    local animalData = animals.types[animal.type]
    
    if animalData.dangerous then
        -- Dangerous animals trigger flee events
        return "flee", animal.type
    else
        -- Normal hunting
        animal.alive = false
        return "success", animalData.meat
    end
end

function animals.damageAnimal(animal, damage)
    animal.health = animal.health - damage
    animal.fleeing = true
    
    if animal.health <= 0 then
        animal.alive = false
        return true -- Animal died
    end
    
    return false -- Animal survived
end

function animals.clearAll()
    animals.active = {}
end

return animals