function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item.itemid ~= 1945 then
        return false
    end

    local config = {
        [20699] = {pokemon = "Malefic Articuno"},
        [20700] = {pokemon = "Malefic Zapdos"},
        [20701] = {pokemon = "Malefic Moltres"}
    }

    local spawnPosition = Position(3224, 3133, 8)
    local radius = 10
    local spawned = false

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

    local allPokemons = { ["Malefic Articuno"] = true, ["Malefic Zapdos"] = true, ["Malefic Moltres"] = true }

    if isAnyPokemonNearby(spawnPosition, radius, allPokemons) then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Já existe um Pokémon especial nas proximidades.")
        return true
    end

    for itemId, data in pairs(config) do
        if player:getItemCount(itemId) > 0 then
            local monster = Game.createMonster(data.pokemon, spawnPosition)
            if monster then
                player:removeItem(itemId, 1)
                local message = "Atenção jogadores! " .. player:getName() .. " spawnou um " .. monster:getName() .. " na area malefics!"
                Game.broadcastMessage(message, MESSAGE_EVENT_ADVANCE)
                player:sendTextMessage(MESSAGE_INFO_DESCR, "Você spawnou um " .. monster:getName() .. ".")
                spawned = true
                break
            else
                player:sendTextMessage(MESSAGE_INFO_DESCR, "Não foi possível spawnar o Pokémon.")
            end
        end
    end

    if not spawned then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Você não tem nenhum item necessário para spawnar um Pokémon.")
    end

    return true
end
