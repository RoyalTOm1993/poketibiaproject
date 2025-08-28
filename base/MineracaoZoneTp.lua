function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then 
    return true 
  end
  
  local requiredStorageValue1 = 102231 -- Valor necess�rio para a primeira storage (resets)
  local requiredStorageValue2 = 19171 -- Valor necess�rio para a segunda storage (permiss�o)
  local requiredValue = 10 -- Valor m�nimo necess�rio na storage 102230 (resets)

  local resets = getPlayerStorageValue(cid, requiredStorageValue1)
  local hasPermission = getPlayerStorageValue(cid, requiredStorageValue2)

  local message = "Voce precisa de:"

  if resets < requiredValue and not hasPermission then
    message = message .. " 10 resets e permiss�o"
  elseif resets < requiredValue then
    message = message .. " 10 resets"
  elseif not hasPermission then
    message = message .. " permiss�o"
  else
    message = "Voce j� tem permiss�o e 10 resets."
  end
  
  message = message .. " para poder passar!"
  
  if resets < requiredValue or not hasPermission then
    doPlayerSendCancel(cid, message)
    doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
    doTeleportThing(cid, fromPosition, true) -- Teleporta o jogador de volta para a posi��o anterior
    return true
  end
  
  return true
end
