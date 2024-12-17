-- function love.load(args)

--     if #args > 0 then
--         local script = args[1]
--         local chunk, err = loadfile(script)
--         if chunk then
--             chunk()
--             if love.load then
--                 love.load()
--             end
--         else
--             print("Error loading file:", err)
--         end
--     else
--         print("no script provided to run")
--     end

-- end


-- Imports
local Board = require("board")
-- local Checker = require("checker")
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