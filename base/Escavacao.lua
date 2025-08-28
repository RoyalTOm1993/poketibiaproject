function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then 
    return true 
  end
  
  local requiredStorageValue = 1 -- Change this to the value of the required storage
  
  -- if getPlayerStorageValue(cid, 71344) < requiredStorageValue then
    -- doPlayerSendCancel(cid, "Você precisa ter pelo menos de 5 online points para entrar aqui.")
    -- doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
    -- return true
  -- end

  local teleportPosition = {x = 3108, y = 2889, z = 9} -- Substitua pelos valores da posição desejada
  
  doTeleportThing(cid, teleportPosition, true)
  doSendMagicEffect(teleportPosition, CONST_ME_TELEPORT)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você foi teleportado!")
  
  return true
end
