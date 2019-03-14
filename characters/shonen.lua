function loadShonenCharacter()
    carFront = love.graphics.newImage("assets/characters/shonen/front.png")
    carSide = love.graphics.newImage("assets/characters/shonen/side.png")
    carTop = love.graphics.newImage("assets/characters/shonen/top.png")

    carBack = love.graphics.newCanvas(1,1)
    love.graphics.setCanvas(carBack)
    love.graphics.clear(unpack({0,0,0,1}))
    love.graphics.setCanvas()
end