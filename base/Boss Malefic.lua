local boss = {
    name = "Malefic Lugia Boss",
    storage = 51494,
    maxCount = 5,
    rewardPokemon = "Malefic Lugia"
}

function onKill(player, target)
    if isPlayer(player) then
        local creatureName = getCreatureName(target)

        -- Check if the killed creature is the specified boss
        if creatureName == boss.name then
            local currentCount = player:getStorageValue(boss.storage)

            -- Check if the player hasn't reached the maximum count
            if currentCount < boss.maxCount then
                -- Update player storage value
                player:setStorageValue(boss.storage, currentCount + 1)

                -- Informative message to the player
                local monsterFormatted = boss.name:gsub("(%a)([%w_']*)", function(first, rest)
                    return first:upper() .. rest:lower()
                end)
                local message = string.format("[Boss Global] Voce derrotou um %s. Voce ja derrotou %d %s Boss.",
                    monsterFormatted, currentCount + 1, monsterFormatted)
                player:sendTextMessage(MESSAGE_INFO_DESCR, message)

                -- Check if the player reached the maximum count
                if currentCount + 1 == boss.maxCount then
                    -- Award the Pokémon to the player
                    doAddPokeball(player, boss.rewardPokemon, 1)

                    -- Inform the player with a global message
                    broadcastMessage(string.format("[Boss Global] Parabéns! O jogador %s ganhou o Pokémon %s por derrotar %d %s Boss. Evento Finalizado!",
                        player:getName(), boss.rewardPokemon, boss.maxCount, monsterFormatted), MESSAGE_EVENT_ADVANCE)

                    -- Global message after the player defeats the boss
                    broadcastMessage(string.format("[Boss Global] %s derrotou o %s!",
                        player:getName(), monsterFormatted), MESSAGE_EVENT_ADVANCE)
                end
            else
                -- Inform the player that further kills won't be counted
                local maxReachedMessage = "[Boss Global] Voce ja derrotou o numero maximo de " .. boss.name .. " Boss permitido."
                player:sendTextMessage(MESSAGE_INFO_DESCR, maxReachedMessage)
            end
        end
    end
    return true
end
