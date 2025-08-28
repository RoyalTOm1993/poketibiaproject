local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

local itemid = 12237

local items = {
    [22717] = {price = 100, name = "carpet"},
    [22719] = {price = 100, name = "carpet"},
    [22721] = {price = 100, name = "carpet"},
    [22723] = {price = 100, name = "carpet"},
    [22725] = {price = 100, name = "carpet"},
    [22727] = {price = 100, name = "carpet"},
    [22729] = {price = 100, name = "carpet"},
    [22731] = {price = 100, name = "carpet"},
    [22733] = {price = 100, name = "carpet"},
    [22735] = {price = 100, name = "carpet"},
    [22737] = {price = 100, name = "carpet"},
    [22740] = {price = 100, name = "carpet"},
    [22742] = {price = 100, name = "carpet"},
    [22744] = {price = 100, name = "carpet"},
    [22746] = {price = 100, name = "carpet"},
    [22748] = {price = 100, name = "carpet"},
    [22750] = {price = 100, name = "carpet"},
    [22752] = {price = 100, name = "carpet"},
    [22754] = {price = 100, name = "carpet"},
    [22756] = {price = 100, name = "carpet"},
    [22758] = {price = 100, name = "carpet"},
    [22760] = {price = 100, name = "carpet"},
    [22767] = {price = 100, name = "carpet"},
    [22770] = {price = 100, name = "carpet"},
    [22774] = {price = 100, name = "carpet"},
    [22776] = {price = 100, name = "carpet"},
    [22778] = {price = 100, name = "carpet"},
}

local function onBuy(cid, item, subType, amount, ignoreCap, inBackpacks)
    local player = Player(cid)
    if items[item] and player:getItemCount(itemid) < items[item].price * amount then
        selfSay("Você não tem " .. items[item].price * amount .. " de Black Diamonds.", cid)
    else
        if ItemType(item):isStackable() then
            player:addItem(item, amount)
            player:removeItem(itemid, items[item].price * amount)
            selfSay("Obrigado por comprar.", cid)
        else
            for i = 1, amount do
                player:addItem(item, 1)
            end
            player:removeItem(itemid, items[item].price * amount)
            selfSay("Obrigado por comprar.", cid)
        end
    end
end

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)
    local player = Player(cid)
    if not npcHandler:isFocused(cid) then
        return false
    end

    if msgcontains(msg, 'trade') or msgcontains(msg, 'TRADE') then
        local shopWindow = {}
        for itemID, ret in pairs(items) do
            table.insert(shopWindow, {id = itemID, subType = 0, buy = ret.price, sell = 0, name = ret.name})
        end
        openShopWindow(cid, shopWindow, onBuy, nil)
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
