local cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/master/cs.lua'
local server = cs.server

if USE_CASTLE_CONFIG then
    server.useCastleConfig()
else
    server.enabled = true
    server.start('22122') -- Port of server
end

local share = server.share -- Maps to `client.share` -- can write
local homes = server.homes -- `homes[id]` maps to `client.home` for that `id` -- can read

local isGameRunning = false
local startTime = nil

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
end

function server.update(dt)
    if isGameRunning == false and startTime and os.time() >= startTime then
        isGameRunning = true
        startTime = nil
    end

    local isRequestingStart = false
    for id, home in pairs(server.homes) do -- Combine mouse info from clients into share
        if home.requestingStart then
            isRequestingStart = true
        end

        if home.car then
            share.cars[id] = home.car
            share.isGameRunning = isGameRunning
            share.isRequestingStart = startTime and isRequestingStart
        end
    end

    if isRequestingStart == true and isGameRunning == false and not startTime then
        -- wait 3 seconds
        startTime = os.time() + 2
    end

    if isRequestingStart == false then
        startTime = nil
    end
end