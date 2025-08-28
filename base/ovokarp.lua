local btype = "pokeball"
local magikarp = {
    "Giant Magikarp A",
    "Giant Magikarp G",
    "Giant Magikarp K"
} -- Lista de Pokémon que podem ser recompensados

function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid)

    if not player then
        return true
    end

    local randomValue = math.random(1, 100) -- Gera um número aleatório entre 1 e 100
    local pokemonName = ""

    -- Defina a probabilidade de 5% para "Gian Magikarp A"
    if randomValue <= 5 then
        pokemonName = "Gian Magikarp A"
    else
        pokemonName = magikarp[math.random(2, 3)] -- 95% de chance para "Gian Magikarp G" ou "Gian Magikarp K"
    end

    local pokeball = doAddPokeball(cid, pokemonName)

    if pokeball then
        player:getPosition():sendMagicEffect(29)
        player:getPosition():sendMagicEffect(27)
        player:getPosition():sendMagicEffect(29)

        -- Remova o item utilizado da mochila do jogador
        item:remove(1)
        -- Envie uma mensagem global informando o jogador sobre o prêmio
        Game.broadcastMessage(player:getName() .. " abriu um ovo e ganhou um " .. pokemonName .. ".", MESSAGE_EVENT_ADVANCE)

    else
        player:sendCancelMessage("Erro ao adicionar o Pokémon. Contate um administrador.")
    end

    return true
end
