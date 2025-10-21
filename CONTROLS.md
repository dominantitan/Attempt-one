# Game Controls Reference
**Updated:** October 21, 2025

## 🚫 RESERVED KEYS - NEVER USE FOR ACTIONS!

These keys are EXCLUSIVELY for movement and must NEVER be used for actions:

- **W** - Move UP only
- **A** - Move LEFT only
- **S** - Move DOWN only
- **D** - Move RIGHT only
- **Arrow Keys** (↑←↓→) - Alternative movement

## ✅ SAFE ACTION KEYS

Use these keys for all game actions (they don't conflict with movement):

### Main Actions
- **E** - Context action (Plant, Harvest, Examine)
- **Q** - Water crops
- **R** - Forage wild crops
- **F** - Fish / Warm up by fire
- **G** - Get free water from pond
- **T** - Debug: Force spawn crops

### Menu/UI
- **I** - Open inventory
- **B** - Shop: Buy mode / Open shop at railway
- **V** - Shop: Sell mode (was S)
- **X** - Shop: Open interior shop (was S)
- **L** - Shop: Liquidate (sell all) (was A)
- **Escape** - Pause / Close menus
- **Enter** - Enter hunting zones / Confirm / Sleep

### Interior Cabin
- **Z** - Sleep in bed
- **C** - Access storage
- **X** - Open shop
- **E** - Examine items
- **F** - Warm up by fire

### Hunting Mode
- **1** - Switch to Bow
- **2** - Switch to Rifle
- **3** - Switch to Shotgun
- **Mouse Click** - Shoot
- **Enter/Escape** - Exit hunting

### Shop Mode
- **B** - Buy tab
- **V** - Sell tab
- **↑/↓** - Navigate items
- **Enter** - Confirm purchase
- **1-9** - Quick sell item by number
- **L** - Liquidate (sell all items)

## 🎮 Control Philosophy

### Rule #1: Movement vs Actions
**NEVER** use WASD for actions! They are exclusively for continuous movement.

### Rule #2: Contextual Keys
Keys like E, F, Q, R work near specific structures:
- E = Generic "use" action (context-sensitive)
- Q = Specific action (watering)
- F = Special actions (fishing, warmth)
- G = Gathering (water)
- R = Resource collection (foraging)

### Rule #3: Menu Keys
Non-movement keys for UI:
- I = Inventory
- B = Buy/Shop
- V = Sell/Vendor
- X = eXamine/interior shops
- L = Liquidate

## 📝 Key Binding History

### October 21, 2025 - Major Control Fixes

**Problems Fixed:**
1. W key was used for BOTH up movement AND watering → auto-watering bug
2. S key was used for BOTH down movement AND shop sell mode → conflict
3. A key was used for BOTH left movement AND sell all → conflict

**Changes Made:**
- ❌ Removed W from watering (now Q only)
- ❌ Changed shop sell mode from S to V
- ❌ Changed interior shop from S to X
- ❌ Changed "sell all" from A to L
- ✅ All movement keys now exclusively for movement

## 🛡️ Developer Guidelines

When adding new features:

### ✅ DO:
- Use keys from safe list: E, Q, R, F, G, T, I, B, V, X, L, Z, C, etc.
- Use number keys (1-9) for quick actions
- Use Enter/Space for confirmations
- Use Escape for cancel/back

### ❌ DON'T:
- Use W, A, S, D for ANY actions
- Use arrow keys for actions
- Create key conflicts between states
- Use same key for continuous and one-time actions

### Testing Checklist:
1. Can player move freely while near interactive objects?
2. Does pressing movement keys trigger unintended actions?
3. Does the key work in all relevant game states?
4. Is the key intuitive for the action?

## 🎯 Quick Reference Card

```
╔════════════════════════════════════════╗
║     DARK FOREST SURVIVAL - CONTROLS    ║
╠════════════════════════════════════════╣
║ MOVEMENT                               ║
║  W/↑  - Move Up                        ║
║  A/←  - Move Left                      ║
║  S/↓  - Move Down                      ║
║  D/→  - Move Right                     ║
╠════════════════════════════════════════╣
║ FARMING                                ║
║  E - Plant/Harvest                     ║
║  Q - Water crops (NOT W!)              ║
║  R - Forage wild crops                 ║
╠════════════════════════════════════════╣
║ POND                                   ║
║  F - Fish                              ║
║  G - Get free water (5x)               ║
╠════════════════════════════════════════╣
║ SHOP/TRADE                             ║
║  B - Buy mode                          ║
║  V - Sell mode                         ║
║  L - Liquidate (sell all)              ║
║  ↑↓ - Navigate                         ║
║  Enter - Confirm                       ║
╠════════════════════════════════════════╣
║ HUNTING                                ║
║  Enter - Enter hunting zone            ║
║  1/2/3 - Switch weapons                ║
║  Mouse - Aim                           ║
║  Click - Shoot                         ║
║  Escape - Exit                         ║
╠════════════════════════════════════════╣
║ CABIN                                  ║
║  Z - Sleep in bed                      ║
║  C - Storage                           ║
║  X - Interior shop                     ║
║  E - Examine                           ║
╠════════════════════════════════════════╣
║ MENU                                   ║
║  I - Inventory                         ║
║  Escape - Pause/Close                  ║
╚════════════════════════════════════════╝
```

## 💡 Tips

1. **No Auto-Actions:** Movement keys will NEVER trigger actions
2. **Context Sensitive:** Same key (E, F) does different things in different places
3. **Visual Prompts:** Game shows what keys to press when near objects
4. **Focus Bug Fixed:** Mouse leaving window properly pauses/unpauses game

---

**Remember:** WASD = Movement ONLY, never actions!
