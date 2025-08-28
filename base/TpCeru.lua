function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local x = 1438
    local y = 2419
    local z = 8
    player:teleportTo(Position(x, y, z))
    player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    return true
end
