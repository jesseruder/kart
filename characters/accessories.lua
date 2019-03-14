function accessoryNone(car)

end

function accessoryHat(car)
    local hatTopHeight = 1.8
    local hatBottomHeight = 0.9
    local hatBrimSize = 1.2
    local color = car.color

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

    table.insert(car.models, hatFront)
    table.insert(car.models, hatBack)
    table.insert(car.models, hatLeft)
    table.insert(car.models, hatRight)
end

Accessories = {
    {name = "none", action = accessoryNone},
    {name = "hat_basic", action = accessoryHat},
}

function nameToAccessory(name)
    for k,v in pairs(Accessories) do
        if v.name == name then
            return v
        end
    end
end
