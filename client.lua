require "constants"
require "server"
Engine = require "engine"
require "car"
require "multiplayer"
require "items.items"
require "levels.levels"
require "assets"
require "characters.characters"
require "characters.accessories"

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
    Car.z = PATH_POINTS[1][2] * RoadScale - RoadScale / 2.0 + CAR_RANDOM_POS * math.random()
    Car.y = roadHeightAtPoint(Car.x, Car.y, 1).height + 0.3
    Car.angle = PATH_POINTS[1][3]
    Car.angleUp = 0
    Car.angleSide = 0
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
    preloadLevels()

    love.graphics.setCanvas()

    Scene = Engine.newScene(GraphicsWidth, GraphicsHeight)

    --loadGrassLevel()
    -- CHOOSE CHARACTER STUFF
    GameState = ACTUAL_GAME and "choose_character" or "waiting_to_get_server_state"
    LocalLevel = nil
    ChooseCharacterState = "main"
    FontColor = {1, 1, 1, 1}
    FogColor = {1,1,1,1}
    FogStartDist = 5
    FogDivide = 100

    CharacterIndex = 1
    for k,v in pairs(Characters) do
        --preload
        v.action()
    end
    AccessoryIndex = 1
    ColorIndex = 1
    Colors = {
        {128,0,0},
        {170,110,40},
        {128,128,0},
        {0,128,128},
        {0,0,128},
        {0,0,0},
        {230,25,75},
        {245,130,48},
        {225,225,25},
        {210,245,60},
        {60,180,75},
        {70,240,240},
        {0,130,200},
        {145,30,180},
        {240,50,230},
        {128,128,128},
        {250,190,190},
        {255,215,180},
        {255,250,200},
        {170,255,195},
        {230,190,255},
        {255,255,255}
    }
    
    Car = makeCar(Characters[CharacterIndex].name, "none")
    Car.x = 0
    Car.y = 0
    Car.z = 0
    Car.angle = 0
    Car.angleUp = 0
    Car.angleSide = 0

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


    --loadGrassLevel()
    --resetGame()
end

function recordLap()
    Lap = Lap + 1
    EligibleForNextLap = false
    if Lap > Laps then
        IsFinished = true
    end
end

function showAlert(text)
    AlertTime = 1.0
    AlertText = text
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
    if GameState == "choose_character" then
        local loadCharacter = false
        local dontResetRotation = false

        if ChooseCharacterState == "accessory" then
            if key == "left" then
                AccessoryIndex = AccessoryIndex - 1
                if AccessoryIndex <= 0 then
                    AccessoryIndex = #Accessories
                end
                loadCharacter = true
            elseif key == "right" then
                AccessoryIndex = AccessoryIndex + 1
                if AccessoryIndex > #Accessories then
                    AccessoryIndex = 1
                end
                loadCharacter = true
            elseif key == "up" then
                ColorIndex = ColorIndex - 1
                if ColorIndex <= 0 then
                    ColorIndex = #Colors
                end
                loadCharacter = true
                dontResetRotation = true
            elseif key == "down" then
                ColorIndex = ColorIndex + 1
                if ColorIndex > #Colors then
                    ColorIndex = 1
                end
                loadCharacter = true
                dontResetRotation = true
            elseif key == "return" then
                GameState = "waiting_to_get_server_state"
            end
        end

        if ChooseCharacterState == "main" then
            if key == "left" then
                CharacterIndex = CharacterIndex - 1
                if CharacterIndex <= 0 then
                    CharacterIndex = #Characters
                end
                loadCharacter = true
            elseif key == "right" then
                CharacterIndex = CharacterIndex + 1
                if CharacterIndex > #Characters then
                    CharacterIndex = 1
                end
                loadCharacter = true
            elseif key == "return" then
                ChooseCharacterState = "accessory"
                AccessoryIndex = 2
                loadCharacter = true
            end
        end

        if loadCharacter then
            if dontResetRotation == false then
                IntroCameraRotation = -math.pi/4
            end
            removeCar(Car)
            local color = Colors[ColorIndex]
            local newColor = {}
            newColor[1] = color[1] / 256.0
            newColor[2] = color[2] / 256.0
            newColor[3] = color[3] / 256.0
            Car = makeCar(Characters[CharacterIndex].name, Accessories[AccessoryIndex].name, newColor)
            Car.x = 0
            Car.y = 0
            Car.z = 0
            Car.angle = 0
            Car.angleUp = 0
            Car.angleSide = 0
        end

        return
    end

    if GameState == "running" and MyItem and key == "return" then
        MyItem.action()
        MyItem = nil
    end
end

function client.update(dt)
    TimeElapsed = TimeElapsed + dt
    -- Scene:basicCamera(dt)
    
    LogicAccumulator = LogicAccumulator+dt

    -- update 3d scene
    PhysicsStep = false
    if LogicAccumulator >= 1/LogicRate then
        dt = 1/LogicRate
        LogicAccumulator = LogicAccumulator - 1/LogicRate
        PhysicsStep = true
    else
        return
    end

    Scene:update()
    getMultiplayerUpdate(dt)
    
    if GameState == "choose_character" then
        ChooseCharacterCameraRotationDist = 1.0
        ChooseCharacterCameraRotationSpeed = 0.6
        local height = 0.4
        local speed = 0.9

        if ChooseCharacterState == "accessory" then
            ChooseCharacterCameraRotationDist = 1.5
            height = 0.6
        end

        local Camera = Engine.camera
        IntroCameraRotation = IntroCameraRotation + dt * ChooseCharacterCameraRotationSpeed
        Car.angle = -IntroCameraRotation
        Car.angleUp = 0
        Car.angleSide = 0

        local dx = Car.x + ChooseCharacterCameraRotationDist - Camera.pos.x
        local dz = Car.z - Camera.pos.z
        local dy = height - Camera.pos.y

        local s = 1--math.sqrt(dx*dx + dy*dy + dz*dz)

        Camera.pos.x = Camera.pos.x + speed * dx * dt / s
        Camera.pos.y = Camera.pos.y + speed * dy * dt / s
        Camera.pos.z = Camera.pos.z + speed * dz * dt / s

        Camera.angle.x = math.pi-math.atan2(Car.x - Camera.pos.x, Car.z - Camera.pos.z)
        Camera.angle.y = 0.3


        updateCarPosition(Car)
        return
    end

    if ServerLevel and ServerLevel ~= LocalLevel then
        Levels[ServerLevel].action()
        if ACTUAL_GAME == false then
            resetGame()
            makeItems(5)
        end
        LocalLevel = ServerLevel
    end

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

    if LocalLevel == nil then
        return
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
    if isDrift and Car.isTouchingGround then
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

    local oldCarX = Car.x
    local oldCarZ = Car.z
    Car.x = Car.x + Car.vel.x * dt
    Car.z = Car.z + Car.vel.z * dt

    local hap = roadHeightAtPoint(Car.x, Car.z, Car.roadIndex)
    local heightFront = roadHeightAtPoint(Car.x + Car.size * math.cos(Car.angle), Car.z + Car.size * math.sin(Car.angle), Car.roadIndex).height
    local heightSide = roadHeightAtPoint(Car.x + Car.size * math.cos(Car.angle - math.pi/2), Car.z + Car.size * math.sin(Car.angle - math.pi/2), Car.roadIndex).height
    local desiredAngleUp = math.atan2(heightFront - hap.height, Car.size)
    local desiredAngleSide = math.atan2(heightSide - hap.height, Car.size)
    local dAngleUp = desiredAngleUp - Car.angleUp
    local dAngleSide = desiredAngleSide - Car.angleSide
    local angleSpeed = 10


    --- HEIGHT CALCULATION
    local roadHeight = hap.height + CAR_EXTRA_Y

    if roadHeight > Car.y + 0.3 then
        print("hey dummy")
        Car.x = oldCarX
        Car.z = oldCarZ
        Car.y = roadHeightAtPoint(Car.x, Car.z, Car.roadIndex).height + CAR_EXTRA_Y
        Car.vel.x = 0
        Car.vel.z = 0
    else
        local firstOffGround = false
        if Car.isTouchingGround then
            if roadHeight < Car.y  then
                Car.isTouchingGround = false
                firstOffGround = true
                Car.vel.y = 0.0
            else
                Car.y = roadHeight
            end
        end

        if Car.isTouchingGround == false then
            Car.y = Car.y + Car.vel.y * dt
            Car.vel.y = Car.vel.y - GRAVITY * dt
            if Car.y < roadHeight then
                Car.y = roadHeight
                Car.isTouchingGround = true
            elseif firstOffGround then
                Car.vel.y = math.sin(Car.angleUp) * carSpeed / 2
            end
        end
    end
    Car.normal = hap.normal
    -- DONE HEIGHT CALC

    if Car.isTouchingGround then
        Car.angleUp = Car.angleUp + dt * dAngleUp * angleSpeed
        Car.angleSide = Car.angleSide + dt * dAngleSide * angleSpeed
    end

    local DIST_TO_CHECK_BACK = 100
    local DIST_TO_CHECK_FORWARD = 10
    local closestRoadIndex = 0
    local closestRoadDistance = 100000000000
    for idx = Car.roadIndex - DIST_TO_CHECK_BACK, Car.roadIndex + DIST_TO_CHECK_FORWARD do
        local realIdx = idx
        if realIdx <= 0 then
            realIdx = realIdx + #PATH_POINTS
        end
        if realIdx > #PATH_POINTS then
            realIdx = realIdx - #PATH_POINTS
        end

        local rx = PATH_POINTS[realIdx][1] * RoadScale - RoadScale / 2.0
        local rz = PATH_POINTS[realIdx][2] * RoadScale - RoadScale / 2.0
        local ry = PATH_POINTS[realIdx][5] + heightAtPoint(rx, rz).height
        local distance = math.sqrt(math.pow(rx - Car.x, 2) + math.pow(ry - Car.y, 2) + math.pow(rz - Car.z, 2))
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
        showAlert("Out of bounds!")
    end

    if Car.roadIndex > #PATH_POINTS * 0.4 and Car.roadIndex < #PATH_POINTS * 0.6 then
        EligibleForNextLap = true
    end

    if Car.roadIndex > 0 and Car.roadIndex < 5 and EligibleForNextLap == true then
        recordLap()
    end

    if closestRoadDistance > RoadRadius and Car.isTouchingGround then
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

    local carToTrack = Car
    if GameState == "postgame" and Winner and otherCars[Winner] then
        carToTrack = otherCars[Winner]
    end

    if GameState == "postgame" then
        IntroCameraRotation = IntroCameraRotation + dt * IntroCameraRotationSpeed
        desiredCamX = carToTrack.x + math.cos(IntroCameraRotation) * IntroCameraRotationDist
        desiredCamZ = carToTrack.z + math.sin(IntroCameraRotation) * IntroCameraRotationDist
    end

    local cdx = desiredCamX - CameraPos.x
    local cdz = desiredCamZ - CameraPos.z
    local camt = math.sqrt(math.pow(cdx, 2) + math.pow(cdz, 2))

    --if camt > 0.1 then
        CameraPos.x = CameraPos.x + dt * cameraSpeed * cdx-- / camt
        CameraPos.z = CameraPos.z + dt * cameraSpeed * cdz-- / camt
    --end
    desiredCamY = 1 + math.max(carToTrack.y,
        roadHeightAtPoint(CameraPos.x, CameraPos.z, carToTrack.roadIndex - 5, true).height,
        roadHeightAtPoint(CameraPos.x*0.25 + carToTrack.x*0.75, CameraPos.z*0.25 + carToTrack.z*0.75, carToTrack.roadIndex - 1, true).height,
        roadHeightAtPoint(CameraPos.x*0.75 + carToTrack.x*0.25, CameraPos.z*0.75 + carToTrack.z*0.25, carToTrack.roadIndex - 3, true).height,
        roadHeightAtPoint((CameraPos.x + carToTrack.x)/2.0, (CameraPos.z + carToTrack.z)/2.0, carToTrack.roadIndex - 2, true).height)

    if GameState == "running" then
        local cdy = desiredCamY - CameraPos.y
        CameraPos.y = CameraPos.y + dt * cameraSpeed * cdy
    else
        CameraPos.y = desiredCamY
    end

    Camera.angle.x = math.pi-math.atan2(carToTrack.x - CameraPos.x, carToTrack.z - CameraPos.z)

    Camera.angle.y = 0.3

    if not USE_REMOTE_CAR then
        updateCarPosition(Car)
    end

    sendMultiplayerUpdate()
    updateItems(dt)

    if GameCountdownTime then
        GameCountdownTime = GameCountdownTime + dt
    end

    if GameCountdownBright then
        GameCountdownBright = GameCountdownBright - dt * 2
    end

    if AlertTime then
        AlertTime = AlertTime - dt
        if AlertTime < 0.0 then
            AlertTime = nil
        end
    end
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

                if AlertTime then
                    love.graphics.setFont(HugeFont)
                    love.graphics.print(AlertText, GraphicsWidth / 2 - 350, GraphicsHeight / 2 - 50)
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

                if GameState == "choose_character" then
                    love.graphics.setFont(BigFont)
                    local text = "CHOOSE YOUR CHARACTER"
                    if ChooseCharacterState == "accessory" then
                        text = "CHOOSE YOUR ACCESSORY"
                        love.graphics.print("[LEFT] [RIGHT] to choose [UP] [DOWN] for color [ENTER] to select", GraphicsWidth / 2 - 350, GraphicsHeight - 80)
                    else
                        love.graphics.print("[LEFT] [RIGHT] to choose [ENTER] to select", GraphicsWidth / 2 - 235, GraphicsHeight - 80)
                    end
                    love.graphics.print(text, GraphicsWidth / 2 - 160, 100)
                    love.graphics.setFont(DefaultFont)
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
