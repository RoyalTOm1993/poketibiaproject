function onUse(cid, item, fromPosition, itemEx, toPosition)
    if item.uid == 7103 then
        local player = Player(cid) -- Create a Player object
        local questStatus = player:getStorageValue(2537)

        if questStatus == -1 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você completou a quests Stones, parabéns!")
            player:addItem(13234, 50)
            player:addItem(13198, 50)
            player:addItem(14435, 50)
            player:addItem(14434, 50)
            player:setStorageValue(2537, 1)
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você já completou essa quest!")
        end
    end

    return true
end
