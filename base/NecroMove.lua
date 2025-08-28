function onStepIn(creature, item, position, fromPosition)
    if not creature:isPlayer() then
        return true
    end

    local requiredLevel = 25000

    if creature:getLevel() < requiredLevel then
        creature:sendCancelMessage("Você precisa ser level " .. requiredLevel .. " para entrar aqui.")
        creature:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    local teleportPosition
    local randomTeleport = math.random(1, 12) -- define um valor aleatório entre 1 e 12

    if randomTeleport == 1 then
        -- Substitua pelos valores da posição desejada
        teleportPosition = Position(1339, 1629, 12)
    else
        -- Adicione aqui as posições possíveis para teleportação
        local possiblePositions = {
            Position(1418, 1645, 11),
            Position(1434, 1615, 10),
            Position(1360, 1594, 9)
        }
        -- Escolhe aleatoriamente uma das posições possíveis
        teleportPosition = possiblePositions[math.random(1, #possiblePositions)]
        creature:sendTextMessage(MESSAGE_INFO_DESCR, "Você foi teleportado para um local aleatório.")
    end

    creature:teleportTo(teleportPosition)
    teleportPosition:sendMagicEffect(CONST_ME_TELEPORT)
    creature:sendTextMessage(MESSAGE_INFO_DESCR, "Você foi teleportado!")

    return true
end
