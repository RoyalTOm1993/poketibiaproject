function onThink(interval, lastExecution, thinkInterval)

	
local resultId = db.storeQuery("SELECT shop_historico.*, players.name as name_player FROM shop_historico INNER JOIN players ON shop_historico.player_id = players.id WHERE shop_historico.entregue = 0 ;")
		
		if(resultId ~= false) then
			while(true) do
			cid = getPlayerByName(tostring(result.getDataString(resultId,"name_player")))
			
		
			
			product = tonumber(result.getDataInt(resultId,"shop_item_id"))
			itemr = db.storeQuery("SELECT * FROM shop_item WHERE `id` = "..product..";")
			itemr2 = db.storeQuery("SELECT shop_historico.*, players.name as name_player FROM shop_historico INNER JOIN players ON shop_historico.player_id = players.id WHERE `player_id` = '"..tostring(result.getDataString(resultId,"player_id")).."';")
		if (itemr2 ~= false) then
				-- print("Nome:", result.getDataString(itemr2, "name_player"))
				if isPlayer(cid) and getCreatureName(cid) == result.getDataString(itemr2, "name_player") then
					local id = tonumber(result.getDataInt(itemr,"item_id_tibia"))
					local id_historico = tonumber(result.getDataInt(resultId, "id"))							
					local quantidade = tonumber(result.getDataInt(resultId,"quantidade"))
					local type = tonumber(result.getDataInt(itemr, "type"))
					local productn = tostring(result.getDataString(itemr, "nome"))
					if type == 2 then
						if getPlayerFreeCap(cid) >= getItemWeight(id, quantidade) then
							player = Player(cid)
							player:addItem(id,quantidade)
							doPlayerSendTextMessage(cid,19, "You have received >> ".. quantidade .."x "..productn.." << from our shop system")
							db.query("UPDATE `shop_historico` SET `entregue`='1' WHERE id = " .. id_historico .. ";")
						else
							doPlayerSendTextMessage(cid,19, "Sorry, you don't have enough capacity to receive >> "..productn.." << (You need. "..getItemWeight(id, quantidade).." Capacity)")
						end
					elseif type == 1 then
						local pokeFull = tostring(result.getDataString(resultId,"full")) --	F Ou T
							if pokeFull == "T" then
							
								doPlayerSendTextMessage(cid, 19, "Você recebeu o pokémon. " .. productn .. " [FULL] do shop.")
								doAddPokeballFull(cid, productn)
								db.query("UPDATE `shop_historico` SET `entregue`='1' WHERE id = " .. id_historico .. ";")
							else 
								doPlayerSendTextMessage(cid, 19, "Você recebeu o pokémon. " .. productn .. " do shop.")
								doAddPokeball(cid, productn)
								db.query("UPDATE `shop_historico` SET `entregue`='1' WHERE id = " .. id_historico .. ";")
								
							end
				elseif type == 4 then
						local pokeFull = tostring(result.getDataString(resultId,"full")) --	F Ou T
							if pokeFull == "T" then
							
								doPlayerSendTextMessage(cid, 19, "Você recebeu o pokémon. " .. productn .. " [FULL] do shop.")
								doAddPokeballSupreme(cid, productn)
								db.query("UPDATE `shop_historico` SET `entregue`='1' WHERE id = " .. id_historico .. ";")
							else 
								doPlayerSendTextMessage(cid, 19, "Você recebeu o pokémon. " .. productn .. " do shop.")
								doAddPokeball(cid, productn)
								db.query("UPDATE `shop_historico` SET `entregue`='1' WHERE id = " .. id_historico .. ";")
								
							end
										
					elseif type == 3 then
								doPlayerSendTextMessage(cid, 19, "Você recebeu a outfit. " .. productn .. " do shop.")
								 player = Player(cid)
								 player:addOutfit(id)
				
							db.query("UPDATE `shop_historico` SET `entregue`='1' WHERE id = " .. id_historico .. ";") 
					end
				end
			end
			if not(result.next()) then
				break
			end
		end
		result.free()
	end
	
	return true
end
