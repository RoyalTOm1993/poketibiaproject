function onUse(cid, item, fromPosition, itemEx, toPosition)
    -- Verifica se o jogador possui o item necessário para invocar os pokémons
    if getPlayerItemCount(cid, 21037) < 1 then
        doPlayerSendCancel(cid, "Você precisa ter o item correto para invocar estes pokémons.")
        return true
    end

    -- Lista de monstros e coordenadas permanece a mesma

    local monsters = {
        "Dragao Branco Dos Olhos Azuis",
        "Mago Do Tempo",
        -- Adicione mais nomes de monstros conforme necessário
    }

    local coordinates = {
        {x = 3193, y = 3683, z = 10},
        {x = 3173, y = 3683, z = 10},
        {x = 3185, y = 3671, z = 10},
        {x = 3184, y = 3696, z = 10},
        {x = 3177, y = 3674, z = 9},
        {x = 3190, y = 3679, z = 9},
        {x = 3185, y = 3685, z = 9},
        {x = 3178, y = 3692, z = 9},
        {x = 3195, y = 3688, z = 9},
        {x = 3172, y = 3672, z = 8},
        {x = 3186, y = 3672, z = 8},
        {x = 3176, y = 3683, z = 8},
        {x = 3190, y = 3684, z = 8},
        {x = 3186, y = 3691, z = 8},
        {x = 3174, y = 3691, z = 8},
        {x = 3172, y = 3672, z = 7},
        {x = 3180, y = 3680, z = 7},
        {x = 3174, y = 3684, z = 7},
        {x = 3194, y = 3686, z = 7},
        {x = 3197, y = 3672, z = 7},
        {x = 3173, y = 3696, z = 7},
        {x = 3173, y = 3696, z = 7},
        {x = 3193, y = 3676, z = 6},
        {x = 3183, y = 3675, z = 6},
        {x = 3178, y = 3680, z = 6},
        {x = 3183, y = 3684, z = 6},
    }

    local minMonsters = 1
    local maxMonsters = 1

    -- Obtém o nome do jogador que invocou os monstros
    local playerName = getPlayerName(cid)

    -- Itera sobre todas as coordenadas e invoca monstros nelas
    for _, coord in ipairs(coordinates) do
        local monsterCount = math.random(minMonsters, maxMonsters)
        for i = 1, monsterCount do
            local monsterName = monsters[math.random(1, #monsters)]
            Game.createMonster(monsterName, coord)
        end
    end

    -- Anuncia o nome do jogador que invocou os monstros
    Game.broadcastMessage(playerName .. " invocou alguns monstros na torre pvp!")

    -- Remova 1 item do jogador após invocar os pokémons
    doPlayerRemoveItem(cid, 21037, 1)

    return true
end