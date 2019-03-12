local cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/master/cs.lua'
local client = cs.client

client.useCastleConfig()

local share = client.share -- Maps to `server.share` -- can read
local home = client.home -- Maps to `server.homes[id]` with our `id` -- can write

function doMultiplayerUpdate()
    if client.connected then
        home.car.size = Car.size
        home.car.vel = Car.vel
        home.car.color = Car.color
        home.car.x = Car.x
        home.car.y = Car.y
        home.car.z = Car.z
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
end

function client.connect() -- Called on connect from server
    home.car = {}
    doMultiplayerUpdate()
    print("connected!")
end

function client.disconnect() -- Called on disconnect from server
    print("disconnected!")
end

function client.receive(...) -- Called when server does `server.send(id, ...)` with our `id`
end

local otherCars = {}
function updateMultiplayer()
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
