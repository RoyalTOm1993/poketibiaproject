local playerA = {
    {x = 3231, y = 3481, z = 8}, -- Lugar onde o primeiro player vai estar
    {x = 3229, y = 3481, z = 8}, -- Lugar onde o segundo player vai estar
    {x = 3229, y = 3483, z = 8}, -- Lugar onde o terceiro player vai estar
    {x = 3231, y = 3483, z = 8}, -- Lugar onde o quarto player vai estar
}

local playerB = {
    {x = 3230, y = 3477, z = 8}, -- Lugar onde o primeiro player vai aparecer
    {x = 3230, y = 3478, z = 8}, -- Lugar onde o segundo player vai aparecer
    {x = 3230, y = 3479, z = 8}, -- Lugar onde o terceiro player vai aparecer
    {x = 3230, y = 3480, z = 8}, -- Lugar onde o quarto player vai aparecer
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local players = {}

    for i, pos in pairs(playerA) do
        local tile = Tile(pos)
        local creature = tile:getTopCreature()
        if not creature or not creature:isPlayer() then
            return doPlayerSendCancel(cid, 'Você precisa de 4 jogadores para esta missão.')
        elseif creature:getLevel() < 5000 then -- Level
            return doPlayerSendCancel(cid, 'Todos os jogadores precisam ter nível 5000 ou superior.')
        end
        table.insert(players, creature)
    end

    for i, pos in pairs(playerB) do
        if players[i] then
            players[i]:teleportTo(pos)
            Game.createMonster("EffectArea", pos, false, true)
        end
    end

    return true
end
