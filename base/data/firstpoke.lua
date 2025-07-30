function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getStorageValue(505050) == 2 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voce ja escolheu seu Pokemon inicial.")
        return true
    end
    
    if player:getStorageValue(505051) ~= 1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Fale com o professor Oak para poder escolher seu pokemon inicial.")
        return true
    end
    
    player:sendExtendedOpcode(69, ":)")
    return true
end
