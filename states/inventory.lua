-- Inventory State
-- Clean 3x3 grid display of player items

local inventory = {}

-- Grid configuration
inventory.gridSize = 3 -- 3x3 grid
inventory.cellSize = 80 -- Size of each cell
inventory.cellPadding = 10 -- Space between cells
inventory.startX = 300 -- Starting X position (centered)
inventory.startY = 100 -- Starting Y position

function inventory:enter()
    print("📦 Opening inventory")
end

function inventory:update(dt)
    -- Inventory is just display, no real-time updates needed
end

function inventory:draw()
    local lg = love.graphics
    local playerEntity = require("entities/player")
    
    -- Dark semi-transparent background
    lg.setColor(0, 0, 0, 0.85)
    lg.rectangle("fill", 0, 0, 960, 540)
    
    -- Title
    lg.setColor(1, 1, 0.8)
    lg.print("INVENTORY", 420, 40, 0, 2, 2)
    
    -- Player money
    lg.setColor(1, 1, 0.5)
    lg.print("💰 Money: $" .. playerEntity.getMoney(), 400, 80)
    
    -- Draw 3x3 grid
    local cellTotal = inventory.gridSize * inventory.gridSize
    local itemIndex = 1
    
    for row = 0, inventory.gridSize - 1 do
        for col = 0, inventory.gridSize - 1 do
            local x = inventory.startX + col * (inventory.cellSize + inventory.cellPadding)
            local y = inventory.startY + row * (inventory.cellSize + inventory.cellPadding)
            
            -- Draw cell background
            lg.setColor(0.2, 0.2, 0.25)
            lg.rectangle("fill", x, y, inventory.cellSize, inventory.cellSize)
            
            -- Draw cell border
            lg.setColor(0.4, 0.4, 0.5)
            lg.setLineWidth(2)
            lg.rectangle("line", x, y, inventory.cellSize, inventory.cellSize)
            lg.setLineWidth(1)
            
            -- Draw item if exists
            if playerEntity.inventory.items[itemIndex] then
                local item = playerEntity.inventory.items[itemIndex]
                
                -- Item name (truncated if too long)
                lg.setColor(1, 1, 1)
                local itemName = item.type
                if #itemName > 10 then
                    itemName = itemName:sub(1, 10) .. "..."
                end
                lg.print(itemName, x + 5, y + 5, 0, 0.8, 0.8)
                
                -- Quantity
                lg.setColor(1, 1, 0.5)
                lg.print("x" .. item.quantity, x + 5, y + inventory.cellSize - 20, 0, 1.2, 1.2)
                
                -- Item icon/color based on type
                inventory:drawItemIcon(item.type, x + inventory.cellSize/2, y + inventory.cellSize/2 - 5)
            else
                -- Empty slot
                lg.setColor(0.3, 0.3, 0.35, 0.5)
                lg.print("Empty", x + 20, y + 30, 0, 0.8, 0.8)
            end
            
            itemIndex = itemIndex + 1
        end
    end
    
    -- Instructions
    lg.setColor(0.7, 0.7, 0.7)
    lg.print("Press [I] or [ESC] to close", 360, 480)
    
    -- Item list (if more than 9 items)
    local totalItems = #playerEntity.inventory.items
    if totalItems > 9 then
        lg.setColor(1, 0.5, 0.5)
        lg.print("⚠ More than 9 items! Showing first 9 only.", 300, 450)
    end
    
    lg.setColor(1, 1, 1) -- Reset color
end

function inventory:drawItemIcon(itemType, x, y)
    -- Simple colored squares as icons (can be replaced with sprites later)
    local lg = love.graphics
    local size = 20
    
    -- Color based on item type
    if itemType:find("seed") then
        lg.setColor(0.6, 0.8, 0.4) -- Green for seeds
    elseif itemType:find("meat") then
        lg.setColor(0.8, 0.3, 0.3) -- Red for meat
    elseif itemType == "water" then
        lg.setColor(0.3, 0.6, 1) -- Blue for water
    elseif itemType:find("carrot") or itemType:find("potato") or itemType:find("mushroom") then
        lg.setColor(0.9, 0.6, 0.3) -- Orange for crops
    elseif itemType:find("berries") or itemType:find("herbs") or itemType:find("nuts") then
        lg.setColor(0.5, 0.8, 0.5) -- Light green for forage
    else
        lg.setColor(0.7, 0.7, 0.7) -- Gray for unknown
    end
    
    lg.circle("fill", x, y, size)
end

function inventory:keypressed(key)
    if key == "escape" or key == "i" then
        -- Close inventory, return to gameplay
        local gamestate = require("states/gamestate")
        gamestate.switch("gameplay")
    end
end

function inventory:exit()
    print("📦 Closing inventory")
end

return inventory