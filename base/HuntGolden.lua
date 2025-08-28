function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then 
    return true 
  end
  
  local requiredStorageValue = 1 -- Valor mínimo da storage
  
  local playerStorageValue = getPlayerStorageValue(cid, 98751)
  
  if playerStorageValue < requiredStorageValue then
    doPlayerSendCancel(cid, "Você Precisa Ter Acesso A Essa Hunt!")
    doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
    return true
  end
  
  local teleportPositions = {
    {x = 2391, y = 4059, z = 7}, -- Substitua pelas coordenadas de teletransporte desejadas
    {x = 2567, y = 4061, z = 7},
    {x = 2748, y = 4059, z = 7}
  }
  
  local teleportCount = math.random(1, 3) -- Número aleatório de locais para teleportar (1 a 3)
  
  for i = 1, teleportCount do
    local randomIndex = math.random(1, #teleportPositions) -- Índice aleatório da posição de teletransporte
    local teleportPosition = teleportPositions[randomIndex]
    
    doTeleportThing(cid, teleportPosition, true)
    doSendMagicEffect(teleportPosition, CONST_ME_TELEPORT)
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você foi teleportado!")
    
    table.remove(teleportPositions, randomIndex) -- Remove a posição usada para evitar teleportar para o mesmo local novamente
  end
  
  setPlayerStorageValue(cid, 98751, 0) -- Remove a storage 41232
  
  return true
end
