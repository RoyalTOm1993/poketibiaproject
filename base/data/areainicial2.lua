function onStepIn(cid, item, position, fromPosition)
    local requiredLevel = 45000 -- Defina o n�vel necess�rio para o teleport.

    if getPlayerLevel(cid) >= requiredLevel then
        -- O jogador tem o n�vel necess�rio.
        doTeleportThing(cid, {x = 44, y = 477, z = 5})
        doSendMagicEffect(position, CONST_ME_TELEPORT)
    else
        -- O jogador n�o tem o n�vel necess�rio.
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Voc� n�o tem o n�vel necess�rio para usar este teleport. N�vel m�nimo: " .. requiredLevel)
    end

    return true
end
