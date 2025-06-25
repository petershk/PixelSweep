local Game = {}
local Deflector = require("Deflector")
local BlackHole = require("BlackHole")

function Game:new(maxPixels)
    local obj = {
        pixels = {},
        blackHoles = {}, -- Initialize black holes table
        deflectors = {}, -- Initialize deflectors table
        timePassed = 0,
        maxPixels = maxPixels or 1000,
        pixelsEscaped = 0,
        pixelsAbsorbed = 0
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Game:initializePixels(screen_width, screen_height, box_x, box_y, box_width, box_height)
    for i = 1, self.maxPixels do
        local rel_x = love.math.random(0, box_width)
        local rel_y = love.math.random(0, box_height)
        table.insert(self.pixels, Pixel:new(rel_x, rel_y))
    end
end

function Game:addBlackHole(x, y, strength, size)
     table.insert(self.blackHoles, BlackHole:new(x - box_x, y - box_y, strength, size))
end

function Game:addDeflector(x, y, strength, size)
    table.insert(self.deflectors, Deflector:new(x - box_x, y - box_y, strength, size))
end

function Game:updatePixels(dt, boundingBox)

    for _, deflector in ipairs(self.deflectors) do
        deflector:update(dt)
    end
    
    for _, blackHole in ipairs(self.blackHoles) do
        blackHole:update(dt)
    end

    local mergeDistance = 3 -- tune this
    local pixelGravityStrength = 10 -- tune this for effect
    for i = #self.pixels, 1, -1 do
        local pixel = self.pixels[i]

        -- Track nearest black hole
        local nearestBH = nil
        local minDistSq = math.huge
        local toBHx, toBHy = 0, 0
        
        -- Apply black hole effects
        pixel.bhDot = 0
        for _, blackHole in ipairs(self.blackHoles) do
            local bh_dx = blackHole.x - pixel.x
            local bh_dy = blackHole.y - pixel.y
            local bh_distance = math.sqrt(bh_dx * bh_dx + bh_dy * bh_dy)

             -- Track nearest BlackHole
            local distSq = bh_dx * bh_dx + bh_dy * bh_dy
            if distSq < minDistSq then
                minDistSq = distSq
                nearestBH = blackHole
                toBHx = bh_dx
                toBHy = bh_dy
            end

            if bh_distance > 0 then
                -- Calculate the gravitational force
                local bh_force = blackHole.strength / (bh_distance * bh_distance)

                -- Normalize the direction vector
                local norm_dx = bh_dx / bh_distance
                local norm_dy = bh_dy / bh_distance

                -- Add tangential (swirling) force
                local tangential_force = 0.1 * bh_force -- Adjust this factor for more/less swirl
                local tangent_dx = -norm_dy * tangential_force
                local tangent_dy = norm_dx * tangential_force

                -- Apply both gravitational and tangential forces
                pixel.vx = pixel.vx + (norm_dx * bh_force + tangent_dx) * dt
                pixel.vy = pixel.vy + (norm_dy * bh_force + tangent_dy) * dt
                --pixel.x = pixel.x + (norm_dx * bh_force + tangent_dx) * dt
                --pixel.y = pixel.y + (norm_dy * bh_force + tangent_dy) * dt
            end

            -- After black hole loop, determine movement direction
            if nearestBH then
                local dot = pixel.vx * toBHx + pixel.vy * toBHy
                pixel.bhDot = dot -- Store for draw
            end

            -- Absorb pixel if it gets too close to the black hole
            if bh_distance < blackHole.size then
                table.remove(self.pixels, i)
                blackHole.strength = blackHole.strength + pixel.strength -- Absorb pixel strength
                blackHole.size = blackHole.size + pixel.size / 100-- Absorb pixel size
                if blackHole.size > 60 then  -- Set your desired max size here
                    blackHole.size = 30
                end
                blackHole.stars_eaten = blackHole.stars_eaten + 1 -- Increment stars eaten count
                self.pixelsAbsorbed = self.pixelsAbsorbed + 1 -- Increment absorbed pixel count
            end
            -- Check if black hole should be destroyed and release stars
            if blackHole.stars_eaten >= 500 then
                -- Release 1000 stars at the black hole's position
                for s = 1, 500 do
                    -- Randomize position slightly around the black hole
                    local angle = love.math.random() * 2 * math.pi
                    local radius = love.math.random() * blackHole.size
                    local rel_x = blackHole.x + math.cos(angle) * radius
                    local rel_y = blackHole.y + math.sin(angle) * radius

                    -- Give each pixel a velocity outward from the center
                    local speed = 100 + love.math.random() * 200 -- adjust min/max speed as desired
                    local vx = math.cos(angle) * speed
                    local vy = math.sin(angle) * speed
                    table.insert(self.pixels, Pixel:new(rel_x, rel_y, vx, vy))
                end
                -- Remove the black hole
                table.remove(self.blackHoles, _)
                break -- Exit the black hole loop since this black hole is gone
            end
        end

        -- Apply deflector effects
        for _, deflector in ipairs(self.deflectors) do
            local def_dx = pixel.x - deflector.x
            local def_dy = pixel.y - deflector.y
            local def_distance = math.sqrt(def_dx * def_dx + def_dy * def_dy)
           
            if def_distance > 0  then
                local def_force = deflector.strength / (def_distance * def_distance)
                pixel.vx = pixel.vx + def_dx * def_force * dt
                pixel.vy = pixel.vy + def_dy * def_force * dt
            end
        end

        -- Move and update pixel
        pixel:move(dt)
        pixel:updateColor(dt)

        -- Remove pixel if out of bounds
        if pixel.x < 0 or pixel.x > box_width or pixel.y < 0 or pixel.y > box_height then
            table.remove(self.pixels, i)
            self.pixelsEscaped = self.pixelsEscaped + 1 -- Increment escaped pixel count
        end
    end
end

return Game