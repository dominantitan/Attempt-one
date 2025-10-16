# HP System & Tiger Chase Implementation Complete! ✅

## What's Been Implemented

### 1. ✅ Animal HP System
- **HP Values Set:**
  - Rabbit: 50 HP (1-2 shots with bow, 1 shot with rifle/shotgun)
  - Deer: 150 HP (3 shots with bow, 2 with rifle)
  - Boar: 250 HP (5 shots with bow, 3 with rifle)
  - Tiger: 500 HP (10 shots with bow, 5 with rifle)

- **Damage System:**
  - Each hit reduces animal HP by weapon damage
  - Headshots deal 2x damage
  - Shows HP status after each hit

### 2. ✅ Wounded Animal Flee Behavior
- Animals that are hit but not killed become "wounded"
- Wounded animals flee off-screen at high speed
- Flee speeds: Rabbit 300, Deer 200, Boar 180
- Animals removed once they escape off-screen

### 3. ✅ Tiger Attack Mechanic
- Tiger no longer causes instant-exit when spawned
- If tiger gets within 150 pixels of player center, it attacks
- Triggers tiger chase in overworld
- Warning messages displayed

### 4. ✅ Tiger Chase System (Overworld)
- Tiger spawns behind player when chase starts
- Chases player at 120 speed (faster than player)
- Visual: Orange circle with face + flashing warning
- Two outcomes:
  - **Caught**: Player dies → Death screen
  - **Safe**: Player reaches house → Tiger gives up

### 5. ✅ Death Screen
- Shows "YOU DIED" with red text
- Displays days survived
- Tiger emoji and message
- Press ENTER/SPACE to restart
- Full game reset on restart

### 6. ✅ Day Counter Display
- Shows "Day X" in top-right corner
- Already integrated from daynight system

## Files Modified

1. **states/hunting.lua**
   - Added HP system to hitAnimal() function (lines 494-541)
   - Added wounded flee behavior to updateAnimal() (lines 287-304)
   - Removed tiger instant-exit, replaced with warning (lines 364-370)
   - Added tiger attack detection (lines 247-269)

2. **systems/world.lua**
   - Added tiger chase update logic (lines 424-487)
   - Added tiger chase drawing (lines 321-338)
   - Checks for player caught or reaching house

3. **states/gameplay.lua**
   - Added world.update() call with player position (line 29)

4. **states/death.lua** (NEW FILE)
   - Complete death screen implementation
   - Restart functionality
   - Score display

5. **main.lua**
   - Registered death state (lines 46-55)

## How to Test

### Test HP System:
1. Enter hunting (ENTER near zone)
2. Shoot rabbit with bow - should take 1-2 hits
3. Watch console for HP messages
4. Shoot deer - should take 3+ hits
5. Animals should flee when wounded (not killed)

### Test Tiger Chase:
1. Keep hunting until tiger spawns
2. Let tiger get close (within 150px of center)
3. You'll be ejected to overworld with tiger chasing
4. **Option A:** Run to house (safe!)
5. **Option B:** Let tiger catch you (death screen)

### Test Death Screen:
1. Get caught by tiger
2. Should see "YOU DIED" screen
3. Shows days survived
4. Press ENTER to restart

## Expected Console Output

```
═══════════════════════════════════════
🎯 ENTERING HUNTING MODE
📍 Entry count: 1
✓ Validation passed
🎮 Active state set to TRUE
═══════════════════════════════════════

💥 HIT Rabbit for 50 damage! HP: 0/50
💀 KILLED Rabbit! +2 meat

💥 HIT Deer for 50 damage! HP: 100/150
💨 Deer is WOUNDED (HP: 100) and fleeing!

🐅 TIGER SPOTTED! DANGEROUS!
⚠️  This animal will attack you!

═══════════════════════════════════════
🐅 TIGER ATTACKS!
💀 You are being chased!
🏃 RUN TO YOUR HOUSE!
═══════════════════════════════════════

🏠 YOU MADE IT HOME SAFELY!
✅ The tiger gives up and runs away
```

## Next Steps (Optional Enhancements)

1. **Add animal sprites** - Replace circles with actual sprites
2. **Blood effects** - Show blood when animals are hit
3. **Tiger roar sound** - Play sound when tiger attacks
4. **Health bar UI** - Show animal HP bars above them
5. **Difficulty scaling** - Animals get tougher each day
6. **Multiple tigers** - Chance for 2+ tigers at once
7. **Tracking system** - Follow blood trails of wounded animals
8. **Trophy system** - Keep count of kills per animal type

## Known Behavior

- Lint warnings about `love` global are normal (it's provided by LÖVE2D)
- Tiger chase speed (120) is intentionally faster than player
- House safe zone is 50 pixels from cabin center
- All features work together - you can get wounded animals, then tiger attacks, then chase!

## Debug Commands

Already in console:
- Entry/exit tracking
- HP damage messages
- Tiger spawn warnings
- Chase status updates
- Death/safety messages

Enjoy the new hunting challenge! 🎯🐅
