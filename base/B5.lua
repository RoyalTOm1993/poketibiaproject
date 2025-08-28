local lootTable = {
    [2160] = 50,
    [16185] = 1,
    [22665] = 2, -- ItemID 5678 com quantidade 3

    -- Adicione mais itens conforme necessário
}

local storageValue = 1001

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)

    if not player then
        return true
    end

    if player:getStorageValue(storageValue) == 1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você já concluiu esta quest.")
        return true
    end

    if next(lootTable) == nil then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "A tabela de recompensas está vazia.")
        return true
    end

    for itemID, quantity in pairs(lootTable) do
        player:addItem(itemID, quantity)
    end

    player:setStorageValue(storageValue, 1)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Parabéns! Você concluiu a quest e recebeu as recompensas.")

    return true
end
