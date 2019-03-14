local skyboxModels = nil

function skybox(imageSkybox)
    if skyboxModels then
        for k,v in pairs(skyboxModels) do
            v.dead = true
        end
    end

    local lowY = -1
    -- front
    local front = rect({
        {-WorldSize, lowY, -WorldSize,                 0.25, 0.5},
        {-WorldSize, SkyboxHeight, -WorldSize,      0.25, 0.3333},
        {WorldSize, SkyboxHeight, -WorldSize,       0.5, 0.3333},
        {WorldSize, lowY, -WorldSize,                  0.5, 0.5}
    }, imageSkybox, nil, 0.0)

    -- right
    local right = rect({
        {WorldSize, lowY, -WorldSize,                 0.5, 0.5},
        {WorldSize, SkyboxHeight, -WorldSize,      0.5, 0.3333},
        {WorldSize, SkyboxHeight, WorldSize,       0.75, 0.3333},
        {WorldSize, lowY, WorldSize,                  0.75, 0.5}
    }, imageSkybox, nil, 0.0)

    -- back
    local back = rect({
        {WorldSize, lowY, WorldSize,                 0.75, 0.5},
        {WorldSize, SkyboxHeight, WorldSize,      0.75, 0.3333},
        {-WorldSize, SkyboxHeight, WorldSize,       1, 0.3333},
        {-WorldSize, lowY, WorldSize,                  1, 0.5}
    }, imageSkybox, nil, 0.0)

    -- left
    local left = rect({
        {-WorldSize, lowY, WorldSize,                 0, 0.5},
        {-WorldSize, SkyboxHeight, WorldSize,      0, 0.3333},
        {-WorldSize, SkyboxHeight, -WorldSize,       0.25, 0.3333},
        {-WorldSize, lowY, -WorldSize,                  0.25, 0.5}
    }, imageSkybox, nil, 0.0)

    -- top
    local top = rect({
        {-WorldSize, SkyboxHeight, -WorldSize,     0.25, 0.3333},
        {WorldSize, SkyboxHeight, -WorldSize,      0.5, 0.3333},
        {WorldSize, SkyboxHeight, WorldSize,       0.5, 0},
        {-WorldSize, SkyboxHeight, WorldSize,      0.25, 0}
    }, imageSkybox, nil, 0.0)

    skyboxModels = {front, right, back, left, op}
end
