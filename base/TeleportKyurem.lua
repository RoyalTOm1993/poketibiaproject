local t = {
    level = 100,
    inicio = {
        Position(3134, 3500, 3), -- Location where the first player will be
        Position(3133, 3499, 3), -- Location where the second player will be
        Position(3132, 3500, 3), -- Location where the third player will be
        Position(3133, 3501, 3), -- Location where the fourth player will be
    },
    fim = Position(3419, 3443, 9),
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local players = {}

    for k, v in pairs(t.inicio) do
        local creature = Tile(v):getTopCreature()
        if not creature or not creature:isPlayer() or creature:getLevel() < t.level then
            player:say("Alguém não cumpre os requisitos da quest!", TALKTYPE_MONSTER_SAY)
            item:transform(item:getId() == 1945 and 1946 or 1945)
            return true
        end

        table.insert(players, creature)
    end

    for k, v in pairs(players) do
        v:teleportTo(t.fim)
    end

    item:transform(item:getId() == 1945 and 1946 or 1945)
    return true
end
