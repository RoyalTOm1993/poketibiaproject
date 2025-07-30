local lootTable = {
    [2160] = 50, -- ItemID 1234 com quantidade 1
    [16194] = 1, -- ItemID 5678 com quantidade 3
    [22665] = 2, -- ItemID 5678 com quantidade 3

    -- Adicione mais itens conforme necessário
}

local requiredStorage = 1009
local rewardedStorage = 1010

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)

    if not player then
        return true
    end

    if player:getStorageValue(requiredStorage) ~= 1 then
        -- Envia uma mensagem global para todos os jogadores online
        broadcastMessage("O jogador " .. player:getName() .. " tentou concluir a quest Box 14, mas ainda não completou a box 13!")

        return true
    end

    if player:getStorageValue(rewardedStorage) == 1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você já concluiu esta quest.")
        return true
    end

    if next(lootTable) == nil then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "A tabela de recompensas está vazia..")
        return true
    end

    for itemID, quantity in pairs(lootTable) do
        player:addItem(itemID, quantity)
    end

    player:setStorageValue(rewardedStorage, 1)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Parabéns! Você concluiu a quest e recebeu as recompensas.")

    return true
end






