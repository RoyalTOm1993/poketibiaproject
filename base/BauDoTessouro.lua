local USE_INTERVAL = 30 -- Tempo de espera em segundos
local ITEM_STORAGE = 9865 -- Chave de armazenamento para controlar o uso do item

-- Função para remover o item do chão após um jogador pegá-lo
local function removeItemFromGround(position, itemid)
    local groundItem = Tile(position):getItemById(itemid)
    if groundItem then
        groundItem:remove()
    end
end

local function canUseItem(player)
    local lastUse = player:getStorageValue(ITEM_STORAGE)
    local currentTime = os.time()
    
    if lastUse == -1 or currentTime - lastUse >= USE_INTERVAL then
        return true
    else
        local timeLeft = USE_INTERVAL - (currentTime - lastUse)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Esse Tesouro Ja Foi Saqueado!.")
        return false
    end
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not canUseItem(player) then
        return true
    end

    local itemsReceived = {}  -- Lista para armazenar os itens recebidos
    local possibleItems = {
        {itemid = 14435, min = 100, max = 2000},
        {itemid = 14434, min = 100, max = 2000},
        {itemid = 13198, min = 100, max = 2000},
        {itemid = 13234, min = 100, max = 2000},
        {itemid = 12237, min = 100, max = 500},
        {itemid = 13559, min = 1, max = 5},
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
    for i = 1, math.random(1, 3) do
        local randomItem = possibleItems[math.random(#possibleItems)]
        local amount = math.random(randomItem.min, randomItem.max)
        local itemType = ItemType(randomItem.itemid)
        if itemType then
            player:addItem(randomItem.itemid, amount)
            table.insert(itemsReceived, amount .. "x " .. itemType:getName())
        end
    end

    local receivedItemsMessage = "e recebeu: " .. table.concat(itemsReceived, ", ")
    Game.broadcastMessage(player:getName() .. " acabou de abrir um bau do tesouro!, " .. receivedItemsMessage, MESSAGE_EVENT_ADVANCE)

    for _, otherPlayer in ipairs(Game.getPlayers()) do
        otherPlayer:setStorageValue(ITEM_STORAGE, os.time()) -- Armazena o tempo em que o item foi usado para todos os jogadores
    end

    -- Remove o baú do tesouro do chão após o jogador clicar nele
    removeItemFromGround(fromPosition, item:getId())

    return true
end