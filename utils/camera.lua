-- Camera Utility
-- Manages camera position, following, and transformations

local camera = {}

-- Camera properties
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

-- Follow target
camera.target = nil
camera.followSpeed = 5
camera.deadZone = {x = 100, y = 75}

-- Screen shake
camera.shakeIntensity = 0
camera.shakeDuration = 0
camera.shakeTimer = 0

-- Bounds
camera.bounds = {
    left = 0,
    top = 0,
    right = 2000,
    bottom = 1500
}

function camera.load()
    -- Initialize camera
    camera.x = love.graphics.getWidth() / 2
    camera.y = love.graphics.getHeight() / 2
end

function camera.update(dt)
    -- Follow target
    if camera.target then
        local targetX = camera.target.x or camera.target[1]
        local targetY = camera.target.y or camera.target[2]
        
        -- Calculate desired camera position
        local desiredX = targetX - love.graphics.getWidth() / 2
        local desiredY = targetY - love.graphics.getHeight() / 2
        
        -- Apply dead zone
        local dx = desiredX - camera.x
        local dy = desiredY - camera.y
        
        if math.abs(dx) > camera.deadZone.x then
            camera.x = camera.x + (dx - math.sign(dx) * camera.deadZone.x) * camera.followSpeed * dt
        end
        
        if math.abs(dy) > camera.deadZone.y then
            camera.y = camera.y + (dy - math.sign(dy) * camera.deadZone.y) * camera.followSpeed * dt
        end
    end
    
    -- Apply bounds
    camera.x = math.max(camera.bounds.left, math.min(camera.bounds.right - love.graphics.getWidth(), camera.x))
    camera.y = math.max(camera.bounds.top, math.min(camera.bounds.bottom - love.graphics.getHeight(), camera.y))
    
    -- Update screen shake
    if camera.shakeDuration > 0 then
        camera.shakeTimer = camera.shakeTimer + dt
        
        if camera.shakeTimer >= camera.shakeDuration then
            camera.shakeDuration = 0
            camera.shakeTimer = 0
            camera.shakeIntensity = 0
        end
    end
end

function camera.apply()
    -- Apply camera transformation
    love.graphics.push()
    
    local shakeX = 0
    local shakeY = 0
    
    if camera.shakeDuration > 0 then
        shakeX = (math.random() - 0.5) * camera.shakeIntensity
        shakeY = (math.random() - 0.5) * camera.shakeIntensity
    end
    
    love.graphics.translate(-camera.x + shakeX, -camera.y + shakeY)
    love.graphics.scale(camera.scaleX, camera.scaleY)
    love.graphics.rotate(camera.rotation)
end

function camera.unapply()
    -- Remove camera transformation
    love.graphics.pop()
end

function camera.setPosition(x, y)
    camera.x = x
    camera.y = y
end

function camera.getPosition()
    return camera.x, camera.y
end

function camera.setTarget(target)
    camera.target = target
end

function camera.setFollowSpeed(speed)
    camera.followSpeed = speed
end

function camera.setDeadZone(x, y)
    camera.deadZone.x = x
    camera.deadZone.y = y
end

function camera.setBounds(left, top, right, bottom)
    camera.bounds.left = left
    camera.bounds.top = top
    camera.bounds.right = right
    camera.bounds.bottom = bottom
end

function camera.shake(intensity, duration)
    camera.shakeIntensity = intensity
    camera.shakeDuration = duration
    camera.shakeTimer = 0
end

function camera.setZoom(scaleX, scaleY)
    camera.scaleX = scaleX
    camera.scaleY = scaleY or scaleX
end

function camera.setRotation(rotation)
    camera.rotation = rotation
end

function camera.worldToScreen(worldX, worldY)
    local screenX = (worldX - camera.x) * camera.scaleX
    local screenY = (worldY - camera.y) * camera.scaleY
    return screenX, screenY
end

function camera.screenToWorld(screenX, screenY)
    local worldX = (screenX / camera.scaleX) + camera.x
    local worldY = (screenY / camera.scaleY) + camera.y
    return worldX, worldY
end

function camera.isVisible(x, y, width, height)
    width = width or 0
    height = height or 0
    
    return not (x + width < camera.x or 
                x > camera.x + love.graphics.getWidth() or
                y + height < camera.y or 
                y > camera.y + love.graphics.getHeight())
end

function math.sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

return camera