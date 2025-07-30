function onUse(cid, item, fromPosition, itemEx, toPosition)
    if item.uid == 7104 then
        local player = Player(cid) -- Create a Player object
        local questStatus = player:getStorageValue(2538)

        if questStatus == -1 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você completou a quests Stones, parabéns!")
            player:addItem(13234, 100)
            player:addItem(13198, 100)
            player:addItem(14435, 100)
            player:addItem(14434, 100)
            player:setStorageValue(2538, 1)
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você já completou essa quest!")
        end
    end

    return true
end
