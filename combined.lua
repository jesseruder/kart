
USE_CASTLE_CONFIG = true

if CASTLE_SERVER or not USE_CASTLE_CONFIG then
    require 'server'
end

if not CASTLE_SERVER then
    require 'main'
end
