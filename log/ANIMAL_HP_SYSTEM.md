# Animal HP & Tiger Chase System - Implementation Guide
**Date:** October 16, 2025  
**Status:** Partially implemented - needs completion

---

## ✅ Completed

### 1. Day Counter System
- Day counter now displays in top-right corner of screen
- Shows "Day X" format
- Updates automatically when midnight passes
- File: `states/gameplay.lua` lines 125-126

### 2. Animal HP Values Set
All animals now have proper HP values:
- **Rabbit**: 50 HP (one-shot with bow/rifle)
- **Deer**: 150 HP (3 bow shots, 2 rifle shots)
- **Boar**: 250 HP (5 bow shots, 3 rifle shots)
- **Tiger**: 500 HP (10 bow shots, 6 rifle shots) + attacks player
- File: `states/hunting.lua` lines 69-130

---

## 🚧 Needs Implementation

### 3. Remove Tiger Instant-Exit (CRITICAL)
**Current Code (Line 350):**
```lua
-- TIGER FEAR MECHANIC: If tiger spawns, player is too scared to hunt!
if chosenType == "tiger" then
    print("═══════════════════════════════════════")
    print("🐅 TIGER APPEARS! You flee in fear!")
    print("⚠️  A WILD TIGER scared you away!")
    print("💨 You ran out of the hunting zone!")
    print("═══════════════════════════════════════")
    hunting:exitHunting()
    return
end
```

**REPLACE WITH:**
```lua
-- TIGER SPAWN: Instead of instant flee, tiger attacks player!
if chosenType == "tiger" then
    print("═══════════════════════════════════════")
    print("🐅 TIGER APPEARS! It's attacking you!")
    print("⚠️  DANGER! You must escape to your house!")
    print("═══════════════════════════════════════")
    -- Don't return - let tiger spawn normally
    -- Tiger will chase player when hunting ends
end
```

### 4. Animal Instance HP System
**Add to spawn function (around line 367):**
```lua
local animal = {
    type = chosenType,
    x = spawnX,
    y = hunting.bushPositions[spawnBushIndex],
    visible = false,
    hiding = true,
    hideTimer = math.random(animalData.hideTime.min, animalData.hideTime.max),
    direction = math.random() > 0.5 and 1 or -1,
    
    -- NEW HP SYSTEM
    health = animalData.maxHealth, -- Current HP
    maxHealth = animalData.maxHealth, -- Max HP
    wounded = false, -- Is animal wounded and fleeing?
    fleeing = false, -- Is animal actively fleeing?
    fleeDirection = 1 -- Direction to flee (1 = right, -1 = left)
}
```

### 5. Hit Detection with HP Damage
**Update checkProjectileHit function (around line 445):**
```lua
function hunting:checkProjectileHit(proj, animal)
    if not animal.visible then return false end
    
    local animalData = hunting.animalTypes[animal.type]
    local dx = proj.x - animal.x
    local dy = proj.y - animal.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance < animalData.size / 2 then
        -- HIT!
        local weapon = hunting.weapons[proj.weapon]
        animal.health = animal.health - weapon.damage
        
        print("🎯 HIT " .. animalData.name .. " for " .. weapon.damage .. " damage!")
        print("   HP: " .. animal.health .. "/" .. animal.maxHealth)
        
        if animal.health <= 0 then
            -- KILL
            animal.dead = true
            hunting:collectMeat(animal)
            print("💀 KILLED " .. animalData.name .. "!")
            return true
        else
            -- WOUNDED - Animal flees!
            animal.wounded = true
            animal.fleeing = true
            animal.visible = true -- Stay visible while fleeing
            animal.fleeDirection = proj.vx > 0 and 1 or -1 -- Flee away from shot
            print("💨 " .. animalData.name .. " is wounded and fleeing!")
            return true
        end
    end
    
    return false
end
```

### 6. Animal Flee Behavior
**Update updateAnimal function (around line 285):**
```lua
function hunting:updateAnimal(animal, dt)
    if animal.dead then return end
    
    local animalType = hunting.animalTypes[animal.type]
    
    -- FLEE BEHAVIOR (when wounded)
    if animal.fleeing then
        animal.x = animal.x + (animalType.fleeSpeed or animalType.speed * 2) * animal.fleeDirection * dt
        
        -- Remove animal when it escapes off screen
        if animal.x < 0 or animal.x > 960 then
            print("💨 " .. animalType.name .. " escaped!")
            animal.dead = true -- Remove from game
            return
        end
        return -- Skip normal behavior
    end
    
    -- [Rest of normal behavior code...]
end
```

### 7. Tiger Attack Player Mechanic
**Add tiger attack detection (in update function, around line 240):**
```lua
-- Check if tiger is attacking player
for i, animal in ipairs(hunting.animals) do
    if animal.type == "tiger" and animal.visible and not animal.dead then
        local animalData = hunting.animalTypes["tiger"]
        
        -- Tiger charges at center (where player is)
        local dx = hunting.gunX - animal.x
        if math.abs(dx) < 100 then
            -- TIGER REACHED PLAYER!
            print("═══════════════════════════════════════")
            print("🐅 TIGER ATTACKED YOU!")
            print("💨 You flee the hunting zone!")
            print("⚠️  GET TO YOUR HOUSE NOW!")
            print("═══════════════════════════════════════")
            
            -- Set global tiger chase flag
            Game.tigerChasing = true
            Game.tigerX = 500 -- Spawn tiger near player in overworld
            Game.tigerY = 300
            
            hunting:exitHunting()
            return
        end
    end
end
```

### 8. Tiger Chase in Overworld
**Add to systems/world.lua:**
```lua
world.tigerChase = {
    active = false,
    x = 0,
    y = 0,
    speed = 100
}

function world.update(dt)
    -- [existing code...]
    
    -- Tiger chase logic
    if Game.tigerChasing then
        world.tigerChase.active = true
        
        local playerSystem = require("systems/player")
        local dx = playerSystem.x - world.tigerChase.x
        local dy = playerSystem.y - world.tigerChase.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < 30 then
            -- TIGER CAUGHT PLAYER!
            local gamestate = require("states/gamestate")
            gamestate.switch("death")
            return
        end
        
        -- Move tiger towards player
        if distance > 0 then
            world.tigerChase.x = world.tigerChase.x + (dx / distance) * world.tigerChase.speed * dt
            world.tigerChase.y = world.tigerChase.y + (dy / distance) * world.tigerChase.speed * dt
        end
        
        -- Check if player reached house (safety)
        if playerSystem.x > 430 and playerSystem.x < 550 and 
           playerSystem.y > 280 and playerSystem.y < 380 then
            -- SAFE AT HOUSE!
            Game.tigerChasing = false
            world.tigerChase.active = false
            print("✅ You made it to safety! Tiger gave up.")
        end
    end
end

function world.draw()
    -- [existing code...]
    
    -- Draw chasing tiger
    if world.tigerChase.active then
        love.graphics.setColor(1, 0.4, 0)
        love.graphics.rectangle("fill", world.tigerChase.x, world.tigerChase.y, 40, 40)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("🐅 TIGER!", world.tigerChase.x - 10, world.tigerChase.y - 20)
    end
end
```

### 9. Death Screen State
**Create new file: states/death.lua:**
```lua
local death = {}

function death:enter()
    print("💀 GAME OVER - Tiger caught you!")
end

function death:draw()
    local lg = love.graphics
    
    -- Black background
    lg.setColor(0, 0, 0)
    lg.rectangle("fill", 0, 0, 960, 540)
    
    -- Death message
    lg.setColor(1, 0, 0)
    lg.print("YOU DIED", 960/2 - 100, 540/2 - 100, 0, 3, 3)
    
    lg.setColor(1, 1, 1)
    lg.print("A tiger caught you!", 960/2 - 80, 540/2)
    lg.print("Press R to restart", 960/2 - 70, 540/2 + 40)
    
    local daynightSystem = require("systems/daynight")
    lg.print("You survived " .. daynightSystem.dayCount .. " days", 960/2 - 80, 540/2 + 80)
end

function death:keypressed(key)
    if key == "r" then
        -- Restart game
        love.load()
        local gamestate = require("states/gamestate")
        gamestate.switch("gameplay")
    end
end

return death
```

**Register death state in main.lua:**
```lua
local death = require("states/death")
gamestate.register("death", death)
```

---

## 📋 Implementation Steps

1. ✅ Add day counter display
2. ✅ Set animal HP values
3. ⚠️ Remove tiger instant-exit code
4. ⚠️ Add HP system to animal instances
5. ⚠️ Update hit detection with HP damage
6. ⚠️ Add wounded flee behavior
7. ⚠️ Implement tiger attack player
8. ⚠️ Add tiger chase in overworld
9. ⚠️ Create death screen state

---

## 🎮 Testing Checklist

- [ ] Day counter displays and increments
- [ ] Rabbit dies in 1 bow shot
- [ ] Deer takes 3 bow shots to kill
- [ ] Boar takes 5 bow shots to kill
- [ ] Wounded animals flee off screen
- [ ] Tiger spawns and attacks player
- [ ] Tiger chase activates in overworld
- [ ] Death screen appears when caught
- [ ] Player safe when reaching house
- [ ] Can restart after death

---

**STATUS: Day counter done, HP values set. Need to implement damage/flee/chase mechanics next session.**
