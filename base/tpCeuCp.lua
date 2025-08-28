local teleportPosition = Position(3082, 2906, 7)

function onStepIn(player, item, position, fromPosition)
	if not player:isPlayer() then return true end
	player:teleportTo(teleportPosition)
    return true
end