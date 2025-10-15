# 🌲 Dark Forest Survival Game

A dark 2D survival-farming game built with LÖVE2D (Lua) where players balance farming chores with hunting and horror elements while investigating their missing uncle.

## 🎮 Game Features

- **Top-down 2D gameplay** with WASD movement controls
- **Dark forest environment** with multiple locations (cabin, shop, farm, pond, railway station)
- **Day/night cycle** with atmospheric lighting and danger mechanics
- **Farming system** - plant seeds, water crops, harvest vegetables and mushrooms
- **Hunting mechanics** - interact with animals, special tiger encounters
- **Resource management** - inventory system for crops, tools, and materials
- **Fishing** at the pond with catch mechanics
- **Trading system** with shopkeeper NPC
- **Save/Load system** for game persistence
- **Dark aesthetic** inspired by Don't Starve

## 🛠️ Development Setup

### Prerequisites
1. **Install LÖVE2D**: Download from [love2d.org](https://love2d.org/)
2. **Add LÖVE to PATH** (Windows): Add the LÖVE installation directory to your system PATH

### Libraries Installed ✅
- **bump.lua** - 2D collision detection and response
- **json.lua** - Save/load game data serialization  
- **lume.lua** - Utility functions for game math
- **anim8.lua** - Sprite animation management
- **hump.camera** - Advanced camera system with following and effects

### Running the Game
```bash
# Navigate to project directory
cd "c:\dev\Attempt one"

# Run with LÖVE2D
love .

# Or if LÖVE isn't in PATH, run directly:
"C:\Program Files\LOVE\love.exe" .
```

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

## 🎯 Current Status

### ✅ Completed Systems
- **Core Architecture**: Complete game loop with proper state management
- **Library Integration**: All essential libraries downloaded and integrated
- **Player System**: Movement, stats, inventory management
- **Farming System**: Plant → Water → Harvest cycle
- **Hunting System**: Animal interactions with special events
- **Day/Night Cycle**: Time progression with atmospheric effects
- **Camera System**: Smooth following with screen shake effects
- **Save System**: JSON-based game state persistence
- **Collision System**: AABB and grid-based detection
- **Audio Framework**: Sound and music management structure

### 🎮 Debug Controls
- **F3** - Toggle debug info display
- **F4** - Pause/unpause game
- **ESC** - Return to gameplay or quit
- **I** - Open inventory (from gameplay)

### 🚀 Next Development Steps

1. **Add Basic Sprites** - Replace colored rectangles with actual pixel art
2. **Implement World Areas** - Create different zones (forest, cabin, farm, etc.)
3. **Add Sound Effects** - Footsteps, farming sounds, ambient forest audio
4. **Create Game Assets** - Following the asset guide in `/assets/README.md`
5. **Polish UI** - Inventory grid, health bars, dialogue boxes
6. **Add More Game Content** - More crop types, animal varieties, story elements

### 🐛 Known Issues
- Game requires LÖVE2D to be installed and in PATH
- No sprites yet (using colored placeholder rectangles)
- Audio files not included (need to add sound assets)
- Missing uncle story elements (main quest system)

### 🎨 Art Requirements
- **Pixel Art Style**: 16x16 or 32x32 sprites
- **Color Palette**: Dark, muted tones (browns, dark greens, grays)
- **Animation**: 4-frame walking cycles for player
- **Environment**: Forest tiles, cabin, shop, pond sprites

## 💡 Tips for Development

1. **Start Simple**: Test with placeholder graphics first
2. **Test Frequently**: Run `love .` after each major change
3. **Use Debug Mode**: Press F3 to see FPS, player position, etc.
4. **Modular Design**: Each system is independent and can be developed separately
5. **Asset Organization**: Follow the structure in `/assets/README.md`

## 📚 Documentation
- **LÖVE2D Docs**: [love2d.org/wiki](https://love2d.org/wiki/Main_Page)
- **Library Docs**: See individual library GitHub repositories
- **Asset Guidelines**: Check `/assets/README.md` for sprite specifications

---
