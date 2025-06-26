local Button = require("Button")
local Menu = {  
                width = 300,
                x = -300, -- Start hidden
                targetX = -300,
                speed = 0.15,
                open = false,
                transitioning = false,
                buttons = {}
            }
Menu.__index = Menu

function Menu:initButtons()
    self.buttons = {
        Button:new(20, 100, 260, 40, "Add Star", function()
            -- Your add star logic here
            print("Add Star pressed!")
        end)
        -- Add more buttons as needed
    }
end

function Menu:new()
    local obj = setmetatable({}, self)
    obj:initButtons()
    return obj
end

function Menu:draw(screen_height)
    if self.x > -self.width then
       
        love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
        love.graphics.rectangle("fill", self.x, 0, self.width, screen_height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Simulation Menu", self.x + 20, 30)
        love.graphics.print("[Add controls here]", self.x + 20, 60)
         -- You can add buttons, sliders, etc. here
        for _, btn in ipairs(self.buttons) do
            btn:draw(self.x)
        end 
    end

end

function Menu:update(dt)
    
    local mx, my = love.mouse.getPosition()
    for _, btn in ipairs(self.buttons) do
        btn:update(mx - self.x, my) -- Adjust for menu x offset
    end

    if not self.transitioning then
        return
    end


    if (self.transitioning) then
        self.x = self.x + (self.targetX - self.x) * self.speed
    end

    -- Snap to target if very close
    if math.abs(self.x - self.targetX) < 1 then
        self.transitioning = false
        self.x = self.targetX
    else
        self.transitioning = true
    end

   
end

function Menu:toggle()
    self.open = not self.open
    self.transitioning = true
    self.targetX = self.open and 0 or -self.width
    self:initButtons() -- Reposition buttons if needed
end

return Menu