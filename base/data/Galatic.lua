function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then 
    return true 
  end
  
  local requiredLevel = 20000
  
  if getPlayerLevel(cid) < requiredLevel then
    doPlayerSendCancel(cid, "Você precisa ser level " .. requiredLevel .. " para entrar aqui.")
    doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
    return true
  end
  
  local teleportPosition = {x = 4198, y = 1450, z = 6} -- Substitua pelos valores da posição desejada
  
  doTeleportThing(cid, teleportPosition, true)
  doSendMagicEffect(teleportPosition, CONST_ME_TELEPORT)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você foi teleportado!")
    return true
end
