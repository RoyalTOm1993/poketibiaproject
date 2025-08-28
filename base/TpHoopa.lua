local config = {
    level = 45000,               -- Nível mínimo necessário
    requiredStorage = 102231,    -- ID da storage necessária
    startPositions = {
        {x = 3396, y = 2664, z = 8},  -- Posições iniciais dos jogadores
        {x = 3393, y = 2667, z = 8},
        {x = 3399, y = 2667, z = 8},
    },
    endPosition = {x = 3296, y = 3085, z = 8}  -- Posição final para onde os jogadores serão teletransportados
}

function onUse(player, item, fromPosition, target, toPosition)
    local players = {}
    
    for _, position in pairs(config.startPositions) do
        local tile = Tile(position)
        local creature = tile:getTopCreature()
        
        if not creature or not creature:isPlayer() or creature:getLevel() < config.level then
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "Alguém não cumpre os requisitos da quest!")
            return true
        end

        -- Verifica se o jogador tem a storage requerida
        if player:getStorageValue(config.requiredStorage) < 50 then
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "Você não tem a storage necessária!")
            return true
        end
        
        table.insert(players, creature)
    end
    
    for _, playerToTeleport in pairs(players) do
        playerToTeleport:teleportTo(config.endPosition)
    end
    
    return true
end