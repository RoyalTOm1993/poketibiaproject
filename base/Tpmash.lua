local t = {
  level = 100,
  inicio = {
    {x = 4155, y = 2537, z = 5}, -- Lugar onde o primeiro jogador vai estar
    {x = 4170, y = 2529, z = 5}, -- Lugar onde o segundo jogador vai estar
    {x = 4163, y = 2528, z = 5}, -- Lugar onde o terceiro jogador vai estar
  },
  fim = {x = 4232, y = 2391, z = 4},
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
  local player = Player(cid) -- Create a Player object
  local players = {}

  for _, v in pairs(t.inicio) do
    local creature = Tile(v):getTopCreature()
    if not creature or not creature:isPlayer() or creature:getLevel() < t.level then
      player:say("Alguem não cumpre os requisitos da quest!", TALKTYPE_MONSTER_SAY, false, cid, v)
      item:transform(item:getId() == 1945 and 1946 or 1945)
      return true
    end

    table.insert(players, creature)
  end

  for _, v in pairs(players) do
    v:teleportTo(t.fim)
  end

  item:transform(item:getId() == 1945 and 1946 or 1945)
  return true
end
