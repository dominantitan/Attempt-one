# Dark Forest Survival - Room System

## 🏠 Area/Room System Overview

The game now features a comprehensive room/area system similar to Stardew Valley, allowing players to move between different locations:

### Available Areas

#### 🌲 Main World (Dark Forest)
- **Type**: Overworld
- **Features**: Farm plots, pond, structures, hunting zone entrances
- **Exits**: 
  - Enter cabin (near wooden cabin structure)
  - Enter shop (near merchant building)
  - Enter hunting zones (circular areas in corners)

#### 🏠 Cabin Interior (Uncle's Cabin)
- **Type**: Interior
- **Size**: 480x320 pixels
- **Features**:
  - 🛏️ **Bed**: Press Z to sleep (fully restore health/stamina, advance day)
  - 📦 **Storage Chest**: Press C to access (placeholder for now)
  - 🔥 **Fireplace**: Press F to warm up (restore some health/energy)
  - 📋 **Table**: Press E to examine (find uncle's notes)
- **Exit**: Press ENTER near door to go outside

#### 🏪 Shop Interior (Merchant's Shop)
- **Type**: Interior 
- **Size**: 320x240 pixels
- **Features**:
  - 🛒 **Counter**: Press S to trade with merchant
  - 📚 **Shelves**: Press E to examine goods
- **Exit**: Press ENTER near door to go outside

#### 🚂 Railway Station (Old Railway Station)
- **Type**: Overworld Structure
- **Location**: Southwestern area (replaces hunting zone)
- **Features**:
  - 🛒 **Station Master Ellis**: Press S to trade with station shopkeeper
  - 🔍 **Examine Station**: Press E to investigate the mysterious old station
  - 🛤️ **Railway Tracks**: Visual railway elements extending into the forest
  - 🏪 **Trading Post**: Supplies for travelers (seeds, water, meat, tools)

#### 🌲 Hunting Areas (3 Zones)
- **Northwestern Woods**: Rabbit + Deer (Easy)
- **Northeastern Grove**: Rabbit + Boar (Medium)  
- **Southeastern Wilderness**: Boar + Tiger (Hard)

**Features**:
- **Dense Animal Spawning**: 4-10 animals per zone
- **Contained Boundaries**: Animals stay within circular boundaries
- **Hunting**: Press H to hunt nearby animals
- **Danger System**: Tigers can force you to flee the area
- **Exit**: Press ENTER near exit point to return to main world

### Controls

#### Universal
- **WASD**: Move around
- **I**: Open inventory
- **ESC**: Pause game

#### Area Transitions  
- **ENTER**: Enter/exit areas when near doors or zone entrances

#### Interactions
- **Z**: Sleep in bed (cabin only)
- **C**: Access storage chest (cabin only)  
- **F**: Warm by fire (cabin only)
- **S**: Trade with merchants (shop interior + railway station)
- **H**: Hunt animals (hunting areas + main world)
- **E**: Examine furniture/objects/railway station

### Technical Details

#### Area System Architecture
- `systems/areas.lua`: Core area management system
- Each area has definition with size, type, exits, furniture, spawning rules
- Area-specific data stored separately (animals, objects, visited status)
- Seamless transitions between areas with position management

#### Area Types
- **overworld**: Main game world with farming, structures, hunting zone entrances
- **interior**: Indoor spaces with furniture interactions and cozy atmosphere  
- **hunting_area**: Contained wilderness zones with dense animal populations

#### Integration
- Updated `states/gameplay.lua` for area-aware interactions
- Modified `main.lua` for area-specific rendering and updates
- Hunting system enhanced for area-specific animal spawning
- Camera and collision systems work across all areas

### Gameplay Flow

1. **Start** in main world Dark Forest
2. **Explore** to find cabin, shop, and hunting zones
3. **Enter cabin** to sleep, access storage, warm by fire
4. **Visit shop** to trade with merchant
5. **Enter hunting areas** for better animal hunting
6. **Manage** health, stamina, and day/night cycle
7. **Investigate** uncle's disappearance through notes and exploration

The room system creates immersive, distinct spaces that each serve specific gameplay purposes while maintaining the dark, mysterious atmosphere of the forest survival theme.