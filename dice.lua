local Dice = {}
Dice.__index = Dice

function Dice:new(spritePath)
    local obj = {
        rolls = {}, -- Store the dice roll values
        sprite = love.graphics.newImage(spritePath),
        faceWidth = 40,
        y = love.graphics.getHeight() / 2 - 30/2, -- Vertically centered
        x = 750, -- Position on the screen
    }
    setmetatable(obj, self)
    return obj
end

function Dice:rollDice()
    -- if self.current_action ~= "roll" then return end -- Only roll dice in the "roll" state

    -- Example dice roll logic (replace with actual random rolls later)
    self.rolls = {math.random(1, 6), math.random(1, 6)}
    print(self.current_player, "rolled:", table.concat(self.diceRolls, ", "))

    -- Transition to "move"
    self.current_action = "move"
end