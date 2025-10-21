-- Simple Shop State (MVP)
-- BALANCE PHILOSOPHY:
-- - Farming: Barely profitable (seeds $10-20, crops sell $4-10) - steady but slow income
-- - Hunting: 3-4x more profitable ($15-100 per kill) - risky but rewarding
-- - This encourages hunting while farming provides backup income

local shop = {}

-- Shop inventory (what player can buy)
shop.items = {
    -- Seeds (EXPENSIVE - makes farming an investment, not guaranteed profit)
    {name = "Carrot Seeds", type = "seeds", price = 10, sellPrice = 1, description = "Grows carrots in 60s (slow!)"},
    {name = "Potato Seeds", type = "potato_seeds", price = 15, sellPrice = 2, description = "Grows potatoes in 90s (slow!)"},
    {name = "Mushroom Spores", type = "mushroom_seeds", price = 20, sellPrice = 2, description = "Grows mushrooms in 120s (slow!)"},
    
    -- Water (encourages free collection at pond instead of buying)
    {name = "Water Bucket", type = "water", price = 5, sellPrice = 0, description = "Waters crops (get free at pond!)"},
    
    -- Food (for emergencies when player is desperate)
    {name = "Bread", type = "bread", price = 6, sellPrice = 1, description = "Restores hunger"},
    {name = "Canned Beans", type = "beans", price = 10, sellPrice = 2, description = "Restores hunger and health"},
    
    -- HUNTING EQUIPMENT (New!)
    {name = "Arrows (10x)", type = "arrows", price = 15, sellPrice = 1, description = "Ammo for bow"},
    {name = "Rifle", type = "rifle_weapon", price = 200, sellPrice = 50, description = "Powerful hunting rifle (one-time purchase)"},
    {name = "Rifle Bullets (10x)", type = "bullets", price = 25, sellPrice = 2, description = "Ammo for rifle"},
    {name = "Shotgun", type = "shotgun_weapon", price = 350, sellPrice = 80, description = "Spread shot hunter (one-time purchase)"},
    {name = "Shotgun Shells (10x)", type = "shells", price = 30, sellPrice = 2, description = "Ammo for shotgun"},
    
    -- FISHING EQUIPMENT
    {name = "Fishing Net", type = "fishingNet", price = 50, sellPrice = 10, description = "Catch multiple fish at once! (one-time purchase)"},
    
    --[[ FUTURE FEATURES - COMMENTED OUT FOR MVP
    {name = "Soil Fertilizer", type = "fertilizer", price = 30, sellPrice = 3, description = "Improves soil quality"},
    {name = "Pesticide", type = "pesticide", price = 35, sellPrice = 4, description = "Reduces pest damage"},
    {name = "Basic Hoe", type = "hoe", price = 50, sellPrice = 10, description = "Improves farming efficiency"},
    {name = "Watering Can", type = "watering_can", price = 40, sellPrice = 8, description = "Waters multiple crops"},
    --]]
}

-- What shopkeeper buys from player (PRICE BALANCE IS CRITICAL!)
-- PROFIT MARGINS:
--   Farming: Buy seeds $10-20 → Sell crops $4-10 → Loss to small profit (needs water+time)
--   Hunting: Free to hunt → Sell meat $15-100 → Pure profit (but risky)
--   Foraging: Free to collect → Sell $5-8 → Pure profit (safe but low yield)
shop.buyPrices = {
    -- CROPS (LOW value - farming is a grind, not a goldmine)
    carrot = 4,      -- Seeds $10, sells $4 → Need 3+ yield to profit
    potato = 7,      -- Seeds $15, sells $7 → Need 3+ yield to profit
    mushroom = 10,   -- Seeds $20, sells $10 → Need 3+ yield to profit
    
    -- FORAGE (MEDIUM value - safe income for exploring)
    berries = 6,
    herbs = 8,
    nuts = 5,
    
    -- FISHING (MEDIUM-HIGH value - skill-based income!)
    small_fish = 5,
    bass = 12,
    catfish = 20,
    rare_trout = 35,
    snake_skin = 15,
    
    -- HUNTING (HIGH value - risk = reward!)
    rabbit_meat = 15,    -- Low risk, decent reward
    deer_meat = 30,      -- Medium risk, good reward
    boar_meat = 50,      -- High risk, great reward
    tiger_meat = 100     -- Extreme risk, huge reward
    
    --[[ HARDCORE MODE - COMMENTED OUT
    carrot = 2,    -- Sell for 2, but seeds cost 15 - loss!
    potato = 4,    -- Sell for 4, but seeds cost 25 - loss!
    mushroom = 6,  -- Sell for 6, but spores cost 40 - loss!
    --]]
}

shop.selectedItem = 1
shop.mode = "buy" -- "buy" or "sell"
shop.scrollOffset = 0 -- For scrolling through long lists

function shop:enter()
    print("💰 Entering Shop")
    print("📦 Buy seeds and supplies, sell your harvest!")
    shop.scrollOffset = 0 -- Reset scroll on entry
end

function shop:update(dt)
    -- Handle shop interactions and transactions
end

function shop:draw()
    local playerEntity = require("entities/player")
    
    -- Draw simple shop interface
    local lg = love.graphics
    lg.setColor(0.1, 0.1, 0.1, 0.95) -- Dark background
    lg.rectangle("fill", 50, 50, 860, 440)
    
    -- Title
    lg.setColor(0.8, 1, 0.8)
    lg.print("💰 GENERAL STORE 💰", 60, 70, 0, 1.5, 1.5)
    lg.setColor(0.8, 0.8, 0.8)
    lg.print("Buy supplies and sell your harvest", 60, 100)
    
    -- Player money (consistent $ formatting)
    lg.setColor(1, 1, 0.5)
    lg.print("Your Money: $" .. playerEntity.getMoney(), 60, 130)
    
    -- Mode tabs
    lg.setColor(shop.mode == "buy" and 0.8 or 0.4, shop.mode == "buy" and 1 or 0.4, shop.mode == "buy" and 0.8 or 0.4)
    lg.print("[B] BUY", 60, 160)
    lg.setColor(shop.mode == "sell" and 0.8 or 0.4, shop.mode == "sell" and 1 or 0.4, shop.mode == "sell" and 0.8 or 0.4)
    lg.print("[V] SELL", 150, 160)
    
    if shop.mode == "buy" then
        -- Show items for sale
        lg.setColor(1, 1, 1)
        lg.print("Items for Sale (Use UP/DOWN, ENTER to buy):", 60, 190)
        
        -- Scrolling viewport: show max 8 items at a time
        local maxVisibleItems = 8
        local startIndex = shop.scrollOffset + 1
        local endIndex = math.min(startIndex + maxVisibleItems - 1, #shop.items)
        
        for i = startIndex, endIndex do
            local item = shop.items[i]
            local y = 220 + (i - startIndex) * 25
            local color = i == shop.selectedItem and {1, 1, 0.5} or {0.8, 0.8, 0.8}
            lg.setColor(color[1], color[2], color[3])
            
            local canAfford = playerEntity.getMoney() >= item.price
            local affordText = canAfford and "" or " (TOO EXPENSIVE!)"
            
            lg.print(string.format("%s - $%d%s", item.name, item.price, affordText), 80, y)
            lg.setColor(0.6, 0.6, 0.6)
            lg.print(item.description, 300, y)
        end
        
        -- Scroll indicators
        if shop.scrollOffset > 0 then
            lg.setColor(1, 1, 0.5)
            lg.print("▲ More items above", 80, 420)
        end
        if endIndex < #shop.items then
            lg.setColor(1, 1, 0.5)
            lg.print("▼ More items below", 300, 420)
        end
        
    else -- sell mode
        lg.setColor(1, 1, 0.8)
        lg.print("YOUR ITEMS - Press number to sell:", 60, 190)
        
        local y = 220
        local itemIndex = 1
        shop.sellableItems = {} -- Track what can be sold
        
        for itemType, price in pairs(shop.buyPrices) do
            local count = playerEntity.getItemCount(itemType) or 0
            if count > 0 then
                lg.setColor(0.2, 1, 0.3)
                lg.print(string.format("[%d] %s x%d", itemIndex, itemType, count), 80, y)
                lg.setColor(1, 1, 0.5)
                lg.print(string.format("→ $%d each ($%d total)", price, price * count), 320, y)
                shop.sellableItems[itemIndex] = {type = itemType, count = count, price = price}
                itemIndex = itemIndex + 1
                y = y + 25
            end
        end
        
        if y == 220 then
            lg.setColor(0.6, 0.6, 0.6)
            lg.print("No items to sell - go farm or hunt!", 80, y)
        else
            lg.setColor(1, 0.8, 0.2)
            lg.print("[L] Liquidate (Sell ALL items at once)", 80, y + 20)
        end
    end
    
    -- Instructions
    lg.setColor(1, 1, 1)
    lg.rectangle("fill", 50, 440, 860, 40)
    lg.setColor(0.1, 0.1, 0.1)
    lg.print("BUY: [UP]/[DOWN] select, [ENTER] buy  |  SELL: Press [1-9] or [A]ll  |  [ESC] exit", 60, 455)
    
    lg.setColor(1, 1, 1) -- Reset color
end

function shop:keypressed(key)
    local playerEntity = require("entities/player")
    
    if key == "escape" then
        -- Return to gameplay
        local gamestate = require("states/gamestate")
        gamestate.switch("gameplay")
        
    elseif key == "b" then
        shop.mode = "buy"
        shop.selectedItem = 1
        
    elseif key == "v" then
        shop.mode = "sell"
        
    elseif shop.mode == "buy" then
        if key == "up" then
            shop.selectedItem = math.max(1, shop.selectedItem - 1)
            -- Auto-scroll when selection goes above visible area
            if shop.selectedItem <= shop.scrollOffset then
                shop.scrollOffset = math.max(0, shop.selectedItem - 1)
            end
        elseif key == "down" then
            shop.selectedItem = math.min(#shop.items, shop.selectedItem + 1)
            -- Auto-scroll when selection goes below visible area
            local maxVisibleItems = 8
            if shop.selectedItem > shop.scrollOffset + maxVisibleItems then
                shop.scrollOffset = shop.selectedItem - maxVisibleItems
            end
        elseif key == "return" or key == "space" then
            shop:buyItem()
        end
        
    elseif shop.mode == "sell" then
        -- Selling - press number keys 1-9
        local num = tonumber(key)
        if num and shop.sellableItems and shop.sellableItems[num] then
            local item = shop.sellableItems[num]
            shop:sellItem(item.type)
        elseif key == "l" then
            -- Sell all items (L for "Liquidate")
            shop:sellAllItems()
        end
    end
end

function shop:buyItem()
    local playerEntity = require("entities/player")
    local item = shop.items[shop.selectedItem]
    local money = playerEntity.getMoney()
    
    if money >= item.price then
        playerEntity.removeMoney(item.price)
        playerEntity.addItem(item.type, 1)
        print("💸 Bought " .. item.name .. " for $" .. item.price)
        print("💰 Money left: $" .. playerEntity.getMoney())
    else
        print("❌ Cannot afford " .. item.name .. " (need $" .. item.price .. ")")
    end
end

function shop:sellItem(itemType)
    local playerEntity = require("entities/player")
    local count = playerEntity.getItemCount(itemType) or 0
    
    if count > 0 then
        local price = shop.buyPrices[itemType]
        local totalEarned = price * count
        playerEntity.removeItem(itemType, count)
        playerEntity.addMoney(totalEarned)
        print("💰 Sold " .. count .. "x " .. itemType .. " for $" .. totalEarned)
        print("💵 Your money: $" .. playerEntity.getMoney())
    else
        print("❌ You don't have any " .. itemType)
    end
end

function shop:sellAllItems()
    local playerEntity = require("entities/player")
    local totalEarned = 0
    local itemsSold = 0
    
    print("💰 SELLING ALL ITEMS...")
    for itemType, price in pairs(shop.buyPrices) do
        local count = playerEntity.getItemCount(itemType) or 0
        if count > 0 then
            local earned = price * count
            playerEntity.removeItem(itemType, count)
            playerEntity.addMoney(earned)
            totalEarned = totalEarned + earned
            itemsSold = itemsSold + count
            print("  ✓ " .. count .. "x " .. itemType .. " = $" .. earned)
        end
    end
    
    if itemsSold > 0 then
        print("💵 SOLD " .. itemsSold .. " items for $" .. totalEarned)
        print("💰 Your money: $" .. playerEntity.getMoney())
    else
        print("❌ No items to sell!")
    end
end

function shop:exit()
    -- Cleanup shop state
end

return shop