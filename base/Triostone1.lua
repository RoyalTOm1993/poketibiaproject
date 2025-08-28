function onUse(cid, item, fromPosition, itemEx, toPosition)
    if item.uid == 1121 then
        local player = Player(cid) -- Create a Player object
        local questStatus = player:getStorageValue(2237)

        if questStatus == -1 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você completou a quests Boost Stones, parabéns!")
            player:addItem(15252, 1)
            player:addItem(13563, 1)
            player:addItem(13563, 1)
            player:addItem(13563, 1)
            player:setStorageValue(2237, 1)
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você já completou essa quest!")
        end
    end

    return true
end
