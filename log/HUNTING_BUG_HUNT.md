# Hunting System Bug Hunt & Analysis

**Date:** October 17, 2025  
**Status:** 🔍 COMPREHENSIVE REVIEW

## 🐛 BUGS FOUND

### 1. 🎲 Tiger Spawn Rate is 95% (TESTING VALUE)
**Severity:** HIGH  
**Location:** `entities/animals.lua` line 104  
**Issue:** Tiger spawn chance is set to 0.95 (95%) for testing, making tigers spawn almost every time  
**Expected:** Should be 0.05 (5%) normally, with increased chance at night  
**Impact:** Game is too dangerous, tiger encounters are not rare/special

### 2. 🌙 No Dynamic Tiger Spawn Rate (Day/Night)
**Severity:** MEDIUM  
**Location:** `states/hunting.lua` spawnAnimal() function  
**Issue:** Tiger spawn rate is static - doesn't increase at night  
**Expected:** Tigers should be 3-5x more common at night  
**Impact:** Missing atmospheric danger/night risk mechanic

### 3. 🔄 Animals Get Stuck in Hunting Circles (Overworld)
**Severity:** MEDIUM  
**Location:** `entities/animals.lua` lines 188-220  
**Issue:** Animals try to stay within hunting zones, causing them to circle/get stuck  
**Impact:** Visual bug, animals look unnatural, performance overhead from zone checks

### 4. 🎯 Spawn Probability Math Error
**Severity:** LOW  
**Location:** `states/hunting.lua` lines 419-430  
**Issue:** Spawn chances add up to 1.55 (155%) instead of 1.0 (100%)  
- Rabbit: 0.5 (50%)
- Deer: 0.3 (30%)  
- Boar: 0.15 (15%)
- Tiger: 0.95 (95%) ← This breaks the math!
**Impact:** Tiger spawn rate is even higher than intended, other animals rarely spawn

### 5. 💥 No Projectile Hit Feedback
**Severity:** LOW  
**Location:** `states/hunting.lua` checkProjectileHit()  
**Issue:** No visual/audio feedback when arrow hits animal  
**Impact:** Player doesn't know if they hit until health bar appears

### 6. 🎲 Spawn Probability Algorithm Flaw
**Severity:** MEDIUM  
**Location:** `states/hunting.lua` lines 424-428  
**Current Logic:**
```lua
for animalType, data in pairs(hunting.animalTypes) do
    cumulative = cumulative + data.spawnChance
    if roll <= cumulative then
        chosenType = animalType
        break
    end
end
```
**Issue:** Uses `pairs()` which has undefined iteration order - spawn rates are inconsistent!  
**Impact:** Sometimes rabbit spawns first, sometimes tiger, despite probabilities

## ✅ FIXES TO APPLY

### Fix 1: Normalize Tiger Spawn Rate + Day/Night Dynamic
```lua
-- In entities/animals.lua
huntingStats = {
    spawnChance = 0.05, -- 5% base rate (normalized)
    nightSpawnMultiplier = 4, -- 4x more common at night (20%)
    -- ... rest of stats
}
```

### Fix 2: Improve Spawn Algorithm (Weighted Random)
```lua
-- In states/hunting.lua spawnAnimal()
function hunting:spawnAnimal()
    -- Get day/night info for dynamic spawn rates
    local daynightSystem = require("systems/daynight")
    local isNight = daynightSystem.isNight or false
    
    -- Build weighted spawn table
    local spawnTable = {}
    local totalWeight = 0
    
    for animalType, data in pairs(hunting.animalTypes) do
        local weight = data.spawnChance
        
        -- Increase tiger spawn at night
        if animalType == "tiger" and isNight and data.nightSpawnMultiplier then
            weight = weight * data.nightSpawnMultiplier
        end
        
        table.insert(spawnTable, {type = animalType, weight = weight})
        totalWeight = totalWeight + weight
    end
    
    -- Weighted random selection
    local roll = math.random() * totalWeight
    local cumulative = 0
    local chosenType = "rabbit"
    
    for _, entry in ipairs(spawnTable) do
        cumulative = cumulative + entry.weight
        if roll <= cumulative then
            chosenType = entry.type
            break
        end
    end
    
    -- Rest of function...
end
```

### Fix 3: Remove Hunting Zone Steering (Overworld Animals)
```lua
-- In entities/animals.lua - REMOVE lines 188-220
-- Animals should wander freely, not get stuck in circles
-- Just keep world bounds check (lines 221-223)
```

## 🎯 TESTING CHECKLIST

After fixes:
- [ ] Tiger spawns ~5% during day (1 in 20 spawns)
- [ ] Tiger spawns ~20% at night (1 in 5 spawns)
- [ ] Rabbit spawns most frequently (~64% day, ~60% night)
- [ ] Overworld animals don't circle hunting zones
- [ ] Spawn algorithm is consistent (not random order)

## 📊 SPAWN PROBABILITY ANALYSIS

### BEFORE FIX (BROKEN - 155% total):
- Rabbit: 50%
- Deer: 30%
- Boar: 15%
- Tiger: 95% ← BREAKS MATH!

### AFTER FIX (Day - 100% total):
- Rabbit: 64.5% (0.5 / 0.775)
- Deer: 38.7% (0.3 / 0.775)
- Boar: 19.4% (0.15 / 0.775)
- Tiger: 6.5% (0.05 / 0.775)

### AFTER FIX (Night - 100% total):
- Rabbit: 53.2% (0.5 / 0.94)
- Deer: 31.9% (0.3 / 0.94)
- Boar: 16.0% (0.15 / 0.94)
- Tiger: 21.3% (0.2 / 0.94) ← 4x increase!

## 🤔 RECOMMENDATION: Polish Now or Move On?

### Arguments for POLISH NOW:
✅ **Hunting is a core mechanic** - Players will use it constantly  
✅ **Bugs are straightforward** - 2-3 hours to fix all issues  
✅ **Foundation for economy** - Hunting drives the game loop  
✅ **Tiger encounters are special** - Need proper balancing  
✅ **Code quality matters** - Spawn algorithm flaw affects reliability  

### Arguments for MOVE ON:
⚠️ **Other systems incomplete** - Farming/foraging need work  
⚠️ **Can polish later** - Not game-breaking bugs  
⚠️ **Feature-complete first** - Get all systems working  
⚠️ **Playtesting will reveal more** - Might need redesign anyway  

## 🎯 MY PROFESSIONAL RECOMMENDATION:

**FIX THE CRITICAL BUGS NOW (1 hour), MOVE ON TO OTHER SYSTEMS**

### Do These NOW:
1. ✅ **Fix tiger spawn rate** (5 min) - Game is unplayable with 95% tigers
2. ✅ **Add day/night spawn modifier** (15 min) - Easy win, big impact
3. ✅ **Fix spawn algorithm** (20 min) - Prevents future bugs
4. ✅ **Remove hunting zone steering** (10 min) - Visual bug fix

### Do These LATER (After MVP):
- ⏳ Hit feedback/visual polish
- ⏳ Advanced AI behaviors
- ⏳ More animal variety
- ⏳ Sound effects
- ⏳ Better animations

## 📝 RATIONALE:

The hunting system is **70% complete**. The bugs found are:
- 2 CRITICAL (spawn rate, algorithm)
- 2 MEDIUM (zone steering, night spawns)
- 2 LOW (feedback, minor polish)

**Fixing the critical bugs takes ~1 hour and prevents frustration.**  
**Polish can wait until after farming/foraging/shop are done.**

Then you can playtest the FULL GAME LOOP:
1. Hunt for meat/money
2. Farm for crops
3. Forage for items
4. Buy upgrades at shop
5. Survive tiger encounters

**Once the loop works, THEN polish everything based on real feedback.**

---

## 🎬 NEXT STEPS:

**OPTION A: Fix Critical Bugs (~1 hour)**
1. Normalize tiger spawn (5 min)
2. Add night spawn multiplier (15 min)
3. Fix spawn algorithm (20 min)
4. Remove zone steering (10 min)
5. Test hunting (10 min)
→ THEN move to farming system

**OPTION B: Move On Now**
1. Accept hunting is "good enough"
2. Build farming system (2 hours)
3. Build foraging polish (1 hour)
4. Build shop expansion (1 hour)
5. Come back to hunting polish later

**MY VOTE: OPTION A** ✅
