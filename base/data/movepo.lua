local questStorage = 505050

function onStepIn(creature, item, position, fromPosition)
    -- Verifica se a criatura � um jogador
    if not creature or not creature:isPlayer() then
        return true
    end

    -- Obt�m o jogador corretamente
    local player = creature:getPlayer()

    -- Verifica se o storage N�O � 1
    if player:getStorageValue(questStorage) ~= 2 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voce precisa falar com o Professor Oak e escolher um pokemon inicial antes de prosseguir!")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Voce precisa falar com o Professor Oak e escolher um pokemon inicial antes de prosseguir!")
        player:teleportTo(fromPosition, true) -- Teleporta o jogador de volta
        return false
    end

    return true
end
