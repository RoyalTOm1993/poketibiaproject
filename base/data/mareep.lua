
local mType = Game.createMonsterType("Mareep")
local pokemon = {}
pokemon.eventFile = false -- will try to load the file example.lua in data/scripts/pokemons/events
pokemon.eventFile = "default" -- will try to load the file test.lua in data/scripts/pokemons/events
pokemon.description = "a Mareep"
pokemon.experience = 243
pokemon.outfit = {
    lookType = 830
}

pokemon.health = 1640
pokemon.maxHealth = pokemon.health
pokemon.race = "electric"
pokemon.race2 = "none"
pokemon.corpse = 27040
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
    minimumLevel = 20,
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
    moveMagicAttackBase = 25,
    moveMagicDefenseBase = 15,
    catchChance = 250,
    canControlMind = 0,
    canLevitate = 0,
    canLight = 0,
    canCut = 0,
    canSmash = 0,
    canDig = 0,
    canTeleport = 0,
    canBlink = 0,
    isSurfable = 0,
    isRideable = 941,
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
{id = "screw", chance = 8000000, maxCount = 13},
{id = "electric box", chance = 3250000, maxCount = 1},
}

pokemon.moves = {
	{name = "melee", power = 3, interval = 2000},
    {name = "Charge", power = 7, interval = 50000},
    {name = "Tackle", power = 7, interval = 10000},
    {name = "Fire Punch", power = 7, interval = 25000},
    {name = "Cotton Spore", power = 7, interval = 45000},
    {name = "Thunder Shock", power = 7, interval = 10000},
    {name = "Thunderbolt", power = 9, interval = 20000},
    {name = "Thunder Punch", power = 7, interval = 25000},
    {name = "Signal Beam", power = 7, interval = 60000},
}



pokemon.attacks = {
	{name = "melee", power = 3, interval = 2000, chance = 100},
    {name = "Charge", power = 7, interval = 50000, chance = 100},
    {name = "Tackle", power = 7, interval = 10000, chance = 100},
    {name = "Fire Punch", power = 7, interval = 25000, chance = 100},
    {name = "Cotton Spore", power = 7, interval = 45000, chance = 100},
    {name = "Thunder Shock", power = 7, interval = 10000, chance = 100},
    {name = "Thunderbolt", power = 9, interval = 20000, chance = 100},
    {name = "Thunder Punch", power = 7, interval = 25000, chance = 100},
    {name = "Signal Beam", power = 7, interval = 60000, chance = 100},
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
