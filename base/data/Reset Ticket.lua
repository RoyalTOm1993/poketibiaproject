function onUse(player, item, fromPosition, target, toPosition)
    -- Define a quantidade a ser adicionada para cada storage
    local storageReset = 2
    local storageResetPoints = 4
    
    player:setStorageValue(102231, player:getStorageValue(102231) + storageReset)
    player:setStorageValue(32070, player:getStorageValue(32070) + storageResetPoints)
    
    item:remove(1)
    
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voce Recebeu 2 Resets e 4 Reset Points.!")
    
    return true 
end
