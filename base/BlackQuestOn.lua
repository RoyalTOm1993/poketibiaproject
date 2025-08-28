local cfg = {
    pos = {x = 3130, y = 2148, z = 7},  -- Posição para onde os jogadores serão teleportados.
    message = "Você Acertou Parabens!"  -- Mensagem após o teleporto.
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    doSendMagicEffect(getPlayerPosition(cid), CONST_ME_TELEPORT)
    doTeleportThing(cid, cfg.pos)

    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, cfg.message)

    return true
end
