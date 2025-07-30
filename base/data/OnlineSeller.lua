local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

local requiredStorage = 71344  -- Defina o número da storage necessária para comprar os itens
local shopWindow = {items = {}}

local items = {
    [12426] = {price = 5}, -- itemid da picareta
    [17314] = {price = 1}, -- itemid da picareta
    [17311] = {price = 3}, -- itemid da picareta
    [17312] = {price = 5}, -- itemid da picareta
    [17313] = {price = 10}, -- itemid da picareta
    [10223] = {price = 5}, -- itemid da picareta
    [13228] = {price = 50}, -- itemid da picareta
    [14600] = {price = 1}, -- itemid da picareta
    [20699] = {price = 2}, -- itemid da picareta
    [20701] = {price = 5}, -- itemid da picareta
    [20700] = {price = 7}, -- itemid da picareta
}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

-- Tabela de nomes de itens por ID
-- Tabela de nomes de itens por ID
local itemNames = {
    [12426] = "Erva Pokemon",
    [17314] = "Boss Chave Noob",
    [17311] = "Boss Chave Facil",
    [17312] = "Boss Chave Media",
    [17313] = "Boss Chave Hard",
    [10223] = "mechanical fishing rod",
    [13228] = "Master ball",
    [14600] = "Legendary Potion",
    [20699] = "Pena De Invocaçao Articuno",
    [20701] = "Pena De Invocaçao Moltres",
    [20700] = "Pena De Invocaçao Zapdos",

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
            selfSay("Você não tem " .. items[item].price * amount .. " Online Points suficientes.", cid)
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