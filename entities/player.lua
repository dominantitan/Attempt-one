-- Player Entity
-- Defines the player character's properties and behaviors

local player = {}

-- Player stats
player.health = 100
player.maxHealth = 100
player.stamina = 100
player.maxStamina = 100
player.hunger = 100
player.maxHunger = 100

-- Inventory (CONSOLIDATED SYSTEM - all items use items array)
-- Money is stored separately as it's not a stackable item
player.inventory = {
    items = {},  -- Array of {type = "string", quantity = number}
    maxSlots = 20,
    money = 0    -- Stored separately
}

-- Player state
player.isDead = false
player.isHungry = false
player.isTired = false

function player.load()
    -- Initialize player entity
    player.resetStats()
    
    -- Give player LIMITED starting items (forces hunting/foraging early)
    player.addItem("seeds", 3)  -- Only 3 seeds (was 10) - can't rely on farming alone!
    player.addItem("water", 2)  -- Only 2 water (was 5) - must get from pond!
    player.addItem("arrows", 10) -- Starting bow arrows for hunting
    player.inventory.money = 30 -- Less starting money (was 50) - harder start
    --[[ HARDCORE MODE: player.inventory.money = 20 -- Very small starting amount --]]
    
    -- Player starts with ONLY the bow (weapons are one-time purchases)
    player.addItem("bow_weapon", 1) -- Everyone starts with a bow
    
    print("🎒 Starting with bow, 10 arrows, 3 seeds, 2 water, and $30")
    print("⚠️  Limited resources - buy ammo to hunt, or guns for better hunting!")
end

function player.update(dt)
    -- Update player stats over time
    player.hunger = player.hunger - (dt * 2) -- Hunger decreases slowly
    player.stamina = math.min(player.maxStamina, player.stamina + (dt * 5)) -- Stamina regenerates
    
    -- Check status conditions
    player.isHungry = player.hunger < 30
    player.isTired = player.stamina < 20
    player.isDead = player.health <= 0
    
    -- Clamp values
    player.health = math.max(0, math.min(player.maxHealth, player.health))
    player.hunger = math.max(0, math.min(player.maxHunger, player.hunger))
    player.stamina = math.max(0, math.min(player.maxStamina, player.stamina))
end

function player.takeDamage(amount)
    player.health = player.health - amount
    if player.health <= 0 then
        player.isDead = true
    end
end

function player.heal(amount)
    player.health = math.min(player.maxHealth, player.health + amount)
end

function player.eat(nutritionValue)
    player.hunger = math.min(player.maxHunger, player.hunger + nutritionValue)
end

function player.rest(restAmount)
    player.stamina = math.min(player.maxStamina, player.stamina + restAmount)
end

function player.addItem(itemType, quantity)
    -- Add item to inventory (consolidated system)
    quantity = quantity or 1
    
    -- Check if item already exists in inventory
    for i, item in ipairs(player.inventory.items) do
        if item.type == itemType then
            item.quantity = item.quantity + quantity
            return true
        end
    end
    
    -- Item doesn't exist, add new entry
    if #player.inventory.items < player.inventory.maxSlots then
        table.insert(player.inventory.items, {type = itemType, quantity = quantity})
        return true
    end
    
    return false -- Inventory full
end

function player.removeItem(itemType, quantity)
    -- Remove item from inventory
    quantity = quantity or 1
    
    for i, item in ipairs(player.inventory.items) do
        if item.type == itemType then
            if item.quantity > quantity then
                item.quantity = item.quantity - quantity
                return true
            elseif item.quantity == quantity then
                table.remove(player.inventory.items, i)
                return true
            end
        end
    end
    
    return false -- Item not found or insufficient quantity
end

function player.hasItem(itemType, quantity)
    quantity = quantity or 1
    
    for i, item in ipairs(player.inventory.items) do
        if item.type == itemType and item.quantity >= quantity then
            return true
        end
    end
    
    return false
end

function player.getItemCount(itemType)
    for i, item in ipairs(player.inventory.items) do
        if item.type == itemType then
            return item.quantity
        end
    end
    return 0
end

function player.addMoney(amount)
    player.inventory.money = (player.inventory.money or 0) + amount
end

function player.removeMoney(amount)
    if (player.inventory.money or 0) >= amount then
        player.inventory.money = player.inventory.money - amount
        return true
    end
    return false
end

function player.resetStats()
    player.health = player.maxHealth
    player.stamina = player.maxStamina
    player.hunger = player.maxHunger
    player.isDead = false
end

function player.getStatusText()
    local status = {}
    
    if player.isHungry then
        table.insert(status, "Hungry")
    end
    
    if player.isTired then
        table.insert(status, "Tired")
    end
    
    if player.isDead then
        table.insert(status, "Dead")
    end
    
    return table.concat(status, ", ")
end

-- API Getters (for consistent access patterns)
-- Direct property access is fine too: player.health, player.inventory.money
function player.getMoney()
    return player.inventory.money or 0
end

function player.getHealth()
    return player.health
end

function player.getHunger()
    return player.hunger
end

function player.getStamina()
    return player.stamina
end

return player