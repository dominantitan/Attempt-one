# 🔍 POTENTIAL ISSUES ANALYSIS
**Date:** October 16, 2025  
**Analysis Type:** Proactive Debugging & Code Quality Review

---

## 🚨 CRITICAL ISSUES

### 1. **Game.tigerBlockedAreas Never Gets Reset**
**Location:** Multiple files  
**Severity:** 🔴 CRITICAL - Memory leak & save corruption  

**Problem:**
```lua
-- states/hunting.lua:18
if not Game.tigerBlockedAreas then Game.tigerBlockedAreas = {} end

-- states/hunting.lua:465
Game.tigerBlockedAreas[hunting.currentArea] = currentDay
```

- `Game.tigerBlockedAreas` grows infinitely - never cleared
- If player plays 100 days, this table has 100+ entries
- **Worse:** This data is NOT saved/loaded, causing desync
- After game restart, blocked areas reset but day count doesn't

**Impact:**
- Memory leak (minor but exists)
- Save/load desync - areas blocked before save become unblocked after load
- Inconsistent game state

**Solution Needed:**
```lua
-- In daynightSystem.advanceDay():
function daynightSystem.advanceDay()
    daynightSystem.dayCount = daynightSystem.dayCount + 1
    
    -- CLEAR OLD BLOCKED AREAS
    if Game.tigerBlockedAreas then
        Game.tigerBlockedAreas = {} -- Reset all blocked areas on new day
    end
    
    -- Rest of day advance logic...
end
```

---

### 2. **Nil Animal Reference After Table.Remove**
**Location:** states/hunting.lua:302  
**Severity:** 🔴 CRITICAL - Potential crash  

**Problem:**
```lua
-- states/hunting.lua:295-305
for i = #hunting.animals, 1, -1 do
    local animal = hunting.animals[i]
    
    -- Multiple checks use `animal` variable
    if animal.type == "tiger" and animal.attacking then
        -- ... chase logic
    end
    
    -- Remove dead animals
    if animal.dead then
        table.remove(hunting.animals, i) -- Animal removed here
    end
end
```

**Issue:** If `table.remove()` is called, the loop continues but `animal` still references the removed object. While Lua handles this gracefully, later code might access `animal.x`, `animal.y` etc. which could be nil if the object is garbage collected.

**Likelihood:** Low (Lua's GC is smart) but still a concern

**Better Pattern:**
```lua
for i = #hunting.animals, 1, -1 do
    local animal = hunting.animals[i]
    
    if animal.dead then
        table.remove(hunting.animals, i)
        -- Skip rest of loop iteration
        goto continue
    end
    
    -- All other animal logic here
    
    ::continue::
end
```

---

### 3. **World Update Called When nil World System**
**Location:** main.lua:204  
**Severity:** 🟠 HIGH - Conditional crash  

**Problem:**
```lua
-- main.lua:168
if areas.currentArea == "main_world" then
    worldSystem.update(dt) -- What if worldSystem is nil?
    farmingSystem.update(dt)
    cropsEntity.update(dt)
end
```

**Issue:** If `worldSystem` fails to load (require error), this crashes with "attempt to index nil value"

**Solution:**
```lua
if areas.currentArea == "main_world" then
    if worldSystem and worldSystem.update then
        worldSystem.update(dt)
    end
    if farmingSystem and farmingSystem.update then
        farmingSystem.update(dt)
    end
    if cropsEntity and cropsEntity.update then
        cropsEntity.update(dt)
    end
end
```

---

## ⚠️ HIGH-PRIORITY ISSUES

### 4. **Animal HP Bar Division by Zero**
**Location:** states/hunting.lua:858-870  
**Severity:** 🟠 HIGH - Visual glitch  

**Problem:**
```lua
-- states/hunting.lua:858
if animal.hasBeenHit and animal.health and animal.maxHealth then
    -- What if maxHealth is 0?
    local healthPercent = animal.health / animal.maxHealth
```

**Issue:** If `animal.maxHealth` is somehow set to 0, this causes division by zero (returns `nan` or `inf`)

**Current Safeguard:** The check `animal.maxHealth` only checks if it exists (truthy), not if it's > 0

**Better Check:**
```lua
if animal.hasBeenHit and animal.health and animal.maxHealth and animal.maxHealth > 0 then
    local healthPercent = math.max(0, math.min(1, animal.health / animal.maxHealth))
```

---

### 5. **Spawn Logic Can Create Infinite Loops**
**Location:** states/hunting.lua:347  
**Severity:** 🟠 HIGH - Performance freeze  

**Problem:**
```lua
-- states/hunting.lua:347
if tigerCount == 0 or otherAnimalCount < 2 then
    hunting:spawnAnimal()
end
```

**Issue:** If `spawnAnimal()` fails repeatedly (e.g., no valid spawn positions), this runs every frame trying to spawn but never succeeding. While not an infinite loop, it's wasteful.

**Potential Scenario:**
1. Tiger spawned, blocks area
2. Spawn attempts fail for other animals
3. Every frame tries to spawn (0.5% chance × 60fps = 30 attempts/sec)
4. None succeed but keep trying

**Solution:** Add cooldown timer
```lua
hunting.spawnCooldown = hunting.spawnCooldown or 0
hunting.spawnCooldown = hunting.spawnCooldown - dt

if #hunting.animals < 3 and hunting.spawnCooldown <= 0 then
    if math.random() < 0.005 then
        if tigerCount == 0 or otherAnimalCount < 2 then
            local spawned = hunting:spawnAnimal()
            if spawned then
                hunting.spawnCooldown = 2 -- 2 second cooldown between spawns
            else
                hunting.spawnCooldown = 5 -- Longer cooldown if spawn failed
            end
        end
    end
end
```

---

### 6. **Tiger Chase Triggers Even After Death**
**Location:** systems/world.lua:501  
**Severity:** 🟡 MEDIUM - Logic error  

**Problem:**
```lua
-- systems/world.lua (tiger chase logic)
-- Check if tiger exists in worldSystem
if world.chasingTiger and world.chasingTiger.health and world.chasingTiger.health > 0 then
    -- Chase continues
end
```

**Issue:** Need to verify this check exists. If tiger health drops to 0 but chase continues, player is chased by a ghost tiger.

**Verify:** Check if `world.chasingTiger.dead` or `world.chasingTiger.health <= 0` stops the chase

---

## 🟡 MEDIUM-PRIORITY ISSUES

### 7. **Inventory Duplication Risk**
**Location:** entities/player.lua  
**Severity:** 🟡 MEDIUM - Economy breaking  

**Problem:** When save/load is re-enabled:
```lua
-- What if player has inventory from gameplay
-- Then loads a save with different inventory?
-- Does it merge or replace?
```

**Current Code:**
```lua
if savedData.player.inventory then
    playerEntity.inventory = savedData.player.inventory -- Full replacement
end
```

**Issue:** If player picks up items between death and reload, those items are lost. But this is actually correct behavior.

**Potential Issue:** If save system is called multiple times rapidly (e.g., spam F5 to save), could corrupt data

**Solution:** Add save cooldown/debounce

---

### 8. **DayNight Time Can Go Negative**
**Location:** systems/daynight.lua  
**Severity:** 🟡 MEDIUM - Time corruption  

**Problem:** Need to verify:
```lua
-- If time decreases faster than it increases
-- Or if manual time adjustment sets negative values
daynightSystem.time = daynightSystem.time - someValue
```

**Solution:** Always clamp time:
```lua
daynightSystem.time = math.max(0, math.min(24, daynightSystem.time))
```

---

### 9. **Camera Target Can Be Nil**
**Location:** main.lua:179  
**Severity:** 🟡 MEDIUM - Visual glitch  

**Problem:**
```lua
if Game.camera.setTarget then
    Game.camera:setTarget({x = playerSystem.x, y = playerSystem.y})
end
```

**Issue:** If `playerSystem.x` or `playerSystem.y` is nil, camera gets {x=nil, y=nil}

**Better:**
```lua
if Game.camera.setTarget and playerSystem.x and playerSystem.y then
    Game.camera:setTarget({x = playerSystem.x, y = playerSystem.y})
end
```

---

### 10. **Foraging Spawn Position Not Validated**
**Location:** systems/foraging.lua  
**Severity:** 🟡 MEDIUM - Collision issues  

**Problem:** When foraging items spawn, are they checked against:
- Hunting zone boundaries?
- Structure positions?
- Player position (avoid spawning on top of player)?

**Risk:** Items spawn in inaccessible locations

---

## 🔵 LOW-PRIORITY / POLISH ISSUES

### 11. **Magic Numbers Everywhere**
**Severity:** 🔵 LOW - Code maintainability  

**Examples:**
```lua
-- states/hunting.lua:117
tiger.spawnChance = 0.95 -- TESTING VALUE - should be constant

-- states/hunting.lua:343
if #hunting.animals < 3 and math.random() < 0.005 then -- Magic numbers

-- systems/world.lua:85
radius = 80, -- Hardcoded radius
```

**Solution:** Create constants file:
```lua
-- constants.lua
return {
    HUNTING = {
        MAX_ANIMALS = 3,
        SPAWN_CHANCE = 0.005,
        TIGER_SPAWN_CHANCE_TESTING = 0.95,
        TIGER_SPAWN_CHANCE_NORMAL = 0.05,
    },
    ZONES = {
        HUNTING_RADIUS = 80,
    }
}
```

---

### 12. **No Error Handling in Require Statements**
**Severity:** 🔵 LOW - Debugging difficulty  

**Problem:**
```lua
local worldSystem = require("systems/world")
-- If file doesn't exist, cryptic error
```

**Better:**
```lua
local success, worldSystem = pcall(require, "systems/world")
if not success then
    error("❌ CRITICAL: Failed to load world system - " .. tostring(worldSystem))
end
```

---

### 13. **Projectile Cleanup Never Happens**
**Location:** states/hunting.lua:309  
**Severity:** 🔵 LOW - Minor memory leak  

**Problem:**
```lua
-- Projectiles update but what if they go off-screen?
-- Do they get removed or keep moving forever?
```

**Check:** Verify projectiles are removed when:
- They hit an animal
- They travel max distance
- They go off-screen

---

## 📊 PRIORITY RANKING

| Issue # | Severity | Priority | Fix Time | Impact |
|---------|----------|----------|----------|--------|
| 1 | 🔴 CRITICAL | **P0** | 30 min | Save corruption |
| 2 | 🔴 CRITICAL | **P0** | 15 min | Potential crash |
| 3 | 🟠 HIGH | **P1** | 10 min | Crash on error |
| 4 | 🟠 HIGH | **P1** | 5 min | Visual glitch |
| 5 | 🟠 HIGH | **P1** | 20 min | Performance |
| 6 | 🟡 MEDIUM | **P2** | 15 min | Logic error |
| 7 | 🟡 MEDIUM | **P2** | 30 min | Economy |
| 8 | 🟡 MEDIUM | **P2** | 5 min | Time corruption |
| 9 | 🟡 MEDIUM | **P2** | 5 min | Visual glitch |
| 10 | 🟡 MEDIUM | **P2** | 20 min | Collision |
| 11 | 🔵 LOW | **P3** | 60 min | Maintainability |
| 12 | 🔵 LOW | **P3** | 30 min | Debugging |
| 13 | 🔵 LOW | **P3** | 10 min | Memory |

---

## 🎯 RECOMMENDED FIX ORDER

### Phase 1: Critical Fixes (Today)
1. **Issue #1** - Reset tiger blocked areas on day change
2. **Issue #2** - Fix animal removal loop pattern
3. **Issue #3** - Add nil checks for system updates

### Phase 2: High-Priority (This Week)
4. **Issue #4** - Add division by zero protection
5. **Issue #5** - Add spawn cooldown system
6. **Issue #6** - Verify tiger chase death checks

### Phase 3: Medium-Priority (Next Week)
7. **Issue #7-10** - Polish gameplay mechanics

### Phase 4: Low-Priority (When Time Permits)
8. **Issue #11-13** - Code quality improvements

---

## 🧪 TESTING CHECKLIST

After fixes, test:
- [ ] Play for 10+ days - verify tiger areas unblock
- [ ] Kill all animals rapidly - check for crashes
- [ ] Manually set worldSystem = nil - verify graceful handling
- [ ] Spawn animals with 0 max health - verify no division errors
- [ ] Let spawn attempts fail repeatedly - check FPS stays stable
- [ ] Kill tiger while being chased - verify chase stops
- [ ] Save/load multiple times - verify no duplication
- [ ] Manually set negative time - verify clamping works
- [ ] Teleport player far away - verify camera follows
- [ ] Play for extended period - check for memory leaks

---

## 💡 ARCHITECTURAL IMPROVEMENTS (Future)

1. **Event System** - Replace direct function calls with event bus
2. **State Validation** - Add assertions for critical state
3. **Constants File** - Centralize all magic numbers
4. **Error Boundaries** - Wrap all system updates in pcall
5. **Debug Commands** - Add F-key shortcuts for testing edge cases
6. **Logging System** - Replace print with proper logger
7. **Save Validation** - Checksum save files to detect corruption
8. **Unit Tests** - Test critical functions in isolation

---

## 📝 NOTES

- Most issues are **preventive** - they haven't caused crashes yet
- Code is generally well-structured
- Main risks are edge cases and long-term play
- Save/load system is the biggest risk area when re-enabled

**Next Steps:**
1. Review this analysis with team
2. Prioritize fixes based on timeline
3. Implement Phase 1 critical fixes immediately
4. Create GitHub issues for tracking
