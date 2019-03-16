
function loadCarAssets(assets)
    carFront = assets["front"]
    carSide = assets["side"]
    carBack = assets["back"]
    carTop = assets["top"]
end

function makeCar(characterName, accessoryName, color)
    if not color then
        color = {math.random(), math.random(), math.random()}
    end

    nameToCharacter(characterName).action()

    local Car = {
        characterName = characterName,
        accessoryName = accessoryName,
        size = 0.2,
        roadIndex = 1,
        accel = 500,
        turnAngle = math.pi*0.25,
        turnSpeed = 1.5,
        vel = {x = 0, y = 0, z = 0},
        isTouchingGround = true,
        offRoadMaxSpeed = 1.5,
        normal = {x = 0, y = 0, z = 1},
        color = color
    }

    local front = rect({
        {-1, -1, 1,   1,0},
        {-1, 1, 1,    1,1},
        {1, 1, 1,     0,1},
        {1, -1, 1,    0,0}
    }, carSide, Car.size)

    local back = rect({
        {-1, -1, -1,  1,0},
        {-1, 1, -1,   1,1},
        {1, 1, -1,    0,1},
        {1, -1, -1,   0,0}
    }, carSide, Car.size)

    local left = rect({
        {-1, -1, 1,   0,0},
        {-1, 1, 1,    0,1},
        {-1, 1, -1,   1,1},
        {-1, -1, -1,   1,0}
    }, carBack, Car.size)

    local right = rect({
        {1, -1, 1,    0,1},
        {1, 1, 1,     0,0},
        {1, 1, -1,    1,0},
        {1, -1, -1,   1,1}
    }, carFront, Car.size)

    local top = rect({
        {-1, 1, 1,    1,0},
        {1, 1, 1,     0,0},
        {1, 1, -1,    0,1},
        {-1, 1, -1,   1,1}
    }, carTop, Car.size)

    Car.models = {front, back, left, right, top}--, hatFront, hatBack, hatLeft, hatRight}--, eye1, eyePupil1, eye2, eyePupil2}
    nameToAccessory(accessoryName).action(Car)

    return Car
end

function updateCarPosition(car)
    if not Car.angleUp then
        Car.angleUp = 0
    end

    if not Car.angleSide then
        Car.angleSide = 0
    end

    for k,v in pairs(car.models) do
        v:setTransform({car.x, car.size / 2.0 + car.y, car.z}, {-car.angle, cpml.vec3.unit_y, car.angleUp, cpml.vec3.unit_z, car.angleSide, cpml.vec3.unit_x})
    end
end

function removeCar(car)
    for k,v in pairs(car.models) do
        v.dead = true
    end
end
