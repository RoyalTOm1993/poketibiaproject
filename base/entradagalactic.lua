local t = {
    level = 20000,
    inicio = {
        {x = 3924, y = 2176, z = 0},
        {x = 4019, y = 2205, z = 0},
        {x = 4039, y = 2149, z = 0},
        {x = 4158, y = 2148, z = 0},
        {x = 4154, y = 2207, z = 0},
        {x = 4240, y = 2222, z = 0},
        {x = 4281, y = 2186, z = 0}
    },
    fim = {x = 3923, y = 2140, z = 5}
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local players = {}

    for _, v in ipairs(t.inicio) do
        local creature = Tile(v):getTopCreature()
        if not creature or not creature:isPlayer() or creature:getLevel() < t.level then
            doSendAnimatedText(getThingPos(cid), "Alguem não cumpre os requisitos da quest!", 55)
            doTransformItem(item.uid, item.itemid == 1945 and 1946 or 1945)
            return true
        end
        table.insert(players, creature)
    end

    for _, player in ipairs(players) do
        player:teleportTo(t.fim)
    end

    doTransformItem(item.uid, item.itemid == 1945 and 1946 or 1945)
    return true
end
