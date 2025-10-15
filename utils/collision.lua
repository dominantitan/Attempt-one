-- Collision Utility
-- Handles collision detection between game objects

local collision = {}

-- Basic AABB collision detection
function collision.checkAABB(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

-- Point in rectangle collision
function collision.pointInRect(px, py, x, y, w, h)
    return px >= x and px <= x + w and py >= y and py <= y + h
end

-- Circle collision detection
function collision.checkCircle(x1, y1, r1, x2, y2, r2)
    local dx = x2 - x1
    local dy = y2 - y1
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < (r1 + r2)
end

-- Point in circle collision
function collision.pointInCircle(px, py, cx, cy, radius)
    local dx = px - cx
    local dy = py - cy
    return (dx * dx + dy * dy) < (radius * radius)
end

-- Line intersection
function collision.lineIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
    local denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    
    if denom == 0 then
        return false -- Lines are parallel
    end
    
    local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
    local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom
    
    if t >= 0 and t <= 1 and u >= 0 and u <= 1 then
        local ix = x1 + t * (x2 - x1)
        local iy = y1 + t * (y2 - y1)
        return true, ix, iy
    end
    
    return false
end

-- Check collision between player and world objects
function collision.checkPlayerCollision(player, objects)
    local collisions = {}
    
    for _, obj in ipairs(objects) do
        if collision.checkAABB(player.x, player.y, player.width, player.height,
                              obj.x, obj.y, obj.width, obj.height) then
            table.insert(collisions, obj)
        end
    end
    
    return collisions
end

-- Resolve collision by moving object back
function collision.resolveAABB(moving, static)
    local overlapX = math.min(moving.x + moving.width - static.x, 
                             static.x + static.width - moving.x)
    local overlapY = math.min(moving.y + moving.height - static.y, 
                             static.y + static.height - moving.y)
    
    if overlapX < overlapY then
        -- Resolve horizontally
        if moving.x < static.x then
            moving.x = static.x - moving.width
        else
            moving.x = static.x + static.width
        end
    else
        -- Resolve vertically
        if moving.y < static.y then
            moving.y = static.y - moving.height
        else
            moving.y = static.y + static.height
        end
    end
end

-- Grid-based collision system for tilemap
collision.grid = {}

function collision.grid.init(cellSize)
    collision.grid.cellSize = cellSize or 32
    collision.grid.objects = {}
end

function collision.grid.addObject(obj, x, y, width, height)
    obj.gridX = x
    obj.gridY = y
    obj.gridWidth = width
    obj.gridHeight = height
    
    local startX = math.floor(x / collision.grid.cellSize)
    local startY = math.floor(y / collision.grid.cellSize)
    local endX = math.floor((x + width) / collision.grid.cellSize)
    local endY = math.floor((y + height) / collision.grid.cellSize)
    
    for gx = startX, endX do
        for gy = startY, endY do
            local key = gx .. "," .. gy
            if not collision.grid.objects[key] then
                collision.grid.objects[key] = {}
            end
            table.insert(collision.grid.objects[key], obj)
        end
    end
end

function collision.grid.removeObject(obj)
    if not obj.gridX then return end
    
    local startX = math.floor(obj.gridX / collision.grid.cellSize)
    local startY = math.floor(obj.gridY / collision.grid.cellSize)
    local endX = math.floor((obj.gridX + obj.gridWidth) / collision.grid.cellSize)
    local endY = math.floor((obj.gridY + obj.gridHeight) / collision.grid.cellSize)
    
    for gx = startX, endX do
        for gy = startY, endY do
            local key = gx .. "," .. gy
            if collision.grid.objects[key] then
                for i, gridObj in ipairs(collision.grid.objects[key]) do
                    if gridObj == obj then
                        table.remove(collision.grid.objects[key], i)
                        break
                    end
                end
            end
        end
    end
    
    obj.gridX = nil
    obj.gridY = nil
    obj.gridWidth = nil
    obj.gridHeight = nil
end

function collision.grid.getNearbyObjects(x, y, width, height)
    local nearby = {}
    local seen = {}
    
    local startX = math.floor(x / collision.grid.cellSize)
    local startY = math.floor(y / collision.grid.cellSize)
    local endX = math.floor((x + width) / collision.grid.cellSize)
    local endY = math.floor((y + height) / collision.grid.cellSize)
    
    for gx = startX, endX do
        for gy = startY, endY do
            local key = gx .. "," .. gy
            if collision.grid.objects[key] then
                for _, obj in ipairs(collision.grid.objects[key]) do
                    if not seen[obj] then
                        seen[obj] = true
                        table.insert(nearby, obj)
                    end
                end
            end
        end
    end
    
    return nearby
end

-- Utility functions
function collision.getDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function collision.getAngle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function collision.normalize(x, y)
    local length = math.sqrt(x * x + y * y)
    if length == 0 then
        return 0, 0
    end
    return x / length, y / length
end

return collision