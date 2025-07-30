function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)

    local availableItems = {
        {itemId = 22594, minAmount = 1, maxAmount = 1},
        {itemId = 22602, minAmount = 1, maxAmount = 1},
        {itemId = 22610, minAmount = 1, maxAmount = 1},
        {itemId = 22618, minAmount = 1, maxAmount = 1},
        {itemId = 22626, minAmount = 1, maxAmount = 1},
        {itemId = 22634, minAmount = 1, maxAmount = 1},
        {itemId = 22642, minAmount = 1, maxAmount = 1},
    }

    local numItemsToAdd = math.random(1, 1)
    local chosenItems = {}

    for i = 1, numItemsToAdd do
        local randomIndex = math.random(1, #availableItems)
        local selectedItem = availableItems[randomIndex]

        while chosenItems[selectedItem.itemId] do
            randomIndex = math.random(1, #availableItems)
            selectedItem = availableItems[randomIndex]
        end

        chosenItems[selectedItem.itemId] = true
        player:addItem(selectedItem.itemId, math.random(selectedItem.minAmount, selectedItem.maxAmount))
    end

    local foundItems = next(chosenItems) ~= nil

    if not foundItems then
        Game.broadcastMessage(player:getName() .. " abriu uma bolsa, mas nada foi encontrado.", MESSAGE_EVENT_ADVANCE)
    else
        local itemNames = {}
        for itemID, _ in pairs(chosenItems) do
            local itemData = ItemType(itemID)
            if itemData then
                table.insert(itemNames, itemData:getName())
            end
        end
        local itemNamesStr = table.concat(itemNames, ", ")
        Game.broadcastMessage(player:getName() .. " acabou de abrir uma bolsa contendo: " .. itemNamesStr, MESSAGE_EVENT_ADVANCE)
    end

    item:remove(1)
    return true
end
