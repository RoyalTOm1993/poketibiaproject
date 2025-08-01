monsterLevelDamage = 0
monsterLevelExp = 0
monsterLevelSpeed = 0
monsterLevelHealth = 0
monsterLevelLoot = 0
monsterPrefix = ""

showScriptsLogInConsole = false

--- character creating client
femaleOutfit = 3116 -- 0 gender
maleOutfit = 3119 -- 1 gender

-- Server Statistics
-- time in seconds: 30 = 30 seconds, 0 = disabled
statsDumpInterval = 30
-- time in milliseconds: 10 = 0.01 sec, 0 = disabled
statsSlowLogTime = 10
-- time in milliseconds: 50 = 0.05 sec, 0 = disabled
statsVerySlowLogTime = 50

-- Combat settings
-- NOTE: valid values for worldType are: "pvp", "no-pvp" and "pvp-enforced"
worldType = "no-pvp"
hotkeyAimbotEnabled = true
cleanProtectionZones = true
protectionLevel = 1
killsToRedSkull = 3
killsToBlackSkull = 6
pzLocked = 60000
removeChargesFromRunes = true
timeToDecreaseFrags = 24 * 60 * 60 * 1000
whiteSkullTime = 15 * 60 * 1000
stairJumpExhaustion = 2000
experienceByKillingPlayers = false
expFromPlayersLevelRange = 75

-- Connection Config
-- NOTE: maxPlayers set to 0 means no limit
ip = "127.0.0.1"
bindOnlyGlobalAddress = false
loginProtocolPort = 7171
gameProtocolPort = 7172
statusProtocolPort = 7171
createCharacterPort = 7173
createAccountPort = 7174
maxPlayers = 0
motd = "Bem Vindo Ao PokeMaster!"
onePlayerOnlinePerAccount = true
allowClones = false
serverName = "PokeMaster"
statusTimeout = 5000
replaceKickOnLogin = true
maxPacketsPerSecond = 500 -- default 25

-- Deaths
-- NOTE: Leave deathLosePercent as -1 if you want to use the default
-- death penalty formula. For the old formula, set it to 10. For
-- no skill/experience loss, set it to 0.
deathLosePercent = -1

-- Houses
-- NOTE: set housePriceEachSQM to -1 to disable the ingame buy house functionality
housePriceEachSQM = 1000
houseRentPeriod = "never"

-- Item Usage
timeBetweenActions = 50
timeBetweenExActions = 50

-- Map
-- NOTE: set mapName WITHOUT .otbm at the end
mapName = "map2"
mapAuthor = ""

-- Market
marketOfferDuration = 30 * 24 * 60 * 60
premiumToCreateMarketOffer = false
checkExpiredMarketOffersEachMinutes = 60
maxMarketOffersAtATimePerPlayer = 100

-- MySQL
mysqlHost = "127.0.0.1"
mysqlUser = "root"
mysqlPass = ""
mysqlDatabase = "pokemaster"
mysqlPort = 3306
mysqlSock = ""
passwordType = "sha1"

-- Misc. 
allowChangeOutfit = true
freePremium = true
kickIdlePlayerAfterMinutes = 120
maxMessageBuffer = 4
emoteSpells = false
classicEquipmentSlots = false

-- Rates
-- NOTE: rateExp is not used if you have enabled stages in data/XML/stages.xml
rateExp = 10
rateSkill = 3
rateLoot = 10
rateMagic = 3
rateSpawn = 25

-- Monsters
deSpawnRange = 2
deSpawnRadius = 30

-- Stamina
staminaSystem = true

-- Scripts
warnUnsafeScripts = true
convertUnsafeScripts = true

-- Startup
-- NOTE: defaultPriority only works on Windows and sets process
-- priority, valid values are: "normal", "above-normal", "high"
defaultPriority = "high"
startupDatabaseOptimization = false

-- Status server information
ownerName = ""
ownerEmail = ""
url = "https://otland.net/"
location = "Sweden"
