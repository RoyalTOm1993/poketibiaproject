local t = {
  level = 35000,
  requiredResets = 2, -- Quantidade de Resets Storage necessários
  inicio = {
    {x = 4019, y = 2538, z = 4}, -- Lugar onde o primeiro jogador vai estar
    {x = 4037, y = 2539, z = 4}, -- Lugar onde o segundo jogador vai estar
    {x = 4034, y = 2551, z = 4}, -- Lugar onde o terceiro jogador vai estar
    {x = 4028, y = 2564, z = 4}, -- Lugar onde o terceiro jogador vai estar
  },
  fim = {x = 4145, y = 2668, z = 8},
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
  local player = Player(cid) -- Criar um objeto Player
  local players = {}

  for _, v in pairs(t.inicio) do
    local creature = Tile(v):getTopCreature()
    if not creature or not creature:isPlayer() or creature:getLevel() < t.level then
      player:say("Alguém não cumpre os requisitos da quest!", TALKTYPE_MONSTER_SAY, false, cid, v)
      return true
    end

    local resets = creature:getStorageValue(102231)
    if resets < t.requiredResets then
      player:say("O jogador " .. creature:getName() .. " precisa de pelo menos " .. t.requiredResets .. " resets para ser teleportado.", TALKTYPE_MONSTER_SAY, false, cid, v)
      return true
    end

    table.insert(players, creature)
  end

  for _, v in pairs(players) do
    v:teleportTo(t.fim)
  end

  return true
end
