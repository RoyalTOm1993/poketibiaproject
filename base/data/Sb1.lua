local lootTable = {
    [2160] = 50, -- ItemID 1234 com quantidade 1
    [16207] = 1, -- ItemID 5678 com quantidade 3
    -- Adicione mais itens conforme necess�rio
}

local requiredStorage = 10022
local rewardedStorage = 10023

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)

    if not player then
        return true
    end

    if player:getStorageValue(requiredStorage) ~= 1 then
        -- Envia uma mensagem global para todos os jogadores online
        broadcastMessage("O jogador " .. player:getName() .. " tentou concluir a quest Super Box1, mas ainda n�o completou a box 25!")

        return true
    end

    if player:getStorageValue(rewardedStorage) == 1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� j� concluiu esta quest.")
        return true
    end

    if next(lootTable) == nil then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "A tabela de recompensas est� vazia..")
        return true
    end

    for itemID, quantity in pairs(lootTable) do
        player:addItem(itemID, quantity)
    end

    player:setStorageValue(rewardedStorage, 1)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Parab�ns! Voc� concluiu a quest e recebeu as recompensas.")

    return true
end






