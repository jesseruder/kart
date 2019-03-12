Engine = require "engine"
require "path"
require "heightmap"
local cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/master/cs.lua'
local client = cs.client

client.useCastleConfig()

RESET_CAR = false
PLAY_MUSIC = false

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
    GridSize = 0.5
    SkyboxHeight = 30
    MaxClosestRoadDistance = 2.5
    RoadScale = 35
    RoadRadius = 1.0
    Car = {
        size = 0.2,
        roadIndex = 0,
        accel = 500,
        turnAngle = math.pi*0.25,
        turnSpeed = 1.5,
        vel = {x = 0, z = 0},
        offRoadMaxSpeed = 1.5,
        normal = {x = 0, y = 0, z = 1}
    }

    love.graphics.setCanvas()

    Scene = Engine.newScene(GraphicsWidth, GraphicsHeight)

    makeHeightMap()
    imageDirt = love.graphics.newImage("assets/grass.png")
    imageDirt:setWrap('repeat','repeat')

    local groundVerts = {}
    for x = 1, #HEIGHTS-1 do
        for y = 1, #HEIGHTS[x]-1 do
            local worldX = x * GridSize - WorldSize
            local worldY = y * GridSize - WorldSize

            table.insert(groundVerts, {worldX, HEIGHTS[x][y], worldY,    worldX/4, worldY/4})
            table.insert(groundVerts, {worldX+GridSize, HEIGHTS[x+1][y], worldY,    (worldX + GridSize)/4, worldY/4})
            table.insert(groundVerts, {worldX, HEIGHTS[x][y+1], worldY+GridSize,    worldX/4, (worldY + GridSize)/4})


            table.insert(groundVerts, {worldX+GridSize, HEIGHTS[x+1][y], worldY,    (worldX + GridSize)/4, worldY/4})
            table.insert(groundVerts, {worldX+GridSize, HEIGHTS[x+1][y+1], worldY+GridSize,    (worldX + GridSize)/4, (worldY + GridSize)/4})
            table.insert(groundVerts, {worldX, HEIGHTS[x][y+1], worldY+GridSize,    worldX/4, (worldY + GridSize)/4})
        end
    end
    local groundModel = Engine.newModel(groundVerts, imageDirt)
    table.insert(Scene.modelList, groundModel)


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


    imageCheese = love.graphics.newImage("assets/cheese.png")
    makeRoad()
    makeCar()

    if PLAY_MUSIC then
        local music = love.audio.newSource("assets/music.mp3", "stream")
        music:setLooping(true)
        music:play()
    end
end

--[[
1     2

4     3
]]--
function rect(coords, texture, scale)
    local model = Engine.newModel({ coords[1], coords[2], coords[4], coords[2], coords[3], coords[4] }, texture, nil, nil, nil, scale)
    table.insert(Scene.modelList, model)
    return model
end

function rectColor(coords, color, scale)
    local model = Engine.newModel({ coords[1], coords[2], coords[4], coords[2], coords[3], coords[4] }, nil, nil, color, { 
        {"VertexPosition", "float", 3}, 
    }, scale)
    table.insert(Scene.modelList, model)
    return model
end

function makeCar()
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
end

function love.update(dt)
    -- Scene:basicCamera(dt)
    
    LogicAccumulator = LogicAccumulator+dt

    -- update 3d scene
    Scene:update()
    PhysicsStep = false
    if LogicAccumulator >= 1/LogicRate then
        LogicAccumulator = LogicAccumulator - 1/LogicRate
        PhysicsStep = true
    end

    -- update everything
    --Car.x = dt * 0.5 + Car.x
    local frictionConst = 100
    local accel = love.keyboard.isDown("space") and 1 or 0
    local turnDirection = love.keyboard.isDown("left") and -1 or (love.keyboard.isDown("right") and 1 or 0)
    local isDrift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

    local turnAngle
    if isDrift then
        frictionConst = 150
        turnAngle = Car.angle + turnDirection * -math.pi / 4
    else
        turnAngle = Car.angle + turnDirection * Car.turnAngle
    end

    local frictionx = Car.vel.x * dt * -frictionConst
    local frictionz = Car.vel.z * dt * -frictionConst
    local carax = dt * accel * math.cos(turnAngle) * Car.accel
    local caraz = dt * accel * math.sin(turnAngle) * Car.accel

    if isDrift then
        Car.angle = Car.angle + turnDirection * Car.turnSpeed * dt * 0.5
    else
        Car.angle = Car.angle + turnDirection * Car.turnSpeed * dt
    end

    Car.vel.x = Car.vel.x + (frictionx + carax) * dt
    Car.vel.z = Car.vel.z + (frictionz + caraz) * dt
    Car.x = Car.x + Car.vel.x * dt
    Car.z = Car.z + Car.vel.z * dt
    local hap = heightAtPoint(Car.x, Car.z)
    Car.y = hap.height + 0.1
    Car.normal = hap.normal

    local DIST_TO_CHECK = 10
    local closestRoadIndex = 0
    local closestRoadDistance = 100000000000
    for idx = Car.roadIndex - DIST_TO_CHECK, Car.roadIndex + DIST_TO_CHECK do
        local realIdx = idx
        if realIdx <= 0 then
            realIdx = realIdx + #PATH_POINTS
        end
        if realIdx > #PATH_POINTS then
            realIdx = realIdx - #PATH_POINTS
        end

        local rx = PATH_POINTS[realIdx][1] * RoadScale - RoadScale / 2.0
        local ry = PATH_POINTS[realIdx][2] * RoadScale - RoadScale / 2.0
        local distance = math.sqrt(math.pow(rx - Car.x, 2) + math.pow(ry - Car.z, 2))
        if distance < closestRoadDistance then
            closestRoadDistance = distance
            closestRoadIndex = realIdx
        end
    end
    Car.roadIndex = closestRoadIndex
    -- reset car
    if RESET_CAR and closestRoadDistance > MaxClosestRoadDistance then
        Car.x = PATH_POINTS[closestRoadIndex][1] * RoadScale - RoadScale / 2.0
        Car.z = PATH_POINTS[closestRoadIndex][2] * RoadScale - RoadScale / 2.0
    end

    if closestRoadDistance > RoadRadius then
        local speed = math.sqrt(math.pow(Car.vel.x, 2) + math.pow(Car.vel.z, 2))
        if speed > Car.offRoadMaxSpeed then
            Car.vel.x = Car.vel.x * Car.offRoadMaxSpeed / speed
            Car.vel.z = Car.vel.z * Car.offRoadMaxSpeed / speed
        end
    end

    local Camera = Engine.camera
    local CameraPos = Camera.pos
    local cameraSpeed = 3 --3
    local desiredCamDist = 3

    local CAM_DIST_TO_CHECK = 50
    local lastCamIdx
    local lastTestCamX
    local lastTestCamZ
    local desiredCamX
    local desiredCamZ
    for idx = Car.roadIndex - CAM_DIST_TO_CHECK, Car.roadIndex do
        local realIdx = idx
        if realIdx <= 0 then
            realIdx = realIdx + #PATH_POINTS
        end
        if realIdx > #PATH_POINTS then
            realIdx = realIdx - #PATH_POINTS
        end
        
        local testCamX = (PATH_POINTS[realIdx][1] * RoadScale - RoadScale / 2.0)
        local testCamZ = (PATH_POINTS[realIdx][2] * RoadScale - RoadScale / 2.0)
        local testCamDist = math.sqrt(math.pow(Car.x - testCamX, 2) + math.pow(Car.z - testCamZ, 2))
        
        -- We're close enough!
        if testCamDist < desiredCamDist then
            if lastCamIdx then
                -- start at last road section, iterate until we're the correct distance
                local vecX = testCamX - lastTestCamX
                local vecZ = testCamZ - lastTestCamZ
                local amt = 0.0
                while amt < 1.0 do
                    local x = lastTestCamX + vecX * amt
                    local z = lastTestCamZ + vecZ * amt
                    local dist = math.sqrt(math.pow(Car.x - x, 2) + math.pow(Car.z - z, 2))
                    if dist < desiredCamDist then
                        desiredCamX = x
                        desiredCamZ = z
                        break
                    end
                    amt = amt + 0.002
                end
            else
                -- should never happen
                desiredCamX = testCamX
                desiredCamZ = testCamZ
            end
        end

        if desiredCamX then
            break
        end

        lastCamIdx = realIdx
        lastTestCamX = testCamX
        lastTestCamZ = testCamZ
    end

    if not desiredCamX then
        local camIdx = Car.roadIndex - 5
        if camIdx <= 0 then
            camIdx = camIdx + #PATH_POINTS
        end

        desiredCamX = (PATH_POINTS[camIdx][1] * RoadScale - RoadScale / 2.0)
        desiredCamZ = (PATH_POINTS[camIdx][2] * RoadScale - RoadScale / 2.0)
    end


    local cdx = desiredCamX - CameraPos.x
    local cdz = desiredCamZ - CameraPos.z
    local camt = math.sqrt(math.pow(cdx, 2) + math.pow(cdz, 2))

    --if camt > 0.1 then
        CameraPos.x = CameraPos.x + dt * cameraSpeed * cdx-- / camt
        CameraPos.z = CameraPos.z + dt * cameraSpeed * cdz-- / camt
    --end
    CameraPos.y = 1 + math.max(Car.y, heightAtPoint(CameraPos.x, CameraPos.z).height)

    Camera.angle.x = math.pi-math.atan2(Car.x - CameraPos.x, Car.z - CameraPos.z)
    Camera.angle.y = 0.3

    for k,v in pairs(Car.models) do
        v:setTransform({Car.x, Car.size / 2.0 + Car.y, Car.z}, {-Car.angle, cpml.vec3.unit_y})
    end
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
    -- Scene:mouseLook(x,y, dx,dy)
end

function makeRoad()
    local elev = 0.05

    local imageRoad = love.graphics.newImage("assets/road.png")
    local lastPoint = PATH_POINTS[#PATH_POINTS]
    Car.x = PATH_POINTS[1][1] * RoadScale - RoadScale / 2.0
    Car.y = 0
    Car.z = PATH_POINTS[1][2] * RoadScale - RoadScale / 2.0
    Car.angle = PATH_POINTS[1][3]

    for k,v in pairs(PATH_POINTS) do
        local lx = lastPoint[1] * RoadScale - RoadScale / 2.0
        local ly = lastPoint[2] * RoadScale - RoadScale / 2.0
        local la = lastPoint[3]
        local ldx = math.cos(la + math.pi/2) * RoadRadius
        local ldy = math.sin(la + math.pi/2) * RoadRadius

        local x = v[1] * RoadScale - RoadScale / 2.0
        local y = v[2] * RoadScale - RoadScale / 2.0
        local a = v[3]
        local dx = math.cos(a + math.pi/2) * RoadRadius
        local dy = math.sin(a + math.pi/2) * RoadRadius

        --elev = elev + 0.05
        rect({
            {lx - ldx, elev + heightAtPoint(lx - ldx, ly - ldy).height, ly - ldy,    0, 0},
            {x - dx, elev + heightAtPoint(x - dx, y - dy).height, y - dy,   0,1},
            {x + dx, elev + heightAtPoint(x + dx, y + dy).height, y + dy,     1,1},
            {lx + ldx, elev + heightAtPoint(lx + ldx, ly + ldy).height, ly + ldy,    1,0}
        }, imageRoad)

        lastPoint = v
    end
end