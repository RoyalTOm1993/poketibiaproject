local monsters = {
    {pos = Position(1419, 1662, 15), name = "Espectral Zygarde MVP"},
    {pos = Position(1412, 1683, 15), name = "Mew Ultra"},
}

local config = {
    onSpawnMonster = 29,
    onRemoveItem = 3,
    missingItem = 2,
    despawnTime = 300000, -- Tempo em milissegundos (5 minutos)
    checkRadius = 25 -- Raio de verificação
}

local switch = {pos = Position(1419, 1695, 15), itemid = 1945}

function onUse(player, item, fromPosition, target, toPosition)
    if item:getId() ~= switch.itemid or fromPosition ~= switch.pos then
        return player:sendCancelMessage("Você precisa estar perto da alavanca para ativar.")
    end

    if isMonsterInRange(monsters, config.checkRadius) then
        return player:sendCancelMessage("Já existe um monstro nas proximidades.")
    end

    for _, monsterInfo in pairs(monsters) do
        local monster = Game.createMonster(monsterInfo.name, monsterInfo.pos)
        if monster then
            monster:getPosition():sendMagicEffect(config.onSpawnMonster)
            addEvent(removeMonster, config.despawnTime, monster:getId())
            player:say("O Boss Ira Sumir Em 5 Minutos!", TALKTYPE_ORANGE_1)
        end
    end

    return true
end

function removeMonster(monsterId)
    local monster = Monster(monsterId)
    if monster then
        monster:getPosition():sendMagicEffect(config.onRemoveItem)
        monster:remove()
    end
end

function isMonsterInRange(monsters, radius)
    for _, monsterInfo in pairs(monsters) do
        local creatures = Game.getSpectators(monsterInfo.pos, false, false, radius, radius, radius, radius)
        for i = 1, #creatures do
            local creature = creatures[i]
            if creature:isMonster() and creature:getName() == monsterInfo.name then
                return true
            end
        end
    end
    return false
end
