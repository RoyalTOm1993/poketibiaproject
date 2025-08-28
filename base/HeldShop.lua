local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

local itemid = 12237 -- Novos points ( default é scarab coin )
local shopWindow = {}
local items = {
 [13391] = {price = 12},
 [13392] = {price = 24},
 [13393] = {price = 48},
 [13394] = {price = 72},
 [13398] = {price = 12},
 [13399] = {price = 24},
 [13400] = {price = 48},
 [13401] = {price = 72},
 [13412] = {price = 12},
 [13413] = {price = 24},
 [13414] = {price = 48},
 [13415] = {price = 72},
 [13426] = {price = 12},
 [13427] = {price = 24},
 [13428] = {price = 48},
 [13429] = {price = 72},
 [13419] = {price = 12},
 [13420] = {price = 24},
 [13421] = {price = 48},
 [13422] = {price = 72},
 [13405] = {price = 12},
 [13406] = {price = 24},
 [13407] = {price = 48},
 [13408] = {price = 72},
 [13484] = {price = 24},
 [13485] = {price = 72},
 [13486] = {price = 100},
 [13487] = {price = 320},
 [13463] = {price = 24},
 [13464] = {price = 72},
 [13465] = {price = 100},
 [13466] = {price = 120},
 [16812] = {price = 24},
 [16813] = {price = 72},
 [16814] = {price = 200},
 [16815] = {price = 320},
 

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
      selfSay("voce nao tem "..items[item].price * amount.." Black Diamonds.", cid)
    else
      print(item)
      doPlayerAddItem(cid, item, amount)
      doPlayerRemoveItem(cid, itemid, (items[item].price) * amount)
      selfSay("Aqui Seus Helds", cid)
    end
  end

  if msgcontains(msg, 'trade') or msgcontains(msg, 'TRADE') then
    for i = 1, #shopWindow do
      shopWindow[i] = nil
    end

    for var, ret in pairs(items) do
      table.insert(shopWindow, {id = var, subType = 0, buy = ret.price, sell = 0, name = getItemNameById(var)})
    end
  
    openShopWindow(cid, shopWindow, onBuy, onSell)
  end
  return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())