local OPCODE_DONATIONGOALS = 8
local OPCODE_REQUEST_MANAGER = 1

function onExtendedOpcode(player, opcode, buffer)

	if opcode == OPCODE_MARKET then
		player:handleMarket(buffer)
		return
	end

	if opcode == OPCODE_TASKS_KILL then
		player:handleTasksKill(buffer)
		return
	end

	if opcode == EXTENDED_OPCODE_CONTRACT then
		player:handleContract(buffer)
		return
	end

	if opcode == OPCODE_REQUEST_MANAGER then
		player:requestModule(buffer)
		return
	end

	if opcode == OPCODE_BANK then
		player:handleBank(buffer)
		return
	end

	if opcode == OPCODE_REDEEM_CODES then
		player:handleRedeemCodes(buffer)
		return
	end

	if opcode == OPCODE_NEW_SHOP then
		player:handleShop(buffer)
		return
	end

    if opcode == 53 then
        player:handlePokebar(buffer)
      	return
    end
	
    if opcode == POKEDEX_OPCODE then
        player:handlePokedex(buffer)
        return
    end

    if opcode == OPCODE_DONATIONGOALS then
        if buffer == "doCollectPersonalReward1" then
            doCollectGoalReward(player, 1)
        elseif buffer == "doCollectPersonalReward2" then
            doCollectGoalReward(player, 2)
        elseif buffer == "doCollectPersonalReward3" then
            doCollectGoalReward(player, 3)
        elseif buffer == "doCollectGlobalReward" then
            doCollectGlobalReward(player)
        end
		return
    end

	if opcode == 78 then
		local data = json.decode(buffer)
		local type = data.type
		
		if type == "check" then
			if #player:getSummons() == 0 then
				doPlayerPopupFYI(player, "Você não possui o pokemon ativo.")
				return true
			end
			local ball = player:getUsingBall()
			if not ball then return end
			if ball:getSpecialAttribute("shader") then
				local shaderId = tonumber(data.shader)
				local shader = SHADERSLIST[shaderId]
				if shader then
					ball:setSpecialAttribute("shader", shaderId)
					doPlayerPopupFYI(player, "Particle aura alterado.")
					player:modifierPokemon(0, 0, SHADER_NAMES_TO_IDS[shader], -1)
				end
			else
				doPlayerPopupFYI(player, "Este pokémon não possui particle aura.")
			end
		end
		return true
	end

	if opcode == CODE_GAMESTORE then
		if not GAME_STORE then
			gameStoreInitialize()
			addEvent(refreshPlayersPoints, 10 * 1000)
		end
	
		local status, json_data =
			pcall(
			function()
				return json.decode(buffer)
			end
		)
		if not status then
			return
		end
	
		local action = json_data.action
		local data = json_data.data
		if not action or not data then
			return
		end
	
		if action == "fetch" then
			gameStoreFetch(player)
		elseif action == "purchase" then
			gameStorePurchase(player, data)
		elseif action == "gift" then
			gameStorePurchaseGift(player, data)
		end
	end

end