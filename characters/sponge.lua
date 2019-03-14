local carAssets = nil

function loadSpongeCharacter()
    if not carAssets then
        carAssets = {}
        carAssets["front"] = love.graphics.newImage("assets/characters/sponge/front.png")
        carAssets["side"] = love.graphics.newImage("assets/characters/sponge/side.png")
        carAssets["back"] = love.graphics.newImage("assets/characters/sponge/back.png")
        carAssets["top"] = carAssets["side"]
    end

    loadCarAssets(carAssets)
end