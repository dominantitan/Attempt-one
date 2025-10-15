-- Audio System
-- Manages ambient sounds, music, and audio cues

local audio = {}

-- Audio sources
audio.sounds = {}
audio.music = {}
audio.currentMusic = nil

function audio.load()
    -- Load audio files
    -- audio.sounds.footsteps = love.audio.newSource("assets/sounds/footsteps.wav", "static")
    -- audio.sounds.danger = love.audio.newSource("assets/sounds/danger.wav", "static")
    -- audio.music.forest = love.audio.newSource("assets/music/forest_ambient.ogg", "stream")
end

function audio.update(dt)
    -- Update audio based on game state
end

function audio.playSound(soundName)
    -- Play a sound effect
    if audio.sounds[soundName] then
        audio.sounds[soundName]:stop()
        audio.sounds[soundName]:play()
    end
end

function audio.playMusic(musicName, volume, loop)
    -- Play background music
    volume = volume or 0.5
    loop = loop ~= false -- Default to true
    
    if audio.currentMusic then
        audio.currentMusic:stop()
    end
    
    if audio.music[musicName] then
        audio.currentMusic = audio.music[musicName]
        audio.currentMusic:setVolume(volume)
        audio.currentMusic:setLooping(loop)
        audio.currentMusic:play()
    end
end

function audio.stopMusic()
    -- Stop current music
    if audio.currentMusic then
        audio.currentMusic:stop()
        audio.currentMusic = nil
    end
end

function audio.setMasterVolume(volume)
    -- Set master volume
    love.audio.setVolume(volume)
end

function audio.playAmbient()
    -- Play forest ambient sounds
    audio.playMusic("forest", 0.3, true)
end

function audio.playDangerSound()
    -- Play danger/warning sound
    audio.playSound("danger")
end

return audio