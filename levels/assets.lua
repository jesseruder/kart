local obj_loader = require "obj.obj_loader"
local hat = require "assets.accessories.hat"

function preloadLevels()
    hatObject = obj_loader.load(hat)

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

    Levels[1].icon = love.graphics.newImage("assets/levels/grass/icon.png")
    Levels[2].icon = love.graphics.newImage("assets/levels/moon/icon.png")
    Levels[3].icon = love.graphics.newImage("assets/levels/water/icon.png")
end