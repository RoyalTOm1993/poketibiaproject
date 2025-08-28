local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

local itemid = 12237
local shopWindow = {items = {}}

local items = {
}

local function onBuy(cid, item, subType, amount, ignoreCap, inBackpacks)
    local player = Player(cid)
    if player:getItemCount(itemid) < items[item].price * amount then
        selfSay("Você não tem "..items[item].price * amount.." de Black Diamonds.", cid)
    elseif  ItemType(item):isStackable() then
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
            local itemName = ItemType(itemID):getName() -- Get the name of the item based on its ID
            table.insert(shopWindow, {id = itemID, subType = 0, buy = ret.price, sell = 0, name = itemName})
        end
        openShopWindow(cid, shopWindow, onBuy, nil)
    end
    return true
end


npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
