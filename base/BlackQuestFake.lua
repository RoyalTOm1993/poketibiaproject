local cfg = {
    pos = {x = 3099, y = 2906, z = 6},  -- Posição para onde os jogadores serão teleportados.
    message = "Você errou e foi teleportado para o cp!"  -- Mensagem após o teleporto.
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    doSendMagicEffect(getPlayerPosition(cid), CONST_ME_TELEPORT)
    doTeleportThing(cid, cfg.pos)

    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, cfg.message)

    return true
end
