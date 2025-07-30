local t = {
    storage = 7312, -- Only modify if necessary.
    temp = 6, -- Time in hours.
    count = {250, 250, 250, 1, 1, 250}, -- Quantities of the rewards to be gained.
    reward = {14435, 13234, 14434, 16361, 20653, 12237} -- Items to be gained.
}

function onUse(cid, item, fromPos, itemEx, toPos)
    local player = Player(cid)
    if not player then
        return true
    end

    -- Check if a boss monster is nearby
    local monsters = {
        {pos = {x = 3929, y = 2508, z = 0}, name = "Boss Houndoom M1"},
    }

    for _, monsterinfo in ipairs(monsters) do
        local spectator = Game.getSpectators(monsterinfo.pos, false, true, 10, 10)
        for _, v in ipairs(spectator) do
            if v:isCreature() and v:getName() == monsterinfo.name then
                player:sendCancelMessage("Um boss ainda está próximo. Você não pode pegar o item.")
                return true
            end
        end
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
