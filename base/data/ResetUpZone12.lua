function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then 
    return true 
  end
  
  local requiredStorageValue = 80 -- Valor mínimo da storage
  local maxStorageValue = 1000 -- Valor máximo da storage
  
  local playerStorageValue = getPlayerStorageValue(cid, 102231)
  
  if playerStorageValue < requiredStorageValue or playerStorageValue > maxStorageValue then
    doPlayerSendCancel(cid, "Você precisa ter entre 80 e 100 resets para entrar aqui.")
    doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
    return true
  end
  
  local teleportPosition = {x = 4727, y = 2868, z = 7} -- Replace with the desired teleport position
  
  doTeleportThing(cid, teleportPosition, true)
  doSendMagicEffect(teleportPosition, CONST_ME_TELEPORT)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você foi teleportado!")
  
  return true
end
