# Asset Organization Guide

This folder contains all game assets organized by type and category.

## Sprites (`/sprites/`)

### Player (`/sprites/player/`)
- `player_idle_down.png` - Player facing down (idle)
- `player_idle_up.png` - Player facing up (idle)
- `player_idle_left.png` - Player facing left (idle)
- `player_idle_right.png` - Player facing right (idle)
- `player_walk_down.png` - Walking down animation spritesheet
- `player_walk_up.png` - Walking up animation spritesheet
- `player_walk_left.png` - Walking left animation spritesheet
- `player_walk_right.png` - Walking right animation spritesheet

### Animals (`/sprites/animals/`)
- `rabbit.png` - Rabbit sprite
- `deer.png` - Deer sprite
- `boar.png` - Wild boar sprite
- `tiger.png` - Tiger sprite (dangerous)
- `fish.png` - Fish sprite for pond

### Crops (`/sprites/crops/`)
- `carrot_stages.png` - Carrot growth stages (4 frames)
- `potato_stages.png` - Potato growth stages (4 frames)
- `mushroom_stages.png` - Mushroom growth stages (4 frames)
- `berry_stages.png` - Berry growth stages (4 frames)
- `soil_plot.png` - Empty soil plot
- `watered_soil.png` - Watered soil plot

### Environment (`/sprites/environment/`)
- `trees_dark.png` - Dark forest trees
- `cabin.png` - Uncle's cabin
- `shop.png` - Shopkeeper's building
- `railway_station.png` - Old railway station
- `pond.png` - Water pond
- `rocks.png` - Forest rocks and obstacles
- `grass_patches.png` - Various grass textures
- `path_tiles.png` - Dirt/stone path tiles

### UI (`/sprites/ui/`)
- `inventory_slot.png` - Inventory slot background
- `health_bar.png` - Health bar frame
- `hunger_bar.png` - Hunger bar frame
- `stamina_bar.png` - Stamina bar frame
- `dialogue_box.png` - NPC dialogue background
- `button_normal.png` - UI button normal state
- `button_hover.png` - UI button hover state

## Audio

### Sounds (`/sounds/`)
- `footsteps_grass.wav` - Walking on grass
- `footsteps_dirt.wav` - Walking on dirt paths
- `plant_seed.wav` - Planting seeds
- `water_crop.wav` - Watering plants
- `harvest.wav` - Harvesting crops
- `hunt_success.wav` - Successful hunt
- `danger.wav` - Danger/warning sound
- `tiger_roar.wav` - Tiger encounter
- `fishing_cast.wav` - Casting fishing line
- `fishing_catch.wav` - Catching fish
- `shop_bell.wav` - Entering shop
- `coin.wav` - Money transaction

### Music (`/music/`)
- `forest_ambient.ogg` - Main forest ambience (looping)
- `cabin_interior.ogg` - Cozy cabin music
- `danger_theme.ogg` - Tense music for dangerous situations
- `shop_theme.ogg` - Peaceful shop music
- `night_sounds.ogg` - Nighttime forest sounds

## Fonts (`/fonts/`)
- `pixel_font.ttf` - Main game font (pixel style)
- `dialogue_font.ttf` - Font for dialogue text
- `ui_font.ttf` - Font for UI elements

## Recommended Asset Specifications

### Sprites
- **Format**: PNG with transparency
- **Pixel Art Style**: 16x16 or 32x32 base size
- **Color Palette**: Muted, dark tones (Don't Starve inspired)
- **Animation**: 4-frame walking cycles

### Audio
- **Sounds**: WAV format, 44.1kHz, 16-bit
- **Music**: OGG format for compression
- **Volume**: Normalized to avoid clipping

### Color Palette Suggestions
- **Earth Tones**: Browns, dark greens, muted yellows
- **Accent Colors**: Deep reds, dark oranges for highlights
- **Night Tints**: Deep blues and purples
- **UI Colors**: Light grays and whites for contrast

## Asset Loading Notes
- Assets should be loaded in `love.load()` function
- Use `love.graphics.newImage()` for sprites
- Use `love.audio.newSource()` for sounds
- Consider sprite batching for performance with many objects