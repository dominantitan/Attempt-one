# Tiger Passive & Area Blocking System Fix

**Date:** Current Session  
**Status:** ✅ Complete

---

## Issues Fixed

### Issue 1: Tiger Attacking First (Not Truly Passive)
**Problem:** Tigers were triggering the chase sequence even when not provoked because the proximity check didn't verify if the tiger was actually attacking.

**Root Cause:** 
- In `hunting:update()`, the tiger proximity check (lines 265-276) didn't check `animal.attacking`
- The check triggered if ANY tiger (passive or attacking) got within 150-200px
- Since passive tigers spawn and stand still, if they happened to spawn near the player, it would trigger the chase immediately

**Solution:** Added `and animal.attacking` to the proximity check condition.

**Location:** `states/hunting.lua` line 267

**Code Change:**
```lua
-- BEFORE (BROKEN):
if animal.type == "tiger" and animal.visible and not animal.dead then

-- AFTER (FIXED):
if animal.type == "tiger" and animal.visible and not animal.dead and animal.attacking then
```

---

### Issue 2: Tiger Blocks Area Until Next Day
**Problem:** Need to prevent players from re-entering hunting areas where tigers have spawned until the next day passes.

**Solution:** Implemented a global area blocking system:

1. **Tracking System** (`states/hunting.lua` lines 15-17):
   - Added `Game.tigerBlockedAreas` table to track blocked hunting zones
   - Format: `{areaId = dayNumber}` - stores which day the tiger was encountered
   - Persists across state changes

2. **Area Tracking** (`states/hunting.lua` lines 149-151):
   - Added `hunting.currentArea` to track which zone player entered
   - Passed as parameter from `gamestate.switch("hunting", zoneId)`

3. **Block on Tiger Spawn** (`states/hunting.lua` lines 441-449):
   - When tiger spawns, marks current area as blocked
   - Stores current day number from `daynightSystem.dayCount`
   - Shows warning messages to player

4. **Entry Prevention** (`states/gameplay.lua` lines 177-199):
   - Checks if zone is blocked before allowing entry
   - Compares `Game.tigerBlockedAreas[zoneId]` with current day
   - Shows red "BLOCKED" message if tiger encountered today
   - Prevents `gamestate.switch()` call if blocked

5. **Visual Indicator** (`states/gameplay.lua` lines 58-80):
   - Draw function shows red "🚫 BLOCKED" message instead of hunt prompt
   - Players can see blocked status without trying to enter

---

## Technical Details

### Tiger Passive Flow
```
1. Tiger spawns with attacking=false
2. Tiger uses "passive" behavior (doesn't move)
3. Player shoots tiger
   → animal.attacking=true
   → hunting.tigerWarning=true (red screen)
4. Tiger charges at player (attackSpeed=250)
5. IF tiger gets within 200px AND animal.attacking==true
   → Triggers overworld chase
6. Player must escape to house or die
```

### Area Blocking Flow
```
1. Player enters hunting zone "hunting_southeast"
2. hunting.currentArea = "hunting_southeast"
3. Tiger spawns (5% chance, 95% for testing)
4. Game.tigerBlockedAreas["hunting_southeast"] = 1 (day 1)
5. Player leaves/dies/escapes
6. Player returns to same zone
7. Check: blockedDay==currentDay? → YES (both day 1)
8. Entry denied: "🚫 AREA BLOCKED!"
9. Next day arrives: dayCount=2
10. Check: blockedDay==currentDay? → NO (1≠2)
11. Entry allowed: Area is safe again
```

### Hunting Zone IDs
```
hunting_northwest = "Northwestern Woods" (REMOVED - railway station)
hunting_northeast = "Northeastern Grove" (Rabbit, Boar, Tiger)
hunting_southeast = "Southeastern Wilderness" (Boar, Tiger)
```

---

## Code Changes

### 1. states/hunting.lua
**Added global tracking (lines 12-17):**
```lua
hunting.currentArea = nil -- Track which hunting area we're in

-- Tiger encounter tracking (blocks areas until next day)
if not Game then Game = {} end
if not Game.tigerBlockedAreas then Game.tigerBlockedAreas = {} end
```

**Track area on entry (lines 149-151):**
```lua
-- Track which hunting area we entered from
hunting.currentArea = entryPoint or "unknown"
print("🗺️  Entered hunting area: " .. hunting.currentArea)
```

**Mark area when tiger spawns (lines 441-449):**
```lua
if chosenType == "tiger" then
    -- ... existing warning ...
    
    -- BLOCK THIS AREA UNTIL NEXT DAY!
    local daynightSystem = require("systems/daynight")
    local currentDay = daynightSystem.dayCount or 1
    Game.tigerBlockedAreas[hunting.currentArea] = currentDay
    print("🚫 " .. hunting.currentArea .. " is now BLOCKED until next day!")
end
```

**Fix tiger proximity check (line 267):**
```lua
if animal.type == "tiger" and animal.visible and not animal.dead and animal.attacking then
```

### 2. states/gameplay.lua
**Check blocking before entry (lines 177-199):**
```lua
if nearHuntingZone then
    -- Check if this hunting zone is blocked by a tiger encounter
    local daynightSystem = require("systems/daynight")
    local currentDay = daynightSystem.dayCount or 1
    local zoneId = nearHuntingZone.target or nearHuntingZone.name
    local blockedDay = Game.tigerBlockedAreas[zoneId]
    
    if blockedDay and blockedDay == currentDay then
        -- Show warning and prevent entry
        print("🚫 AREA BLOCKED! Try a different hunting area!")
        return
    end
    
    -- Pass zone ID to hunting state
    gamestate.switch("hunting", zoneId)
end
```

**Visual blocked indicator (lines 58-80):**
```lua
if nearHuntingZone then
    local zoneId = nearHuntingZone.target or nearHuntingZone.name
    local blockedDay = Game.tigerBlockedAreas[zoneId]
    
    if blockedDay and blockedDay == currentDay then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("🚫 " .. nearHuntingZone.name .. ": BLOCKED (Tiger sighting today!)", ...)
    else
        love.graphics.setColor(0.9, 0.7, 0.3)
        love.graphics.print("🎯 " .. nearHuntingZone.name .. ": Press ENTER to hunt", ...)
    end
end
```

---

## Testing

### Test Case 1: Tiger Passive Behavior
1. Enter hunting zone
2. Wait for tiger to spawn (95% chance)
3. **Expected:** Tiger stands still, doesn't approach
4. Shoot the tiger
5. **Expected:** Red warning screen appears
6. **Expected:** Tiger charges toward player
7. **Expected:** Chase triggers when tiger gets within 200px

✅ **Result:** Tigers are now truly passive until provoked

### Test Case 2: Area Blocking
1. Enter "Southeastern Wilderness"
2. Tiger spawns (95% chance)
3. Leave the area (exit or get caught)
4. Return to same zone
5. **Expected:** Red "🚫 BLOCKED" message, entry denied
6. Try other zones
7. **Expected:** Other zones work normally
8. Sleep/wait until next day
9. Return to blocked zone
10. **Expected:** Entry allowed, zone is safe again

✅ **Result:** Area blocking works correctly

---

## Game Balance Impact

### Strategic Depth
- **Before:** Players could farm the same hunting area repeatedly
- **After:** Tiger encounters force rotation between multiple hunting zones
- **Effect:** More exploration, risk/reward decisions

### Multiple Hunting Zones
- Players MUST use different zones if tiger appears
- Encourages learning all three hunting areas
- Prevents over-farming a single safe zone

### Tiger Rarity
- **Testing:** 95% spawn rate (very high)
- **Production:** 5% spawn rate (rare but impactful)
- **Impact:** Occasional area rotation, not constant

---

## Known Limitations

1. **Area block persists even if tiger is killed**
   - Could add: Clear block if tiger is killed before triggering chase
   - Current: Simple and punishing - any tiger encounter blocks area

2. **No visual indicator on map**
   - Could add: Red X or warning icon on blocked hunting zone circles
   - Current: Only shows when player approaches zone

3. **Blocks persist through game restarts** (if Game table saved)
   - Could add: Clear all blocks on new game
   - Current: Blocks are session-based (cleared on restart)

---

## Future Enhancements

1. **Kill-based unblocking:**
   - If player kills tiger before chase triggers → don't block area
   - Reward for quick kills

2. **Map indicators:**
   - Red overlay on blocked hunting zones
   - Show "BLOCKED" label on map

3. **Timed blocks:**
   - Tiger encounter at 10 AM → blocked until 6 PM
   - Allows return on same day after time passes

4. **Multiple tiers:**
   - Yellow warning: Tiger spotted but not aggressive
   - Red block: Tiger attacked player

---

## Summary

Both issues are now resolved:
1. **Tigers are truly passive** - won't trigger chase unless `animal.attacking==true`
2. **Areas block after tiger encounters** - forces strategic hunting zone rotation

This creates interesting gameplay:
- Tigers are dangerous but fair (you must shoot first)
- Encounter a tiger → blocked from that area for rest of day
- Must use multiple hunting zones → more exploration
- Adds risk/reward: High-tier zones have tigers, but better loot

**Game is now more strategic and fair!** 🐅✅
