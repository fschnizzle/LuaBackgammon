local Point = require("point")

local Points = {}
Points.__index = Points

function Points:new()
    local obj = {
        points = {}
    }
    setmetatable(obj, Points)
    obj:initializePoints()
    return obj
end

function Points:draw()
    self:drawCheckers()
    if current_player ~= "none" and current_action == "move" then
        self:showPossibleMoves()
    end
    
end

function Points:showPossibleMoves()
    if current_action == "move" then 
        -- Check if any checkers are on bar (25 for brown, 26 for white)
        local bar = (current_player == "brown") and 25 or 26

        if self.points[bar].count > 0 then
            -- Check if any moves are possible for the current roll
            point = self.points[bar]
            point:highlightPoint()
        else
            -- Check if any moves are possible for the current roll
            for _, point in ipairs(self.points) do --TODO: check for and remove points that don't have any moves possible for that roll
                if point.color == current_player then
                    point:highlightPoint()
                end
            end
        end
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
        table.insert(self.points, point)
    end

    -- Initialize special points 25 to 28
    for i = 25, 26 do
        local point = Point:new(i)
        point.type = "bar"
        table.insert(self.points, point)
    end
    for i = 27, 28 do
        local point = Point:new(i)
        point.type = "bearOff"
        table.insert(self.points, point)
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
        print(point.id, point.count, point.color, point.type)
    end
end


return Points