function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item.itemid == 2145 then
        item:remove(1)
        player:addItem(12237, 10000)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você trocou 1 small diamond por 10k BD.")
    elseif item.itemid == 12237 then
        if item.type == 10000 then
            item:remove()
            player:addItem(2145, 1)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você trocou 10k BD por 1 small diamond.")
        end
    end
    return true
end