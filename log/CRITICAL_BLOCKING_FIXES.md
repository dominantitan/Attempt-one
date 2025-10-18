# Critical Blocking Fixes - October 18, 2025

## User-Reported Issues
1. **Tiger blocking happens without seeing a tiger** - Area gets blocked every time you exit hunting
2. **Sleeping doesn't advance the day** - Day number stays the same after sleeping

---

## Bug #1: Tiger Blocking Without Encounter

### Root Cause
Tiger blocking was triggered when tiger **spawned** (invisible), not when player **saw** it.

**Original Code (hunting.lua:465):**
```lua
-- BLOCK THIS AREA UNTIL NEXT DAY!
if chosenType == "tiger" then
    Game.tigerBlockedAreas[hunting.currentArea] = currentDay
    print("🚫 Area is now BLOCKED until next day!")
end
```

This ran immediately after spawn calculation, before the tiger was ever visible.

### The Fix
**Moved blocking logic to state transition** (hunting.lua:383-398):
- Only block when tiger changes from "hidden" → "visible" state
- Player now sees the tiger before area gets blocked
- Added `animal.blockingLogged` flag to prevent duplicate logs

**New Code:**
```lua
if animal.state == "hidden" then
    if animal.stateTimer <= 0 then
        animal.state = "visible"
        animal.visible = true
        
        -- TIGER BLOCKING: Only when tiger APPEARS
        if animal.type == "tiger" and not animal.blockingLogged then
            print("🐅 TIGER APPEARS! DANGEROUS!")
            Game.tigerBlockedAreas[hunting.currentArea] = currentDay
            animal.blockingLogged = true
            print("🚫 " .. hunting.currentArea .. " is now BLOCKED!")
        end
    end
end
```

### Impact
✅ Tiger blocking now requires actual tiger encounter  
✅ Players see warning when tiger appears  
✅ Can hunt normally without invisible blocking  
✅ Area only blocks if tiger becomes visible during session  

---

## Bug #2: Sleep Not Advancing Day

### Root Cause
`sleepInBed()` only changed time to morning (0.25) without incrementing `dayCount`.

**Original Code (gameplay.lua:505-514):**
```lua
function gameplay:sleepInBed(playerEntity, daynightSystem)
    playerEntity.heal(100)
    playerEntity.rest(100)
    
    daynightSystem.time = 0.25 -- Set to morning
    -- ❌ dayCount NOT incremented!
    
    print("💤 You sleep comfortably")
end
```

Day only advanced when time naturally crossed 1.0 (midnight), which takes 5 real minutes.

### The Fix
**Added day increment and blocking reset** (gameplay.lua:505-522):

```lua
function gameplay:sleepInBed(playerEntity, daynightSystem)
    playerEntity.heal(100)
    playerEntity.rest(100)
    
    -- Advance to next day
    local previousDay = daynightSystem.dayCount
    daynightSystem.dayCount = daynightSystem.dayCount + 1  -- ✅ INCREMENT DAY
    daynightSystem.time = 0.25
    
    -- Clear tiger blocked areas on new day
    if Game and Game.tigerBlockedAreas then
        Game.tigerBlockedAreas = {}  -- ✅ RESET BLOCKING
        print("🐅 Tiger blocked areas cleared for new day")
    end
    
    print("💤 You sleep comfortably in your uncle's bed")
    print("❤️  Health and stamina fully restored!")
    print("🌅 Day " .. previousDay .. " → Day " .. daynightSystem.dayCount)
    print("🗓️  A new day begins!")
end
```

### Impact
✅ Sleeping now properly advances to next day  
✅ Day counter increments immediately  
✅ Tiger blocked areas reset on sleep  
✅ Clear feedback showing day change (Day 0 → Day 1)  

---

## Testing Instructions

### Test Tiger Blocking (5 minutes)
1. Start game (Day 0)
2. Enter hunting area (North Forest)
3. Wait for animal to appear
4. **If tiger appears:** Area should block, see warning
5. **If no tiger:** No blocking, can re-enter freely
6. Exit and sleep
7. Day should advance to Day 1
8. Hunting area should be accessible again

### Test Day Advancement (2 minutes)
1. Note current day number (top right)
2. Enter cabin
3. Walk to bed
4. Press Z to sleep
5. Verify console shows "Day X → Day Y"
6. Verify day number increased by 1
7. Verify "Tiger blocked areas cleared" message

### Expected Console Output
```
🐅 TIGER APPEARS! DANGEROUS!
⚠️  This animal will attack you!
═══════════════════════════════════════
🚫 North Forest is now BLOCKED until next day!
🗓️  Current day: 0
🗺️  You'll need to hunt in a different area today!

[Later, after sleeping...]
💤 You sleep comfortably in your uncle's bed
🐅 Tiger blocked areas cleared for new day
❤️  Health and stamina fully restored!
🌅 Day 0 → Day 1
🗓️  A new day begins!
```

---

## Related Systems

### Day/Night Cycle (systems/daynight.lua)
- Still resets `tigerBlockedAreas` at natural midnight (time >= 1.0)
- Both natural progression and sleep now reset blocking
- Redundant but safe - ensures blocking always clears

### Hunting State (states/hunting.lua)
- Tiger spawn rate: 5% day, 20% night (4x multiplier)
- Tigers may spawn but not appear during session
- Only visible tigers trigger blocking

### Blocking Check (states/gameplay.lua:205-227)
- Compares `blockedDay == currentDay`
- Incremented day breaks equality check
- Area becomes accessible again

---

## Files Modified
1. **states/hunting.lua** (lines 453-455, 383-398)
   - Removed blocking from spawn logic
   - Added blocking to visibility state transition
   
2. **states/gameplay.lua** (lines 505-522)
   - Added dayCount increment
   - Added tiger blocking reset
   - Enhanced console feedback

---

## Status
✅ **BOTH BUGS FIXED**
- Tiger blocking requires actual encounter
- Sleep properly advances day and resets blocking
- Ready for ammo testing workflow

---

## Next Steps
1. **Test fixes** with instructions above
2. **Ammo testing** can now proceed properly:
   - Enter hunting with 10 arrows
   - Shoot 3 times
   - Exit and verify 7 arrows remain
   - Re-enter and verify ammo persists
3. **Continue feature development** after validation
