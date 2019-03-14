
function makeBanana()
    local x = Car.x + math.cos(Car.angle) * -0.7
    local z = Car.z + math.sin(Car.angle) * -0.7
    local y = heightAtPoint(x, z).height + 0.2
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

            local dist = math.sqrt(math.pow(v.x - Car.x, 2) + math.pow(v.z - Car.z, 2) + math.pow(v.y - Car.y, 2))
            if dist < bananaRadius then
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