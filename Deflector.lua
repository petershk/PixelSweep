local Deflector = {}
Deflector.__index = Deflector

function Deflector:new(x, y, strength, size)
    local obj = setmetatable({}, self)
    obj.x = x or 0
    obj.y = y or 0
    obj.strength = strength or 1000
    obj.size = size or 15
    obj.phase = love.math.random() * 2 * math.pi -- Unique phase for each deflector
    return obj
end

function Deflector:update(dt)
    -- Example: pulse strength
    local base_strength = 100
    local pulse_amount = 50
    self.strength = base_strength + math.sin(love.timer.getTime() * 2 + self.phase) * pulse_amount
end

function Deflector:draw(box_x, box_y)
    -- Draw range
    love.graphics.setColor(0, 0.5, 1, 0.2)
    love.graphics.circle("line", box_x + self.x, box_y + self.y, self.size * 5)
    -- Draw deflector
    love.graphics.setColor(0, 0, 1, 0.5)
    love.graphics.circle("fill", box_x + self.x, box_y + self.y, self.size)
    -- Draw strength
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        string.format("%.0f", self.strength),
        box_x + self.x + self.size + 5,
        box_y + self.y - 8
    )
end

return Deflector