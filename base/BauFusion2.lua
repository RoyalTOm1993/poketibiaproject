local t = {
  storage = 7319, -- Only modify if necessary.
  temp = 3000, -- Time in hours.
  count = {1}, -- Quantities of the rewards to be gained.
  reward = {20686} -- Items to be gained.
}

function onUse(player, item, fromPosition, target, toPosition)
  -- Check if a boss monster is nearby
  local monsters = {
    {position = {x = 3358, y = 2270, z = 8}, name = "Fusion Zygarde"},
  }

  for _, monsterInfo in ipairs(monsters) do
    local creature = Game.getSpectators(monsterInfo.position, false, false, 10, 10)
    for _, spectator in ipairs(creature) do
      if spectator:isMonster() and spectator:getName() == monsterInfo.name then
        player:sendCancelMessage("Um boss ainda está próximo. Você não pode pegar o item.")
        return true
      end
    end
  end

  if player:getStorageValue(t.storage) < os.time() then
    for i = 1, #t.reward do
      player:sendTextMessage(MESSAGE_INFO_DESCR, "Você encontrou " .. t.count[i] .. "x " .. ItemType(t.reward[i]):getName() .. ".")
      player:addItem(t.reward[i], t.count[i])
    end
    player:setStorageValue(t.storage, os.time() + (t.temp * 60 * 60))
  else
    local remainingTime = math.ceil((player:getStorageValue(t.storage) - os.time()) / 3600)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Você precisa esperar " .. remainingTime .. " hora(s) para pegar novamente.")
  end

  return true
end
