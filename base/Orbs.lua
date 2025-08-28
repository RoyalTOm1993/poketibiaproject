function onUse(player, item, fromPosition, target, toPosition)
    local pokeUid = target.uid

    local pokeballs = {23456, 13231, 13229, 11826, 11828, 11832, 11834, 11835, 11837, 11829, 11831, 10975, 10977, 16704, 16706, 16707, 16709, 16710, 16712, 16713, 16715, 16716, 16718, 16719, 16721, 16722, 16724, 16725, 16727, 16728, 16730, 16731, 16733, 16734, 16736, 16737, 16739, 16740, 16742, 22942, 22943, 22944, 22945, 22946, 22947, 22948, 22949, 22950, 22951, 22952, 22953, 22922, 22921} -- colocar todos os ids de balls aqui (com poke dentro)

	if not isInArray(pokeballs,target.itemid) then
	--print("error, player tried to use held on invalid item.") -- 
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Use em uma pokebola!.")
	return true
	end

    if item.itemid == 17166 then -- Exp Orb (ID 17166)
        if target:getSpecialAttribute("expOrb") then
            player:sendCancelMessage("Você já possui!")
            return true
        end
		target:setSpecialAttribute("expOrb", 1)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você usou orb de exp em seu pokemon")
		item:remove(1)
		
    elseif item.itemid == 17165 then -- Regen Orb (ID 17165)
        if target:getSpecialAttribute("regenOrb") then
            player:sendCancelMessage("Você já possui!")
            return true
        end
        target:setSpecialAttribute("regenOrb", 1)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você usou orb de regen em seu pokemon")
        item:remove(1)
    elseif item.itemid == 2150 then -- Cooldown Orb
        if target:getSpecialAttribute("orbCooldown") then
            player:sendCancelMessage("Você já possui!")
            return true
        end
        target:setSpecialAttribute("orbCooldown", 1)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você usou cooldown orb em seu pokemon! redução de 30% de cooldown em spells.")
        item:remove(1)
		
    end

    return true
end
