function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then 
    return true 
  end
  
  local requiredStorageValue1 = 102231 -- Valor necessário para a primeira storage (resets)
  local requiredStorageValue2 = 19171 -- Valor necessário para a segunda storage (permissão)
  local requiredValue = 10 -- Valor mínimo necessário na storage 102230 (resets)

  local resets = getPlayerStorageValue(cid, requiredStorageValue1)
  local hasPermission = getPlayerStorageValue(cid, requiredStorageValue2)

  local message = "Voce precisa de:"

  if resets < requiredValue and not hasPermission then
    message = message .. " 10 resets e permissão"
  elseif resets < requiredValue then
    message = message .. " 10 resets"
  elseif not hasPermission then
    message = message .. " permissão"
  else
    message = "Voce já tem permissão e 10 resets."
  end
  
  message = message .. " para poder passar!"
  
  if resets < requiredValue or not hasPermission then
    doPlayerSendCancel(cid, message)
    doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
    doTeleportThing(cid, fromPosition, true) -- Teleporta o jogador de volta para a posição anterior
    return true
  end
  
  return true
end
