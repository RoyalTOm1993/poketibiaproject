function onHolders(pokeball)
	print("Holder Created")
	local spawnName = pokeball:getSpecialAttribute("pokeName")
	local pokeBoost = pokeball:getSpecialAttribute("pokeBoost") or 0
	local pokeLevel = pokeball:getSpecialAttribute("pokeLevel") or 1
	local creatureName = string.format("%s [%d] +%d", spawnName, pokeLevel, pokeBoost)
	local spawnType = MonsterType(spawnName)
	local spawnPosition = pokeball:getTopParent():getPosition()
	local npc = Game.createNpc("Holder", spawnPosition, false, true, creatureName, true)
	if npc then
		npc:setSpeechBubble(0)
		toCylinder:setSpecialAttribute("creatureID", npc:getId())
		npc:setOutfit(spawnType:outfit())
		local updateTile = Tile(spawnPosition)
		updateTile:update()
		local ballKey = getBallKey(item:getId())
		npc:getPosition():sendMagicEffect(balls[ballKey].effectRelease)
	end	
end
