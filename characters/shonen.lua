local carAssets = nil

function loadShonenCharacter()
    if not carAssets then
        carAssets = {}
        carAssets["front"] = love.graphics.newImage("assets/characters/shonen/front.png")
        carAssets["side"] = love.graphics.newImage("assets/characters/shonen/side.png")
        carAssets["top"] = love.graphics.newImage("assets/characters/shonen/top.png")
        carAssets["back"] = love.graphics.newCanvas(1,1)
        love.graphics.setCanvas(carAssets["back"])
        love.graphics.clear(unpack({0,0,0,1}))
        love.graphics.setCanvas()
    end

    loadCarAssets(carAssets)
end