_G.love = require("love")
require("PIxel") -- Include the Pixel class
require("Player") -- Include the Player class

function love.load()
    game = {}
    game.pixels = {}
    game.timePassed = 0
    game.maxPixels = 1000
    game.blackholemode = false -- Initialize black hole mode
    player = Player:new(0, 0) -- Create a new Player object

    love.mouse.setVisible(false)

    screen_width, screen_height = love.graphics.getDimensions()

    -- Create Pixel objects instead of simple tables
    for i = 1, game.maxPixels do
        local x = love.math.random(5, screen_width - 5)
        local y = love.math.random(5, screen_height - 5)
        game.pixels[i] = Pixel:new(x, y) -- Use the Pixel:new constructor
    end

    love.graphics.setPointSize(2)
end

function love.draw()
    -- Draw the sweeping sphere
    love.graphics.setColor(player.r, player.g, player.b, player.a) -- Green with transparency
    love.graphics.circle("line", player.x, player.y, player.sweepRadius) -- Draw the sphere

    love.graphics.setColor(0, 255, 0, 1) -- Green with transparency
    love.graphics.rectangle("line",50,50, screen_width - 100, screen_height - 100) -- Draw the bounding box

    -- Draw each Pixel object
    for _, pixel in ipairs(game.pixels) do
        pixel:draw() -- Call the draw method of each Pixel
    end

    love.graphics.setColor(255, 255, 255) -- Reset color to white for text
    love.graphics.print("Time: " .. game.timePassed, 10, 10)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 30)
    love.graphics.print("Pixels: " .. #game.pixels, 10, 50)     
end

function love.update(dt)
    local boundingBox = {xMin = 50, yMin = 50, xMax = screen_width - 50, yMax = screen_height - 50} -- Define the bounding box

    for i = #game.pixels, 1, -1 do -- Iterate backward to safely remove items
        local pixel = game.pixels[i]
        local dx = pixel.x - player.x
        local dy = pixel.y - player.y

        if(game.blackholemode == true) then
            dx = player.x - pixel.x
            dy = player.y - pixel.y
        end
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance <= player.sweepRadius then
            -- Set heading based on direction from the circle
            pixel.heading = math.atan2(dy, dx)

            -- Set speed based on player's push strength
            pixel.speed = player.pushStrength

            if(game.blackholemode == true) then
                pixel.speed = math.max(player.pushStrength * (1 - distance / player.sweepRadius), 0)
            end
        end

        -- Update pixel position
        pixel:move(dt)

        -- Update pixel color to make it twinkle
        pixel:updateColor(dt)

        -- Remove the pixel if it goes outside the bounding box
        if pixel.x < boundingBox.xMin or pixel.x > boundingBox.xMax or
           pixel.y < boundingBox.yMin or pixel.y > boundingBox.yMax then
            table.remove(game.pixels, i)
        end

        if(game.blackholemode == true) then
            if distance < 5 then -- Threshold for destruction
                table.remove(game.pixels, i)
            end
        end 
    end

    game.timePassed = game.timePassed + dt
    player.dt = dt
end

function love.mousemoved(x, y, dx, dy, istouch)
    player.x = x
    player.y = y
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Left mouse button
        game.blackholemode = not game.blackholemode -- Toggle black hole mode
    end
end    