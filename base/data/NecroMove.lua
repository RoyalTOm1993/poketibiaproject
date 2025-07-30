function onStepIn(creature, item, position, fromPosition)
    if not creature:isPlayer() then
        return true
    end

    local requiredLevel = 25000

    if creature:getLevel() < requiredLevel then
        creature:sendCancelMessage("Voc� precisa ser level " .. requiredLevel .. " para entrar aqui.")
        creature:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    local teleportPosition
    local randomTeleport = math.random(1, 12) -- define um valor aleat�rio entre 1 e 12

    if randomTeleport == 1 then
        -- Substitua pelos valores da posi��o desejada
        teleportPosition = Position(1339, 1629, 12)
    else
        -- Adicione aqui as posi��es poss�veis para teleporta��o
        local possiblePositions = {
            Position(1418, 1645, 11),
            Position(1434, 1615, 10),
            Position(1360, 1594, 9)
        }
        -- Escolhe aleatoriamente uma das posi��es poss�veis
        teleportPosition = possiblePositions[math.random(1, #possiblePositions)]
        creature:sendTextMessage(MESSAGE_INFO_DESCR, "Voc� foi teleportado para um local aleat�rio.")
    end

    creature:teleportTo(teleportPosition)
    teleportPosition:sendMagicEffect(CONST_ME_TELEPORT)
    creature:sendTextMessage(MESSAGE_INFO_DESCR, "Voc� foi teleportado!")

    return true
end
