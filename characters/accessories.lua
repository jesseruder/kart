function accessoryNone(car)
    --[[local coords = {}

    for k1,face in pairs(hatObject.f) do
        if #face == 3 then
            local v1 = hatObject.v[face[1][1] ]
            local v2 = hatObject.v[face[2][1] ]
        elseif #face == 4 then

        end
    end

    local model = Engine.newModel(coords, texture, nil, nil, nil, scale, fogAmount)
    table.insert(Scene.modelList, model)
    table.insert(car.models, model)]]--
end

function accessoryHat(car)
    local hatTopHeight = 1.8
    local hatBottomHeight = 0.9
    local hatBrimSize = 1.2
    local color = car.color

    local model = modelFromCoordsColor({
        {-hatBrimSize, hatBottomHeight, hatBrimSize},
        {hatBrimSize, hatBottomHeight, hatBrimSize},
        {0, hatTopHeight, 0},

        {-hatBrimSize, hatBottomHeight, -hatBrimSize},
        {hatBrimSize, hatBottomHeight, -hatBrimSize},
        {0, hatTopHeight, 0},

        {-hatBrimSize, hatBottomHeight, hatBrimSize},
        {-hatBrimSize, hatBottomHeight, -hatBrimSize},
        {0, hatTopHeight, 0},

        {hatBrimSize, hatBottomHeight, hatBrimSize},
        {hatBrimSize, hatBottomHeight, -hatBrimSize},
        {0, hatTopHeight, 0}
    }, color, Car.size)
    table.insert(car.models, model)
end

function accessoryContacts(car)
    local eyeSize = 0.4
    local eyeDistFromSide = 0.25
    local eyeDistFromTop = 0.6

    local pupilSize = 0.25
    local pupilDistFromSide = eyeDistFromSide + (eyeSize - pupilSize) * 0.5
    local pupilDistFromTop = eyeDistFromTop + (eyeSize - pupilSize) * 0.5
    local color = car.color

    local whiteVerts = {}
    local colorVerts = {}

    addRectVerts(whiteVerts, {
        {1.02, 1 - eyeDistFromTop - eyeSize, 1 - eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, 1 - eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, 1 - eyeDistFromSide - eyeSize},
        {1.02, 1 - eyeDistFromTop - eyeSize, 1 - eyeDistFromSide - eyeSize}
    })

    addRectVerts(colorVerts, {
        {1.04, 1 - pupilDistFromTop - pupilSize, 1 - pupilDistFromSide},
        {1.04, 1 - pupilDistFromTop, 1 - pupilDistFromSide},
        {1.04, 1 - pupilDistFromTop, 1 - pupilDistFromSide - pupilSize},
        {1.04, 1 - pupilDistFromTop - pupilSize, 1 - pupilDistFromSide - pupilSize}
    })

    addRectVerts(whiteVerts, {
        {1.02, 1 - eyeDistFromTop - eyeSize, -1 + eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, -1 + eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, -1 + eyeDistFromSide + eyeSize},
        {1.02, 1 - eyeDistFromTop - eyeSize, -1 + eyeDistFromSide + eyeSize}
    })

    addRectVerts(colorVerts, {
        {1.04, 1 - pupilDistFromTop - pupilSize, -1 + pupilDistFromSide},
        {1.04, 1 - pupilDistFromTop, -1 + pupilDistFromSide},
        {1.04, 1 - pupilDistFromTop, -1 + pupilDistFromSide + pupilSize},
        {1.04, 1 - pupilDistFromTop - pupilSize, -1 + pupilDistFromSide + pupilSize}
    })

    local whiteModel = modelFromCoordsColor(whiteVerts, {1,1,1,1}, Car.size)
    local colorModel = modelFromCoordsColor(colorVerts, color, Car.size)

    table.insert(car.models, whiteModel)
    table.insert(car.models, colorModel)
end

function accessoryGlasses(car)
    local eyeSize = 0.6
    local eyeDistFromSide = 0.1
    local eyeDistFromTop = 0.4
    local bandSize = 0.1

    local pupilSize = 0.25
    local pupilDistFromSide = eyeDistFromSide + (eyeSize - pupilSize) * 0.5
    local pupilDistFromTop = eyeDistFromTop + (eyeSize - pupilSize) * 0.5
    local color = car.color

    local verts= {}

    addRectVerts(verts, {
        {1.02, 1 - eyeDistFromTop - eyeSize, 1 - eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, 1 - eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, 1 - eyeDistFromSide - eyeSize},
        {1.02, 1 - eyeDistFromTop - eyeSize, 1 - eyeDistFromSide - eyeSize}
    })

    addRectVerts(verts, {
        {1.02, 1 - eyeDistFromTop - eyeSize, -1 + eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, -1 + eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, -1 + eyeDistFromSide + eyeSize},
        {1.02, 1 - eyeDistFromTop - eyeSize, -1 + eyeDistFromSide + eyeSize}
    })

    local bandTop = 1 - eyeDistFromTop - eyeSize * 0.5 - bandSize * 0.5
    local bandBottom = 1 - eyeDistFromTop - eyeSize * 0.5 + bandSize * 0.5
    addRectVerts(verts, {
        {1.02, bandTop, -1.02},
        {1.02, bandBottom, -1.02},
        {1.02, bandBottom, 1.02},
        {1.02, bandTop, 1.02}
    })

    addRectVerts(verts, {
        {-1, bandTop, -1.02},
        {-1, bandBottom, -1.02},
        {1.02, bandBottom, -1.02},
        {1.02, bandTop, -1.02}
    })

    addRectVerts(verts, {
        {-1, bandTop, 1.02},
        {-1, bandBottom, 1.02},
        {1.02, bandBottom, 1.02},
        {1.02, bandTop, 1.02}
    })

    local model = modelFromCoordsColor(verts, color, Car.size)
    table.insert(car.models, model)
end

function accessoryWitchHat(car)
    local height = 2.0
    local bottomWidth = 1.7
    local width = 0.7
    local color = car.color

    local verts = {}
    local angle = 0.0
    while angle <= math.pi *2 do
        local nextAngle = angle + 0.7

        table.insert(verts, {0,1.02,0})
        table.insert(verts, {math.cos(angle) * bottomWidth, 1.02, math.sin(angle) * bottomWidth})
        table.insert(verts, {math.cos(nextAngle) * bottomWidth, 1.02, math.sin(nextAngle) * bottomWidth})

        angle = nextAngle
    end

    angle = 0.0
    while angle <= math.pi *2 do
        local nextAngle = angle + 0.7

        table.insert(verts, {0,1 + height,0})
        table.insert(verts, {math.cos(angle) * width, 1.02, math.sin(angle) * width})
        table.insert(verts, {math.cos(nextAngle) * width, 1.02, math.sin(nextAngle) * width})

        angle = nextAngle
    end

    local model = modelFromCoordsColor(verts, color, Car.size)
    table.insert(car.models, model)
end

function accessoryTopHat(car)
    local height = 2.0
    local bottomWidth = 1.6
    local width = 0.7
    local color = car.color

    local verts = {}
    local angle = 0.0
    while angle <= math.pi *2 do
        local nextAngle = angle + 0.7

        table.insert(verts, {0,1.02,0})
        table.insert(verts, {math.cos(angle) * bottomWidth, 1.02, math.sin(angle) * bottomWidth})
        table.insert(verts, {math.cos(nextAngle) * bottomWidth, 1.02, math.sin(nextAngle) * bottomWidth})

        angle = nextAngle
    end

    angle = 0.0
    while angle <= math.pi *2 do
        local nextAngle = angle + 0.7

        addRectVerts(verts, {
            {math.cos(angle) * width, 1.02, math.sin(angle) * width},
            {math.cos(nextAngle) * width, 1.02, math.sin(nextAngle) * width},
            {math.cos(nextAngle) * width, 1.0 + height, math.sin(nextAngle) * width},
            {math.cos(angle) * width, 1.0 + height, math.sin(angle) * width},
        })

        angle = nextAngle
    end

    angle = 0.0
    while angle <= math.pi *2 do
        local nextAngle = angle + 0.7

        table.insert(verts, {0,1.0 + height,0})
        table.insert(verts, {math.cos(angle) * width, 1.0 + height, math.sin(angle) * width})
        table.insert(verts, {math.cos(nextAngle) * width, 1.0 + height, math.sin(nextAngle) * width})

        angle = nextAngle
    end

    local model = modelFromCoordsColor(verts, color, Car.size)
    table.insert(car.models, model)
end

Accessories = {
    {name = "none", action = accessoryNone},
    {name = "hat_basic", action = accessoryHat},
    {name = "contacts", action = accessoryContacts},
    {name = "glasses", action = accessoryGlasses},
    {name = "witchHat", action = accessoryWitchHat},
    {name = "topHat", action = accessoryTopHat},
}

function nameToAccessory(name)
    for k,v in pairs(Accessories) do
        if v.name == name then
            return v
        end
    end
end
