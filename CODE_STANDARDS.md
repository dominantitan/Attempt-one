# Code Standards & Architecture Guide

## Purpose
This document explains the coding patterns, architecture decisions, and best practices for this LÖVE2D farming/hunting game. Read this BEFORE making changes to prevent bugs and maintain consistency.

---

## Player Entity (`entities/player.lua`)

### Inventory System
**CRITICAL:** The inventory uses a consolidated array-based system:

```lua
player.inventory = {
    items = {},      -- Array of {type = "string", quantity = number}
    maxSlots = 20,
    money = 0        -- Stored separately (not a stackable item)
}
```

**How to add/remove items:**
```lua
-- Adding items (automatically stacks if exists)
playerEntity.addItem("seeds", 5)  -- Adds 5 seeds
playerEntity.addItem("carrot", 1) -- Adds 1 carrot

-- Removing items
playerEntity.removeItem("seeds", 1)  -- Removes 1 seed

-- Checking items
playerEntity.hasItem("seeds", 1)     -- Returns true/false
playerEntity.getItemCount("seeds")   -- Returns quantity

-- Money operations
playerEntity.addMoney(50)            -- Add money
playerEntity.removeMoney(10)         -- Remove money (returns false if insufficient)
```

### API Getters (Preferred Pattern)
```lua
-- Use these getter functions (prevents nil errors):
playerEntity.getMoney()    -- Returns 0 if nil
playerEntity.getHealth()
playerEntity.getHunger()
playerEntity.getStamina()

-- Direct property access also works:
playerEntity.health
playerEntity.inventory.money
```

**❌ NEVER DO THIS:**
```lua
-- Don't mix inventory systems!
player.inventory.seeds = 5  -- BAD - bypasses addItem logic
player.inventory.items[1] = ... -- BAD - direct array manipulation

-- Don't access undefined properties
player.nutrition  -- Doesn't exist yet
player.getStats() -- Doesn't exist
```

---

## Shop System (`states/shop.lua`)

### Price Balance Philosophy
The shop prices are **carefully balanced** to make hunting more profitable than farming:

| Activity | Cost | Sell Price | Net Profit | Risk |
|----------|------|------------|------------|------|
| **Farming** | Seeds $10-20 | Crops $4-10 | Small (needs water+time) | Low |
| **Hunting** | Free | Meat $15-100 | High | Medium-High |
| **Foraging** | Free | Items $5-8 | Medium | Low |

**When balancing prices, maintain these ratios:**
- Farming: Barely profitable (forces diversification)
- Hunting: 3-4x more profitable than farming (rewards risk)
- Foraging: Safe but low yield (backup income)

### Shop Code Pattern
```lua
-- ALWAYS use getMoney() to avoid nil errors:
local money = playerEntity.getMoney()
if money >= item.price then
    playerEntity.removeMoney(item.price)
    playerEntity.addItem(item.type, 1)
end

-- Money formatting: ALWAYS use $ prefix
print("Costs $" .. price)
print("Your money: $" .. playerEntity.getMoney())
```

**Shop Items Structure:**
```lua
shop.items = {
    {name = "Display Name", type = "item_id", price = 10, description = "Text"}
}

shop.buyPrices = {
    item_id = 10  -- What shopkeeper pays for this item
}
```

---

## Farming System (`systems/farming.lua`)

### Crop Balance (Harsh Economy)
```lua
farming.cropTypes = {
    carrot = {
        growTime = 60,      -- Seconds to grow
        waterNeeded = 3,    -- Water applications needed
        value = 4           -- Sell price
    }
}
```

**Profit calculation:**
- Carrot seeds: $10
- Carrot sell: $4 each
- Yield: 1-2 per harvest
- Net: $4-8 revenue - $10 cost = **Loss to $-2 profit**
- Need 3+ yield to profit (uncommon)

### Farming Functions Pattern
```lua
-- Plant: Returns (success, message)
local success, msg = farming.plantSeed(x, y, "carrot")
if success then
    playerEntity.removeItem("seeds", 1)
end

-- Water: Returns (success, message)
local success, msg = farming.waterCrop(x, y)

-- Harvest: Returns (cropType, yield, message)
local cropType, yield, message = farming.harvestCrop(x, y)
if cropType then
    playerEntity.addItem(cropType, yield)
end
```

**Farming plots:**
- 2x3 grid (6 plots total)
- Located at `(575, 335)` - matches world structure
- 32x32 plot size, 8px spacing
- 10px interaction buffer for easier clicking

---

## Console Output Standards

### Keep It Clean
Only print **important player feedback**. Remove debug spam.

**✅ GOOD:**
```lua
print("🌱 Planted carrot")
print("💰 Sold 3 carrots for $12")
```

**❌ BAD:**
```lua
print("DEBUG: Player at (123.45, 67.89)")
print("🔍 Trying to plant at (" .. x .. ", " .. y .. ")")
print("✓ Found plot #2 at (575, 335)")
```

### Emoji Usage
Use emojis for quick visual scanning:
- 🌱 Plant/farming
- 💧 Water
- 🌾 Harvest
- 💰 Money earned
- 💸 Money spent
- ❌ Error/failure
- ✓ Success (use sparingly)

---

## Common Pitfalls & Solutions

### ❌ Problem: "attempt to call field 'getStats' (a nil value)"
**Solution:** Use `playerEntity.getMoney()` instead of `playerEntity.getStats().money`

### ❌ Problem: "attempt to call field 'addNutrition' (a nil value)"
**Solution:** Nutrition system doesn't exist yet. Remove the call or implement it.

### ❌ Problem: Items not stacking in inventory
**Solution:** Make sure you're using `playerEntity.addItem()` which automatically stacks. Don't manipulate `inventory.items` directly.

### ❌ Problem: Money shows as `nil`
**Solution:** Use `playerEntity.getMoney()` which returns 0 if nil, instead of direct `inventory.money` access.

### ❌ Problem: Planting not working
**Solution:** Check player is within farm bounds (575, 335) with 10px buffer. Use farming.getPlotAt() to verify.

---

## Future Feature Guidelines

### Before Adding New Features:
1. **Document it first** - Add clear comments explaining what it does
2. **Use existing patterns** - Follow the addItem/removeItem pattern
3. **Balance carefully** - Maintain hunting > farming profitability
4. **Test with edge cases** - What if player has 0 money? 0 items?
5. **Clean output** - Only print user-relevant messages

### Commented-Out Code
Leave complex features commented out with `--[[` `--]]` blocks for future expansion:
```lua
--[[ FUTURE FEATURE - Nutrition System
player.nutrition = 100
function player.addNutrition(amount)
    player.nutrition = math.min(100, player.nutrition + amount)
end
--]]
```

---

## File Structure Quick Reference

```
entities/player.lua    - Player stats, inventory (consolidated system)
states/shop.lua        - Trading system (balanced pricing)
states/gameplay.lua    - Main game loop, interactions (clean output)
systems/farming.lua    - Crop growth, planting, harvest (harsh balance)
systems/world.lua      - Structures, collision detection
systems/areas.lua      - Area management, transitions
```

---

## Testing Checklist

Before committing changes:
- [ ] Game starts without crashes
- [ ] Shop opens with B key (not S)
- [ ] Can buy seeds ($10) and sell crops ($4)
- [ ] Planting removes 1 seed from inventory
- [ ] Watering increases water level (3 needed)
- [ ] Harvesting gives 1-2 crops and clears plot
- [ ] Money displays consistently with $ prefix
- [ ] No excessive debug output in console
- [ ] Inventory stacks items correctly

---

## Questions?
If you're unsure about a pattern, search the codebase for existing examples:
- Money operations: Check `shop.lua` lines 180-200
- Inventory: Check `player.lua` lines 80-140
- Farming: Check `farming.lua` lines 240-340
