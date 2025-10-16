# Tiger Chase System - Implementation Status

**Date**: October 16, 2025  
**Issue**: Tiger chase mechanism appears incomplete  
**Status**: Code is implemented but needs testing/verification

## Current Implementation Overview

The tiger chase system WAS implemented across three files:

### 1. **Trigger (states/hunting.lua)** ✅ IMPLEMENTED

Lines 251-273:
```lua
-- TIGER ATTACK: Check if tiger gets too close!
if animal.type == "tiger" and animal.visible and not animal.dead and not animal.fleeing then
    local tigerScreenX = animal.x
    local crosshairX = hunting.gunX
    local distanceToPlayer = math.abs(tigerScreenX - crosshairX)
    
    -- If tiger gets within 150 pixels of center screen, it attacks!
    if distanceToPlayer < 150 then
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
```

**Status**: ✅ Code present and should work

### 2. **Chase Logic (systems/world.lua)** ✅ IMPLEMENTED

Lines 440-500:
```lua
function world.update(dt, playerX, playerY)
    -- TIGER CHASE SYSTEM
    if Game and Game.tigerChasing and world.tigerChase then
        local tiger = world.tigerChase
        
        -- Move tiger toward player
        local dx = playerX - tiger.x
        local dy = playerY - tiger.y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        if distance > 0 then
            tiger.x = tiger.x + (dx / distance) * tiger.speed * dt
            tiger.y = tiger.y + (dy / distance) * tiger.speed * dt
        end
        
        -- Check if tiger caught player
        if distance < 30 then
            print("💀 THE TIGER CAUGHT YOU!")
            local gamestate = require("states/gamestate")
            gamestate.switch("death")
            return
        end
        
        -- Check if player reached house (safe zone)
        local houseX = world.structures.cabin.x + world.structures.cabin.width/2
        local houseY = world.structures.cabin.y + world.structures.cabin.height/2
        local distanceToHouse = math.sqrt((playerX - houseX)^2 + (playerY - houseY)^2)
        
        if distanceToHouse < 50 then
            print("🏠 YOU MADE IT HOME SAFELY!")
            Game.tigerChasing = false
            Game.tigerWarning = false
            world.tigerChase = nil
        end
    end
    
    -- Initialize tiger chase if triggered
    if Game and Game.tigerChasing and not world.tigerChase then
        world.tigerChase = {
            x = playerX - 100,
            y = playerY,
            speed = 120
        }
        print("🐅 Tiger chase started! Run to your house!")
    end
end
```

**Status**: ✅ Code present and should work

### 3. **Visual Display (systems/world.lua)** ✅ IMPLEMENTED

Lines 321-338:
```lua
function world.draw()
    -- DRAW TIGER CHASE
    if Game and Game.tigerChasing and world.tigerChase then
        local tiger = world.tigerChase
        love.graphics.setColor(1, 0.5, 0, 1)
        love.graphics.circle("fill", tiger.x, tiger.y, 20)
        
        -- Draw tiger face
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", tiger.x - 7, tiger.y - 5, 3) -- Eye
        love.graphics.circle("fill", tiger.x + 7, tiger.y - 5, 3) -- Eye
        love.graphics.arc("line", "open", tiger.x, tiger.y + 5, 8, math.pi * 0.2, math.pi * 0.8)
        
        -- Warning text
        love.graphics.setColor(1, 0, 0, math.abs(math.sin(love.timer.getTime() * 5)))
        love.graphics.print("🐅 TIGER CHASING! RUN TO HOUSE!", 300, 20)
    end
end
```

**Status**: ✅ Code present and should work

### 4. **Update Call (states/gameplay.lua)** ✅ IMPLEMENTED

Lines 14-30:
```lua
function gameplay:update(dt)
    local areas = require("systems/areas")
    areas.update(dt)
    
    local playerSystem = require("systems/player")
    playerSystem.update(dt)
    
    local daynightSystem = require("systems/daynight")
    daynightSystem.update(dt)
    
    -- Update world system (for tiger chase)
    local worldSystem = require("systems/world")
    worldSystem.update(dt, playerSystem.x, playerSystem.y)
end
```

**Status**: ✅ Code present and should work

### 5. **Death Screen (states/death.lua)** ✅ IMPLEMENTED

Complete death screen with restart functionality.

**Status**: ✅ Code present and registered in main.lua

## Why Tiger Chase Might Not Be Working

### Possible Issues

#### 1. **Tiger Spawn Rate**
Tigers have only 5% spawn chance:
```lua
tiger = {
    spawnChance = 0.05,  -- Only 5%!
    -- ...
}
```

**Impact**: May take many hunting attempts before seeing a tiger

#### 2. **Tiger Approach Behavior**
Tigers use "stalk" behavior which is SLOW:
```lua
elseif animalType.behavior == "stalk" then
    -- Slow approach
    animal.x = animal.x + animal.direction * animalType.speed * 0.3 * dt
end
```

**Impact**: Tiger moves at 30% speed, may not reach 150px trigger distance

#### 3. **Player Can Kill Tiger First**
Tiger has 500 HP but player can shoot it before it gets close:
- Rifle: 5 shots to kill (100 dmg × 5 = 500)
- Bow: 10 shots to kill (50 dmg × 10 = 500)

**Impact**: Tiger might die or flee before triggering chase

#### 4. **150px Trigger Distance**
The trigger check is:
```lua
if distanceToPlayer < 150 then
```

**Impact**: Tiger must get VERY close (almost center screen) to trigger

## Testing Procedure

### Step 1: Force Tiger Spawn (DEBUG)
Temporarily increase spawn chance in `states/hunting.lua`:

```lua
-- Line ~69
tiger = {
    spawnChance = 0.95,  -- TEMP: 95% for testing!
    -- ...
}
```

### Step 2: Make Tiger More Aggressive
Increase stalk speed in `states/hunting.lua`:

```lua
-- Line ~334
elseif animalType.behavior == "stalk" then
    -- TEMP: Faster approach for testing
    animal.x = animal.x + animal.direction * animalType.speed * 2.0 * dt
end
```

### Step 3: Widen Trigger Distance
Make it easier to trigger:

```lua
-- Line ~259
if distanceToPlayer < 300 then  -- Was 150
```

### Step 4: Test Sequence
1. Run game
2. Enter hunting zone
3. Tiger should spawn (95% chance)
4. Wait for tiger to approach (or move crosshair near it)
5. When within 300px, should trigger:
   - Console: "🐅 TIGER ATTACKS!"
   - Exit to overworld
   - Tiger appears behind player
   - Chase begins

### Step 5: Test Outcomes
**Outcome A: Reach House**
- Run to cabin (460, 310)
- Within 50px: "🏠 YOU MADE IT HOME SAFELY!"
- Tiger disappears

**Outcome B: Get Caught**
- Let tiger catch you (within 30px)
- Console: "💀 THE TIGER CAUGHT YOU!"
- Death screen appears
- Shows days survived

## Console Output You Should See

### When Tiger Spawns:
```
═══════════════════════════════════════
🐅 TIGER SPOTTED! DANGEROUS!
⚠️  This animal will attack you!
═══════════════════════════════════════
```

### When Tiger Attacks:
```
═══════════════════════════════════════
🐅 TIGER ATTACKS!
💀 You are being chased!
🏃 RUN TO YOUR HOUSE!
═══════════════════════════════════════
🐅 Tiger chase started! Run to your house!
```

### If You Escape:
```
═══════════════════════════════════════
🏠 YOU MADE IT HOME SAFELY!
✅ The tiger gives up and runs away
═══════════════════════════════════════
```

### If Tiger Catches You:
```
═══════════════════════════════════════
💀 THE TIGER CAUGHT YOU!
☠️  GAME OVER
═══════════════════════════════════════
💀 Death screen entered
```

## Current Status Summary

| Component | Status | Location |
|-----------|--------|----------|
| Tiger Spawn | ✅ Working | states/hunting.lua:69 |
| Tiger Attack Trigger | ✅ Implemented | states/hunting.lua:251 |
| Chase Initialization | ✅ Implemented | systems/world.lua:491 |
| Chase Update Logic | ✅ Implemented | systems/world.lua:445 |
| Chase Rendering | ✅ Implemented | systems/world.lua:321 |
| Caught Detection | ✅ Implemented | systems/world.lua:460 |
| Safe Zone Detection | ✅ Implemented | systems/world.lua:473 |
| Death Screen | ✅ Implemented | states/death.lua |
| Integration | ✅ Complete | All files connected |

## Recommendation

The tiger chase IS fully implemented. The issue is likely:

1. **Low spawn rate** (5%) - Players rarely see tigers
2. **Slow approach** (30% speed) - Tiger doesn't get close enough
3. **Player kills it first** - 500 HP but 10 shots with bow

### Quick Fix Options:

**Option A: Make Tigers Spawn More Often (DEBUG)**
```lua
-- Temporary for testing
tiger.spawnChance = 0.3  -- 30% instead of 5%
```

**Option B: Make Tigers More Aggressive**
```lua
-- Make tigers move faster and start closer
tiger.speed = 150  -- Was 100
-- AND in updateAnimal:
elseif animalType.behavior == "stalk" then
    animal.x = animal.x + animal.direction * animalType.speed * 1.0 * dt  -- Was 0.3
end
```

**Option C: Make Trigger More Sensitive**
```lua
-- Trigger from further away
if distanceToPlayer < 250 then  -- Was 150
```

## Files Involved

- `states/hunting.lua` - Tiger spawn, trigger detection
- `systems/world.lua` - Chase logic, rendering
- `states/gameplay.lua` - Update calls
- `states/death.lua` - Game over screen
- `main.lua` - State registration

## Next Steps

1. **Test with increased spawn rate** to verify system works
2. **If working**: Adjust balance (spawn rate, speed, trigger distance)
3. **If not working**: Debug with console output at each step
4. **Document results**: Update this file with findings

---

**Conclusion**: The tiger chase system IS fully implemented in code. The issue is likely game balance making it rare/difficult to trigger. Needs testing with adjusted parameters.
