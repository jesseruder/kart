local cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/master/cs.lua'
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
        home.car.x = Car.x
        home.car.y = Car.y
        home.car.z = Car.z
        home.car.angle = Car.angle

        home.requestingStart = love.keyboard.isDown("space")
    end
end

function updateCarFromRemote(car, remote)
    car.size = remote.size
    car.vel = remote.vel
    car.color = remote.color
    car.x = remote.x
    car.y = remote.y
    car.z = remote.z
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

local otherCars = {}
NumPlayers = 0
function getMultiplayerUpdate()
    if client.connected then
        if share.isGameRunning then
            startGame()
        end

        IsRequestingStart = share.isRequestingStart

        for k,v in pairs(otherCars) do
            v.seenThisUpdate = false
        end

        NumPlayers = 0
        for id, car in pairs(share.cars) do
            NumPlayers = NumPlayers + 1
            if id ~= client.id or USE_REMOTE_CAR then -- Not me
                if not car and otherCard[id] then
                    removeCar(otherCars[id])
                    otherCards[id] = nil
                    break
                end

                if not otherCars[id] then
                    otherCars[id] = makeCar(car.color)
                end

                otherCars[id].seenThisUpdate = false
                updateCarFromRemote(otherCars[id], car)
                updateCarPosition(otherCars[id])
            end
        end

        for k,v in pairs(otherCars) do
            if v.seenThisUpdate == false then
                removeCar(otherCars[k])
                otherCars[k] = nil
            end
        end
    end
end
