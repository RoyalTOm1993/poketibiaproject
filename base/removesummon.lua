function onMove(creature, toPosition, fromPosition)
	local player = Player(creature:getId())
	if not hasSummons(player) then
		return true
	end

	local summon = player:getSummon()
	if summon:getSpeed() == 0 then
		summon:changeSpeed(summon:getTotalSpeed())
	end

        local toTile = Tile(toPosition)

	if toTile and (toTile:getHouse() or toTile:hasFlag(TILESTATE_PROTECTIONZONE)) then 
		if hasSummons(player) then
			doRemoveSummon(player:getId())
			local ball = player:getSlotItem(CONST_SLOT_AMMO)
			if ball then
				local ballId = ball:getId()
				local ballKey = getBallKey(ballId)
				if ballId == balls[ballKey].usedOff then
					ball:transform(balls[ballKey].usedOn)
				end
			end
		end		
	end

	return true
end
