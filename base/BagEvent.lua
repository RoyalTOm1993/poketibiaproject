function onUse(player, item, fromPosition, target, toPosition, isHotkey)

    local itemsReceived = {}  -- Lista para armazenar os itens recebidos
    local possibleItems = {
        {itemid = 14435, min = 100, max = 2000},
        {itemid = 14434, min = 100, max = 2000},
        {itemid = 13198, min = 100, max = 2000},
        {itemid = 13234, min = 100, max = 2000},
        {itemid = 12237, min = 100, max = 500},
        {itemid = 20709, min = 1, max = 2},
        {itemid = 20708, min = 1, max = 1},
        {itemid = 22787, min = 1, max = 1},
        {itemid = 13560, min = 1, max = 5},
        {itemid = 13561, min = 1, max = 5},
        {itemid = 13563, min = 1, max = 5},
        {itemid = 13564, min = 1, max = 5},
        {itemid = 13565, min = 1, max = 5},
        {itemid = 17315, min = 1, max = 10},
        {itemid = 20652, min = 1, max = 5},
        {itemid = 20651, min = 1, max = 3},
        {itemid = 17208, min = 1, max = 1},
        {itemid = 17208, min = 1, max = 1},
        {itemid = 17208, min = 1, max = 1},
        {itemid = 17208, min = 1, max = 1},
        {itemid = 17208, min = 1, max = 1},
        {itemid = 17208, min = 1, max = 1},
        {itemid = 17208, min = 1, max = 1},
        {itemid = 17208, min = 1, max = 1},
        {itemid = 17208, min = 1, max = 1},
        {itemid = 17208, min = 1, max = 1},
        {itemid = 17120, min = 1, max = 10},
    }

    -- Adiciona até 3 itens ao inventário do jogador
    for i = 1, math.random(1, 5) do
        local randomItem = possibleItems[math.random(#possibleItems)]
        local amount = math.random(randomItem.min, randomItem.max)
        local itemType = ItemType(randomItem.itemid)
        if itemType then
            player:addItem(randomItem.itemid, amount)
            table.insert(itemsReceived, amount .. "x " .. itemType:getName())
        end
    end

    local receivedItemsMessage = "e recebeu: " .. table.concat(itemsReceived, ", ")
    Game.broadcastMessage(player:getName() .. " acabou de abrir uma box do evento bag!, " .. receivedItemsMessage, MESSAGE_EVENT_ADVANCE)
    item:remove(1)

    return true
end