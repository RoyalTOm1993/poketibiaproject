function onUse(cid, item, fromPosition, itemEx, toPosition)
    if item.uid == 1123 then
        local player = Player(cid) -- Create a Player object
        local questStatus = player:getStorageValue(2239)

        if questStatus == -1 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você completou a quests Boost Stones, parabéns!")
            player:addItem(15252, 1)
            player:addItem(13565, 1)
            player:addItem(13565, 1)
            player:addItem(13565, 1)
            player:setStorageValue(2239, 1)
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você já completou essa quest!")
        end
    end

    return true
end
