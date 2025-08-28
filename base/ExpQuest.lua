local t = {
  storage = 1339, -- Apenas modifique se necessário.
  temp = 5, -- Tempo em horas.
  count = {1, 5, 10}, -- Quantidades das recompensas a serem obtidas.
  reward = {22664, 17313, 17312} -- Itens a serem obtidos.
}

function isBossNearby(pos, name)
    local monsters = {
        {pos = {x = 3021, y = 2982, z = 11}, name = "Mew Super Ultra"},
        -- Add more bosses if needed
    }

    for _, monsterinfo in ipairs(monsters) do
        local distance = math.max(math.abs(pos.x - monsterinfo.pos.x), math.abs(pos.y - monsterinfo.pos.y))
        if distance <= 10 and name == monsterinfo.name then
            return true
        end
    end
    return false
end

function onUse(cid, item, fromPos, itemEx, toPos)
    local player = Player(cid)
    if not player then
        return true
    end

    local playerPosition = player:getPosition()
    local playerName = player:getName()

    if isBossNearby(playerPosition, playerName) then
        player:sendCancelMessage("Um boss ainda está próximo. Você não pode pegar o item.")
        return true
    end

    if player:getStorageValue(t.storage) < os.time() then
        for i = 1, #t.reward do
            local itemName = ItemType(t.reward[i]):getName()
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Você encontrou " .. t.count[i] .. "x " .. itemName .. ".")
            player:addItem(t.reward[i], t.count[i])
        end
        player:setStorageValue(t.storage, os.time() + (t.temp * 60 * 60))
    else
        local remainingTime = math.ceil((player:getStorageValue(t.storage) - os.time()) / 3600)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Você precisa esperar " .. remainingTime .. " hora(s) para pegar novamente.")
    end

    return true
end