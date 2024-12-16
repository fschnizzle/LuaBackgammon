local Board = require("board")
local Points = require("points")

local Game = {}

-- current_player = "brown" -- or "brown", depending on the current player
-- current_action = "move" -- "roll" = must first click roll btn, "move" = has rolled and now needs to move using remaining dice

local mousePressed = false -- Tracks the mouse state

function Game:new()
    local obj = {
        board = Board:new(),
        points = nil,
        selectedPoint = nil,
        diceRolls = {1, 2},
        current_player = "brown", -- Global variable
        current_action = "move",  -- Global variable
        rollButton = {
            sprite = love.graphics.newImage("images/roll_brown.png"),
            width = 100, -- Placeholder width for the sprite
            height = 30, -- Placeholder height for the sprite
            x = 250, -- Position on the screen
            y = love.graphics.getHeight() / 2 - 30/2, -- Vertically centered
        }
    }
    setmetatable(obj, self)
    self.__index = self


    -- Create points AFTER
    obj.points = Points:new(obj)

    return obj
end

function Game:rollDice()
    if self.current_action ~= "roll" then return end -- Only roll dice in the "roll" state

    -- Example dice roll logic (replace with actual random rolls later)
    self.diceRolls = {math.random(1, 6), math.random(1, 6)}
    print(self.current_player, "rolled:", table.concat(self.diceRolls, ", "))

    -- Transition to "move"
    self.current_action = "move"
end

function Game:checkRollButtonClick(mouseX, mouseY)
    local button = self.rollButton
    if mouseX >= button.x and mouseX <= button.x + button.width and mouseY >= button.y and mouseY <= button.y + button.height then
        self:rollDice()
    end
end

function Game:update(dt)

    -- Await user input [CLICKS]
    local mouseX, mouseY = love.mouse.getPosition()
    if love.mouse.isDown(1) then
        if not mousePressed then
            mousePressed = true -- Register that the mouse is now pressed

            -- Handle based on current action

            -- Handle roll button click
            if self.current_action == "roll" then
                self:checkRollButtonClick(mouseX, mouseY)
                return -- Exit after processing the roll button click
            end

            -- Handle point clicks for moves
            if self.current_action == "move" then
                for _, point in ipairs(self.points.points) do
                    local coords = point.coordinates
                    -- Get smallest and largest x and y from coords
                    local bounds = {}
                    bounds.xMin = math.min(coords[1].x, coords[2].x, coords[3].x, coords[4].x)
                    bounds.xMax = math.max(coords[1].x, coords[2].x, coords[3].x, coords[4].x)
                    bounds.yMin = math.min(coords[1].y, coords[2].y, coords[3].y, coords[4].y)
                    bounds.yMax = math.max(coords[1].y, coords[2].y, coords[3].y, coords[4].y)

                    if mouseX >= bounds.xMin and mouseX <= bounds.xMax and mouseY >= bounds.yMin and mouseY <= bounds.yMax then
                        print("Clicked on point", point.id)
                        if self.selectedPoint == nil then
                            -- Select the point
                            if point.color == self.current_player and point.count > 0 then
                                self.selectedPoint = point
                            end
                        else
                            -- Attempt to move a checker
                            self:moveChecker(self.selectedPoint.id, point.id)
                            self.selectedPoint = nil
                        end
                        break
                    end

                end
            end
        end
    else
        mousePressed = false -- Reset the flag when the mouse button is released
    end
end

function Game:consumeDice(distance)
    for i, roll in ipairs(self.diceRolls) do
        if roll == distance then
            table.remove(self.diceRolls, i)
            break
        end
    end
end

function Game:moveChecker(fromId, toId)
    local fromPoint = self.points.points[fromId]
    local toPoint = self.points.points[toId]

    -- Check if the move is valid (using dice roll logic etc)
    local distance = math.abs(fromId - toId)
    if not self:isValidMove(fromPoint, toPoint, distance) then
        print("Invalid move!")
        return
    end

    -- Move the checker
    if fromPoint:removeChecker() then
        toPoint:addChecker(fromPoint.color)
        print("Moved checker from " .. fromId .. " to " .. toId)
        self:consumeDice(distance)
    else
        print("No checkers to move!")
    end

    -- Check if all dice have been consumed
    if #self.diceRolls == 0 then
        self:endTurn()
    end
end

function Game:endTurn()
    self.current_action = "end_turn"

    -- Switch player
    self.current_player = (self.current_player == "brown") and "white" or "brown"

    -- Reset for next turn
    self.diceRolls = {}
    self.current_action = "roll"
end

-- Add in Game:isValidMove(fromPoint, toPoint, distance) validation function
function Game:isValidMove(fromPoint, toPoint, distance)
    if fromPoint.color ~= self.current_player then
        print("Cannot move checkers of the other player")
        return false -- Cannot move opponent's checkers
    end
    if toPoint.color ~= "none" and toPoint.color ~= fromPoint.color then
        return toPoint.count == 1 -- Opposite color can only be hit if max one checker (blot) is there)
    end


    -- Validated based on dice rolls
    -- local diceRolls = {4,6} -- REPLACE WITH ACTUAL ROLLS LATER
    return table.contains(self.diceRolls, distance)
    
end

-- Helper function to check if a value is in a table
function table.contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end



function Game:draw()
    self.board:draw()
    self.points:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.current_player .. " : " .. table.concat(self.diceRolls, "  "), 10, 10)    -- print("Current player:", self.current_player)
    love.graphics.setColor(1, 1, 1)

    -- Draw the roll button
    if self.current_action == "roll" then
        local button = self.rollButton
        love.graphics.draw(button.sprite, button.x, button.y)
    end
    -- print("Selected point:", self.selectedPoint and self.selectedPoint.id or "None")
    

    -- -- State based drawing
    -- if self.current_action == "roll" then
    --     print("ROLL: click to roll the dice")
    -- elseif self.current_action == "move" then
    --     print("MOVE: click on a checker to select it, then click on a valid point to move it")
    -- elseif self.current_action == "end_turn" then
    --     print("END TURN: click to end turn")
    -- end
end

-- roll_sprite = love.graphics.newImage("images/roll_brown.png")

function drawSprite(sprite, x, y)
    love.graphics.draw(sprite, x, y)
end

return Game