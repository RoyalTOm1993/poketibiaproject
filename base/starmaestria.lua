function onUse(player, item, fromPosition, target, toPosition)
	if not target or type(target) ~= "userdata" or not Item(target.uid) then
		return player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Use em uma pokebola!.")
	end
	if not target:isPokeball() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Use em uma pokebola!.")
		return true
	end
	-- Star 20669
	-- maestria 16361
	-- particle 23150
	local star =  target:getSpecialAttribute("starFusion") or 0
	local maestria = target:getSpecialAttribute("maestria") or 0
	local particle = target:getSpecialAttribute("shader")

    if item.itemid == 20669 then -- Star
        if star >= 5 then
            player:sendCancelMessage("Voc� est� no n�vel m�ximo!")
            return true
        end
            target:setSpecialAttribute("starFusion", star + 1)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Voc� aumentou um n�vel da star fusion")
            item:remove(1)
		
    elseif item.itemid == 16361 then -- Maestria
        if  maestria >= 4 then
            player:sendCancelMessage("Voc� est� no n�vel m�ximo!")
            return true
        end
            target:setSpecialAttribute("maestria", maestria + 1)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Voc� aumentou a maestria do seu pok�mon")
            item:remove(1)
	elseif item.itemid == 23150 then
		if particle then
            player:sendCancelMessage("Seu pok�mon j� possui particle aura!")
            return true
		end
		target:setSpecialAttribute("shader", 0)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Voc� ativou a particle aura no seu pok�mon!")
		item:remove(1)
    end
    return true
end
