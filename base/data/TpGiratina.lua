local teleportPosition = {x = 3108, y = 3129, z = 8}
local requiredLevel = 5000

function onStepIn(player, item, position, fromPosition)
	if not player:isPlayer() then return true end
	
    if player:getLevel() < requiredLevel then
        player:sendCancelMessage('Apenas jogadores level ' .. requiredLevel .. ' podem passar aqui.')
        player:teleportTo(fromPosition)
    else
        player:teleportTo(teleportPosition)
    end

    return true
end