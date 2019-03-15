
function preloadLevels()
    defaultSkybox = love.graphics.newImage("assets/levels/skybox.png")
    defaultRoad = love.graphics.newImage("assets/levels/road.png")
    defaultWall = love.graphics.newImage("assets/levels/wall.png")
    defaultWall:setWrap('repeat','repeat')

    imageFinishLine = love.graphics.newImage("assets/finish-line.png")
    imageFinishLine:setWrap('repeat','repeat')

    grassSkyboxImage = defaultSkybox
    grassTerrainImage = love.graphics.newImage("assets/levels/grass/ground.png")
    grassRoadImage = defaultRoad
    grassWallImage = defaultWall

    moonSkyboxImage = love.graphics.newImage("assets/levels/moon/skybox.png")
    moonTerrainImage = love.graphics.newImage("assets/levels/moon/ground.png")
    moonRoadImage = defaultRoad
    moonWallImage = love.graphics.newImage("assets/levels/moon/wall.png")
    moonWallImage:setWrap('repeat','repeat')

    waterSkyboxImage = defaultSkybox
    waterTerrainImage = love.graphics.newImage("assets/levels/water/ground.png")
    waterRoadImage = love.graphics.newImage("assets/levels/water/road.png")
end
