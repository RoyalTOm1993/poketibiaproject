local condition = Condition(CONDITION_OUTFIT)
condition:setTicks(-1)

-- Efeitos visuais
local WATER_ENTRY_EFFECT = 1468 -- Efeito inicial de mergulho
local WATER_SPLASH_EFFECT = {
    [DIRECTION_NORTH] = {x = 0, y = 1, effect = 31},   -- Sul
    [DIRECTION_EAST]  = {x = -1, y = 0, effect = 50},  -- Oeste
    [DIRECTION_SOUTH] = {x = 0, y = -1, effect = 31},  -- Norte
    [DIRECTION_WEST]  = {x = 1, y = 0, effect = 52}   -- Leste
}

function onStepIn(creature, item, position, fromPosition)
    if not creature:isPlayer() then 
        creature:teleportTo(fromPosition, false)
        return false
    end
    
    if creature:getStorageValue(storageBike) > 0 then
        creature:sendCancelMessage("Sorry, not possible while on bicycle.")
        creature:teleportTo(fromPosition, false)
        return false
    end
    
    local outfit = 267
    
    if hasSummons(creature) then
        local summon = creature:getSummon()
        local summonName = summon:getName()
        local summonSpeed = summon:getTotalSpeed()
        local monsterType = MonsterType(summonName)
        local surfOutfit = monsterType:isSurfable()
        
        if surfOutfit > 0 then
            if surfOutfit > 1 then outfit = surfOutfit end
            creature:changeSpeed(summonSpeed)
            creature:setStorageValue(storageSurf, outfit)
            condition:setOutfit({lookType = outfit})
            creature:addCondition(condition)
            doRemoveSummon(creature:getId(), false, nil, false)
            creature:say(summonName .. ", let's surf!", TALKTYPE_ORANGE_1)
        else
            creature:sendCancelMessage("Sorry, not possible. Your summon cannot surf.")
            creature:teleportTo(fromPosition, false)
            return false
        end
    else
        if creature:getStorageValue(storageSurf) == -1 then
            creature:sendCancelMessage("Sorry, not possible. You need a summon to surf.")
            creature:teleportTo(fromPosition, false)
            return false
        else
            local surfOutfit = creature:getStorageValue(storageSurf)
            condition:setOutfit({lookType = surfOutfit})
            creature:addCondition(condition)
        end
    end
    
    -- Efeito visual ao entrar na água
    if creature:getStorageValue(storageSurfEffect) ~= 1 then
        doSendMagicEffect(position, WATER_ENTRY_EFFECT)
        creature:setStorageValue(storageSurfEffect, 1)
    else
        local direction = creature:getDirection()
        local effectOffset = WATER_SPLASH_EFFECT[direction]
        local effectPosition = Position(position.x + effectOffset.x, position.y + effectOffset.y, position.z)
        doSendMagicEffect(effectPosition, effectOffset.effect)
    end
    
    return true
end

function onStepOut(creature, item, position, fromPosition)
    if not creature:isPlayer() then return false end
    
    local tile = Tile(creature:getPosition())
    if not tile or not tile:getGround() then return false end
    
    local tileId = tile:getGround():getId()
    if (not isInArray(waterIds, tileId) and position == fromPosition) or (creature:getStorageValue(storageDive) > 0) then
        creature:changeSpeed(creature:getBaseSpeed() - creature:getSpeed())
        creature:setStorageValue(storageSurf, -1)
        creature:setStorageValue(storageSurfEffect, -1)
        doReleaseSummon(creature:getId(), creature:getPosition(), false, false)
        creature:say("Thanks!", TALKTYPE_ORANGE_1)
    end
    
    if not (creature:getStorageValue(storageRide) > 0 or 
            creature:getStorageValue(storageFly) > 0 or 
            creature:getStorageValue(storageBike) > 0 or 
            creature:getStorageValue(storageDive) > 0) then
        creature:removeCondition(CONDITION_OUTFIT)
    end
    
    return true
end
