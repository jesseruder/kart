require "levels_tools.road"
require "levels_tools.skybox"
require "levels_tools.terrain"
require "levels_tools.heightmap"

require "levels.moon"
require "levels.grass"
require "levels.water"
require "levels.rainbow"

Levels = {
    {name = "grass", action = loadGrassLevel},
    {name = "moon", action = loadMoonLevel},
    {name = "water", action = loadWaterLevel}
    {name = "rainbow", action = loadRainbowLevel}
}
