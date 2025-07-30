function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    local bag = player:addItem(7343, 1)

    if not bag then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Você não tem espaço para abrir a bolsa!")
        return true
    end
    
    local function addItemToBag(itemID, minAmount, maxAmount)
        local amount = math.random(minAmount, maxAmount)
        bag:addItem(itemID, amount)
    end

    local availableItems = {
        {itemId = 14435, minAmount = 100, maxAmount = 1000},
        {itemId = 14434, minAmount = 100, maxAmount = 1000},
        {itemId = 13198, minAmount = 100, maxAmount = 1000},
        {itemId = 13234, minAmount = 100, maxAmount = 1000},
        {itemId = 12237, minAmount = 100, maxAmount = 1000},
        {itemId = 13559, minAmount = 1, maxAmount = 5},
        {itemId = 13560, minAmount = 1, maxAmount = 5},
        {itemId = 13561, minAmount = 1, maxAmount = 5},
        {itemId = 13563, minAmount = 1, maxAmount = 5},
        {itemId = 13564, minAmount = 1, maxAmount = 5},
        {itemId = 13565, minAmount = 1, maxAmount = 5},
        {itemId = 17315, minAmount = 1, maxAmount = 10},
        {itemId = 20652, minAmount = 1, maxAmount = 5},
        {itemId = 20651, minAmount = 1, maxAmount = 3},
        {itemId = 17208, minAmount = 1, maxAmount = 1},
        {itemId = 17120, minAmount = 1, maxAmount = 10},
    }

    local numItemsToAdd = math.random(1, 5)
    local chosenItems = {}

    for i = 1, numItemsToAdd do
        local randomIndex = math.random(1, #availableItems)
        local selectedItem = availableItems[randomIndex]

        while chosenItems[selectedItem.itemId] do
            randomIndex = math.random(1, #availableItems)
            selectedItem = availableItems[randomIndex]
        end

        chosenItems[selectedItem.itemId] = true
        addItemToBag(selectedItem.itemId, selectedItem.minAmount, selectedItem.maxAmount)
    end

    local foundItems = next(chosenItems) ~= nil

    if not foundItems then
        Game.broadcastMessage(player:getName() .. " Abriu Uma Bosss Box Medio.", MESSAGE_EVENT_ADVANCE)
    else
        Game.broadcastMessage(player:getName() .. " Abriu Uma Bosss Box Medio.", MESSAGE_EVENT_ADVANCE)
    end

    item:remove(1)
    return true
end
