function onStepIn(cid, item, position, fromPosition)
    if not isPlayer(cid) then
        return true
    end
    
    doSendMagicEffect(getThingPos(cid), CONST_ME_MAGIC_RED)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Você não pode se mover aqui!")
    doCreatureSetNoMove(cid, true)
    doMutePlayer(cid)
    return false
end
