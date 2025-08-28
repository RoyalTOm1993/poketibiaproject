function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then 
    return true 
  end

  local requiredStorageValue1 = 102231 -- Valor necessário para a primeira storage (resets)
  local requiredValueResets = 50 -- Valor mínimo necessário na storage 102131 (resets)

  local resets = getPlayerStorageValue(cid, requiredStorageValue1)

  local message = "Você precisa de:"

  if resets < requiredValueResets then
    message = message .. " pelo menos 50 Resets"
  else
    message = "Você já tem o necessário para passar."
  end

  if resets < requiredValueResets then
    doPlayerSendCancel(cid, message)
    doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
    doTeleportThing(cid, fromPosition, true) -- Teleporta o jogador de volta para a posição anterior
    return true
  end

  return true
end
