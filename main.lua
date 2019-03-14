Engine = require "engine"
require "car"
require "multiplayer"
require "items.items"
require "levels_tools.road"
require "levels_tools.skybox"
require "levels_tools.terrain"
require "levels_tools.heightmap"

require "levels.moon"
require "levels.grass"
require "levels.water"

require "characters.anime"
require "characters.shonen"

function resetGame()
    if ACTUAL_GAME then
        Laps = 3
    else
        Laps = 1
    end

    GameState = "intro"
    GameCountdownTime = 1000000
    GameCountdownBright = 0.0
    Lap = 1
    IsFinished = false
    EligibleForNextLap = false
    IsRequestingStart = false
    MyItem = nil
    MyTakenItem = nil

    Car.x = PATH_POINTS[1][1] * RoadScale - RoadScale / 2.0 + CAR_RANDOM_POS * math.random()
    Car.y = 0
    Car.z = PATH_POINTS[1][2] * RoadScale - RoadScale / 2.0 + CAR_RANDOM_POS * math.random()
    Car.angle = PATH_POINTS[1][3]
end

local time3 = 0.666
local time2 = time3 + 0.948
local time1 = time3 + 1.896
local timeStart = time3 + 3.78
local timeBright = 0.1

local playingAmbient = true
function switchToAmbient()
    if PLAY_MUSIC and playingAmbient == false then
        AmbientMusic:play()
        Music:stop()
        playingAmbient = true
    end
end

function switchToMusic()
    if PLAY_MUSIC and playingAmbient then
        AmbientMusic:stop()
        Music:play()
        playingAmbient = false
    end
end

function restartMusic()
    if PLAY_MUSIC then
        AmbientMusic:stop()
        Music:stop()
        Music:play()
        playingAmbient = false
    end
end

function stopCheering()
    if PLAY_MUSIC then
        Music:setVolume(1.0)
        BooSound:stop()
        ApplauseSound:stop()
    end
end

MAX_MOTION_BLUR = 0.5

function client.load()
    -- window graphics settings
    --GraphicsWidth, GraphicsHeight = 520*2, (520*9/16)*2
    GraphicsWidth = love.graphics.getWidth()
    GraphicsHeight = love.graphics.getHeight()
    InterfaceWidth, InterfaceHeight = GraphicsWidth, GraphicsHeight
    OffsetX = 0
    OffsetY = 0
    TimeElapsed = 0.0
    love.graphics.setBackgroundColor(0,0.7,0.95)
    love.graphics.setDefaultFilter("linear", "linear")
    love.graphics.setLineStyle("rough")
    -- love.window.setMode(GraphicsWidth,GraphicsHeight, {vsync = -1, msaa = 8})

    BigFont = love.graphics.newFont(20)
    HugeFont = love.graphics.newFont(100)
    DefaultFont = love.graphics.getFont()
    loadItemImages()

    love.graphics.setCanvas()

    Scene = Engine.newScene(GraphicsWidth, GraphicsHeight)

    loadShonenCharacter()
    Car = makeCar()

    loadGrassLevel()

    if ACTUAL_GAME == false then
        makeItems(5)
    end

    if PLAY_MUSIC then
        AmbientMusic = love.audio.newSource("assets/intro.mp3", "stream")
        AmbientMusic:setLooping(true)
        AmbientMusic:setVolume(0.5)
        AmbientMusic:play()

        Music = love.audio.newSource("assets/music.mp3", "stream")
        Music:setLooping(true)

        ApplauseSound = love.audio.newSource("assets/applause.mp3", "stream")
        ApplauseSound:setLooping(true)
        BooSound = love.audio.newSource("assets/boo.mp3", "stream")
        BooSound:setLooping(true)
    end

    resetGame()
end

function recordLap()
    Lap = Lap + 1
    EligibleForNextLap = false
    if Lap > Laps then
        IsFinished = true
    end
end

--[[
1     2

4     3
]]--
function rect(coords, texture, scale, fogAmount)
    local model = Engine.newModel({ coords[1], coords[2], coords[4], coords[2], coords[3], coords[4] }, texture, nil, nil, nil, scale, fogAmount)
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

function triColor(coords, color, scale)
    local model = Engine.newModel({ coords[1], coords[2], coords[3] }, nil, nil, color, { 
        {"VertexPosition", "float", 3}, 
    }, scale)
    table.insert(Scene.modelList, model)
    return model
end

function love.keypressed(key)
    if MyItem and key == "return" then
        MyItem.action()
        MyItem = nil
    end
end

function client.update(dt)
    TimeElapsed = TimeElapsed + dt
    getMultiplayerUpdate(dt)

    if ServerGameState and ServerGameState ~= GameState then
        if ServerGameState == "countdown" then
            GameCountdownTime = 0
            GameCountdownBright = 0.0
            restartMusic()
            stopCheering()
        elseif ServerGameState == "running" then
            switchToMusic()
            stopCheering()
            if love.keyboard.isDown("space") then
                -- give car some intial velocity
                Car.vel.x = math.cos(Car.angle) * 5
                Car.vel.z = math.sin(Car.angle) * 5
            end
        elseif ServerGameState == "intro" then
            resetGame()
            switchToAmbient()
            stopCheering()
        elseif ServerGameState == "postgame" then
            if PLAY_MUSIC then
                Music:setVolume(0.5)
                if AmIWinner then
                    ApplauseSound:play()
                else
                    BooSound:play()
                end
            end
        end

        GameState = ServerGameState
    end

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
    if GameState ~= "running" then
        accel = 0
    end

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

    if isSlipping or Car.hitByShellTime then
        Car.angle = Car.angle + 5 * dt
        carax = 0
        caraz = 0
    else
        if isDrift then
            Car.angle = Car.angle + turnDirection * Car.turnSpeed * dt * 0.5
        else
            Car.angle = Car.angle + turnDirection * Car.turnSpeed * dt
        end
    end

    Car.vel.x = Car.vel.x + (frictionx + carax) * dt
    Car.vel.z = Car.vel.z + (frictionz + caraz) * dt
    local carSpeed = math.sqrt(math.pow(Car.vel.x, 2) + math.pow(Car.vel.z, 2))
    MotionBlurAmount = carSpeed / 13.0

    Car.x = Car.x + Car.vel.x * dt
    Car.z = Car.z + Car.vel.z * dt
    local hap = heightAtPoint(Car.x, Car.z)
    Car.y = hap.height + CAR_EXTRA_Y
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

    if Car.roadIndex > #PATH_POINTS * 0.4 and Car.roadIndex < #PATH_POINTS * 0.6 then
        EligibleForNextLap = true
    end

    if Car.roadIndex > 0 and Car.roadIndex < 5 and EligibleForNextLap == true then
        recordLap()
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

    if GameState == "intro" then
        IntroCameraRotation = IntroCameraRotation + dt * IntroCameraRotationSpeed
        desiredCamX = Car.x + math.cos(IntroCameraRotation) * IntroCameraRotationDist
        desiredCamZ = Car.z + math.sin(IntroCameraRotation) * IntroCameraRotationDist
    end

    local winnerCar = Car
    if Winner and otherCars[Winner] then
        winnerCar = otherCars[Winner]
    end

    if GameState == "postgame" then
        IntroCameraRotation = IntroCameraRotation + dt * IntroCameraRotationSpeed
        desiredCamX = winnerCar.x + math.cos(IntroCameraRotation) * IntroCameraRotationDist
        desiredCamZ = winnerCar.z + math.sin(IntroCameraRotation) * IntroCameraRotationDist
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

    if not USE_REMOTE_CAR then
        updateCarPosition(Car)
    end

    sendMultiplayerUpdate()
    updateItems(dt)

    GameCountdownTime = GameCountdownTime + dt
    GameCountdownBright = GameCountdownBright - dt * 2
end

function client.draw()
    -- draw 3d scene
    if client.connected then
        Scene:render(true, TimeElapsed)
    else
        love.graphics.clear(0,0,0,0)
    end

    -- draw HUD
    Scene:renderFunction(
        function ()
            love.graphics.setColor(FontColor[1], FontColor[2], FontColor[3], 1)
            love.graphics.print("FPS: " .. love.timer.getFPS(), 20, 20)
            if client.connected then
                love.graphics.print("Ping: " .. client.getPing(), 20, 40)
                love.graphics.print("Players: " .. NumPlayers, GraphicsWidth - 100, 20)
                love.graphics.setColor(1,1,1,1)

                if GameState == "intro" then
                    love.graphics.setFont(BigFont)
                    if IsRequestingStart == true then
                        love.graphics.print("getting ready...", GraphicsWidth / 2 - 80, GraphicsHeight - 80)
                    else
                        love.graphics.print("hold [space] when ready", GraphicsWidth / 2 - 130, GraphicsHeight - 80)
                    end
                    love.graphics.setFont(DefaultFont)
                end

                if GameState == "postgame" then
                    local text = "You lost"
                    if AmIWinner and AmIWinner == true then
                        text = "You win!!"
                    end

                    love.graphics.setFont(HugeFont)
                    love.graphics.print(text, GraphicsWidth / 2 - 200, GraphicsHeight / 2 - 50)
                    love.graphics.setFont(DefaultFont)
                end

                if GameState == "countdown" then
                    love.graphics.setFont(HugeFont)

                    local text = nil

                    if GameCountdownTime > time1 then
                        text = "1"
                        if GameCountdownTime - time1 < timeBright then
                            GameCountdownBright = 1.0
                        end
                    elseif GameCountdownTime > time2 then
                        text = "2"
                        if GameCountdownTime - time2 < timeBright then
                            GameCountdownBright = 1.0
                        end
                    elseif GameCountdownTime > time3 then
                        text = "3"
                        if GameCountdownTime - time3 < timeBright then
                            GameCountdownBright = 1.0
                        end
                    end

                    if text and GameCountdownBright > 0.98 then
                        love.graphics.print(text, GraphicsWidth / 2 - 30, GraphicsHeight / 2 - 50)
                    end

                    love.graphics.setFont(DefaultFont)
                end

                if GameState == "running" then
                    local printLap = Lap
                    if printLap > Laps then
                        printLap = Laps
                    end

                    love.graphics.setColor(FontColor[1], FontColor[2], FontColor[3], 1)
                    love.graphics.print("Lap: " .. printLap, GraphicsWidth - 100, 40)

                    if MyItem then
                        local size = 100
                        local padding = 20
                        love.graphics.print("[return] to use", GraphicsWidth - size - padding, GraphicsHeight - size - padding - 20)
                        love.graphics.setColor(1, 1, 1, 0.9)
                        love.graphics.draw(MyItem.image, GraphicsWidth - size - padding, GraphicsHeight - size - padding, 0, size / MyItem.image:getWidth(), size / MyItem.image:getHeight(), 0, 0)
                    end
                end
            else
                love.graphics.print("Connecting...", GraphicsWidth / 2 - 50, GraphicsHeight / 2 - 20)
            end
        end, true
    )

    --love.graphics.setColor(1,1,1)
    --local scale = love.graphics.getWidth()/InterfaceWidth
    --love.graphics.draw(Scene.twoCanvas, InterfaceWidth/2,InterfaceHeight/2, 0, scale,scale, InterfaceWidth/2 - OffsetX, InterfaceHeight/2 - OffsetY)
end

function love.mousemoved(x,y, dx,dy)
    -- forward mouselook to Scene object for first person camera control
    -- Scene:mouseLook(x,y, dx,dy)
end
