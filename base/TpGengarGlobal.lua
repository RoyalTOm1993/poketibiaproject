local teleportPosition = {x = 3155, y = 3131, z = 8}
local requiredLevel = 5000

function onStepIn (player, item, position, fromPosition)
    if player:getLevel() < requiredLevel then
        player:sendCancelMessage('Apenas jogadores level ' .. requiredLevel .. ' podem passar aqui.')
        player:teleportTo(fromPosition)
    else
        player:teleportTo(teleportPosition)
    end

    return true
end