require "items.bananas"
require "items.shells"

local items = {}
local itemSize = 0.1
local itemRemoveTimeRemaining = nil
local itemRemoveTime = 3.0
itemRadius = 0.4
SwitchItemEnabledTime = nil
DizzyItemEnabledTime = nil

-- bananas
ServerAddBanana = nil
ServerRemoveBanana = nil
LocalBananas = {}
bananaRadius = 0.4

-- shells
ServerAddShell = nil
LocalShells = {}

function loadItemImages()
    ItemTypes = {
        {
            name = "mushroom",
            image = love.graphics.newImage("assets/items/mushroom.png"),
            frequency = 10,
            action = function() 
                Car.vel.x = math.cos(Car.angle) * 15
                Car.vel.z = math.sin(Car.angle) * 15
            end
        },
        {
            name = "switch",
            image = love.graphics.newImage("assets/items/switch.png"),
            frequency = 2,
            action = function() 
                SwitchItemEnabledTime = 2.0
            end
        },
        {
            name = "dizzy",
            image = love.graphics.newImage("assets/items/dizzy.png"),
            frequency = 2,
            action = function() 
                DizzyItemEnabledTime = 5.0
            end
        },
        {
            name = "banana",
            image = love.graphics.newImage("assets/items/banana.png"),
            frequency = 10,
            action = makeBanana
        },
        {
            name = "redshell",
            image = love.graphics.newImage("assets/items/redshell.png"),
            frequency = 5,
            action = makeShell
        }
    }
end

function shouldSwitchScreen()
    if not SwitchItemUsers then
        return false
    end

    local count = 0
    for k,v in pairs(SwitchItemUsers) do
        count = count + 1
    end

    if count > 1 then
        return true
    end

    if count == 1 and not SwitchItemUsers[client.id] then
        return true
    end

    return false
end

function shouldDizzyScreen()
    if not DizzyItemUsers then
        return false
    end

    local count = 0
    for k,v in pairs(DizzyItemUsers) do
        count = count + 1
    end

    if count > 1 then
        return true
    end

    if count == 1 and not DizzyItemUsers[client.id] then
        return true
    end

    return false
end

AllTakenItems = {}

function clearItems()
    for itemIdx,item in pairs(items) do
        for k,v in pairs(item.models) do
            v.dead = true
        end
    end

    items = {}
end

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
    if SwitchItemEnabledTime then
        SwitchItemEnabledTime = SwitchItemEnabledTime - dt
        if SwitchItemEnabledTime < 0.0 then
            SwitchItemEnabledTime = nil
        end
    end

    if DizzyItemEnabledTime then
        DizzyItemEnabledTime = DizzyItemEnabledTime - dt
        if DizzyItemEnabledTime < 0.0 then
            DizzyItemEnabledTime = nil
        end
    end

    if SlipTime then
        SlipTime = SlipTime - dt
        if SlipTime < 0.0 then
            SlipTime = nil
            isSlipping = false
        end
    end

    updateBananas()
    updateShells(dt)

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
                if distance < itemRadius then
                    MyTakenItem = item.id
                    MyItem = randomItem()
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

function randomItem()
    local totalFrequency = 0
    for itemIdx,item in pairs(ItemTypes) do
        totalFrequency = totalFrequency + item.frequency
    end

    local rn = math.random() * totalFrequency
    local sum = 0

    for itemIdx,item in pairs(ItemTypes) do
        sum = sum + item.frequency
        if sum > rn then
            return item
        end
    end
end