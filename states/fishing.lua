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
fishing.playerY = 550  -- Bottom of screen - player standing above pond looking down
fishing.mouseX = 0
fishing.mouseY = 0
fishing.timeInSession = 0
fishing.rocks = {}
fishing.playerFeetBitten = false
fishing.feetBiteTimer = 0
fishing.spearStuck = false
fishing.stuckSpear = nil
fishing.retrievalClicks = 0
fishing.retrievalNeeded = 3
fishing.spearHeight = 0  -- For 3D spear throw animation
fishing.spearShadowOffset = 0  -- Shadow offset based on height
fishing.throwCooldown = 0  -- Prevent multi-throw glitch
fishing.throwCooldownTime = 0.3  -- Minimum time between throws

-- Power Bar System (Stardew Valley style)
fishing.powerBar = {
    charging = false,         -- Is player holding mouse button?
    power = 0,                -- Current power level (0 to 1)
    chargeSpeed = 1.5,        -- How fast the bar fills (full charge in ~0.67 seconds)
    minPower = 0.2,           -- Minimum throw power (20%)
    maxPower = 1.0,           -- Maximum throw power (100%)
    x = 750,                  -- Bar position X (right side of screen)
    y = 200,                  -- Bar position Y
    width = 30,               -- Bar width
    height = 200,             -- Bar height (vertical)
}

-- Small visual fish (boids)
fishing.boidFish = {}
fishing.boidCount = 30  -- Number of small visual fish

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
    
    print("🎣 Entering fishing area: " .. fishing.currentArea)
    print("📍 Area data found: " .. tostring(areaData ~= nil))
    
    if areaData then
        local fishCount = math.random(areaData.fishCount.min, areaData.fishCount.max)
        print("🐟 Spawning " .. fishCount .. " fish...")
        fishing:spawnFish(fishCount, areaData.fishTypes)
        print("✅ Fish spawned: " .. #fishing.fish .. " total")
        fishing.snakeSpawnTimer = math.random(30, 60)
        fishing.snake = nil
        
        -- Spawn 3-5 big rocks as hiding spots
        fishing.rocks = {}
        for i = 1, math.random(3, 5) do
            table.insert(fishing.rocks, {
                x = math.random(150, 650),
                y = math.random(150, 450),
                size = math.random(40, 70)
            })
        end
    end
    
    fishing.playerFeetBitten = false
    fishing.feetBiteTimer = 0
    fishing.spearStuck = false
    fishing.stuckSpear = nil
    fishing.retrievalClicks = 0
    fishing.throwCooldown = 0
    
    -- Reset power bar
    fishing.powerBar.charging = false
    fishing.powerBar.power = 0
    
    -- Spawn small boid fish for visual effect
    fishing.boidFish = {}
    for i = 1, fishing.boidCount do
        local angle = math.random() * 2 * math.pi
        local distance = math.random(50, 250)
        table.insert(fishing.boidFish, {
            x = 400 + math.cos(angle) * distance,
            y = 300 + math.sin(angle) * distance,
            vx = (math.random() - 0.5) * 60,
            vy = (math.random() - 0.5) * 60,
            size = 5
        })
    end
    print("🐠 Spawned " .. fishing.boidCount .. " small boid fish for visual effect")
    
    love.mouse.setVisible(true)
end

function fishing:spawnFish(count, fishTypeNames)
    fishing.fish = {}
    
    -- Pond center coordinates for fish to swim toward
    local pondCenterX = 400
    local pondCenterY = 300
    
    for i = 1, count do
        local typeName = fishTypeNames[math.random(#fishTypeNames)]
        local fishType = fishing.fishTypes[typeName]
        if fishType then
            -- Spawn fish OUTSIDE the pond boundaries (at edges)
            local edge = math.random(1, 4)
            local x, y, initialVx, initialVy
            
            if edge == 1 then -- Top edge
                x = math.random(100, 700)
                y = -50
                -- Initial velocity toward center
                local dx = pondCenterX - x
                local dy = pondCenterY - y
                local dist = math.sqrt(dx*dx + dy*dy)
                initialVx = (dx / dist) * fishType.speed * 0.5
                initialVy = (dy / dist) * fishType.speed * 0.5
            elseif edge == 2 then -- Right edge
                x = 850
                y = math.random(100, 500)
                local dx = pondCenterX - x
                local dy = pondCenterY - y
                local dist = math.sqrt(dx*dx + dy*dy)
                initialVx = (dx / dist) * fishType.speed * 0.5
                initialVy = (dy / dist) * fishType.speed * 0.5
            elseif edge == 3 then -- Bottom edge
                x = math.random(100, 700)
                y = 650
                local dx = pondCenterX - x
                local dy = pondCenterY - y
                local dist = math.sqrt(dx*dx + dy*dy)
                initialVx = (dx / dist) * fishType.speed * 0.5
                initialVy = (dy / dist) * fishType.speed * 0.5
            else -- Left edge
                x = -50
                y = math.random(100, 500)
                local dx = pondCenterX - x
                local dy = pondCenterY - y
                local dist = math.sqrt(dx*dx + dy*dy)
                initialVx = (dx / dist) * fishType.speed * 0.5
                initialVy = (dy / dist) * fishType.speed * 0.5
            end
            
            table.insert(fishing.fish, {
                type = fishType,
                typeName = typeName,
                x = x,
                y = y,
                vx = initialVx,
                vy = initialVy,
                hiding = false,
                entering = true, -- Flag to indicate fish is entering pond
                -- Animal behavior state
                state = "entering", -- entering, swimming, fleeing, hiding, curious
                targetX = math.random(200, 600),
                targetY = math.random(200, 400),
                idleTimer = math.random(2, 5),
                panicTimer = 0
            })
        end
    end
    print("🐟 Spawned " .. #fishing.fish .. " fish at pond edges, swimming toward center")
end

function fishing:update(dt)
    if not fishing.active then return end
    if Game and Game.paused then return end
    
    fishing.timeInSession = fishing.timeInSession + dt
    fishing.mouseX, fishing.mouseY = love.mouse.getPosition()
    
    -- Update Power Bar charging
    if fishing.powerBar.charging and not fishing.spearStuck then
        fishing.powerBar.power = fishing.powerBar.power + (fishing.powerBar.chargeSpeed * dt)
        -- Clamp power to max
        if fishing.powerBar.power > fishing.powerBar.maxPower then
            fishing.powerBar.power = fishing.powerBar.maxPower
        end
    end
    
    -- Update throw cooldown
    if fishing.throwCooldown > 0 then
        fishing.throwCooldown = fishing.throwCooldown - dt
    end
    
    -- Update stuck spear pull effect
    if fishing.stuckSpear and fishing.stuckSpear.pullTime then
        fishing.stuckSpear.pullTime = fishing.stuckSpear.pullTime - dt
        if fishing.stuckSpear.pullTime <= 0 then
            fishing.stuckSpear.pullTime = nil
        end
    end
    
    -- Update boid fish (simple flocking algorithm)
    fishing:updateBoids(dt)
    
    -- GOD-TIER FISH BEHAVIOR: Natural, Realistic, Simple
    for i = #fishing.fish, 1, -1 do
        local fish = fishing.fish[i]
        
        -- Check if hiding behind rocks
        fish.hiding = false
        for _, rock in ipairs(fishing.rocks) do
            local distToRock = math.sqrt((fish.x - rock.x)^2 + (fish.y - rock.y)^2)
            if distToRock < rock.size / 2 + 15 then
                fish.hiding = true
                fish.state = "hiding"
                break
            end
        end
        
        -- Detect danger (spears in air)
        local dangerClose = false
        local dangerX, dangerY = 0, 0
        for _, proj in ipairs(fishing.projectiles) do
            local dist = math.sqrt((fish.x - proj.x)^2 + (fish.y - proj.y)^2)
            if dist < 200 and proj.height < 100 then -- Spear coming down!
                dangerClose = true
                dangerX, dangerY = proj.x, proj.y
                break
            end
        end
        
        -- REAL FISH BEHAVIOR STATE MACHINE
        if dangerClose then
            -- FLEE! Burst speed away from danger
            fish.state = "fleeing"
            fish.entering = false
            fish.panicTimer = 3.0
            local dx = fish.x - dangerX
            local dy = fish.y - dangerY
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist > 0 then
                fish.vx = (dx / dist) * fish.type.speed * 3 -- FAST!
                fish.vy = (dy / dist) * fish.type.speed * 3
            end
        elseif fish.entering then
            -- Fish is entering pond from outside - swim toward center
            local pondCenterX = 400
            local pondCenterY = 300
            local dx = pondCenterX - fish.x
            local dy = pondCenterY - fish.y
            local distToCenter = math.sqrt(dx*dx + dy*dy)
            
            -- Once close to center (within pond area), start normal behavior
            if distToCenter < 150 then
                fish.entering = false
                fish.state = "swimming"
                fish.targetX = math.random(200, 600)
                fish.targetY = math.random(200, 400)
                fish.idleTimer = math.random(2, 5)
                print("🐟 Fish entered pond and started natural swimming")
            else
                -- Continue swimming toward center
                fish.vx = (dx / distToCenter) * fish.type.speed * 0.6
                fish.vy = (dy / distToCenter) * fish.type.speed * 0.6
            end
        elseif fish.panicTimer > 0 then
            -- Still panicking, swim fast
            fish.panicTimer = fish.panicTimer - dt
        else
            -- CALM: Natural swimming behavior
            fish.idleTimer = fish.idleTimer - dt
            
            if fish.idleTimer <= 0 then
                -- Pick new random target to swim toward (stay within pond bounds)
                fish.targetX = math.random(150, 650)
                fish.targetY = math.random(150, 450)
                fish.idleTimer = math.random(3, 7)
                fish.state = "swimming"
            end
            
            -- Swim toward target smoothly
            local dx = fish.targetX - fish.x
            local dy = fish.targetY - fish.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist > 20 then
                fish.vx = (dx / dist) * fish.type.speed * 0.7
                fish.vy = (dy / dist) * fish.type.speed * 0.7
            else
                -- Reached target, slow down
                fish.vx = fish.vx * 0.95
                fish.vy = fish.vy * 0.95
            end
        end
        
        -- Move fish
        fish.x = fish.x + fish.vx * dt
        fish.y = fish.y + fish.vy * dt
        
        -- Boundary handling - NO DESPAWNING, just bounce back
        -- Keep fish within extended boundaries (allow some margin)
        if fish.x < -100 then 
            fish.x = -100
            fish.vx = math.abs(fish.vx)
            fish.targetX = math.random(200, 400)
        elseif fish.x > 900 then 
            fish.x = 900
            fish.vx = -math.abs(fish.vx)
            fish.targetX = math.random(400, 600)
        end
        
        if fish.y < -100 then 
            fish.y = -100
            fish.vy = math.abs(fish.vy)
            fish.targetY = math.random(200, 400)
        elseif fish.y > 700 then 
            fish.y = 700
            fish.vy = -math.abs(fish.vy)
            fish.targetY = math.random(200, 400)
        end
        
        -- Soft boundary nudging when inside pond (keep fish mostly in visible area)
        if not fish.entering and fish.panicTimer <= 0 then
            if fish.x < 100 then 
                fish.vx = fish.vx + 20 * dt -- Gentle push inward
                fish.targetX = math.random(200, 400)
            elseif fish.x > 700 then 
                fish.vx = fish.vx - 20 * dt
                fish.targetX = math.random(400, 600)
            end
            
            if fish.y < 100 then 
                fish.vy = fish.vy + 20 * dt
                fish.targetY = math.random(200, 400)
            elseif fish.y > 500 then 
                fish.vy = fish.vy - 20 * dt
                fish.targetY = math.random(200, 400)
            end
        end
    end
    
    -- Update projectiles (3D spear physics with arc trajectory)
    for i = #fishing.projectiles, 1, -1 do
        local proj = fishing.projectiles[i]
        
        -- Update flight progress (0 to 1)
        proj.flightProgress = proj.flightProgress + (dt / proj.maxLifetime)
        proj.lifetime = proj.lifetime - dt
        
        -- Move spear toward target using smooth interpolation
        proj.x = proj.x + proj.vx * dt
        proj.y = proj.y + proj.vy * dt
        
        -- Calculate arc height based on parabolic trajectory
        -- Height peaks at middle of flight (progress = 0.5)
        -- Formula: h = maxHeight * 4 * progress * (1 - progress)
        -- This creates a smooth arc that starts and ends at ground level
        local arcFactor = 4 * proj.flightProgress * (1 - proj.flightProgress)
        proj.height = proj.maxHeight * arcFactor
        
        -- Clamp height to non-negative
        if proj.height < 0 then
            proj.height = 0
        end
        
        -- Check if spear has landed (reached target or height is 0 after midpoint)
        if not proj.landed and (proj.flightProgress >= 1.0 or (proj.flightProgress > 0.5 and proj.height <= 0)) then
            proj.landed = true
            proj.inAir = false
            proj.height = 0
            -- Snap to exact target position when landing
            proj.x = proj.targetX
            proj.y = proj.targetY
            print("💦 Splash! Spear landed at target")
        end
        
        local hitSomething = false
        
        -- Only check collisions when spear has landed (height = 0)
        if proj.landed and proj.height <= 0 then
            -- Check rock collisions - spear gets stuck if it hits a rock directly
            for _, rock in ipairs(fishing.rocks) do
                local distToRock = math.sqrt((proj.x - rock.x)^2 + (proj.y - rock.y)^2)
                if distToRock < rock.size / 2 then
                    -- Direct hit on rock - spear gets stuck!
                    if not proj.isNet then
                        fishing.spearStuck = true
                        fishing.stuckSpear = {x = proj.x, y = proj.y}
                        fishing.retrievalClicks = 0
                        print("🪨 Spear stuck in rock! Right-click 3 times to retrieve it!")
                    end
                    proj.lifetime = 0
                    hitSomething = true
                    table.remove(fishing.projectiles, i)
                    break
                end
            end
            
            if not hitSomething then
                for j = #fishing.fish, 1, -1 do
                    local fish = fishing.fish[j]
                    -- Fish can't be caught if hiding behind rocks or at edges
                    if not fish.hiding then
                        local distance = math.sqrt((proj.x - fish.x)^2 + (proj.y - fish.y)^2)
                        if distance < proj.aoe + fish.type.size / 2 then
                            fishing:catchFish(fish, j)
                            proj.lifetime = 0
                            hitSomething = true
                            table.remove(fishing.projectiles, i)
                            break
                        end
                    end
                end
            end
            
            if not hitSomething and fishing.snake and not fishing.snake.dead then
                local distance = math.sqrt((proj.x - fishing.snake.x)^2 + (proj.y - fishing.snake.y)^2)
                if distance < 30 then
                    fishing:killSnake()
                    proj.lifetime = 0
                    hitSomething = true
                    table.remove(fishing.projectiles, i)
                end
            end
        end
        
        -- If projectile has landed and expires without hitting anything, it gets stuck in mud
        if not hitSomething and proj.landed and proj.height <= 0 and (proj.lifetime <= 0 or proj.x < 0 or proj.x > 800 or proj.y < 0 or proj.y > 600) then
            if not proj.isNet then -- Only spears get stuck, not nets
                fishing.spearStuck = true
                fishing.stuckSpear = {x = proj.x, y = proj.y}
                fishing.retrievalClicks = 0
                print("🎣 Spear stuck in mud! Right-click 3 times to retrieve it!")
            end
            table.remove(fishing.projectiles, i)
        end
    end
    
    -- Snake bites player's feet (not fish)
    if fishing.snake and not fishing.snake.dead and not fishing.snakeWarning then
        local distToPlayer = math.sqrt((fishing.snake.x - fishing.playerX)^2 + (fishing.snake.y - fishing.playerY)^2)
        if distToPlayer < 40 then
            fishing:snakeBitePlayer()
        end
    end
    
    -- Update snake
    fishing:updateSnake(dt)
end

function fishing:updateBoids(dt)
    -- Boids flocking algorithm parameters
    local separationRadius = 15
    local alignmentRadius = 30
    local cohesionRadius = 40
    local separationForce = 50
    local alignmentForce = 20
    local cohesionForce = 15
    local maxSpeed = 80
    
    -- Avoid spears
    local avoidRadius = 60
    local avoidForce = 100
    
    for i, boid in ipairs(fishing.boidFish) do
        local separationX, separationY = 0, 0
        local alignmentX, alignmentY = 0, 0
        local cohesionX, cohesionY = 0, 0
        local separationCount = 0
        local alignmentCount = 0
        local cohesionCount = 0
        
        -- Check neighbors
        for j, other in ipairs(fishing.boidFish) do
            if i ~= j then
                local dx = boid.x - other.x
                local dy = boid.y - other.y
                local distance = math.sqrt(dx * dx + dy * dy)
                
                -- Separation: steer away from nearby boids
                if distance < separationRadius and distance > 0 then
                    separationX = separationX + dx / distance
                    separationY = separationY + dy / distance
                    separationCount = separationCount + 1
                end
                
                -- Alignment: match velocity with nearby boids
                if distance < alignmentRadius then
                    alignmentX = alignmentX + other.vx
                    alignmentY = alignmentY + other.vy
                    alignmentCount = alignmentCount + 1
                end
                
                -- Cohesion: move toward center of nearby boids
                if distance < cohesionRadius then
                    cohesionX = cohesionX + other.x
                    cohesionY = cohesionY + other.y
                    cohesionCount = cohesionCount + 1
                end
            end
        end
        
        -- Apply separation
        if separationCount > 0 then
            boid.vx = boid.vx + (separationX / separationCount) * separationForce * dt
            boid.vy = boid.vy + (separationY / separationCount) * separationForce * dt
        end
        
        -- Apply alignment
        if alignmentCount > 0 then
            local avgVx = alignmentX / alignmentCount
            local avgVy = alignmentY / alignmentCount
            boid.vx = boid.vx + (avgVx - boid.vx) * alignmentForce * dt
            boid.vy = boid.vy + (avgVy - boid.vy) * alignmentForce * dt
        end
        
        -- Apply cohesion
        if cohesionCount > 0 then
            local centerX = cohesionX / cohesionCount
            local centerY = cohesionY / cohesionCount
            local toCenterX = centerX - boid.x
            local toCenterY = centerY - boid.y
            boid.vx = boid.vx + toCenterX * cohesionForce * dt
            boid.vy = boid.vy + toCenterY * cohesionForce * dt
        end
        
        -- Avoid spears and projectiles
        for _, proj in ipairs(fishing.projectiles) do
            if proj.height < 50 then -- Only avoid when spear is close to water
                local dx = boid.x - proj.x
                local dy = boid.y - proj.y
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance < avoidRadius and distance > 0 then
                    boid.vx = boid.vx + (dx / distance) * avoidForce * dt
                    boid.vy = boid.vy + (dy / distance) * avoidForce * dt
                end
            end
        end
        
        -- Limit speed
        local speed = math.sqrt(boid.vx * boid.vx + boid.vy * boid.vy)
        if speed > maxSpeed then
            boid.vx = (boid.vx / speed) * maxSpeed
            boid.vy = (boid.vy / speed) * maxSpeed
        end
        
        -- Update position
        boid.x = boid.x + boid.vx * dt
        boid.y = boid.y + boid.vy * dt
        
        -- Boundary wrapping (soft bounce)
        if boid.x < 50 then 
            boid.x = 50
            boid.vx = math.abs(boid.vx)
        elseif boid.x > 750 then 
            boid.x = 750
            boid.vx = -math.abs(boid.vx)
        end
        
        if boid.y < 50 then 
            boid.y = 50
            boid.vy = math.abs(boid.vy)
        elseif boid.y > 550 then 
            boid.y = 550
            boid.vy = -math.abs(boid.vy)
        end
    end
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
                    fishing.snake.movementTime = 0
                end
            end
            
            if not fishing.snakeWarning then
                -- GOD-TIER SNAKE: Aggressive sine wave predator
                local dx = fishing.playerX - fishing.snake.x
                local dy = fishing.playerY - fishing.snake.y
                local distance = math.sqrt(dx * dx + dy * dy)
                
                fishing.snake.movementTime = fishing.snake.movementTime + dt * 2 -- Double time speed
                
                if distance > 0 then
                    local dirX = dx / distance
                    local dirY = dy / distance
                    
                    -- AGGRESSIVE sine wave - high frequency, large amplitude
                    local waveAmplitude = 80 -- Large side-to-side motion
                    local waveFrequency = 8 -- FAST oscillation
                    local wave = math.sin(fishing.snake.movementTime * waveFrequency) * waveAmplitude
                    
                    -- Perpendicular direction for sine wave
                    local perpX = -dirY
                    local perpY = dirX
                    
                    -- Fast base speed + sine wave
                    local baseSpeed = 200 -- FAST!
                    fishing.snake.vx = dirX * baseSpeed + perpX * wave * 0.5
                    fishing.snake.vy = dirY * baseSpeed + perpY * wave * 0.5
                end
                
                fishing.snake.x = fishing.snake.x + fishing.snake.vx * dt
                fishing.snake.y = fishing.snake.y + fishing.snake.vy * dt
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
    
    fishing.snake = {x = x, y = y, vx = 0, vy = 0, dead = false, movementTime = 0}
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
    print("💀 SNAKE BIT YOUR FEET!")
    fishing.playerFeetBitten = true
    fishing.feetBiteTimer = 1.0
    fishing.active = false
    love.mouse.setVisible(false)
    local gamestate = require("states/gamestate")
    gamestate.switch("death", "snake")
end

function fishing:throwSpear(power)
    -- Can't throw if spear is stuck
    if fishing.spearStuck then
        print("🎣 Spear is stuck! Right-click to retrieve it!")
        return
    end
    
    -- Cooldown check to prevent multi-throw glitch
    if fishing.throwCooldown > 0 then
        return
    end
    
    -- Default to full power if not specified
    power = power or 1.0
    
    -- Set cooldown
    fishing.throwCooldown = fishing.throwCooldownTime
    
    -- Spear starts from player's hand height (elevated position on shore)
    local spearStartX = fishing.playerX
    local spearStartY = fishing.playerY - 40  -- 40 pixels above feet = hand/chest height
    
    -- Calculate distance to target
    local dx = fishing.mouseX - spearStartX
    local dy = fishing.mouseY - spearStartY
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Apply power to distance - more power = spear goes further/faster
    -- Scale the effective distance by power (20% to 100% of intended distance)
    local effectiveDistance = distance * power
    local actualTargetX = spearStartX + (dx * power)
    local actualTargetY = spearStartY + (dy * power)
    
    -- Calculate flight time based on power (more power = faster throw)
    -- Higher power = shorter flight time = faster spear
    local baseFlightTime = math.max(0.5, math.min(1.5, effectiveDistance / 400))
    -- At 20% power: flightTime = base * 2.0 (slow)
    -- At 100% power: flightTime = base * 0.4 (fast, 2.5x faster than low power)
    local speedMultiplier = 2.0 - (power * 1.6)  -- 2.0 at min power, 0.4 at max power
    local flightTime = baseFlightTime * speedMultiplier
    
    -- Calculate velocity needed to reach actual target in flightTime
    local adjustedDx = actualTargetX - spearStartX
    local adjustedDy = actualTargetY - spearStartY
    local vx = adjustedDx / flightTime
    local vy = adjustedDy / flightTime
    
    -- Arc height calculation: higher power = higher arc
    local arcHeight = (100 + (effectiveDistance * 0.2)) * power
    
    -- 3D spear throw: starts at player hand height, arcs through air to target point
    table.insert(fishing.projectiles, {
        x = spearStartX,
        y = spearStartY,
        startX = spearStartX,
        startY = spearStartY,
        targetX = actualTargetX,  -- Use power-adjusted target
        targetY = actualTargetY,  -- Use power-adjusted target
        vx = vx,
        vy = vy,
        lifetime = flightTime,
        maxLifetime = flightTime,
        flightProgress = 0, -- 0 to 1, tracks arc progress
        height = 150,  -- Current height above water
        maxHeight = arcHeight, -- Peak height of arc
        fallSpeed = (arcHeight * 2) / flightTime, -- Speed to reach peak and come down
        isNet = fishing.hasNet,
        aoe = fishing.hasNet and 50 or 10,
        inAir = true,
        landed = false
    })
    
    print("🎯 Spear launched! Power: " .. math.floor(power * 100) .. "%, Flight time: " .. string.format("%.2f", flightTime) .. "s, Arc height: " .. math.floor(arcHeight))
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
    
    -- Draw water surface (top-down view from above)
    love.graphics.setColor(0.15, 0.4, 0.6)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Draw BOID FISH (small visual fish with flocking behavior)
    for _, boid in ipairs(fishing.boidFish) do
        -- Only draw boids that are in visible area
        if boid.x >= -10 and boid.x <= 810 and boid.y >= -10 and boid.y <= 610 then
            -- Small fish shadow
            love.graphics.setColor(0.1, 0.2, 0.3, 0.4)
            love.graphics.circle("fill", boid.x, boid.y, boid.size)
            -- Bright center (fish body)
            love.graphics.setColor(0.7, 0.8, 0.9, 0.8)
            love.graphics.circle("fill", boid.x, boid.y, boid.size * 0.6)
        end
    end
    
    -- Draw FISH SHADOWS (darker underwater shadows)
    for _, fish in ipairs(fishing.fish) do
        -- Only draw fish that are in reasonable range of visible area
        local inView = fish.x >= -100 and fish.x <= 900 and fish.y >= -100 and fish.y <= 700
        
        -- Skip drawing fish that are hiding behind rocks or outside view
        if not fish.hiding and inView then
            -- Shadow gets bigger/blurrier the deeper the fish
            local shadowSize = fish.type.size / 2 + 3
            love.graphics.setColor(0.05, 0.1, 0.2, 0.5)
            love.graphics.circle("fill", fish.x, fish.y, shadowSize)
            -- Inner darker shadow
            love.graphics.setColor(0.0, 0.05, 0.1, 0.7)
            love.graphics.circle("fill", fish.x, fish.y, fish.type.size / 2 - 2)
            
            -- Draw indicator for entering fish (outside main view)
            if fish.entering and (fish.x < 50 or fish.x > 750 or fish.y < 50 or fish.y > 550) then
                -- Draw arrow pointing to entering fish
                local arrowX = math.max(60, math.min(740, fish.x))
                local arrowY = math.max(60, math.min(540, fish.y))
                love.graphics.setColor(0.3, 0.6, 0.8, 0.5)
                love.graphics.circle("fill", arrowX, arrowY, 8)
                love.graphics.setColor(0.5, 0.8, 1.0, 0.8)
                love.graphics.circle("line", arrowX, arrowY, 12)
            end
        end
    end
    
    -- Draw rocks AFTER fish shadows (rocks are above water level)
    for _, rock in ipairs(fishing.rocks) do
        -- Rock with 3D depth
        love.graphics.setColor(0.25, 0.25, 0.25)
        love.graphics.circle("fill", rock.x + 2, rock.y + 2, rock.size / 2) -- Shadow
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.circle("fill", rock.x, rock.y, rock.size / 2)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.circle("fill", rock.x - rock.size / 6, rock.y - rock.size / 6, rock.size / 8) -- Highlight
    end
    
    -- Draw snake shadow
    if fishing.snake and not fishing.snake.dead then
        if fishing.snakeWarning then
            local pulse = 0.5 + math.sin(love.timer.getTime() * 10) * 0.5
            love.graphics.setColor(1, 0, 0, pulse * 0.6)
        else
            love.graphics.setColor(0.6, 0, 0, 0.5)
        end
        love.graphics.circle("fill", fishing.snake.x, fishing.snake.y, 28)
        love.graphics.setColor(0.8, 0, 0, 0.8)
        love.graphics.circle("fill", fishing.snake.x, fishing.snake.y, 20)
        if fishing.snakeWarning then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("⚠️ SNAKE! " .. string.format("%.1f", fishing.snakeWarningTimer), fishing.snake.x - 30, fishing.snake.y - 40)
        end
    end
    
    -- Draw SPEAR PROJECTILES with 3D shadow effect and arc trajectory
    for _, proj in ipairs(fishing.projectiles) do
        -- Calculate shadow position based on where spear is projected from height
        -- Shadow stays at ground (target position) while spear moves through arc
        local shadowX = proj.targetX
        local shadowY = proj.targetY
        
        -- Draw shadow (grows larger as spear gets closer to landing)
        local shadowSize = 6 + (1 - proj.flightProgress) * 8
        local shadowAlpha = 0.2 + (1 - proj.flightProgress) * 0.3
        love.graphics.setColor(0, 0, 0, shadowAlpha)
        love.graphics.circle("fill", shadowX, shadowY, shadowSize)
        
        -- Draw trajectory line showing arc path (faint)
        if proj.height > 5 then
            love.graphics.setColor(1, 1, 1, 0.15)
            love.graphics.line(proj.startX, proj.startY, proj.targetX, proj.targetY)
        end
        
        -- Draw actual spear at current position
        if proj.height > 0 and not proj.landed then
            -- Spear in air - draw with perspective based on height
            -- Higher = smaller (farther from camera view)
            local heightFactor = proj.height / proj.maxHeight
            local spearSize = 4 + heightFactor * 8 -- Size grows as it's higher
            
            -- Draw spear with rotation angle toward movement direction
            local angle = math.atan2(proj.vy, proj.vx)
            
            -- Spear body
            love.graphics.setColor(0.7, 0.5, 0.3, 0.95)
            love.graphics.circle("fill", proj.x, proj.y, spearSize)
            
            -- Spear tip (brighter)
            love.graphics.setColor(0.95, 0.95, 0.95)
            love.graphics.circle("fill", proj.x, proj.y, spearSize * 0.4)
            
            -- Flight trail effect (motion blur)
            if proj.flightProgress > 0.1 then
                love.graphics.setColor(0.7, 0.5, 0.3, 0.3)
                local trailX = proj.x - proj.vx * 0.02
                local trailY = proj.y - proj.vy * 0.02
                love.graphics.circle("fill", trailX, trailY, spearSize * 0.6)
            end
        else
            -- Spear has landed in water
            if proj.isNet then
                love.graphics.setColor(0.6, 0.4, 0.2, 0.8)
                love.graphics.circle("line", proj.x, proj.y, 25)
            else
                love.graphics.setColor(0.6, 0.4, 0.2)
                love.graphics.circle("fill", proj.x, proj.y, 6)
                love.graphics.setColor(0.9, 0.9, 0.9)
                love.graphics.circle("fill", proj.x, proj.y, 2)
            end
            
            -- Splash effect when just landed
            if proj.landed and proj.flightProgress < 1.1 then
                love.graphics.setColor(1, 1, 1, 0.6 - (proj.flightProgress - 0.9) * 3)
                local splashSize = (proj.flightProgress - 0.9) * 150
                love.graphics.circle("line", proj.x, proj.y, splashSize)
                love.graphics.circle("line", proj.x, proj.y, splashSize * 0.7)
            end
        end
    end
    
    -- Draw stuck spear (if any)
    if fishing.spearStuck and fishing.stuckSpear then
        -- Pulsing effect when pulling
        local pulseScale = 1.0
        if fishing.stuckSpear.pullTime then
            pulseScale = 1.0 + (fishing.stuckSpear.pullTime * 2) -- Scale up when pulling
        end
        
        love.graphics.setColor(0.6, 0.4, 0.2)
        love.graphics.circle("fill", fishing.stuckSpear.x, fishing.stuckSpear.y, 8 * pulseScale)
        
        -- Yellow warning circle
        local alpha = fishing.stuckSpear.pullTime and 1.0 or 0.8
        love.graphics.setColor(1, 1, 0, alpha)
        love.graphics.circle("line", fishing.stuckSpear.x, fishing.stuckSpear.y, 15 * pulseScale)
        love.graphics.circle("line", fishing.stuckSpear.x, fishing.stuckSpear.y, 20 * pulseScale)
        
        -- Warning text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("❗", fishing.stuckSpear.x - 5, fishing.stuckSpear.y - 30)
    end
    
    -- Draw player's feet (top-down view in water)
    if fishing.playerFeetBitten then
        -- Red flash when bitten by snake
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(0.8, 0.7, 0.6)
    end
    
    -- Left foot
    love.graphics.ellipse("fill", fishing.playerX - 10, fishing.playerY, 7, 10)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("line", fishing.playerX - 10, fishing.playerY, 7, 10)
    
    -- Right foot
    if fishing.playerFeetBitten then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(0.8, 0.7, 0.6)
    end
    love.graphics.ellipse("fill", fishing.playerX + 10, fishing.playerY, 7, 10)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("line", fishing.playerX + 10, fishing.playerY, 7, 10)
    
    -- Draw ripples around feet
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.circle("line", fishing.playerX - 10, fishing.playerY, 12)
    love.graphics.circle("line", fishing.playerX + 10, fishing.playerY, 12)
    
    -- Show snake bite indicator
    if fishing.playerFeetBitten then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("OW! 🐍", fishing.playerX - 15, fishing.playerY - 20)
    end
    
    -- Draw player at BOTTOM of screen (standing on shore looking down at pond)
    -- Player body silhouette
    love.graphics.setColor(0.1, 0.1, 0.1, 0.5)
    love.graphics.rectangle("fill", fishing.playerX - 25, fishing.playerY - 60, 50, 60)
    love.graphics.setColor(0.2, 0.15, 0.1, 0.6)
    love.graphics.circle("fill", fishing.playerX, fishing.playerY - 60, 15) -- Head
    
    -- Arms holding fishing rod/spear
    love.graphics.setColor(0.4, 0.3, 0.2)
    love.graphics.line(fishing.playerX - 15, fishing.playerY - 40, fishing.playerX - 5, fishing.playerY - 20)
    love.graphics.line(fishing.playerX + 15, fishing.playerY - 40, fishing.playerX + 5, fishing.playerY - 20)
    
    -- CUSTOM CURSOR: Spear shadow showing where it will land
    if not fishing.spearStuck then
        -- Draw spear shadow at cursor position (where spear will hit water)
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.circle("fill", fishing.mouseX, fishing.mouseY, 12)
        
        -- Spear tip shadow
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.circle("fill", fishing.mouseX, fishing.mouseY, 6)
        
        -- Aiming line from player's HAND HEIGHT (not feet) to cursor
        local handX = fishing.playerX
        local handY = fishing.playerY - 40  -- Hand/chest height where spear is held
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.line(handX, handY, fishing.mouseX, fishing.mouseY)
        
        -- Draw small circle at hand position to show spear origin
        love.graphics.setColor(1, 1, 0, 0.5)
        love.graphics.circle("fill", handX, handY, 4)
        
        -- Crosshair at cursor (target position in water)
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.circle("line", fishing.mouseX, fishing.mouseY, 15)
        love.graphics.line(fishing.mouseX - 18, fishing.mouseY, fishing.mouseX - 12, fishing.mouseY)
        love.graphics.line(fishing.mouseX + 12, fishing.mouseY, fishing.mouseX + 18, fishing.mouseY)
        love.graphics.line(fishing.mouseX, fishing.mouseY - 18, fishing.mouseX, fishing.mouseY - 12)
        love.graphics.line(fishing.mouseX, fishing.mouseY + 12, fishing.mouseX, fishing.mouseY + 18)
    else
        -- Show retrieval cursor
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("RIGHT CLICK!", fishing.mouseX - 35, fishing.mouseY - 25)
    end
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 40)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("🐟 Fish: " .. fishing.fishCaught, 20, 10)
    love.graphics.print("⏱ Time: " .. string.format("%.1f", fishing.timeInSession), 200, 10)
    love.graphics.print("🎣 " .. (fishing.hasNet and "Net" or "Spear"), 400, 10)
    
    -- Draw Power Bar (Stardew Valley style - vertical green bar with brown outline)
    local bar = fishing.powerBar
    if not fishing.spearStuck then
        -- Brown outline (darker border)
        love.graphics.setColor(0.4, 0.25, 0.1) -- Dark brown
        love.graphics.rectangle("fill", bar.x - 2, bar.y - 2, bar.width + 4, bar.height + 4)
        
        -- Black background (empty bar)
        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.rectangle("fill", bar.x, bar.y, bar.width, bar.height)
        
        -- Green fill (power level) - fills from bottom to top
        if bar.power > 0 then
            local fillHeight = bar.height * bar.power
            local fillY = bar.y + bar.height - fillHeight
            
            -- Gradient effect: darker at bottom, brighter at top
            love.graphics.setColor(0.2, 0.8, 0.2) -- Bright green
            love.graphics.rectangle("fill", bar.x, fillY, bar.width, fillHeight)
        end
        
        -- Power bar label
        if bar.charging then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("POWER", bar.x - 10, bar.y - 25)
            love.graphics.print(math.floor(bar.power * 100) .. "%", bar.x - 5, bar.y + bar.height + 5)
        else
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.print("Hold to\n charge", bar.x - 15, bar.y + bar.height / 2 - 10)
        end
    end
    
    -- Bottom UI bar
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 560, 800, 40)
    
    -- Show spear retrieval progress bar if stuck
    if fishing.spearStuck then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("⚠️ SPEAR STUCK! Right-click to retrieve: " .. fishing.retrievalClicks .. "/" .. fishing.retrievalNeeded, 20, 567)
        
        -- Draw progress bar with better visibility
        local barWidth = 250
        local barHeight = 25
        local barX = 450
        local barY = 565
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
        love.graphics.setColor(0, 0.8, 0)
        local progress = fishing.retrievalClicks / fishing.retrievalNeeded
        love.graphics.rectangle("fill", barX, barY, barWidth * progress, barHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
        -- Draw progress text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(math.floor(progress * 100) .. "%", barX + barWidth / 2 - 15, barY + 5)
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("LEFT CLICK: Throw Spear | RIGHT CLICK: Pull Spear | ESC: Exit", 20, 567)
    end
end

function fishing:mousepressed(x, y, button)
    if button == 1 and fishing.active and not fishing.spearStuck then
        -- Start charging the power bar
        fishing.powerBar.charging = true
        fishing.powerBar.power = fishing.powerBar.minPower -- Start at minimum power
    elseif button == 2 and fishing.active and fishing.spearStuck then
        -- Right-click to retrieve stuck spear
        fishing.retrievalClicks = fishing.retrievalClicks + 1
        print("🎣 Pulling spear... " .. fishing.retrievalClicks .. "/" .. fishing.retrievalNeeded .. " *PULL*")
        
        -- Visual feedback: make stuck spear pulse when clicking
        if fishing.stuckSpear then
            fishing.stuckSpear.pullTime = 0.2 -- Flash effect duration
        end
        
        if fishing.retrievalClicks >= fishing.retrievalNeeded then
            fishing.spearStuck = false
            fishing.stuckSpear = nil
            fishing.retrievalClicks = 0
            print("✅ Spear retrieved! You can throw again!")
        end
    end
end

function fishing:mousereleased(x, y, button)
    if button == 1 and fishing.active and fishing.powerBar.charging then
        -- Release the spear with current power level
        fishing.powerBar.charging = false
        fishing:throwSpear(fishing.powerBar.power)
        fishing.powerBar.power = 0 -- Reset power after throw
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
