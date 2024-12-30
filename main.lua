-- Imports
local Game = require("game")

local game

function love.load()
    love.graphics.setBackgroundColor(1,1,1) -- White background
    math.randomseed(os.time()) -- Seed the RNG with the current time
    game = Game:new()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end