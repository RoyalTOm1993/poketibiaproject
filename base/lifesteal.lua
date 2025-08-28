local acombat = createCombatObject()
local combat = createCombatObject()

combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FLYINGDAMAGE)
combat:setStringParameter(COMBAT_PARAM_STRING_SPELLNAME, "Lifesteal")

local area = createCombatArea(NO_AREA)
local area2 = createCombatArea(
{
    {0, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 2, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 0}
}
)

combat:setArea(area2)
acombat:setArea(area)

--

local function AttackDown(params)
    local creature = Creature(params.cid)
    if not creature then
        return
    end

    local position = Position(params.pos)
    position:sendMagicEffect(params.effectId)
end

function onTargetTile(creature, pos)
    -- Deslocando 1 SQM para baixo em relação à posição alvo
    local effectPosition = {x = pos.x + 3, y = pos.y + 3, z = pos.z}  -- Modificado de y + 2 para y + 3
    addEvent(AttackDown, 0, {cid = creature:getId(), pos = effectPosition, effectId = 2515})
end

local function damagear(param)
    local creature = Creature(param.cid)
    if not creature then
        return
    end

    param.combat:execute(creature, param.var)
end

acombat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")

local spell = Spell(SPELL_INSTANT)
function spell.onCastSpell(creature, variant)
    -- Agendamento para executar o dano de forma assíncrona, com a verificação de existência
    addEvent(function()
        local creatureInstance = Creature(creature:getId())
        if creatureInstance then
            damagear({cid = creature:getId(), var = variant, combat = combat})
        end
    end, math.random(0, 300))
    
    -- Verificação antes de executar o combate
    if Creature(creature:getId()) then
        return acombat:execute(creature, variant)
    end

    return false -- Retorna false caso a criatura não exista mais
end

spell:name("Lifesteal")
spell:words("#Lifesteal#")
spell:isAggressive(true)
spell:needLearn(false)
spell:register()
