function onUse(cid, item, frompos, item2, topos)
    if item.uid == 1232 then
        if Player(cid):getStorageValue(2229) == -1 then
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� completou a quest legendary box, parab�ns!")
            Player(cid):addItem(15252, 2)
            Player(cid):setStorageValue(2229, 1)
        else
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� j� completou essa quest!")
        end
    end
end
