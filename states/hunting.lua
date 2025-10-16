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
hunting.currentArea = nil -- Track which hunting area we're in

-- Tiger encounter tracking (blocks areas until next day)
-- Format: {areaId = dayNumber} - if tiger spawned in area on that day, area is blocked
if not Game then Game = {} end
if not Game.tigerBlockedAreas then Game.tigerBlockedAreas = {} end

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
        maxHealth = 50, -- One-shot with bow (50 damage)
        speed = 150, -- pixels per second
        fleeSpeed = 300, -- Speed when wounded and fleeing
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
        maxHealth = 150, -- Takes 3 bow shots or 2 rifle shots
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
    },
    boar = {
        name = "Boar",
        spawnChance = 0.15,
        maxHealth = 250, -- Takes 5 bow shots or 3 rifle shots
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
    },
    tiger = {
        name = "Tiger",
        spawnChance = 0.95, -- TEMP: 95% for testing (normally 0.05)
        maxHealth = 500, -- Very tough! Takes 10 bow shots or 6 rifle shots
        speed = 120,
        attackSpeed = 250, -- Speed when attacking player (when provoked)
        size = 100,
        meatValue = 100,
        meatCount = 5,
        headshotBonus = 2,
        behavior = "passive", -- PASSIVE: Doesn't move unless provoked!
        dangerous = true, -- This tiger attacks when shot!
        hideTime = {min = 5, max = 10},
        showTime = {min = 3, max = 6},
        audioRadius = 200
    }
}

-- Projectiles (for bow arrows)
hunting.projectiles = {}

function hunting:enter(fromState, entryPoint)
    print("═══════════════════════════════════════════════════════════")
    print("🎯 ENTERING HUNTING MODE (Attempt #" .. (hunting.entryCount or 0) + 1 .. ")")
    print("═══════════════════════════════════════════════════════════")
    print("🔍 DEBUG: hunting.active before reset = " .. tostring(hunting.active))
    print("🔍 DEBUG: fromState = " .. tostring(fromState))
    
    -- Track which hunting area we entered from
    -- fromState is the zone ID when called from gameplay (e.g., "hunting_northwest")
    hunting.currentArea = fromState or entryPoint or "unknown"
    print("🗺️  Entered hunting area: " .. hunting.currentArea)
    
    -- Track entry attempts
    hunting.entryCount = (hunting.entryCount or 0) + 1
    
    -- Reset hunting state
    hunting.timeRemaining = 180
    hunting.score = 0
    hunting.kills = 0
    hunting.shots = 0
    hunting.animals = {}
    hunting.projectiles = {}
    hunting.reloading = false
    hunting.reloadTimer = 0
    
    -- Tiger warning system
    hunting.tigerWarning = false
    hunting.tigerWarningTimer = 0
    
    -- Load ammo from player's inventory (limited resources!)
    local playerEntity = require("entities/player")
    
    -- Get ammo counts from inventory
    local arrowCount = playerEntity.getItemCount("arrows") or 0
    local bulletCount = playerEntity.getItemCount("bullets") or 0
    local shellCount = playerEntity.getItemCount("shells") or 0
    
    print("🔍 DEBUG: Inventory ammo - Arrows:" .. arrowCount .. " Bullets:" .. bulletCount .. " Shells:" .. shellCount)
    
    -- FIX: Don't remove ammo from inventory! Just reference it directly
    -- The old system removed ammo on enter and returned on exit, causing loss if state switched incorrectly
    -- NEW SYSTEM: Ammo stays in inventory, we just track it in hunting.ammo for convenience
    -- When shooting, we'll decrement BOTH hunting.ammo AND inventory
    
    -- Load into hunting weapons (reference, not consume)
    hunting.ammo.bow = arrowCount
    hunting.ammo.rifle = bulletCount
    hunting.ammo.shotgun = shellCount
    
    -- Check which weapons player owns
    local hasBow = playerEntity.hasItem("bow_weapon")
    local hasRifle = playerEntity.hasItem("rifle_weapon")
    local hasShotgun = playerEntity.hasItem("shotgun_weapon")
    
    print("🔍 DEBUG: Weapons - Bow:" .. tostring(hasBow) .. " Rifle:" .. tostring(hasRifle) .. " Shotgun:" .. tostring(hasShotgun))
    
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
        hunting.currentWeapon = "bow" -- Force bow as fallback
        print("⚠️ WARNING: No weapons found, forcing bow")
    end
    
    -- REMOVED AMMO VALIDATION - Allow entry even with no ammo for debugging
    print("🔍 DEBUG: Ammo check bypassed - allowing entry")
    
    -- ALL VALIDATION PASSED - Now activate hunting mode!
    hunting.active = true
    print("🔍 DEBUG: hunting.active set to TRUE")
    
    -- Show mouse cursor for aiming
    love.mouse.setVisible(true)
    
    -- Spawn initial animal (just one)
    hunting:spawnAnimal()
    
    print("🏹 Armed with " .. hunting.weapons[hunting.currentWeapon].name)
    print("📦 Ammo: " .. hunting.ammo[hunting.currentWeapon])
    print("═══════════════════════════════════════════════════════════")
    print("🎯 HUNTING MODE READY - You can hunt now!")
    print("═══════════════════════════════════════════════════════════")
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
    
    -- Update tiger warning timer
    if hunting.tigerWarning and hunting.tigerWarningTimer > 0 then
        hunting.tigerWarningTimer = hunting.tigerWarningTimer - dt
        if hunting.tigerWarningTimer <= 0 then
            hunting.tigerWarning = false
        end
    end
    
    -- Update animals (IMPROVED: Better removal pattern)
    for i = #hunting.animals, 1, -1 do
        local animal = hunting.animals[i]
        
        -- Remove dead animals FIRST before processing
        if animal.dead then
            table.remove(hunting.animals, i)
            goto continue -- Skip rest of iteration
        end
        
        -- Now process only living animals
        hunting:updateAnimal(animal, dt)
        
        -- TIGER ATTACK: Check if tiger gets too close!
        -- BUT ONLY if the tiger is ATTACKING (provoked by player shooting it)
        if animal.type == "tiger" and animal.visible and animal.attacking then
            local tigerScreenX = animal.x
            local crosshairX = hunting.gunX -- Use gun position as "player center"
            local distanceToPlayer = math.abs(tigerScreenX - crosshairX)
            
            -- If attacking tiger gets within 200 pixels, it triggers overworld chase
            if distanceToPlayer < 200 then
                print("═══════════════════════════════════════")
                print("🐅 TIGER ATTACKS!")
                print("💀 You are being chased!")
                print("🏃 RUN TO YOUR HOUSE!")
                print("═══════════════════════════════════════")
                
                -- Set global flag to trigger tiger chase in overworld
                if not Game then Game = {} end
                Game.tigerChasing = true
                Game.tigerWarning = true
                
                -- Exit hunting and return to overworld
                local gamestate = require("states/gamestate")
                gamestate.switch("gameplay")
                return
            end
        end
        
        ::continue:: -- Label for skipping iteration
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
    
    -- Spawn new animals periodically (allow up to 3 animals total)
    -- Count tigers and other animals separately
    local tigerCount = 0
    local otherAnimalCount = 0
    for _, animal in ipairs(hunting.animals) do
        if animal.type == "tiger" then
            tigerCount = tigerCount + 1
        else
            otherAnimalCount = otherAnimalCount + 1
        end
    end
    
    -- Spawn logic: Allow 1 tiger + 2 other animals
    if #hunting.animals < 3 and math.random() < 0.005 then -- 0.5% chance per frame
        -- If tiger exists and we have 2+ other animals, don't spawn more
        -- If no tiger, spawn normally
        if tigerCount == 0 or otherAnimalCount < 2 then
            hunting:spawnAnimal()
        end
    end
end

function hunting:updateAnimal(animal, dt)
    local animalType = hunting.animalTypes[animal.type]
    
    -- ATTACKING BEHAVIOR (tigers get aggressive when wounded!)
    if animal.attacking then
        local attackSpeed = animalType.attackSpeed or 250
        
        -- Move toward center of screen (player position)
        if animal.x < hunting.gunX then
            animal.x = animal.x + attackSpeed * dt
        else
            animal.x = animal.x - attackSpeed * dt
        end
        
        -- Keep visible while attacking
        animal.visible = true
        animal.state = "visible"
        
        -- Don't remove attacking animals - they keep coming!
        return
    end
    
    -- FLEEING BEHAVIOR (wounded animals escape!)
    if animal.fleeing then
        local fleeSpeed = animalType.fleeSpeed or 200
        animal.x = animal.x + (animal.fleeDirection * fleeSpeed * dt)
        
        -- Remove when off-screen
        if animal.x < -50 or animal.x > 1010 then
            -- Animal escaped!
            for i, a in ipairs(hunting.animals) do
                if a == animal then
                    table.remove(hunting.animals, i)
                    print("🏃 " .. animalType.name .. " escaped off-screen!")
                    break
                end
            end
        end
        return
    end
    
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
        elseif animalType.behavior == "passive" then
            -- PASSIVE: Tiger doesn't move unless provoked
            -- Just stays in place, watching...
            -- (Will only move when animal.attacking = true)
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
    
    -- TIGER WARNING: Dangerous animal!
    if chosenType == "tiger" then
        print("═══════════════════════════════════════")
        print("🐅 TIGER SPOTTED! DANGEROUS!")
        print("⚠️  This animal will attack you!")
        print("═══════════════════════════════════════")
        
        -- BLOCK THIS AREA UNTIL NEXT DAY!
        local daynightSystem = require("systems/daynight")
        local currentDay = daynightSystem.dayCount or 1
        Game.tigerBlockedAreas[hunting.currentArea] = currentDay
        print("🚫 " .. hunting.currentArea .. " is now BLOCKED until next day!")
        print("🗺️  You'll need to hunt in a different area today!")
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
        health = animalData.maxHealth, -- Use maxHealth from config
        maxHealth = animalData.maxHealth, -- Store max for health bar
        state = "hidden",
        stateTimer = math.random(animalData.hideTime.min, animalData.hideTime.max),
        visible = false,
        dead = false,
        attacking = false, -- Tigers start PASSIVE, only attack when shot
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
    
    -- FIX: Consume ammo from BOTH hunting.ammo AND player inventory
    hunting.ammo[hunting.currentWeapon] = hunting.ammo[hunting.currentWeapon] - 1
    hunting.shots = hunting.shots + 1
    
    -- Also remove from player's actual inventory
    local playerEntity = require("entities/player")
    if hunting.currentWeapon == "bow" then
        playerEntity.removeItem("arrows", 1)
    elseif hunting.currentWeapon == "rifle" then
        playerEntity.removeItem("bullets", 1)
    elseif hunting.currentWeapon == "shotgun" then
        playerEntity.removeItem("shells", 1)
    end
    
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
    local weapon = hunting.weapons[hunting.currentWeapon]
    
    -- Initialize HP if not set
    if not animal.health then
        animal.health = animalData.maxHealth
        animal.maxHealth = animalData.maxHealth
    end
    
    -- Deal damage
    local damage = weapon.damage
    if headshot then
        damage = damage * 2
        print("🎯 HEADSHOT!")
    end
    
    animal.health = animal.health - damage
    animal.hasBeenHit = true -- Track that animal has been hit (for HP bar display)
    print("💥 HIT " .. animalData.name .. " for " .. damage .. " damage! HP: " .. animal.health .. "/" .. animal.maxHealth)
    
    if animal.health <= 0 then
        -- KILLED
        animal.dead = true
        hunting.kills = hunting.kills + 1
        
        -- Calculate loot
        local meatCount = animalData.meatCount
        if headshot then
            meatCount = math.floor(meatCount * animalData.headshotBonus)
        end
        
        -- Add meat to inventory
        playerEntity.addItem(animal.type .. "_meat", meatCount)
        
        -- Update score
        local points = animalData.meatValue * meatCount
        hunting.score = hunting.score + points
        
        print("💀 KILLED " .. animalData.name .. "! +" .. meatCount .. " meat")
    else
        -- WOUNDED - Check if it's a tiger (dangerous animal)
        if animalData.dangerous then
            -- TIGER DOESN'T FLEE - IT GETS ANGRY!
            animal.wounded = true
            animal.attacking = true -- Mark as attacking instead of fleeing
            animal.visible = true
            
            -- TRIGGER BIG RED WARNING!
            hunting.tigerWarning = true
            hunting.tigerWarningTimer = 3.0 -- Show warning for 3 seconds
            
            print("🐅 " .. animalData.name .. " is ENRAGED! (HP: " .. animal.health .. ") It's coming for you!")
        else
            -- Normal animals flee when wounded
            animal.wounded = true
            animal.fleeing = true
            animal.visible = true -- Keep visible while fleeing
            animal.fleeDirection = (hunting.gunX < animal.x) and 1 or -1
            print("💨 " .. animalData.name .. " is WOUNDED (HP: " .. animal.health .. ") and fleeing!")
        end
    end
end

function hunting:exitHunting()
    -- CHECK FOR ATTACKING TIGER FIRST!
    -- If there's an enraged tiger, you can't just walk away!
    for _, animal in ipairs(hunting.animals) do
        if animal.type == "tiger" and animal.attacking and not animal.dead then
            -- TIGER IS CHASING! Can't exit peacefully!
            print("═══════════════════════════════════════")
            print("🐅 YOU CAN'T ESCAPE!")
            print("💀 The tiger is chasing you!")
            print("🏃 IT FOLLOWS YOU OUT!")
            print("═══════════════════════════════════════")
            
            -- Trigger tiger chase in overworld
            if not Game then Game = {} end
            Game.tigerChasing = true
            Game.tigerWarning = true
            
            -- FIX: Ammo stays in inventory now, no need to return it
            -- (Ammo is decremented from inventory when shooting)
            
            -- Exit to overworld with tiger chase active
            local gamestate = require("states/gamestate")
            gamestate.switch("gameplay")
            return
        end
    end
    
    -- NO ATTACKING TIGER - Safe exit
    -- FIX: Ammo stays in inventory now, no need to return it
    -- (Ammo is decremented from inventory when shooting, so it's already accurate)
    
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

-- Called by gamestate manager when leaving hunting state
function hunting:exit()
    print("═══════════════════════════════════════════════════════════")
    print("🔍 DEBUG: hunting:exit() called by gamestate manager")
    print("═══════════════════════════════════════════════════════════")
    hunting.active = false
    
    -- Hide mouse cursor
    love.mouse.setVisible(false)
    
    -- Reset hunting state
    hunting.animals = {}
    hunting.projectiles = {}
    hunting.reloading = false
    hunting.reloadTimer = 0
    
    print("🔍 DEBUG: hunting:exit() complete - hunting.active = " .. tostring(hunting.active))
    print("═══════════════════════════════════════════════════════════")
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
            
            -- Draw health bar ONLY if animal has been hit (not initially visible)
            -- IMPROVED: Added division by zero protection
            if animal.hasBeenHit and animal.health and animal.maxHealth and animal.maxHealth > 0 then
                local barWidth = 50
                local barHeight = 6
                local barX = animal.x - barWidth/2
                local barY = animal.y - size/2 - 18  -- 18 pixels above animal
                
                -- Background (red)
                lg.setColor(0.3, 0, 0, 0.8)
                lg.rectangle("fill", barX, barY, barWidth, barHeight)
                
                -- Health (green to yellow to red based on percentage)
                -- Clamp healthPercent between 0 and 1 to prevent visual glitches
                local healthPercent = math.max(0, math.min(1, animal.health / animal.maxHealth))
                local healthWidth = barWidth * healthPercent
                
                -- Color gradient based on health
                if healthPercent > 0.6 then
                    lg.setColor(0, 0.8, 0, 0.9)  -- Green (healthy)
                elseif healthPercent > 0.3 then
                    lg.setColor(0.9, 0.9, 0, 0.9)  -- Yellow (wounded)
                else
                    lg.setColor(0.9, 0, 0, 0.9)  -- Red (critical)
                end
                
                lg.rectangle("fill", barX, barY, healthWidth, barHeight)
                
                -- Border
                lg.setColor(0, 0, 0, 0.9)
                lg.setLineWidth(1)
                lg.rectangle("line", barX, barY, barWidth, barHeight)
                
                -- NO HP TEXT - Just the visual bar
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
    
    -- Timer (with warning when low)
    local minutes = math.floor(hunting.timeRemaining / 60)
    local seconds = math.floor(hunting.timeRemaining % 60)
    
    if hunting.timeRemaining <= 30 then
        -- Flash red when under 30 seconds
        local flash = math.sin(love.timer.getTime() * 5) > 0
        lg.setColor(flash and 1 or 0.5, 0, 0)
        lg.print(string.format("⚠️ Time: %d:%02d", minutes, seconds), 20, 20)
    else
        lg.setColor(1, 1, 1)
        lg.print(string.format("Time: %d:%02d", minutes, seconds), 20, 20)
    end
    
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
    
    -- ⚠️ TIGER WARNING OVERLAY (BIG RED SCREEN!)
    if hunting.tigerWarning and hunting.tigerWarningTimer > 0 then
        -- Red overlay with pulsing effect
        local pulse = 0.3 + (math.sin(love.timer.getTime() * 10) * 0.2)
        lg.setColor(1, 0, 0, pulse)
        lg.rectangle("fill", 0, 0, 960, 540)
        
        -- Giant warning text
        lg.setColor(1, 1, 1)
        local warningText = "⚠️  TIGER ENRAGED!  ⚠️"
        local font = lg.getFont()
        local textWidth = font:getWidth(warningText)
        lg.print(warningText, 480 - textWidth/2, 200, 0, 2, 2) -- 2x scale
        
        -- RUN! text
        lg.setColor(1, 0, 0)
        local runText = "RUN!"
        local runWidth = font:getWidth(runText)
        lg.print(runText, 480 - runWidth/2, 280, 0, 3, 3) -- 3x scale
        
        -- White outline on RUN text for better visibility
        lg.setColor(1, 1, 1)
        lg.print(runText, 478 - runWidth/2, 278, 0, 3, 3)
        lg.print(runText, 482 - runWidth/2, 282, 0, 3, 3)
    end
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
