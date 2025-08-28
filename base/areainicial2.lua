function onStepIn(cid, item, position, fromPosition)
    local requiredLevel = 45000 -- Defina o nível necessário para o teleport.

    if getPlayerLevel(cid) >= requiredLevel then
        -- O jogador tem o nível necessário.
        doTeleportThing(cid, {x = 44, y = 477, z = 5})
        doSendMagicEffect(position, CONST_ME_TELEPORT)
    else
        -- O jogador não tem o nível necessário.
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você não tem o nível necessário para usar este teleport. Nível mínimo: " .. requiredLevel)
    end

    return true
end
