function onUse(cid, item, frompos, item2, topos)
    if item.uid == 1231 then
        if Player(cid):getStorageValue(2228) == -1 then
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você completou a quest legendary stones, parabéns!")
            Player(cid):addItem(15252, 2)
            Player(cid):setStorageValue(2228, 1)
        else
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você já completou essa quest!")
        end
    end
end
