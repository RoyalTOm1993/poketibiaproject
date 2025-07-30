local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

local requiredStorage = 32070  -- Defina o número da storage necessária para comprar os itens
local shopWindow = {items = {}}

local items = {
    [20653] = {price = 16},  -- itemid da picareta
    [20682] = {price = 1}, -- itemid da picareta
    [17165] = {price = 40}, -- itemid da picareta
    [17166] = {price = 60}, -- itemid da picareta
    [20669] = {price = 100}, -- itemid da picareta
    [20652] = {price = 20}, -- itemid da picareta
    [6569] = {price = 1} -- itemid da picareta
}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

-- Tabela de nomes de itens por ID
local itemNames = {
    [20653] = "Kit Boost Stone",
    [20682] = "Scroll 1250",
    [17165] = "Regen Orb",
    [17166] = "Exp Orb",
    [20669] = "Star Fusion",
    [20652] = "Held Box T12",
    [6569] = "Rare Candy",
    -- Adicione mais itens aqui conforme necessário
}

-- Função para obter o nome do item pelo ID
local function getItemNameById(itemId)
    return itemNames[itemId] or "Item Desconhecido"
end

-- ...

function creatureSayCallback(cid, type, msg)
    if (not npcHandler:isFocused(cid)) then
        return false
    end

    local talkUser = cid

    local onBuy = function(cid, item, subType, amount, ignoreCap, inBackpacks)
        local playerStorage = getPlayerStorageValue(cid, requiredStorage)

        if items[item] and playerStorage < items[item].price * amount then
            selfSay("Você não tem " .. items[item].price * amount .. " Reset Points suficientes.", cid)
        else
            if isItemStackable(item) then
                doPlayerAddItem(cid, item, amount)
                setPlayerStorageValue(cid, requiredStorage, playerStorage - items[item].price * amount)
                selfSay("Obrigado por comprar.", cid)
            else
                if amount > 1 then
                    selfSay("Você não pode comprar este item em grupo.", cid)
                    return true
                else
                    doPlayerAddItem(cid, item, 1)
                    setPlayerStorageValue(cid, requiredStorage, playerStorage - items[item].price)
                    selfSay("Obrigado por comprar.", cid)
                    return true
                end
            end
        end
    end

    if msgcontains(msg, 'trade') or msgcontains(msg, 'TRADE') then
        for i = 1, #shopWindow.items do
            shopWindow.items[i] = nil
        end

        for itemId, itemData in pairs(items) do
            local itemName = getItemNameById(itemId)
            table.insert(shopWindow.items, { id = itemId, subType = 0, buy = itemData.price, sell = 0, name = itemName })
        end

        openShopWindow(cid, shopWindow.items, onBuy, nil)
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())