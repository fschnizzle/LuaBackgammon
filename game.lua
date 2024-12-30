local Board = require("board")
local Points = require("points")
local Dice = require("dice")

local Game = {}
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
        other_player = "white", -- Global variable
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
            if self.current_action == "roll" then
                self:checkRollButtonClick(mouseX, mouseY)
                return
            end

            if self.current_action == "move" then
                self:handleMoveClick(mouseX, mouseY)
            end
        end
    else
        mousePressed = false -- Reset the flag when the mouse button is released
    end
end

function Game:handleMoveClick(mouseX, mouseY)
    local barId = self:getBarPosition(self.current_player)
    local barPoint = self.points.points[barId]

    -- Default to the bar point if checkers are on the bar
    if self:playerHasCheckersOnBar() then
        self.selectedPoint = barPoint
        print("Auto-selected bar point for", self.current_player)
    end

    if self.selectedPoint then
        -- Attempt to move the selected checker
        self:attemptMove(mouseX, mouseY)
    else
        -- No bar checkers: Allow selection of checkers to move
        for _, point in ipairs(self.points.points) do
            if self:clickWithinBounds(mouseX, mouseY, point) 
               and point.color == self.current_player 
               and point.count > 0 then
                print("Selected point:", point.id)
                self.selectedPoint = point
                return
            end
        end
    end
end


function Game:clickWithinBounds(mouseX, mouseY, point)
    local bounds = point:getBounds()
    return mouseX >= bounds.xMin and mouseX <= bounds.xMax and mouseY >= bounds.yMin and mouseY <= bounds.yMax
end

function Game:attemptMove(mouseX, mouseY)
    for _, targetPoint in ipairs(self.points.points) do
        if self:clickWithinBounds(mouseX, mouseY, targetPoint) then
            -- Check for bar movement or normal movement
            local fromId = self.selectedPoint.id
            local toId = targetPoint.id

            if self:playerHasCheckersOnBar() and fromId ~= self:getBarPosition(self.current_player) then
                print("Must move checkers off the bar first!")
                return
            end

            self:moveChecker(fromId, toId)
            self.selectedPoint = nil -- Deselect after a move
            return
        end
    end
    print("No valid move target clicked.")
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
    local fromPoint = self.points.points[fromId]
    local toPoint = self.points.points[toId]
    local color = fromPoint.color

    local distance = (fromId == 26) and toId or (toId - fromId)
    if (color == "brown" and distance >= 0) or (color == "white" and fromId ~= 26 and distance <= 0) then
        print("Invalid move direction for player:", color)
        return
    end

    local absDistance = math.abs(distance)
    if not self:isValidMove(fromPoint, toPoint, absDistance) then
        print("Invalid move!")
        return
    end

    -- Handle blot hit
    local result = toPoint:addChecker(color)
    if result == "hit" then
        self:hitBlot(toPoint)
        toPoint.count = 1
        toPoint.color = color
    elseif result then
        -- Move without hitting a blot
        -- toPoint.count = toPoint.count + 1
        toPoint.color = color
    else
        print("Move failed!")
        return
    end

    -- Always consume the dice distance after a successful move
    self:consumeDice(absDistance)
    fromPoint:removeChecker()

    if #self.dice[self.current_player].diceRolls == 0 then
        self:endTurn()
    end
end


function Game:playerHasCheckersOnBar()
    local barId = self:getBarPosition(self.current_player)
    return self.points.points[barId].count > 0
end

function Game:hitBlot(point)
    local blotColor = point.color
    local barID = self:getBarPosition(blotColor)
    local barPoint = self.points.points[barID]

    print("Hitting blot! Moving", blotColor, "checker to bar", barId)
    barPoint:addChecker(blotColor) -- Move to bar
    point:removeChecker()          -- Remove from current position
end

function Game:getBarPosition(color)
    return (color == "brown") and 25 or 26
end

function Game:endTurn()
    self.current_action = "end_turn"

    -- Switch player
    self.other_player = self.current_player
    self.current_player = (self.current_player == "brown") and "white" or "brown"


    -- Reset for next turn
    self.dice[self.current_player].diceRolls = {}
    self.current_action = "roll"
end

-- Add in Game:isValidMove(fromPoint, toPoint, distance) validation function
function Game:isValidMove(fromPoint, toPoint, distance)
    local playerDice = self.dice[self.current_player]

    -- Ensure distance exists in dice rolls
    if not table.contains(playerDice.diceRolls, distance) then
        print("Invalid move: Distance", distance, "not in dice rolls")
        return false
    end

    -- Bar-specific logic
    local barPosition = self:getBarPosition(self.current_player)
    if fromPoint.id == barPosition then
        if self.current_player == "brown" then
            return toPoint.id == (25 - distance) and toPoint:canAddChecker(self.current_player)
        else
            return toPoint.id == distance and toPoint:canAddChecker(self.current_player)
        end
    end

    -- General move validation
    if fromPoint.color ~= self.current_player then
        print("Cannot move opponent's checkers.")
        return false
    end

    -- Check if destination point is valid
    if toPoint.color ~= "none" and toPoint.color ~= fromPoint.color then
        return toPoint.count == 1 -- Only allow hitting blots
    end

    return true
end


-- Helper function to check if a move to a point is valid
function Game:canMoveToPoint(toPoint)
    if toPoint.color == "none" or toPoint.color == self.current_player then
        return true -- Empty point or same-color checkers
    elseif toPoint.color ~= self.current_player and toPoint.count == 1 then
        return true -- Blot can be hit
    end
    return false -- Invalid move
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