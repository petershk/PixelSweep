Pixel = {}
Pixel.__index = Pixel

function Pixel:new(x, y, vx, vy)
    local obj = setmetatable({}, self)
    obj.x = x or 0
    obj.y = y or 0
    obj.r = 1
    obj.g = 1
    obj.b = 1
    obj.vx = vx or 0
    obj.vy = vy or 0
    obj.speed = 0
    obj.heading = 0
    obj.size = 1 -- Size of the pixel
    obj.strength = 1000 -- Strength of the pixels
    obj.bhDot = nil
    return obj
end

function Pixel:move(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
end

function Pixel:updateColor(dt)
    -- Encode bhDot into color for shader use
    local dot = self.bhDot or 0
    -- Clamp and normalize bhDot to [-1, 1] for color mapping (adjust 5000 for your game's scale)
    local t = math.max(-1, math.min(1, dot / 5000))

    if t > 0 then
        -- Moving toward: more red
        self.r = 1
        self.g = 1 - t
        self.b = 1 - t
    elseif t < 0 then
        -- Moving away: more blue
        self.r = 1 + t
        self.g = 1 + t
        self.b = 1
    else
        -- Neutral
        self.r = 1
        self.g = 1
        self.b = 1
    end

    -- Optionally, size can still depend on speed
    if self.speed > 0 then
        local colorFactor = math.min(self.speed / 200, 1)
        self.size = math.max(2, 8 * colorFactor)
    else
        self.size = 2
    end
end

function Pixel:draw(box_x, box_y)
    love.graphics.setColor(self.r, self.g, self.b)
    love.graphics.setPointSize(self.size) -- Set point size based on pixel size
    love.graphics.points(box_x + self.x, box_y + self.y)

    local px = box_x + self.x
    local py = box_y + self.y
    local scale = 0.2 -- Adjust for visibility
    love.graphics.setColor(1, 1, 0, 0.7) -- Yellow, semi-transparent
    love.graphics.line(px, py, px + self.vx * scale, py + self.vy * scale)
end