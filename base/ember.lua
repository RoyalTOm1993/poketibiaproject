local combat = createCombatObject()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, 4)
combat:setParameter(COMBAT_PARAM_EFFECT, 372)
combat:setStringParameter(COMBAT_PARAM_STRING_SPELLNAME, "Ember")

local spell = Spell(SPELL_INSTANT)

function spell.onCastSpell(creature, variant)
    local targetPosition = variant:getPosition()  -- Obtém a posição do alvo diretamente do variant

    -- Desloca a posição 1 SQM para o sul e 1 SQM para a direita
    local newPosition = Position(targetPosition.x + 1, targetPosition.y + 1, targetPosition.z)

    -- Envia o efeito visual na nova posição
    doSendMagicEffect(newPosition, 372)

    -- Executa o combate
    combat:execute(creature, variant)

    return true
end

spell:name("Ember")
spell:words("##Ember##")
spell:isAggressive(true)
spell:needLearn(false)
spell:range(6)
spell:needTarget(true)
spell:register()
