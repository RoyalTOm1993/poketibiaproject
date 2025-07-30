function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then
    return true
  end

  local monsters = {
    {pos = {x = 3130, y = 2107, z = 6}, name = "Black Raichu"}
  }

  for _, monsterinfo in ipairs(monsters) do
    local spectator = getSpectators(monsterinfo.pos, 3, 3, false)
    for _, v in ipairs(spectator) do
      if isCreature(v) and getCreatureName(v) == monsterinfo.name then
        local playerPos = getCreaturePosition(cid)
        if getDistanceBetween(playerPos, monsterinfo.pos) <= 3 then
          doTeleportThing(cid, fromPosition, true)
          doSendMagicEffect(playerPos, CONST_ME_MAGIC_RED)
          doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Você não matou todos os pokemons.")
          return true
        end
      end
    end
  end

  return true
end
