# Game Asset Requirements List

## Overview
Complete list of visual and audio assets needed for the farming/survival game with hunting, fishing, and farming mechanics.

---

## 🌍 WORLD & ENVIRONMENT

### Main World Map
- **World background texture** (2880x1620px) - Grass, dirt, forest paths
- **Railway station** (360x240px) - Starting area with tracks
- **Cabin exterior** (240x240px) - Player's home
- **Cabin interior** (1440x960px) - Inside home view
- **Farm area texture** (360x240px) - Tilled soil background
- **Pond/water texture** (300x180px) - Fishing area
- **Forest texture tiles** - Trees, bushes, undergrowth
- **Path/road textures** - Dirt paths connecting areas
- **Boundary fence/walls** - Visual markers for world edges

### Environmental Objects
- **Trees** - Pine, oak, birch variants (various sizes)
- **Bushes/shrubs** - Foraging spots
- **Rocks** - Small, medium, large
- **Grass tufts** - Decorative vegetation
- **Flowers** - Wild flowers (decorative)
- **Stumps** - Tree stumps
- **Logs** - Fallen trees

---

## 👤 PLAYER

### Player Character (48x48px base)
- **Idle animation** - Front, back, left, right (4 frames each)
- **Walking animation** - All 4 directions (4-6 frames each)
- **Running animation** - All 4 directions (4-6 frames each)
- **Holding tool poses** - Watering can, bow, rifle, shotgun
- **Action animations**:
  - Watering crops
  - Planting seeds
  - Harvesting crops
  - Drawing bow
  - Aiming rifle/shotgun
  - Fishing with spear

### Player Equipment (Overlay Sprites)
- **Bow** - Held and drawn positions
- **Rifle** - Held and aiming positions
- **Shotgun** - Held and aiming positions
- **Watering can** - Held position
- **Fishing spear** - Held position
- **Backpack** - Worn on back

---

## 🌾 FARMING SYSTEM

### Crops (96x96px plots)
Each crop needs 4-5 growth stages:

**Carrots:**
- Stage 1: Seeds planted (tiny sprout)
- Stage 2: Small leaves
- Stage 3: Growing leaves
- Stage 4: Full carrots (ready to harvest)

**Potatoes:**
- Stage 1: Seeds planted
- Stage 2: Small plant
- Stage 3: Flowering plant
- Stage 4: Ready to harvest

**Mushrooms:**
- Stage 1: Spores planted (tiny dots)
- Stage 2: Small mushroom caps
- Stage 3: Growing mushrooms
- Stage 4: Full grown mushrooms

### Farming Objects
- **Tilled soil** - Empty plot texture (96x96px)
- **Watered soil** - Darker, wet texture (96x96px)
- **Dried soil** - Light brown, cracked texture
- **Watering can sprite** (32x32px)
- **Water bucket** (32x32px)
- **Seed packets** - Carrot, potato, mushroom icons

### Harvested Crops (Inventory Icons 32x32px)
- **Carrot** - Orange vegetable
- **Potato** - Brown tuber
- **Mushroom** - Brown/red cap

---

## 🐾 ANIMALS (HUNTING)

### Huntable Animals (Scaled for world)

**Rabbit** (60x60px):
- Idle animation (2-3 frames)
- Hopping animation (3-4 frames)
- Grazing animation
- Alert/scared pose
- Dead sprite

**Deer** (120x120px):
- Idle animation
- Walking animation (4-6 frames)
- Grazing animation
- Alert/running animation
- Dead sprite

**Boar** (100x100px):
- Idle animation
- Walking animation
- Aggressive charging animation
- Dead sprite

**Tiger** (150x150px) - Dangerous predator:
- Idle animation
- Prowling animation
- Running/chasing animation (fast)
- Pouncing animation
- Roaring animation

### Animal Parts (Icons 32x32px)
- **Rabbit meat**
- **Rabbit pelt**
- **Deer meat**
- **Deer hide**
- **Deer antlers**
- **Boar meat**
- **Boar hide**
- **Boar tusk**

---

## 🎣 FISHING SYSTEM

### Fish (Top-down view)

**Small Fish** (20x10px):
- Swimming animation (3-4 frames)
- Flopping animation (when caught)
- Boid fish for background (16x8px)

**Bass** (40x20px):
- Swimming animation
- Struggling animation

**Catfish** (60x30px):
- Swimming animation
- Whiskers detail

**Rare Trout** (50x25px):
- Swimming animation
- Shimmering effect

**Water Snake** (80x15px) - Danger:
- Swimming animation (S-curve motion)
- Striking animation
- Biting animation

### Fishing Objects
- **Fishing spear** - Throwable weapon (64x8px)
- **Fishing net** - When equipped (80x80px)
- **Spear in water** - Stuck in mud sprite
- **Splash effect** - Water splash animation (3-5 frames)
- **Ripple effect** - Expanding circle animation
- **Pond rocks** - Obstacles (various sizes)
- **Water lilies** - Decorative (32x32px)

### Fishing Catch Icons (32x32px)
- **Small fish**
- **Bass**
- **Catfish**
- **Rare trout**
- **Snake skin** (if added as loot)

---

## 🍃 FORAGING SYSTEM

### Wild Crops (32x32px each)
- **Berries** - Red berry bush
- **Herbs** - Green leafy plants
- **Nuts** - Brown acorns/nuts
- **Wild mushrooms** - Forest floor mushrooms

Each needs:
- Growing state (smaller)
- Ready to harvest (full size)
- Picked state (empty/depleted)

### Inventory Icons (32x32px)
- **Berry bunch**
- **Herb bundle**
- **Nut cluster**
- **Mushroom cluster**

---

## 🏹 WEAPONS & TOOLS

### Weapons (Held sprites + Icons)

**Bow** (48x48px):
- Idle bow
- Half-drawn bow
- Fully drawn bow
- Icon (32x32px)

**Rifle** (64x24px):
- Idle rifle
- Aiming rifle
- Muzzle flash effect
- Icon (32x32px)

**Shotgun** (72x28px):
- Idle shotgun
- Aiming shotgun
- Spread muzzle flash
- Icon (32x32px)

### Ammunition Icons (32x32px)
- **Arrow** - Single arrow
- **Arrows bundle** (10x)
- **Bullet** - Single bullet
- **Bullets box** (10x)
- **Shell** - Shotgun shell
- **Shells box** (10x)

### Projectiles (In-flight)
- **Arrow** - Flying sprite (32x8px)
- **Bullet** - Small yellow dot (4x4px)
- **Shotgun pellets** - Multiple small dots

---

## 🏪 SHOP & UI

### Shop Building
- **Shop exterior** - Shopkeeper's store (240x240px)
- **Shop interior background** - Counter and shelves
- **Shopkeeper character** - Friendly NPC (64x64px)
  - Idle animation
  - Talking animation
  - Waving animation

### UI Elements

**Inventory Screen:**
- **Inventory background** - Panel texture
- **Item slot** - Empty slot texture (40x40px)
- **Selected slot** - Highlighted border
- **Money icon** - Dollar sign or coins
- **Close button** - X button

**HUD Elements:**
- **Health bar** - Frame and fill
- **Hunger bar** - Frame and fill
- **Money counter** - Coin icon
- **Day counter** - Sun/moon icon
- **Time indicator** - Clock icon
- **Ammo counter** - Bullet icon

**Buttons & Icons:**
- **Interact prompt** - "Press E" indicator
- **Inventory button** - "I" or backpack icon
- **Map button** - "M" or map icon
- **Pause menu** - Settings icon

---

## 🎨 EFFECTS & PARTICLES

### Visual Effects

**Combat Effects:**
- **Blood splatter** - Small red particles (when animal hit)
- **Dust cloud** - Brown particles (running)
- **Muzzle flash** - Bright yellow/orange (guns)
- **Hit marker** - Red X or circle (successful hit)

**Environmental Effects:**
- **Leaf particles** - Falling leaves in forest
- **Dust particles** - Ambient atmosphere
- **Water splash** - Fishing spear impact
- **Sparkles** - Harvestable items
- **Growth particles** - Crops growing

**Weather Effects:**
- **Rain drops** - Vertical streaks
- **Rain splash** - Ground impact
- **Clouds** - Sky coverage
- **Fog/mist** - Atmospheric overlay

---

## 🎵 AUDIO ASSETS

### Music Tracks

**Ambient Music:**
- **Main world theme** - Peaceful farming music (3-4 min loop)
- **Forest ambient** - Nature sounds with light music
- **Night theme** - Calm, darker tones
- **Shop theme** - Upbeat, friendly music
- **Hunting theme** - Tense, suspenseful music
- **Fishing theme** - Calm water sounds with melody
- **Tiger chase music** - Intense, fast-paced danger theme

### Sound Effects

**Player Actions:**
- **Footsteps** - Grass, dirt variants
- **Running footsteps** - Faster pace
- **Watering crop** - Water pouring
- **Planting seed** - Digging soil
- **Harvesting crop** - Plucking/picking sound
- **Opening inventory** - Menu open whoosh
- **Closing inventory** - Menu close

**Weapons:**
- **Bow draw** - String tension
- **Arrow release** - Twang sound
- **Arrow hit** - Thud impact
- **Rifle shot** - Loud bang
- **Rifle reload** - Mechanical click
- **Shotgun blast** - Heavy boom
- **Shotgun pump** - Pump action
- **Empty weapon click** - Out of ammo

**Animals:**
- **Rabbit squeak** - High-pitched
- **Deer call** - Low grunt
- **Boar grunt** - Aggressive snort
- **Tiger roar** - Deep, scary roar
- **Tiger growl** - Warning sound
- **Animal death** - Final sound

**Fishing:**
- **Spear throw** - Whoosh
- **Spear splash** - Water impact
- **Spear stuck** - Mud squelch
- **Fish caught** - Water thrashing
- **Net cast** - Fabric sound
- **Snake hiss** - Threatening hiss

**Environment:**
- **Bird chirps** - Background ambience
- **Wind rustling** - Leaves moving
- **Water flowing** - Pond ambience
- **Crickets** - Night sounds
- **Frog croaks** - Pond sounds

**UI:**
- **Button click** - Menu selection
- **Purchase sound** - Cash register ding
- **Item pickup** - Positive chime
- **Money gain** - Coin clink
- **Level up/achievement** - Success fanfare
- **Error sound** - Negative buzz
- **Day transition** - Bell or chime

**Shop:**
- **Door open** - Wooden door creak
- **Shopkeeper greeting** - Voice/grunt
- **Counter interact** - Wood tap

---

## 🌙 DAY/NIGHT CYCLE

### Lighting Overlays
- **Morning tint** (0-25%) - Orange/yellow overlay
- **Day tint** (25-50%) - Bright, clear
- **Evening tint** (50-75%) - Orange/red sunset
- **Night tint** (75-100%) - Dark blue/purple overlay

### Sky Elements
- **Sun sprite** - Yellow circle (64x64px)
- **Moon sprite** - White circle (64x64px)
- **Stars** - Small white dots (scattered)

---

## 📺 UI SCREENS

### Title Screen
- **Title logo** - Game name banner
- **Start button**
- **Background image** - Farm scene

### Death Screen
- **Tiger death image** - Scary tiger face
- **Snake death image** - Snake icon/emoji
- **Skull icon** - Death marker
- **Restart button**

### Pause Menu
- **Semi-transparent overlay**
- **Resume button**
- **Save button**
- **Load button**
- **Quit button**

---

## 📏 RECOMMENDED SIZES

**World Objects:** Scale everything by 3x for your 2880x1620 world
- Small objects: 48-96px
- Medium objects: 120-200px
- Large objects: 240-360px

**Inventory Icons:** 32x32px (standard grid size)

**Character Sprites:** 48x48px base (player), animals vary

**UI Elements:** 40x40px buttons, scalable panels

---

## 🎨 ART STYLE RECOMMENDATIONS

**Pixel Art Style:**
- **16-bit or 32-bit aesthetic** - Retro but detailed
- **Consistent resolution** - All sprites same pixel density
- **Limited color palette** - Cohesive look (64-128 colors)
- **Smooth animations** - 3-6 frames per action

**Color Palette Suggestions:**
- **Nature:** Greens (#228B22, #90EE90), browns (#8B4513, #D2691E)
- **Water:** Blues (#1E90FF, #87CEEB)
- **UI:** Neutral tans (#F5DEB3, #D2B48C)
- **Danger:** Reds (#DC143C, #FF4500)
- **Night:** Dark purples (#483D8B, #2F4F4F)

---

## 🔄 ANIMATION PRIORITY

**Critical (Needed First):**
1. Player walking (4 directions)
2. Animals idle + walking
3. Crop growth stages
4. Weapon holding poses

**Medium Priority:**
5. Attack animations
6. Environmental particles
7. UI animations
8. Water effects

**Polish (Can Add Later):**
9. Weather effects
10. Advanced particle systems
11. Complex attack animations
12. Decorative objects

---

## 📦 ASSET ORGANIZATION

Recommended folder structure:
```
assets/
├── sprites/
│   ├── player/
│   ├── animals/
│   ├── crops/
│   ├── environment/
│   └── ui/
├── sounds/
│   ├── music/
│   ├── sfx/
│   └── ambient/
└── fonts/
```

---

## 💡 TIPS FOR ASSET CREATION

1. **Start with placeholders** - Use colored rectangles to prototype
2. **Create sprite sheets** - Organize animations efficiently
3. **Use consistent lighting** - All assets lit from same angle
4. **Test in-game early** - Make sure scale looks right
5. **Add outlines** - Helps sprites pop against backgrounds
6. **Consider colorblind modes** - Use patterns/shapes not just color
7. **Optimize file sizes** - PNG with transparency, compressed

---

## 🎯 CURRENT STATUS (Your Game)

**Currently Using:**
✅ Colored rectangles for placeholders
✅ Simple geometric shapes
✅ Text-based UI

**Ready for:**
🎨 Player sprite with animations
🎨 Animal sprites (rabbit, deer, boar, tiger)
🎨 Crop sprites (all growth stages)
🎨 Environment textures (grass, water, paths)
🎨 UI panel textures and icons

---

## 📊 ESTIMATED ASSET COUNT

- **Total Sprites:** ~200-300 unique sprites
- **Animations:** ~50-75 animations
- **Icons:** ~40-60 UI icons
- **Sound Effects:** ~60-80 SFX
- **Music Tracks:** ~6-8 tracks
- **Particle Effects:** ~15-20 effects

**Total Project Size (Estimated):** 50-150 MB when complete

---

This comprehensive list covers all visual and audio assets your farming survival game needs. Start with the high-priority items (player, animals, crops) and expand from there!
