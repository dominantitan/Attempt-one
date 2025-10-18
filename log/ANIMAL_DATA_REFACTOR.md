# Animal Data Refactoring

**Date:** October 17, 2025  
**Issue:** Duplicate animal data tables (bad coding practice)  
**Status:** ✅ FIXED

## Problem

The game had **two separate animal data tables**:
1. `entities/animals.lua` - Used for overworld animals
2. `states/hunting.lua` - Had `hunting.animalTypes` for hunting minigame

This violates the **DRY principle** (Don't Repeat Yourself) and causes:
- ❌ Code duplication
- ❌ Inconsistent data (changes need to be made in 2 places)
- ❌ Maintenance nightmare
- ❌ Bugs from forgetting to update both places

## Solution

**Consolidated animal data into `entities/animals.lua` as the SINGLE SOURCE OF TRUTH**

### Changes Made

#### 1. `entities/animals.lua` - Enhanced Structure
```lua
animals.types = {
    rabbit = {
        -- Overworld stats (existing)
        size = {16, 12},
        speed = 80,
        health = 20,
        meat = 2,
        color = {0.8, 0.7, 0.5},
        
        -- Hunting minigame stats (NEW)
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
    -- ... (same for deer, boar, tiger)
}
```

#### 2. `states/hunting.lua` - Reference Centralized Data
**BEFORE:**
```lua
-- Duplicate animal definitions (150+ lines of code)
hunting.animalTypes = {
    rabbit = { ... },
    deer = { ... },
    boar = { ... },
    tiger = { ... }
}
```

**AFTER:**
```lua
-- Import centralized animal data
local animalsEntity = require("entities/animals")

-- Reference the huntingStats from centralized data
hunting.animalTypes = {}
for animalType, data in pairs(animalsEntity.types) do
    if data.huntingStats then
        hunting.animalTypes[animalType] = data.huntingStats
    end
end
```

## Benefits

✅ **Single Source of Truth** - One place to update animal data  
✅ **DRY Principle** - No code duplication  
✅ **Maintainability** - Changes only needed in one file  
✅ **Consistency** - Overworld and hunting stats stay in sync  
✅ **Cleaner Code** - Reduced code by ~150 lines in hunting.lua  
✅ **Better Organization** - All animal data logically grouped in entities/  

## Testing

- ✅ Game launches successfully
- ✅ No runtime errors
- ✅ Hunting minigame works with centralized data
- ✅ Animals spawn correctly with proper names
- ✅ **VERIFIED:** Entered hunting area, deer spawned with "🦌 Deer appeared nearby"

## Bug Fix During Refactoring

**Issue:** Initial refactoring caused error when spawning animals:
```
states/hunting.lua:469: attempt to concatenate field 'name' (a nil value)
```

**Root Cause:** The `huntingStats` subtable didn't include the `name` field, which was in the parent `animals.types` table.

**Solution:** Modified the data loading to copy `name` from parent:
```lua
hunting.animalTypes = {}
for animalType, data in pairs(animalsEntity.types) do
    if data.huntingStats then
        local stats = {}
        for k, v in pairs(data.huntingStats) do
            stats[k] = v
        end
        stats.name = data.name -- Add name from parent
        hunting.animalTypes[animalType] = stats
    end
end
```

## Future Improvements

1. **Consider separating concerns further:**
   - Create `entities/animals/overworld.lua` for overworld-specific behavior
   - Create `entities/animals/hunting.lua` for hunting-specific behavior
   - Keep `entities/animals.lua` as the data-only module

2. **Add validation:**
   - Ensure all animals have both overworld and hunting stats
   - Add schema validation for animal data structure

3. **Consider JSON/external data:**
   - Move animal stats to a JSON file for easy balancing
   - Allow modding by loading from external files

## Code Quality Score

**Before:** ⭐⭐ (Poor - duplicate data)  
**After:** ⭐⭐⭐⭐ (Good - centralized with clean references)

## Related Files

- `entities/animals.lua` - Animal data source of truth (MODIFIED)
- `states/hunting.lua` - Hunting minigame (MODIFIED to reference centralized data)
- `systems/world.lua` - Uses animals.lua (NO CHANGES NEEDED)
- `states/gameplay.lua` - Uses animals.lua (NO CHANGES NEEDED)
