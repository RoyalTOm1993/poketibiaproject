local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

local itemid = 12237 
local shopWindow = {items = {}}

local items = {
 [15221] = {price = 1},
 [13234] = {price = 2},
 [13215] = {price = 5},
 [13198] = {price = 4},
 [14435] = {price = 6},
 [14434] = {price = 8},
 [15226] = {price = 10},
 [14511] = {price = 300},
 [13559] = {price = 300},
 [13560] = {price = 350},
 [13561] = {price = 400},
 [13562] = {price = 500},
 [13563] = {price = 750},
 [2145] = {price = 10000},
}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)
  if(not npcHandler:isFocused(cid)) then
    return false
  end

  local talkUser = NPCHANDLER_CONVbehavior == CONVERSATION_DEFAULT and 0 or cid
  local onBuy = function(cid, item, subType, amount, ignoreCap, inBackpacks)
    if items[item] and getPlayerItemCount(cid, itemid) < items[item].price * amount then
      selfSay("Você não tem "..items[item].price * amount.." Black Diamonds.", cid)
    else
	  if isItemStackable(item) then
        doPlayerAddItem(cid, item, amount)
	    doPlayerRemoveItem(cid, itemid, (items[item].price) * amount)
        selfSay("Obrigado por comprar.", cid)
	  else
	    if amount > 1 then 
	      selfSay("Você não pode comprar este item em grupo.", cid) 
	      return true
	    else 
	      doPlayerAddItem(cid, item, 1)
	      doPlayerRemoveItem(cid, itemid, items[item].price)
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

    for var, ret in pairs(items) do
      table.insert(shopWindow.items, {id = var, subType = 0, buy = ret.price, sell = 0, name = getItemNameById(var)})
    end
  
    openShopWindow(cid, shopWindow.items, onBuy, onSell)
  end
  return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
