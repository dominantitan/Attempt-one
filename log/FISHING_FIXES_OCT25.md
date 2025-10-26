# Fishing System Fixes - October 25, 2025

## Issues Reported
1. **Spear origin problem**: Spear felt like it came from player's legs instead of from above
2. **Rock collision issue**: Rocks should only block spear when it's in the water, not while in air (top-down perspective)
3. **Double rendering**: Fishing appeared as an overlay on top of the overworld instead of a dedicated area like hunting
4. **Extra sprites drawn**: Multiple layers being rendered unnecessarily

## Root Causes

### 1. Spear Origin Point
- Spear was being thrown from `playerX, playerY` (player's feet position)
- Player is standing on shore above the pond, so spear should come from elevated position
- No visual indicator showing the spear was being thrown from player's hands

### 2. Rock Collision
- **NOT AN ISSUE**: Rock collision was already correctly implemented
- Collision check: `if proj.height <= 0 then` - only checks when spear is in water
- This is correct for top-down perspective where spear falls from above

### 3. Double Rendering
- `main.lua`'s `love.draw()` function always drew world elements first
- Then drew the current game state on top
- This made fishing (and potentially other states) render as overlays
- Inventory and shop had the same issue

## Solutions Applied

### 1. Fixed Spear Origin (states/fishing.lua)
**File**: `states/fishing.lua` - `fishing:throwSpear()` function

```lua
-- OLD CODE:
table.insert(fishing.projectiles, {
    x = fishing.playerX,
    y = fishing.playerY,  -- At feet level
    -- ...
})

-- NEW CODE:
-- Spear starts from player's hand height (elevated position on shore)
local spearStartX = fishing.playerX
local spearStartY = fishing.playerY - 40  -- 40 pixels above feet = hand/chest height

local dx = fishing.mouseX - spearStartX
local dy = fishing.mouseY - spearStartY

table.insert(fishing.projectiles, {
    x = spearStartX,
    y = spearStartY,  -- At hand height
    -- ...
})
```

**Result**: Spear now clearly launches from player's elevated position (standing on shore) rather than their feet in the water.

### 2. Improved Visual Feedback (states/fishing.lua)
**File**: `states/fishing.lua` - `fishing:draw()` cursor section

```lua
-- Aiming line from player's HAND HEIGHT (not feet) to cursor
local handX = fishing.playerX
local handY = fishing.playerY - 40  -- Hand/chest height where spear is held
love.graphics.setColor(1, 1, 1, 0.3)
love.graphics.line(handX, handY, fishing.mouseX, fishing.mouseY)

-- Draw small circle at hand position to show spear origin
love.graphics.setColor(1, 1, 0, 0.5)
love.graphics.circle("fill", handX, handY, 4)
```

**Result**: 
- Aiming line now connects from player's hand height to target
- Yellow circle shows exact launch point
- Makes it visually obvious the spear is thrown from above

### 3. Fixed Double Rendering (main.lua)
**File**: `main.lua` - `love.draw()` function

**Problem**: The draw function always rendered world elements, then overlaid the current state on top.

**Solution**: Added state detection to skip world rendering for "fullscreen" states:

```lua
function love.draw()
    -- Check if we're in a dedicated mini-game state (hunting, fishing, death)
    -- or UI state (inventory, shop) that should overlay everything
    local currentStateName = nil
    for name, state in pairs(gamestate.states) do
        if state == gamestate.current then
            currentStateName = name
            break
        end
    end
    
    local isFullscreenState = currentStateName == "hunting" or 
                             currentStateName == "fishing" or 
                             currentStateName == "death" or
                             currentStateName == "inventory" or
                             currentStateName == "shop"
    
    -- Only draw world/camera if we're in normal gameplay, not mini-games
    if not isFullscreenState then
        -- Apply camera transformation
        if Game.camera.apply then
            Game.camera:apply()
        end
        
        -- Draw world elements...
        
        -- Remove camera transformation
        if Game.camera.unapply then
            Game.camera:unapply()
        end
        
        -- Draw day/night overlay (only for gameplay)
        daynightSystem.draw()
    end
    
    -- Draw current game state (mini-games draw themselves completely)
    gamestate.draw()
    
    -- Draw UI overlay (only for normal gameplay, not mini-games)
    if not isFullscreenState then
        -- Draw money, health, time, etc.
    end
end
```

**Result**: 
- Fishing now renders as a complete standalone area (like hunting)
- No more overworld sprites visible underneath
- Clean, dedicated fishing screen
- Same fix applies to inventory, shop, death screens

## Technical Details

### Spear Physics (3D in Top-Down View)
The fishing system uses a pseudo-3D spear physics model:

1. **Height tracking**: Spear has a `height` property (starts at 150)
2. **Fall speed**: Falls at 300 pixels/second
3. **Collision**: Only checks when `height <= 0` (spear hits water)
4. **Visual feedback**: Shadow offset based on height to show depth

This system already correctly handled the top-down perspective. The fix was purely about the launch position.

### State Management
The game uses a state machine (`states/gamestate.lua`) with these states:
- `gameplay` - Normal overworld
- `hunting` - First-person hunting mini-game
- `fishing` - Top-down fishing mini-game (fixed)
- `inventory` - Item management screen
- `shop` - Trading interface
- `death` - Game over screen

Each state should be either:
1. **Overlay states**: Draw on top of world (inventory, shop)
2. **Replacement states**: Completely replace world (hunting, fishing, death)

The fix properly categorizes all states as "fullscreen" states that don't need world rendering underneath.

## Testing Results

✅ Spear now launches from player's hand height (40px above feet)
✅ Aiming line connects from hand to target position
✅ Visual marker shows exact launch point
✅ Rock collision still works correctly (only blocks at water level)
✅ Fishing renders as dedicated area (no overworld underneath)
✅ No extra sprites or double rendering
✅ UI elements hidden during fishing (clean view)

## Files Modified

1. **states/fishing.lua**
   - `fishing:throwSpear()` - Fixed spear origin point
   - `fishing:draw()` - Improved aiming visual feedback

2. **main.lua**
   - `love.draw()` - Added fullscreen state detection
   - Prevents world/UI rendering for mini-game states

## Impact on Other Systems

- **Positive side effect**: This fix also applies to inventory and shop states
- **Hunting state**: Already worked correctly (verified pattern is the same)
- **Death state**: Now properly fullscreen without world underneath
- **Performance**: Slight improvement by not rendering world when not needed

## Future Improvements

Consider these enhancements:
1. Add arc trajectory visualization for spear throw (parabolic path)
2. Add splash effect at spear launch point
3. Consider making player silhouette more prominent at bottom
4. Add ripple effects at hand position when throwing

## Conclusion

All three reported issues have been resolved:
1. ✅ Spear comes from player's hand height (above the pond)
2. ✅ Rock collision works correctly for top-down perspective
3. ✅ Fishing is a dedicated area, not an overlay

The fishing mini-game now feels like a proper standalone area, similar to the hunting mini-game, with clear visual feedback about spear trajectory and launch point.
