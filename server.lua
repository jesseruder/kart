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
    for id, home in pairs(server.homes) do -- Combine mouse info from clients into share
        if home.car then
            share.cars[id] = home.car
        end
    end
end