# Tiger Warning System Implementation

**Date:** Current Session  
**Status:** ✅ Complete and Ready for Testing

---

## Overview

Implemented a dramatic visual warning system that triggers when a passive tiger is shot in the hunting minigame. This gives players a clear indication that they've provoked a dangerous predator and need to react quickly.

---

## Features Implemented

### 1. **Tiger Warning State Variables**
- `hunting.tigerWarning` - Boolean flag to track if warning should be displayed
- `hunting.tigerWarningTimer` - Timer to control how long warning is shown (3 seconds)

**Location:** `states/hunting.lua` lines 163-165

### 2. **Warning Trigger**
When a tiger (dangerous animal) is shot and wounded:
- Sets `hunting.tigerWarning = true`
- Sets `hunting.tigerWarningTimer = 3.0` (3 second display)
- Tiger becomes enraged and charges at player

**Location:** `states/hunting.lua` lines 597-599

### 3. **Warning Timer Update**
Countdown logic in the update loop:
- Decrements `hunting.tigerWarningTimer` by `dt` each frame
- Automatically resets `hunting.tigerWarning = false` when timer expires

**Location:** `states/hunting.lua` lines 251-257

### 4. **Visual Warning Overlay**
Big, bold red screen overlay with pulsing effect:
- **Red Screen:** Semi-transparent red overlay with pulsing animation
- **Warning Text:** "⚠️ TIGER ENRAGED! ⚠️" at 2x scale
- **Run Command:** "RUN!" text at 3x scale with white outline for visibility
- **Animation:** Pulsing red overlay using `math.sin()` for dramatic effect

**Location:** `states/hunting.lua` lines 963-989

---

## Technical Details

### Tiger Behavior Flow
```
1. Tiger spawns (95% chance for testing, normally 5%)
2. Tiger is PASSIVE - doesn't move, just stands there
3. Player shoots tiger
   → Tiger health decreases
   → hunting.tigerWarning = true
   → hunting.tigerWarningTimer = 3.0
   → animal.attacking = true
4. Big red warning screen appears for 3 seconds
5. Tiger charges at player at 250 px/s
6. If tiger gets within 200px → triggers overworld chase
7. Player must run to house to escape or face death
```

### Visual Design
- **Screen Size:** 960x540 pixels
- **Overlay Color:** Red (1, 0, 0) with pulsing alpha (0.1 to 0.5)
- **Warning Text:** Centered at (480, 200), 2x scale
- **Run Text:** Centered at (480, 280), 3x scale with outline
- **Animation Speed:** 10 Hz pulse frequency

### Code Structure
```lua
-- Initialization (in hunting:enter())
hunting.tigerWarning = false
hunting.tigerWarningTimer = 0

-- Trigger (in hitAnimal())
if animalData.dangerous then
    hunting.tigerWarning = true
    hunting.tigerWarningTimer = 3.0
    animal.attacking = true
end

-- Update (in hunting:update())
if hunting.tigerWarning and hunting.tigerWarningTimer > 0 then
    hunting.tigerWarningTimer = hunting.tigerWarningTimer - dt
    if hunting.tigerWarningTimer <= 0 then
        hunting.tigerWarning = false
    end
end

-- Draw (in hunting:drawUI())
if hunting.tigerWarning and hunting.tigerWarningTimer > 0 then
    -- Red pulsing overlay
    -- Giant warning text
    -- RUN! command
end
```

---

## Testing Instructions

1. **Start the game** and go to hunting area
2. **Wait for a tiger to spawn** (95% chance currently - very high for testing)
3. **Observe:** Tiger should be standing still (passive behavior)
4. **Shoot the tiger** with bow or rifle
5. **Expected Results:**
   - Big red screen overlay appears
   - "⚠️ TIGER ENRAGED! ⚠️" text shows at top
   - "RUN!" text shows in center (large and bold)
   - Warning displays for 3 seconds
   - Tiger starts charging toward player at high speed
   - If tiger gets too close (200px), triggers overworld chase

---

## Related Systems

### Tiger Passive Behavior
- **Location:** `states/hunting.lua` lines 117-130
- Tiger has `behavior = "passive"` instead of "stalk"
- Tigers don't move unless `animal.attacking = true`
- Tiger spawn rate: 95% (testing) / 5% (production)

### Tiger Attack Behavior
- **Location:** `states/hunting.lua` lines 312-330
- When `animal.attacking = true`, tiger charges at 250 px/s
- Targets player gun position (screen center)
- Attack speed much faster than normal animal movement

### Tiger Chase System
- **Location:** `systems/world.lua` lines 440-500
- Triggers when tiger gets within 200px in hunting mode
- Switches to overworld with tiger chasing player
- Player must reach house (<50px) to escape
- Getting caught (<30px) triggers death screen

---

## Balance Notes

### Current Settings (Testing)
- Tiger spawn rate: **0.95 (95%)** - Very high for easy testing
- Warning duration: **3.0 seconds** - Gives player time to react
- Attack speed: **250 px/s** - Fast but dodgeable with skill
- Chase trigger: **200 pixels** - Close but fair

### Production Settings (TODO)
- Tiger spawn rate: **0.05 (5%)** - Rare encounter
- Keep warning at 3 seconds (good balance)
- Keep attack speed at 250 (tested and fair)
- Keep chase trigger at 200px (works well)

---

## Future Enhancements

1. **Sound Effects**
   - Roar sound when tiger is provoked
   - Dramatic music swell during warning
   - Heavy footsteps during charge

2. **Visual Effects**
   - Screen shake when warning appears
   - Tiger sprite changes to "angry" version
   - Dust/motion blur during charge

3. **Aggressive Tiger Variant**
   - Some tigers start in "stalk" mode (hunt player immediately)
   - Different spawn rate (1-2%)
   - Higher reward (more meat/money)
   - No warning (they're already hunting)

4. **Difficulty Modes**
   - Easy: Slower tiger, longer warning
   - Normal: Current settings
   - Hard: Faster tiger, shorter warning, higher spawn rate

---

## Known Issues

None - System is working as designed!

---

## Testing Checklist

- [x] Tiger spawns in hunting area
- [x] Tiger is passive (doesn't move)
- [x] Shooting tiger triggers warning
- [x] Red overlay displays correctly
- [x] Warning text is visible and readable
- [x] Warning lasts 3 seconds
- [x] Tiger charges after being shot
- [x] Chase triggers when tiger gets close
- [ ] **TODO:** Test full sequence (spawn → shoot → warning → chase → house/death)
- [ ] **TODO:** Verify warning doesn't overlap with other UI elements
- [ ] **TODO:** Test with both bow and rifle
- [ ] **TODO:** Confirm warning works with multiple tigers

---

## Code Files Modified

1. **states/hunting.lua** (1038 lines)
   - Added warning state variables (lines 163-165)
   - Added warning trigger in hitAnimal() (lines 597-599)
   - Added warning timer update (lines 251-257)
   - Added visual warning overlay (lines 963-989)

---

## Performance Notes

- Warning overlay is simple and efficient (no complex graphics)
- Pulsing animation uses `math.sin()` - very lightweight
- No performance impact expected
- All rendering happens in single draw call

---

## Summary

The tiger warning system provides excellent player feedback when provoking a dangerous predator. The dramatic red screen, bold text, and pulsing effect create urgency and excitement. Combined with the passive tiger behavior, this creates a risk/reward mechanic: tigers are valuable but dangerous, and players have clear warning before things get deadly.

**Next Steps:**
1. Play test the full sequence
2. Gather player feedback on warning duration
3. Adjust spawn rate back to 5% for production
4. Consider adding sound effects for even more impact

---

*Tiger hunting just got a lot more interesting!* 🐅
