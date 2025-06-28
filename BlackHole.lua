blackholeShader = love.graphics.newShader("blackhole.glsl")

local BlackHole = {}
BlackHole.__index = BlackHole

function BlackHole:new(x, y, strength, size)
    local obj = setmetatable({}, self)
    obj.x = x or 0
    obj.y = y or 0
    obj.strength = strength or 2000
    obj.size = size or 20
    obj.stars_eaten = 0
    obj.range = size * 10
    return obj
end

function BlackHole:update(dt)
    -- You can add animations or pulsing here if desired
end

function BlackHole:draw(box_x, box_y)
     local cx = self.x + box_x
    local cy = self.y + box_y
    local r = self.size or 40

    love.graphics.setShader(blackholeShader)
    blackholeShader:send("time", love.timer.getTime())

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", cx, cy, self.size)

    love.graphics.setShader()
    love.graphics.circle("line", cx, cy, self.range)
    -- Draw stars eaten or strength
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        string.format("Eaten: %d", self.stars_eaten),
        box_x + self.x + self.size + 5,
        box_y + self.y - 8
    )
    love.graphics.print(
        string.format("Strength: %d", self.strength),
        box_x + self.x + self.size + 5,
        box_y + self.y - 20
    )
    love.graphics.print(
        string.format("Size: %d", self.size),
        box_x + self.x + self.size + 5,
        box_y + self.y - 32
    )
end

return BlackHole