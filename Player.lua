Player = {}
Player.__index = Player

function Player:new(x, y)
    local obj = setmetatable({}, self)
    obj.x = x or 0
    obj.y = y or 0
    obj.r = 0
    obj.g = 1
    obj.b = 1
    obj.a = 0.2
    obj.dt = 0
    obj.sweepRadius = 200 -- Radius of the sweeping sphere
    obj.pushStrength = 300 -- Strength of the push effect
    obj.credits = 10 --Starting credits
    obj.score = 0 -- Starting score
    return obj
end 

return Player