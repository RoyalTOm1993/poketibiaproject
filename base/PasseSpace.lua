local storageID = 532126

function onUse(player, item, fromPosition, target, toPosition, isHotkey)

    local valorDaStorage = player:getStorageValue(storageID)

    if valorDaStorage ~= 1 then
        player:setStorageValue(storageID, 1)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Voce ativou um ticket monster eterno.")
        item:remove(1)
        return true
    else
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Voce atingiu o limite para o ticket monster eterno.")
    end

    return false
end
