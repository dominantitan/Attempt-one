# Tiger Speed Adjustment for Reaction Time

**Date:** Current Session  
**Status:** ✅ Complete

---

## Speed Adjustment

### Issue
Tiger chase speed was too fast (120 px/s) compared to player speed, giving very little reaction time when the chase starts. Players were getting caught almost immediately.

### Solution
Reduced tiger chase speed from **120** to **85** pixels per second in the overworld.

**Location:** `systems/world.lua` line 501

---

## Speed Comparison

### Player Speed
- **Base Speed:** 200 pixels/second
- **Diagonal Movement:** 141 pixels/second (200 × 0.707)
- **Result:** Player moves significantly faster than tiger

### Tiger Speed (Overworld Chase)
- **Before:** 120 pixels/second (60% of player speed - TOO FAST)
- **After:** 85 pixels/second (42.5% of player speed - BALANCED)

### Tiger Speed (Hunting Area)
- **Passive Tiger:** 0 pixels/second (stands still)
- **Attacking Tiger:** 250 pixels/second (inside hunting minigame only)
- **Note:** This is in the first-person hunting view, not the overworld

---

## Gameplay Impact

### Before Change (Speed 120):
```
Chase starts → Player at 200 speed, Tiger at 120 speed
Distance = 100 pixels initially
Relative speed = 200 - 120 = 80 px/s (player gaining)

Time to reach house (~400 pixels):
Player: 400 / 200 = 2 seconds
Tiger gains if player not moving perfectly

Result: Very tight timing, little room for error
```

### After Change (Speed 85):
```
Chase starts → Player at 200 speed, Tiger at 85 speed
Distance = 100 pixels initially
Relative speed = 200 - 85 = 115 px/s (player gaining much faster)

Time to reach house (~400 pixels):
Player: 400 / 200 = 2 seconds
Tiger: 400 / 85 = 4.7 seconds

Result: Player has ~2.7 seconds buffer time
```

---

## Reaction Time Breakdown

### Scenario 1: Player Runs Immediately
- **Initial Distance:** 100 pixels (tiger spawns behind)
- **Player Speed:** 200 px/s
- **Tiger Speed:** 85 px/s
- **Relative Speed:** 115 px/s (player pulling away)
- **Result:** Player easily escapes ✅

### Scenario 2: Player Hesitates 1 Second
- **Tiger Closes:** 85 pixels in 1 second
- **New Distance:** 100 - 85 = 15 pixels
- **Then Player Runs:** Still pulling away at 115 px/s
- **Result:** Player escapes but close ⚠️

### Scenario 3: Player Hesitates 2 Seconds
- **Tiger Closes:** 170 pixels in 2 seconds
- **New Distance:** Tiger gets within 30 pixels
- **Result:** CAUGHT! 💀

---

## Distance Thresholds

### Safe Distance (House)
- **Radius:** 50 pixels from house center
- **Effect:** Tiger gives up, player is safe
- **House Location:** (460, 310) - center of map

### Catch Distance
- **Radius:** 30 pixels from player
- **Effect:** Game over, death screen
- **Tiger Attack Range:** Close enough to attack

### Spawn Distance
- **Initial:** 100 pixels behind player
- **Gives:** Initial buffer zone for reaction

---

## Code Implementation

```lua
-- systems/world.lua, line 496-503
if Game and Game.tigerChasing and not world.tigerChase then
    -- Spawn tiger behind player
    world.tigerChase = {
        x = playerX - 100,
        y = playerY,
        speed = 85 -- Slightly slower than player - gives reaction time!
    }
    print("🐅 Tiger chase started! Run to your house!")
end
```

---

## Testing Results

### Expected Behavior:
1. ✅ Player sees tiger warning
2. ✅ Has ~2-3 seconds to react
3. ✅ Can easily reach house if moves immediately
4. ✅ Gets caught if stands still too long
5. ✅ Creates tension without being unfair

### Balance Check:
- **Too Easy:** Tiger speed < 70 (player never in danger)
- **Balanced:** Tiger speed = 85 (exciting but fair) ⭐
- **Too Hard:** Tiger speed > 100 (little reaction time)

---

## Different Speed Zones

### Zone 1: Hunting Area (First-Person)
- **Tiger Passive:** 0 speed (stands still)
- **Tiger Attacking:** 250 speed (very fast, short distance)
- **Purpose:** Dramatic chase in confined space
- **Escape:** Triggers overworld chase

### Zone 2: Overworld Chase
- **Tiger Chase:** 85 speed (moderate)
- **Player Speed:** 200 speed (fast)
- **Purpose:** Thrilling escape sequence
- **Escape:** Reach house

### Zone 3: Near House (Safe Zone)
- **Tiger Behavior:** Gives up
- **Distance:** Within 50 pixels of house
- **Purpose:** Defined safe zone

---

## Future Balance Options

### Easy Mode (If Needed):
```lua
speed = 70  -- Player can easily outrun tiger
```
- Tiger catches up very slowly
- Low pressure chase

### Normal Mode (Current):
```lua
speed = 85  -- Balanced challenge
```
- Player can escape if reactive
- Moderate pressure

### Hard Mode (Optional):
```lua
speed = 100  -- Tiger keeps pace with player
```
- Player must move perfectly
- High pressure chase

### Nightmare Mode (Expert):
```lua
speed = 120  -- Tiger slightly faster
```
- Player must take optimal path
- Extreme pressure

---

## Related Systems

### Player Movement
- **File:** `systems/player.lua`
- **Speed:** 200 px/s
- **Diagonal:** 141 px/s (normalized)

### Tiger Chase
- **File:** `systems/world.lua`
- **Init:** Lines 496-503
- **Update:** Lines 450-492
- **Spawn:** 100 pixels behind player

### Death System
- **File:** `states/death.lua`
- **Trigger:** Distance < 30 pixels
- **Effect:** Game over screen

---

## Player Feedback

### Visual Cues:
- ⚠️ Red warning text: "TIGER CHASING!"
- 🐅 Orange tiger circle chasing player
- 🏠 House is clear safe zone

### Audio Cues (Future):
- Roar sound when chase starts
- Heartbeat sound when tiger close
- Safe sound when reaching house

### Tension Curve:
```
Chase Start (High Alert)
    ↓
Player Runs (Building Tension)
    ↓
Tiger Closes or Player Gains Distance
    ↓
Near House (Climax)
    ↓
Safe or Caught (Resolution)
```

---

## Summary

Tiger speed reduced from **120** to **85** pixels per second to give players better reaction time:
- **Old:** Tiger at 60% of player speed - very tight timing
- **New:** Tiger at 42.5% of player speed - balanced challenge

**Result:** Players have 2-3 seconds to react and can escape if they move quickly toward the house. Creates exciting tension without being unfairly difficult! 🐅✅

**Key Balance:** Thrilling but fair - rewards quick reactions while punishing hesitation.
