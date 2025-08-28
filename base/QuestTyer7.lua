function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid)
    local antes = player:getStorageValue(10021)

    if antes == -1 then
        Game.broadcastMessage("O jogador " .. player:getName() .. " está tentando fazer a quest Tyer7 mas não deveria estar aqui!", MESSAGE_STATUS_WARNING)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você ainda não fez a box 25....")
        return true
    end

    if item:getUniqueId() == 11093 then
        local queststatus = player:getStorageValue(2206)

        if queststatus == -1 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você completou Tyer 7.!.")
            player:addItem(2160, 50)
            player:addItem(15239, 1)
            player:addItem(13215, 7)
            player:setStorageValue(2206, 1)
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você já concluiu a Quest.")
        end
    else
        return false
    end

    return true
end
