local roadModels = nil

local imageFinishLine = love.graphics.newImage("assets/finish-line.png")
imageFinishLine:setWrap('repeat','repeat')

function makeRoad(imageRoad)
    if roadModels then
        for k,v in pairs(roadModels) do
            v.dead = true
        end
    end

    roadModels = {}

    local elev = 0.1

    local lastPoint = PATH_POINTS[#PATH_POINTS]
    local finishLineTexY = 0
    local finishLineTexInc = 1

    for k,v in pairs(PATH_POINTS) do
        local lx = lastPoint[1] * RoadScale - RoadScale / 2.0
        local ly = lastPoint[2] * RoadScale - RoadScale / 2.0
        local la = lastPoint[3]
        local ldx = math.cos(la + math.pi/2) * RoadRadius
        local ldy = math.sin(la + math.pi/2) * RoadRadius

        local x = v[1] * RoadScale - RoadScale / 2.0
        local y = v[2] * RoadScale - RoadScale / 2.0
        local a = v[3]
        local dx = math.cos(a + math.pi/2) * RoadRadius
        local dy = math.sin(a + math.pi/2) * RoadRadius

        local i = imageRoad
        local texCoordBegin = 0
        local texCoordEnd = 1
        if k > 1 and k < 4 then
            i = imageFinishLine
            texCoordBegin = finishLineTexY
            texCoordEnd = finishLineTexY + finishLineTexInc
            finishLineTexY = finishLineTexY + finishLineTexInc
        end

        --elev = elev + 0.05
        local model = rect({
            {lx - ldx, elev + heightAtPoint(lx - ldx, ly - ldy).height, ly - ldy,    0, texCoordBegin},
            {x - dx, elev + heightAtPoint(x - dx, y - dy).height, y - dy,   0,texCoordEnd},
            {x + dx, elev + heightAtPoint(x + dx, y + dy).height, y + dy,     1,texCoordEnd},
            {lx + ldx, elev + heightAtPoint(lx + ldx, ly + ldy).height, ly + ldy,    1,texCoordBegin}
        }, i)
        table.insert(roadModels, model)

        lastPoint = v
    end
end
