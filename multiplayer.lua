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
    end
end

function updateCarFromRemote(car, remote)
    print("update from remote")
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
function getMultiplayerUpdate()
    if client.connected then
        for id, car in pairs(share.cars) do
            print(id)
            if id ~= client.id then -- Not me
                print("found car!")
                if not otherCars[id] then
                    print("make car!")
                    otherCars[id] = makeCar()
                end

                updateCarFromRemote(otherCars[id], car)
                updateCarPosition(otherCars[id])
            end
        end
    end
end
