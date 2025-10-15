# 🌾 MVP Farming Game - Development Status

## ✅ SIMPLIFIED TO MVP

All complex systems have been **commented out** (not deleted) for future implementation. The game now focuses on the core gameplay loop.

---

## 🎯 CURRENT MVP FEATURES

### **Simple Farming System**
- ✅ Plant seeds in 2x3 farm grid
- ✅ Water crops to speed growth
- ✅ Harvest when ready
- ✅ Visual growth progression
- ✅ Simple water level indicator

### **Balanced Economy**
- ✅ Start with 50 coins
- ✅ Seeds cost 5-10 coins
- ✅ Crops sell for 8-15 coins
- ✅ **Profitable farming** - you make money!

### **Core Gameplay Loop**
```
Start (50 coins)
  ↓
Buy Seeds (5 coins) + Water (2 coins)
  ↓
Plant & Water crops
  ↓
Wait 30-60 seconds
  ↓
Harvest (2-4 crops)
  ↓
Sell crops (16-60 coins)
  ↓
Profit! Buy more seeds
```

---

## 📊 CROP DETAILS (MVP)

| Crop     | Seed Cost | Grow Time | Water Needed | Yield | Sell Price | Profit/Cycle |
|----------|-----------|-----------|--------------|-------|------------|--------------|
| Carrot   | 5 coins   | 30s       | 2 waters     | 2-4   | 8 ea       | +11-27 coins |
| Potato   | 8 coins   | 45s       | 3 waters     | 2-4   | 12 ea      | +16-40 coins |
| Mushroom | 10 coins  | 60s       | 2 waters     | 2-4   | 15 ea      | +20-50 coins |

**Water cost**: 2 coins per bucket

---

## 🎮 HOW TO PLAY (MVP)

### 1. **Buy Seeds**
- Enter shop (walk to shopkeeper)
- Press `B` for Buy mode
- Use arrow keys to select seeds
- Press ENTER to purchase

### 2. **Plant Crops**
- Walk to farm plots (brown 2x3 grid)
- Stand near a plot
- Press `E` to plant
- Crop appears as small green circle

### 3. **Water Crops**
- Buy water from shop (2 coins)
- Stand near planted crop
- Press `Q` to water
- Blue bar shows water level

### 4. **Harvest**
- Wait for crop to fully grow
- Crop turns bright green when ready
- Press `E` to harvest
- Get 2-4 crops added to inventory

### 5. **Sell Harvest**
- Enter shop
- Press `S` for Sell mode
- Press first letter of crop name to sell
- Get coins!

---

## 💰 STARTER STRATEGY

### First Cycle (50 starting coins):
1. Buy 3 carrot seeds (15 coins)
2. Buy 2 water buckets (4 coins)
3. Plant all 3 seeds
4. Water each twice (6 water = buy 1 more)
5. Wait 30 seconds
6. Harvest 6-12 carrots
7. Sell for 48-96 coins
8. **Profit: 48-96 coins** (almost double!)

### Scaling Up:
- Use profits to buy more expensive seeds
- Potatoes and mushrooms are more profitable
- Fill all 6 plots for maximum efficiency
- Always keep some money for water

---

## 🗺️ GAME CONTROLS

| Key | Action |
|-----|--------|
| WASD | Move player |
| E | Plant/Harvest at farm, Enter shop |
| Q | Water crops |
| ESC | Exit shop/menus |
| B | Buy mode in shop |
| S | Sell mode in shop |
| Arrow Keys | Navigate shop items |

---

## 📂 CODE STRUCTURE

### Simplified Systems:
```
systems/farming.lua
  ├─ Simple crop growth (no weather/pests)
  ├─ Basic water mechanics
  ├─ Straightforward harvest
  └─ [Complex features commented out]

states/shop.lua
  ├─ Fair pricing
  ├─ Profitable economy
  └─ [Hardcore mode commented out]

entities/player.lua
  ├─ 50 starting coins
  └─ [20 coin hardcore mode commented out]
```

### Commented Out (For Future):
- ❌ Weather system (drought, storms, frost)
- ❌ Pest attacks
- ❌ Disease outbreaks
- ❌ Soil quality degradation
- ❌ Crop stress mechanics
- ❌ Random crop failures
- ❌ Complex visual indicators
- ❌ Brutal economy

---

## 🔧 DEVELOPMENT ROADMAP

### ✅ Phase 1: MVP (CURRENT)
- [x] Basic plant/water/harvest loop
- [x] Simple shop with balanced prices
- [x] Visual crop growth
- [x] Profitable economy
- [ ] **TEST: Verify full gameplay loop works**

### 🔲 Phase 2: Core Features
- [ ] Add more crop types
- [ ] Implement foraging properly
- [ ] Add hunting mechanics
- [ ] Create day/night cycle effects
- [ ] Build cabin interior

### 🔲 Phase 3: Polish
- [ ] Add sprites (replace rectangles)
- [ ] Create animations
- [ ] Add sound effects
- [ ] Implement save/load
- [ ] Tutorial system

### 🔲 Phase 4: Hardcore Mode
- [ ] Uncomment weather system
- [ ] Enable pest/disease mechanics
- [ ] Activate soil degradation
- [ ] Switch to brutal economy
- [ ] Add failure states

---

## 🐛 KNOWN ISSUES (TO FIX)

1. ~~Farm coordinates need to match world.lua~~ ✅ FIXED
2. ~~Player starting money too low~~ ✅ FIXED (now 50)
3. ~~Seed prices too expensive~~ ✅ FIXED (now 5-10)
4. ~~Crop values too low~~ ✅ FIXED (now 8-15)
5. Need to test full buy → plant → harvest → sell loop

---

## 📝 TESTING CHECKLIST

- [ ] Start game with 50 coins
- [ ] Buy carrot seeds (5 coins)
- [ ] Buy water (2 coins)
- [ ] Plant seed in farm plot
- [ ] Water crop twice
- [ ] Wait 30 seconds for growth
- [ ] Harvest crop (get 2-4 carrots)
- [ ] Sell carrots in shop (get 16-32 coins)
- [ ] Verify profit margin
- [ ] Repeat cycle to confirm loop works

---

## 🎯 SUCCESS CRITERIA

### MVP is complete when:
1. ✅ Player can buy seeds
2. ✅ Player can plant seeds
3. ✅ Crops grow over time
4. ✅ Player can water crops
5. ✅ Player can harvest ready crops
6. ✅ Player can sell harvest
7. ✅ Farming is profitable
8. ⏳ **Full loop tested and working**

---

## 💡 FUTURE EXPANSIONS (Commented Out Code)

All hardcore features are preserved in code comments marked with:
```lua
--[[ HARDCORE MODE - COMMENTED OUT FOR MVP
    ... complex code here ...
--]]
```

To re-enable hardcore mode later:
1. Uncomment weather system in `farming.update()`
2. Uncomment stress mechanics in `farming.plantSeed()`
3. Uncomment complex yield in `farming.harvestCrop()`
4. Switch shop prices to hardcore values
5. Reduce starting money to 20 coins

---

## 📊 COMPARISON: MVP vs HARDCORE

| Feature | MVP | Hardcore Mode |
|---------|-----|---------------|
| Starting Money | 50 coins | 20 coins |
| Seed Cost | 5-10 | 15-40 |
| Crop Value | 8-15 | 2-8 |
| Grow Time | 30-60s | 90-180s |
| Failure Rate | 0% | 30-50% |
| Weather | None | Active |
| Pests | None | Active |
| Disease | None | Active |
| Profit Margin | +200-400% | -50 to -200% |

---

**The MVP is designed to be fun, learnable, and rewarding. Hardcore mode can be enabled later for experienced players seeking a brutal challenge.**