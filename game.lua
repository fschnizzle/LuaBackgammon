local Board = require("board")
local Points = require("points")

local Game = {}

current_player = "brown" -- or "brown", depending on the current player
current_action = "move" -- "roll" = must first click roll btn, "move" = has rolled and now needs to move using remaining dice


function Game:new()
    local obj = {
        board = Board:new(),
        points = Points:new(),
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Game:update(dt)
end

function Game:draw()
    self.board:draw()
    self.points:draw()
    -- drawSprite(roll_sprite, 254, 330)
end

-- roll_sprite = love.graphics.newImage("images/roll_brown.png")

function drawSprite(sprite, x, y)
    love.graphics.draw(sprite, x, y)
end

return Game