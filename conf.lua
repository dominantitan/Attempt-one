-- LÖVE2D Configuration File
-- Sets up game window and debug console

function love.conf(t)
    -- Window settings
    t.window.title = "Farm & Hunt Game"
    t.window.width = 960
    t.window.height = 540
    t.window.resizable = false
    t.window.vsync = 1
    t.window.msaa = 0
    
    -- Enable console window for debugging (IMPORTANT!)
    t.console = true -- This opens a console window on Windows
    
    -- Modules (enable what you need)
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
    t.modules.thread = true
    
    -- Identity (save folder name)
    t.identity = "farmhuntgame"
    
    -- Version
    t.version = "11.4"
    
    -- Debug
    t.externalstorage = false
    t.accelerometerjoystick = false
    
    -- Release settings (set these to false for production)
    t.console = true -- Keep console for debugging
end
