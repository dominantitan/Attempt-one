# Farming Balance & Bug Check - Update Log

## Date: Current Session

## User Requests Investigation

### 1. ✅ Plants Growing by Time (Not Player Presence)
**Status:** Already working correctly!

**How it works:**
- `systems/farming.lua` has an `update(dt)` function that accumulates growth time for all crops
- In `main.lua` line 235, `farmingSystem.update(dt)` is called GLOBALLY every frame
- This means crops grow continuously regardless of player position or current area
- Growth formula: `crop.growthTime = crop.growthTime + (dt * growthSpeed)`
- `growthSpeed` is 1.0 if watered, 0.0 if not watered (this is intentional game design)

**No changes needed** - The system already works as requested!

---

### 2. ✅ Snake Death Message Bug
**Status:** Already fixed!

**How it works:**
- `states/death.lua` supports multiple death causes via parameter: `death:enter(from, deathCause)`
- When snake bites player in `states/fishing.lua` line 642: `gamestate.switch("death", "snake")`
- Death screen correctly displays:
  - If `death.cause == "snake"`: Shows "🐍 The water snake bit you!"
  - Otherwise: Shows "🐅 The tiger caught you!"

**No changes needed** - The bug was already fixed in a previous session!

---

### 3. ✅ Farming Profitability Balance
**Status:** FIXED - Crop sell prices increased!

#### Previous Economics (Too Low):
```
Carrot:   Seeds $10 → Harvest 2-4 @ $4  = $8-16  → Net: -$2 to +$6 profit
Potato:   Seeds $15 → Harvest 3-5 @ $7  = $21-35 → Net: +$6 to +$20 profit
Mushroom: Seeds $20 → Harvest 2-3 @ $10 = $20-30 → Net: $0 to +$10 profit
```

#### NEW Economics (More Profitable):
```
Carrot:   Seeds $10 → Harvest 2-4 @ $8  = $16-32 → Net: +$6 to +$22 profit (Avg: +$14)
Potato:   Seeds $15 → Harvest 3-5 @ $12 = $36-60 → Net: +$21 to +$45 profit (Avg: +$33)
Mushroom: Seeds $20 → Harvest 2-3 @ $15 = $30-45 → Net: +$10 to +$25 profit (Avg: +$17.5)
```

#### Comparison with Other Income Sources:

**Fishing** (Skill-based, medium-high income):
- Small fish: $5
- Bass: $12
- Catfish: $20
- Rare trout: $35

**Hunting** (Dangerous, high income):
- Rabbit: $15-20
- Deer: $40-60
- Boar: $70-100

**Foraging** (Easy, reliable income):
- Berries: $6
- Herbs: $8
- Nuts: $5
- Mushrooms: $15 (now matches farmed mushrooms)

#### Design Balance:
✅ Farming is now **more profitable than foraging**
✅ Farming is still **less profitable than fishing** (fishing can earn $35 per catch)
✅ Farming is still **much less profitable than hunting** (hunting earns $15-100 per animal)
✅ Farming requires **time investment** (10-15 minutes per crop cycle) and **daily watering**

---

## Files Modified

### `states/shop.lua`
**Changes:**
1. Increased carrot sell price: $4 → $8 (2x)
2. Increased potato sell price: $7 → $12 (1.7x)
3. Increased mushroom sell price: $10 → $15 (1.5x, both foraged and farmed)
4. Updated shop item descriptions with new prices
5. Updated grow times in descriptions (60s → 10 min, etc. to match actual game time)
6. Updated comments to reflect "MEDIUM value" for crops

**Lines modified:**
- Line 15-17: Shop item descriptions
- Line 68: Foraged mushroom price
- Line 71-72: Farmed crop prices

---

## Testing Recommendations

### 1. Test Crop Growth Timing
- Plant a crop at Day 1, 6:00 AM
- Leave the farm area and go hunting/fishing for 10+ real minutes
- Return to farm and verify crop has grown (should be ready after 10 min for carrots)
- This confirms crops grow based on time, not player presence

### 2. Test Snake Death Message
- Go fishing at the pond
- Let the water snake bite your feet (move away from land)
- Verify death screen shows: "🐍 The water snake bit you!" (not tiger message)

### 3. Test Farming Profitability
- Buy carrot seeds ($10), plant, water, wait 10 min, harvest (2-4 carrots @ $8 each)
- Expected profit: $6-22 per plot
- Buy potato seeds ($15), plant, water, wait 12.5 min, harvest (3-5 potatoes @ $12 each)
- Expected profit: $21-45 per plot
- Buy mushroom spores ($20), plant, water, wait 15 min, harvest (2-3 mushrooms @ $15 each)
- Expected profit: $10-25 per plot

### 4. Compare Income Rates
- Farming: ~$20/plot every 10-15 minutes (with 12 plots = ~$240 per cycle)
- Fishing: ~$15-35 per catch (every 30-60 seconds with skill)
- Hunting: ~$40-100 per animal (every 2-5 minutes with danger)

---

## Summary

✅ **All three user requests were already working or have been fixed:**
1. Crops grow by time (not player presence) - Already working
2. Snake death message - Already fixed
3. Farming profitability - NOW FIXED (prices increased 1.5-2x)

🎮 **Game Balance Achievement:**
- Farming is now a **viable income source** for players who prefer low-risk gameplay
- Still requires **time investment** and **daily maintenance** (watering)
- **Less lucrative** than fishing/hunting, but **more predictable** and **safer**
- **Better than foraging** for dedicated farmers

📊 **Economic Hierarchy (Profit per Time):**
1. Hunting: $40-100 per kill (HIGH risk, HIGH reward)
2. Fishing: $5-35 per catch (MEDIUM risk, MEDIUM-HIGH reward)
3. Farming: $20-40 per harvest (LOW risk, MEDIUM reward, requires investment)
4. Foraging: $5-15 per item (NO risk, LOW reward, immediate)
