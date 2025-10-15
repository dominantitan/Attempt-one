# Libraries for Dark Survival-Farming Game

This folder contains external Lua libraries to enhance game development.

## Essential Libraries (Recommended)

### 🎥 **hump.camera** 
- **Purpose**: Advanced camera system with smooth following, zoom, and rotation
- **Why needed**: Your game has multiple areas (forest, cabin, farm, pond) - camera transitions will be crucial
- **Download**: https://github.com/vrld/hump
- **File**: `libs/hump/camera.lua`

### 🎬 **anim8**
- **Purpose**: Sprite animation management 
- **Why needed**: Player walking animations, crop growth stages, animal movements
- **Download**: https://github.com/kikito/anim8
- **File**: `libs/anim8.lua`

### 💥 **bump.lua**
- **Purpose**: 2D collision detection and response
- **Why needed**: Player movement, world boundaries, interaction zones
- **Download**: https://github.com/kikito/bump.lua
- **File**: `libs/bump.lua`

### 🔧 **lume**
- **Purpose**: Utility functions (math, table operations, etc.)
- **Why needed**: Game math, random generation, data manipulation
- **Download**: https://github.com/rxi/lume
- **File**: `libs/lume.lua`

### 📊 **JSON.lua** 
- **Purpose**: Save/load game data in JSON format
- **Why needed**: Your save system needs JSON encoding/decoding
- **Download**: https://github.com/rxi/json.lua
- **File**: `libs/json.lua`

## Optional But Useful Libraries

### 🎵 **TEsound**
- **Purpose**: Advanced audio management with fading, looping
- **Why needed**: Ambient forest sounds, music transitions
- **Download**: https://github.com/Ensayia/TEsound
- **File**: `libs/TEsound.lua`

### 🎛️ **Gamestate** (Alternative to custom)
- **Purpose**: Professional game state management
- **Why needed**: If you want more advanced state transitions
- **Download**: https://github.com/vrld/hump (part of hump)
- **File**: `libs/hump/gamestate.lua`

### 📝 **inspect**
- **Purpose**: Debug printing for tables and objects
- **Why needed**: Debugging save data, game state
- **Download**: https://github.com/kikito/inspect.lua
- **File**: `libs/inspect.lua`

## How to Download and Install

### Method 1: Manual Download
1. Visit each GitHub repository
2. Download the `.lua` files
3. Place them in the appropriate `libs/` subfolder
4. Add `require("libs/filename")` to your main.lua

### Method 2: Git Submodules (Advanced)
```bash
cd "c:\dev\Attempt one"
git submodule add https://github.com/vrld/hump.git libs/hump
git submodule add https://github.com/kikito/anim8.git libs/anim8
git submodule add https://github.com/kikito/bump.lua.git libs/bump
git submodule add https://github.com/rxi/lume.git libs/lume
git submodule add https://github.com/rxi/json.lua.git libs/json
```

## Library Integration Example

```lua
-- In main.lua, add these requires:

-- Essential libraries
local Camera = require("libs/hump/camera")
local anim8 = require("libs/anim8")
local bump = require("libs/bump")
local lume = require("libs/lume")
local json = require("libs/json")

-- Optional libraries
local TEsound = require("libs/TEsound")
local inspect = require("libs/inspect")
```

## Recommended Priority Order

1. **bump.lua** - Get collision working first
2. **json.lua** - Fix your save system
3. **anim8** - Add player animations
4. **hump.camera** - Smooth camera following
5. **lume** - Useful utilities as needed

## File Structure After Adding Libraries

```
libs/
├── bump.lua                 # Collision detection
├── json.lua                 # JSON encoding/decoding
├── lume.lua                 # Utility functions
├── anim8.lua               # Animation system
├── inspect.lua             # Debug printing
├── TEsound.lua             # Audio management
└── hump/                   # HUMP library collection
    ├── camera.lua          # Camera system
    ├── gamestate.lua       # State management
    ├── timer.lua           # Timing utilities
    └── vector.lua          # 2D vector math
```

## Notes
- All these libraries are MIT licensed and free to use
- They're lightweight and won't impact performance
- Start with the essential ones first
- You can always add more libraries later as needed