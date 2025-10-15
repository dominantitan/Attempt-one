-- Shopkeeper Entity
-- Manages the shopkeeper NPC, shop inventory, and trading system

local shopkeeper = {}

-- Shopkeeper properties
shopkeeper.x = 600
shopkeeper.y = 200
shopkeeper.width = 32
shopkeeper.height = 48
shopkeeper.name = "Old Merchant"
shopkeeper.dialogue = {
    greeting = "Welcome to my shop, traveler. What can I do for you?",
    noMoney = "You don't have enough coins for that.",
    thanks = "Thank you for your business!",
    goodbye = "Safe travels, and come back soon!"
}

-- Shop inventory
shopkeeper.inventory = {
    -- Seeds for farming
    {item = "carrot_seed", price = 3, stock = 20, category = "seeds"},
    {item = "potato_seed", price = 5, stock = 15, category = "seeds"},
    {item = "mushroom_spore", price = 8, stock = 10, category = "seeds"},
    {item = "berry_seed", price = 4, stock = 12, category = "seeds"},
    
    -- Tools
    {item = "watering_can", price = 25, stock = 5, category = "tools"},
    {item = "fishing_rod", price = 35, stock = 3, category = "tools"},
    {item = "hunting_knife", price = 40, stock = 2, category = "tools"},
    
    -- Food
    {item = "bread", price = 8, stock = 30, category = "food"},
    {item = "cheese", price = 12, stock = 20, category = "food"},
    {item = "dried_meat", price = 15, stock = 15, category = "food"},
    
    -- Supplies
    {item = "lantern", price = 50, stock = 8, category = "supplies"},
    {item = "rope", price = 10, stock = 25, category = "supplies"},
    {item = "bandage", price = 6, stock = 40, category = "supplies"}
}

-- Purchase prices (what shopkeeper pays for items)
shopkeeper.buyPrices = {
    carrot = 3,
    potato = 5,
    mushroom = 8,
    berry = 2,
    rabbit_meat = 8,
    deer_meat = 20,
    boar_meat = 35,
    fish = 6
}

function shopkeeper.load()
    -- Initialize shopkeeper
end

function shopkeeper.update(dt)
    -- Update shopkeeper behavior (could add walking animations, etc.)
end

function shopkeeper.draw()
    -- Draw shopkeeper
    love.graphics.setColor(0.8, 0.6, 0.4) -- Tan skin
    love.graphics.rectangle("fill", shopkeeper.x, shopkeeper.y, shopkeeper.width, shopkeeper.height)
    
    -- Draw simple clothing
    love.graphics.setColor(0.3, 0.2, 0.1) -- Brown clothes
    love.graphics.rectangle("fill", shopkeeper.x + 4, shopkeeper.y + 16, 24, 32)
    
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function shopkeeper.isNearby(playerX, playerY)
    local distance = math.sqrt((shopkeeper.x - playerX)^2 + (shopkeeper.y - playerY)^2)
    return distance < 80
end

function shopkeeper.getShopItems(category)
    local items = {}
    
    if category then
        for _, item in ipairs(shopkeeper.inventory) do
            if item.category == category then
                table.insert(items, item)
            end
        end
    else
        return shopkeeper.inventory
    end
    
    return items
end

function shopkeeper.buyItem(itemName, quantity, playerMoney)
    quantity = quantity or 1
    
    for _, item in ipairs(shopkeeper.inventory) do
        if item.item == itemName then
            local totalCost = item.price * quantity
            
            if playerMoney >= totalCost and item.stock >= quantity then
                item.stock = item.stock - quantity
                return true, totalCost
            else
                return false, totalCost
            end
        end
    end
    
    return false, 0
end

function shopkeeper.sellItem(itemName, quantity)
    quantity = quantity or 1
    local price = shopkeeper.buyPrices[itemName]
    
    if price then
        local totalValue = price * quantity
        return true, totalValue
    end
    
    return false, 0
end

function shopkeeper.restockShop()
    -- Restock shop items (could be called daily)
    for _, item in ipairs(shopkeeper.inventory) do
        local restockAmount = math.random(1, 5)
        item.stock = math.min(item.stock + restockAmount, 99)
    end
end

function shopkeeper.getDialogue(context)
    if context == "greeting" then
        return shopkeeper.dialogue.greeting
    elseif context == "noMoney" then
        return shopkeeper.dialogue.noMoney
    elseif context == "thanks" then
        return shopkeeper.dialogue.thanks
    elseif context == "goodbye" then
        return shopkeeper.dialogue.goodbye
    else
        return shopkeeper.dialogue.greeting
    end
end

function shopkeeper.getPosition()
    return shopkeeper.x, shopkeeper.y
end

function shopkeeper.setPosition(x, y)
    shopkeeper.x = x
    shopkeeper.y = y
end

return shopkeeper