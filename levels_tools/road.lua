local roadModels = nil
local roadTriangles = {}
local fakeRoadTriangles = {}
local ROAD_EXTRA_ELEV = 0.1

function ptInTriangle2d(p, p0, p1, p2)
    local A = 1/2 * (-p1.z * p2.x + p0.z * (-p1.x + p2.x) + p0.x * (p1.z - p2.z) + p1.x * p2.z)
    local sign
    if A < 0 then
        sign = -1
    else
        sign = 1
    end

    local s = (p0.z * p2.x - p0.x * p2.z + (p2.z - p0.z) * p.x + (p0.x - p2.x) * p.z) * sign
    local t = (p0.x * p1.z - p0.z * p1.x + (p0.z - p1.z) * p.x + (p1.x - p0.x) * p.z) * sign
    
    return s > 0 and t > 0 and (s + t) < 2 * A * sign
end

function roadHeightAtPoint(x, z, indexHint, useFakeHeight)
    local DIST_TO_CHECK = 10
    for idx = indexHint - DIST_TO_CHECK, indexHint + DIST_TO_CHECK do
        local realIdx = idx
        if realIdx <= 0 then
            realIdx = realIdx + #PATH_POINTS
        end
        if realIdx > #PATH_POINTS then
            realIdx = realIdx - #PATH_POINTS
        end

        local tris = roadTriangles
        if useFakeHeight then
            tris = fakeRoadTriangles
        end

        if tris[realIdx] then
            for _,triangle in pairs(tris[realIdx]) do
                local p = {
                    x = x,
                    z = z,
                }
                local t1 = {
                    x = triangle[1][1],
                    y = triangle[1][2],
                    z = triangle[1][3]
                }
                local t2 = {
                    x = triangle[2][1],
                    y = triangle[2][2],
                    z = triangle[2][3]
                }
                local t3 = {
                    x = triangle[3][1],
                    y = triangle[3][2],
                    z = triangle[3][3]
                }

                if ptInTriangle2d(p, t1, t2, t3) then
                    local normal = normalizeVec(crossVec(minusVec(t2, t1), minusVec(t3, t1)))
                
                    local intersection = lineIntersection(
                        t1,
                        normal,
                        {x = x, y = 0, z = z},
                        {x = 0, y = 1, z = 0}
                    )

                    -- let heightAtPoint take care of this if not
                    if intersection.y - ROAD_EXTRA_ELEV ~= 0.0 then
                        return {
                            height = intersection.y - ROAD_EXTRA_ELEV,
                            normal = normal
                        }
                    end
                end
            end
        end
    end

    return heightAtPoint(x, z)
end

function updatePathPoints()
    for k,v in pairs(PATH_POINTS) do
        v[4] = 0.0
        -- 5 is "Fake height" used for shells and for car roadindex calculations
        v[5] = 0.0
    end
end

function makeJump(index, length, height)
    if not length then
        length = 5.0
    end

    if not height then
        height = 2.0
    end

    local currHeight = 0.0
    local heightInc = height / length

    for idx = index, index + length do
        currHeight = currHeight + heightInc

        PATH_POINTS[idx][4] = currHeight
        PATH_POINTS[idx][5] = currHeight
    end

    for idx = index + length - 1, index + length*2 - 1 do
        currHeight = currHeight - heightInc

        PATH_POINTS[idx][4] = currHeight
        PATH_POINTS[idx][5] = currHeight
    end
end

function makeEmptyJump(index, length, height, emptyLength, downAmt)
    if not length then
        length = 5.0
    end

    if not height then
        height = 2.0
    end

    if not emptyLength then
        emptyLength = 5.0
    end

    if not downAmt then
        downAmt = -0.7
    end

    local currHeight = 0.0
    local heightInc = height / length
    local currIdx

    for idx = index, index + length do
        currHeight = currHeight + heightInc

        PATH_POINTS[idx][4] = currHeight
        PATH_POINTS[idx][5] = currHeight
        currIdx = idx
    end

    for idx = currIdx, currIdx + emptyLength do
        PATH_POINTS[idx][4] = -10000
        PATH_POINTS[idx][5] = currHeight
        currIdx = idx
    end

    currHeight = currHeight + downAmt
    for idx = currIdx, currIdx + length do
        currHeight = currHeight - heightInc

        PATH_POINTS[idx][4] = currHeight
        PATH_POINTS[idx][5] = currHeight
        currIdx = idx
    end
end

function makeTabletopJump(index, length, height, topLength)
    if not length then
        length = 5.0
    end

    if not height then
        height = 2.0
    end

    if not topLength then
        topLength = 5.0
    end

    local currHeight = 0.0
    local heightInc = height / length
    local currIdx

    for idx = index, index + length do
        currHeight = currHeight + heightInc

        PATH_POINTS[idx][4] = currHeight
        PATH_POINTS[idx][5] = currHeight
        currIdx = idx
    end

    for idx = currIdx, currIdx + topLength do
        PATH_POINTS[idx][4] = currHeight
        PATH_POINTS[idx][5] = currHeight
        currIdx = idx
    end

    for idx = currIdx, currIdx + length do
        currHeight = currHeight - heightInc

        PATH_POINTS[idx][4] = currHeight
        PATH_POINTS[idx][5] = currHeight
        currIdx = idx
    end
end

function makeRoad(imageRoad, imageWall)
    if roadModels then
        for k,v in pairs(roadModels) do
            v.dead = true
        end
    end

    roadModels = {}

    local elev = ROAD_EXTRA_ELEV

    local lastPoint = PATH_POINTS[#PATH_POINTS]
    local finishLineTexY = 0
    local finishLineTexInc = 1
    local currTexCoord = 0.0
    local texCoordInc = 0.1

    local allRoadVerts = {}
    local allWallVerts = {}

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

        local texCoordBegin = 0
        local texCoordEnd = 1
        local isFinishLine = false
        if k > 1 and k < 4 then
            isFinishLine = true
            texCoordBegin = finishLineTexY
            texCoordEnd = finishLineTexY + finishLineTexInc
            finishLineTexY = finishLineTexY + finishLineTexInc
        end

        local h1 = heightAtPoint(lx - ldx, ly - ldy).height
        local h2 = heightAtPoint(x - dx, y - dy).height
        local h3 = heightAtPoint(x + dx, y + dy).height
        local h4 = heightAtPoint(lx + ldx, ly + ldy).height

        local minHeightLast = math.min(h1, h4) + lastPoint[4]
        local minHeightCurrent = math.min(h2, h3) + v[4]

        local verts = {
            {lx - ldx, elev + math.max(h1, minHeightLast), ly - ldy,    0, texCoordBegin},
            {x - dx, elev + math.max(h2, minHeightCurrent), y - dy,   0,texCoordEnd},
            {x + dx, elev + math.max(h3, minHeightCurrent), y + dy,     1,texCoordEnd},
            {lx + ldx, elev + math.max(h4, minHeightLast), ly + ldy,    1,texCoordBegin}
        }

        local fakeMinHeightLast = math.min(h1, h4) + lastPoint[5]
        local fakeMinHeightCurrent = math.min(h2, h3) + v[5]

        local fakeVerts = {
            {lx - ldx, elev + math.max(h1, fakeMinHeightLast), ly - ldy,    0, texCoordBegin},
            {x - dx, elev + math.max(h2, fakeMinHeightCurrent), y - dy,   0,texCoordEnd},
            {x + dx, elev + math.max(h3, fakeMinHeightCurrent), y + dy,     1,texCoordEnd},
            {lx + ldx, elev + math.max(h4, fakeMinHeightLast), ly + ldy,    1,texCoordBegin}
        }

        if not CASTLE_SERVER and lastPoint[4] > -100 and v[4] > -100 then
            if isFinishLine then
                local model = rect(verts, imageFinishLine)
                table.insert(roadModels, model)
            else
                addRectVerts(allRoadVerts, verts)
            end

            if imageWall then
                addRectVerts(allWallVerts, {
                    {verts[1][1], verts[1][2], verts[1][3], currTexCoord, verts[1][2] + 5},-- last
                    {verts[2][1], verts[2][2], verts[2][3], currTexCoord + texCoordInc, verts[2][2] + 5},
                    {verts[2][1], -5, verts[2][3],   currTexCoord + texCoordInc, 0},
                    {verts[1][1], -5, verts[1][3],   currTexCoord, 0},-- last
                })

                addRectVerts(allWallVerts, {
                    {verts[3][1], verts[3][2], verts[3][3], currTexCoord, verts[3][2] + 5},-- last
                    {verts[4][1], verts[4][2], verts[4][3], currTexCoord + texCoordInc, verts[4][2] + 5},
                    {verts[4][1], -5, verts[4][3],   currTexCoord + texCoordInc, 0},
                    {verts[3][1], -5, verts[3][3],   currTexCoord, 0},-- last
                })

                addRectVerts(allWallVerts, {
                    {verts[1][1], verts[1][2], verts[1][3], 0, verts[1][2] + 5},-- last
                    {verts[4][1], verts[4][2], verts[4][3], RoadRadius * 2, verts[4][2] + 5},
                    {verts[4][1], -5, verts[4][3],   RoadRadius * 2, 0},
                    {verts[1][1], -5, verts[1][3],   0, 0},-- last
                })

                addRectVerts(allWallVerts, {
                    {verts[3][1], verts[3][2], verts[3][3], 0, verts[3][2] + 5},-- last
                    {verts[2][1], verts[2][2], verts[2][3], RoadRadius * 2, verts[2][2] + 5},
                    {verts[2][1], -5, verts[2][3],   RoadRadius * 2, 0},
                    {verts[3][1], -5, verts[3][3],   0, 0},-- last
                })
            end
        end

        roadTriangles[k] = {
            {verts[1], verts[2], verts[4]},
            {verts[2], verts[3], verts[4]}
        }

        fakeRoadTriangles[k] = {
            {fakeVerts[1], fakeVerts[2], fakeVerts[4]},
            {fakeVerts[2], fakeVerts[3], fakeVerts[4]}
        }

        lastPoint = v
        currTexCoord = currTexCoord + texCoordInc
    end

    if not CASTLE_SERVER then
        local model = modelFromCoords(allRoadVerts, imageRoad)
        table.insert(roadModels, model)

        if imageWall then
            model = modelFromCoords(allWallVerts, imageWall)
            table.insert(roadModels, model)
        end
    end
end
