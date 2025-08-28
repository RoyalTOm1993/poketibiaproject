function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid)
    local antes = player:getStorageValue(10020)

    if antes == -1 then
        Game.broadcastMessage("O jogador " .. player:getName() .. " est� tentando fazer a quest Ancient/Star Stone mas n�o deveria estar aqui!", MESSAGE_STATUS_WARNING)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� ainda n�o fez a box 25....")
        return true
    end

    if item:getUniqueId() == 17393 then
        local queststatus = player:getStorageValue(2209)

        if queststatus == -1 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� completou Ancient/Star Stone.!.")
            player:addItem(2160, 50)
            player:addItem(16239, 1)
            player:addItem(13215, 5)
            player:setStorageValue(2209, 1)
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� j� concluiu a Quest.")
        end
    else
        return false
    end

    return true
end
