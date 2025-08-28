local t = {
    pos = Position(2552, 3113, 8),
    level = 15000
}

function onStepIn(cid, item, position, fromPosition)
    local player = Player(cid)
    if player:getLevel() < t.level then
        player:sendCancelMessage('Apenas jogadores level ' .. t.level .. ' podem Fazer A Quest Latios Types!.')
        player:teleportTo(fromPosition)
    else
        player:teleportTo(t.pos)
    end
    return true
end
