local t = {
    level = 40000,
    inicio = {
        {x = 3356, y = 2487, z = 8}, -- Lugar onde o primeiro jogador vai estar
        {x = 3357, y = 2487, z = 8}, -- Lugar onde o segundo jogador vai estar
        {x = 3358, y = 2487, z = 8}, -- Lugar onde o terceiro jogador vai estar
    },
    destino = {
        {x = 3337, y = 2469, z = 8}, -- Local para onde o primeiro jogador será teleportado
        {x = 3358, y = 2469, z = 8}, -- Local para onde o segundo jogador será teleportado
        {x = 3380, y = 2469, z = 8}, -- Local para onde o terceiro jogador será teleportado
    },
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local players = {}

    for k, v in pairs(t.inicio) do
        local tile = Tile(v)
        local creature = tile:getTopCreature()
        if not creature or not creature:isPlayer() or creature:getLevel() < t.level then 
            doPlayerSendCancel(cid, 'Alguém não cumpre os requisitos da quest!')
            doTransformItem(item.uid, item.itemid == 5074 and 5074 or 5074)
            return true 
        end

        table.insert(players, {player = creature, destination = t.destino[k]})
    end

    for k, v in pairs(players) do
        v.player:teleportTo(v.destination)
    end

    doTransformItem(item.uid, item.itemid == 5074 and 5074 or 5074)
    return true
end
