local bosses = {
    {
        name = "Jocker Outfit",
        storage = 61401,
        maxCount = 100,
        outfit = 3764
    },
    {
        name = "Motoqueiro Outfit",
        storage = 61402,
        maxCount = 100,
        outfit = 3502
    },
    {
        name = "Mumia Outfit",
        storage = 61403,
        maxCount = 100,
        outfit = 3691
    },
    {
        name = "Nasus Outfit",
        storage = 61404,
        maxCount = 100,
        outfit = 3688
    },
    {
        name = "Boneco Sasori Outfit",
        storage = 61405,
        maxCount = 100,
        outfit = 3129
    },
    {
        name = "Deidara Outfit",
        storage = 61406,
        maxCount = 100,
        outfit = 3124
    },
    {
        name = "Hagoromo Outfit",
        storage = 61407,
        maxCount = 100,
        outfit = 3301
    },
    {
        name = "Itachi Outfit",
        storage = 61408,
        maxCount = 100,
        outfit = 3125
    },
    {
        name = "Kisame Outfit",
        storage = 61409,
        maxCount = 100,
        outfit = 3126
    },
    {
        name = "Sasori Outfit",
        storage = 61410,
        maxCount = 100,
        outfit = 3128
    },
    {
        name = "Tobi Outfit",
        storage = 61411,
        maxCount = 100,
        outfit = 3127
    },	
}

function onKill(player, target)
    if isPlayer(player) then
        local creatureName = getCreatureName(target)

        for _, boss in ipairs(bosses) do
            if creatureName == boss.name then
                local currentCount = player:getStorageValue(boss.storage)

                -- Check if the player hasn't reached the maximum count
                if currentCount < boss.maxCount then
                    local remainingCount = boss.maxCount - currentCount
                    -- Update player storage value
                    player:setStorageValue(boss.storage, currentCount + 1)

                    -- Informative message to the player
                    local monsterFormatted = boss.name:gsub("(%a)([%w_']*)", function(first, rest)
                        return first:upper() .. rest:lower()
                    end)
                    local message = string.format("[Outfit Task] Voce derrotou um %s. Voce ja derrotou %d %s. Faltam %d para completar o desafio.",
                        monsterFormatted, currentCount + 1, monsterFormatted, remainingCount)
                    player:sendTextMessage(MESSAGE_INFO_DESCR, message)

                    -- Check if the player reached the maximum count
                    if currentCount + 1 == boss.maxCount then
                        -- Give the Pokémon outfit to the player
                        player:addOutfit(boss.outfit)

                        -- Inform the player with a global message
                        broadcastMessage(string.format("[Outfit Task] Parabéns! O jogador %s ganhou a outfit do %s por derrotar %d %s. Desafio completado!",
                            player:getName(), boss.name, boss.maxCount, monsterFormatted), MESSAGE_EVENT_ADVANCE)

                        -- Global message after the player defeats the boss
                        broadcastMessage(string.format("[Outfit Task] %s derrotou o %s!",
                            player:getName(), monsterFormatted), MESSAGE_EVENT_ADVANCE)
                    end
                else
                    -- Inform the player that further kills won't be counted
                    local maxReachedMessage = "[Outfit Task] Voce ja derrotou o numero maximo de " .. boss.name .. "."
                    player:sendTextMessage(MESSAGE_INFO_DESCR, maxReachedMessage)
                end
                break
            end
        end
    end
    return true
end
