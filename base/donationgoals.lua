local OPCODE = 8

DonationGoalKey = 85210
GoalStartDate = "2024-04-09T00:00:00Z"
GoalEndDate = "2024-05-09T23:59:59Z"

newGoalStartDate = "2024-04-09 00:00:00"
newGoalEndDate = "2024-05-09 00:00:00"

globalGoalReward = {
  -- { 
    -- type = "ITEM", 
    -- reward = {id = 40889, count = 5},
	-- desc = "A pokï¿½ball superior to Ultra Ball if used on NORMAL or PSYCHIC type pokï¿½mon",
    -- meta = 2000, 
	-- playerDonate = 180,
    -- storage = DonationGoalKey+1 
  -- },
  {
    type = "POKEMON", 
    reward = "Mewtwo Degolador De Deuses", 
    outfit = {type = 4997, head = 0, body = 0, legs = 0, feet = 0},
    desc = "Recolha Seu Degolador De Tier Deus!.",
  
    meta = 3500, 
    playerDonate = 100,
    storage = DonationGoalKey+1 
  },
}

goalsReward = {
  { type = "ITEM", meta = 25, reward = {id = 22664, count = 10}, desc = "10 Experience Booster 400%!.", storage = DonationGoalKey+2 },
  { type = "ITEM", meta = 50, reward = {id = 22868, count = 15}, desc = "15 Monster Tickets!.", storage = DonationGoalKey+3 },
   { type = "ITEM", meta = 140, reward = {id = 21081, count = 1}, desc = "Card Tier [Deus], Da Os Status De 80% Ao Seu pokemon!.",  storage = DonationGoalKey+4 },

  -- { type = "POKEMON", meta = 180, reward = "Legendary Arceus", outfit = 3008, desc = "Um pokï¿½mon lendï¿½rio, capaz de derrotar atï¿½ os mais dificeis bosses.", storage = DonationGoalKey+4 },
}

function doSendDonationGoalsInformation(player)
  informations = {
	ServerGoal = doGetDonateGlobal(GoalStartDate, GoalEndDate),
	PlayerGoal = getTotalDonationPlayer(GoalStartDate, GoalEndDate, player:getName()),
	globalGoal = getTableConverted(player, globalGoalReward),
	personalGoal = getTableConverted(player, goalsReward),
	date = {
		AtualDate = getFormattedDate(),
		EndDate = GoalEndDate
	}
  }
  sendDonateGoalsByJSON(player, "DonationGoalsInformation", informations)
end

function getTableConverted(player, receivedTable)
  local convertedTable = {}

  for i, item in ipairs(receivedTable) do
    local convertedItem = {}

    if item.type == "ITEM" then
      if item.reward then
        local rewardItem = ItemType(item.reward.id)
        local clientId = rewardItem:getClientId()
        local itemName = getItemName(item.reward.id)
        local rewardDesc = itemName .. "\n" .. (item.desc or "")
        convertedItem.type = item.type
        convertedItem.reward = { id = clientId, count = item.reward.count }
        convertedItem.desc = rewardDesc
      else
        convertedItem.type = item.type
        convertedItem.desc = item.desc or ""
      end
      if item.storage then
        local storageValue = player:getStorageValue(item.storage)
        convertedItem.storage = storageValue
      end
      if item.meta then
        convertedItem.meta = item.meta
      end
      if item.playerDonate then
        convertedItem.playerDonate = item.playerDonate
      end
    elseif item.type == "POKEMON" then
      if item.reward then
        local rewardDesc = item.reward .. "\n" .. (item.desc or "")
        convertedItem.type = item.type
        convertedItem.desc = rewardDesc
      else
        convertedItem.type = item.type
        convertedItem.desc = item.desc or ""
      end
      if item.storage then
        local storageValue = player:getStorageValue(item.storage)
        convertedItem.storage = storageValue
      end
      if item.meta then
        convertedItem.meta = item.meta
      end
      if item.outfit then
        convertedItem.outfit = item.outfit
      end
      if item.playerDonate then
        convertedItem.playerDonate = item.playerDonate
      end
    end

    table.insert(convertedTable, convertedItem)
  end

  return convertedTable
end

function doCollectGoalReward(player, position)
  local jogadorSelecionado = player:getName()
  local globalDonateValue = doGetDonateGlobal(GoalStartDate, GoalEndDate)
  local playerDonateValue = getTotalDonationPlayer(GoalStartDate, GoalEndDate, jogadorSelecionado)
  local getGlobalStorage = player:getStorageValue(goalsReward[position].storage)
      
  if playerDonateValue >= goalsReward[position].meta then
 
     if getGlobalStorage == -1 then
        if goalsReward[position].type == "ITEM" then
  		local reward = goalsReward[position].reward
  	    player:addItem(reward.id, reward.count)

  		player:setStorageValue(goalsReward[position].storage, 1)
  		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Parabéns! Você atingiu sua meta de doação pessoal e recebeu a seguinte recompensa: "..ItemType(reward.id):getName()) 
  	  elseif goalsReward[position].type == "POKEMON" then
  		local reward = goalsReward[position].reward
            doAddPokeball(player, reward)
            doSendPokeTeamByClient(player)

  		player:setStorageValue(goalsReward[position].storage, 1)
  		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Parabéns Você ajudou o servidor a atingir a meta de doação global e recebeu o seguinte pokémon: "..reward)
  	  end
     else
  	  player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você já coletou essa recompensa.")
     end
  else
     player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa ajudar o servidor com pelo menos "..goalsReward[position].meta.." pontos para coletar essa recompensa.")
  end
end

function doCollectGlobalReward(player)
    local jogadorSelecionado = player:getName()
    local globalDonateValue = doGetDonateGlobal(GoalStartDate, GoalEndDate)
    local playerDonateValue = getTotalDonationPlayer(GoalStartDate, GoalEndDate, jogadorSelecionado) -- getTotalSpendingAmountOfDiamonds(GoalStartDate, GoalEndDate, player:getName())
    local getGlobalStorage = player:getStorageValue(globalGoalReward[1].storage)
    if globalDonateValue >= globalGoalReward[1].meta then
        if playerDonateValue >= globalGoalReward[1].playerDonate then
	        if getGlobalStorage == -1 then
	            if globalGoalReward[1].type == "ITEM" then
			        local reward = globalGoalReward[1].reward
		            player:addItem(reward.id, reward.count)
			        player:setStorageValue(globalGoalReward[1].storage, 1)
			        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Parabéns! Você ajudou o servidor a atingir a meta de doação global e recebeu a seguinte recompensa: "..ItemType(reward.id):getName()) 
		        elseif globalGoalReward[1].type == "POKEMON" then
			        local reward = globalGoalReward[1].reward
                    if reward == "Maga Negra" then
                        player:addOutfit(globalGoalReward[1].outfit.type)
                        return player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Parabéns! Você ajudou o servidor a atingir a meta de doação global e recebeu a outfit maga negra")
                    end
                    doAddPokeball(player:getId(), reward)
                    doSendPokeTeamByClient(player)
			        player:setStorageValue(globalGoalReward[1].storage, 1)
			        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Parabéns! Você ajudou o servidor a atingir a meta de doação global e recebeu o seguinte pokémon: "..reward)
		        end
	        else
		        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você já coletou a recompensa global deste mês.")
	        end
	    else
	        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa ajudar o servidor com pelo menos "..globalGoalReward[1].playerDonate.." pontos para coletar a recompensa de meta global.")
	    end
    else
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Ainda não atingimos a meta de doação global!")
    end
end

function doGetDonateGlobal(dataInicial, dataFinal)
  local totalDonate = 0
   --\/- API EFI -\/-
  local resultId = db.storeQuery("SELECT * FROM `pix_payment` WHERE `creation` BETWEEN '" .. dataInicial .. "' AND '" .. dataFinal .. "' AND `status` = 'CONCLUIDA' ORDER BY `loc_id` DESC")
  if resultId ~= false then
      repeat
        local value = result.getDataString(resultId, "price")
		local formattedPrice = string.format("%.2f", value)
		formattedPrice = string.gsub(formattedPrice, "%.?0+$", "") 
        totalDonate = totalDonate + tonumber(formattedPrice)
      until not result.next(resultId)
      result.free(resultId)
  end
  --\/- API MERCADOPAGO -\/-
  local newResultId = db.storeQuery("SELECT * FROM `historico_pagamentos` WHERE `date_created` BETWEEN '" .. newGoalStartDate .. "' AND '" .. newGoalEndDate .. "' AND `status` = '4' AND `entregue` = '1' ORDER BY `id` DESC")
  if newResultId ~= false then
    repeat
      local value = result.getDataInt(newResultId, "valor")
      totalDonate = totalDonate + value
    until not result.next(newResultId)
      result.free(newResultId)
  end
  totalDonate = totalDonate
  if totalDonate > globalGoalReward[1].meta then
  -- totalDonate = globalGoalReward[1].meta
  end

  return totalDonate
end

function getTotalDonationPlayer(startDate, endDate, jogadorSelecionado)
  local playerGUID = getPlayerGUIDByName(jogadorSelecionado)
  local totalDonate = 0
   --\/- temporary query -\/-
  local resultId = db.storeQuery("SELECT * FROM `pix_payment` WHERE `player_id` = '" .. playerGUID .. "' AND `creation` BETWEEN '" .. startDate .. "' AND '" .. endDate .. "' AND `status` = 'CONCLUIDA' ORDER BY `loc_id` DESC")
  if resultId ~= false then
      repeat
        local value = result.getDataString(resultId, "price")
		    local formattedPrice = string.format("%.2f", value)
		    formattedPrice = string.gsub(formattedPrice, "%.?0+$", "") 
        totalDonate = totalDonate + tonumber(formattedPrice)
      until not result.next(resultId)
        result.free(resultId)
  end
--/\- temporary query -/\-
  local newResultId = db.storeQuery("SELECT * FROM `historico_pagamentos` WHERE `player_id` = '" .. playerGUID .. "' AND `date_created` BETWEEN '" .. newGoalStartDate .. "' AND '" .. newGoalEndDate .. "' AND `status` = '4' AND `entregue` = '1' ORDER BY `id` DESC")
  if newResultId ~= false then
    repeat
      local value = result.getDataInt(newResultId, "valor")
      totalDonate = totalDonate + value
    until not result.next(newResultId)
      result.free(newResultId)
  end
  return totalDonate
end

function string.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function sendDonateGoalsByJSON(player, action, data)
  local MAX_PACKET_SIZE = 50000
  
  local buffer = json.encode({action = action, data = data})
  local s = {}
  for i = 1, #buffer, MAX_PACKET_SIZE do
      s[#s + 1] = buffer:sub(i, i + MAX_PACKET_SIZE - 1)
  end
  local msg = NetworkMessage()
  if #s == 1 then
      msg:addByte(50)
      msg:addByte(OPCODE)
      msg:addString(s[1])
      msg:sendToPlayer(player)
      return
  end
  -- split message if too big
  msg:addByte(50)
  msg:addByte(OPCODE)
  msg:addString("S" .. s[1])
  msg:sendToPlayer(player)
  for i = 2, #s - 1 do
      msg = NetworkMessage()
      msg:addByte(50)
      msg:addByte(OPCODE)
      msg:addString("P" .. s[i])
      msg:sendToPlayer(player)
  end
  msg = NetworkMessage()
  msg:addByte(50)
  msg:addByte(OPCODE)
  msg:addString("E" .. s[#s])
  msg:sendToPlayer(player)
end

function getFormattedDate()
  local currentTime = os.time()
  local formattedDate = os.date("%d-%m-%Y", currentTime)
  return formattedDate
end