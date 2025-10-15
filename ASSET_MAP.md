# 🗺️ Game World Map - Asset Reference Guide

## 📍 Main World Layout (960x540 pixels)

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                                                                                │
│    🌲                      🏠 Cabin                    🌲         🌲         │
│  🌲   🌲                  (220, 150)                 🌲                        │
│                          [80x60px]                                            │
│  🌲        🌲                                                    🌲           │
│                                                                               │
│            💧 Pond                                                            │
│           (280, 450)                       🌾🌾🌾 Farm Grid                  │
│          [60x40 oval]                     (575, 325)                         │
│                                           [2x3 plots]                         │
│                                           Each: 32x32px                       │
│  🌲                                                                           │
│                                                                    🌲         │
│                    🏪 Shop Interior                                           │
│                   (inside cabin)                                              │
│                                                              🌲     🌲        │
│                                                                               │
│              🚂 Railway Station                                               │
│             (750, 400)                                                        │
│            [100x80px]                                    🌲                   │
│                                                                               │
│  🌲                                              🌲                           │
│                ⭕ Northern Thicket                                            │
│               (300, 200) r=80                                      🌲         │
│                                                                               │
│                                    ⭕ Eastern Grove                           │
│                                   (700, 250) r=80                             │
│  🌲                                                                           │
│                                                              🌲               │
│         ⭕ Western Meadow                                                     │
│        (150, 400) r=80                                                        │
│                                                                       🌲      │
│                                                                               │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎨 **ASSETS NEEDED - By Priority**

### **🏠 TIER 1: Core Structures (Essential)**

#### 1. **Player Character** 
- **Current**: Green rectangle (16x16)
- **Need**: Top-down sprite with 4 directions
- **Frames**: 3-4 per direction (walking animation)
- **Style**: Pixel art, dark/mysterious theme
- **Size**: 32x32px (for better detail)
- **Position**: Moves with WASD

```
Suggested sprite:
  👤
 /|\   → [Front view]
 / \

  👤
  |    → [Side views: left/right]
 /|\   
  |

  👤
  |    → [Back view]
 /|\   
 / \
```

---

#### 2. **Cabin (Main Structure)**
- **Current**: Brown rectangle (80x60)
- **Location**: (220, 150)
- **Need**: Cozy wooden cabin sprite
- **Details**: Door, windows, chimney, worn wood
- **Style**: Dark, mysterious forest cabin
- **Size**: 80x60px or larger (120x90px for detail)

```
Cabin design ideas:
     /\
    /  \     ← Roof
   /____\
   |  □ |    ← Window
   | ▄▄ |    ← Door
   |____|
```

---

#### 3. **Farm Plots (Critical Gameplay)**
- **Current**: Brown squares (32x32 each)
- **Location**: (575, 325) - 2x3 grid
- **Need**: Tilled soil texture
- **Details**: Dark earth, furrows, edges
- **Size**: 32x32px per plot (6 total)

```
Farm grid layout:
┌──┬──┬──┐
│🟫│🟫│🟫│  ← Row 1 (3 plots)
├──┼──┼──┤
│🟫│🟫│🟫│  ← Row 2 (3 plots)
└──┴──┴──┘

Each plot needs:
- Empty tilled soil
- Seed planted (small sprout)
- Growing crop (medium plant)
- Harvest ready (full vegetable)
```

---

### **🌾 TIER 2: Crops (Farming System)**

#### 4. **Carrot Stages**
- **Seed**: Tiny brown dot
- **Sprout**: Green shoots emerging (days 1-10)
- **Growing**: Orange top visible (days 11-25)
- **Harvest**: Full carrot with leaves (day 30)
- **Size**: 16x16px (centered in 32x32 plot)

```
Stages:
•  →  ⚇  →  🥕  →  🥕
     [Fits in farm plot]
```

#### 5. **Potato Stages**
- Similar growth progression
- **Size**: 16x16px
- **Color**: Brown/tan

#### 6. **Mushroom Stages**
- **Size**: 16x16px
- **Color**: Brown/gray caps

---

### **🌲 TIER 3: Environment**

#### 7. **Trees/Forest**
- **Current**: Nothing (empty space)
- **Need**: Simple tree sprites scattered
- **Size**: 40x60px (various sizes)
- **Count**: 15-20 trees
- **Style**: Dark, dense forest

```
Tree variations:
   🌲      🌲      🌳
Simple  Tall   Thick
```

#### 8. **Pond**
- **Current**: Blue ellipse (60x40)
- **Location**: (280, 450)
- **Need**: Water texture with ripples
- **Details**: Dark blue, reflections
- **Size**: 80x60px (larger for detail)

```
   ≈≈≈≈
  ≈≈≈≈≈
  ≈≈≈≈≈  ← Water with ripples
   ≈≈≈
```

---

### **🏪 TIER 4: Interiors & Details**

#### 9. **Shop Interior**
- **Dimensions**: 960x540 (full screen)
- **Elements**: Counter, shelves, items, shopkeeper
- **Style**: Wooden interior, dim lighting

```
Shop layout:
┌────────────────┐
│ 📦 📦 📦 📦 │  ← Shelves
│ 📦 📦 📦 📦 │
│              │
│   🧑 Counter  │  ← Shopkeeper
│   ┌────────┐ │
│   │        │ │
└───┴────────┴─┘
```

#### 10. **Railway Station**
- **Current**: Detailed brown building (100x80)
- **Location**: (750, 400)
- **Need**: Old wooden station sprite
- **Details**: Platform, tracks, weathered wood
- **Size**: 120x100px

```
    ╔══════╗
    ║STATION║  ← Building
    ║  ▄▄  ║  ← Door
    ╚══════╝
═══════════════  ← Tracks
```

---

### **🦌 TIER 5: Animals & Wildlife**

#### 11. **Deer**
- **Size**: 32x32px
- **Frames**: 2-3 (grazing animation)
- **Style**: Side view, brown

#### 12. **Rabbit**
- **Size**: 24x24px
- **Frames**: 2 (hopping)

#### 13. **Boar**
- **Size**: 36x36px
- **Aggressive appearance**

#### 14. **Wild Crops (Foraging)**
- Berries, mushrooms, herbs
- **Size**: 16x16px each
- Scattered in world

---

### **🎯 TIER 6: UI Elements**

#### 15. **Icons**
- Seed icons (16x16)
- Tool icons (hoe, watering can)
- Food icons (bread, beans)
- Heart icon (health)
- Coin icon (money)

---

## 📐 **Exact Coordinates Map**

```
STRUCTURE POSITIONS (x, y, width, height):

Cabin:          (220, 150, 80, 60)
Pond:           (280, 450, 60, 40) - ellipse
Farm Plot 1:    (575, 325, 32, 32)
Farm Plot 2:    (615, 325, 32, 32)
Farm Plot 3:    (655, 325, 32, 32)
Farm Plot 4:    (575, 365, 32, 32)
Farm Plot 5:    (615, 365, 32, 32)
Farm Plot 6:    (655, 365, 32, 32)
Railway Stn:    (750, 400, 100, 80)

HUNTING ZONES (x, y, radius):

Northern Thicket:  (300, 200, 80)
Eastern Grove:     (700, 250, 80)
Western Meadow:    (150, 400, 80)
```

---

## 🎨 **Art Style Guidelines**

### **Color Palette (Dark Forest Theme)**
```
🟫 Browns:    #3d2817, #5c3d2e (structures, earth)
🟩 Greens:    #2d5016, #4a7c30 (plants, player)
🟦 Blues:     #1a3d5c, #2d5a7b (water, night)
⬜ Grays:     #4a4a4a, #6a6a6a (stone, metal)
🟥 Accents:   #8b2e16 (danger, warnings)
🟨 Highlights: #d4af37 (coins, ripe crops)
```

### **Style Notes**
- **Pixel art**: 16x16 or 32x32 base
- **Top-down view**: Like Stardew Valley, old Zelda
- **Dark, moody**: Forest survival atmosphere
- **Readable**: Clear even at small size
- **Consistent**: Same pixel density across all assets

---

## 📦 **Asset File Organization**

```
assets/
├── sprites/
│   ├── player/
│   │   ├── player_front.png (32x32)
│   │   ├── player_back.png
│   │   ├── player_left.png
│   │   └── player_right.png
│   ├── crops/
│   │   ├── carrot_seed.png (16x16)
│   │   ├── carrot_sprout.png
│   │   ├── carrot_growing.png
│   │   ├── carrot_harvest.png
│   │   ├── potato_* (same stages)
│   │   └── mushroom_* (same stages)
│   ├── environment/
│   │   ├── tree_1.png (40x60)
│   │   ├── tree_2.png
│   │   ├── pond.png (80x60)
│   │   └── grass_tile.png (32x32)
│   ├── animals/
│   │   ├── deer.png (32x32)
│   │   ├── rabbit.png (24x24)
│   │   └── boar.png (36x36)
│   └── ui/
│       ├── icons/ (16x16 each)
│       └── panels/ (various)
```

---

## 🔧 **Quick Start: Minimum Viable Assets**

### **Start with these 5 assets to make game feel complete:**

1. **Player sprite** (32x32) - Replace green rectangle
2. **Cabin** (80x60) - Replace brown rectangle
3. **Carrot crop stages** (4 images, 16x16) - Replace circles
4. **Farm plot texture** (32x32) - Better than solid brown
5. **Tree** (40x60) - Add some to empty areas

These 5 assets will transform the game's look dramatically! 🎨

---

## 💡 **Tools for Creating Assets**

- **Aseprite**: Best for pixel art animation
- **Piskel**: Free online pixel art editor
- **GIMP**: Free, can do pixel art
- **Photoshop**: With pixel art techniques
- **AI Generation**: Midjourney/DALL-E for concepts, then pixel-ify

---

**Use this map as reference when creating or commissioning assets!** 🗺️✨