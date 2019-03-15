require "constants"
require "levels.levels"

local cs = require 'share.cs'
local server = cs.server

if USE_CASTLE_CONFIG then
    server.useCastleConfig()
else
    server.enabled = true
    server.start('22122') -- Port of server
end

local share = server.share -- Maps to `client.share` -- can write
local homes = server.homes -- `homes[id]` maps to `client.home` for that `id` -- can read

local gameState = ACTUAL_GAME and "level_select" or "running"
local startTime = nil
local winner = nil
local bananas = {}
local shells = {}

function server.connect(id) -- Called on connect from client with `id`
    print('client ' .. id .. ' connected')
end

function server.disconnect(id) -- Called on disconnect from client with `id`
    print('client ' .. id .. ' disconnected')
    share.cars[id] = nil
end

function server.receive(id, ...) -- Called when client with `id` does `client.send(...)`
end

-- Server only gets `.load`, `.update`, `.quit` Love events (also `.lowmemory` and `.threaderror`
-- which are less commonly used)

function server.load()
    share.cars = {}

    if ACTUAL_GAME then
        share.level = nil
    else
        share.level = 1
        Levels[share.level].action()
    end
end

local time = 0
local floorTime = 0
local frames = 0
local ServerLogicAccumulator = 0.0
local ServerLogicRate = 60
local VERBOSE = false

function getVotedLevel()
    local levelVotes = {}
    for id, level in pairs(Levels) do
        levelVotes[id] = 0
    end

    for id, home in pairs(server.homes) do
        local l = home.requestingLevel
        if l >= 1 and l <= #Levels then
            levelVotes[l] = levelVotes[l] + 1
        end
    end

    local max = -1
    local maxIdx = 1
    for id, level in pairs(Levels) do
        if levelVotes[id] > max then
            max = levelVotes[id]
            maxIdx = id
        elseif levelVotes[id] == max and math.random() > 0.5 then
            maxIdx = id
        end
    end

    return maxIdx
end

function server.update(dt)
    ServerLogicAccumulator = ServerLogicAccumulator+dt
    if ServerLogicAccumulator >= 1/ServerLogicRate then
        dt = 1/LogicRate
        ServerLogicAccumulator = ServerLogicAccumulator - 1/LogicRate
    else
        return
    end

    time = time + dt
    frames = frames + 1
    local printThisFrame = false
    local lastFrames = frames
    if math.floor(time) > floorTime then
        floorTime = math.floor(time)
        if VERBOSE then
            print("time: " .. floorTime)
        end
        printThisFrame = true
        frames = 0
    end


    for cark, car in pairs(share.cars) do
        if car.hitByShellTime then
            car.hitByShellTime = car.hitByShellTime - dt
            if car.hitByShellTime < 0 then
                car.hitByShellTime = nil
            end
        end
    end

    if gameState == "level_select" and startTime and os.time() >= startTime then
        gameState = "intro"
        startTime = os.time() + 4
        bananas = {}
        shells = {}

        share.level = getVotedLevel()
        if CASTLE_SERVER then
            Levels[share.level].action()
        end
    end

    if gameState == "intro" and startTime and os.time() >= startTime then
        gameState = "countdown"
        startTime = os.time() + 4
        bananas = {}
        shells = {}
    end

    if gameState == "countdown" and startTime and os.time() >= startTime then
        gameState = "running"
        startTime = nil
        bananas = {}
        shells = {}
    end

    if gameState == "postgame" and startTime and os.time() >= startTime then
        gameState = "level_select"
        startTime = nil
        bananas = {}
        shells = {}
    end

    local isRequestingLevel = false
    local takenItems = {}
    local switchItemUsers = {}
    local dizzyItemUsers = {}

    for id, home in pairs(server.homes) do -- Combine mouse info from clients into share
        if home.car then
            if not share.cars[id] then
                share.cars[id] = home.car
            else
                -- don't overwite values set on the server
                share.cars[id].size = home.car.size
                share.cars[id].vel = home.car.vel
                share.cars[id].color = home.car.color
                share.cars[id].roadIndex = home.car.roadIndex
                share.cars[id].characterName = home.car.characterName
                share.cars[id].accessoryName = home.car.accessoryName
                share.cars[id].x = home.car.x
                share.cars[id].y = home.car.y
                share.cars[id].z = home.car.z
                share.cars[id].angle = home.car.angle
                share.cars[id].angleUp = home.car.angleUp
                share.cars[id].angleSide = home.car.angleSide
                share.cars[id].lap = home.lap
            end
        end

        if home.requestingLevel then
            isRequestingLevel = true
        end

        if home.takenItem then
            takenItems[home.takenItem] = true
        end

        if home.isFinished and gameState == "running" then
            gameState = "postgame"
            winner = id
            startTime = os.time() + 8
        end

        if home.switchItemEnabled then
            switchItemUsers[id] = true
        end

        if home.dizzyItemEnabled then
            dizzyItemUsers[id] = true
        end

        if home.addBanana then
            table.insert(bananas, home.addBanana)
        end

        if home.removeBanana then
            for k,v in pairs(bananas) do
                if v.id == home.removeBanana then
                    table.remove(bananas, k)
                    break
                end
            end
        end

        if home.addShell then
            table.insert(shells, home.addShell)
        end
    end

    for k, shell in pairs(shells) do
        local closestRoadIndex = 0
        local closestRoadDistance = 100000000000
        for idx = shell.roadIndex - 5, shell.roadIndex + 5 do
            local realIdx = idx
            if realIdx <= 0 then
                realIdx = realIdx + #PATH_POINTS
            end
            if realIdx > #PATH_POINTS then
                realIdx = realIdx - #PATH_POINTS
            end
    
            local rx = PATH_POINTS[realIdx][1] * RoadScale - RoadScale / 2.0
            local ry = PATH_POINTS[realIdx][2] * RoadScale - RoadScale / 2.0
            local distance = math.sqrt(math.pow(rx - shell.x, 2) + math.pow(ry - shell.z, 2))
            if distance < closestRoadDistance then
                closestRoadDistance = distance
                closestRoadIndex = realIdx
            end
        end
        shell.roadIndex = closestRoadIndex

        local nextRoadIndex = closestRoadIndex + 5
        if nextRoadIndex > #PATH_POINTS then
            nextRoadIndex = nextRoadIndex - #PATH_POINTS
        end

        local desiredX = PATH_POINTS[nextRoadIndex][1] * RoadScale - RoadScale / 2.0
        local desiredZ = PATH_POINTS[nextRoadIndex][2] * RoadScale - RoadScale / 2.0

        local hit = false
        for id, car in pairs(share.cars) do
            if id ~= shell.from then
                local dtocar = math.sqrt(math.pow(car.x - shell.x, 2) + math.pow(car.z - shell.z, 2) + math.pow(car.y - car.y, 2))
                if dtocar < 0.4 then
                    car.hitByShellTime = 2.0
                    table.remove(shells, k)
                    hit = true
                    break
                end

                if dtocar < 2 then
                    desiredX = car.x
                    desiredZ = car.z
                    break
                end
            end
        end

        if hit then
            break
        end

        local dx = desiredX - shell.x
        local dz = desiredZ - shell.z

        local SHELL_SPEED = 10

        local speed = math.sqrt(dx * dx + dz * dz)

        shell.velx = dx * SHELL_SPEED / speed
        shell.velz = dz * SHELL_SPEED / speed
        if VERBOSE and printThisFrame then
            print("velx:" .. shell.velx .. " velz:" .. shell.velz .. " speed:" .. speed .. "  dt:" .. dt .. "  frames:" .. lastFrames)
        end
        shell.x = shell.x + dt * shell.velx
        shell.z = shell.z + dt * shell.velz
    end

    share.gameState = gameState
    share.isRequestingLevel = startTime and isRequestingLevel
    share.takenItems = takenItems
    share.winner = winner
    share.switchItemUsers = switchItemUsers
    share.dizzyItemUsers = dizzyItemUsers
    share.bananas = bananas
    share.shells = shells

    if isRequestingLevel == true and gameState == "level_select" and not startTime then
        -- wait 3 seconds
        startTime = os.time() + 2
    end

    if isRequestingLevel == false and gameState == "level_select" then
        startTime = nil
    end
end