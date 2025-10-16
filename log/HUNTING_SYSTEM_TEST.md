# NEW Hunting System - Verification Guide

## 🎯 What You SHOULD See

When you enter a hunting zone (press ENTER near circular areas), you should see:

### ✅ NEW First-Person DOOM-Style System:
1. **Dark Green Background** - Solid color, not top-down view
2. **5 Bushes** - Dark green rectangles scattered across screen
3. **Player at Bottom** - Small character sprite at bottom-center (480, 480)
4. **Weapon in Hand** - Bow/rifle/shotgun pointing at mouse cursor
5. **Crosshair** - White cross following your mouse
6. **First-Person View** - You're "inside" the player looking out
7. **Animals Spawn** - Rectangles that appear in front of bushes
8. **Peeking Mechanic** - Animals briefly peek from behind bushes
9. **Arrow on Bow** - Visible arrow when bow is loaded
10. **UI Panel** - Top-left shows timer, ammo, kills

### ❌ OLD Top-Down System (You Should NOT See):
1. ~~Top-down bird's eye view~~
2. ~~Circular boundary visible~~
3. ~~Player character walking around~~
4. ~~Animals walking in circles~~
5. ~~Press H to hunt~~
6. ~~Area-based animal spawning~~

---

## 🧪 Testing Steps

### Test 1: Verify System Type
1. Start game
2. Walk to Northwestern Woods (top-left, 130, 130)
3. Get near the circle
4. Press **ENTER**

**What you should see**:
```
✅ Screen fills with dark green
✅ First-person view (DOOM-style)
✅ Crosshair appears (white cross)
✅ Weapon at bottom pointing at cursor
✅ Bushes as rectangles
✅ UI in top-left corner
✅ Timer starts at 3:00
```

**What you should NOT see**:
```
❌ Top-down view of a circular area
❌ Your player character visible and walking
❌ Animals walking around on ground
❌ "Press H to hunt" message
```

### Test 2: Verify Controls
Once in hunting mode:
- **Move Mouse** → Weapon should rotate to follow
- **Left Click** → Should shoot (arrow flies from weapon)
- **1/2/3 Keys** → Switch weapons (if owned)
- **ENTER/ESC** → Exit hunting

### Test 3: Verify Animal Behavior
- Animals should spawn as **rectangles**
- They should appear **in front of bushes**
- Some should be **peeking from behind bushes** (semi-transparent)
- They should NOT be walking around the screen

### Test 4: Verify Economy
- **Check ammo** before hunting (I key)
- Enter hunting
- Shoot some arrows
- Exit hunting (ENTER)
- **Check ammo** again (should be reduced)

---

## 🐛 If You're Seeing the OLD System

### Symptoms:
- Top-down view with circular boundary
- Player character walking around
- Animals as sprites walking in area
- No first-person view
- No crosshair or weapon aiming

### This means:
The game is loading the OLD hunting area system from `systems/areas.lua` instead of the NEW hunting state from `states/hunting.lua`.

### Solution Needed:
We need to prevent `areas.lua` from taking over when entering hunting zones.

---

## 📋 Current Implementation Status

### What's Implemented:
✅ **Hunting State** (`states/hunting.lua`) - NEW first-person system (799 lines)
✅ **Hunting Zones** (`systems/areas.lua`) - 3 circular zones on map
✅ **Zone Detection** - Prompts show when near zones
✅ **Ammo Economy** - Limited ammo, must buy from shop
✅ **Weapon System** - Bow/rifle/shotgun with pointing
✅ **Tiger Fear** - Instant ejection if tiger spawns
✅ **3D Effects** - Weapon rotation, arrow visuals

### Potential Issue:
⚠️ **Two Hunting Systems** - Both exist in code:
1. `states/hunting.lua` - NEW first-person (what we want)
2. `systems/areas.lua` hunting_area type - OLD top-down (don't want)

---

## 🔍 Diagnosis Questions

Please answer these to help identify the issue:

1. **When you press ENTER at a hunting zone, what do you see?**
   - [ ] Dark green background with bushes (first-person)
   - [ ] Top-down view with circular boundary
   - [ ] Something else: _______________

2. **Do you see a crosshair (white cross)?**
   - [ ] Yes - follows mouse cursor
   - [ ] No - no crosshair visible

3. **Do you see your player character?**
   - [ ] Small sprite at bottom-center only
   - [ ] Full character walking around top-down
   - [ ] Not visible at all

4. **Can you aim with the mouse?**
   - [ ] Yes - weapon rotates to follow cursor
   - [ ] No - mouse does nothing

5. **What's in the top-left corner?**
   - [ ] Black panel with Timer, Ammo, Kills
   - [ ] Nothing / Different UI
   - [ ] Area name only

6. **When you click, what happens?**
   - [ ] Arrow shoots from weapon at bottom
   - [ ] Nothing happens
   - [ ] Something else: _______________

---

## 🎮 Expected vs Actual

### Expected Flow (NEW System):
```
Walk to hunting zone circle
    ↓
Prompt: "🎯 Northwestern Woods: Press ENTER"
    ↓
Press ENTER
    ↓
Screen transitions to dark green
    ↓
First-person view loads
    ↓
Crosshair appears
    ↓
Weapon visible at bottom
    ↓
Animals spawn
    ↓
Hunt with mouse aiming
    ↓
Press ENTER to exit
    ↓
Return to main world
```

### If Seeing OLD System:
```
Walk to hunting zone circle
    ↓
Prompt appears
    ↓
Press ENTER
    ↓
Transition to hunting_area
    ↓
Top-down view loads
    ↓
Animals spawn in circle
    ↓
Walk around with WASD
    ↓
Press H to hunt individual animals
    ↓
Exit area
```

---

## 🛠️ Files Involved

### NEW Hunting (What Should Run):
- `states/hunting.lua` (799 lines)
  - Lines 1-70: Weapon definitions
  - Lines 132-198: Enter function (loads ammo, checks weapons)
  - Lines 200-240: Update function (timer, animals, projectiles)
  - Lines 513-680: Draw function (bushes, animals, weapon, crosshair)
  - Lines 728-765: Controls (keypressed, mousepressed)

### OLD Hunting (Should Be Bypassed):
- `systems/areas.lua` (461 lines)
  - Lines 71-119: hunting_area definitions
  - Lines 220-252: spawnHuntingAreaAnimals()
  - Lines 281-304: updateHuntingArea()
  - Lines 335-356: drawHuntingArea()

### Entry Point:
- `states/gameplay.lua`
  - Lines 214-224: ENTER key handler
  - Should call: `gamestate.switch("hunting")`
  - Should load: `states/hunting.lua`

---

## 💡 What Should Happen

### Correct Sequence:
1. **Detection**: gameplay.lua detects you're near hunting zone
2. **Prompt**: Shows "Press ENTER to hunt"
3. **Switch**: Calls `gamestate.switch("hunting")`
4. **Load**: Loads `states/hunting.lua`
5. **Enter**: Calls `hunting:enter()` function
6. **Display**: Shows first-person view
7. **Run**: Uses hunting.lua for all logic
8. **Exit**: Returns to gameplay

### The Bypass:
- areas.lua should NOT handle hunting anymore
- Hunting zones are just trigger points
- They activate the hunting state, not hunting areas
- The gamestate switch should go directly to states/hunting.lua

---

## 📊 System Comparison

| Feature | NEW System (hunting.lua) | OLD System (areas.lua) |
|---------|-------------------------|------------------------|
| **View** | First-person DOOM-style | Top-down bird's eye |
| **Controls** | Mouse aim + click | WASD walk + H hunt |
| **Player** | Fixed at bottom | Walks around area |
| **Animals** | Spawn/despawn | Walk in circle |
| **Weapon** | Visible, rotates | Not visible |
| **Crosshair** | Yes, follows mouse | No |
| **Ammo** | Limited economy | Not tracked |
| **Timer** | 3 minute session | No timer |
| **Exit** | ENTER key | Walk to exit area |
| **Background** | Dark green solid | Circular boundary |

---

## ✅ Success Criteria

The NEW system is working if:
1. ✅ First-person view (not top-down)
2. ✅ Mouse cursor controls aiming
3. ✅ Weapon rotates to follow cursor
4. ✅ Dark green background
5. ✅ 5 bushes visible
6. ✅ Crosshair (white cross)
7. ✅ Timer in top-left
8. ✅ Ammo counter visible
9. ✅ Left-click shoots
10. ✅ Animals peek from bushes

---

Please test the game and let me know which system you're seeing!
