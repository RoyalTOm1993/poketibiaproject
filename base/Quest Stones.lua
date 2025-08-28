function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid) -- Create a Player object for the player using the item

    local antes = player:getStorageValue(10020) -- Use getStorageValue method
    if antes == -1 then
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "Você ainda não fez a box 25....")
        return true
    end

    if item.uid == 1986 then
        local questStatus = player:getStorageValue(65431) -- Use getStorageValue method
        if questStatus == -1 then
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você completou a quest Stones.")
            player:addItem(22919, 100)
            player:addItem(23149, 2)
            player:addItem(23035, 5)
            player:addItem(22868, 2)
            player:setStorageValue(65431, 1) -- Use setStorageValue method
        else
            player:sendTextMessage(MESSAGE_STATUS_WARNING, "Você já concluiu a quest.")
        end
    else
        return false -- Return false if the item UID doesn't match
    end

    return true
end
