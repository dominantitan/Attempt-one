-- Save/Load System
-- Handles game state persistence and save file management

local save = {}

-- Try to load JSON library safely
local json = nil
local hasJSON = pcall(function() json = require("libs/json") end)

if not hasJSON then
    print("⚠️  JSON library not found - save/load will use basic Lua serialization")
end

-- Save file path
save.saveFile = "savegame.json"

-- Default save data structure
save.defaultData = {
    player = {
        x = 400,
        y = 300,
        health = 100,
        stamina = 100,
        hunger = 100,
        inventory = {
            items = {},
            money = 100
        }
    },
    world = {
        time = 0.5,
        day = 1,
        crops = {},
        animals = {},
        discoveredAreas = {}
    },
    progress = {
        foundUncle = false,
        completedTutorial = false,
        unlockedAreas = {"farm", "forest"}
    },
    settings = {
        volume = 0.8,
        difficulty = "normal"
    }
}

function save.load()
    -- Load save data from file
    if love.filesystem.getInfo(save.saveFile) then
        local content = love.filesystem.read(save.saveFile)
        if content then
            if hasJSON and json then
                local success, data = pcall(json.decode, content)
                if success and data then
                    return data
                end
            else
                -- Fallback: try to load as Lua table
                local success, data = pcall(loadstring("return " .. content))
                if success and data then
                    return data()
                end
            end
        end
    end
    
    -- Return default data if load fails
    return save.getDefaultData()
end

function save.save(data)
    -- Save data to file
    local content = nil
    
    if hasJSON and json then
        local success, encoded = pcall(json.encode, data)
        if success then
            content = encoded
        end
    end
    
    -- Fallback: basic Lua table serialization
    if not content then
        content = save.serializeTable(data)
    end
    
    if content then
        local writeSuccess = love.filesystem.write(save.saveFile, content)
        return writeSuccess
    end
    
    return false
end

-- Simple table serialization fallback
function save.serializeTable(t, indent)
    indent = indent or 0
    local str = "{\n"
    
    for k, v in pairs(t) do
        str = str .. string.rep("  ", indent + 1)
        
        if type(k) == "string" then
            str = str .. '["' .. k .. '"] = '
        else
            str = str .. "[" .. k .. "] = "
        end
        
        if type(v) == "table" then
            str = str .. save.serializeTable(v, indent + 1)
        elseif type(v) == "string" then
            str = str .. '"' .. v .. '"'
        else
            str = str .. tostring(v)
        end
        
        str = str .. ",\n"
    end
    
    str = str .. string.rep("  ", indent) .. "}"
    return str
end

function save.getDefaultData()
    -- Deep copy of default data
    local data = {}
    
    -- Player data
    data.player = {
        x = save.defaultData.player.x,
        y = save.defaultData.player.y,
        health = save.defaultData.player.health,
        stamina = save.defaultData.player.stamina,
        hunger = save.defaultData.player.hunger,
        inventory = {
            items = {},
            money = save.defaultData.player.inventory.money
        }
    }
    
    -- World data
    data.world = {
        time = save.defaultData.world.time,
        day = save.defaultData.world.day,
        crops = {},
        animals = {},
        discoveredAreas = {}
    }
    
    -- Progress data
    data.progress = {
        foundUncle = save.defaultData.progress.foundUncle,
        completedTutorial = save.defaultData.progress.completedTutorial,
        unlockedAreas = {"farm", "forest"}
    }
    
    -- Settings data
    data.settings = {
        volume = save.defaultData.settings.volume,
        difficulty = save.defaultData.settings.difficulty
    }
    
    return data
end

function save.saveGame(gameState)
    -- Convert current game state to save data
    local data = save.getDefaultData()
    
    -- Update with current game state
    if gameState.player then
        data.player.x = gameState.player.x
        data.player.y = gameState.player.y
        data.player.health = gameState.player.health
        data.player.stamina = gameState.player.stamina
        data.player.hunger = gameState.player.hunger
        data.player.inventory = gameState.player.inventory
    end
    
    if gameState.world then
        data.world.time = gameState.world.time
        data.world.day = gameState.world.day
        data.world.crops = gameState.world.crops or {}
        data.world.animals = gameState.world.animals or {}
    end
    
    if gameState.progress then
        data.progress = gameState.progress
    end
    
    return save.save(data)
end

function save.loadGame()
    -- Load and apply save data to game state
    local data = save.load()
    return data
end

function save.deleteSave()
    -- Delete save file
    if love.filesystem.getInfo(save.saveFile) then
        return love.filesystem.remove(save.saveFile)
    end
    return true
end

function save.hasSaveFile()
    -- Check if save file exists
    return love.filesystem.getInfo(save.saveFile) ~= nil
end

function save.createBackup()
    -- Create backup of current save
    local backupFile = "savegame_backup.json"
    
    if love.filesystem.getInfo(save.saveFile) then
        local content = love.filesystem.read(save.saveFile)
        if content then
            return love.filesystem.write(backupFile, content)
        end
    end
    
    return false
end

function save.autoSave(gameState)
    -- Automatic save with error handling
    local success = save.saveGame(gameState)
    
    if success then
        print("Game auto-saved successfully")
    else
        print("Auto-save failed")
    end
    
    return success
end

-- Utility functions for specific data
function save.savePlayerPosition(x, y)
    local data = save.load()
    data.player.x = x
    data.player.y = y
    return save.save(data)
end

function save.savePlayerInventory(inventory)
    local data = save.load()
    data.player.inventory = inventory
    return save.save(data)
end

function save.saveWorldTime(time, day)
    local data = save.load()
    data.world.time = time
    data.world.day = day
    return save.save(data)
end

function save.saveProgress(progress)
    local data = save.load()
    data.progress = progress
    return save.save(data)
end

-- Note: You'll need to install a JSON library for this to work
-- You can use a simple JSON implementation or external library
-- For now, this provides the structure for save/load functionality

return save