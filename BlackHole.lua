local BlackHole = {}
BlackHole.__index = BlackHole

function BlackHole:new(x, y, strength, size)
    local obj = setmetatable({}, self)
    obj.x = x or 0
    obj.y = y or 0
    obj.strength = strength or 2000
    obj.size = size or 20
    obj.stars_eaten = 0
    return obj
end

function BlackHole:update(dt)
    -- You can add animations or pulsing here if desired
end

function BlackHole:draw(box_x, box_y)
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.circle("fill", box_x + self.x, box_y + self.y, self.size)
    -- Draw stars eaten or strength
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        string.format("Eaten: %d", self.stars_eaten),
        box_x + self.x + self.size + 5,
        box_y + self.y - 8
    )
end

return BlackHole