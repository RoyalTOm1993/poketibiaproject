
local mType = Game.createMonsterType("Girafarig")
local pokemon = {}
pokemon.eventFile = false -- will try to load the file example.lua in data/scripts/pokemons/events
pokemon.eventFile = "default" -- will try to load the file test.lua in data/scripts/pokemons/events
pokemon.description = "a Girafarig"
pokemon.experience = 4583
pokemon.outfit = {
    lookType = 879
}

pokemon.health = 14796
pokemon.maxHealth = pokemon.health
pokemon.race = "normal"
pokemon.race2 = "psychic"
pokemon.corpse = 27064
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
    isSurfable = 0,
    isRideable = 942,
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
{id = "enchanted gem", chance = 8000000, maxCount = 13},
{id = "future orb", chance = 3250000, maxCount = 1},
{id = "darkness stone", chance = 150000, maxCount = 1},
{id = "rubber ball", chance = 8000000, maxCount = 13},
{id = "bitten apple", chance = 3250000, maxCount = 1},
{id = "heart stone", chance = 150000, maxCount = 1},
}

pokemon.moves = {
	{name = "melee", power = 3, interval = 2000},
    {name = "Tackle", power = 7, interval = 10000},
    {name = "Crunch", power = 9, interval = 10000},
    {name = "Shadow Ball", power = 7, interval = 10000},
    {name = "Foul Play", power = 12, interval = 30000},
    {name = "Shock Wave", power = 10, interval = 25000},
    {name = "Astonish", power = 17, interval = 25000},
    {name = "Assurance", power = 20, interval = 50000},
    {name = "Nasty Plot", power = 15, interval = 25000},
    {name = "Reflect", power = 0, interval = 60000},
    {name = "Agility", power = 0, interval = 40000},
}



pokemon.attacks = {
	{name = "melee", power = 3, interval = 2000, chance = 100},
    {name = "Tackle", power = 7, interval = 10000, chance = 100},
    {name = "Crunch", power = 9, interval = 10000, chance = 100},
    {name = "Shadow Ball", power = 7, interval = 10000, chance = 100},
    {name = "Foul Play", power = 12, interval = 30000, chance = 100},
    {name = "Shock Wave", power = 10, interval = 25000, chance = 100},
    {name = "Astonish", power = 17, interval = 25000, chance = 100},
    {name = "Assurance", power = 20, interval = 50000, chance = 100},
    {name = "Nasty Plot", power = 15, interval = 25000, chance = 100},
    {name = "Reflect", power = 0, interval = 60000, chance = 100},
    {name = "Agility", power = 0, interval = 40000, chance = 100},
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
