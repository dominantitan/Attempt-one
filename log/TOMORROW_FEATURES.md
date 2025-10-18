# 🌅 TOMORROW'S FEATURE LIST - October 17, 2025

## 🔥 CRITICAL PRIORITIES (Must Complete)

### 1. 🐅 Tiger Chase Death Check (15 minutes)
**Current Issue:** Tiger might continue chasing even after death  
**File:** `systems/world.lua`  
**Fix:**
```lua
-- Add check in chase logic:
if world.chasingTiger and (world.chasingTiger.health <= 0 or world.chasingTiger.dead) then
    world.chasingTiger = nil
    Game.tigerChasing = false
    print("🐅 Tiger died - chase ended")
end
```

**Test:** Kill tiger while being chased, verify chase stops

---

### 2. 🎯 Spawn Cooldown System (20 minutes)
**Current Issue:** Spawn attempts every frame waste performance  
**File:** `states/hunting.lua`  
**Implementation:**
```lua
-- Add to hunting module:
hunting.spawnCooldown = 0

-- In hunting:update():
hunting.spawnCooldown = hunting.spawnCooldown - dt
if hunting.spawnCooldown <= 0 and #hunting.animals < 3 then
    if math.random() < 0.005 then
        local spawned = hunting:spawnAnimal()
        hunting.spawnCooldown = spawned and 2 or 5
    end
end
```

**Test:** Monitor FPS during extended hunting sessions

---

### 3. 🏹 Projectile Cleanup (15 minutes)
**Current Issue:** Arrows might accumulate in memory  
**File:** `states/hunting.lua`  
**Add Checks:**
- Max distance traveled (remove after 2000 pixels)
- Off-screen removal
- Lifetime limit (5 seconds)

**Test:** Shoot 100 arrows, verify they're removed

---

### 4. 🧪 Ammo System Testing (30 minutes)
**Verify Today's Fix:**
- Enter hunting with 10 arrows
- Shoot 3 times
- Exit and re-enter
- Verify 7 arrows remain (not 10, not 0)
- Test multiple sessions
- Test crash recovery

---

## 🎮 FEATURE DEVELOPMENT

### 5. 🌿 Foraging System Polish (1 hour)

**Current State:** Basic items spawn randomly  

**Improvements:**
- [ ] Validate spawn positions (avoid structures, zones)
- [ ] Add visual glow/indicator for items
- [ ] Balance spawn rates (berries common, mushrooms rare)
- [ ] Add item variety (5+ types)
- [ ] Add "shimmer" animation
- [ ] Improve collision detection

**Files:**
- `systems/foraging.lua`
- `systems/world.lua` (spawn logic)

**Rewards:**
- Berries: +10 hunger, $5 sell
- Mushrooms: +20 hunger, $15 sell  
- Herbs: Healing item, $10 sell
- Wild Roots: +5 hunger, $3 sell
- Rare Flowers: $25 sell (cosmetic)

---

### 6. 🌾 Farming System Completion (2 hours)

**Current State:** Can plant seeds, plots exist  

**Needed Features:**
- [ ] **Growth Stages:** Seed → Sprout → Growing → Harvestable
- [ ] **Watering System:** Press W near plot with water item
- [ ] **Growth Timer:** 2 days per stage (6 days total)
- [ ] **Visual Changes:** Different sprites per stage
- [ ] **Harvest Rewards:** Wheat = $20, Carrots = $15, etc.
- [ ] **Crop Death:** If not watered in 24hrs, wilts

**Implementation Steps:**
1. Add growth stage tracking to crop entity
2. Add water requirement (boolean flag)
3. Update visual based on stage
4. Add harvest interaction
5. Add wilting logic
6. Balance timings

**Files:**
- `systems/farming.lua`
- `entities/crops.lua`
- `states/gameplay.lua` (watering interaction)

**Crop Types:**
| Crop | Days to Harvest | Water Needs | Sell Price | Seed Cost |
|------|----------------|-------------|------------|-----------|
| Wheat | 4 days | Daily | $20 | $5 |
| Carrots | 5 days | Daily | $25 | $8 |
| Potatoes | 6 days | Daily | $30 | $10 |
| Tomatoes | 7 days | 2x daily | $40 | $15 |

---

### 7. 🛒 Shop System Expansion (1 hour)

**Current State:** Can buy basic items  

**New Features:**
- [ ] **Weapon Confirmation:** "Buy rifle for $150? (Y/N)"
- [ ] **Stock Limits:** Only 3 rifles available per day
- [ ] **Daily Refresh:** Stock resets at midnight
- [ ] **Special Items:**
  - Healing Potion: $25, restores 50 HP
  - Watering Can: $30 (one-time purchase)
  - Fishing Rod: $40 (for pond fishing - future)
  - Backpack Upgrade: $100 (+10 inventory slots)

**Shop Inventory:**
```lua
shop.items = {
    -- Existing items
    {name = "Arrows (10x)", price = 15, type = "arrows", quantity = 10},
    {name = "Bullets (20x)", price = 40, type = "bullets", quantity = 20},
    {name = "Shells (10x)", price = 50, type = "shells", quantity = 10},
    
    -- NEW items
    {name = "Healing Potion", price = 25, type = "healing_potion", stock = 5},
    {name = "Watering Can", price = 30, type = "watering_can", oneTime = true},
    {name = "Backpack Upgrade", price = 100, type = "backpack_upgrade", oneTime = true},
}
```

**Files:**
- `states/shop.lua`
- `entities/shopkeeper.lua`

---

## 🧪 TESTING & POLISH

### 8. 🎯 Comprehensive Testing (1.5 hours)

**Test Plan:**

#### Tiger Mechanics (30 min)
- [ ] Passive until shot
- [ ] Warning screen appears
- [ ] Area blocks until next day
- [ ] Chase triggers on exit
- [ ] Speed balanced (can escape)
- [ ] Death stops chase ← NEW TEST

#### Ammo System (20 min)
- [ ] Doesn't disappear on entry
- [ ] Decrements on shooting
- [ ] Persists between sessions
- [ ] Works with all 3 weapons
- [ ] Shop restocks work

#### Hunting Gameplay (20 min)
- [ ] Animals spawn correctly (1 tiger + 2 others)
- [ ] HP bars show after hit
- [ ] No HP numbers displayed
- [ ] Tiger persists until killed
- [ ] Spawn cooldown prevents spam ← NEW TEST
- [ ] Projectiles clean up ← NEW TEST

#### Economy Balance (20 min)
- [ ] Can afford basic ammo
- [ ] Hunting is profitable
- [ ] Weapons are expensive but achievable
- [ ] Farming provides steady income
- [ ] Foraging supplements income

#### World Systems (20 min)
- [ ] Day/night cycle smooth
- [ ] Time display accurate
- [ ] Foraging items spawn
- [ ] Crops grow properly
- [ ] No crashes over 10+ days

---

### 9. 🎨 UI/UX Improvements (1 hour)

**Visual Feedback:**
- [ ] Add "✓ Ammo loaded" message on hunting entry
- [ ] Show ammo count in hunting HUD (bigger, clearer)
- [ ] Add "Out of ammo!" flashing warning
- [ ] Better interaction prompts (colored, bordered)
- [ ] Add sound effect placeholders (print statements)

**HUD Improvements:**
```lua
-- Hunting HUD should show:
- Weapon name (bigger font)
- Ammo count (LARGE numbers)
- Animal count
- Score
- Timer (optional)
```

**Interaction Prompts:**
```lua
-- Better visual style:
[PRESS ENTER] Enter Northwestern Woods
[PRESS W] Water crops
[PRESS E] Harvest wheat (Ready!)
[PRESS B] Open shop
```

**Files:**
- `states/hunting.lua` (HUD)
- `states/gameplay.lua` (prompts)
- `main.lua` (global HUD)

---

## 💾 OPTIONAL: SAVE/LOAD (If Time Permits)

### 10. 💾 Proper Save System (2-3 hours)

**Only do this if ALL above is complete!**

**Requirements:**
1. **Manual Save:** F9 key saves game
2. **Auto-Load:** Load on startup (optional)
3. **Save Validation:** Checksum to detect corruption
4. **Graceful Failure:** Handle corrupted saves

**What to Save:**
```lua
saveData = {
    version = "1.0",
    timestamp = os.time(),
    player = {
        x, y,
        health, stamina, hunger,
        inventory = {...}
    },
    world = {
        day = daynightSystem.dayCount,
        time = daynightSystem.time,
        tigerBlockedAreas = Game.tigerBlockedAreas,  ← IMPORTANT!
        crops = cropsEntity.planted,
        foragedItems = foragingSystem.activeCrops
    },
    progression = {
        weaponsOwned = {...},
        backpackUpgrade = bool,
        shopPurchases = {...}
    }
}
```

**Implementation:**
1. Create validation function
2. Add F9 keybind
3. Show "Game Saved!" message
4. Add save file version check
5. Test save/load multiple times

**Files:**
- `utils/save.lua` (add validation)
- `main.lua` (keybind + load)

---

## 📊 TIME ESTIMATES

| Task | Priority | Time | Cumulative |
|------|----------|------|------------|
| Tiger chase death check | 🔴 P0 | 15 min | 0:15 |
| Spawn cooldown | 🔴 P0 | 20 min | 0:35 |
| Projectile cleanup | 🔴 P0 | 15 min | 0:50 |
| Ammo testing | 🔴 P0 | 30 min | 1:20 |
| **Morning Break** | | | **1:20** |
| Foraging polish | 🟠 P1 | 1 hour | 2:20 |
| **Lunch Break** | | | **2:20** |
| Farming completion | 🟠 P1 | 2 hours | 4:20 |
| Shop expansion | 🟡 P2 | 1 hour | 5:20 |
| **Afternoon Break** | | | **5:20** |
| Comprehensive testing | 🟢 P3 | 1.5 hours | 6:50 |
| UI/UX improvements | 🟢 P3 | 1 hour | 7:50 |
| **Save/load (optional)** | 🔵 P4 | 2-3 hours | 9:50-10:50 |

**Total Realistic Work:** 6-8 hours  
**With Optional Save/Load:** 8-11 hours

---

## ✅ SUCCESS CRITERIA

### Minimum Viable Progress:
- ✅ All P0 critical fixes done
- ✅ Foraging system polished
- ✅ Farming system working end-to-end
- ✅ All systems tested

### Good Progress:
- ✅ All of the above
- ✅ Shop expanded
- ✅ UI/UX improved

### Excellent Progress:
- ✅ All of the above  
- ✅ Save/load implemented
- ✅ Game feels polished

---

## 🎯 FOCUS AREAS

### Morning (3 hours):
**"Fix and Polish Hunting"**
- Critical fixes
- Ammo testing
- Foraging polish

### Afternoon (3 hours):
**"Complete Core Loops"**
- Farming end-to-end
- Shop expansion
- Testing

### Evening (Optional):
**"Make it Shine"**
- UI/UX
- Save/load
- Final polish

---

## 📝 TESTING CHECKLIST

Print this out or keep open:

### Before Starting:
- [ ] Read today's session wrap-up
- [ ] Review POTENTIAL_ISSUES_ANALYSIS.md
- [ ] Run game once to verify current state

### After Each Feature:
- [ ] Test the feature in isolation
- [ ] Test with other systems
- [ ] Check console for errors
- [ ] Verify no performance issues

### Before Finishing:
- [ ] Play for 15 minutes straight
- [ ] Try to break things
- [ ] Document any bugs found
- [ ] Update documentation

---

## 🚀 STRETCH GOALS

If you finish everything early:

1. **Sound Effects** (1 hour)
   - Add basic sound placeholders
   - Shooting sounds
   - Animal sounds
   - Ambient forest sounds

2. **Tutorial System** (2 hours)
   - First-time player guidance
   - Tool-tips on hover
   - Quest markers

3. **Achievements** (1 hour)
   - Track milestones
   - "First Kill", "100 Arrows Shot", etc.

4. **Balance Pass** (1 hour)
   - Adjust all prices
   - Fine-tune timings
   - Test economy thoroughly

---

## 💭 DESIGN QUESTIONS TO ANSWER

While working, decide on:

1. **Farming Balance:**
   - How long should crops take? (Currently: 4-7 days)
   - Should watering be once or twice daily?
   - What should harvest yields be?

2. **Shop Balance:**
   - Are weapon prices fair? (Bow free, Rifle $150, Shotgun $200)
   - Should ammo be more/less expensive?
   - Should there be bulk discounts?

3. **Foraging:**
   - How rare should items be?
   - Should there be a "forage" action or auto-collect?
   - What should be the value vs hunting/farming?

4. **Progression:**
   - What order should player unlock things?
   - Bow → Farm → Forage → Rifle → Shotgun?
   - Or more flexible?

---

## 🎮 PLAYTESTING NOTES

After implementing features, test from player perspective:

**New Player Experience:**
- Is it clear what to do?
- Are first 10 minutes fun?
- Can they earn money easily?

**Mid-Game:**
- Is there progression?
- Are goals clear?
- Is grinding required?

**Late-Game:**
- Is there variety?
- Are all systems useful?
- Is there replay value?

---

## 📁 FILES TO CREATE/MODIFY TOMORROW

### Will Definitely Touch:
- `states/hunting.lua` (spawn cooldown, projectile cleanup)
- `systems/world.lua` (tiger chase death)
- `systems/foraging.lua` (polish)
- `systems/farming.lua` (complete cycle)
- `states/shop.lua` (expand)
- `entities/crops.lua` (growth stages)

### Might Touch:
- `main.lua` (save/load, if time)
- `utils/save.lua` (validation, if time)
- `states/gameplay.lua` (interactions)
- `assets/` (if adding visuals)

### Will Create:
- `log/TESTING_REPORT_OCT17.md` (test results)
- `log/BALANCE_CHANGES.md` (price adjustments)
- `constants.lua` (if cleaning up magic numbers)

---

## 🔧 DEVELOPMENT SETUP

Before starting tomorrow:

1. **Backup Current Code:**
   ```bash
   git add .
   git commit -m "End of day Oct 16 - All fixes applied"
   ```

2. **Create Feature Branch (Optional):**
   ```bash
   git checkout -b feature/farming-foraging
   ```

3. **Open These Files:**
   - `log/TOMORROW'S_FEATURES.md` (this file)
   - `log/POTENTIAL_ISSUES_ANALYSIS.md`
   - `states/hunting.lua`
   - `systems/farming.lua`

4. **Run Game First:**
   - Test current state
   - Verify today's fixes work
   - Note any issues

---

## 🎯 FINAL REMINDERS

### Do:
- ✅ Test frequently
- ✅ Commit after each feature
- ✅ Document as you go
- ✅ Take breaks
- ✅ Ask for clarification if needed

### Don't:
- ❌ Rush through testing
- ❌ Skip documentation
- ❌ Implement without planning
- ❌ Work when tired
- ❌ Forget to have fun!

---

**Good luck tomorrow! Let's make this game amazing! 🚀🎮✨**

**Remember:** Features > Polish > Perfection  
**Motto:** Make it work, make it right, make it fast (in that order!)

---

*Last Updated: October 16, 2025, 11:45 PM*  
*Next Review: October 17, 2025, 9:00 AM*
