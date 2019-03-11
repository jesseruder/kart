Engine = require "engine"

function love.load()
    -- window graphics settings
    GraphicsWidth, GraphicsHeight = 520*2, (520*9/16)*2
    InterfaceWidth, InterfaceHeight = GraphicsWidth, GraphicsHeight
    love.graphics.setBackgroundColor(0,0.7,0.95)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    love.window.setMode(GraphicsWidth,GraphicsHeight, {vsync = -1})

    -- for capping game logic at 60 manually
    LogicRate = 60
    LogicAccumulator = 0
    PhysicsStep = true

    love.graphics.setCanvas()

    Scene = Engine.newScene(GraphicsWidth, GraphicsHeight)

    imageDirt = love.graphics.newImage("assets/grass.png")
    local model = Engine.newModel({ {0,0,0, 0,0}, {1,0,0, 1,0}, {0,0,1, 0,1} }, imageDirt, {2,0,0})
    table.insert(Scene.modelList, model)
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