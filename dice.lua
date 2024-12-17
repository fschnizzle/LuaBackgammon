local Dice = {}
Dice.__index = Dice

function Dice:new(playerColor)
    local obj = {
        diceRolls = {}, -- Store the dice roll values
        spritesheet = love.graphics.newImage("images/" .. playerColor .. "DiceSpritesheet4x.png"), -- Spritesheet: dice_brown.png or dice_white.png
        spriteWidth = 160,
        spriteHeight = 160,
        playerColor = playerColor,
        y = love.graphics.getHeight() / 2 - 30/2, -- Vertically centered
        x = (playerColor == "brown") and 250 or 600, -- Position on the screen
        
    }
    setmetatable(obj, self)

    -- Scale factor
    obj.scaleX = 40 / obj.spriteWidth
    obj.scaleY = 40 / obj.spriteHeight

    -- Create Spritesheet quads
    obj.quads = {}
    for i = 0, 5 do
        obj.quads[i] = love.graphics.newQuad(i * obj.spriteWidth, 0, obj.spriteWidth, obj.spriteHeight, obj.spritesheet:getDimensions())
    end

    return obj
end

function Dice:roll()
    -- if self.current_action ~= "roll" then return end -- Only roll dice in the "roll" state

    -- Example dice roll logic (replace with actual random rolls later)
    self.diceRolls = {math.random(1, 6), math.random(1, 6)}
    print(self.playerColor, "rolled:", table.concat(self.diceRolls, ", "))

    return self.diceRolls
end

function Dice:draw()
    for i, value in ipairs(self.diceRolls) do
        love.graphics.draw(self.spritesheet, self.quads[value - 1], self.x + (i - 1) * 60, self.y, 0, self.scaleX, self.scaleY)
    end
end

function Dice:consume(distance)
    for i, roll in ipairs(self.diceRolls) do
        if roll == distance then
            table.remove(self.diceRolls, i)
            return true
        end
    end
    return false
end

return Dice