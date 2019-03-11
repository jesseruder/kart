Engine = require "engine"
require "path"

function love.load()
    -- window graphics settings
    GraphicsWidth, GraphicsHeight = 520*2, (520*9/16)*2
    InterfaceWidth, InterfaceHeight = GraphicsWidth, GraphicsHeight
    love.graphics.setBackgroundColor(0,0.7,0.95)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    --love.window.setMode(GraphicsWidth,GraphicsHeight, {vsync = -1, msaa = 4})

    -- for capping game logic at 60 manually
    LogicRate = 60
    LogicAccumulator = 0
    PhysicsStep = true
    WorldSize = 30
    SkyboxHeight = 30

    love.graphics.setCanvas()

    Scene = Engine.newScene(GraphicsWidth, GraphicsHeight)

    imageDirt = love.graphics.newImage("assets/grass.png")
    imageDirt:setWrap('repeat','repeat')
    rect({
        {-WorldSize, 0, -WorldSize,    -WorldSize, -WorldSize},
        {WorldSize, 0, -WorldSize,      WorldSize, -WorldSize},
        {WorldSize, 0, WorldSize,       WorldSize, WorldSize},
        {-WorldSize, 0, WorldSize,     -WorldSize, WorldSize}
    }, imageDirt)


    imageSkybox = love.graphics.newImage("assets/skybox.png")
    -- front
    rect({
        {-WorldSize, 0, -WorldSize,                 0.25, 0.5},
        {-WorldSize, SkyboxHeight, -WorldSize,      0.25, 0.3333},
        {WorldSize, SkyboxHeight, -WorldSize,       0.5, 0.3333},
        {WorldSize, 0, -WorldSize,                  0.5, 0.5}
    }, imageSkybox)

    -- right
    rect({
        {WorldSize, 0, -WorldSize,                 0.5, 0.5},
        {WorldSize, SkyboxHeight, -WorldSize,      0.5, 0.3333},
        {WorldSize, SkyboxHeight, WorldSize,       0.75, 0.3333},
        {WorldSize, 0, WorldSize,                  0.75, 0.5}
    }, imageSkybox)

    -- back
    rect({
        {WorldSize, 0, WorldSize,                 0.75, 0.5},
        {WorldSize, SkyboxHeight, WorldSize,      0.75, 0.3333},
        {-WorldSize, SkyboxHeight, WorldSize,       1, 0.3333},
        {-WorldSize, 0, WorldSize,                  1, 0.5}
    }, imageSkybox)

    -- left
    rect({
        {-WorldSize, 0, WorldSize,                 0, 0.5},
        {-WorldSize, SkyboxHeight, WorldSize,      0, 0.3333},
        {-WorldSize, SkyboxHeight, -WorldSize,       0.25, 0.3333},
        {-WorldSize, 0, -WorldSize,                  0.25, 0.5}
    }, imageSkybox)

    -- top
    rect({
        {-WorldSize, SkyboxHeight, -WorldSize,     0.25, 0.3333},
        {WorldSize, SkyboxHeight, -WorldSize,      0.5, 0.3333},
        {WorldSize, SkyboxHeight, WorldSize,       0.5, 0},
        {-WorldSize, SkyboxHeight, WorldSize,      0.25, 0}
    }, imageSkybox)


    makeRoad()
end

--[[
1     2

4     3
]]--
function rect(coords, texture)
    local model = Engine.newModel({ coords[1], coords[2], coords[4] }, texture)
    table.insert(Scene.modelList, model)

    local model2 = Engine.newModel({ coords[2], coords[3], coords[4] }, texture)
    table.insert(Scene.modelList, model2)
end

function love.update(dt)
    Scene:basicCamera(dt)
    
    LogicAccumulator = LogicAccumulator+dt

    -- update 3d scene
    Scene:update()
    PhysicsStep = false
    if LogicAccumulator >= 1/LogicRate then
        LogicAccumulator = LogicAccumulator - 1/LogicRate
        PhysicsStep = true
    end

    -- update everything
end

function love.draw()
    -- draw 3d scene
    Scene:render(true)

    love.graphics.setColor(1,1,1)
    local scale = love.graphics.getWidth()/InterfaceWidth
    love.graphics.draw(Scene.twoCanvas, love.graphics.getWidth()/2,love.graphics.getHeight()/2 +1, 0, scale,scale, InterfaceWidth/2, InterfaceHeight/2)
end

function love.mousemoved(x,y, dx,dy)
    -- forward mouselook to Scene object for first person camera control
    Scene:mouseLook(x,y, dx,dy)
end

function makeRoad()
    local elev = 0.01
    local road_width = 0.5
    local road_scale = 20

    local imageRoad = love.graphics.newImage("assets/road.png")
    local lastPoint = PATH_POINTS[#PATH_POINTS]
    for k,v in pairs(PATH_POINTS) do

        local lx = lastPoint[1] * road_scale - road_scale / 2.0
        local ly = lastPoint[2] * road_scale - road_scale / 2.0
        local la = lastPoint[3]
        local ldx = math.cos(la + math.pi/2) * road_width
        local ldy = math.sin(la + math.pi/2) * road_width

        local x = v[1] * road_scale - road_scale / 2.0
        local y = v[2] * road_scale - road_scale / 2.0
        local a = v[3]
        local dx = math.cos(a + math.pi/2) * road_width
        local dy = math.sin(a + math.pi/2) * road_width

        --elev = elev + 0.05
        rect({
            {lx - ldx, elev, ly - ldy,    0, 0},
            {x - dx, elev, y - dy,   0,1},
            {x + dx, elev, y + dy,     1,1},
            {lx + ldx, elev, ly + ldy,    1,0}
        }, imageRoad)

        lastPoint = v
    end
end