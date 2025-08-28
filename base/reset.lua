function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    local storageToBeRemoved = 102231
    local storageToBeAdded = 102331
    local storagesToRemove = 100

    local currentAddedValue = player:getStorageValue(storageToBeAdded)

    if player:getStorageValue(storageToBeRemoved) >= storagesToRemove then
        -- Primeira troca: ganha 2 do storage 102131, se for trocas subsequentes, adiciona 1
        if currentAddedValue == 0 then
            player:setStorageValue(storageToBeAdded, 1) -- Alterado de 0 para 1
        else
            player:setStorageValue(storageToBeAdded, currentAddedValue + 1)
        end

        -- Remove os 100 storages
        player:setStorageValue(storageToBeRemoved, player:getStorageValue(storageToBeRemoved) - storagesToRemove)

        -- Adiciona o item com ID 22787 (Mega Reset)
        player:addItem(22787, 1)

        -- Notificações
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Você perdeu 100 Resets e agora tem " .. player:getStorageValue(storageToBeAdded) .. " Mega Reset(s) e recebeu uma box held t20.")
        local playerName = player:getName()
        Game.broadcastMessage("[MegaReset] " .. playerName .. " realizou uma troca e agora tem " .. player:getStorageValue(storageToBeAdded) .. " Mega Reset(s) e recebeu uma box held t20!")
    else
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você não tem resets suficientes para fazer esta troca.")
    end

    return true
end
