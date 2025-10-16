# 🎮 Quick Testing Guide - Hardcore Farming System

## How to Test the New System

### 1. **Start the Game**
```powershell
cd "c:\dev\Attempt one"
love .
```

### 2. **Initial Setup**
- You start with **20 coins** (visible in shop)
- No seeds - must buy from shop first
- Farm is located near cabin at coordinates (565, 325)

### 3. **Buy Your First Seed**
1. Walk to the cabin/shop area
2. Press **E** to enter shop (if near shopkeeper)
3. Press **B** for Buy mode
4. Use **UP/DOWN** arrows to select "Carrot Seeds" (15 coins)
5. Press **ENTER** to buy
6. Press **ESC** to exit shop

### 4. **Find the Farm**
- Walk to the farm area (brown rectangle near cabin)
- You should see a 2x3 grid of farm plots
- Watch the top-left corner for:
  - **Weather status** (starts with drought!)
  - **Soil quality** (terrible at 10-30%)
  - **Pest level** (high at 40%)

### 5. **Plant Your First Crop**
1. Stand near a farm plot
2. Press **E** to plant
3. You'll see:
   - Seed planted message with survival chance
   - Small green circle appears in plot
   - Water bar appears (empty!)

### 6. **Water the Crop (Critical!)**
⚠️ **Problem**: You need water but have no money left!
- Option A: Find water at pond (not implemented yet)
- Option B: Restart with more money for testing

### 7. **Watch the Crop (If you can water it)**
- Crop slowly grows over 2 minutes
- Watch for:
  - **Size increases** as it grows
  - **Color changes** based on health
  - **💀 symbol** if it dies
  - **Pest/disease indicators** (🐛 and 🦠)
  - **Water bar depleting** rapidly

### 8. **Harvest (If it survives)**
1. Wait until crop shows full size and green
2. Stand near the plot
3. Press **E** to harvest
4. You'll get 1-3 carrots worth 2 coins each
5. **Profit**: -15 coins seed + ~6 coins crop = -9 coins loss!

---

## Known Issues for Testing

### Issue 1: Not Enough Starting Money
**Current**: 20 coins = 1 seed + no water
**Problem**: Crops die without water
**Solution**: Either:
- Increase starting money temporarily for testing
- Implement free pond water collection

### Issue 2: Farm Location
- Farm coordinates: (565, 325)
- Make sure player spawns near this area
- Or add clear directions to find farm

### Issue 3: Visual Feedback
The farming system draws:
- At top-left corner (weather/stats)
- At farm location (565, 325)
- Make sure this doesn't overlap with other UI

---

## Expected Behavior

### ✅ **Working Features:**
- [x] Shop displays items with brutal prices
- [x] Can buy seeds (if you have money)
- [x] Can plant seeds at farm plots
- [x] Crops grow over time with visual feedback
- [x] Weather changes affect crops
- [x] Water level depletes rapidly
- [x] Pest damage accumulates
- [x] Crops can die from stress
- [x] Can harvest ready crops
- [x] Soil quality degrades over time

### ❌ **Common Test Failures:**
- Crop dies from lack of water (expected)
- Drought kills crop immediately (expected)
- Pest attack kills young crop (expected)
- Random failure at harvest (expected - 40% failure rate!)
- Economic death spiral (expected - seeds cost more than crops)

---

## Debug Commands to Add (Recommended)

Add these to `states/gameplay.lua` for easier testing:

```lua
-- In gameplay:keypressed function
elseif key == "m" then
    -- Give money for testing
    playerEntity.addMoney(100)
    print("💰 Added 100 coins for testing")
    
elseif key == "w" then
    -- Give water for testing
    playerEntity.addItem("water", 10)
    print("💧 Added 10 water for testing")
    
elseif key == "f" then
    -- Improve all soil for testing
    local farmingSystem = require("systems/farming")
    for i = 1, 6 do
        farmingSystem.plots[i].soilQuality = 0.8
    end
    print("🌱 Improved all soil to 80%")
```

---

## Performance Metrics to Watch

### FPS
- Should stay at 60 FPS
- Farming system updates 6 plots per frame
- Drawing is optimized

### Memory
- 6 plots + crop data = minimal memory
- Weather system = one timer
- No memory leaks expected

---

## Next Steps After Testing

1. **Balance adjustments** if needed:
   - Increase starting money?
   - Reduce seed costs?
   - Improve initial soil quality?
   
2. **Add pond water collection** (free water source)

3. **Tutorial messages** for first-time players

4. **Achievement tracking** for successful harvests

---

**Remember**: The system is SUPPOSED to be brutal. Crop deaths and failures are features, not bugs!