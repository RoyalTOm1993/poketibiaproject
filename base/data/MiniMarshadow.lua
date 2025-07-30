function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid) -- Create a Player object
    local pos = Position(1937, 2097, 15)
    local requiredItemId = 17824  -- ID do item necess�rio para teleportar
    
    -- Verifica se o jogador possui o item necess�rio
    if player:getItemCount(requiredItemId) > 0 then
        player:teleportTo(pos)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� foi teleportado.")
        player:removeItem(requiredItemId, 1)  -- Remove 1 item do jogador
    else
        player:sendCancelMessage("Voc� precisa da chave marshadow para passar aqui!")
    end
    
    return true
end
