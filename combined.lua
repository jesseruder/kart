
USE_CASTLE_CONFIG = false
USE_REMOTE_CAR = false
ACTUAL_GAME = false

RESET_CAR = true
PLAY_MUSIC = false

if CASTLE_SERVER or not USE_CASTLE_CONFIG then
    require 'server'
end

if not CASTLE_SERVER then
    require 'main'
end
