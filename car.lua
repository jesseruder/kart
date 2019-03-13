
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


    Car.models = {front, back, left, right}

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
