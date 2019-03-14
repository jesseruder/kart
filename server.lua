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

local gameState = ACTUAL_GAME and "intro" or "running"
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

function shuffle(tbl)
    local size = #tbl
    for i = size, 1, -1 do
        local rand = math.random(i)
        tbl[i], tbl[rand] = tbl[rand], tbl[i]
    end
    return tbl
  end

function server.load()
    share.cars = {}

    SortedLevels = {}
    for i=1, #Levels do
        SortedLevels[i] = i
    end
    --SortedLevels = shuffle(SortedLevels)
    SortedLevels = {3,1,2}
    LevelIndex = 1

    share.level = SortedLevels[LevelIndex]

    if CASTLE_SERVER then
        Levels[share.level].action()
    end
end

local time = 0
local floorTime = 0
local frames = 0

function server.update(dt)
    time = time + dt
    frames = frames + 1
    local printThisFrame = false
    local lastFrames = frames
    if math.floor(time) > floorTime then
        floorTime = math.floor(time)
        print("time: " .. floorTime)
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
        gameState = "intro"
        startTime = nil
        LevelIndex = LevelIndex + 1
        if LevelIndex > #Levels then
            LevelIndex = 1
        end
        share.level = SortedLevels[LevelIndex]

        if CASTLE_SERVER then
            Levels[share.level].action()
        end
        bananas = {}
        shells = {}
    end

    local isRequestingStart = false
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
                share.cars[id].characterName = home.car.characterName
                share.cars[id].accessoryName = home.car.accessoryName
                share.cars[id].x = home.car.x
                share.cars[id].y = home.car.y
                share.cars[id].z = home.car.z
                share.cars[id].angle = home.car.angle
            end
        end

        if home.requestingStart then
            isRequestingStart = true
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

        local SHELL_SPEED
        if CASTLE_SERVER then
            SHELL_SPEED = 1
        else
            SHELL_SPEED = 8
        end

        local speed = math.sqrt(dx * dx + dz * dz)

        shell.velx = dx * SHELL_SPEED / speed
        shell.velz = dz * SHELL_SPEED / speed
        if printThisFrame then
            print("velx:" .. shell.velx .. " velz:" .. shell.velz .. " speed:" .. speed .. "  dt:" .. dt .. "  frames:" .. lastFrames)
        end
        shell.x = shell.x + dt * shell.velx
        shell.z = shell.z + dt * shell.velz
        shell.y = heightAtPoint(shell.x, shell.z).height + 0.2
    end

    share.gameState = gameState
    share.isRequestingStart = startTime and isRequestingStart
    share.takenItems = takenItems
    share.winner = winner
    share.switchItemUsers = switchItemUsers
    share.dizzyItemUsers = dizzyItemUsers
    share.bananas = bananas
    share.shells = shells

    if isRequestingStart == true and gameState == "intro" and not startTime then
        -- wait 3 seconds
        startTime = os.time() + 2
    end

    if isRequestingStart == false and gameState == "intro" then
        startTime = nil
    end
end