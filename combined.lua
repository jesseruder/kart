
USE_CASTLE_CONFIG = false
USE_REMOTE_CAR = false
ACTUAL_GAME = true

RESET_CAR = true
PLAY_MUSIC = true

-- for capping game logic at 60 manually
LogicRate = 60
LogicAccumulator = 0
PhysicsStep = true
GridSize = 0.5
SkyboxHeight = 30
CAR_RANDOM_POS = 0.8
MotionBlurAmount = 0.0
CAR_EXTRA_Y = 0.15

IntroCameraRotation = -math.pi/4
IntroCameraRotationDist = 5
IntroCameraRotationSpeed = 0.2
ChooseCharacterCameraRotationDist = 1.0
ChooseCharacterCameraRotationSpeed = 0.6

if CASTLE_SERVER or not USE_CASTLE_CONFIG then
    require 'server'
end

if not CASTLE_SERVER then
    require 'main'
end
