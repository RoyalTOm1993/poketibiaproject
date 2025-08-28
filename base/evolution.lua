local evolutions = {
    -- Pok�mon Inicial = { Pok�mon Evolu�do, ID da Pedra de Evolu��o }
    ["Pidgey"] = { "Pidgeot", 10034 },  -- Pidgey evolui para Pidgeot com a pedra de ID 10034
    ["Charmander"] = { "Charizard", 10035 },  -- Charmander evolui para Charizard com a pedra de ID 10035
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local pokemonName = player:getName()  -- O nome do jogador � o nome do Pok�mon

    -- Verificar se o Pok�mon est� na tabela de evolu��es
    if evolutions[pokemonName] then
        local evolvedPokemon = evolutions[pokemonName][1]
        local evolutionStone = evolutions[pokemonName][2]

        -- Verificar se o item utilizado � a pedra correta
        if item:getId() == evolutionStone then
            -- Verificar se o jogador tem a pedra no invent�rio
            if player:getItemCount(item:getId()) > 0 then
                -- Remover a pedra do invent�rio
                player:removeItem(item:getId(), 1)

                -- Alterar o nome do jogador para o Pok�mon evolu�do
                player:setName(evolvedPokemon)
                player:sendTextMessage(MESSAGE_INFO_DESCR, pokemonName .. " evoluiu para " .. evolvedPokemon .. "!")

                return true
            else
                player:sendTextMessage(MESSAGE_INFO_DESCR, "Voc� n�o tem a pedra necess�ria para evoluir!")
                return false
            end
        else
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Esta n�o � a pedra correta para evolu��o!")
            return false
        end
    end

    -- Caso o Pok�mon n�o esteja na tabela de evolu��es
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Este Pok�mon n�o pode evoluir com uma pedra!")
    return false
end
