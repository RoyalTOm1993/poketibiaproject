function onStepIn(creature, item, position, fromPosition)
    if not creature:isPlayer() then
        return true
    end
    
    local player = Player(creature)
    
    -- Check if the player has the necessary items
    local item1 = player:getItemCount(13553)
    local item2 = player:getItemCount(16278)
    
    if item1 < 1 or item2 < 1 then
        player:sendCancelMessage("Você precisa de certos itens dropados pelos pokemons deoxys e mewtwo!.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end
    
    local requiredLevel = 15000
    
    if player:getLevel() < requiredLevel then
        player:sendCancelMessage("Você precisa ser level " .. requiredLevel .. " para entrar aqui.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end
    
    local teleportPosition = Position(4216, 1631, 6) -- Replace with the desired position
    
    -- Remove the items from the player's inventory
    local itemToRemove1 = player:getItemById(13553)
    local itemToRemove2 = player:getItemById(16278)
    
    if itemToRemove1 and itemToRemove2 then
        itemToRemove1:remove(1)
        itemToRemove2:remove(1)
    end
    
    player:teleportTo(teleportPosition, true)
    teleportPosition:sendMagicEffect(CONST_ME_TELEPORT)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Você foi teleportado!")
    
    return true
end
