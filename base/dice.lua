function onUse(player, item, fromPosition, target, toPosition)
    if fromPosition.x ~= CONTAINER_POSITION then
        fromPosition:sendMagicEffect(CONST_ME_CRAPS)
    end

    local minValue = 1
    local maxValue = 6
    local value = math.random(minValue, maxValue)

    player:say(player:getName() .. ' rolled a ' .. value .. '.', TALKTYPE_ORANGE_1)

    return true
end
