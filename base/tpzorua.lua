local t = {
    pos = {x = 2656, y = 2466, z = 8},
    level = 8000
}

function onStepIn(creature, item, position, fromPosition)
    local player = Player(creature)
    
    if player:getLevel() < t.level then
        player:sendCancelMessage('Apenas jogadores level ' .. t.level .. ' podem Fazer A Quest Zorua!.')
        player:teleportTo(fromPosition)
    else
        player:teleportTo(t.pos)
    end
    
    return true
end
