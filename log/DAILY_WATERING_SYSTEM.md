# Daily Watering System Implementation
**Date:** October 19, 2025  
**Feature:** Crops require daily watering or they stop growing

---

## 🌱 Overview

Implemented a **daily watering requirement** where crops completely stop growing if not watered each day. This adds active gameplay and prevents "plant and forget" farming.

---

## ⚙️ Technical Implementation

### 1. **Plot Tracking**
Added `lastWateredDay` field to each plot:
```lua
plot = {
    crop = {...},
    waterLevel = 0,
    lastWateredDay = -1, -- Tracks which day plot was last watered
    wateredRecently = false,
    wateredTime = 0
}
```

### 2. **Growth Logic Update**
Modified `farming.update()` to check daily watering:
```lua
local currentDay = math.floor(daynightSystem.dayCount or 0)
local wateredToday = (plot.lastWateredDay == currentDay)

if wateredToday then
    -- Normal growth (0.1x or 1.0x based on water level)
    if plot.waterLevel >= cropType.waterNeeded then
        growthSpeed = 1.0 -- Full speed
    else
        growthSpeed = 0.1 -- Slow growth
    end
else
    -- NOT watered today - STOPS GROWING!
    growthSpeed = 0.0
    crop.needsWater = true -- Visual warning flag
end
```

### 3. **Watering Function**
Updated `farming.waterCrop()` to track day:
```lua
local currentDay = math.floor(daynightSystem.dayCount or 0)
plot.lastWateredDay = currentDay -- Mark as watered today
plot.waterLevel = plot.waterLevel + 1
crop.needsWater = false -- Clear warning flag
```

### 4. **Planting Initialization**
Updated `farming.plantSeed()` to set initial state:
```lua
plot.lastWateredDay = currentDay -- Consider planted day as watered
plot.waterLevel = 0
crop.needsWater = false
```

---

## 🎨 Visual Indicators

### Red Warning Ring (Needs Water)
When crop hasn't been watered today:
```lua
if crop.needsWater then
    -- Pulsing red circles
    local pulse = 0.5 + (math.sin(time * 4) * 0.5)
    love.graphics.setColor(1, 0.2, 0.2, pulse)
    love.graphics.circle("line", centerX, centerY, 16)
    love.graphics.circle("line", centerX, centerY, 18) -- Double ring
end
```

**Visual Effect:**
- Double red rings around crop
- Pulses at 4 Hz for visibility
- Only appears when `needsWater = true`
- Cleared when watered

### Console Feedback
```
🌱 Planted carrot
💧 Remember to water every day or growth will stop!

💧 Watered (3/3) ✓ Fully watered!
```

---

## 📊 Growth Time Calculations

### In-Game Days (1 day = 300 seconds / 5 minutes)

**Carrot:**
- Total time: 600 seconds = 2 days
- Must water: Day 0, Day 1
- Ready: End of Day 2

**Potato:**
- Total time: 750 seconds = 2.5 days
- Must water: Day 0, Day 1, Day 2
- Ready: Middle of Day 3

**Mushroom:**
- Total time: 900 seconds = 3 days
- Must water: Day 0, Day 1, Day 2
- Ready: End of Day 3

### Growth Scenarios

**Scenario 1: Perfect Watering**
```
Day 0: Plant + Water → Grows 300s
Day 1: Water → Grows 300s
Day 2: Water → Grows 300s (600s total, READY!)
```

**Scenario 2: Missed Day**
```
Day 0: Plant + Water → Grows 300s
Day 1: FORGOT TO WATER → 0 growth (red warning)
Day 2: Water → Grows 300s (only 300s total)
Day 3: Water → Grows 300s (600s total, READY!)
```

**Scenario 3: Insufficient Water**
```
Day 0: Water 1/3 times → Slow growth (0.1x = 30s)
Day 1: Water 2/3 times → Slow growth (0.1x = 30s)
Day 2: Water 3/3 times → Full growth (1.0x = 300s)
Day 3+: Continue until 600s total reached
```

---

## 🎮 Gameplay Impact

### Active Management Required
- Players must check farm daily
- Sleeping advances day (resets watering status)
- Forgotten crops don't die, but pause growth
- Strategic decision: farm vs hunt each day

### Water Resource Management
**Water Sources:**
- Pond (unlimited, press G)
- Shop purchase (limited stock)
- Starting inventory (2 water)

**Water Requirements per Crop:**
- Carrot: 3 water per day
- Potato: 4 water per day
- Mushroom: 3 water per day

**Farm Full Capacity (6 plots):**
- All carrots: 18 water/day
- All potatoes: 24 water/day
- Mixed farm: ~20 water/day average

### Risk vs Reward
**Farming Benefits:**
- Reliable food source
- Sells for profit
- Safe (no danger)

**Farming Costs:**
- Daily time investment
- Water trips to pond
- Slower than hunting income

**Balancing:**
- Hunting = high risk, high reward, fast
- Farming = low risk, medium reward, slow + daily work
- Foraging = zero risk, low reward, random

---

## 🐛 Edge Cases Handled

### 1. **Planting Day = Day 0**
- `lastWateredDay = currentDay` on plant
- Crop starts growing immediately
- First "real" watering needed Day 1

### 2. **Multiple Waters Same Day**
- `lastWateredDay` only tracks day, not count
- Multiple waters increase `waterLevel`
- Only one water per day needed (more = faster growth)

### 3. **Day Transitions**
- When day advances (sleep or time passes):
  - `wateredToday` check fails for previous day
  - Crop stops growing until next water
  - Red warning appears automatically

### 4. **Harvest Before Full Growth**
- Can't harvest unready crops
- Message shows time remaining
- Shows water status in message

---

## 💡 Player Strategies

### Efficient Farming
1. Morning routine: Water all plots
2. Go hunting/foraging during day
3. Return for harvest when ready
4. Sleep to advance to next day
5. Repeat

### Water Conservation
- Get 10 water from pond (free)
- Water 3 plots per trip
- 2 trips = full farm watered

### Multi-Day Crops
- Carrots ready in 2 days
- Potatoes ready in 2.5 days
- Mushrooms ready in 3 days
- Stagger planting for daily harvests

---

## 📈 Balance Considerations

### Growth Times vs Day Length
- 1 day = 5 real minutes
- 2 days = 10 minutes (carrot)
- 3 days = 15 minutes (mushroom)
- Reasonable wait time with other activities

### Watering Frequency
- Daily = active but not tedious
- Missing a day = significant penalty (0 growth)
- Not instant death (can recover)

### Water Availability
- Pond unlimited = no hard cap
- Shop limited = strategic backup
- Walk distance = time cost

---

## 🎯 Future Enhancements (Not Implemented)

### Crop Death System
- 2+ days without water = crop dies
- Withered visual state (brown/dead)
- Must replant from scratch
- Higher stakes for neglect

### Rain Weather
- Random rain events
- Auto-waters all crops
- Skip watering that day
- Weather forecast system

### Sprinkler Upgrade
- Shop item: $150
- Auto-waters adjacent plots
- Limited range (3x3 area)
- Requires water can refills

### Fertilizer System
- Speeds up growth (1.5x)
- Reduces water needs (2 instead of 3)
- Craftable or purchasable
- Single use per crop

---

## ✅ Testing Checklist

- [x] Crop grows when watered today
- [x] Crop stops when not watered today
- [x] Red warning appears when needs water
- [x] Warning disappears after watering
- [x] `lastWateredDay` updates correctly
- [x] Day transitions reset watering status
- [x] Planting initializes watering state
- [x] Multiple waters same day work
- [x] Water level bar updates
- [x] Console messages show water status

---

## 🚀 Status

**Implementation:** Complete ✅  
**Testing:** Ready for user testing  
**Documentation:** Complete  

**Next Steps:**
1. User test the daily watering system
2. Adjust growth times if needed
3. Continue with shop stock system (Option A remaining)

---

**Growth Times Summary:**
- 🥕 Carrot: 2 days (10 min real time)
- 🥔 Potato: 2.5 days (12.5 min real time)
- 🍄 Mushroom: 3 days (15 min real time)

**Watering Required:** Every in-game day or growth pauses!
