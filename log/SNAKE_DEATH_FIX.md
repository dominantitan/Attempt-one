# Snake Death Message Fix

## Issue Found
When killed by snake in fishing, death screen showed "The tiger caught you!" instead of "The water snake bit you!"

## Root Cause
**Parameter mismatch in `death:enter()` function**

### The Problem:
```lua
-- death.lua (BEFORE FIX)
function death:enter(from, deathCause)
    death.cause = deathCause or "tiger"  -- deathCause was nil!
```

When calling `gamestate.switch("death", "snake")`:
- The gamestate.switch passes `...` (varargs) to the enter function
- So `death:enter(...)` becomes `death:enter("snake")`
- With two parameters expected, this meant:
  - `from` = "snake" 
  - `deathCause` = nil ❌
- Therefore `deathCause or "tiger"` always defaulted to "tiger"

### The Fix:
```lua
-- death.lua (AFTER FIX)  
function death:enter(deathCause)
    death.cause = deathCause or "tiger"  -- Now receives "snake" correctly!
```

Now when calling `gamestate.switch("death", "snake")`:
- `death:enter(...)` becomes `death:enter("snake")`
- With one parameter expected:
  - `deathCause` = "snake" ✅
- Therefore `death.cause` is set to "snake" correctly!

## What Those Circles Are

The connected outline circles in the fishing screen are **water ripples** - a visual effect for the pond!

```lua
-- fishing.lua line 723
-- Draw lighter water ripples for depth
love.graphics.setColor(0.2, 0.5, 0.7, 0.3)
for i = 1, 5 do
    love.graphics.circle("line", 200 + i * 120, 150 + math.sin(fishing.timeInSession + i) * 20, 40 + i * 10)
end
```

These animated circles create a sense of water depth and movement in the top-down fishing view.

## Files Modified

### `states/death.lua`
- Changed `death:enter(from, deathCause)` to `death:enter(deathCause)`
- Added debug prints to verify correct parameter passing
- Death message now correctly shows snake emoji 🐍 and message when killed by snake

## Testing
1. Go fishing at the pond
2. Wait 30-60 seconds for water snake to spawn
3. Move away from land and let snake bite your feet
4. Verify death screen shows: **"🐍 The water snake bit you!"**

## Status
✅ **FIXED** - Snake death now displays correct message!
