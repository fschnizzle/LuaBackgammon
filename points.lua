local Point = require("point")

local Points = {}
Points.__index = Points

function Points:new(game)
    if not game then
        error("Game object must be provided to Points!")
    end


    -- print("Game reference passed to Points:", game ~= nil) -- Should print "true"
    local obj = {
        points = {},
        game = game
    }
    setmetatable(obj, Points)
    obj:initializePoints()
    return obj
end

function Points:draw()
    -- Debug the Game object and current_action
    -- if not self.game then
    --     print("Error: Game object not set in Points.")
    -- elseif not self.game.current_action then
    --     print("Error: current_action is nil in Game.")
    -- else
    --     print("Game.current_action:", self.game.current_action)
    -- end

    -- Draw checkers
    self:drawCheckers()

    -- Highlight possible moves if applicable
    if self.game.current_action == "move" then
        self:showPossibleMoves()
    end
end

function Points:getPlayerDice()
    return self.game.dice[self.game.current_player]
end


function Points:highlightValidMoves(point)
    -- Highlight moves based on the current roll
    local playerDice = self:getPlayerDice()

    for _, roll in ipairs(playerDice.diceRolls) do
        local targetId = (self.game.current_player == "brown") and (point.id - roll) or (point.id + roll)
        if targetId >= 1 and targetId <= 24 then
            local targetPoint = self.points[targetId]

            if self.game:isValidMove(point, targetPoint, roll) then
                targetPoint:highlightPoint()
                targetPoint:pointDescription()
            end
        end
    end
end

-- function Points:showPossibleMoves()
--     -- Check if any checkers are on bar (25 for brown, 26 for white)
--     local bar = (self.game.current_player == "brown") and 25 or 26

--     if self.points[bar].count > 0 then
--         -- Check if any moves are possible for the current roll
--         local point = self.points[bar]
--         point:highlightPoint()
--     else
--         -- Check if any moves are possible for the current roll
--         for _, point in ipairs(self.points) do --TODO: check for and remove points that don't have any moves possible for that roll
--             if point.color == self.game.current_player then
--                 self:highlightValidMoves(point)
--             end
--         end
--     end
-- end

function Points:showPossibleMoves()
    -- If no point is selected, highlight points with the current players checkers
    if self.game.selectedPoint == nil then
        -- print(" pts.shPoMoves(): Highlighting points for", self.game.current_player)
        for _, point in ipairs(self.points) do
            if point.color == self.game.current_player and point.count > 0 then
                point:highlightPoint()
            end
        end
    else
        -- If a point is selected, highlight valid moves
        -- print("Highlighting valid moves for point:", self.game.selectedPoint.id)
        self:highlightValidMoves(self.game.selectedPoint)
    end
end

function Points:drawCheckers()
    for _, point in ipairs(self.points) do
        num_checkers = point.count
        if num_checkers > 0 then
            point:drawCheckers()
        end
    end
end

function Points:initializePoints()
    local spike_width = 50
    local spike_height = 180

    -- Initialize points 1 to 24
    for i = 1, 24 do
        local point = Point:new(i)
        local quadrant = math.ceil(i / 6)
        local position = (i - 1) % 6
        local startX, startY
    
        if quadrant == 1 then
            startX = 500
            startY = 599
            position = 5 - position -- Reverse the position within the quadrant
        elseif quadrant == 2 then
            startX = 150
            startY = 599
            position = 5 - position -- Reverse the position within the quadrant

        elseif quadrant == 3 then
            startX = 150
            startY = 101
        elseif quadrant == 4 then
            startX = 500
            startY = 101
        end
    
        local x1 = startX + spike_width * position
        local x2 = x1 + spike_width
        local y1 = startY
        local y2 = (quadrant <= 2) and (y1 - spike_height - 25) or (y1 + spike_height + 25)
    
        point.coordinates = {{x = x1, y = y1}, {x = x2, y = y1}, {x = x2, y = y2}, {x = x1, y = y2}}
        self.points[i] = point
    end

    -- Initialize special points 25 to 28
    for i = 25, 28 do
        local point = Point:new(i)
        point.type = i <= 26 and "bar" or "bearOff"
        -- TODO: Set proper coordinates for special points
        point.coordinates = {{x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}} -- Default placeholder
        self.points[i] = point
    end

    -- Set initial counts and colors for a standard backgammon setup
    self.points[1]:setCheckers(2, "white")
    self.points[6]:setCheckers(5, "brown")
    self.points[8]:setCheckers(3, "brown")
    self.points[12]:setCheckers(5, "white")
    self.points[13]:setCheckers(5, "brown")
    self.points[17]:setCheckers(3, "white")
    self.points[19]:setCheckers(5, "white")
    self.points[24]:setCheckers(2, "brown")

    for _, point in ipairs(self.points) do
        -- print(point.id, point.count, point.color, point.type)
    end
end


return Points