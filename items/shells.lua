
function makeShell()
    local x = Car.x + math.cos(Car.angle) * 1
    local z = Car.z + math.sin(Car.angle) * 1
    local y = Car.y + 0.2
    ServerAddShell = {x = x, y = y, z = z, roadIndex = Car.roadIndex, from = client.id, id = "shell" .. math.floor(math.random() * 1000000)}
end

function updateShells(dt)
    for k,v in pairs(LocalShells) do
        v.seen = false
    end

    if Shells then
        for k,v in pairs(Shells) do
            local id = v.id
            if LocalShells[id] then
                LocalShells[id].seen = true
                if LocalShells[id].serverX == v.x and LocalShells[id].serverY == v.y and LocalShells[id].serverZ == v.z then
                    LocalShells[id].x = LocalShells[id].x + v.velx * dt
                    LocalShells[id].z = LocalShells[id].z + v.velz * dt
                else
                    LocalShells[id].serverX = v.x
                    LocalShells[id].serverY = v.y
                    LocalShells[id].serverZ = v.z

                    LocalShells[id].x = v.x
                    LocalShells[id].y = v.y
                    LocalShells[id].z = v.z
                end

                -- need this for water level
                LocalShells[id].roadIndex = v.roadIndex
                LocalShells[id].y = roadHeightAtPoint(LocalShells[id].x, LocalShells[id].z, v.roadIndex, true).height + 0.4

                for k,model in pairs(LocalShells[id].models) do
                    model:setTransform({LocalShells[id].x, LocalShells[id].y, LocalShells[id].z}, {0, cpml.vec3.unit_y})
                end
            else
                addShell(v)
            end
        end
    end

    for k,v in pairs(LocalShells) do
        if v.seen == false then
            for modelNum,model in pairs(v.models) do
                model.dead = true
            end

            LocalShells[k] = nil
        end
    end
end

function addShell(serverShell)
    local color = {1.0, 0.0, 0.0, 1.0}
    local size = 0.1

    local verts= {}

    addRectVerts(verts, {
        {-1, -1, 1,   0,0},
        {-1, 1, 1,    0,1},
        {1, 1, 1,     1,1},
        {1, -1, 1,    1,0}
    })

    addRectVerts(verts, {
        {-1, -1, -1,  0,0},
        {-1, 1, -1,   0,1},
        {1, 1, -1,    1,1},
        {1, -1, -1,   1,0}
    })

    addRectVerts(verts, {
        {-1, -1, 1,   0,0},
        {-1, 1, 1,    0,1},
        {-1, 1, -1,   1,1},
        {-1, -1, -1,   1,0}
    })

    addRectVerts(verts, {
        {1, -1, 1,    0,0},
        {1, 1, 1,     0,1},
        {1, 1, -1,    1, 1},
        {1, -1, -1,   1,0}
    })

    local model = modelFromCoordsColor(verts, color, size)
    local models = {model}

    for k,v in pairs(models) do
        v:setTransform({serverShell.x, serverShell.y, serverShell.z}, {0, cpml.vec3.unit_y})
    end

    LocalShells[serverShell.id] = {
        models = models,
        seen = true,
        roadIndex = serverShell.roadIndex,
        x = serverShell.x,
        y = serverShell.y,
        z = serverShell.z,
    }
end