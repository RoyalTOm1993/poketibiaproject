local t = {
    storage = 7312, -- Only modify if necessary.
    temp = 6, -- Time in hours.
    count = {250, 250, 250, 1, 1, 250}, -- Quantities of the rewards to be gained.
    reward = {14435, 13234, 14434, 16361, 20653, 12237} -- Items to be gained.
}

function isBossNearby(pos, name)
    local monsters = {
        {pos = {x = 3929, y = 2508, z = 0}, name = "Boss Houndoom M1"},
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
        player:sendCancelMessage("Um boss ainda est� pr�ximo. Voc� n�o pode pegar o item.")
        return true
    end

    if player:getStorageValue(t.storage) < os.time() then
        for i = 1, #t.reward do
            local itemName = ItemType(t.reward[i]):getName()
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Voc� encontrou " .. t.count[i] .. "x " .. itemName .. ".")
            player:addItem(t.reward[i], t.count[i])
        end
        player:setStorageValue(t.storage, os.time() + (t.temp * 60 * 60))
    else
        local remainingTime = math.ceil((player:getStorageValue(t.storage) - os.time()) / 3600)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Voc� precisa esperar " .. remainingTime .. " hora(s) para pegar novamente.")
    end

    return true
end
