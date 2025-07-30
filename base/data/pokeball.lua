function onDeEquip(cid, item, slot)
	if slot == CONST_SLOT_AMMO or slot == CONST_SLOT_LEFT then
		local player = Player(cid)
		if player and item:isPokeball() then
			local pokeName = item:getSpecialAttribute("pokeName")
			local monsterType = MonsterType(pokeName)
			local portraitId = monsterType:portraitId()
			local putPortrait = player:removeItem(portraitId, 1)
			local portrait = player:getSlotItem(CONST_SLOT_HEAD)
			if not putPortrait and portrait and portrait:getId() ~= portraitId then
				portrait:remove()
				print("WARNING! Problem on remove portrait movements onDeEquip " .. pokeName .. " player " .. player:getName())
			end			
		end
		local ballKey = getBallKey(item:getId())
 		if player and item:isPokeball() and hasSummons(cid) and player:getSummons()[1]:getHealth() > 0 then
--			doRemoveSummon(cid, balls[ballKey].effectRelease, item.uid, true, balls[ballKey].missile)
--			item:transform(balls[ballKey].usedOn)
		end
		if player:getStorageValue(storageRide) == 1 or player:getStorageValue(storageFly) == 1 then
			player:removeCondition(CONDITION_OUTFIT)
			player:changeSpeed(player:getBaseSpeed()-player:getSpeed())
			player:setStorageValue(storageRide, -1)
			player:setStorageValue(storageFly, -1)
			player:say("Thanks!", TALKTYPE_SAY) -- " .. summonName .. "
		end
	end	
	return true
end

function onEquip(cid, item, slot)
	--criar foto dos pokes
	if slot == CONST_SLOT_AMMO then
	local player = Player(cid)
		if player and item:isPokeball() then
			local pokeName = item:getSpecialAttribute("pokeName")
			if not pokeName then return true end
			local monsterType = MonsterType(pokeName)
			local portraitId = monsterType:portraitId()
			if portraitId == 0 then return true end
			local putPortrait = player:addItem(portraitId, 1, false, 1, CONST_SLOT_HEAD)
			if not putPortrait and player:getSlotItem(CONST_SLOT_HEAD) and player:getSlotItem(CONST_SLOT_HEAD):getId() ~= portraitId then
				print("WARNING! Problem on put portrait movements onEquip " .. pokeName .. " player " .. player:getName())
			end
		end
	end
	return true
end

