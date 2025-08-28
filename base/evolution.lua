local evolutions = {
    -- Pokémon Inicial = { Pokémon Evoluído, ID da Pedra de Evolução }
    ["Pidgey"] = { "Pidgeot", 10034 },  -- Pidgey evolui para Pidgeot com a pedra de ID 10034
    ["Charmander"] = { "Charizard", 10035 },  -- Charmander evolui para Charizard com a pedra de ID 10035
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local pokemonName = player:getName()  -- O nome do jogador é o nome do Pokémon

    -- Verificar se o Pokémon está na tabela de evoluções
    if evolutions[pokemonName] then
        local evolvedPokemon = evolutions[pokemonName][1]
        local evolutionStone = evolutions[pokemonName][2]

        -- Verificar se o item utilizado é a pedra correta
        if item:getId() == evolutionStone then
            -- Verificar se o jogador tem a pedra no inventário
            if player:getItemCount(item:getId()) > 0 then
                -- Remover a pedra do inventário
                player:removeItem(item:getId(), 1)

                -- Alterar o nome do jogador para o Pokémon evoluído
                player:setName(evolvedPokemon)
                player:sendTextMessage(MESSAGE_INFO_DESCR, pokemonName .. " evoluiu para " .. evolvedPokemon .. "!")

                return true
            else
                player:sendTextMessage(MESSAGE_INFO_DESCR, "Você não tem a pedra necessária para evoluir!")
                return false
            end
        else
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Esta não é a pedra correta para evolução!")
            return false
        end
    end

    -- Caso o Pokémon não esteja na tabela de evoluções
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Este Pokémon não pode evoluir com uma pedra!")
    return false
end
