Pixel = {}
Pixel.__index = Pixel

function Pixel:new(x, y)
    local obj = setmetatable({}, self)
    obj.x = x or 0
    obj.y = y or 0
    obj.r = 1
    obj.g = 0
    obj.b = 1
    obj.speed = 0
    obj.heading = 0
    obj.size = 1 -- Size of the pixel
    return obj
end

function Pixel:move(dt)
    if self.speed > 0 then
        -- Update the position based on speed and heading
        self.x = self.x + math.cos(self.heading) * self.speed * dt
        self.y = self.y + math.sin(self.heading) * self.speed * dt
        self.speed = self.speed - 100 * dt -- Decrease speed over time
    end
end

function Pixel:updateColor(dt)
    local originalR, originalG, originalB = 1, 1, 1 -- Original color (purple)
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

function Pixel:draw()
    love.graphics.setColor(self.r, self.g, self.b)
    love.graphics.setPointSize(self.size) 
    love.graphics.points(self.x, self.y)
end