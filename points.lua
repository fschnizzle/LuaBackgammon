local Point = require("point")

local Points = {}
Points.__index = Points

function Points:new(game)
    if not game then
        error("Game object must be provided to Points!")
    end

    local obj = {
        points = {},
        game = game
    }
    setmetatable(obj, Points)
    obj:initializePoints()
    return obj
end

function Points:draw()
    self:drawCheckers()

    -- Highlight actions during the "move" phase
    if self.game.current_action == "move" then
        self:highlightActions()
    end
end

-- Main highlighting function
function Points:highlightActions()
    local barId = self.game:getBarPosition(self.game.current_player)
    local barPoint = self.points[barId]

    if barPoint.count > 0 then
        -- Checkers on bar must move first
        self:highlightBarMoves(barPoint)
    elseif self.game.selectedPoint then
        -- Highlight moves for a selected checker
        self:highlightValidMoves(self.game.selectedPoint)
    else
        -- Highlight checkers that can be selected
        self:highlightCheckers()
    end
end

-- Highlight valid moves for a checker on the bar
function Points:highlightBarMoves(barPoint)
    local playerDice = self:getPlayerDice()
    for _, roll in ipairs(playerDice.diceRolls) do
        local targetId = self:getBarTargetId(roll)
        if targetId >= 1 and targetId <= 24 then
            local targetPoint = self.points[targetId]
            if self.game:isValidMove(barPoint, targetPoint, roll) then
                targetPoint:highlightPoint()
            end
        end
    end
end

-- Highlight checkers that can be selected
function Points:highlightCheckers()
    for _, point in ipairs(self.points) do
        if point.color == self.game.current_player and point.count > 0 then
            point:highlightPoint()
        end
    end
end

-- Highlight valid moves for a selected checker
function Points:highlightValidMoves(selectedPoint)
    local playerDice = self:getPlayerDice()
    for _, roll in ipairs(playerDice.diceRolls) do
        local targetId = self:getTargetId(selectedPoint.id, roll)
        if targetId >= 1 and targetId <= 24 then
            local targetPoint = self.points[targetId]
            if self.game:isValidMove(selectedPoint, targetPoint, roll) then
                targetPoint:highlightPoint()
            end
        end
    end
end

-- Get target ID for bar moves
function Points:getBarTargetId(roll)
    return (self.game.current_player == "brown") and (25 - roll) or roll
end

-- Get target ID for standard moves
function Points:getTargetId(pointId, roll)
    return (self.game.current_player == "brown") and (pointId - roll) or (pointId + roll)
end

function Points:getPlayerDice()
    return self.game.dice[self.game.current_player]
end

function Points:drawCheckers()
    for _, point in ipairs(self.points) do
        if point.count > 0 then
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
        local startX = (quadrant == 1 or quadrant == 4) and 500 or 150
        local startY = (quadrant <= 2) and 599 or 101
        if quadrant <= 2 then position = 5 - position end -- Reverse position for bottom quadrants

        local x1 = startX + spike_width * position
        local x2 = x1 + spike_width
        local y1 = startY
        local y2 = (quadrant <= 2) and (y1 - spike_height - 25) or (y1 + spike_height + 25)

        point.coordinates = {{x = x1, y = y1}, {x = x2, y = y1}, {x = x2, y = y2}, {x = x1, y = y2}}
        self.points[i] = point
    end

    -- Initialize special points (bar positions)
    for i = 25, 26 do
        local point = Point:new(i)
        point.type = i <= 26 and "bar" or "bearOff"
        -- TODO: Set proper coordinates for special points
        if i == 25 then
            point.coordinates = {{x = 450, y = 0}, {x = 500, y = 0}, {x = 500, y = 300}, {x = 450, y = 300}} -- Mid bottom
        elseif i == 26 then
            point.coordinates = {{x = 450, y = 300}, {x = 500, y = 300}, {x = 500, y = 500}, {x = 450, y = 500}} -- Mid top
        else
            point.coordinates = {{x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}} -- Default placeholder
        end
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
    self.points[21]:setCheckers(1, "white")
    self.points[22]:setCheckers(1, "white")
    self.points[23]:setCheckers(1, "white")
    self.points[24]:setCheckers(2, "brown")
end

return Points
