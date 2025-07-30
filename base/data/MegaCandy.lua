function onUse(cid, item, fromPosition, itemEx, toPosition)
  if not isPlayer(cid) then
    return false
  end

  -- Nome do Pokémon que você deseja verificar a presença
  local pokemonName = "Giant A MVP"

  -- Define a distância máxima em tiles para verificar a presença do Pokémon
  local maxDistance = 3

  -- Defina as informações do "Mech Genesect" a serem verificadas
  local monsters = {
    {pos = {x = 3150, y = 2791, z = 7}, name = "Giant A MVP"}
  }

  for _, monsterinfo in ipairs(monsters) do
    local spectator = getSpectators(monsterinfo.pos, 3, 3, false)
    for _, v in ipairs(spectator) do
      if isCreature(v) and getCreatureName(v) == monsterinfo.name then
        local playerPos = getCreaturePosition(cid)
        if getDistanceBetween(playerPos, monsterinfo.pos) <= maxDistance then
          doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Você não pode usar isso com um " .. pokemonName .. " por perto.")
          return true
        end
      end
    end
  end

  -- Se não houver um Pokémon com o nome específico por perto, teleporte o jogador para o local desejado
  local teleportPosition = {x = 3151, y = 2786, z = 7}  -- Substitua com as coordenadas do local desejado
  doTeleportThing(cid, teleportPosition, false)
  doSendMagicEffect(teleportPosition, CONST_ME_TELEPORT)
  return true
end



