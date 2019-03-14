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
        home.car.characterName = Car.characterName
        home.car.accessoryName = Car.accessoryName
        home.car.x = Car.x
        home.car.y = Car.y
        home.car.z = Car.z
        home.car.angle = Car.angle

        home.requestingStart = love.keyboard.isDown("space") and not GameResetTimer
        home.isFinished = IsFinished

        home.takenItem = MyTakenItem

        home.switchItemEnabled = SwitchItemEnabledTime and true or false
        home.dizzyItemEnabled = DizzyItemEnabledTime and true or false
        home.addBanana = ServerAddBanana
        ServerAddBanana = nil
        home.removeBanana = ServerRemoveBanana
        ServerRemoveBanana = nil
        home.addShell = ServerAddShell
        ServerAddShell = nil
    end
end

function updateCarFromRemote(dt, car, remote)
    car.size = remote.size
    car.vel = remote.vel
    car.color = remote.color
    car.characterName = remote.characterName
    car.accessoryName = remote.accessoryName
    car.hitByShellTime = remote.hitByShellTime
    if car.serverX == remote.x and car.serverY == remote.y and car.serverZ == remote.z then
        car.x = car.x + remote.vel.x * dt
        car.z = car.z + remote.vel.z * dt
        car.y = heightAtPoint(car.x, car.z).height + CAR_EXTRA_Y
    else
        car.serverX = remote.x
        car.serverY = remote.y
        car.serverZ = remote.z

        car.x = remote.x
        car.y = remote.y
        car.z = remote.z
    end
    car.angle = remote.angle
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
        IsRequestingStart = share.isRequestingStart or false
        AllTakenItems = share.takenItems or {}
        Winner = share.winner
        AmIWinner = Winner == client.id
        SwitchItemUsers = share.switchItemUsers
        DizzyItemUsers = share.dizzyItemUsers
        Bananas = share.bananas
        Shells = share.shells

        for k,v in pairs(otherCars) do
            v.seenThisUpdate = false
        end

        NumPlayers = 0
        for id, car in pairs(share.cars) do
            NumPlayers = NumPlayers + 1
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
            else
                Car.hitByShellTime = car.hitByShellTime
            end
        end

        for k,v in pairs(otherCars) do
            if v.seenThisUpdate == false then
                print("remove car!")
                removeCar(otherCars[k])
                otherCars[k] = nil
            end
        end
    end
end
