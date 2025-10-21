# Fishing System Refactor - Implementation Guide
**Date:** October 21, 2025  
**Status:** In Progress - Needs Manual File Creation

---

## 🎯 Goal

Refactor fishing from a mini-game overlay to an area system like hunting:
- Top-down view (not first-person)
- Mouse-aimed spear throwing
- Snake danger with instant death (like tiger)
- Fewer fish (5-8 instead of 15)
- Harder difficulty

---

## 📝 Required Changes

### 1. states/fishing.lua - CREATE NEW FILE

Create a simple 300-line fishing.lua based on hunting.lua structure. Key features:

```lua
-- Minimal structure:
local fishing = {}
fishing.active = false
fishing.fish = {} -- 5-8 fish
fishing.snake = nil -- Spawns after 30-60s
fishing.projectiles = {} -- Spear throws

function fishing:enter(fromState, areaId)
    -- Spawn fish, reset snake timer, show mouse
end

function fishing:update(dt)
    -- Update fish movement
    -- Update spear projectiles  
    -- Update snake (3s warning, then chase)
    -- Check snake collision = death
end

function fishing:draw()
    -- Simple blue water
    -- Fish shadows (circles)
    -- Snake (red circle if warning, else dark red)
    -- Spear projectiles
    -- Player legs
    -- Crosshair
    -- UI
end

function fishing:mousepressed(x, y, button)
    -- Throw spear toward mouse
end

function fishing:keypressed(key)
    -- ESC to exit
end
```

### 2. systems/areas.lua - ALREADY DONE ✅

Added fishing zone and area definition:
- Fishing zone at pond (630, 480, radius 60)
- fishing_pond area (800x600)
- Fish count: 5-8 (reduced from 15)
- Added `getPlayerNearFishingZone()` function

### 3. states/gameplay.lua - NEEDS UPDATE

Add fishing zone check in keypressed(), right after hunting zone check (around line 270):

```lua
-- Check for fishing zones
local nearFishingZone = areas.getPlayerNearFishingZone(playerSystem.x, playerSystem.y)
if nearFishingZone then
    print("🎣 Entering " .. nearFishingZone.name .. " - Top-Down Fishing!")
    local zoneId = nearFishingZone.target or nearFishingZone.name
    gamestate.switch("fishing", zoneId)
    return
end
```

Also update the prompt display (around line 92):

```lua
-- Add after hunting zone check:
local nearFishingZone = areas.getPlayerNearFishingZone(playerSystem.x, playerSystem.y)
if nearFishingZone then
    prompt = "🎣 " .. nearFishingZone.name .. ": Press ENTER to fish"
end
```

Remove old pond interaction code (key == "return" for fishing structure).

### 4. states/death.lua - ALREADY DONE ✅

Added snake death message:
- Accepts death cause parameter
- Shows snake emoji and message if cause == "snake"

### 5. states/shop.lua - ALREADY DONE ✅

- Fishing Net: $50
- Fish sell prices added

---

## 🐍 Snake Behavior (Like Tiger)

```lua
-- Spawn after 30-60 seconds
fishing.snakeSpawnTimer = math.random(30, 60)

-- 3 second warning with pulsing red visual
fishing.snakeWarning = true
fishing.snakeWarningTimer = 3.0

-- After warning, chase player at 150 speed
-- If reaches player (distance < 40): INSTANT DEATH
gamestate.switch("death", "snake")
```

---

## 🐟 Fish System (Simplified)

```lua
-- Only 5-8 fish spawn (harder)
local fishCount = math.random(5, 8)

-- 4 types with different speeds:
small_fish: speed 100, value $5
bass: speed 80, value $12
catfish: speed 60, value $20
rare_trout: speed 120, value $35

-- Simple AI: random movement, bounce off boundaries
if math.random() < 0.02 then
    fish.vx = (math.random() - 0.5) * fish.type.speed
    fish.vy = (math.random() - 0.5) * fish.type.speed
end
```

---

## 🎯 Spear Mechanics

```lua
-- Mouse aim, click to throw
function fishing:throwSpear()
    local dx = mouseX - playerX
    local dy = mouseY - playerY
    -- Normalize and create projectile
    -- Speed: 400 pixels/second
    -- Lifetime: 1 second
    -- AOE: 10 (spear) or 50 (net)
end

-- Collision: distance < aoe + fish.size
-- On hit: add to inventory, remove fish
```

---

## ✅ What's Already Done

1. ✅ areas.lua updated with fishing zone
2. ✅ death.lua updated with snake death
3. ✅ shop.lua updated with net and fish prices
4. ✅ Removed old goFishing() function
5. ✅ Updated pond prompt text

---

## ❌ What Needs Manual Creation

**states/fishing.lua** - File got corrupted during automated creation. Needs to be created manually with the structure above.

---

## 🎮 Final Flow

```
Player → Pond (630, 480)
→ Prompt: "🎣 Pond: Press ENTER to fish"
→ Press ENTER
→ gamestate.switch("fishing", "fishing_pond")
→ fishing:enter() spawns 5-8 fish
→ Top-down view, mouse aim, click to throw spear
→ Snake spawns after 30-60s
→ 3s warning, then chases
→ If caught: gamestate.switch("death", "snake")
→ Press ESC: return to gameplay
```

---

## 🔧 Debugging Tips

1. Test pond zone detection: walk to (630, 480)
2. Check prompt appears: "Press ENTER to fish"
3. Press ENTER: should switch to fishing state
4. If crash: fishing.lua has errors
5. Check snake spawn timer in console
6. Test snake death by letting it catch you
7. Test fish catching with left click

---

**STATUS:** Need to manually create fishing.lua file due to file corruption issues with automated tool.
