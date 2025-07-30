function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	if not creature:hasKilledLegendaryPokemon() then
		creature:sendTextMessage(MESSAGE_INFO_DESCR, "Voce precisa derrotar o pokemon lendario primeiro.")
		creature:teleportTo(fromPosition, true)
		return false
	end

	return true
end
