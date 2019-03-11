Engine = require "engine"

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
    WorldSize = 10
    SkyboxHeight = 10

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

function skybox()

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