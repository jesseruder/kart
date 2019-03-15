require "levels_tools.road"
require "levels_tools.skybox"
require "levels_tools.terrain"
require "levels_tools.heightmap"

require "levels.moon"
require "levels.grass"
require "levels.water"
require "levels.rainbow"
require "levels.desert"
require "levels.snow"

Levels = {
    {name = "XP", action = loadGrassLevel},
    {name = "Moon", action = loadMoonLevel},
    {name = "Surf", action = loadWaterLevel},
    {name = "Rainbow", action = loadRainbowLevel},
    {name = "Desert", action = loadDesertLevel},
    {name = "Snow", action = loadSnowLevel}
}
