-- Hunting State (DOOM-style First-Person View)
-- Duck Hunt mechanics with stealth animal spotting

local hunting = {}

-- Hunting session state
hunting.active = false
hunting.timeRemaining = 180 -- 3 minutes
hunting.animals = {}
hunting.score = 0
hunting.kills = 0
hunting.shots = 0

-- Player weapon state
hunting.currentWeapon = "bow" -- "bow", "rifle", "shotgun"
hunting.ammo = {
    bow = 10,
    rifle = 0,
    shotgun = 0
}
hunting.reloading = false
hunting.reloadTimer = 0

-- Weapon stats
hunting.weapons = {
    bow = {
        name = "Bow",
        damage = 100,
        reloadTime = 2.0,
        range = 300,
        spread = 5, -- pixels
        sound = "bow_shot",
        projectileSpeed = 400, -- pixels per second
        silent = true -- doesn't scare animals
    },
    rifle = {
        name = "Rifle", 
        damage = 100,
        reloadTime = 0.5,
        range = 600,
        spread = 2,
        sound = "rifle_shot",
        projectileSpeed = 999999, -- instant hitscan
        silent = false -- scares nearby animals
    },
    shotgun = {
        name = "Shotgun",
        damage = 100,
        reloadTime = 1.5,
        range = 200,
        spread = 30,
        sound = "shotgun_blast",
        projectileSpeed = 999999,
        silent = false
    }
}

-- Crosshair and gun position
hunting.crosshair = {
    x = 0,
    y = 0,
    size = 20
}

-- Gun/weapon position (bottom-center, where player is)
hunting.gunX = 480
hunting.gunY = 480

-- Animal definitions
hunting.animalTypes = {
    rabbit = {
        name = "Rabbit",
        spawnChance = 0.5, -- 50% of spawns
        health = 100,
        speed = 150, -- pixels per second
        size = 40,
        meatValue = 15,
        meatCount = 1,
        headshotBonus = 2, -- 2x meat on headshot
        behavior = "dart", -- quick movements
        hideTime = {min = 2, max = 4}, -- seconds hidden
        showTime = {min = 1, max = 3}, -- seconds visible
        audioRadius = 100 -- pixels, how far rustling is heard
    },
    deer = {
        name = "Deer",
        spawnChance = 0.3,
        health = 100,
        speed = 80,
        size = 80,
        meatValue = 30,
        meatCount = 2,
        headshotBonus = 2,
        behavior = "graze",
        hideTime = {min = 1, max = 2},
        showTime = {min = 4, max = 8},
        audioRadius = 120
    },
    boar = {
        name = "Boar",
        spawnChance = 0.15,
        health = 150,
        speed = 200,
        size = 60,
        meatValue = 50,
        meatCount = 3,
        headshotBonus = 1.5,
        behavior = "charge",
        hideTime = {min = 3, max = 5},
        showTime = {min = 2, max = 4},
        audioRadius = 150
    },
    tiger = {
        name = "Tiger",
        spawnChance = 0.05, -- rare!
        health = 200,
        speed = 120,
        size = 100,
        meatValue = 100,
        meatCount = 5,
        headshotBonus = 2,
        behavior = "stalk",
        hideTime = {min = 5, max = 10},
        showTime = {min = 3, max = 6},
        audioRadius = 200
    }
}

-- Projectiles (for bow arrows)
hunting.projectiles = {}

function hunting:enter(fromState, entryPoint)
    print("🎯 Entering HUNTING MODE")
    -- DON'T set active=true yet! Wait until all validation passes
    hunting.timeRemaining = 180
    hunting.score = 0
    hunting.kills = 0
    hunting.shots = 0
    hunting.animals = {}
    hunting.projectiles = {}
    hunting.reloading = false
    hunting.reloadTimer = 0
    
    -- Load ammo from player's inventory (limited resources!)
    local playerEntity = require("entities/player")
    
    -- Get ammo counts from inventory
    local arrowCount = playerEntity.getItemCount("arrows") or 0
    local bulletCount = playerEntity.getItemCount("bullets") or 0
    local shellCount = playerEntity.getItemCount("shells") or 0
    
    -- CONSUME ammo from inventory (remove it)
    if arrowCount > 0 then
        playerEntity.removeItem("arrows", arrowCount)
    end
    if bulletCount > 0 then
        playerEntity.removeItem("bullets", bulletCount)
    end
    if shellCount > 0 then
        playerEntity.removeItem("shells", shellCount)
    end
    
    -- Load into hunting weapons
    hunting.ammo.bow = arrowCount
    hunting.ammo.rifle = bulletCount
    hunting.ammo.shotgun = shellCount
    
    -- Check which weapons player owns
    local hasBow = playerEntity.hasItem("bow_weapon")
    local hasRifle = playerEntity.hasItem("rifle_weapon")
    local hasShotgun = playerEntity.hasItem("shotgun_weapon")
    
    -- Set starting weapon (prioritize owned weapons with ammo)
    if hasBow and hunting.ammo.bow > 0 then
        hunting.currentWeapon = "bow"
    elseif hasRifle and hunting.ammo.rifle > 0 then
        hunting.currentWeapon = "rifle"
    elseif hasShotgun and hunting.ammo.shotgun > 0 then
        hunting.currentWeapon = "shotgun"
    elseif hasBow then
        hunting.currentWeapon = "bow" -- Default to bow even if no ammo
    else
        print("❌ You don't own any weapons! Buy a weapon from the shop first.")
        local gamestate = require("states/gamestate")
        gamestate.switch("gameplay")
        return
    end
    
    -- Check if player has any ammo at all
    if hunting.ammo.bow == 0 and hunting.ammo.rifle == 0 and hunting.ammo.shotgun == 0 then
        print("❌ No ammo! Buy arrows/bullets/shells from the shop.")
        local gamestate = require("states/gamestate")
        gamestate.switch("gameplay")
        return
    end
    
    -- ALL VALIDATION PASSED - Now activate hunting mode!
    hunting.active = true
    
    -- Show mouse cursor for aiming
    love.mouse.setVisible(true)
    
    -- Spawn initial animal (just one)
    hunting:spawnAnimal()
    
    print("🏹 Armed with " .. hunting.weapons[hunting.currentWeapon].name)
    print("📦 Ammo: " .. hunting.ammo[hunting.currentWeapon])
end

function hunting:update(dt)
    if not hunting.active then return end
    
    -- Update timer
    hunting.timeRemaining = hunting.timeRemaining - dt
    if hunting.timeRemaining <= 0 then
        hunting:exitHunting()
        return
    end
    
    -- Update crosshair position (follow mouse)
    hunting.crosshair.x = love.mouse.getX()
    hunting.crosshair.y = love.mouse.getY()
    
    -- Update reload timer
    if hunting.reloading then
        hunting.reloadTimer = hunting.reloadTimer - dt
        if hunting.reloadTimer <= 0 then
            hunting.reloading = false
        end
    end
    
    -- Update animals
    for i = #hunting.animals, 1, -1 do
        local animal = hunting.animals[i]
        hunting:updateAnimal(animal, dt)
        
        -- Remove dead animals
        if animal.dead then
            table.remove(hunting.animals, i)
        end
    end
    
    -- Update projectiles (arrows)
    for i = #hunting.projectiles, 1, -1 do
        local proj = hunting.projectiles[i]
        proj.x = proj.x + proj.vx * dt
        proj.y = proj.y + proj.vy * dt
        proj.lifetime = proj.lifetime - dt
        
        -- Check collision with animals
        for _, animal in ipairs(hunting.animals) do
            if animal.visible and not animal.dead then
                if hunting:checkProjectileHit(proj, animal) then
                    hunting:hitAnimal(animal, proj.headshot)
                    proj.lifetime = 0 -- Remove projectile
                end
            end
        end
        
        -- Remove expired projectiles
        if proj.lifetime <= 0 or proj.x < 0 or proj.x > 960 or proj.y < 0 or proj.y > 540 then
            table.remove(hunting.projectiles, i)
        end
    end
    
    -- Spawn new animals periodically (reduced rate)
    if #hunting.animals < 2 and math.random() < 0.005 then -- 0.5% chance per frame (much slower)
        hunting:spawnAnimal()
    end
end

function hunting:updateAnimal(animal, dt)
    local animalType = hunting.animalTypes[animal.type]
    
    -- Update state timer
    animal.stateTimer = animal.stateTimer - dt
    
    if animal.state == "hidden" then
        -- Animal is hiding
        if animal.stateTimer <= 0 then
            animal.state = "visible"
            animal.stateTimer = math.random(animalType.showTime.min, animalType.showTime.max)
            animal.visible = true
        end
        
    elseif animal.state == "visible" then
        -- Animal is showing
        if animal.stateTimer <= 0 then
            animal.state = "hidden"
            animal.stateTimer = math.random(animalType.hideTime.min, animalType.hideTime.max)
            animal.visible = false
        end
        
        -- Move animal based on behavior
        if animalType.behavior == "dart" then
            -- Quick random movements
            animal.x = animal.x + math.random(-50, 50) * dt
        elseif animalType.behavior == "graze" then
            -- Slow left-right movement
            animal.x = animal.x + math.sin(love.timer.getTime() * 0.5) * 20 * dt
        elseif animalType.behavior == "charge" then
            -- Fast horizontal movement
            animal.x = animal.x + animal.direction * animalType.speed * dt
            if animal.x < 100 or animal.x > 860 then
                animal.direction = -animal.direction
            end
        elseif animalType.behavior == "stalk" then
            -- Slow approach
            animal.x = animal.x + animal.direction * animalType.speed * 0.3 * dt
        end
        
        -- Keep in bounds
        animal.x = math.max(50, math.min(910, animal.x))
    end
end

function hunting:spawnAnimal()
    -- Choose random animal type based on spawn chances
    local roll = math.random()
    local cumulative = 0
    local chosenType = "rabbit"
    
    for animalType, data in pairs(hunting.animalTypes) do
        cumulative = cumulative + data.spawnChance
        if roll <= cumulative then
            chosenType = animalType
            break
        end
    end
    
    local animalData = hunting.animalTypes[chosenType]
    
    -- TIGER FEAR MECHANIC: If tiger spawns, player is too scared to hunt!
    if chosenType == "tiger" then
        print("🐅 TIGER APPEARS! You flee in fear!")
        print("⚠️  You were too scared to hunt and ran away!")
        hunting:exitHunting()
        return
    end
    
    -- Spawn from sides or center
    local spawnSide = math.random(1, 3)
    local spawnX
    if spawnSide == 1 then
        spawnX = math.random(50, 200) -- Left side
    elseif spawnSide == 2 then
        spawnX = math.random(400, 560) -- Center
    else
        spawnX = math.random(760, 910) -- Right side
    end
    
    local animal = {
        type = chosenType,
        x = spawnX,
        y = math.random(280, 380), -- Ground level
        health = animalData.health,
        state = "hidden",
        stateTimer = math.random(animalData.hideTime.min, animalData.hideTime.max),
        visible = false,
        dead = false,
        direction = math.random() > 0.5 and 1 or -1
    }
    
    table.insert(hunting.animals, animal)
    print("🦌 " .. animalData.name .. " appeared nearby")
end

function hunting:shoot()
    if hunting.reloading then
        print("🔄 Reloading...")
        return
    end
    
    local weapon = hunting.weapons[hunting.currentWeapon]
    
    -- Check ammo
    if hunting.ammo[hunting.currentWeapon] <= 0 then
        print("❌ Out of ammo!")
        return
    end
    
    -- Consume ammo
    hunting.ammo[hunting.currentWeapon] = hunting.ammo[hunting.currentWeapon] - 1
    hunting.shots = hunting.shots + 1
    
    -- Start reload
    hunting.reloading = true
    hunting.reloadTimer = weapon.reloadTime
    
    print("💥 " .. weapon.name .. " fired! (" .. hunting.ammo[hunting.currentWeapon] .. " ammo left)")
    
    -- Fire from gun position (not from random bush)
    
    -- Hitscan weapons (rifle, shotgun) - instant check
    if weapon.projectileSpeed > 10000 then
        hunting:checkHitscanShot()
    else
        -- Projectile weapon (bow) - create arrow
        hunting:createProjectile()
    end
end

function hunting:createProjectile()
    local weapon = hunting.weapons[hunting.currentWeapon]
    local spread = math.random(-weapon.spread, weapon.spread)
    
    -- Fire from gun position towards crosshair
    local angle = math.atan2(hunting.crosshair.y - hunting.gunY, hunting.crosshair.x - hunting.gunX) + math.rad(spread)
    
    local proj = {
        x = hunting.gunX,
        y = hunting.gunY,
        vx = math.cos(angle) * weapon.projectileSpeed,
        vy = math.sin(angle) * weapon.projectileSpeed,
        lifetime = 2.0, -- seconds
        headshot = math.abs(spread) < 2 -- Perfect aim = headshot potential
    }
    
    table.insert(hunting.projectiles, proj)
end

function hunting:checkHitscanShot()
    local weapon = hunting.weapons[hunting.currentWeapon]
    local hitSomething = false
    
    -- Check if crosshair is over any visible animal
    for _, animal in ipairs(hunting.animals) do
        if animal.visible and not animal.dead then
            local animalData = hunting.animalTypes[animal.type]
            local dx = hunting.crosshair.x - animal.x
            local dy = hunting.crosshair.y - animal.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            -- Check if within hitbox (including spread)
            if distance < (animalData.size / 2 + weapon.spread) then
                local headshot = dy < -animalData.size * 0.3 -- Upper 30% is head
                hunting:hitAnimal(animal, headshot)
                hitSomething = true
                break
            end
        end
    end
    
    if not hitSomething then
        print("💨 Miss!")
    end
end

function hunting:checkProjectileHit(proj, animal)
    local animalData = hunting.animalTypes[animal.type]
    local dx = proj.x - animal.x
    local dy = proj.y - animal.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    return distance < animalData.size / 2
end

function hunting:hitAnimal(animal, headshot)
    local animalData = hunting.animalTypes[animal.type]
    local playerEntity = require("entities/player")
    
    animal.dead = true
    hunting.kills = hunting.kills + 1
    
    -- Calculate loot
    local meatCount = animalData.meatCount
    if headshot then
        meatCount = math.floor(meatCount * animalData.headshotBonus)
        print("🎯 HEADSHOT! " .. animalData.name .. " killed! (+" .. meatCount .. " meat)")
    else
        print("✓ " .. animalData.name .. " killed! (+" .. meatCount .. " meat)")
    end
    
    -- Add meat to inventory
    playerEntity.addItem(animal.type .. "_meat", meatCount)
    
    -- Update score
    local points = animalData.meatValue * meatCount
    hunting.score = hunting.score + points
end

function hunting:exitHunting()
    hunting.active = false
    
    -- Return unused ammo to player's inventory
    local playerEntity = require("entities/player")
    
    -- Add back only what wasn't used
    if hunting.ammo.bow > 0 then
        playerEntity.addItem("arrows", hunting.ammo.bow)
    end
    if hunting.ammo.rifle > 0 then
        playerEntity.addItem("bullets", hunting.ammo.rifle)
    end
    if hunting.ammo.shotgun > 0 then
        playerEntity.addItem("shells", hunting.ammo.shotgun)
    end
    
    -- Calculate accuracy
    local accuracy = hunting.shots > 0 and math.floor((hunting.kills / hunting.shots) * 100) or 0
    
    print("🏁 HUNTING SESSION ENDED")
    print("🎯 Kills: " .. hunting.kills)
    print("💯 Accuracy: " .. accuracy .. "%")
    print("💰 Score: $" .. hunting.score)
    print("📦 Ammo returned: " .. hunting.ammo.bow .. " arrows, " .. hunting.ammo.rifle .. " bullets, " .. hunting.ammo.shotgun .. " shells")
    
    -- Return to gameplay
    local gamestate = require("states/gamestate")
    gamestate.switch("gameplay")
end

function hunting:draw()
    if not hunting.active then return end
    
    local lg = love.graphics
    
    -- Dark green background (simple solid color)
    lg.setColor(0.1, 0.3, 0.15)
    lg.rectangle("fill", 0, 0, 960, 540)
    
    -- Draw 4-5 bushes scattered around (placeholder rectangles)
    lg.setColor(0.05, 0.2, 0.1)
    
    -- Bush 1 (left)
    lg.rectangle("fill", 80, 200, 100, 80)
    
    -- Bush 2 (left-center)
    lg.rectangle("fill", 220, 250, 120, 90)
    
    -- Bush 3 (center)
    lg.rectangle("fill", 420, 180, 110, 85)
    
    -- Bush 4 (right-center)
    lg.rectangle("fill", 620, 240, 115, 95)
    
    -- Bush 5 (right)
    lg.rectangle("fill", 800, 210, 105, 88)
    
    -- Store bush positions for animal hiding
    local bushes = {
        {x = 80, y = 200, w = 100, h = 80},
        {x = 220, y = 250, w = 120, h = 90},
        {x = 420, y = 180, w = 110, h = 85},
        {x = 620, y = 240, w = 115, h = 95},
        {x = 800, y = 210, w = 105, h = 88}
    }
    
    -- Draw hidden animals BEHIND bushes
    for _, animal in ipairs(hunting.animals) do
        if not animal.visible and not animal.dead and animal.peekingOut then
            -- Find nearest bush
            local nearestBush = bushes[1]
            local minDist = math.abs(animal.x - nearestBush.x)
            for _, bush in ipairs(bushes) do
                local dist = math.abs(animal.x - bush.x)
                if dist < minDist then
                    minDist = dist
                    nearestBush = bush
                end
            end
            
            -- Draw animal peeking from behind bush (slightly visible)
            local animalData = hunting.animalTypes[animal.type]
            local size = animalData.size * 0.7 -- Smaller when peeking
            
            -- Position animal behind bush (slightly offset)
            local peekX = nearestBush.x + nearestBush.w * 0.3
            local peekY = nearestBush.y + nearestBush.h * 0.5
            
            -- Color by type (darker/translucent)
            if animal.type == "rabbit" then
                lg.setColor(0.6, 0.5, 0.4, 0.5)
            elseif animal.type == "deer" then
                lg.setColor(0.5, 0.4, 0.3, 0.5)
            elseif animal.type == "boar" then
                lg.setColor(0.3, 0.2, 0.2, 0.5)
            elseif animal.type == "tiger" then
                lg.setColor(0.8, 0.5, 0.2, 0.5)
            end
            
            -- Draw small peek shape
            lg.rectangle("fill", peekX - size/4, peekY - size/4, size/2, size/2)
            
            -- Eyes peeking
            if animal.type == "tiger" then
                lg.setColor(1, 1, 0, 0.7)
                lg.circle("fill", peekX - size/8, peekY, 2)
                lg.circle("fill", peekX + size/8, peekY, 2)
            end
        end
    end
    
    -- Draw animals (simple rectangles) when fully visible
    for _, animal in ipairs(hunting.animals) do
        if animal.visible and not animal.dead then
            local animalData = hunting.animalTypes[animal.type]
            
            -- Color by type
            if animal.type == "rabbit" then
                lg.setColor(0.6, 0.5, 0.4)
            elseif animal.type == "deer" then
                lg.setColor(0.5, 0.4, 0.3)
            elseif animal.type == "boar" then
                lg.setColor(0.3, 0.2, 0.2)
            elseif animal.type == "tiger" then
                lg.setColor(0.8, 0.5, 0.2)
            end
            
            -- Draw as simple rectangle
            local size = animalData.size
            lg.rectangle("fill", animal.x - size/2, animal.y - size/2, size, size * 0.6)
            
            -- Add simple features
            if animal.type == "tiger" then
                -- Glowing eyes
                lg.setColor(1, 1, 0)
                lg.circle("fill", animal.x - size/4, animal.y - size/4, 3)
                lg.circle("fill", animal.x + size/4, animal.y - size/4, 3)
            elseif animal.type == "rabbit" then
                -- Ears
                lg.setColor(0.5, 0.4, 0.3)
                lg.rectangle("fill", animal.x - size/4, animal.y - size/2, 5, 10)
                lg.rectangle("fill", animal.x + size/4 - 5, animal.y - size/2, 5, 10)
            elseif animal.type == "deer" then
                -- Simple antlers
                lg.setColor(0.4, 0.3, 0.2)
                lg.line(animal.x - size/3, animal.y - size/2, animal.x - size/2, animal.y - size)
                lg.line(animal.x + size/3, animal.y - size/2, animal.x + size/2, animal.y - size)
            end
        end
    end
    
    -- Draw projectiles (arrows) with proper rotation
    for _, proj in ipairs(hunting.projectiles) do
        local angle = math.atan2(proj.vy, proj.vx)
        lg.push()
        lg.translate(proj.x, proj.y)
        lg.rotate(angle)
        
        -- Arrow shaft
        lg.setColor(0.6, 0.4, 0.2)
        lg.rectangle("fill", -15, -1, 20, 2)
        
        -- Arrow head
        lg.setColor(0.8, 0.8, 0.8)
        lg.polygon("fill", 5, 0, 0, -3, 0, 3)
        
        lg.pop()
    end
    
    -- Draw player at bottom-center (simple representation)
    lg.setColor(0.3, 0.3, 0.4)
    lg.rectangle("fill", 460, 480, 40, 60) -- Body
    lg.setColor(0.4, 0.35, 0.3)
    lg.circle("fill", 480, 475, 15) -- Head
    
    -- Draw weapon pointing at crosshair (3D effect)
    local weaponAngle = math.atan2(hunting.crosshair.y - hunting.gunY, hunting.crosshair.x - hunting.gunX)
    
    lg.push()
    lg.translate(hunting.gunX, hunting.gunY)
    lg.rotate(weaponAngle)
    
    if hunting.currentWeapon == "bow" then
        -- Draw bow
        lg.setColor(0.5, 0.3, 0.2)
        lg.rectangle("fill", 0, -3, 50, 6) -- Bow body
        lg.setColor(0.3, 0.2, 0.1)
        lg.rectangle("fill", 45, -2, 5, 4) -- Bow tip
        
        -- Draw arrow if not reloading
        if not hunting.reloading then
            lg.setColor(0.6, 0.4, 0.2)
            lg.rectangle("fill", 10, -1, 35, 2) -- Arrow shaft
            lg.setColor(0.8, 0.8, 0.8)
            lg.polygon("fill", 45, 0, 40, -2, 40, 2) -- Arrow head
        end
    elseif hunting.currentWeapon == "rifle" then
        -- Draw rifle
        lg.setColor(0.2, 0.2, 0.2)
        lg.rectangle("fill", 0, -4, 60, 8) -- Rifle body
        lg.setColor(0.3, 0.3, 0.3)
        lg.rectangle("fill", 50, -2, 15, 4) -- Barrel
    elseif hunting.currentWeapon == "shotgun" then
        -- Draw shotgun
        lg.setColor(0.25, 0.2, 0.15)
        lg.rectangle("fill", 0, -5, 55, 10) -- Shotgun body
        lg.setColor(0.3, 0.3, 0.3)
        lg.rectangle("fill", 45, -3, 20, 6) -- Barrel (wider)
    end
    
    lg.pop()
    
    -- Draw UI overlay
    hunting:drawUI()
    
    -- Draw crosshair (always on top)
    hunting:drawCrosshair()
end

function hunting:drawCrosshair()
    local lg = love.graphics
    local x, y = hunting.crosshair.x, hunting.crosshair.y
    local size = hunting.crosshair.size
    
    if hunting.reloading then
        lg.setColor(1, 0, 0, 0.5)
    else
        lg.setColor(1, 1, 1, 0.8)
    end
    
    lg.setLineWidth(2)
    -- Crosshair lines
    lg.line(x - size, y, x - size/3, y)
    lg.line(x + size/3, y, x + size, y)
    lg.line(x, y - size, x, y - size/3)
    lg.line(x, y + size/3, x, y + size)
    
    -- Center dot
    lg.circle("fill", x, y, 2)
    lg.setLineWidth(1)
end

function hunting:drawUI()
    local lg = love.graphics
    
    -- Semi-transparent UI background
    lg.setColor(0, 0, 0, 0.7)
    lg.rectangle("fill", 10, 10, 300, 120)
    
    -- Timer
    lg.setColor(1, 1, 1)
    local minutes = math.floor(hunting.timeRemaining / 60)
    local seconds = math.floor(hunting.timeRemaining % 60)
    lg.print(string.format("⏱ Time: %d:%02d", minutes, seconds), 20, 20)
    
    -- Weapon and ammo
    local weapon = hunting.weapons[hunting.currentWeapon]
    lg.print("🏹 " .. weapon.name, 20, 40)
    lg.print("📦 Ammo: " .. hunting.ammo[hunting.currentWeapon], 20, 60)
    
    if hunting.reloading then
        lg.setColor(1, 0.5, 0)
        lg.print("🔄 Reloading...", 20, 80)
    end
    
    -- Score
    lg.setColor(1, 1, 1)
    lg.print("🎯 Kills: " .. hunting.kills, 20, 100)
    
    -- Instructions
    lg.setColor(1, 1, 1, 0.5)
    lg.print("[LEFT CLICK] Shoot  [1/2/3] Switch Weapon  [ENTER] Exit", 20, 515)
end

function hunting:keypressed(key)
    if key == "return" or key == "escape" then
        hunting:exitHunting()
    elseif key == "1" then
        local playerEntity = require("entities/player")
        if playerEntity.hasItem("bow_weapon") then
            hunting.currentWeapon = "bow"
            print("🏹 Switched to Bow (Ammo: " .. hunting.ammo.bow .. ")")
        else
            print("❌ You don't own a bow!")
        end
    elseif key == "2" then
        local playerEntity = require("entities/player")
        if playerEntity.hasItem("rifle_weapon") then
            if hunting.ammo.rifle > 0 then
                hunting.currentWeapon = "rifle"
                print("🔫 Switched to Rifle (Ammo: " .. hunting.ammo.rifle .. ")")
            else
                print("❌ No rifle ammo! Buy bullets from shop.")
            end
        else
            print("❌ You don't own a rifle! Buy one from shop ($200)")
        end
    elseif key == "3" then
        local playerEntity = require("entities/player")
        if playerEntity.hasItem("shotgun_weapon") then
            if hunting.ammo.shotgun > 0 then
                hunting.currentWeapon = "shotgun"
                print("💣 Switched to Shotgun (Ammo: " .. hunting.ammo.shotgun .. ")")
            else
                print("❌ No shotgun ammo! Buy shells from shop.")
            end
        else
            print("❌ You don't own a shotgun! Buy one from shop ($350)")
        end
    end
end

function hunting:mousepressed(x, y, button)
    if button == 1 then -- Left click
        hunting:shoot()
    end
end

return hunting
