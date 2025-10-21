-- Fishing State - Top-Down Spear Fishing (Like Hunting Areas)
local fishing = {}

fishing.active = false
fishing.currentArea = nil
fishing.fish = {}
fishing.fishCaught = 0
fishing.snake = nil
fishing.snakeSpawnTimer = 0
fishing.snakeWarning = false
fishing.snakeWarningTimer = 0
fishing.projectiles = {}
fishing.hasNet = false
fishing.playerX = 400
fishing.playerY = 550
fishing.mouseX = 0
fishing.mouseY = 0
fishing.timeInSession = 0

fishing.fishTypes = {
    small_fish = {name = "Small Fish", size = 20, speed = 100, value = 5},
    bass = {name = "Bass", size = 30, speed = 80, value = 12},
    catfish = {name = "Catfish", size = 40, speed = 60, value = 20},
    rare_trout = {name = "Rare Trout", size = 35, speed = 120, value = 35}
}

function fishing:enter(fromState, areaId)
    print("🎣 Entering Fishing Area")
    fishing.currentArea = areaId or "fishing_pond"
    fishing.active = true
    fishing.timeInSession = 0
    fishing.fishCaught = 0
    fishing.projectiles = {}
    
    local playerEntity = require("entities/player")
    fishing.hasNet = playerEntity.hasItem("fishingNet") or false
    
    local areas = require("systems/areas")
    local areaData = areas.definitions[fishing.currentArea]
    
    if areaData then
        local fishCount = math.random(areaData.fishCount.min, areaData.fishCount.max)
        fishing:spawnFish(fishCount, areaData.fishTypes)
        fishing.snakeSpawnTimer = math.random(30, 60)
        fishing.snake = nil
    end
    
    love.mouse.setVisible(true)
    print("🐟 Spawned " .. #fishing.fish .. " fish")
end

function fishing:spawnFish(count, fishTypeNames)
    fishing.fish = {}
    for i = 1, count do
        local typeName = fishTypeNames[math.random(#fishTypeNames)]
        local fishType = fishing.fishTypes[typeName]
        if fishType then
            table.insert(fishing.fish, {
                type = fishType,
                typeName = typeName,
                x = math.random(100, 700),
                y = math.random(100, 500),
                vx = (math.random() - 0.5) * fishType.speed,
                vy = (math.random() - 0.5) * fishType.speed
            })
        end
    end
end

function fishing:update(dt)
    if not fishing.active then return end
    if Game and Game.paused then return end
    
    fishing.timeInSession = fishing.timeInSession + dt
    fishing.mouseX, fishing.mouseY = love.mouse.getPosition()
    
    -- Update fish
    for _, fish in ipairs(fishing.fish) do
        fish.x = fish.x + fish.vx * dt
        fish.y = fish.y + fish.vy * dt
        if math.random() < 0.02 then
            fish.vx = (math.random() - 0.5) * fish.type.speed
            fish.vy = (math.random() - 0.5) * fish.type.speed
        end
        if fish.x < 100 or fish.x > 700 then fish.vx = -fish.vx end
        if fish.y < 100 or fish.y > 500 then fish.vy = -fish.vy end
    end
    
    -- Update projectiles
    for i = #fishing.projectiles, 1, -1 do
        local proj = fishing.projectiles[i]
        proj.x = proj.x + proj.vx * dt
        proj.y = proj.y + proj.vy * dt
        proj.lifetime = proj.lifetime - dt
        
        for j = #fishing.fish, 1, -1 do
            local fish = fishing.fish[j]
            local distance = math.sqrt((proj.x - fish.x)^2 + (proj.y - fish.y)^2)
            if distance < proj.aoe + fish.type.size / 2 then
                fishing:catchFish(fish, j)
                proj.lifetime = 0
            end
        end
        
        if fishing.snake and not fishing.snake.dead then
            local distance = math.sqrt((proj.x - fishing.snake.x)^2 + (proj.y - fishing.snake.y)^2)
            if distance < 30 then
                fishing:killSnake()
                proj.lifetime = 0
            end
        end
        
        if proj.lifetime <= 0 or proj.x < 0 or proj.x > 800 or proj.y < 0 or proj.y > 600 then
            table.remove(fishing.projectiles, i)
        end
    end
    
    -- Update snake
    fishing:updateSnake(dt)
end

function fishing:updateSnake(dt)
    if not fishing.snake then
        fishing.snakeSpawnTimer = fishing.snakeSpawnTimer - dt
        if fishing.snakeSpawnTimer <= 0 then
            fishing:spawnSnake()
        end
    else
        if not fishing.snake.dead then
            if fishing.snakeWarning and fishing.snakeWarningTimer > 0 then
                fishing.snakeWarningTimer = fishing.snakeWarningTimer - dt
                if fishing.snakeWarningTimer <= 0 then
                    fishing.snakeWarning = false
                end
            end
            
            if not fishing.snakeWarning then
                local dx = fishing.playerX - fishing.snake.x
                local dy = fishing.playerY - fishing.snake.y
                local distance = math.sqrt(dx * dx + dy * dy)
                
                if distance > 0 then
                    fishing.snake.vx = (dx / distance) * 150
                    fishing.snake.vy = (dy / distance) * 150
                end
                
                fishing.snake.x = fishing.snake.x + fishing.snake.vx * dt
                fishing.snake.y = fishing.snake.y + fishing.snake.vy * dt
                
                if distance < 40 then
                    fishing:snakeBitePlayer()
                    return
                end
            end
        end
    end
end

function fishing:spawnSnake()
    local edge = math.random(1, 4)
    local x, y
    if edge == 1 then x = math.random(100, 700); y = 100
    elseif edge == 2 then x = 700; y = math.random(100, 500)
    elseif edge == 3 then x = math.random(100, 700); y = 500
    else x = 100; y = math.random(100, 500) end
    
    fishing.snake = {x = x, y = y, vx = 0, vy = 0, dead = false}
    fishing.snakeWarning = true
    fishing.snakeWarningTimer = 3.0
    print("⚠️  🐍 WATER SNAKE! 3 seconds!")
end

function fishing:killSnake()
    local playerEntity = require("entities/player")
    playerEntity.addItem("snake_skin", 1)
    playerEntity.addMoney(15)
    fishing.snake = nil
    fishing.snakeSpawnTimer = math.random(30, 60)
    print("💀 Killed snake! +$15")
end

function fishing:snakeBitePlayer()
    print("💀 SNAKE BIT YOU!")
    fishing.active = false
    love.mouse.setVisible(false)
    local gamestate = require("states/gamestate")
    gamestate.switch("death", "snake")
end

function fishing:throwSpear()
    local dx = fishing.mouseX - fishing.playerX
    local dy = fishing.mouseY - fishing.playerY
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance > 0 then dx = dx / distance; dy = dy / distance end
    
    table.insert(fishing.projectiles, {
        x = fishing.playerX,
        y = fishing.playerY,
        vx = dx * 400,
        vy = dy * 400,
        lifetime = 1.0,
        isNet = fishing.hasNet,
        aoe = fishing.hasNet and 50 or 10
    })
end

function fishing:catchFish(fish, index)
    local playerEntity = require("entities/player")
    playerEntity.addItem(fish.typeName, 1)
    playerEntity.addMoney(fish.type.value)
    fishing.fishCaught = fishing.fishCaught + 1
    table.remove(fishing.fish, index)
    print("🐟 Caught " .. fish.type.name .. "! +$" .. fish.type.value)
end

function fishing:draw()
    if not fishing.active then return end
    
    love.graphics.setColor(0.2, 0.5, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    for _, fish in ipairs(fishing.fish) do
        love.graphics.setColor(0.1, 0.2, 0.3, 0.6)
        love.graphics.circle("fill", fish.x, fish.y, fish.type.size / 2)
    end
    
    if fishing.snake and not fishing.snake.dead then
        if fishing.snakeWarning then
            local pulse = 0.5 + math.sin(love.timer.getTime() * 10) * 0.5
            love.graphics.setColor(1, 0, 0, pulse)
        else
            love.graphics.setColor(0.8, 0, 0)
        end
        love.graphics.circle("fill", fishing.snake.x, fishing.snake.y, 25)
        if fishing.snakeWarning then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("⚠️ SNAKE! " .. string.format("%.1f", fishing.snakeWarningTimer), fishing.snake.x - 30, fishing.snake.y - 40)
        end
    end
    
    for _, proj in ipairs(fishing.projectiles) do
        love.graphics.setColor(0.6, 0.4, 0.2)
        if proj.isNet then
            love.graphics.circle("line", proj.x, proj.y, 25)
        else
            love.graphics.circle("fill", proj.x, proj.y, 5)
        end
    end
    
    love.graphics.setColor(0.8, 0.7, 0.6)
    love.graphics.circle("fill", fishing.playerX - 10, fishing.playerY, 8)
    love.graphics.circle("fill", fishing.playerX + 10, fishing.playerY, 8)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", fishing.mouseX, fishing.mouseY, 10)
    love.graphics.line(fishing.mouseX - 15, fishing.mouseY, fishing.mouseX - 5, fishing.mouseY)
    love.graphics.line(fishing.mouseX + 5, fishing.mouseY, fishing.mouseX + 15, fishing.mouseY)
    love.graphics.line(fishing.mouseX, fishing.mouseY - 15, fishing.mouseX, fishing.mouseY - 5)
    love.graphics.line(fishing.mouseX, fishing.mouseY + 5, fishing.mouseX, fishing.mouseY + 15)
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 40)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("🐟 Fish: " .. fishing.fishCaught, 20, 10)
    love.graphics.print("⏱ Time: " .. string.format("%.1f", fishing.timeInSession), 200, 10)
    love.graphics.print("🎣 " .. (fishing.hasNet and "Net" or "Spear"), 400, 10)
    love.graphics.print("LEFT CLICK: Throw | ESC: Exit", 20, 560)
end

function fishing:mousepressed(x, y, button)
    if button == 1 and fishing.active then
        fishing:throwSpear()
    end
end

function fishing:keypressed(key)
    if key == "escape" then
        fishing.active = false
        love.mouse.setVisible(false)
        local gamestate = require("states/gamestate")
        gamestate.switch("gameplay")
    end
end

return fishing
