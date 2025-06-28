_G.love = require("love")
require("Pixel")
local Game = require("Game")
local Menu = require("menu")
local menu = setmetatable({}, Menu)

zoom = 1.0

menuToggleSound = love.audio.newSource("sounds/menu_toggle.ogg", "static")

game_ready = false
 
function love.load()
    screen_width, screen_height = love.graphics.getDimensions()
    box_width = 5000
    box_height = 4000
    box_x = (screen_width - box_width) / 2
    box_y = (screen_height - box_height) / 2

    game = Game:new(1000)
    game:initializePixels(screen_width, screen_height, box_x, box_y, box_width, box_height)

    love.mouse.setVisible(true)
    love.graphics.setPointSize(2)

    pixelShader = love.graphics.newShader("pixelshader.glsl")

end

function love.resize(w, h)
    screen_width = w
    screen_height = h
    box_x = (screen_width - box_width) / 2
    box_y = (screen_height - box_height) / 2
end

function love.draw()
    -- Draw bounding box centered
    love.graphics.push()
    --love.graphics.translate((1 - zoom) * love.mouse.getX() / zoom, (1 - zoom) * love.mouse.getY() / zoom)
    love.graphics.scale(zoom, zoom)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("line", box_x, box_y, box_width, box_height)

    

    -- Draw pixels
    love.graphics.setShader(pixelShader)
    --pixelShader:send("time", love.timer.getTime())
    for _, pixel in ipairs(game.pixels) do
        pixel:draw(box_x, box_y)
    end
    love.graphics.setShader()

    -- Draw black holes
    love.graphics.setColor(1, 0, 0, 0.5)
    for _, blackHole in ipairs(game.blackHoles) do
        blackHole:draw(box_x, box_y)
    end

    -- Draw deflectors
    love.graphics.setColor(0, 0, 1, 0.5)
    for _, deflector in ipairs(game.deflectors) do
        deflector:draw(box_x, box_y)
    end

    love.graphics.pop()

    menu:draw(screen_height)

    -- Draw stats
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Time: " .. game.timePassed, 10, 10)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 30)
    love.graphics.print("Pixels: " .. #game.pixels, 10, 50)
    love.graphics.print("Escaped: " .. game.pixelsEscaped, 10, 70) -- Display escaped pixels
    love.graphics.print("Absorbed: " .. game.pixelsAbsorbed, 10, 90) -- Display absorbed pixels
end

function love.update(dt)
    local boundingBox = {
        xMin = box_x,
        yMin = box_y,
        xMax = box_x + box_width,
        yMax = box_y + box_height
    }

    if isPanning then
        local mx, my = love.mouse.getPosition()
        -- Adjust for zoom!
        box_x = boxStartX + (mx - panStartX) / zoom
        box_y = boxStartY + (my - panStartY) / zoom
    end
    
    for _, deflector in ipairs(game.deflectors) do
        deflector:update(dt)
    end
    game:updatePixels(dt, boundingBox)
    

    menu:update(dt)
   
    game.timePassed = game.timePassed + dt
end

isPanning = false
panStartX = 0
panStartY = 0
boxStartX = 0
boxStartY = 0
function love.mousepressed(x, y, button, istouch, presses)
    if(menu.open) then
        for _, btn in ipairs(menu.buttons) do
            btn:mousepressed(love.mouse.getX() - menu.x, love.mouse.getY(), 1)
        end
    else
        if button == 1 then
            -- Adjust for zoom
            local wx = x / zoom
            local wy = y / zoom
            game:addBlackHole(wx, wy, 500000, 60)
        elseif button == 2 then
            local wx = x / zoom
            local wy = y / zoom
            game:addDeflector(wx, wy, 20000, 50)
        elseif button == 3 then
            -- Start panning
            isPanning = true
            panStartX = x  
            panStartY = y
            boxStartX = box_x
            boxStartY = box_y
        end
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 3 then
        isPanning = false
    end
end

function love.wheelmoved(x, y)
    if y == 0 then return end

    local mx, my = love.mouse.getPosition()
    -- World coordinate under mouse BEFORE zoom
    local world_x = (mx / zoom) - box_x
    local world_y = (my / zoom) - box_y

    -- Adjust zoom
    if y > 0 then
        zoom = zoom * 1.1
    elseif y < 0 then
        zoom = zoom / 1.1
    end
    zoom = math.max(0.1, math.min(zoom, 10))

    -- Adjust box_x and box_y so the same world point stays under the mouse
    box_x = (mx / zoom) - world_x
    box_y = (my / zoom) - world_y
end

function love.keypressed(key)
    if not menu.open then
        if key == "s" then
            game:initializePixels(screen_width, screen_height, box_x, box_y, box_width, box_height)
        end
    end
    if key == "tab" then
        menu:toggle()
    end
 
end

