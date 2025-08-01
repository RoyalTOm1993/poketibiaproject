
local mType = Game.createMonsterType("Kabutops")
local pokemon = {}
pokemon.eventFile = false -- will try to load the file example.lua in data/scripts/pokemons/events
pokemon.eventFile = "default" -- will try to load the file test.lua in data/scripts/pokemons/events
pokemon.description = "a Kabutops"
pokemon.experience = 4583
pokemon.outfit = {
    lookType = 141
}

pokemon.health = 14796
pokemon.maxHealth = pokemon.health
pokemon.race = "rock"
pokemon.race2 = "water"
pokemon.corpse = 27002
pokemon.speed = 180
pokemon.maxSummons = 0

pokemon.changeTarget = {
    interval = 4*1000,
    chance = 20
}
pokemon.wild = {
    health = pokemon.health * 1.8,
    maxHealth = pokemon.health * 1.8,
    speed = 220
}

pokemon.flags = {
    minimumLevel = 80,
    attackable = true,
    summonable = true,
    passive = false,
    hostile = true,
    convinceable = true,
    illusionable = true,
    canPushItems = false,
    canPushCreatures = false,
    targetDistance = 1,
    staticAttackChance = 97,
    pokemonRank = "",
    hasShiny = 1,
    hasMega = 0,
    moveMagicAttackBase = 145,
    moveMagicDefenseBase = 115,
    catchChance = 250,
    canControlMind = 0,
    canLevitate = 0,
    canLight = 0,
    canCut = 0,
    canSmash = 0,
    canDig = 0,
    canTeleport = 0,
    canBlink = 0,
    isSurfable = 178,
    isRideable = 0,
    isFlyable = 0,
}

pokemon.events = {
    "MonsterHealthChange"
}
pokemon.summons = {}

pokemon.voices = {
    interval = 5000,
    chance = 65,
    {text = "ABUUUH!", yell = FALSE},
}

pokemon.loot = {
{id = "small stone", chance = 8000000, maxCount = 13},
{id = "stone orb", chance = 3250000, maxCount = 1},
{id = "rock stone", chance = 150000, maxCount = 1},
{id = "water gem", chance = 8000000, maxCount = 13},
{id = "water pendant", chance = 3250000, maxCount = 1},
{id = "water stone", chance = 150000, maxCount = 1}
}

pokemon.moves = {
	{name = "melee", power = 3, interval = 2000},
    {name = "Ancient Absorb", power = 7, interval = 10000},
    {name = "Leech Life", power = 7, interval = 20000},
    {name = "Rock Throw", power = 12, interval = 10000},
    {name = "Aqua Jet", power = 12, interval = 30000},
    {name = "Mud Shot", power = 9, interval = 15000},
    {name = "X-Scissor", power = 15, interval = 25000},
    {name = "Liquidation", power = 20, interval = 25000},
    {name = "Ancient Power", power = 20, interval = 35000},
}



pokemon.attacks = {
	{name = "melee", power = 3, interval = 2000, chance = 100},
    {name = "Ancient Absorb", power = 7, interval = 10000, chance = 100},
    {name = "Leech Life", power = 7, interval = 20000, chance = 100},
    {name = "Rock Throw", power = 12, interval = 10000, chance = 100},
    {name = "Aqua Jet", power = 12, interval = 30000, chance = 100},
    {name = "Mud Shot", power = 9, interval = 15000, chance = 100},
    {name = "X-Scissor", power = 15, interval = 25000, chance = 100},
    {name = "Liquidation", power = 20, interval = 25000, chance = 100},
    {name = "Ancient Power", power = 20, interval = 35000, chance = 100},
}



pokemon.defenses = {}

pokemon.elements = {}

pokemon.immunities = {}

mType.onThink = function(pokemon, interval)
end

mType.onAppear = function(pokemon, creature)
end

mType.onDisappear = function(pokemon, creature)
end

mType.onMove = function(pokemon, creature, fromPosition, toPosition)
end

mType.onSay = function(pokemon, creature, type, message)
end

mType:register(pokemon)
