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
    return obj
end

function Pixel:move(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
end

function Pixel:updateColor(dt)
    local originalR, originalG, originalB = self.r, self.g, self.b -- Original color (purple)
    local speedR, speedG, speedB = 1, 0.5, 0.5 -- Speed-based color (reddish)

    if self.speed > 0 then
        -- Calculate the interpolation factor based on speed
        local colorFactor = math.min(self.speed / 200, 1) -- Normalize speed to a value between 0 and 1

        -- Lerp between original color and speed-based color
        self.r = originalR + (speedR - originalR) * colorFactor
        self.g = originalG + (speedG - originalG) * colorFactor
        self.b = originalB + (speedB - originalB) * colorFactor
        self.size = 4 * colorFactor -- Increase size when moving
    else
        -- Reset to the original color when not moving
        self.r = originalR
        self.g = originalG
        self.b = originalB
        self.size = 1 -- Reset size when not moving 
    end
end

function Pixel:draw(box_x, box_y)
    love.graphics.setColor(self.r, self.g, self.b)
    love.graphics.setPointSize(self.size) -- Set point size based on pixel size
    love.graphics.points(box_x + self.x, box_y + self.y)
end