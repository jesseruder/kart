
function makeCar(color)
    if not color then
        color = {math.random(), math.random(), math.random()}
    end

    local Car = {
        size = 0.2,
        roadIndex = 0,
        accel = 500,
        turnAngle = math.pi*0.25,
        turnSpeed = 1.5,
        vel = {x = 0, z = 0},
        offRoadMaxSpeed = 1.5,
        normal = {x = 0, y = 0, z = 1},
        color = color
    }

    local front = rect({
        {-1, -1, 1,   0,0},
        {-1, 1, 1,    0,1},
        {1, 1, 1,     1,1},
        {1, -1, 1,    1,0}
    }, imageCheese, Car.size)

    local back = rect({
        {-1, -1, -1,  0,0},
        {-1, 1, -1,   0,1},
        {1, 1, -1,    1,1},
        {1, -1, -1,   1,0}
    }, imageCheese, Car.size)

    local left = rect({
        {-1, -1, 1,   0,0},
        {-1, 1, 1,    0,1},
        {-1, 1, -1,   1,1},
        {-1, -1, -1,   1,0}
    }, imageCheese, Car.size)

    local right = rect({
        {1, -1, 1,    0,0},
        {1, 1, 1,     0,1},
        {1, 1, -1,    1, 1},
        {1, -1, -1,   1,0}
    }, imageCheese, Car.size)

    local hatTopHeight = 1.8
    local hatBottomHeight = 0.9
    local hatBrimSize = 1.2

    local hatFront = triColor({
        {-hatBrimSize, hatBottomHeight, hatBrimSize},
        {hatBrimSize, hatBottomHeight, hatBrimSize},
        {0, hatTopHeight, 0}
    }, color, Car.size)

    local hatBack = triColor({
        {-hatBrimSize, hatBottomHeight, -hatBrimSize},
        {hatBrimSize, hatBottomHeight, -hatBrimSize},
        {0, hatTopHeight, 0}
    }, color, Car.size)

    local hatLeft = triColor({
        {-hatBrimSize, hatBottomHeight, hatBrimSize},
        {-hatBrimSize, hatBottomHeight, -hatBrimSize},
        {0, hatTopHeight, 0}
    }, color, Car.size)

    local hatRight = triColor({
        {hatBrimSize, hatBottomHeight, hatBrimSize},
        {hatBrimSize, hatBottomHeight, -hatBrimSize},
        {0, hatTopHeight, 0}
    }, color, Car.size)

    local eyeSize = 0.4
    local eyeDistFromSide = 0.3
    local eyeDistFromTop = 0.3

    local pupilSize = 0.25
    local pupilDistFromSide = eyeDistFromSide + (eyeSize - pupilSize) * 0.5
    local pupilDistFromTop = eyeDistFromTop + (eyeSize - pupilSize) * 0.5

    local eye1 = rectColor({
        {1.02, 1 - eyeDistFromTop - eyeSize, 1 - eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, 1 - eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, 1 - eyeDistFromSide - eyeSize},
        {1.02, 1 - eyeDistFromTop - eyeSize, 1 - eyeDistFromSide - eyeSize}
    }, {1,1,1,1}, Car.size)

    local eyePupil1 = rectColor({
        {1.04, 1 - pupilDistFromTop - pupilSize, 1 - pupilDistFromSide},
        {1.04, 1 - pupilDistFromTop, 1 - pupilDistFromSide},
        {1.04, 1 - pupilDistFromTop, 1 - pupilDistFromSide - pupilSize},
        {1.04, 1 - pupilDistFromTop - pupilSize, 1 - pupilDistFromSide - pupilSize}
    }, {0,0,0,1}, Car.size)

    local eye2 = rectColor({
        {1.02, 1 - eyeDistFromTop - eyeSize, -1 + eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, -1 + eyeDistFromSide},
        {1.02, 1 - eyeDistFromTop, -1 + eyeDistFromSide + eyeSize},
        {1.02, 1 - eyeDistFromTop - eyeSize, -1 + eyeDistFromSide + eyeSize}
    }, {1,1,1,1}, Car.size)

    local eyePupil2 = rectColor({
        {1.04, 1 - pupilDistFromTop - pupilSize, -1 + pupilDistFromSide},
        {1.04, 1 - pupilDistFromTop, -1 + pupilDistFromSide},
        {1.04, 1 - pupilDistFromTop, -1 + pupilDistFromSide + pupilSize},
        {1.04, 1 - pupilDistFromTop - pupilSize, -1 + pupilDistFromSide + pupilSize}
    }, {0,0,0,1}, Car.size)

    Car.models = {front, back, left, right, hatFront, hatBack, hatLeft, hatRight, eye1, eyePupil1, eye2, eyePupil2}

    return Car
end

function updateCarPosition(car)
    for k,v in pairs(car.models) do
        v:setTransform({car.x, car.size / 2.0 + car.y, car.z}, {-car.angle, cpml.vec3.unit_y})
    end
end

function removeCar(car)
    for k,v in pairs(car.models) do
        v.dead = true
    end
end
