require "characters.anime"
require "characters.shonen"
require "characters.colorado"
require "characters.sponge"
require "characters.blue"

Characters = {
    {name = "shonen", action=loadShonenCharacter},
    {name = "anime", action=loadAnimeCharacter},
    {name = "colorado", action=loadColoradoCharacter},
    {name = "sponge", action=loadSpongeCharacter},
    {name = "blue", action=loadBlueCharacter},
}

function nameToCharacter(name)
    for k,v in pairs(Characters) do
        if v.name == name then
            return v
        end
    end
end
