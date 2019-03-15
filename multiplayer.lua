local cs = require 'share.cs'
client = cs.client

if USE_CASTLE_CONFIG then
    client.useCastleConfig()
else
    client.enabled = true
    client.start('127.0.0.1:22122') -- IP address ('127.0.0.1' is same computer) and port of server
end

local share = client.share -- Maps to `server.share` -- can read
local home = client.home -- Maps to `server.homes[id]` with our `id` -- can write

function sendMultiplayerUpdate()
    if client.connected then
        home.car.size = Car.size
        home.car.vel = Car.vel
        home.car.color = Car.color
        home.car.roadIndex = Car.roadIndex
        home.car.characterName = Car.characterName
        home.car.accessoryName = Car.accessoryName
        home.car.x = Car.x
        home.car.y = Car.y
        home.car.z = Car.z
        home.car.angle = Car.angle
        home.car.angleUp = Car.angleUp
        home.car.angleSide = Car.angleSide
        home.car.lap = Lap

        home.requestingLevel = MyRequestedLevel
        home.isFinished = IsFinished

        home.takenItem = MyTakenItem

        home.switchItemEnabled = SwitchItemEnabledTime and true or false
        home.dizzyItemEnabled = DizzyItemEnabledTime and true or false
        home.addBanana = ServerAddBanana
        home.removeBanana = ServerRemoveBanana
        home.addShell = ServerAddShell
    end
end

function updateCarFromRemote(dt, car, remote)
    car.size = remote.size
    car.vel = remote.vel
    car.color = remote.color
    car.roadIndex = remote.roadIndex
    car.characterName = remote.characterName
    car.accessoryName = remote.accessoryName
    car.hitByShellTime = remote.hitByShellTime
    if car.serverX == remote.x and car.serverY == remote.y and car.serverZ == remote.z then
        car.x = car.x + remote.vel.x * dt
        car.z = car.z + remote.vel.z * dt
    else
        car.serverX = remote.x
        car.serverY = remote.y
        car.serverZ = remote.z

        car.x = remote.x
        car.y = remote.y
        car.z = remote.z
    end

    -- need this for water level
    car.y = roadHeightAtPoint(car.x, car.z, car.roadIndex).height + CAR_EXTRA_Y
    car.angle = remote.angle
    car.angleUp = remote.angleUp
    car.angleSide = remote.angleSide
    car.lap = remote.lap
end

function client.connect() -- Called on connect from server
    home.car = {}
    sendMultiplayerUpdate()
    print("connected!")
end

function client.disconnect() -- Called on disconnect from server
    print("disconnected!")
end

function client.receive(...) -- Called when server does `server.send(id, ...)` with our `id`
end

otherCars = {}
NumPlayers = 0
function getMultiplayerUpdate(dt)
    if client.connected then
        ServerGameState = share.gameState
        ServerLevel = share.level
        IsRequestingLevel = share.isRequestingLevel or false
        AllTakenItems = share.takenItems or {}
        Winner = share.winner
        AmIWinner = Winner == client.id
        SwitchItemUsers = share.switchItemUsers
        DizzyItemUsers = share.dizzyItemUsers
        Bananas = share.bananas
        Shells = share.shells
        ServerAcks = share.acks

        if ServerAddBanana and ServerAcks[ServerAddBanana.id] then
            ServerAddBanana = nil
        end

        if ServerRemoveBanana and ServerAcks[ServerRemoveBanana.id] then
            ServerRemoveBanana = nil
        end

        if ServerAddShell and ServerAcks[ServerAddShell.id] then
            ServerAddShell = nil
        end

        for k,v in pairs(otherCars) do
            v.seenThisUpdate = false
        end

        NumPlayers = 0
        local carsAheadOfMe = 0

        for id, car in pairs(share.cars) do
            NumPlayers = NumPlayers + 1
            if GameState == "running" then
                if id ~= client.id or USE_REMOTE_CAR then -- Not me
                    if not car and otherCard[id] then
                        removeCar(otherCars[id])
                        print("remove car!")
                        otherCards[id] = nil
                        break
                    end

                    if not otherCars[id] then
                        print("make car " .. id)
                        otherCars[id] = makeCar(car.characterName, car.accessoryName, car.color)
                    end

                    otherCars[id].seenThisUpdate = true
                    updateCarFromRemote(dt, otherCars[id], car)
                    updateCarPosition(otherCars[id])

                    if car.lap and Lap and car.roadIndex and Car.roadIndex then
                        if car.lap > Lap then
                            carsAheadOfMe = carsAheadOfMe + 1
                        elseif car.roadIndex > Car.roadIndex then
                            carsAheadOfMe = carsAheadOfMe + 1
                        end
                    end
                else
                    Car.hitByShellTime = car.hitByShellTime
                end
            end
        end

        MyPlace = carsAheadOfMe + 1

        if GameState == "running" then
            for k,v in pairs(otherCars) do
                if v.seenThisUpdate == false then
                    print("remove car!")
                    removeCar(otherCars[k])
                    otherCars[k] = nil
                end
            end
        end
    end
end
