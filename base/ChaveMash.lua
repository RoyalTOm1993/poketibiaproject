function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid) -- Create a Player object
    local playerStorage = 2236 -- Número da storage para verificar se o jogador já recebeu o item
    local rewardItemId = 17824 -- ID do item que o jogador ganhará

    if player:getStorageValue(playerStorage) ~= 1 then
        player:addItem(rewardItemId, 1)
        player:setStorageValue(playerStorage, 1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Parabéns, você achou 1 Chave.")
    else
        player:sendCancelMessage("Você já recebeu o item anteriormente.")
    end

    return true
end
