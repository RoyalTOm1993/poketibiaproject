function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then 
    return true 
  end
  
  local requiredStorageValue = 40 -- Valor m�nimo da storage
  local maxStorageValue = 79 -- Valor m�ximo da storage
  
  local playerStorageValue = getPlayerStorageValue(cid, 102231)
  
  if playerStorageValue < requiredStorageValue or playerStorageValue > maxStorageValue then
    doPlayerSendCancel(cid, "Voc� precisa ter entre 40 e 79 resets para entrar aqui.")
    doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
    return true
  end
  
  local teleportPosition = {x = 3818, y = 3033, z = 7} -- Replace with the desired teleport position
  
  doTeleportThing(cid, teleportPosition, true)
  doSendMagicEffect(teleportPosition, CONST_ME_TELEPORT)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc� foi teleportado!")
  
  return true
end
