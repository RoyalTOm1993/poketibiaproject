local config = {
    level = 45000,               -- N�vel m�nimo necess�rio
    requiredStorage = 102231,    -- ID da storage necess�ria
    startPositions = {
        {x = 2647, y = 2460, z = 8},  -- Posi��es iniciais dos jogadores
        {x = 2658, y = 2461, z = 8},
        {x = 2656, y = 2466, z = 8},
    },
    endPosition = {x = 3006, y = 2180, z = 4}  -- Posi��o final para onde os jogadores ser�o teletransportados
}

function onUse(player, item, fromPosition, target, toPosition)
    local players = {}
    
    for _, position in pairs(config.startPositions) do
        local tile = Tile(position)
        local creature = tile:getTopCreature()
        
        if not creature or not creature:isPlayer() or creature:getLevel() < config.level then
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "Algu�m n�o cumpre os requisitos da quest!")
            return true
        end

        -- Verifica se o jogador tem a storage requerida
        if player:getStorageValue(config.requiredStorage) < 20 then
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "Voc� n�o tem a storage necess�ria!")
            return true
        end
        
        table.insert(players, creature)
    end
    
    for _, playerToTeleport in pairs(players) do
        playerToTeleport:teleportTo(config.endPosition)
    end
    
    return true
end