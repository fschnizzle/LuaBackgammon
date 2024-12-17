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

function Point:canAddChecker(color)
    return self.color == "none" or self.color == color
end

function Point:addChecker(color)
    if self:canAddChecker(color) then
        -- Add checker to empty or same-color point
        self.count = self.count + 1
        self.color = color
        return true
    elseif self.count == 1 and self.color ~= color then
        -- Handle hitting a blot (single opponent checker)
        print("Blot hit! Moving opponent checker to bar.")
        return "hit" -- Signal to Game to handle the blot
    else
        print("FAILED: can't add", color, "checker to point", self.id, "of colour", self.color)
        return false
    end
end


function Point:removeChecker()
    if self.count > 0 then
        self.count = self.count - 1
        if self.count == 0 then
            self.color = "none"
        end
        return true
    else
        error("No checkers to remove")
        return false
    end
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

function Point:getBounds()
    local coords = self.coordinates
    return {
        xMin = math.min(coords[1].x, coords[2].x, coords[3].x, coords[4].x),
        xMax = math.max(coords[1].x, coords[2].x, coords[3].x, coords[4].x),
        yMin = math.min(coords[1].y, coords[2].y, coords[3].y, coords[4].y),
        yMax = math.max(coords[1].y, coords[2].y, coords[3].y, coords[4].y),
    }
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
    elseif self.id == 25 then
        -- Draw the bar checkers
        local x = 475
        local y = 150
        for i = 1, self.count do
            self:drawChecker(x, y, self.color)
            y = y + 50
        end
    elseif self.id == 26 then
        -- Draw the bear off checkers
        local x = 475
        local y = 550
        for i = 1, self.count do
            self:drawChecker(x, y, self.color)
            y = y - 50
        end
    end


end

function Point:highlightPoint()
    love.graphics.setColor(1, 1, 0, 0.4) -- Yellow shader
    love.graphics.polygon('fill', self.coordinates[1].x, self.coordinates[1].y, self.coordinates[2].x, self.coordinates[2].y, self.coordinates[3].x, self.coordinates[3].y, self.coordinates[4].x, self.coordinates[4].y)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color after drawing
end

function Point:pointDescription()
    print("ID:", self.id, "Count:", self.count, "Color:", self.color, "Type:", self.type)
end

return Point