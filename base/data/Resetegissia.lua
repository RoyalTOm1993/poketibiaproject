function onStepIn(cid, item, position, fromPosition)
    local player = Player(cid)
    if not player then
        return true
    end
    
    local requiredLevel = 20000
    if player:getLevel() < requiredLevel then
        player:teleportTo(fromPosition, true)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Você precisa ser level 20K para upar aqui!")
    end
    
    return true
end
