-- _G.love = require(love)

function love.load()
    print("Backgammon.lua")
    love.graphics.setBackgroundColor(1, 1, 1) -- White background

    -- Checker
    checker = {
        x = 155, -- X position of the circle
        y = 122, -- Y position of the circle
        radius = 20,   -- Radius of the circle
        hovered = false, -- Hover state
        selected = false -- Selected state
    }
end

local isMousePressed = false

function love.draw()
    drawBackgammonBoard()
    drawSampleChecker(checker)

end

function love.update(dt)
    if love.mouse.isDown(1) then
        if not isMousePressed then
            isMousePressed = true
            if checker.selected then 
                checker.selected = false
            else
                local mouseX, mouseY = love.mouse.getPosition()
                local distance = math.sqrt((mouseX - checker.x)^2 + (mouseY - checker.y)^2)
                checker.selected = distance <= checker.radius
            end
        end
    else
        isMousePressed = false
    end

    if checker.selected then
        local mouseX, mouseY = love.mouse.getPosition()
        -- Move according to a grid of 50x40 squares
        checker.x = math.floor((mouseX) / 50) * 50 + 25
        -- Add 20 to checker.y if below the centre of the board
        local middle = love.graphics.getHeight() / 2
        if mouseY > middle then
            checker.y = math.floor((mouseY) / 40) * 40 + 20
        else
            checker.y = math.floor((mouseY + 20) / 40) * 40
        end

    end

end






function drawBackgammonBoard()

    local function drawBGrect()
        -- Board BG Rectangle
        love.graphics.setColor(1, 1, 1) -- White fill
        love.graphics.rectangle('fill', 100, 100, 750, 500)
        love.graphics.setColor(0, 0, 0) -- Black Outline 
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', 100, 100, 750, 500)
    end

    local function drawEdges()
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

    local function drawSpikes()
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

    -- SetUpBoard
    drawBGrect()
    drawEdges()
    drawSpikes()
    
end

function drawSampleChecker(checker)
    local i=0
    if checker.selected then
        love.graphics.setColor(0.82, 0.60, 0.25) -- White fill
    else
        love.graphics.setColor(0.92, 0.66, 0.32) -- White fill
    end
    
    love.graphics.circle('fill', checker.x, checker.y, 20)
    love.graphics.setColor(0.1, 0.1, 0.1) -- Black Outline 
    love.graphics.setLineWidth(2)
    love.graphics.circle('line', checker.x, checker.y, 20)
end