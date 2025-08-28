local storageValue = 235165

local drops = {22661}

local dropsRaros = {22661}

local maxitens = 2


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


local function dropTable(item, player)
    local player = Player(player)
    local itemDrop

    if math.random(1, 1000) == 1 then
        itemDrop = dropsRaros[math.random(#dropsRaros)]
        if itemDrop then
            local itemName = ItemType(itemDrop):getName()
        end
    else
        itemDrop = drops[math.random(#drops)]
    end

    return itemDrop
end

local function isCollecting(player)
    local player = Player(player)
    return player:getStorageValue(storageValue) == 1
end

local function startCollecting(player)
    local player = Player(player)
    player:setStorageValue(storageValue, 1)
end

local function stopCollecting(player)
    local player = Player(player)
    player:setStorageValue(storageValue, -1)
end

local function sendReward(playerID, itemID, count)
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

local function coletar(player, fromPosition, item, playerName, toPosition)
    local player = Player(player)
      if not player then return true end
    local failChance = 30
    local tempo = 5
    local itemDrop = dropTable(item, player:getId())
    local itemName = ItemType(itemDrop):getName()
    local hundredpercent = math.random(1, 100)

    if player then
        local npos = player:getPosition()
        local pos = fromPosition

        if (pos.x == npos.x) and (pos.y == npos.y) and (pos.z == npos.z) and isCollecting(player) then
            if failChance < hundredpercent then
                local quantity = math.random(1, 2)
                sendReward(player:getId(), itemDrop, quantity)
            end

            player:setDirection(changePlayerDirection(player:getPosition(), toPosition))
            doChangeOutfit(player:getId(), {lookType = 4909}, 1000 * tempo)
            addEvent(coletar, 1000 * tempo, player:getId(), fromPosition, item, playerName, toPosition)
        else
            stopCollecting(player:getId())
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você saiu.")
        end
    end
end


function onUse(player, item, fromPosition, itemEx, toPosition)
        if (player:getStorageValue(17000) >= 1 or player:getStorageValue(63215) >= 1 or
            player:getStorageValue(17001) >= 1) then
            return player:sendCancelMessage("Não é possível fazer isso.")
        end

        if isCollecting(player) then
            return player:sendCancelMessage("Você já está coletando.")
        end

        startCollecting(player:getId())
        coletar(player:getId(), player:getPosition(), item:getId(), player:getName(), toPosition)


    return true
end