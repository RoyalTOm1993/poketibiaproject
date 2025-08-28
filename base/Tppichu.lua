local t = {
    pos = {x = 2529, y = 2878, z = 8},
    level = 5000
}

function onStepIn(creature, item, position, fromPosition)
    local player = Player(creature) -- Convert creature ID to Player object
    
    if player:getLevel() < t.level then
        player:sendCancelMessage('Apenas jogadores level ' .. t.level .. ' podem fazer a Quest Dark Pichu!')
        player:teleportTo(fromPosition, false)
    else
        player:teleportTo(t.pos, false)
    end
    
    return true
end
