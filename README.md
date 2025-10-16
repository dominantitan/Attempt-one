# 🌲 Dark Forest Survival

<div align="center">

![LÖVE](https://img.shields.io/badge/LÖVE-11.4-EA316E?style=for-the-badge&logo=lua&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow?style=for-the-badge)

**A dark 2D survival-farming game where players balance farming, hunting, and survival while uncovering the mystery of their missing uncle.**

[Features](#-features) • [Installation](#-installation) • [Gameplay](#-gameplay) • [Development](#-development) • [Documentation](#-documentation)

</div>

---

## ✨ Features

### 🎮 Core Gameplay
- **Top-down 2D perspective** with smooth WASD movement controls
- **Dynamic day/night cycle** with atmospheric lighting and time-based events
- **Resource management** - Manage inventory, stamina, and survival needs
- **Multiple game zones** - Cabin, farm, forest, pond, railway station

### 🌾 Survival Systems
- **Farming System** - Plant, water, and harvest crops with realistic growth cycles
- **Hunting Mechanics** - First-person DOOM-style hunting minigame with animal HP system
- **Fishing** - Catch fish at the pond with timing-based mechanics
- **Trading** - Buy seeds, tools, weapons, and ammo from the shopkeeper

### 🐅 Combat & Danger
- **Animal HP System** - Rabbits (50 HP), Deer (150 HP), Boar (250 HP), Tiger (500 HP)
- **Wounded Animals** - Injured animals flee instead of dying instantly
- **Tiger Chase Mechanic** - Get too close to a tiger and it will chase you in the overworld
- **Death System** - Caught by a tiger? Game over with days survived counter

### 🎯 Weapons & Tools
- **Bow** - 50 damage, 500 range, 10° spread
- **Rifle** - 100 damage, 600 range, 2° spread (precise)
- **Shotgun** - 100 damage, 200 range, 30° spread (close-range)
- **Headshot Bonus** - 2x damage for skilled shots

### 💾 Technical Features
- **Save/Load System** - JSON-based game state persistence
- **Collision Detection** - Smooth physics with bump.lua
- **Camera System** - Dynamic following camera with effects
- **Debug Console** - Real-time debugging with comprehensive logging

## � Installation

### Prerequisites

<details>
<summary><b>Windows</b></summary>

1. **Download LÖVE2D** from [love2d.org](https://love2d.org/)
2. Install to `C:\Program Files\LOVE\` (or your preferred location)
3. **Add to PATH** (Optional but recommended):
   - Right-click "This PC" → Properties → Advanced System Settings
   - Environment Variables → System Variables → Path → Edit
   - Add: `C:\Program Files\LOVE\`

</details>

<details>
<summary><b>macOS</b></summary>

```bash
# Using Homebrew
brew install love
```

</details>

<details>
<summary><b>Linux</b></summary>

```bash
# Ubuntu/Debian
sudo apt-get install love

# Arch Linux
sudo pacman -S love
```

</details>

### Quick Start

```bash
# Clone or download the repository
cd "path/to/Attempt one"

# Run the game
love .

# Windows (if LÖVE not in PATH)
"C:\Program Files\LOVE\love.exe" .
```

### 📚 Dependencies

All libraries are **included** in the `/libs` folder:

| Library | Version | Purpose |
|---------|---------|---------|
| **bump.lua** | Latest | 2D AABB collision detection and response |
| **json.lua** | Latest | Save/load game state serialization |
| **lume.lua** | Latest | Utility functions and game math helpers |
| **anim8.lua** | Latest | Sprite animation management |
| **hump.camera** | Latest | Dynamic camera with following and effects |

> ✅ **No additional installation required** - Everything is ready to run!

## 📁 Project Structure

```
c:\dev\Attempt one\
├── main.lua                 # Main game entry point ✅
├── states/                  # Game state management
│   ├── gamestate.lua       # State switching system ✅
│   ├── gameplay.lua        # Main gameplay loop ✅
│   ├── inventory.lua       # Inventory UI ✅
│   └── shop.lua            # Shop interface ✅
├── systems/                 # Core game systems  
│   ├── player.lua          # Player movement & input ✅
│   ├── farming.lua         # Crop mechanics ✅
│   ├── hunting.lua         # Animal interactions ✅
│   ├── daynight.lua        # Time & lighting ✅
│   └── audio.lua           # Sound management ✅
├── entities/                # Game objects
│   ├── player.lua          # Player stats & inventory ✅
│   ├── animals.lua         # Animal types & AI ✅
│   ├── crops.lua           # Crop growth system ✅
│   └── shopkeeper.lua      # NPC trading ✅
├── utils/                   # Utility modules
│   ├── camera.lua          # Camera control ✅
│   ├── collision.lua       # Collision detection ✅
│   └── save.lua            # Save/load system ✅
├── log/                     # 📂 Archived documentation
│   └── *.md                # Historical development docs
├── FULL_DOCUMENTATION.md   # 📚 Complete development guide
└── README.md               # 📖 This file
├── libs/                    # External libraries
│   ├── bump.lua            # Downloaded ✅
│   ├── json.lua            # Downloaded ✅  
│   ├── lume.lua            # Downloaded ✅
│   ├── anim8.lua           # Downloaded ✅
│   └── hump/camera.lua     # Downloaded ✅
└── assets/                  # Game assets (sprites, sounds, music)
    ├── sprites/            # Visual assets 📁
    ├── sounds/             # Audio effects 📁
    ├── music/              # Background music 📁
    └── fonts/              # Game fonts 📁
```

## � Gameplay

### Controls

#### Overworld
| Key | Action |
|-----|--------|
| **WASD** | Move player |
| **I** | Open/Close inventory |
| **R** | Forage wild crops |
| **E** | Interact with farm plots |
| **Q** | Water crops |
| **F** | Fish at pond |
| **B** | Trade at railway station |
| **ENTER** | Enter hunting zones |
| **ESC** | Pause/Resume |

#### Hunting Mode (First-Person)
| Key | Action |
|-----|--------|
| **Mouse** | Aim crosshair |
| **Left Click** | Shoot |
| **1/2/3** | Switch weapons |
| **ESC** | Exit hunting |

### Game Loop

1. **Morning** - Wake up at your uncle's cabin
2. **Farm** - Plant and water crops for food/income
3. **Hunt** - Enter forest zones to hunt animals for meat
4. **Trade** - Sell resources and buy supplies
5. **Survive** - Avoid tigers, manage resources, survive days
6. **Repeat** - Build up resources and uncover the mystery

### Hunting Mechanics

- **Circular Zones** - Three hunting zones on the map
- **Animal Spawning** - Random animals appear (rabbit, deer, boar, tiger)
- **HP System** - Animals have health and require multiple shots
- **Wounded Behavior** - Injured animals flee off-screen
- **Tiger Danger** - Get too close and the tiger attacks, chasing you home!
- **Loot** - Collect meat from kills for selling or trading

## 🏆 Current Status

### ✅ Fully Implemented
- ✅ Core game loop with state management
- ✅ Player movement and collision system
- ✅ Farming system (plant, water, harvest)
- ✅ First-person hunting minigame
- ✅ Animal HP system with headshots
- ✅ Wounded animal flee behavior
- ✅ Tiger chase mechanic
- ✅ Death screen and game restart
- ✅ Day/night cycle with counter
- ✅ Inventory management
- ✅ Trading system
- ✅ Save/load functionality
- ✅ Debug console and logging

### 🚧 In Progress
- 🔧 Sprite assets (currently using placeholder graphics)
- 🔧 Sound effects and music
- 🔧 Story/quest system
- 🔧 Additional content (more crops, animals, items)

### 🎯 Planned Features
- 📋 Uncle's mystery storyline
- 📋 Craftign system
- 📋 Building/upgrades
- 📋 More animal varieties
- 📋 Seasonal changes
- 📋 Multiple save slots

### 🎮 Debug Tools
| Key | Function |
|-----|----------|
| **F3** | Toggle debug overlay |
| **F4** | Pause/Unpause |
| **T** | Spawn debug crops |
| **Console** | View real-time logs (Windows only)

## �️ Development

### Architecture

```
┌─────────────────────────────────────────────┐
│           main.lua (Entry Point)            │
├─────────────────────────────────────────────┤
│   States (gamestate.lua - State Manager)    │
│   ├─ gameplay.lua  (Main overworld)         │
│   ├─ hunting.lua   (First-person hunting)   │
│   ├─ inventory.lua (Inventory UI)           │
│   ├─ shop.lua      (Trading interface)      │
│   └─ death.lua     (Game over screen)       │
├─────────────────────────────────────────────┤
│   Systems (Core Game Logic)                 │
│   ├─ player.lua    (Movement & input)       │
│   ├─ farming.lua   (Crop mechanics)         │
│   ├─ hunting.lua   (Animal spawning)        │
│   ├─ daynight.lua  (Time progression)       │
│   ├─ world.lua     (Map & structures)       │
│   └─ audio.lua     (Sound management)       │
├─────────────────────────────────────────────┤
│   Entities (Game Objects)                   │
│   ├─ player.lua    (Stats & inventory)      │
│   ├─ animals.lua   (Animal types)           │
│   ├─ crops.lua     (Crop definitions)       │
│   └─ shopkeeper.lua(NPC trading)            │
└─────────────────────────────────────────────┘
```

### Code Standards
- **Lua 5.1** syntax (LÖVE2D compatibility)
- **Modular design** - Each system is independent
- **State-based** architecture for clean scene management
- **Entity-Component** pattern for game objects
- **Comprehensive logging** for debugging

### Key Systems

<details>
<summary><b>Hunting System</b></summary>

- **First-person view** inspired by DOOM
- **Animal spawning** with weighted probabilities
- **Hit detection** with headshot calculations
- **HP-based combat** instead of instant kills
- **Flee behavior** for wounded animals
- **Tiger mechanics** - Attack triggers overworld chase

</details>

<details>
<summary><b>Tiger Chase System</b></summary>

- Triggered when tiger gets within 150px of player
- Tiger spawns in overworld behind player
- Chases at 120 speed (faster than player's 100)
- Two outcomes:
  - **Reach house**: Tiger gives up, player safe
  - **Get caught**: Death screen, shows days survived

</details>

<details>
<summary><b>Farming System</b></summary>

- **6 farm plots** in 2x3 grid layout
- **Growth stages**: Planted → Growing → Harvestable
- **Water requirement**: Crops need watering
- **Multiple crop types**: Carrots, potatoes, wheat, etc.
- **Seasonal mechanics**: Time-based growth

</details>

## 📚 Documentation

### 📖 Main Documentation Files

| File | Description | Purpose |
|------|-------------|---------|
| **[README.md](README.md)** | Project overview & setup | Start here for installation and quick start |
| **[FULL_DOCUMENTATION.md](FULL_DOCUMENTATION.md)** | Complete development docs | All technical guides, implementations, and notes |
| **[log/](log/)** | Archived individual docs | Historical documentation files (26 files) |

### 📋 Documentation Structure

```
Documentation/
├── README.md                    # 👈 You are here - Setup & overview
├── FULL_DOCUMENTATION.md        # Complete technical reference
│   ├── System Implementations   # How features work
│   ├── Bug Fixes & Solutions    # Problem resolutions
│   ├── Game Mechanics Guides    # Design documentation
│   ├── Code Organization        # Architecture details
│   ├── Testing Documentation    # Test procedures
│   └── Development Checklists   # Feature tracking
└── log/                         # Archived source files
    ├── README.md               # Archive explanation
    └── [26 historical .md files]
```

### 🔍 Finding Information

1. **Setting up the game?** → Start with this README
2. **Understanding a system?** → Search `FULL_DOCUMENTATION.md` (Ctrl+F)
3. **Historical context?** → Check individual files in `/log`
4. **LÖVE2D API reference?** → [love2d.org/wiki](https://love2d.org/wiki/Main_Page)

### ✍️ Contributing Documentation

**From now on, all new documentation is added directly to `FULL_DOCUMENTATION.md`:**

```markdown
# Add new sections to FULL_DOCUMENTATION.md:

---

# [Feature Name] - [Date]

## Overview
Brief description of what you're documenting

## Implementation Details
Code examples, file locations, function signatures

## Testing
How to test and verify the feature

## Notes
Any additional context or gotchas

---
```

**Benefits of this approach:**
- ✅ Single source of truth
- ✅ Easy to search (one file, Ctrl+F)
- ✅ Consistent formatting
- ✅ Better version control (fewer merge conflicts)
- ✅ Historical docs preserved in `/log`

### Quick References
- **Project Structure**: See file tree in [Installation](#-installation)
- **Asset Guidelines**: `/assets/README.md`
- **System Architecture**: Above architecture diagram
- **LÖVE2D API**: [love2d.org/wiki](https://love2d.org/wiki/Main_Page)

### For Contributors
1. Read `CODE_STANDARDS.md` (in FULL_DOCUMENTATION.md)
2. Follow modular design patterns
3. Add comprehensive logging
4. Test with debug console enabled
5. Document new systems in markdown

## 🐛 Known Issues & Limitations

- **Graphics**: Currently using placeholder colored rectangles
- **Audio**: Sound files not yet implemented
- **Story**: Uncle's mystery questline incomplete
- **Performance**: Large animal counts may impact FPS
- **Balance**: Weapon/animal stats may need tuning

## 🎨 Asset Requirements

### Sprites Needed
- **Player**: 32x32px, 4-direction walk cycles
- **Animals**: 32x32px (rabbit, deer, boar, tiger)
- **Crops**: 16x16px growth stages (4 frames each)
- **Buildings**: 64x64px+ (cabin, shop, farm plots)
- **UI**: Inventory slots, health bar, buttons

### Audio Needed
- **SFX**: Footsteps, gunshots, animal sounds, harvesting
- **Music**: Ambient forest theme, tense hunting music
- **Ambience**: Birds, wind, water flowing

### Style Guide
- **Pixel art** aesthetic (16-32px sprites)
- **Dark palette** - muted greens, browns, grays
- **High contrast** for visibility
- **Consistent proportions** across all assets

## 🤝 Contributing

Contributions are welcome! Areas that need help:
- 🎨 **Pixel art** sprites and animations
- 🎵 **Audio** - SFX and music composition
- 📝 **Story writing** - Uncle's mystery quest
- 🐛 **Bug testing** and balance feedback
- 💡 **Feature ideas** and game design

## 📄 License

This project is licensed under the MIT License - feel free to use, modify, and distribute.

## � Credits

### Frameworks & Libraries
- **LÖVE2D** - Game framework
- **bump.lua** by kikito - Collision detection
- **anim8** by kikito - Animation library
- **hump** by vrld - Camera system
- **lume** by rxi - Utility functions
- **json.lua** by rxi - JSON encoding/decoding

### Inspiration
- **Don't Starve** - Art style and survival mechanics
- **DOOM** - First-person hunting perspective
- **Stardew Valley** - Farming and daily cycle systems

---

<div align="center">

**Made with ❤️ using LÖVE2D and Lua**

[Report Bug](https://github.com/dominantitan/Attempt-one/issues) • [Request Feature](https://github.com/dominantitan/Attempt-one/issues)

</div>
