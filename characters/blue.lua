local carAssets = nil

function loadSpongeCharacter()
    if not carAssets then
        carAssets = {}
        carAssets["front"] = love.graphics.newImage("assets/characters/blue/front.png")
        carAssets["side"] = love.graphics.newImage("assets/characters/blue/side.png")
        carAssets["top"] = love.graphics.newImage("assets/characters/blue/top.png")
        carAssets["back"] = carAssets["side"]
    end

    loadCarAssets(carAssets)
end