


function love.load()
    love.graphics.setBackgroundColor(255,255,255,255) --white background
end


function drawBackgammonBoard()
    -- Outer Edge
    love.graphics.setColor(0,0,0)
    love.graphics.setLineWidth(3)
    love.graphics.polygon('line', {100,100, 900,100, 900, 700, 100, 700})

    -- Inner Edges
    -- love.graphics.setColor(0,100, 0)
    love.graphics.setLineWidth(2)
    love.graphics.line(140, 100,140,700) --Left

    local midX1 = love.graphics.getWidth()/2 -20
    local midX2 = love.graphics.getWidth()/2 +20

    love.graphics.line(midX1,100, midX1,700) --Left
    love.graphics.line(midX2,100, midX2,700) --Left

    love.graphics.line(860, 100,860,700) --Right

    -- Spikes (Q1)
    local startX = 142
    local y_bottom=698
    local y_40p = y_bottom-235
    for i= 0,5,1 
    do
        local x1=startX+56*i
        local x2=x1+56

        if i%2==0 then
            love.graphics.setColor(0.8,0.8,0.8)
            
        else
            love.graphics.setColor(0.6,0.6,0.6)
        end
        love.graphics.polygon('fill', {x1,y_bottom, x2,y_bottom, (x1+x2)/2, y_40p})
    end 

    -- Spikes (Q2)
    local startX = 522
    for i= 0,5,1 
    do
        local x1=startX+56*i
        local x2=x1+56

        if i%2==0 then
            love.graphics.setColor(0.8,0.8,0.8)
            
        else
            love.graphics.setColor(0.6,0.6,0.6)
        end
        love.graphics.polygon('fill', {x1,y_bottom, x2,y_bottom, (x1+x2)/2, y_40p})
    end 





end


function love.draw()

    drawBackgammonBoard()

end
