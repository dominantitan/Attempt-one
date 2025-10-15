# Hunting Zone System - Implementation Guide

## ✅ What Was Changed

### Problem Fixed:
1. ❌ **OLD**: Press ENTER anywhere to hunt (floating hunting mode)
2. ❌ **OLD**: Railway station was treated as hunting area
3. ❌ **OLD**: No connection to the 3 circular hunting zones on the map

### Solution Implemented:
1. ✅ **NEW**: Hunting only accessible at **3 circular hunting zones**
2. ✅ **NEW**: Must walk to hunting zones to hunt
3. ✅ **NEW**: Railway station is now just a shop/mystery location
4. ✅ **NEW**: Each hunting zone has unique attributes

---

## 🗺️ Hunting Zone Locations

The game has **3 hunting zones** marked as circles on the main world map:

### 1. Northwestern Woods 🌲
- **Location**: Top-left (x: 130, y: 130)
- **Radius**: 80 pixels
- **Animals**: Rabbit, Deer
- **Danger Level**: Low (0.2)
- **Best For**: Beginners, safe hunting
- **Expected**: 6-10 animals

### 2. Northeastern Grove 🌳
- **Location**: Top-right (x: 830, y: 130)
- **Radius**: 80 pixels
- **Animals**: Rabbit, Boar
- **Danger Level**: Medium (0.4)
- **Best For**: Intermediate hunters
- **Expected**: 5-8 animals

### 3. Southeastern Wilderness 🌑
- **Location**: Bottom-right (x: 830, y: 410)
- **Radius**: 80 pixels
- **Animals**: Boar, Tiger
- **Danger Level**: High (0.8)
- **Best For**: Advanced hunters, high risk/reward
- **Expected**: 4-6 animals
- **⚠️ WARNING**: Tigers spawn here!

---

## 🎮 How to Hunt Now

### Step-by-Step Process:

1. **Find a Hunting Zone**
   - Look for circular areas on the map
   - Walk towards one of the 3 zones
   - They're marked in your memory from exploring

2. **Approach the Circle**
   - Get close to the circular boundary
   - You'll see a prompt appear:
     - `🎯 [Zone Name]: Press ENTER to hunt`

3. **Enter Hunting Mode**
   - Press **ENTER** when near the circle
   - You'll transition to the NEW hunting system
   - First-person DOOM-style hunting begins

4. **Hunt Animals**
   - Use the new hunting mechanics:
     - Mouse to aim
     - Left-click to shoot
     - 1/2/3 to switch weapons
     - Watch for peeking animals
     - Avoid tigers!

5. **Exit Hunting**
   - Press **ENTER** or **ESC** to leave
   - Or wait for 3-minute timer to end
   - Or tiger forces you out (fear)

---

## 🔧 Technical Implementation

### Code Changes Made:

#### 1. Removed Global Hunting Access
**File**: `states/gameplay.lua`

**Before**:
```lua
-- Press ENTER anywhere to hunt
if key == "return" then
    gamestate.switch("hunting")
end
```

**After**:
```lua
-- Press ENTER only near hunting zones
if key == "return" then
    local nearHuntingZone = areas.getPlayerNearHuntingZone(playerX, playerY)
    if nearHuntingZone then
        gamestate.switch("hunting")
    else
        print("Find a hunting zone first!")
    end
end
```

#### 2. Added Zone Detection Prompt
**File**: `states/gameplay.lua`

**New Code**:
```lua
-- Show prompt when near hunting zone
if currentArea.type == "overworld" and currentArea.huntingZones then
    local nearHuntingZone = areas.getPlayerNearHuntingZone(playerX, playerY)
    if nearHuntingZone then
        love.graphics.print("🎯 " .. nearHuntingZone.name .. ": Press ENTER to hunt")
    end
end
```

#### 3. Zone Detection Function
**File**: `systems/areas.lua`

**Existing Code** (now properly used):
```lua
function areas.getPlayerNearHuntingZone(playerX, playerY)
    if areas.currentArea ~= "main_world" then return nil end
    
    local currentArea = areas.getCurrentArea()
    if not currentArea.huntingZones then return nil end
    
    for _, zone in ipairs(currentArea.huntingZones) do
        local distance = math.sqrt((playerX - zone.x)^2 + (playerY - zone.y)^2)
        -- Check if player is near the circle edge
        if distance <= zone.radius + 30 and distance >= zone.radius - 20 then
            return zone
        end
    end
    
    return nil
end
```

---

## 🎯 Detection Zones

### How It Works:
- Each hunting zone is a **circle** on the map
- Player must be **near the edge** of the circle to enter
- Detection range: **radius ±30 pixels**
- This creates an "entrance" feel (not floating in middle)

### Visual Representation:
```
        Hunting Zone Circle (radius 80)
              ╭───────╮
           ╭─────────────╮
        ╭─────────────────────╮
       │    Detection Zone    │ ← 50px band around circle
       │  (radius 60 to 110)  │
        ╰─────────────────────╯
           ╰─────────────╯
              ╰───────╯
```

---

## 📋 Zone Comparison Table

| Zone | Location | Animals | Danger | Difficulty | Tiger Risk |
|------|----------|---------|---------|------------|------------|
| Northwestern Woods | Top-Left | Rabbit, Deer | 20% | ⭐ Easy | None |
| Northeastern Grove | Top-Right | Rabbit, Boar | 40% | ⭐⭐ Medium | None |
| Southeastern Wilderness | Bottom-Right | Boar, Tiger | 80% | ⭐⭐⭐ Hard | HIGH! |

---

## 🚫 What Doesn't Trigger Hunting Anymore

### Removed Access Points:
- ❌ Pressing ENTER in middle of map
- ❌ Pressing ENTER at railway station
- ❌ Pressing ENTER at cabin
- ❌ Pressing ENTER at shop
- ❌ Pressing ENTER at farm
- ❌ Pressing ENTER at pond

### Only These Work Now:
- ✅ Northwestern Woods circle (top-left)
- ✅ Northeastern Grove circle (top-right)
- ✅ Southeastern Wilderness circle (bottom-right)

---

## 🎮 Player Experience

### Exploration Flow:
```
Start Game
    ↓
Explore Main World
    ↓
Find Circular Hunting Zones
    ↓
Approach Circle Edge
    ↓
See Prompt: "🎯 [Zone]: Press ENTER"
    ↓
Press ENTER
    ↓
Enter NEW Hunting Mode
    ↓
First-Person DOOM-style hunting
    ↓
Animals peek from bushes
    ↓
Weapon points at crosshair
    ↓
Shoot with mouse
    ↓
Exit with ENTER
    ↓
Return to Main World
    ↓
Sell meat at shop
    ↓
Buy more ammo
    ↓
Choose next hunting zone
```

---

## 💡 Gameplay Benefits

### Why This Is Better:

1. **Spatial Connection** 🗺️
   - Hunting zones are actual places
   - Must travel to them
   - Creates exploration goals

2. **Risk/Reward Choice** ⚖️
   - Choose safe zone (Northwestern)
   - Or risky zone (Southeastern + tigers)
   - Strategic decision making

3. **World Integration** 🌍
   - Hunting feels like part of the world
   - Not a floating minigame
   - Connects to map layout

4. **Progressive Difficulty** 📈
   - Start at easy zone
   - Move to harder zones as you improve
   - Natural skill progression

5. **No Confusion** ✅
   - Clear where hunting happens
   - No accidental triggers
   - Railway station is not hunting area

---

## 🐛 Bug Fixes

### Railway Station Issue - FIXED ✅
**Problem**: Railway station was being confused with hunting area

**Before**:
```
Player at railway station
Press ENTER
→ Enters hunting mode ❌ (wrong!)
```

**After**:
```
Player at railway station
Press ENTER
→ Nothing happens (correct!)
Press B → Opens shop ✅
Press E → Examines station ✅
```

---

## 🧪 Testing Guide

### Test 1: Northwestern Woods
1. Move to top-left corner (130, 130)
2. Approach circular area
3. Look for prompt: "🎯 Northwestern Woods: Press ENTER to hunt"
4. Press ENTER
5. ✅ Should enter hunting mode

### Test 2: Northeastern Grove
1. Move to top-right corner (830, 130)
2. Approach circular area
3. Look for prompt: "🎯 Northeastern Grove: Press ENTER to hunt"
4. Press ENTER
5. ✅ Should enter hunting mode

### Test 3: Southeastern Wilderness
1. Move to bottom-right corner (830, 410)
2. Approach circular area
3. Look for prompt: "🎯 Southeastern Wilderness: Press ENTER to hunt"
4. Press ENTER
5. ✅ Should enter hunting mode
6. ⚠️ Watch out for tigers!

### Test 4: Railway Station (Should NOT Hunt)
1. Move to railway station (130, 410)
2. Press ENTER
3. ✅ Should print: "Find a hunting zone first!"
4. Should NOT enter hunting mode

### Test 5: Random Location (Should NOT Hunt)
1. Stand in middle of map (480, 270)
2. Press ENTER
3. ✅ Should print: "Find a hunting zone first!"
4. Should NOT enter hunting mode

---

## 📊 Success Criteria

The system works correctly if:
- ✅ Can only hunt from 3 circular zones
- ✅ Prompts show zone names when near
- ✅ ENTER doesn't work anywhere else
- ✅ Railway station is NOT a hunting trigger
- ✅ Each zone has different animals
- ✅ All 3 zones accessible and functional

---

The hunting system is now properly integrated with the game world! 🎯🏹
