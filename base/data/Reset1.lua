function onStepIn(cid, item, position, fromPosition)
    if not isPlayer(cid) then 
        return true 
    end
    
    local requiredStorageValue = 1 -- Altere isso para o valor do storage necessário
    
    if getPlayerStorageValue(cid, 102231) < requiredStorageValue then
        doPlayerSendCancel(cid, "Você precisa ter pelo menos 1 resets para passar por aqui.")
        doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
        doTeleportThing(cid, fromPosition, true)
    end
    
    return true
end
