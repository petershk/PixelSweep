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

function Game:applyBlackHoleEffects(pixel, dt)
    local nearestBH, minDistSq, toBHx, toBHy = nil, math.huge, 0, 0
    for _, blackHole in ipairs(self.blackHoles) do
        local bh_dx = blackHole.x - pixel.x
        local bh_dy = blackHole.y - pixel.y
        local bh_distance = math.sqrt(bh_dx * bh_dx + bh_dy * bh_dy)
        local distSq = bh_dx * bh_dx + bh_dy * bh_dy
        if distSq < minDistSq then
            minDistSq = distSq
            nearestBH = blackHole
            toBHx = bh_dx
            toBHy = bh_dy
        end
        if bh_distance > 0 then
            local bh_force = blackHole.strength / (bh_distance * bh_distance)
            local norm_dx = bh_dx / bh_distance
            local norm_dy = bh_dy / bh_distance
            local tangential_force = 0.0 * bh_force
            local tangent_dx = -norm_dy * tangential_force
            local tangent_dy = norm_dx * tangential_force
            pixel.vx = pixel.vx + (norm_dx * bh_force + tangent_dx) * dt
            pixel.vy = pixel.vy + (norm_dy * bh_force + tangent_dy) * dt
        end
        -- Absorb pixel if it gets too close
        if bh_distance < blackHole.size then
            self:handlePixelAbsorption(pixel, blackHole)
            return true -- Pixel absorbed, stop further processing
        end
        -- Black hole explosion
        if blackHole.stars_eaten >= 500 then
            self:handleBlackHoleExplosion(blackHole)
            return false -- Black hole exploded, stop further processing
        end
    end
    if nearestBH then
        pixel.bhDot = pixel.vx * toBHx + pixel.vy * toBHy
    end
    return false
end

function Game:applyDeflectorEffects(pixel, dt)
    for _, deflector in ipairs(self.deflectors) do
        local def_dx = pixel.x - deflector.x
        local def_dy = pixel.y - deflector.y
        local def_distance = math.sqrt(def_dx * def_dx + def_dy * def_dy)
        if def_distance > 0 then
            local def_force = deflector.strength / (def_distance * def_distance)
            pixel.vx = pixel.vx + def_dx * def_force * dt
            pixel.vy = pixel.vy + def_dy * def_force * dt
        end
    end
end

function Game:handlePixelAbsorption(pixel, blackHole)
    for i, p in ipairs(self.pixels) do
        if p == pixel then
            table.remove(self.pixels, i)
            break
        end
    end
    blackHole.strength = blackHole.strength + pixel.strength
    blackHole.size = blackHole.size + pixel.size / 100
    if blackHole.size > 60 then
        blackHole.size = 30
    end
    blackHole.stars_eaten = blackHole.stars_eaten + 1
    self.pixelsAbsorbed = self.pixelsAbsorbed + 1
end

function Game:handleBlackHoleExplosion(blackHole)
    for s = 1, 500 do
        local angle = love.math.random() * 2 * math.pi
        local radius = love.math.random() * blackHole.size
        local rel_x = blackHole.x + math.cos(angle) * radius
        local rel_y = blackHole.y + math.sin(angle) * radius
        local speed = 100 + love.math.random() * 200
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        table.insert(self.pixels, Pixel:new(rel_x, rel_y, vx, vy))
    end
    for i, bh in ipairs(self.blackHoles) do
        if bh == blackHole then
            table.remove(self.blackHoles, i)
            break
        end
    end
end

function Game:removePixelIfOutOfBounds(i, pixel)
    if pixel.x < 0 or pixel.x > box_width or pixel.y < 0 or pixel.y > box_height then
        table.remove(self.pixels, i)
        self.pixelsEscaped = self.pixelsEscaped + 1
        return true
    end
    return false
end

function Game:updatePixels(dt, boundingBox)
    for i = #self.pixels, 1, -1 do
        local pixel = self.pixels[i]
        if self:applyBlackHoleEffects(pixel, dt) then
            -- Pixel absorbed or black hole exploded, skip to next pixel
            goto continue
        end
        self:applyDeflectorEffects(pixel, dt)
        pixel:move(dt)
        pixel:updateColor(dt)
        if self:removePixelIfOutOfBounds(i, pixel) then
            goto continue
        end
        ::continue::
    end
end

return Game