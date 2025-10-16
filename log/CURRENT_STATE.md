# Current Game State & Next Steps

**Last Updated:** October 15, 2025  
**Version:** MVP (Minimal Viable Product)  
**Status:** Core systems working, hunting system 90% complete (has re-entry bug)

---

## ✅ What's Working

### Core Systems
- [x] **Player movement** - Arrow keys to walk around world
- [x] **Inventory system** - Consolidated array-based storage
- [x] **Money system** - Earn/spend with $ formatting
- [x] **Area transitions** - Move between areas (working in code)
- [x] **Day/night cycle** - Time progression system

### Farming Loop (Complete)
- [x] **Plant seeds** - Press E on farm plot (costs 1 seed)
- [x] **Water crops** - Press Q on farm plot (needs 3 water)
- [x] **Harvest crops** - Press E when ready (yields 1-2 items)
- [x] **Growth tracking** - 60-120 second grow times
- [x] **Visual feedback** - See crop growth, water levels

### Shop System (Complete)
- [x] **Buy items** - Press B at railway, use UP/DOWN/ENTER
- [x] **Sell items** - Press S in shop, use number keys 1-9
- [x] **Sell all** - Press A to sell everything at once
- [x] **Balanced pricing** - Farming barely profitable, hunting lucrative

### Starting Resources
- Money: $30
- Seeds: 3 carrot seeds
- Water: 2 buckets

### Hunting System (90% Complete) ⚠️
- [x] **First-person DOOM-style hunting** - Complete with mouse aiming, crosshair
- [x] **3 weapons** - Bow (free), Rifle ($200), Shotgun ($350)
- [x] **Limited ammo** - Arrows $15/10, Bullets $25/10, Shells $30/10
- [x] **4 animal types** - Rabbit $15, Deer $30, Boar $50, Tiger $100 (fear mechanic)
- [x] **Zone-based hunting** - 3 circular zones on map with prompts
- [x] **180-second sessions** - Timed hunting with score tracking
- [x] **Shop integration** - Buy weapons/ammo, sell meat
- [ ] **RE-ENTRY BUG** - Can't enter hunting after first session (CRITICAL)
- [ ] **Shop scrolling** - UI overlaps, needs testing

---

## ❌ What's Missing

### Critical (Blocks Gameplay)
- [ ] **Hunting re-entry bug** - Player can't enter hunting zones after first visit
  - Root cause: State management or validation issue
  - Fix attempted: Moved hunting.active flag after validation
  - Status: Needs debugging and testing

- [ ] **Foraging visibility** - Items spawn but not visible
  - Need: Either show items on ground OR show prompt when near
  - Need: "Press R to collect berries" type interaction
  - Prices ready: Berries $6, Herbs $8, Nuts $5

### Important (Improves Experience)
- [ ] **Player goals** - No objective or win condition
  - Suggestion: "Earn $100 to win" or "Survive 3 days"
  - Need: UI showing progress toward goal

- [ ] **Pond interactions** - Free water collection
  - Need: "Press G to get water (5x)" at pond
  - Currently in code but needs testing

- [ ] **Visual polish** - Actions feel flat
  - Need: Particle effects for planting/harvesting
  - Need: Sound effects for actions
  - Need: Better UI feedback

### Nice to Have (Future Updates)
- [ ] **Save/load system** - Lose progress on exit
- [ ] **Tutorial** - No explanation of controls
- [ ] **Keyboard guide** - What keys do what?
- [ ] **Crop variety** - Only carrots currently plantable
- [ ] **Nutrition system** - Hunger exists but no food effects

---

## 🎮 Controls Reference

### Movement
- **Arrow Keys** - Walk around
- **ENTER** - Enter hunting zones/areas

### Farming (at farm plots: 575, 335)
- **E** - Plant seeds OR harvest ready crops
- **Q** - Water crops

### Trading (at railway station)
- **B** - Open shop
- **In Shop:**
  - **B** - Buy mode
  - **S** - Sell mode
  - **UP/DOWN** - Select item (buy mode)
  - **ENTER** - Confirm purchase
  - **1-9** - Sell specific item (sell mode)
  - **A** - Sell ALL items
  - **ESC** - Close shop

### Other
- **I** - Open inventory
- **F4** - Toggle asset map
- **ESC** - Close menus

---

## 📊 Economy Balance

### Farming Economics
| Item | Buy Price | Sell Price | Time | Net Profit |
|------|-----------|------------|------|------------|
| Carrot Seeds | $10 | - | - | -$10 |
| Carrot Crop | - | $4 | 60s | +$4 |
| **Net Result** | **-$10** | **+$4-8** | **~60s+** | **-$6 to -$2** |

**Farming is a GRIND:** Need 3+ crop yield to break even!

### Hunting Economics (Not Implemented Yet)
| Animal | Sell Price | Risk | Time | Net Profit |
|--------|-----------|------|------|------------|
| Rabbit | $15 | Low | ~10s | +$15 |
| Deer | $30 | Medium | ~20s | +$30 |
| Boar | $50 | High | ~30s | +$50 |
| Tiger | $100 | Very High | ~45s | +$100 |

**Hunting is PROFITABLE:** 3-10x better than farming!

### Foraging Economics (Not Visible Yet)
| Item | Sell Price | Risk | Time | Net Profit |
|------|-----------|------|------|------------|
| Berries | $6 | None | ~5s | +$6 |
| Herbs | $8 | None | ~5s | +$8 |
| Nuts | $5 | None | ~5s | +$5 |

**Foraging is SAFE:** Low but steady income.

---

## 🔧 Known Issues

### Bugs
- None currently! Recent refactor fixed major crashes.

### UX Issues
1. **No tutorial** - Players don't know what to do
2. **Unclear controls** - Which keys do what?
3. **No feedback** - Actions are silent
4. **No goal** - What are we working toward?

### Technical Debt
1. **Save system broken** - Uses deprecated Lua functions
2. **Camera system unused** - Code exists but not integrated
3. **Collision system** - Only partially used
4. **Commented features** - Weather, diseases, nutrition all disabled

---

## 🚀 Recommended Next Steps

### Phase 1: Make It Playable (1-2 hours)
1. **Implement hunting mechanic**
   - Detect player near animals
   - Show "Press H to hunt" prompt
   - Success/fail chance (50-80% based on animal)
   - Drop meat item on success
   - Small stamina cost

2. **Fix foraging visibility**
   - Either: Draw items on ground
   - Or: Show prompt when near items
   - Test collection works

3. **Add player goal**
   - Simple: "Earn $100 to win"
   - Display in UI corner
   - Victory screen when achieved

### Phase 2: Polish It (2-3 hours)
4. **Add visual feedback**
   - Particle effects for planting/harvesting
   - Screen shake for hunting
   - Color flash for money changes

5. **Add audio feedback**
   - Plant sound (whoosh)
   - Harvest sound (pop)
   - Coin sound (cha-ching)
   - Hunt sounds (animal cries)

6. **Tutorial overlay**
   - Show on first play
   - Explain: Farm, Hunt, Shop
   - List all controls

### Phase 3: Expand It (Future)
7. **More crop types**
   - Enable potato seeds ($15, 90s, $7)
   - Enable mushroom spores ($20, 120s, $10)
   - Different plot behaviors

8. **Player progression**
   - Better tools (faster farming)
   - Hunting weapons (higher success)
   - Upgrades (more inventory slots)

9. **Save/load system**
   - Fix deprecated functions
   - Auto-save on area transition
   - Load on game start

---

## 📁 File Organization

### Critical Files (Touch Often)
```
entities/player.lua       - Inventory, stats, money
states/gameplay.lua       - Main game loop, interactions
states/shop.lua           - Trading system
systems/farming.lua       - Crop mechanics
```

### Important Files (Touch Sometimes)
```
systems/world.lua         - Structures, collision
systems/areas.lua         - Area management
systems/hunting.lua       - Animal spawning (needs work!)
systems/foraging.lua      - Item spawning (needs visibility!)
```

### Utility Files (Rarely Touch)
```
systems/daynight.lua      - Time system
systems/audio.lua         - Sound manager
utils/camera.lua          - Camera (unused)
utils/collision.lua       - Collision helpers
libs/                     - Third-party libraries
```

---

## 🎯 Success Metrics

The game is "done" when:
- [x] Player can farm (plant → water → harvest → sell)
- [ ] Player can hunt (find → attempt → succeed → sell)
- [ ] Player can forage (find → collect → sell)
- [ ] Player has a goal (earn $X or survive X days)
- [ ] Controls are explained (tutorial or help screen)
- [ ] Actions give feedback (sounds, particles, messages)
- [ ] Progress is saved (don't lose work on quit)

**Current Progress: 2/7 complete (29%)**

---

## 💡 Design Philosophy

### MVP First
- Get ONE complete gameplay loop working
- Then add features one at a time
- Don't build everything at once

### Risk vs Reward
- Safe activities (farming) = low profit
- Risky activities (hunting) = high profit
- Player chooses their playstyle

### No Grinding Required
- Farming alone is HARD (intentional!)
- Forces players to try hunting/foraging
- Multiple income sources = more fun

---

**Ready to continue? Start with Phase 1, Step 1: Implement hunting mechanic!**
