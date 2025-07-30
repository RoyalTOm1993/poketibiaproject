function onStepIn(creature, item, position, fromPosition)
    local player = Player(creature)
    if not player then
        return true
    end
    
    local requiredLevel = 15000
    if player:getLevel() < requiredLevel then
        player:teleportTo(fromPosition, true)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Voc� precisa ser level 15K para upar aqui!")
    end
    
    return true
end
