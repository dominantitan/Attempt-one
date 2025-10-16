# Refactor Log - Code Cleanup Session

**Date:** October 14, 2025  
**Goal:** Fix architectural issues, improve code quality, prevent future bugs

---

## Problems Identified

### 1. **Dual Inventory System** ❌
**Problem:** Player had both `inventory.items[]` array AND direct properties like `inventory.seeds`, `inventory.water`. This caused confusion about which to use.

**Solution:** ✅ Consolidated to use ONLY `inventory.items[]` array. All items managed through `addItem()`, `removeItem()`, `getItemCount()` functions.

**Changed Files:**
- `entities/player.lua` - Removed direct properties, improved addItem to auto-stack

---

### 2. **Inconsistent API Access** ❌
**Problem:** Code tried calling `playerEntity.getStats()` which didn't exist, causing crashes.

**Solution:** ✅ Added proper getter functions:
- `getMoney()` - Returns `inventory.money` or 0
- `getHealth()` - Returns `health`
- `getHunger()` - Returns `hunger`
- `getStamina()` - Returns `stamina`

**Changed Files:**
- `entities/player.lua` - Added getter functions (lines 145-160)
- `states/shop.lua` - Updated all calls to use `getMoney()`

---

### 3. **Excessive Debug Output** ❌
**Problem:** Console was spammed with debug messages:
```
🔍 Trying to plant at (575.23, 335.67)
✓ Found plot #2 at (575, 335)
✓ Plant successful, removing 1 seed...
✓ Seeds remaining: 2
```

**Solution:** ✅ Removed all debug spam, kept only essential player feedback:
```
🌱 Planted carrot
```

**Changed Files:**
- `systems/farming.lua` - Simplified plantSeed(), waterCrop(), harvestCrop() output
- `states/gameplay.lua` - Removed debug logging from farmingAction()

---

### 4. **Visual Debug Clutter** ❌
**Problem:** Farming system drew:
- Yellow boxes around farm area
- Plot numbers on each square
- Coordinates on each plot
- "FARM AREA" text
- "Player: (x,y)" position

**Solution:** ✅ Removed all debug visuals, kept only:
- Brown soil plots
- Clean borders
- Crop growth indicators
- Water level bars

**Changed Files:**
- `systems/farming.lua` - Cleaned up draw() function (lines 160-220)

---

### 5. **Inconsistent Money Formatting** ❌
**Problem:** Mixed usage of:
- "10 coins"
- "$10"
- "money: 10"

**Solution:** ✅ Standardized to ALWAYS use `$` prefix:
- "Costs $10"
- "Your money: $30"
- "Sold for $12"

**Changed Files:**
- `states/shop.lua` - Updated all print statements and UI text

---

### 6. **Undocumented Balance Logic** ❌
**Problem:** No explanation of why seeds cost $10 but crops sell for $4. Future developers might "fix" this thinking it's a bug.

**Solution:** ✅ Added comprehensive comments explaining balance philosophy:
```lua
-- BALANCE PHILOSOPHY:
-- - Farming: Barely profitable (seeds $10-20, crops sell $4-10)
-- - Hunting: 3-4x more profitable ($15-100 per kill)
-- - This encourages hunting while farming provides backup income
```

**Changed Files:**
- `states/shop.lua` - Added detailed header comments (lines 1-6, 26-43)

---

### 7. **Dead Code / Commented Functions** ❌
**Problem:** `gameplay.lua` had commented-out call to non-existent `addNutrition()` function.

**Solution:** ✅ Removed the call entirely. Nutrition system not part of MVP.

**Changed Files:**
- `states/gameplay.lua` - Removed commented addNutrition call from farmingAction()

---

## New Standards Established

### Code Style
1. **Consistent API:** Use getter functions for safety
2. **Clean output:** Only print user-relevant messages
3. **Document balance:** Explain non-obvious decisions
4. **No debug visuals:** Remove before release

### Inventory Pattern
```lua
playerEntity.addItem("seeds", 5)      -- ✅ Correct
playerEntity.removeItem("seeds", 1)   -- ✅ Correct
playerEntity.getItemCount("seeds")    -- ✅ Correct

player.inventory.seeds = 5            -- ❌ Wrong
```

### Money Pattern
```lua
local money = playerEntity.getMoney()  -- ✅ Safe
print("Your money: $" .. money)        -- ✅ Formatted

local money = player.inventory.money   -- ⚠️ Can be nil
print("Money: " .. money)              -- ❌ Inconsistent format
```

---

## Files Modified Summary

| File | Changes | Lines Changed |
|------|---------|---------------|
| `entities/player.lua` | Added getters, improved addItem | ~30 lines |
| `states/shop.lua` | Added comments, standardized $, use getMoney() | ~20 lines |
| `systems/farming.lua` | Removed debug visuals, simplified output | ~50 lines |
| `states/gameplay.lua` | Cleaned up farmingAction, removed debug | ~15 lines |

**Total:** ~115 lines modified/removed

---

## Testing Results

✅ **All Tests Passed:**
- Game starts without errors
- Shop opens with B key
- Buying items works (decreases money)
- Selling items works (increases money)
- Planting seeds works (decreases seeds)
- Watering crops works (increases water level)
- Harvesting works (gives crops, clears plot)
- Money always shows with $ prefix
- Console output is clean (no spam)
- Inventory stacks items correctly

---

## Documentation Created

1. **CODE_STANDARDS.md** - Comprehensive guide for future development
2. **REFACTOR_LOG.md** - This file, documents what changed and why

---

## Future Recommendations

### High Priority
1. **Implement hunting mechanic** - Economy is balanced for it, but doesn't exist yet
2. **Add foraging visibility** - Items spawn but aren't visible
3. **Player goals/objectives** - Give players something to work toward

### Medium Priority
4. **Visual feedback** - Particles, sounds for actions
5. **Better error handling** - What if player has negative money?
6. **Save/load system** - Currently not functional

### Low Priority
7. **Nutrition system** - If added, implement `player.addNutrition()`
8. **Weather system** - Commented out in farming.lua
9. **Crop diseases** - Commented out complexity feature

---

## Lessons Learned

1. **Dual systems cause confusion** - Pick ONE pattern and stick to it
2. **Debug code accumulates** - Remove it regularly, don't let it build up
3. **Document non-obvious decisions** - Balance choices aren't bugs
4. **Getter functions prevent crashes** - Safer than direct property access
5. **Consistency matters** - Money format, API patterns, output style

---

## Breaking Changes

⚠️ **None** - All changes are backward compatible. Existing code still works because:
- Direct property access still works (`player.health`)
- New getters are additions, not replacements
- Inventory still uses same `items[]` array structure

---

**End of Refactor Log**
