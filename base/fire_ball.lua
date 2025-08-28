local MISSILE_TYPE = 4

local combat = createCombatObject()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 347)
combat:setStringParameter(COMBAT_PARAM_STRING_SPELLNAME, "Fire Ball")

local spell = Spell(SPELL_INSTANT)

function spell.onCastSpell(creature, variant)
    local creaturePos = creature:getPosition()
    local target = creature:getTarget()
    local centerPos = target and target:getPosition() or creaturePos

    -- Enviar o míssil para a posição do alvo, se houver
    doSendDistanceShoot(creaturePos, centerPos, MISSILE_TYPE)

    local area = {
        {0, 1, 1, 1, 0},
        {1, 1, 1, 1, 1},
        {1, 1, 3, 1, 1},
        {1, 1, 1, 1, 1},
        {0, 1, 1, 1, 0}
    }

    for x = -2, 2 do
        for y = -2, 2 do
            if area[x + 3][y + 3] == 1 or (x == 0 and y == 0) then
                local pos = Position(centerPos.x + x, centerPos.y + y, centerPos.z)
                combat:execute(creature, Variant(pos))
            end
        end
    end

    return true
end

spell:name("Fire Ball")
spell:words("#Fire Ball#")
spell:isAggressive(true)
spell:needLearn(false)
spell:register()
