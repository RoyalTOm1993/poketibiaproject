function onStepIn(creature, item, position, fromPosition)
    if not creature:isPlayer() then
        return true
    end

    local player = Player(creature)
    if not player then
        return true
    end

    if player:getStorageValue(87412) == 1 then
        -- Teleportar o jogador para a posição desejada
        player:teleportTo(Position(196, 1455, 4))  -- Substitua x, y, z pelas coordenadas do destino

        -- Remover a storage após o teletransporte
        player:setStorageValue(87412, -1)
    end

    return true
end
