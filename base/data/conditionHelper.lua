local conditionHelper = {}

conditionHelper.addConfusion = function(creature, ticks, eff, effTicks)
    local creature = Creature(creature)
    if not creature then return false end

    local condition = Condition(CONDITION_CONFUSION)
    condition:setTicks(ticks)
    condition:setParameter(CONDITION_PARAM_EFFECT, eff)
    condition:setParameter(CONDITION_PARAM_EFFECT_TICKS, effTicks)

    creature:addCondition(condition)
end

conditionHelper.addStun = function(creature, ticks, eff, effTicks)
    local creature = Creature(creature)
    if not creature then return false end

    local condition = Condition(CONDITION_STUN)
    condition:setTicks(ticks)
    condition:setParameter(CONDITION_PARAM_EFFECT, eff)
    condition:setParameter(CONDITION_PARAM_EFFECT_TICKS, effTicks)

    creature:addCondition(condition)
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    toPosition:sendMagicEffect(14)

    --  conditionHelper.addConfusion(player:getId(), 10000, 32, 1000
    local summon = player:getSummons()[1]
    conditionHelper.addConfusion(summon:getId(), 10000, 32, 1000)
    -- conditionHelper.addStun(summon:getId(), 10000, 330, 1000)
    return true
end
