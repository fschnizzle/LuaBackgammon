local Board = {}

function Board:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Board:draw()

    -- Background Rectangle
    self:drawBG()
    
    -- Edges (Left, Right, Middle)
    self:drawEdges()

    -- Spikes (1-24)
    self:drawSpikes()
    
end


function Board:drawBG()
    -- Board BG Rectangle
    love.graphics.setColor(1, 1, 1) -- White fill
    love.graphics.rectangle('fill', 100, 100, 750, 500)
    love.graphics.setColor(0, 0, 0) -- Black Outline 
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', 100, 100, 750, 500)
end

function Board:drawEdges()
    --- Edges

    -- LEFT EDGE
    love.graphics.setColor(0.3, 0.3, 0.3) -- Grey Fill
    love.graphics.rectangle('fill', 100, 100, 48, 500)
    love.graphics.setColor(0, 0, 0) -- Black Outlines
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', 100, 100, 48, 500)

    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', 100, 300, 48, 100)

    -- RIGH EDGE
    local rightEdgeXDelta = 702
    love.graphics.setColor(0.3, 0.3, 0.3) -- Grey Fill
    love.graphics.rectangle('fill', 100 + rightEdgeXDelta, 100, 48, 500)
    love.graphics.setColor(0, 0, 0) -- Black Outlines
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', 100  + rightEdgeXDelta, 100, 48, 500)

    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', 100  + rightEdgeXDelta, 300, 48, 100)

    -- MIDDLE EDGE
    local middleEdgeXDelta = 352
    love.graphics.setColor(0.3, 0.3, 0.3) -- Grey Fill
    love.graphics.rectangle('fill', 100 + middleEdgeXDelta, 100, 46, 500)
    love.graphics.setColor(0, 0, 0) -- Black Outlines
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', 100  + middleEdgeXDelta, 100, 46, 500)
end

function Board:drawSpikes()
    local spike_width = 50
    local spike_height = 180

    -- Bottom Spikes (Q1, Q2)
    for quadrant = 1, 2 do
        local startX = (quadrant == 1) and 150 or 500
        for i = 0, 5 do
            local x1 = startX + spike_width * i
            local x2 = x1 + spike_width
            local y1 = 599
            local y2 = y1 - spike_height
            love.graphics.setColor(i % 2 == 0 and 0.8 or 0.6, 0.8, 0.8) -- Alternate spike color
            love.graphics.polygon('fill', {x1, y1, x2, y1, (x1 + x2) / 2, y2})
        end
    end

    -- Top Spikes (Q3, Q4)
    for quadrant = 3, 4 do
        local startX = (quadrant == 3) and 150 or 500
        for i = 0, 5 do
            local x1 = startX + spike_width * i
            local x2 = x1 + spike_width
            local y1 = 101
            local y2 = y1 + spike_height
            love.graphics.setColor((i+1) % 2 == 0 and 0.8 or 0.6, 0.8, 0.8) -- Alternate spike color
            love.graphics.polygon('fill', {x1, y1, x2, y1, (x1 + x2) / 2, y2})
        end
    end
end


return Board