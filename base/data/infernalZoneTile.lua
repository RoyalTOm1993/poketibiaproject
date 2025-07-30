function getCustomSpectators(position, multifloor, showPlayers, showMonsters, showNPCs, minRangeX, maxRangeX, minRangeY, maxRangeY)
    --getSpectators(position[, multifloor = false[, onlyPlayer = false[, minRangeX = 0[, maxRangeX = 0[, minRangeY = 0[, maxRangeY = 0]]]]]])

    local spectators = Game.getSpectators(position, multifloor, false, minRangeX, maxRangeX, minRangeY, maxRangeY)

    customSpectatorsList = {}
    for _, spectatorCreature in ipairs(spectators) do
        if (showPlayers and spectatorCreature:isPlayer()) or
            (showMonsters and spectatorCreature:isMonster()) or
            (showNPCs and spectatorCreature:isNpc()) then
            table.insert(customSpectatorsList, spectatorCreature)
        end
    end

    return customSpectatorsList
end

function Creature:changeSprite(sprite, tempo)
		
		local condition = Condition(CONDITION_OUTFIT)

		condition:setOutfit(0, sprite)
		condition:setTicks(tempo)
		self:addCondition(condition)
end

function Creature:setInvisible(tempo)
		
		local condition = Condition(CONDITION_OUTFIT)

		condition:setOutfit(0, 0, 0, 0, 0, 0, 0, 0, 0 , 0, 0)
		condition:setTicks(tempo)
		self:addCondition(condition)

end

function onStepIn(player, item, position, fromPosition)
local player = Player(player:getId())
local pos = {x = 3731, y = 4725, z = 7}
      player:say("ESSSSAAAA NÃOOOOOOOOOO!!!!!!  ", TALKTYPE_SAY)
      addEvent(function() player = Player(player:getId()) if player then player:say("FIQUEI PRESO!!!!!  ", TALKTYPE_SAY) end end, 1000)
      
      player:setNoMove(true)
      local posEffect = player:getPosition()
      posEffect.x = posEffect.x + 1
     
     local posText = {x = 3731, y = 4695, z = 7}
     
      addEvent(function() player = Player(player:getId()) if player then  player:changeSprite(100, -1) end end, 6200)
      addEvent(function() player = Player(player:getId()) if player then  posEffect:sendMagicEffect(2342) player:setHiddenHealth(true) end end, 6200)
      
      addEvent(function() player = Player(player:getId()) if player then player:setNoMove(false) player:teleportTo(pos) player:changeSprite(4927 , -1) player:setHiddenHealth(false) end end, 10000)
      
      
      addEvent(function() player = Player(player:getId()) if player then  player:getPosition():sendMagicEffect(2339) end end, 4300)
      addEvent(function() player = Player(player:getId()) if player then  player:getPosition():sendMagicEffect(2339) end end, 4000)
      addEvent(function() player = Player(player:getId()) if player then  player:getPosition():sendMagicEffect(2339) end end, 5000)
      addEvent(function() player = Player(player:getId()) if player then  player:getPosition():sendMagicEffect(2339) end end, 4500)
      addEvent(function() player = Player(player:getId()) if player then  player:getPosition():sendMagicEffect(2339) end end, 5500)
      addEvent(function() player = Player(player:getId()) if player then  player:getPosition():sendMagicEffect(2339) end end, 6500)
      addEvent(function() player = Player(player:getId()) if player then  player:getPosition():sendMagicEffect(2339) end end, 6000)
     
    local spectators = getCustomSpectators(player:getPosition(), false, false, false, true, 15, 15, 15, 15)
      for _, spectator in ipairs(spectators) do
        if isNpc(spectator) then
             addEvent(function() npc = Creature(spectator:getId()) if npc then Game.sendAnimatedText(posText, "SEU DESTINO É APENAS UM!!", math.random(1, 255))   end end, 2000) -- npc:say("SEU DESTINO É APENAS UM!!", TALKTYPE_SAY)
             addEvent(function() npc = Creature(spectator:getId()) if npc then Game.sendAnimatedText(posText, "A MORTEEEEE!!!!!!", math.random(1, 255)) end end, 3000) -- npc:say("A MORTEEEEE!!!!!!", TALKTYPE_SAY)
             addEvent(function() npc = Creature(spectator:getId()) if npc then npc:changeSprite(4929 , 1000) end end, 3000)
             addEvent(function() npc = Creature(spectator:getId()) if npc then npc:changeSprite(4928 , 1000) end end, 4000)
             addEvent(function() npc = Creature(spectator:getId()) if npc then npc:changeSprite(4926 , 1500) end end, 5000)
             break
        end
      end

  return true
end
