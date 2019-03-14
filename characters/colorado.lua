local carAssets = nil

function loadColoradoCharacter()
    if not carAssets then
        carAssets = {}
        carAssets["front"] = love.graphics.newImage("assets/characters/colorado/front.png")
        carAssets["side"] = love.graphics.newImage("assets/characters/colorado/side.png")
        carAssets["top"] = love.graphics.newImage("assets/characters/colorado/top.png")
        carAssets["back"] = love.graphics.newCanvas(1,1)
        love.graphics.setCanvas(carAssets["back"])
        love.graphics.clear(unpack({0,0,0,1}))
        love.graphics.setCanvas()
    end

    loadCarAssets(carAssets)
end