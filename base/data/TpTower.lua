local t = {
   pos = {x = 3169, y = 2343, z = 15},
   level = 10000
}

function onStepIn(player, item, position, fromPosition)
    local cid = player:getId() -- Get the player's ID from the player object

    if player:getLevel() < t.level then
        player:sendCancelMessage('Apenas jogadores level ' .. t.level .. ' podem passar aqui.')
        player:teleportTo(fromPosition)
    else
        player:teleportTo(t.pos)
    end

    return true
end
