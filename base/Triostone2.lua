function onUse(cid, item, fromPosition, itemEx, toPosition)
    if item.uid == 1122 then
        local player = Player(cid) -- Create a Player object
        local questStatus = player:getStorageValue(2238)

        if questStatus == -1 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� completou a quests Boost Stones, parab�ns!")
            player:addItem(15252, 1)
            player:addItem(13564, 1)
            player:addItem(13564, 1)
            player:addItem(13564, 1)
            player:setStorageValue(2238, 1)
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� j� completou essa quest!")
        end
    end

    return true
end
