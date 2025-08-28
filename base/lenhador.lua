local sources = {22658}
local storageCutting = 604000
local tempo = 5 --  5 segundos

local texts = {
cancel = "Você não pode fazer isso.",
isCutting = "Você já está coletando.",
}

local quebrando = {22651, 22652, 22653, 22654, 22655, 22656}
local nascendo = {22656, 22657, 22650, 22658}

local outfit = {
[1] = 4907,
[0] = 4908
}



function sendReward(playerID, itemID, count)
 local itemsToLootAllWindow = {}
local player = Player(playerID)
if not player then return true end
  local lootidclient = ItemType(itemID):getClientId()
  local itemTable = {id = lootidclient, count = count, lootedBy = player:getId()}
  table.insert(itemsToLootAllWindow, itemTable)
  
  player:addItem(itemID, count)

    local dataLog = {
        tabela = itemsToLootAllWindow,
        creature = playerID
    }
    
  player:sendExtendedOpcode(58, json.encode(dataLog))
end

local function changePlayerDirection(pos, pos2)
    local x1, y1 = pos.x, pos.y
    local x2, y2 = pos2.x, pos2.y

    if x1 - x2 <= 0 and y1 - y2 > 0 then
        return DIRECTION_NORTH
    elseif x1 - x2 < 0 and y1 - y2 == 0 then
        return DIRECTION_EAST
    elseif x1 - x2 < 0 and y1 - y2 < 0 then
        return DIRECTION_EAST
    elseif x1 - x2 > 0 and y1 - y2 < 0 then
        return DIRECTION_SOUTH
    elseif x1 - x2 > 0 and y1 - y2 <= 0 then
        return DIRECTION_WEST
    elseif x1 - x2 > 0 and y1 - y2 >= 0 then
        return DIRECTION_WEST
    elseif x1 - x2 == 0 and y1 - y2 < 0 then
        return DIRECTION_SOUTH
    end
    return DIRECTION_WEST
end

function Player:isCutting()
  return self:getStorageValue(storageCutting) == 1 and true or false
end

function Player:resetCutting()
  return self:setStorageValue(storageCutting,0)
end

function Player:startCutting()
  return self:setStorageValue(storageCutting,1)
end

function Player:startCuttingTree(item, fromPosition, toPosition)

local rareRewards = {2674} 
local rareQtd = math.random(2)

local normalRewards = {5901, 22661}
local normalQtd = math.random(4)

self:startCutting()
self:setNoMove(true)
self:setDirection(changePlayerDirection(self:getPosition(), toPosition))
doChangeOutfit(self:getId(), {lookType = outfit[self:getSex()]}, 1000 * tempo)
self:sendProgressbar(tempo*1000, true)

local percentChance = math.random(100)
local rareChance    = math.random(20)

local getRewardNormal = normalRewards[math.random(#normalRewards)]
local getRewardNormalQtd = math.random(1, 4) -- Defina a quantidade como desejado

local getRewardRare = rareRewards[math.random(#rareRewards)]
local getRewardRareQtd = rareQtd


  for num,element in ipairs(quebrando) do
    event =  addEvent(function()  
    local player = Player(self:getId()) 
    if not player then 
      item:transform(22658)
      stopEvent(event) 
      return true
    end 
    item:transform(element) 
    end, (num*280) + ((tempo/1.5)*1000))
  end
  
   for num,element in ipairs(nascendo) do
    addEvent(function() item:transform(element) end, (num*3000) + ((tempo*5)*1000))
  end

  addEvent(function() 
  local player = Player(self:getId()) 
    if player then  
    player:resetCutting() 
    player:setNoMove(false) 
    sendReward(self:getId(), getRewardNormal, getRewardNormalQtd)
    -- print(self:getId(), getRewardNormal, getRewardNormalQtd)
    if percentChance < rareChance then
        addEvent(function() sendReward(self:getId(), getRewardRare, getRewardRareQtd) end, 300)
    end
    
    end 
  end, 200 + (tempo * 1000))

end




function onUse(player, item, fromPosition, target, toPosition, isHotkey)
  
  if player:isCutting() then return  player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, texts.isCutting) end

  if isInArray(sources, target.itemid) then
    player:startCuttingTree(target, fromPosition, toPosition)
    return true
  else 
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, texts.cancel)
  end
	return true
end
