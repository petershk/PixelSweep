local Button = {}
Button.__index = Button

function Button:new(x, y, w, h, text, onclick)
    local btn = setmetatable({}, Button)
    btn.x = x
    btn.y = y
    btn.w = w
    btn.h = h
    btn.text = text
    btn.onclick = onclick or function() end
    btn.hovered = false
    return btn
end

function Button:isHovered(mx, my)
    return mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h
end

function Button:update(mx, my)
    self.hovered = self:isHovered(mx, my)
end

function Button:draw(menuX)
    local drawX = menuX + self.x
    love.graphics.setColor(self.hovered and {0.7,0.7,1,1} or {0.4,0.4,0.6,1})
    love.graphics.rectangle("fill", drawX, self.y, self.w, self.h, 8, 8)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(self.text, drawX, self.y + self.h/2 - 8, self.w, "center")
end

function Button:mousepressed(mx, my, button)
    if button == 1 and self:isHovered(mx, my) then
        self.onclick()
    end
end

return Button