
local items = {}
local itemSize = 0.1
local itemRemoveTimeRemaining = nil
local itemRemoveTime = 3.0
SwitchItemEnabledTime = nil
DizzyItemEnabledTime = nil
ServerAddBanana = nil
ServerRemoveBanana = nil
LocalBananas = {}

function loadItemImages()
    ItemTypes = {
        --[[{
            name = "mushroom",
            image = love.graphics.newImage("assets/items/mushroom.png"),
            action = function() 
                Car.vel.x = math.cos(Car.angle) * 15
                Car.vel.z = math.sin(Car.angle) * 15
            end
        },
        {
            name = "switch",
            image = love.graphics.newImage("assets/items/switch.png"),
            action = function() 
                SwitchItemEnabledTime = 2.0
            end
        },
        {
            name = "dizzy",
            image = love.graphics.newImage("assets/items/dizzy.png"),
            action = function() 
                DizzyItemEnabledTime = 5.0
            end
        },]]--
        {
            name = "banana",
            image = love.graphics.newImage("assets/items/banana.png"),
            action = makeBanana
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

function makeBanana()
    local x = Car.x + math.cos(Car.angle) * -0.7
    local z = Car.z + math.sin(Car.angle) * -0.7
    local y = heightAtPoint(x, z).height + 0.1
    ServerAddBanana = {x = x, y = y, z = z, id = "banana" .. math.floor(math.random() * 1000000)}
end

isSlipping = false
SlipTime = 0.0
local slipSpeed = 0.3
function slipBanana()
    if isSlipping then
        return
    end

    isSlipping = true
    SlipTime = 1.0
end

function updateBananas()
    for k,v in pairs(LocalBananas) do
        v.seen = false
    end

    if Bananas then
        for k,v in pairs(Bananas) do
            local id = v.id
            if LocalBananas[id] then
                LocalBananas[id].seen = true
            else
                addBanana(v)
            end

            local dist = math.sqrt(math.pow(v.x - Car.x, 2) + math.pow(v.z - Car.z, 2))
            if dist < 0.3 then
                slipBanana()
                ServerRemoveBanana = id
            end
        end
    end

    for k,v in pairs(LocalBananas) do
        if v.seen == false then
            for modelNum,model in pairs(v.models) do
                model.dead = true
            end

            LocalBananas[k] = nil
        end
    end
end

function addBanana(serverBanana)
    local color = {1.0, 1.0, 0.0, 1.0}
    local size = 0.1

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

    local models = {front, back, left, right}

    for k,v in pairs(models) do
        v:setTransform({serverBanana.x, serverBanana.y, serverBanana.z}, {0, cpml.vec3.unit_y})
    end

    LocalBananas[serverBanana.id] = {
        models = models,
        seen = true,
        x = serverBanana.x,
        z = serverBanana.z,
    }
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
                    MyItem = ItemTypes[math.floor(math.random() * #ItemTypes) + 1]
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