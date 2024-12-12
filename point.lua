local Point = {}
Point.__index = Point

function Point:new(id)
    local obj = {
        id = id,
        count = 0,
        color = "none",
        type = (id <= 24) and "point" or "special",
        coordinates = {{x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}}
    }
    setmetatable(obj, self)
    return obj
end

function Point:setCheckers(count, color)
    if count > 0 and count <= 15 then
        self.count = count
        self.color = color
    elseif count == 0 then
        self:clear()
    else
        error("Invalid number of checkers")
    end
    return self
end

function Point:clear()
    self.count = 0
    self.color = "none"
end

function Point:drawChecker(x, y)
    -- Draw a circle of radius 20
    if self.color == "white" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle('fill', x, y, 20)
    elseif self.color == "brown" then
        love.graphics.setColor(0.82, 0.60, 0.25)
        love.graphics.circle('fill', x, y, 20)
    end

    -- Outline
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle('line', x, y, 20)
end

function Point:drawCheckers()
    -- Draw circles of radius 20 for each checker, 
    -- Get the starting checker's coordinates:
    -- x = middle of the point
    -- y = 20 from the top of the point for top quadrants (13 <= id <= 24)
    -- y = 20 from the bottom of the point for bottom quadrants(1 <= id <= 12)
    -- ie: y = 121 or 579

    local x = (self.coordinates[1].x + self.coordinates[2].x) / 2
    if self.id <= 12 then
        local y = 579
        for i = 1, self.count do
            self:drawChecker(x, y, self.color)
            y = y - 40
        end
    elseif self.id <= 24 then
        local y = 121
        for i = 1, self.count do
            self:drawChecker(x, y, self.color)
            y = y + 40
        end
    -- elseif -- FOR THE SPECIAL POINTS
    end


end

function Point:highlightPoint()
    love.graphics.setColor(1, 1, 0, 0.4) -- Yellow shader
    love.graphics.polygon('fill', self.coordinates[1].x, self.coordinates[1].y, self.coordinates[2].x, self.coordinates[2].y, self.coordinates[3].x, self.coordinates[3].y, self.coordinates[4].x, self.coordinates[4].y)
end

return Point