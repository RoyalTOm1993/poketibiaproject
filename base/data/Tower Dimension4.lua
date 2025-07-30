function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then
    return true
  end

  local monsters = {
    {pos = {x = 3929, y = 2507, z = 0}, name = "Boss Houndoom M1"}
  }

  for _, monsterinfo in ipairs(monsters) do
    local spectator = getSpectators(monsterinfo.pos, 10, 10, false)
    for _, v in ipairs(spectator) do
      if isCreature(v) and getCreatureName(v) == monsterinfo.name then
        local playerPos = getCreaturePosition(cid)
        if getDistanceBetween(playerPos, monsterinfo.pos) <= 10 then
          doTeleportThing(cid, fromPosition, true)
          doSendMagicEffect(playerPos, CONST_ME_MAGIC_RED)
          doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Você não pode passar. Um boss ainda está próximo.")
          return true
        end
      end
    end
  end

  return true
end

