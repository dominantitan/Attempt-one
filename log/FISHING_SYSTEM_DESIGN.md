# Fishing System Design
**Date:** October 19, 2025  
**Status:** Concept/Design Phase - NOT YET IMPLEMENTED

---

## 🎣 Core Concept

**Fishing as a Mini-Game** (similar to hunting system)
- Separate state/scene like hunting
- Top-down 2D view of pond/river
- Spear-based fishing mechanics
- Risk vs reward with snake encounters

---

## 🎮 Gameplay Mechanics

### Entry & Setup
**Trigger:** Player approaches pond, press ENTER to fish

**Transition:**
```
[OVERWORLD] → Press ENTER at pond → [FISHING STATE]
Top-down view of water surface
Player controls spear throw direction
Fish shadows move under water
```

### Inherited Spear
**Starting Equipment:**
- Uncle's Fishing Spear (inherited at start)
- Unlimited uses but slow
- Must retrieve after each throw
- Single target only

**Spear Stats:**
```lua
{
    name = "Fishing Spear",
    damage = 100, -- One-hit fish
    throwSpeed = 400,
    retrieveTime = 2.0, -- 2 seconds to pull back
    range = 200,
    cost = 0 -- Inherited from uncle
}
```

### Fishing Net (Upgrade)
**Purchase from Shop:** $50

**Net Stats:**
```lua
{
    name = "Fishing Net",
    damage = 100,
    throwSpeed = 300, -- Slower
    retrieveTime = 3.0, -- Takes longer
    range = 150, -- Shorter range
    areaOfEffect = 50, -- Can catch multiple fish!
    cost = 50
}
```

**Net Advantage:** Can catch 2-3 fish in one throw if they're grouped

---

## 🐟 Fish Types & Behavior

### Fish Species
```lua
fishTypes = {
    {
        name = "Small Fish",
        icon = "🐟",
        size = 20,
        speed = 100,
        value = 5,
        spawnRate = 0.5, -- 50%
        behavior = "schooling" -- Groups of 3-5
    },
    {
        name = "Bass",
        icon = "🐠",
        size = 30,
        speed = 80,
        value = 12,
        spawnRate = 0.3, -- 30%
        behavior = "patrol" -- Swims in patterns
    },
    {
        name = "Catfish",
        icon = "🐡",
        size = 40,
        speed = 60,
        value = 20,
        spawnRate = 0.15, -- 15%
        behavior = "bottom" -- Stays near bottom
    },
    {
        name = "Rare Trout",
        icon = "🎣",
        size = 35,
        speed = 120,
        value = 35,
        spawnRate = 0.05, -- 5%
        behavior = "fast" -- Quick, hard to hit
    }
}
```

### Fish Shadows
**Visual Design:**
- Fish appear as **dark shadows** under water
- Shape indicates fish type (small circle, medium oval, large shape)
- Shadows move smoothly across pond
- Ripples when fish surfaces briefly

**Movement Patterns:**
- **Schooling:** Small fish move in groups, synchronized
- **Patrol:** Medium fish swim in figure-8 or circles
- **Bottom:** Large fish stay in deep areas, slow movement
- **Fast:** Rare fish dart quickly, change direction often

---

## 🐍 Snake Danger System

### Water Snake Spawning
**Spawn Conditions:**
- Random spawn every 30-60 seconds
- Warning: "🐍 Something moves in the water..."
- Snake appears as distinctive shadow (S-shaped, red tint)

**Snake Behavior:**
```lua
snake = {
    name = "Water Snake",
    icon = "🐍",
    size = 50,
    speed = 150,
    damage = 100, -- INSTANT DEATH if bites player
    health = 50, -- Can be killed with spear
    aggressive = true, -- Moves toward player
    warningTime = 3.0 -- 3 seconds before attacking
}
```

### Snake Encounter Flow
1. **Warning Phase (3 seconds):**
   - Snake appears with red tint shadow
   - "⚠️ SNAKE! Aim carefully!"
   - Snake slowly approaches player position
   - Player has time to aim spear

2. **Attack Phase:**
   - If snake reaches player hitbox → INSTANT DEATH
   - Game over, return to death state
   - "💀 You were bitten by a water snake!"

3. **Defense Options:**
   - **Kill it:** Hit snake with spear → drops snake skin ($15)
   - **Exit:** Leave fishing area before it reaches you
   - **Dodge:** Move aim reticle away (snake follows slowly)

### Risk vs Reward
**Strategy:**
- Stay fishing = more fish but higher snake risk
- Leave when snake appears = safe but lose time
- Kill snake = valuable drop but uses time/spear throw

---

## 🎯 Fishing Controls

### Spear Aiming (Mouse)
```
MOUSE: Aim direction (crosshair shows throw direction)
LEFT CLICK: Throw spear at mouse position
SPACE: Retrieve spear early (if missed)
ESC: Exit fishing area
```

### Top-Down View Layout
```
════════════════════════════════════
║  POND - TOP-DOWN VIEW            ║
║                                   ║
║    🐟  (Small Fish Shadow)       ║
║         🐠 (Bass Shadow)         ║
║  🐡     (Catfish Shadow)         ║
║                                   ║
║    [PLAYER POSITION - CENTER]    ║
║         ↑ (Spear Direction)      ║
║                                   ║
║  💰 Fish Caught: 3  ⏱ Time: 1:24 ║
════════════════════════════════════
```

### Camera View
- Fixed camera showing entire pond area (800x600 view)
- Player spear origin at center bottom
- Fish swim across visible area
- Water texture with transparency effect

---

## 🌊 Pond Environment

### Visual Elements
**Water Effects:**
- Blue-green water texture with transparency
- Ripples where fish surface
- Shadows darker in deep areas
- Light reflections (shimmer effect)

**Depth Zones:**
- Shallow (edges): Light blue, small fish
- Medium (middle): Blue, all fish types
- Deep (center): Dark blue, large fish only

**Decorations:**
- Lily pads (static obstacles)
- Reeds at edges
- Rocks on pond floor (shadows)
- Occasional fish jump (visual only)

---

## 💰 Economy Integration

### Fish Values (Sell at Shop)
- Small Fish: $5 each
- Bass: $12 each  
- Catfish: $20 each
- Rare Trout: $35 each
- Snake Skin: $15 each

### Net Purchase
- Fishing Net: $50 (one-time purchase)
- Unlocks multi-catch ability
- Strategic investment for serious fishers

### Income Comparison
**Fishing vs Hunting:**
- Fishing: Safer (except snake), consistent income
- Hunting: Higher value but more dangerous
- Foraging: Free but random spawns

**Ideal Strategy:**
- Early game: Fish with spear (safe money)
- Mid game: Buy net, fish efficiently
- Late game: Hunt for big money, fish as backup

---

## 🎮 Technical Implementation

### File Structure
```
states/
    fishing.lua       -- New fishing state (like hunting.lua)
    
systems/
    fishing_system.lua -- Fish spawning, behavior logic
    
entities/
    fish.lua          -- Fish types and properties
    snake.lua         -- Snake entity and AI
```

### State Flow
```lua
-- Entry from gameplay state
if atPond and pressedEnter then
    gamestate.switch("fishing")
end

-- Fishing state update loop
function fishing:update(dt)
    updateFishMovement(dt)
    updateSpearPhysics(dt)
    checkSnakeSpawn(dt)
    checkCollisions()
end

-- Exit conditions
if pressedEscape or snakeBitPlayer then
    gamestate.switch("gameplay")
    if snakeBitPlayer then
        gamestate.switch("death") -- Instant death
    end
end
```

### Fish AI
```lua
-- Schooling behavior
for each fishInSchool do
    followLeader(leader, distance)
    matchSpeed(leader)
    avoidEdges()
end

-- Patrol behavior
function patrolBehavior(fish)
    followWaypoints(fish.patrolPath)
    smoothTurning()
end

-- Chase player (snake only)
function snakeBehavior(snake)
    moveToward(playerPosition)
    avoidObstacles()
    attackWhenClose()
end
```

---

## 🎯 Progression Integration

### Early Game (Day 0-1)
- Start with uncle's spear
- Fish for quick safe money ($5-20 per session)
- Learn spear aiming mechanics
- Encounter first snake (scary tutorial)

### Mid Game (Day 2-5)
- Buy fishing net ($50)
- More efficient fishing (2-3 fish per throw)
- Balance fishing vs hunting vs farming
- Snake becomes manageable threat

### Late Game (Day 6+)
- Fishing as reliable income source
- Quick cash between hunting sessions
- Snake hunting for bonus $15
- Supplies for boss fight preparation

---

## 🎨 Visual & Audio Ideas

### Sound Effects
- 🎣 Spear throw: "Whoosh"
- 💦 Spear hits water: "Splash"
- 🐟 Fish caught: "Pop" + ripple sound
- 🐍 Snake appears: Hiss + warning music
- ⚡ Snake bite: Dramatic sting
- 🎵 Fishing ambiance: Calm water sounds, birds

### Visual Feedback
- Splash particles when spear enters water
- Blood particles if fish/snake hit
- Screen flash red when snake gets close
- Slow-motion when snake about to bite (last chance!)
- Victory sparkle when rare fish caught

---

## ⚠️ Design Considerations

### Balance Concerns
**Not Too Easy:**
- Spear retrieve time prevents spam
- Fish move unpredictably
- Snake forces time pressure
- Net is expensive upgrade

**Not Too Hard:**
- Large pond area (easier to hit fish)
- Shadows visible (not pure guessing)
- Snake warning gives time to react
- Can exit anytime (no trap)

### Player Strategy
**Skill-Based Income:**
- Good aim = more fish = more money
- Risk management with snake
- Net upgrade timing decision
- Time investment vs reward

### Replayability
- Different fish spawn patterns each session
- Random snake timing creates tension
- Challenge: Catch all 4 fish types in one session
- Speedrun: How much money in 2 minutes?

---

## 📝 Implementation Phases

### Phase 1: Basic Fishing (3 hours)
- [ ] Create fishing state (copy hunting structure)
- [ ] Top-down pond view rendering
- [ ] Spear throw mechanics with mouse
- [ ] Fish shadows and movement
- [ ] Collision detection (spear hits fish)

### Phase 2: Fish Variety (2 hours)
- [ ] Implement 4 fish types with stats
- [ ] Different movement behaviors (schooling, patrol, etc.)
- [ ] Shadow shapes based on fish size
- [ ] Value system and inventory integration

### Phase 3: Snake Danger (2 hours)
- [ ] Snake spawn timer and warning
- [ ] Snake AI (move toward player)
- [ ] Death trigger on contact
- [ ] Snake killable for skin drop

### Phase 4: Fishing Net (1 hour)
- [ ] Add net to shop inventory
- [ ] Purchase system and flag
- [ ] Area-of-effect throw detection
- [ ] Multi-catch logic

### Phase 5: Polish (2 hours)
- [ ] Water visual effects
- [ ] Sound effects integration
- [ ] UI (fish count, time, warnings)
- [ ] Balance testing and tuning

**TOTAL TIME:** ~10 hours

---

## 🎯 Priority Status

**Current Plan:**
1. ✅ Polish foraging system (glow, variety)
2. ✅ Complete farming system (growth, watering)
3. ✅ Expand shop system (stock, items)
4. ⏸️ Fishing system (this document)
5. ⏸️ Story redesign (STORY_REDESIGN.md)

**Fishing Implementation:** After Option A features complete

---

## 💭 Alternative Ideas

### Fishing Boat
- Upgradeable boat in center of pond
- Cast from boat for deeper fish
- Costs $100, increases rare fish spawn

### Seasonal Fish
- Different fish in different seasons
- Ice fishing in winter
- Spawning season = more fish

### Fishing Quests
- Shopkeeper: "Catch me a catfish for $30"
- Uncle's notes: "The legendary giant fish..."
- Achievements for rare catches

---

**STATUS:** Documented, awaiting implementation after core polish ✅
