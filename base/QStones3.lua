function onUse(cid, item, fromPosition, itemEx, toPosition)
    if item.uid == 7105 then
        local player = Player(cid) -- Create a Player object
        local questStatus = player:getStorageValue(2539)

        if questStatus == -1 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você completou a quests Stones, parabéns!")
            player:addItem(13234, 150)
            player:addItem(13198, 150)
            player:addItem(14435, 150)
            player:addItem(14434, 150)
            player:setStorageValue(2539, 1)
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você já completou essa quest!")
        end
    end

    return true
end
