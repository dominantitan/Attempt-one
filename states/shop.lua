-- Simple Shop State (MVP)
-- BALANCE PHILOSOPHY:
-- - Farming: Barely profitable (seeds $10-20, crops sell $4-10) - steady but slow income
-- - Hunting: 3-4x more profitable ($15-100 per kill) - risky but rewarding
-- - This encourages hunting while farming provides backup income

local shop = {}

-- Shop inventory (what player can buy) - ORGANIZED BY CATEGORY
shop.categories = {
    {
        name = "🌾 FARMING SUPPLIES",
        color = {0.5, 0.9, 0.3},
        items = {
            {name = "Carrot Seeds", type = "seeds", price = 10, sellPrice = 1, description = "Grows carrots in 10 min • Sells for $8 each"},
            {name = "Potato Seeds", type = "potato_seeds", price = 15, sellPrice = 2, description = "Grows potatoes in 12.5 min • Sells for $12 each"},
            {name = "Mushroom Spores", type = "mushroom_seeds", price = 20, sellPrice = 2, description = "Grows mushrooms in 15 min • Sells for $15 each"},
            {name = "Water Bucket", type = "water", price = 5, sellPrice = 0, description = "Waters crops (Get FREE at pond!)"},
        }
    },
    {
        name = "🏹 HUNTING GEAR",
        color = {1, 0.5, 0.3},
        items = {
            {name = "Arrows (10x)", type = "arrows", price = 15, sellPrice = 1, description = "Ammo for bow hunting"},
            {name = "Rifle", type = "rifle_weapon", price = 200, sellPrice = 50, description = "⭐ Powerful rifle • One-time purchase"},
            {name = "Rifle Bullets (10x)", type = "bullets", price = 25, sellPrice = 2, description = "Ammo for rifle"},
            {name = "Shotgun", type = "shotgun_weapon", price = 350, sellPrice = 80, description = "⭐ Spread shot • One-time purchase"},
            {name = "Shotgun Shells (10x)", type = "shells", price = 30, sellPrice = 2, description = "Ammo for shotgun"},
        }
    },
    {
        name = "🎣 FISHING EQUIPMENT",
        color = {0.4, 0.7, 1},
        items = {
            {name = "Fishing Net", type = "fishingNet", price = 50, sellPrice = 10, description = "⭐ Catch multiple fish! • One-time purchase"},
        }
    },
    {
        name = "🍞 CONSUMABLES",
        color = {1, 0.9, 0.5},
        items = {
            {name = "Bread", type = "bread", price = 6, sellPrice = 1, description = "Restores hunger"},
            {name = "Canned Beans", type = "beans", price = 10, sellPrice = 2, description = "Restores lots of hunger"},
        }
    }
}

-- Flatten items for backward compatibility
shop.items = {}
for _, category in ipairs(shop.categories) do
    for _, item in ipairs(category.items) do
        table.insert(shop.items, item)
    end
end

-- What shopkeeper buys from player (PRICE BALANCE IS CRITICAL!)
-- PROFIT MARGINS:
--   Farming: Buy seeds $10-20 → Sell crops $4-10 → Loss to small profit (needs water+time)
--   Foraging: Free to collect → Sell $5-10 → Pure profit (safe, good early income!)
--   Fishing: Free to catch → Sell $5-35 → Pure profit (skill-based income)
--   Hunting: Free to hunt → Sell meat $15-100 → Pure profit (risky but rewarding)
shop.buyPrices = {
    -- FORAGED GOODS (Best early-game income - safe, free, reliable!)
    berries = 6,      -- Common, good starter income
    herbs = 8,        -- Uncommon, medicinal value
    nuts = 5,         -- Rare but nutritious
    mushroom = 15,    -- Can be foraged OR farmed from spores
    
    -- CROPS (MEDIUM value - farming is viable but not as profitable as fishing/hunting)
    carrot = 8,      -- Seeds $10, sells $8 → Avg yield 3 = $24 → Net +$14 profit
    potato = 12,     -- Seeds $15, sells $12 → Avg yield 4 = $48 → Net +$33 profit
    
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

shop.selectedCategory = 1
shop.selectedItem = 1
shop.mode = "buy" -- "buy" or "sell"
shop.scrollOffset = 0 -- For scrolling through long lists

function shop:enter()
    print("💰 Entering Shop")
    print("📦 Buy seeds and supplies, sell your harvest!")
    shop.scrollOffset = 0 -- Reset scroll on entry
    shop.selectedCategory = 1
    shop.selectedItem = 1
end

function shop:update(dt)
    -- Handle shop interactions and transactions
end

function shop:draw()
    local playerEntity = require("entities/player")
    local lg = love.graphics
    
    -- ========== BACKGROUND ==========
    lg.setColor(0.05, 0.05, 0.08, 0.97)
    lg.rectangle("fill", 0, 0, 960, 600)
    
    -- ========== HEADER BAR ==========
    lg.setColor(0.1, 0.15, 0.2, 1)
    lg.rectangle("fill", 0, 0, 960, 80)
    
    -- Title with shadow effect
    lg.setColor(0, 0, 0, 0.5)
    lg.print("💰 GENERAL STORE", 22, 17, 0, 2, 2)
    lg.setColor(1, 0.95, 0.6)
    lg.print("💰 GENERAL STORE", 20, 15, 0, 2, 2)
    
    lg.setColor(0.7, 0.7, 0.7)
    lg.print("Buy supplies and sell your harvest", 20, 52)
    
    -- Player money display (top right)
    lg.setColor(0.15, 0.2, 0.25, 1)
    lg.rectangle("fill", 720, 15, 220, 50)
    lg.setColor(0.3, 0.4, 0.5, 1)
    lg.rectangle("line", 720, 15, 220, 50)
    lg.setColor(1, 0.85, 0.2)
    lg.print("Your Money:", 735, 22, 0, 1.2, 1.2)
    lg.setColor(0.2, 1, 0.3)
    lg.print("$" .. playerEntity.getMoney(), 735, 40, 0, 1.5, 1.5)
    
    -- ========== MODE TABS ==========
    local tabY = 90
    local tabWidth = 150
    
    -- Buy Tab
    local buyTabColor = shop.mode == "buy" and {0.2, 0.6, 0.3} or {0.2, 0.25, 0.3}
    lg.setColor(buyTabColor[1], buyTabColor[2], buyTabColor[3])
    lg.rectangle("fill", 20, tabY, tabWidth, 40)
    lg.setColor(shop.mode == "buy" and 1 or 0.5, shop.mode == "buy" and 1 or 0.5, shop.mode == "buy" and 1 or 0.5)
    lg.print("[B] BUY", 60, tabY + 10, 0, 1.3, 1.3)
    
    -- Sell Tab
    local sellTabColor = shop.mode == "sell" and {0.6, 0.4, 0.2} or {0.2, 0.25, 0.3}
    lg.setColor(sellTabColor[1], sellTabColor[2], sellTabColor[3])
    lg.rectangle("fill", 180, tabY, tabWidth, 40)
    lg.setColor(shop.mode == "sell" and 1 or 0.5, shop.mode == "sell" and 1 or 0.5, shop.mode == "sell" and 1 or 0.5)
    lg.print("[V] SELL", 215, tabY + 10, 0, 1.3, 1.3)
    
    -- ========== MAIN CONTENT AREA ==========
    if shop.mode == "buy" then
        shop:drawBuyMode(lg, playerEntity)
    else
        shop:drawSellMode(lg, playerEntity)
    end
    
    -- ========== FOOTER BAR ==========
    lg.setColor(0.1, 0.15, 0.2, 1)
    lg.rectangle("fill", 0, 550, 960, 50)
    lg.setColor(0.9, 0.9, 0.9)
    
    if shop.mode == "buy" then
        lg.print("🎮 [A/D] Switch Category  |  [W/S] Select Item  |  [E/ENTER] Buy  |  [ESC] Exit", 20, 563)
    else
        lg.print("🎮 [1-9] Sell Item  |  [L] Liquidate All  |  [ESC] Exit", 20, 563)
    end
    
    lg.setColor(1, 1, 1)
end

-- ========== BUY MODE UI ==========
function shop:drawBuyMode(lg, playerEntity)
    local contentY = 145
    
    -- Category Navigation Bar
    lg.setColor(0.15, 0.2, 0.25, 0.8)
    lg.rectangle("fill", 20, contentY, 920, 50)
    
    local catX = 30
    for i, category in ipairs(shop.categories) do
        local isSelected = (i == shop.selectedCategory)
        
        -- Category button background
        if isSelected then
            lg.setColor(category.color[1], category.color[2], category.color[3], 0.3)
            lg.rectangle("fill", catX - 5, contentY + 5, 200, 40, 8, 8)
        end
        
        -- Category text
        local textColor = isSelected and 1 or 0.5
        lg.setColor(category.color[1] * textColor, category.color[2] * textColor, category.color[3] * textColor)
        lg.print(category.name, catX, contentY + 12, 0, 1.1, 1.1)
        
        catX = catX + 230
    end
    
    -- Items in selected category
    local itemsY = contentY + 70
    local currentCategory = shop.categories[shop.selectedCategory]
    
    lg.setColor(currentCategory.color[1], currentCategory.color[2], currentCategory.color[3])
    lg.print("▼ " .. currentCategory.name, 40, itemsY, 0, 1.3, 1.3)
    
    itemsY = itemsY + 35
    
    -- Calculate global item index offset
    local globalOffset = 0
    for i = 1, shop.selectedCategory - 1 do
        globalOffset = globalOffset + #shop.categories[i].items
    end
    
    -- Draw items
    for i, item in ipairs(currentCategory.items) do
        local globalIndex = globalOffset + i
        local isSelected = (globalIndex == shop.selectedItem)
        local y = itemsY + (i - 1) * 65
        
        -- Item card background
        if isSelected then
            lg.setColor(0.25, 0.35, 0.45, 0.9)
            lg.rectangle("fill", 40, y - 5, 880, 60, 5, 5)
            lg.setColor(currentCategory.color[1], currentCategory.color[2], currentCategory.color[3], 0.8)
            lg.rectangle("line", 40, y - 5, 880, 60, 5, 5)
            lg.setLineWidth(3)
            lg.rectangle("line", 40, y - 5, 880, 60, 5, 5)
            lg.setLineWidth(1)
        else
            lg.setColor(0.15, 0.2, 0.25, 0.6)
            lg.rectangle("fill", 40, y - 5, 880, 60, 5, 5)
        end
        
        -- Item name
        local nameColor = isSelected and 1 or 0.8
        lg.setColor(nameColor, nameColor, nameColor)
        lg.print(item.name, 60, y + 5, 0, 1.2, 1.2)
        
        -- Item description
        lg.setColor(0.6, 0.6, 0.6)
        lg.print(item.description, 60, y + 28)
        
        -- Price tag
        local canAfford = playerEntity.getMoney() >= item.price
        local priceX = 820
        
        if canAfford then
            lg.setColor(0.2, 0.8, 0.3, 0.8)
            lg.rectangle("fill", priceX - 10, y, 100, 35, 5, 5)
            lg.setColor(1, 1, 1)
            lg.print("$" .. item.price, priceX, y + 8, 0, 1.3, 1.3)
        else
            lg.setColor(0.8, 0.2, 0.2, 0.8)
            lg.rectangle("fill", priceX - 10, y, 100, 35, 5, 5)
            lg.setColor(1, 1, 1)
            lg.print("$" .. item.price, priceX, y + 3, 0, 1.2, 1.2)
            lg.setColor(1, 0.4, 0.4)
            lg.print("TOO PRICEY", priceX + 10, y + 20, 0, 0.7, 0.7)
        end
    end
end

-- ========== SELL MODE UI ==========
function shop:drawSellMode(lg, playerEntity)
    local contentY = 145
    
    lg.setColor(1, 0.95, 0.7)
    lg.print("YOUR INVENTORY - Choose items to sell:", 40, contentY, 0, 1.4, 1.4)
    
    local y = contentY + 40
    local itemIndex = 1
    shop.sellableItems = {} -- Track what can be sold
    
    -- ORGANIZE BY CATEGORY for better readability
    local sellCategories = {
        {name = "🌿 FORAGED GOODS", icon = "🌿", items = {"berries", "herbs", "nuts", "mushroom"}, color = {0.4, 0.9, 0.5}},
        {name = "🌾 CROPS", icon = "🌾", items = {"carrot", "potato"}, color = {0.9, 0.8, 0.3}},
        {name = "🐟 FISH & AQUATIC", icon = "🐟", items = {"small_fish", "bass", "catfish", "rare_trout", "snake_skin"}, color = {0.4, 0.7, 1}},
        {name = "🥩 HUNTING GOODS", icon = "🥩", items = {"rabbit_meat", "deer_meat", "boar_meat", "tiger_meat"}, color = {1, 0.5, 0.3}}
    }
    
    local hasAnyItems = false
    
    for _, category in ipairs(sellCategories) do
        local categoryHasItems = false
        
        -- Check if category has any items first
        for _, itemType in ipairs(category.items) do
            local count = playerEntity.getItemCount(itemType) or 0
            if count > 0 then
                categoryHasItems = true
                break
            end
        end
        
        -- Draw category header if it has items
        if categoryHasItems then
            lg.setColor(0.2, 0.25, 0.3, 0.9)
            lg.rectangle("fill", 30, y, 900, 30, 5, 5)
            lg.setColor(category.color[1], category.color[2], category.color[3])
            lg.print(category.name, 45, y + 6, 0, 1.3, 1.3)
            y = y + 40
            hasAnyItems = true
            
            -- Draw items in this category
            for _, itemType in ipairs(category.items) do
                local count = playerEntity.getItemCount(itemType) or 0
                if count > 0 then
                    local price = shop.buyPrices[itemType]
                    
                    -- Item card
                    lg.setColor(0.15, 0.2, 0.25, 0.7)
                    lg.rectangle("fill", 50, y, 860, 40, 5, 5)
                    
                    -- Hotkey badge
                    lg.setColor(0.3, 0.5, 0.7, 1)
                    lg.rectangle("fill", 60, y + 5, 30, 30, 5, 5)
                    lg.setColor(1, 1, 1)
                    lg.print(tostring(itemIndex), 70, y + 10, 0, 1.2, 1.2)
                    
                    -- Item name and quantity
                    lg.setColor(0.2, 1, 0.4)
                    lg.print(string.format("%s", itemType), 110, y + 5, 0, 1.2, 1.2)
                    lg.setColor(0.9, 0.9, 0.9)
                    lg.print(string.format("x%d", count), 110, y + 20, 0, 0.9, 0.9)
                    
                    -- Price per unit
                    lg.setColor(1, 0.9, 0.5)
                    lg.print(string.format("$%d each", price), 400, y + 12, 0, 1.1, 1.1)
                    
                    -- Total value
                    local totalValue = price * count
                    lg.setColor(0.2, 0.8, 0.3, 0.9)
                    lg.rectangle("fill", 750, y + 5, 140, 30, 5, 5)
                    lg.setColor(1, 1, 1)
                    lg.print(string.format("= $%d", totalValue), 765, y + 10, 0, 1.2, 1.2)
                    
                    shop.sellableItems[itemIndex] = {type = itemType, count = count, price = price}
                    itemIndex = itemIndex + 1
                    y = y + 48
                end
            end
            
            y = y + 5 -- Spacing between categories
        end
    end
    
    if not hasAnyItems then
        lg.setColor(0.15, 0.2, 0.25, 0.8)
        lg.rectangle("fill", 200, 280, 560, 80, 10, 10)
        lg.setColor(0.6, 0.6, 0.6)
        lg.print("📦 Your inventory is empty!", 260, 295, 0, 1.5, 1.5)
        lg.setColor(0.5, 0.5, 0.5)
        lg.print("Go forage, farm, fish, or hunt to gather sellable items!", 230, 325)
    else
        -- Liquidate button
        lg.setColor(0.7, 0.3, 0.1, 0.9)
        lg.rectangle("fill", 350, y + 10, 260, 45, 8, 8)
        lg.setColor(1, 0.8, 0.2, 1)
        lg.rectangle("line", 350, y + 10, 260, 45, 8, 8)
        lg.setLineWidth(2)
        lg.rectangle("line", 350, y + 10, 260, 45, 8, 8)
        lg.setLineWidth(1)
        lg.setColor(1, 1, 1)
        lg.print("🔥 [L] LIQUIDATE ALL 🔥", 370, y + 20, 0, 1.2, 1.2)
    end
end

function shop:keypressed(key)
    local playerEntity = require("entities/player")
    
    if key == "escape" then
        -- Return to gameplay
        local gamestate = require("states/gamestate")
        gamestate.switch("gameplay")
        
    elseif key == "b" then
        shop.mode = "buy"
        shop.selectedCategory = 1
        shop.selectedItem = 1
        
    elseif key == "v" then
        shop.mode = "sell"
        
    elseif shop.mode == "buy" then
        -- WASD CONTROLS for buy mode
        if key == "a" then
            -- Switch to previous category
            shop.selectedCategory = math.max(1, shop.selectedCategory - 1)
            -- Update selected item to first item in new category
            local offset = 0
            for i = 1, shop.selectedCategory - 1 do
                offset = offset + #shop.categories[i].items
            end
            shop.selectedItem = offset + 1
            
        elseif key == "d" then
            -- Switch to next category
            shop.selectedCategory = math.min(#shop.categories, shop.selectedCategory + 1)
            -- Update selected item to first item in new category
            local offset = 0
            for i = 1, shop.selectedCategory - 1 do
                offset = offset + #shop.categories[i].items
            end
            shop.selectedItem = offset + 1
            
        elseif key == "w" then
            -- Move up in current category (NO WRAPPING TO OTHER CATEGORIES)
            local offset = 0
            for i = 1, shop.selectedCategory - 1 do
                offset = offset + #shop.categories[i].items
            end
            local minItem = offset + 1
            
            if shop.selectedItem > minItem then
                shop.selectedItem = shop.selectedItem - 1
            end
            
        elseif key == "s" then
            -- Move down in current category (NO WRAPPING TO OTHER CATEGORIES)
            local offset = 0
            for i = 1, shop.selectedCategory - 1 do
                offset = offset + #shop.categories[i].items
            end
            local maxItem = offset + #shop.categories[shop.selectedCategory].items
            
            if shop.selectedItem < maxItem then
                shop.selectedItem = shop.selectedItem + 1
            end
            
        elseif key == "return" or key == "space" or key == "e" then
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
    
    if not item then
        print("❌ ERROR: No item at index " .. shop.selectedItem)
        return
    end
    
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