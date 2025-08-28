function onStepIn(cid, item, position, fromPosition)
  
  if not isPlayer(cid) then 
    return true 
  end
  
  local requiredLevel = 15000
  
  if getPlayerLevel(cid) < requiredLevel then
    doPlayerSendCancel(cid, "Você precisa ser level " .. requiredLevel .. " para entrar aqui.")
    doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
    return true
  end
  
  local teleportPosition = {x = 3956, y = 2495, z = 4} -- Substitua pelos valores da posição desejada
  
  doTeleportThing(cid, teleportPosition)
  doSendMagicEffect(teleportPosition, CONST_ME_TELEPORT)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você foi teleportado!")

end
