local carAssets = nil

function loadAnimeCharacter()
    if not carAssets then
        carAssets = {}
        carAssets["front"] = love.graphics.newImage("assets/characters/anime/front.png")
        carAssets["side"] = love.graphics.newImage("assets/characters/anime/side.png")
        carAssets["back"] = love.graphics.newImage("assets/characters/anime/back.png")
        carAssets["top"] = carAssets["side"]
    end

    loadCarAssets(carAssets)
end