local function isAnyPokemonNearby(position, radius, pokemons)
    local creatures = Game.getSpectators(position, false, false, radius, radius, radius, radius)
    for i = 1, #creatures do
        local creature = creatures[i]
        if creature:isMonster() and pokemons[creature:getName()] then
            return true
        end
    end
    return false
end

function onTime(interval)
    local bossPosition = {x = 3157, y = 3134, z = 8} -- Coordenadas do Boss Ho-oh
    local bossName = "Gengar Lua Superior Boss" -- Nome do Boss
    local range = 20 -- Range de busca de espectadores
    local pokemons = {[bossName] = true} -- Lista de Pokémon a serem verificados

    -- Verifica se há algum Pokémon nas proximidades
    if isAnyPokemonNearby(bossPosition, range, pokemons) then
        Game.broadcastMessage("[Boss Global] Event Boss Cancelado: " .. bossName .. " já está no local.")
        return true
    end

    -- Se não houver outro Pokémon nas proximidades, spawn o novo boss
    Game.createMonster(bossName, bossPosition)
    Game.broadcastMessage("[Boss Global] Um evento de boss começou! Prepare-se para enfrentar o " .. bossName .. "!")
    return true
end