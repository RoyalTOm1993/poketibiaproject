local monsters = {
  {pos = Position(4231, 2361, 1), name = "Marshadow Rgb MVP 2"},
}

local config = {
  onSpawnMonster = CONST_ME_TELEPORT, -- effect played when monster is created
}

function onUse(cid, item, frompos, item2, topos)
  local player = Player(cid) -- Create a Player object
  
  for _, monsterinfo in pairs(monsters) do
    local hasNearbyBoss = false
    local spectator = Game.getSpectators(monsterinfo.pos, false, true, 10, 10, 10, 10)
    
    for _, v in ipairs(spectator) do
      if v:isCreature() and v:getName() == monsterinfo.name then
        hasNearbyBoss = true
        break
      end
    end

    if not hasNearbyBoss then
      local monster = Game.createMonster(monsterinfo.name, monsterinfo.pos, false)
      if monster and tonumber(config.onSpawnMonster) and config.onSpawnMonster ~= 255 then
        addEvent(function()
          local spectator = Game.getSpectators(monsterinfo.pos, false, true, 10, 10, 10, 10)
          if spectator and #spectator > 0 then
            for _, v in ipairs(spectator) do
              if v:isCreature() and v:getName() == monsterinfo.name then
                v:remove()
              end
            end
          end
        end, 18000000)

        monster:getPosition():sendMagicEffect(config.onSpawnMonster)
        player:say("O Boss irá sumir em 5 minutos!", TALKTYPE_ORANGE_1)
      end
    else
      player:say("Um boss ainda está próximo!", TALKTYPE_ORANGE_1)
    end
  end
  return true
end
