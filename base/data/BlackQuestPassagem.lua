function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then 
    return true 
  end
  
  local requiredStorageValue1 = 102231 -- Valor necessário para a primeira storage (resets)
  local requiredStorageValue2 = 6652 -- Valor necessário para a segunda storage (permissão)
  local requiredValueResets = 20 -- Valor mínimo necessário na storage 102231 (resets)
  local requiredValuePermission = 1 -- Valor mínimo necessário na storage 6651 (permissão)

  local resets = getPlayerStorageValue(cid, requiredStorageValue1)
  local hasPermission = getPlayerStorageValue(cid, requiredStorageValue2)

  local message = "Voce precisa de:"

  if resets < requiredValueResets then
    message = message .. " " .. (requiredValueResets - resets) .. " resets"
  end

  if hasPermission < requiredValuePermission then
    if resets < requiredValueResets then
      message = message .. " e"
    end
    message = message .. " " .. (requiredValuePermission - hasPermission) .. " permissão"
  end

  if resets >= requiredValueResets and hasPermission >= requiredValuePermission then
    message = "Você já tem permissão e pelo menos 20 resets."
  end

  message = message .. " para poder passar!"

  if resets < requiredValueResets or hasPermission < requiredValuePermission then
    doPlayerSendCancel(cid, message)
    doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
    doTeleportThing(cid, fromPosition, true) -- Teleporta o jogador de volta para a posição anterior
    return true
  end
  
  return true
end
