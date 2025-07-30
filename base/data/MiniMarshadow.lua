function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid) -- Create a Player object
    local pos = Position(1937, 2097, 15)
    local requiredItemId = 17824  -- ID do item necessário para teleportar
    
    -- Verifica se o jogador possui o item necessário
    if player:getItemCount(requiredItemId) > 0 then
        player:teleportTo(pos)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você foi teleportado.")
        player:removeItem(requiredItemId, 1)  -- Remove 1 item do jogador
    else
        player:sendCancelMessage("Você precisa da chave marshadow para passar aqui!")
    end
    
    return true
end
