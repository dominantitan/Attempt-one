# 🗺️ Asset Map System - Quick Reference

## 🎮 **HOW TO USE THE IN-GAME MAP**

### **Press F4 in-game to toggle the asset map overlay!**

This shows you exactly where every asset needs to be placed with:
- 🏠 Structure markers with sizes and coordinates
- 🌾 Farm plot grid layout
- ⭕ Hunting zone boundaries
- 🌲 Suggested tree placements
- 👤 Your current player position

---

## 📋 **ASSET CHECKLIST**

### **Priority 1: Core Gameplay (Start Here!)**
- [ ] **Player Character** - 32x32px, 4 directions
- [ ] **Cabin Sprite** - 80x60px
- [ ] **Farm Soil Texture** - 32x32px per plot
- [ ] **Carrot Crop Stages** - 4 stages, 16x16px each
- [ ] **Potato Crop Stages** - 4 stages, 16x16px each
- [ ] **Mushroom Crop Stages** - 4 stages, 16x16px each

### **Priority 2: Environment**
- [ ] **Tree Sprites** - 40x60px, 10-15 variations
- [ ] **Pond Water** - 80x60px
- [ ] **Grass/Ground Tiles** - 32x32px repeating

### **Priority 3: Buildings**
- [ ] **Railway Station** - 100x80px
- [ ] **Shop Interior** - Full screen background

### **Priority 4: Animals & Wildlife**
- [ ] **Deer** - 32x32px
- [ ] **Rabbit** - 24x24px
- [ ] **Boar** - 36x36px
- [ ] **Wild Crops** - 16x16px (berries, mushrooms, herbs)

### **Priority 5: UI Elements**
- [ ] **Seed Icons** - 16x16px each
- [ ] **Tool Icons** - 16x16px each
- [ ] **Food Icons** - 16x16px each

---

## 📍 **EXACT POSITIONS & SIZES**

All coordinates are in pixels from top-left (0,0):

```
STRUCTURE             X     Y    WIDTH  HEIGHT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Cabin                220   150    80     60
Pond                 280   450    60     40 (ellipse)
Railway Station      750   400   100     80

FARM PLOTS (2x3 Grid)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Plot 1 (top-left)    575   325    32     32
Plot 2 (top-mid)     615   325    32     32
Plot 3 (top-right)   655   325    32     32
Plot 4 (bot-left)    575   365    32     32
Plot 5 (bot-mid)     615   365    32     32
Plot 6 (bot-right)   655   365    32     32

HUNTING ZONES (Circles)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Northern Thicket     300   200   radius=80
Eastern Grove        700   250   radius=80
Western Meadow       150   400   radius=80
```

---

## 🎨 **COLOR PALETTE**

Use these colors for consistency:

```
BROWNS (Structures, Earth)
━━━━━━━━━━━━━━━━━━━━━━━━━
Dark:   #3d2817
Medium: #5c3d2e
Light:  #8b7355

GREENS (Plants, Player)
━━━━━━━━━━━━━━━━━━━━━━━━━
Dark:   #2d5016
Medium: #4a7c30
Light:  #6a9944

BLUES (Water, Night)
━━━━━━━━━━━━━━━━━━━━━━━━━
Dark:   #1a3d5c
Medium: #2d5a7b
Light:  #4a7da0

GRAYS (Stone, Metal)
━━━━━━━━━━━━━━━━━━━━━━━━━
Dark:   #3a3a3a
Medium: #5a5a5a
Light:  #8a8a8a

ACCENTS
━━━━━━━━━━━━━━━━━━━━━━━━━
Red (Danger):   #8b2e16
Yellow (Coins): #d4af37
Orange (Fire):  #e67332
```

---

## 🖼️ **ASSET SPECIFICATIONS**

### **Player Character (32x32px)**
```
Required frames:
- Front walk: 3 frames
- Back walk: 3 frames
- Left walk: 3 frames
- Right walk: 3 frames

Total: 12 frames

Animation speed: 8 FPS
Format: PNG with transparency
```

### **Crop Growth (16x16px each)**
```
Each crop needs 4 stages:

Stage 1: Seed
- Small brown dot in soil
- Barely visible

Stage 2: Sprout  
- Green shoots emerging
- 25% grown

Stage 3: Growing
- Clear vegetable shape
- 75% grown

Stage 4: Harvest Ready
- Full size, bright colors
- Ready to pick!
```

### **Farm Plot (32x32px)**
```
Tilled soil texture:
- Dark brown earth
- Visible furrows/rows
- Slightly rough texture
- Tileable (repeats seamlessly)
```

### **Trees (40x60px)**
```
Need 3-5 variations:
- Pine/conifer style
- Dark, mysterious
- Top-down angled view
- Semi-transparent canopy
```

---

## 📂 **FILE NAMING CONVENTION**

```
assets/sprites/
├── player/
│   ├── player_walk_front_1.png
│   ├── player_walk_front_2.png
│   ├── player_walk_front_3.png
│   ├── player_walk_back_1.png
│   ├── player_walk_left_1.png
│   └── player_walk_right_1.png
│
├── crops/
│   ├── carrot_stage1.png (seed)
│   ├── carrot_stage2.png (sprout)
│   ├── carrot_stage3.png (growing)
│   ├── carrot_stage4.png (harvest)
│   ├── potato_stage1.png
│   └── ... (repeat pattern)
│
├── environment/
│   ├── tree_pine_1.png
│   ├── tree_pine_2.png
│   ├── pond.png
│   ├── grass_tile.png
│   └── soil_tilled.png
│
├── structures/
│   ├── cabin.png
│   ├── railway_station.png
│   └── shop_interior_bg.png
│
└── ui/
    ├── icon_seeds.png
    ├── icon_carrot.png
    ├── icon_water.png
    └── icon_coins.png
```

---

## 🎯 **QUICK START WORKFLOW**

### **Step 1: Launch Asset Map**
1. Run the game with `love .`
2. Press **F4** to toggle asset map overlay
3. Take screenshot for reference

### **Step 2: Create Priority Assets**
1. Start with **player character** (most visible)
2. Then **cabin** (main landmark)
3. Then **3 crop stages** (core gameplay)
4. Then **farm soil texture**
5. Then **trees** (fills empty space)

### **Step 3: Test In-Game**
1. Place assets in correct folders
2. Update sprite loading code
3. Test and adjust sizes/positions

### **Step 4: Polish**
1. Add remaining crops
2. Add animals
3. Add UI icons
4. Add sound effects

---

## 🔑 **KEYBOARD SHORTCUTS**

```
F3  = Toggle debug info (FPS, position)
F4  = Toggle asset map overlay
F5  = Pause game
ESC = Exit menus / Quit game
```

---

## 💡 **PRO TIPS**

1. **Start simple**: Even stick figures are better than rectangles!
2. **Use pixel art tools**: Aseprite, Piskel, or GIMP
3. **Keep consistent style**: All assets should feel cohesive
4. **Test early**: Put in placeholder art to see how it looks
5. **Iterate**: Start rough, refine gradually
6. **Reference the overlay**: Press F4 constantly while creating

---

## 📊 **PROGRESS TRACKER**

Use this to track your asset creation:

```
MVP Assets (Minimum to look decent):
□ Player character
□ Cabin sprite
□ Carrot 4-stages
□ Farm soil texture
□ 3 tree sprites

Nice-to-Have Assets:
□ Potato 4-stages
□ Mushroom 4-stages
□ Pond water
□ Railway station
□ 10 more trees
□ Grass tiles

Polish Assets:
□ Animals (3 types)
□ Wild crops (3 types)
□ UI icons (10+ icons)
□ Shop interior
□ Cabin interior
```

---

## 🎨 **AI GENERATION PROMPTS**

If using AI to generate concept art:

```
Player Character:
"Top-down pixel art sprite of mysterious hooded figure,
32x32 pixels, dark forest survivor, medieval fantasy,
front view walking animation, dark green cloak"

Cabin:
"Top-down pixel art wooden cabin, 80x60 pixels,
weathered dark wood, mysterious forest dwelling,
simple roof, one door, two windows, game asset"

Crop Stages:
"Pixel art carrot growing stages, 16x16 pixels,
4 stages from seed to harvest, farming game sprite,
top-down view, dark earth background"
```

---

**Press F4 in-game to see this map visualized with all positions marked!** 🗺️✨