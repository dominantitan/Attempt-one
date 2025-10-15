-- Hunting System
-- Manages animal interactions, hunting mechanics, and danger events

local hunting = {}

-- Animals in the world
hunting.animals = {}
hunting.animalTypes = {
    rabbit = { health = 25, speed = 150, value = 10, aggressive = false },
    deer = { health = 50, speed = 120, value = 25, aggressive = false },
    boar = { health = 75, speed = 100, value = 40, aggressive = true },
    tiger = { health = 150, speed = 200, value = 0, aggressive = true, dangerous = true }
}

function hunting.load()
    -- Spawn initial animals
    hunting.spawnAnimal("rabbit", 300, 400)
    hunting.spawnAnimal("deer", 500, 300)
end

function hunting.update(dt)
    -- Update animal behavior
    for i, animal in ipairs(hunting.animals) do
        -- Simple AI movement
        animal.x = animal.x + math.random(-20, 20) * dt
        animal.y = animal.y + math.random(-20, 20) * dt
        
        -- Keep animals within bounds
        animal.x = math.max(50, math.min(910, animal.x))
        animal.y = math.max(50, math.min(490, animal.y))
    end
end

function hunting.draw()
    -- Draw animals
    for i, animal in ipairs(hunting.animals) do
        if animal.type == "rabbit" then
            love.graphics.setColor(0.8, 0.8, 0.6) -- Light brown
        elseif animal.type == "deer" then
            love.graphics.setColor(0.6, 0.4, 0.2) -- Brown
        elseif animal.type == "boar" then
            love.graphics.setColor(0.3, 0.2, 0.1) -- Dark brown
        elseif animal.type == "tiger" then
            love.graphics.setColor(1, 0.5, 0) -- Orange
        end
        
        love.graphics.rectangle("fill", animal.x, animal.y, 24, 16)
    end
    
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function hunting.spawnAnimal(animalType, x, y)
    local animal = {
        type = animalType,
        x = x,
        y = y,
        health = hunting.animalTypes[animalType].health,
        alive = true
    }
    
    table.insert(hunting.animals, animal)
end

function hunting.huntAnimal(playerX, playerY)
    -- Try to hunt nearby animal
    for i, animal in ipairs(hunting.animals) do
        local distance = math.sqrt((animal.x - playerX)^2 + (animal.y - playerY)^2)
        
        if distance < 40 and animal.alive then
            if animal.type == "tiger" then
                -- Tiger encounter - trigger flee event
                return "tiger_encounter"
            else
                -- Successful hunt
                animal.alive = false
                table.remove(hunting.animals, i)
                return animal.type
            end
        end
    end
    
    return nil
end

function hunting.spawnTiger(x, y)
    -- Special function to spawn dangerous tiger
    hunting.spawnAnimal("tiger", x, y)
end

return hunting