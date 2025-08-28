function onStepIn(creature, item, position, fromPosition)
    local player = Player(creature)
    
    if not player then 
        return true 
    end
    
    local requiredLevel = 20000
    
    if player:getLevel() < requiredLevel then
        player:sendCancelMessage("Você precisa ser level " .. requiredLevel .. " para entrar aqui.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end
    
    local teleportPosition
    local randomTeleport = math.random(1, 12)
    
    if randomTeleport == 1 then
        teleportPosition = Position(4240, 2224, 0) -- Replace with the desired position
    else
        local possiblePositions = {
            Position(3924, 2176, 0),
            Position(4019, 2205, 0),
            Position(4039, 2149, 0),
            Position(4158, 2148, 0),
            Position(4154, 2207, 0),
            Position(4240, 2222, 0),
            Position(4281, 2186, 0)
        } -- Add possible teleport positions here
        teleportPosition = possiblePositions[math.random(1, #possiblePositions)]
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Você foi teleportado para um local aleatório.")
    end
    
    player:teleportTo(teleportPosition, true)
    teleportPosition:sendMagicEffect(CONST_ME_TELEPORT)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Você foi teleportado!")
return true
end
