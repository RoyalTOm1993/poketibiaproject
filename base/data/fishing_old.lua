local monsterTrash = {"Magikarp"}
local monsterCommon = {"Magikarp", "Horsea", "Goldeen", "Tentacool", "Krabby", "Poliwag", "Staryu"}
local monsterRare = {"Magikarp", "Horsea", "Goldeen", "Tentacool", "Krabby", "Poliwag", "Staryu", "Seadra", "Seaking"}
local monsterVeryRare = {"Magikarp", "Horsea", "Goldeen", "Tentacool", "Krabby", "Poliwag", "Staryu", "Seadra", "Seaking", "Gyarados"}
local useWorms = false
local maxSkill = 100

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local targetId = target.itemid
	if not isInArray(waterIds, target.itemid) then
		return false
	end

	if targetId == 493 or targetId == 15402 then
		return true
	end

	if targetId == 10499 then
		local owner = target:getAttribute(ITEM_ATTRIBUTE_CORPSEOWNER)
		if owner ~= 0 and owner ~= player:getId() then
			player:sendTextMessage(MESSAGE_STATUS_SMALL, "You are not the owner.")
			return true
		end

		toPosition:sendMagicEffect(CONST_ME_WATERSPLASH)
		target:remove()
	end

	if targetId ~= 7236 then
		toPosition:sendMagicEffect(CONST_ME_LOSEENERGY)
	end

	if player:getEffectiveSkillLevel(SKILL_FISHING) <= 100 then
		player:addSkillTries(SKILL_FISHING, 1)
	end
	if math.random(1, 100) <= math.min(math.max(10 + (player:getEffectiveSkillLevel(SKILL_FISHING) - 10) * 0.597, 10), 50) then
		if useWorms and not player:removeItem("worm", 1) then
			return true
		end

		local name = "Magikarp"

		if player:getSkillLevel(SKILL_FISHING) < 20 then
			name = monsterTrash[math.random(#monsterTrash)]
		elseif player:getSkillLevel(SKILL_FISHING) >= 20 and player:getSkillLevel(SKILL_FISHING) < 30 then
			name = monsterCommon[math.random(#monsterCommon)]
		elseif player:getSkillLevel(SKILL_FISHING) >= 30 and player:getSkillLevel(SKILL_FISHING) < 40 then
			name = monsterRare[math.random(#monsterRare)]
		elseif player:getSkillLevel(SKILL_FISHING) >= 40 then
			name = monsterVeryRare[math.random(#monsterVeryRare)]
		end

		local monsterType = MonsterType(name)
		if math.random(1, 100) <= shinyChance then
			if monsterType:hasShiny() > 0 then
				name = "Shiny " .. name
				local shinyMonsterType = MonsterType(name)
				if not shinyMonsterType then
					print("WARNING! " .. name .. " not found for respawn.")
					return false
				end
			end
		end

		Game.createMonster(name, player:getClosestFreePosition(player:getPosition()))

		if targetId == 15401 then
			target:transform(targetId + 1)
			target:decay()
		elseif targetId == 7236 then
			target:transform(targetId + 1)
			target:decay()
		end
	end
	return true
end
