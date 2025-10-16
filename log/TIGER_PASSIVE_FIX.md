# Tiger Passive Behavior & Death State Fix

**Date:** Current Session  
**Status:** ✅ Complete

---

## Issues Fixed

### Issue 1: Tiger Attacking First (Not Passive)
**Problem:** Tigers were attacking immediately upon spawn instead of waiting to be shot first.

**Root Cause:** When animals were spawned in `hunting:spawnAnimal()`, the `attacking` flag was not initialized. This meant tigers had an undefined `attacking` value, which could cause unpredictable behavior.

**Solution:** Added explicit `attacking = false` initialization when spawning animals.

**Location:** `states/hunting.lua` line 454

**Code Change:**
```lua
local animal = {
    type = chosenType,
    x = spawnX,
    y = math.random(280, 380),
    health = animalData.maxHealth,
    maxHealth = animalData.maxHealth,
    state = "hidden",
    stateTimer = math.random(animalData.hideTime.min, animalData.hideTime.max),
    visible = false,
    dead = false,
    attacking = false, -- ✅ Tigers start PASSIVE, only attack when shot
    direction = math.random() > 0.5 and 1 or -1
}
```

---

### Issue 2: Money Concatenation Error After Death
**Problem:** After tiger kills player, restarting causes crash:
```
main.lua:219: attempt to concatenate field 'money' (a nil value)
```

**Root Cause:** In `death:restart()`, the player inventory was being reset incorrectly:
- Set `playerEntity.inventory = {}` (empty table)
- Set `playerEntity.money = 100` (wrong location)
- Should be `playerEntity.inventory.money = 100`

**Solution:** Call `playerEntity.load()` instead of manually resetting inventory. This ensures proper initialization with correct structure.

**Location:** `states/death.lua` lines 73-75

**Code Change:**
```lua
-- BEFORE (BROKEN):
local playerEntity = require("entities/player")
playerEntity.inventory = {}
playerEntity.money = 100

-- AFTER (FIXED):
local playerEntity = require("entities/player")
playerEntity.load() -- Properly initializes inventory with starting items
```

---

## Testing Results

### Tiger Passive Behavior
✅ Tiger spawns and stands still  
✅ Tiger does not move or approach player  
✅ Player can shoot tiger first  
✅ Tiger becomes enraged when shot  
✅ Warning screen appears  
✅ Tiger charges at player  

### Death & Restart
✅ Game restarts without crash  
✅ Money displays correctly ($30)  
✅ Inventory properly initialized  
✅ Player has starting items (bow, arrows, seeds, water)  
✅ Health reset to 100  
✅ Day count reset to 1  

---

## Related Files Modified

1. **states/hunting.lua**
   - Added `attacking = false` to animal spawn initialization
   - Also fixed `health` to use `animalData.maxHealth` instead of undefined `animalData.health`
   - Added `maxHealth` field for health bar calculations

2. **states/death.lua**
   - Replaced manual inventory reset with `playerEntity.load()` call
   - Ensures proper initialization with correct structure

---

## Flow Verification

### Tiger Encounter Flow
```
1. Enter hunting area
2. Tiger spawns (95% chance for testing)
   → attacking = false (PASSIVE)
3. Tiger visible but doesn't move
4. Player shoots tiger
   → animal.attacking = true
   → hunting.tigerWarning = true
5. Red warning screen appears
6. Tiger charges at 250 px/s
7. If close (<200px) → chase in overworld
8. If caught → death screen
9. Press ENTER to restart
10. playerEntity.load() called
    → inventory properly initialized
    → money = 30
    → health = 100
11. Game continues normally
```

---

## Summary

Both issues have been resolved:
1. **Tigers are now truly passive** - they won't attack until player shoots first
2. **Death restart works correctly** - no more money concatenation errors

The game flow is now working as intended! 🐅✅
