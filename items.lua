
local items = {}
local itemSize = 0.1
local itemRemoveTimeRemaining = nil
local itemRemoveTime = 3.0

MyItem = nil
MyTakenItem = nil
AllTakenItems = {}

function makeItems(roadIdx)
    local a = PATH_POINTS[roadIdx][3]
    local dx = math.cos(a + math.pi/2) * 0.7
    local dy = math.sin(a + math.pi/2) * 0.7
    makeItem(roadIdx, -dx, -dy, roadIdx .. "-" .. 0)
    makeItem(roadIdx, 0, 0, roadIdx .. "-" .. 1)
    makeItem(roadIdx, dx, dy, roadIdx .. "-" .. 2)
end

function makeItem(roadIdx, dx, dy, id)
    local item = {
        id = id,
        rotation = 0,
    }

    local color = {1.0, 0.0, 0.0, 0.5}
    local size = itemSize
    local x = (PATH_POINTS[roadIdx][1] * RoadScale - RoadScale / 2.0) + dx
    local z = (PATH_POINTS[roadIdx][2] * RoadScale - RoadScale / 2.0) + dy
    local y = heightAtPoint(x, z).height + 0.3

    item.x = x
    item.y = y
    item.z = z

    local front = rectColor({
        {-1, -1, 1,   0,0},
        {-1, 1, 1,    0,1},
        {1, 1, 1,     1,1},
        {1, -1, 1,    1,0}
    }, color, size)

    local back = rectColor({
        {-1, -1, -1,  0,0},
        {-1, 1, -1,   0,1},
        {1, 1, -1,    1,1},
        {1, -1, -1,   1,0}
    }, color, size)

    local left = rectColor({
        {-1, -1, 1,   0,0},
        {-1, 1, 1,    0,1},
        {-1, 1, -1,   1,1},
        {-1, -1, -1,   1,0}
    }, color, size)

    local right = rectColor({
        {1, -1, 1,    0,0},
        {1, 1, 1,     0,1},
        {1, 1, -1,    1, 1},
        {1, -1, -1,   1,0}
    }, color, size)

    item.models = {front, back, left, right}

    for k,v in pairs(item.models) do
        v:setTransform({x, y, z}, {0, cpml.vec3.unit_y})
    end

    table.insert(items, item)
end

function updateItems(dt)
    if MyTakenItem then
        itemRemoveTimeRemaining = itemRemoveTimeRemaining - dt
        if itemRemoveTimeRemaining < 0 then
            MyTakenItem = nil
            itemRemoveTimeRemaining = nil
        end
    end

    for itemIdx,item in pairs(items) do
        item.rotation = item.rotation + dt
        local dy = 0
        if AllTakenItems[item.id] == true then
            dy = -10
        else
            if not MyTakenItem and not MyItem then
                local distance = math.sqrt(math.pow(item.x - Car.x, 2) + math.pow(item.z - Car.z, 2))
                if distance < 0.3 then
                    MyTakenItem = item.id
                    MyItem = item
                    itemRemoveTimeRemaining = itemRemoveTime
                    -- TODO add to AllTakenItems
                end
            end
        end

        for k,v in pairs(item.models) do
            v:setTransform({item.x, item.y + dy, item.z}, {item.rotation, cpml.vec3.unit_y})
        end
    end
end