local t = {
  storage = 7819, -- Only modify if necessary.
  temp = 24, -- Time in hours.
  count = {100}, -- Quantities of the rewards to be gained.
  reward = {22666} -- Items to be gained.
}

function onUse(player, item, fromPosition, target, toPosition)
  -- Check if a boss monster is nearby
  local monsters = {
    {position = {x = 3150, y = 2780, z = 7}, name = "Giant A MVP"},
  }

for _, monsterInfo in ipairs(monsters) do
  local creature = Game.getSpectators(monsterInfo.position, false, false, 255, 255)  -- Ampliando a �rea para 255x255.
  for _, spectator in ipairs(creature) do
    if spectator:isMonster() and spectator:getName() == monsterInfo.name then
      -- Calcule a dist�ncia em rela��o �s coordenadas do jogador.
      local distanceX = math.abs(player:getPosition().x - monsterInfo.position.x)
      local distanceY = math.abs(player:getPosition().y - monsterInfo.position.y)

      if distanceX <= 5 and distanceY <= 5 then
        print("O monstro est� presente nas proximidades!")  -- Mensagem de depura��o
        player:sendCancelMessage("Um boss ainda est� pr�ximo. Voc� n�o pode pegar o item.")
        return true
      end
    end
  end
end


  if player:getStorageValue(t.storage) < os.time() then
    for i = 1, #t.reward do
      player:sendTextMessage(MESSAGE_INFO_DESCR, "Voc� encontrou " .. t.count[i] .. "x " .. ItemType(t.reward[i]):getName() .. ".")
      player:addItem(t.reward[i], t.count[i])
    end
    player:setStorageValue(t.storage, os.time() + (t.temp * 60 * 60))
  else
    local remainingTime = math.ceil((player:getStorageValue(t.storage) - os.time()) / 3600)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Voc� precisa esperar " .. remainingTime .. " hora(s) para pegar novamente.")
  end

  return true
end

