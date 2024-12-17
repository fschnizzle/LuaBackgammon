local Board = require("board")
local Points = require("points")
local Dice = require("dice")

local Game = {}

-- current_player = "brown" -- or "brown", depending on the current player
-- current_action = "move" -- "roll" = must first click roll btn, "move" = has rolled and now needs to move using remaining dice

local mousePressed = false -- Tracks the mouse state

function Game:new()
    local obj = {
        board = Board:new(),
        points = nil,
        selectedPoint = nil,
        dice = {
            brown = Dice:new("brown"),
            white = Dice:new("white")
        },
        current_player = "brown", -- Global variable
        current_action = "roll",  -- Global variable
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
                    local bounds = point:getBounds()

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

function Game:draw()
    self.board:draw()
    self.points:draw()

    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.current_player .. " : " .. table.concat(self.dice[self.current_player].diceRolls, "  "), 10, 10)    -- print("Current player:", self.current_player)
    love.graphics.setColor(1, 1, 1)

    local playerDice = self.dice[self.current_player]

    -- HAS ROLLED
    if self.current_action == "move" then
        playerDice:draw()
    -- NEEDS TO ROLL
    elseif self.current_action == "roll" then -- Draw the roll button
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

function Game:rollDice()
    if self.current_action ~= "roll" then return end

    -- Roll dice for the current player
    local playerDice = self.dice[self.current_player]
    playerDice:roll()

    -- Transition to "move"
    self.current_action = "move"
end


function Game:checkRollButtonClick(mouseX, mouseY)
    local button = self.rollButton
    if mouseX >= button.x and mouseX <= button.x + button.width and mouseY >= button.y and mouseY <= button.y + button.height then
        self:rollDice()
    end
end

function Game:consumeDice(distance)
    local playerDice = self.dice[self.current_player]
    if not playerDice:consume(distance) then
        print("Invalid dice consumption!")
    end
end

function Game:moveChecker(fromId, toId)

    -- DEBUGGING: Print out all point descriptions
    for _, point in ipairs(self.points.points) do
        point:pointDescription()
    end


    local fromPoint = self.points.points[fromId]
    local toPoint = self.points.points[toId]
    local color = fromPoint.color

    -- Check if the move is valid (using dice roll logic etc)
    local distance = toId - fromId
    -- Ensure movement is valid for the player's color
    if (color == "brown" and distance >= 0) or (color == "white" and distance <= 0) then
        print("Invalid move direction for player:", color)
        return
    end

    local absDistance = math.abs(distance)
    if not self:isValidMove(fromPoint, toPoint, absDistance) then
        print("Invalid move!")
        return
    end

    -- Move the checker
    if toPoint:addChecker(color) then
        fromPoint:removeChecker()
        print("Moved checker from " .. fromId .. " to " .. toId)
        self:consumeDice(absDistance)
    else
        print("No checkers to move!")
    end

    -- Check if all dice have been consumed
    if #self.dice[self.current_player].diceRolls == 0 then
        self:endTurn()
    end
end

function Game:endTurn()
    self.current_action = "end_turn"

    -- Switch player
    self.current_player = (self.current_player == "brown") and "white" or "brown"

    -- Reset for next turn
    self.dice[self.current_player].diceRolls = {}
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
    -- local dice[self.current_player].diceRolls = {4,6} -- REPLACE WITH ACTUAL ROLLS LATER
    local playerDice = self.dice[self.current_player]
    return table.contains(playerDice.diceRolls, distance)
    
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

-- roll_sprite = love.graphics.newImage("images/roll_brown.png")

function drawSprite(sprite, x, y)
    love.graphics.draw(sprite, x, y)
end

return Game