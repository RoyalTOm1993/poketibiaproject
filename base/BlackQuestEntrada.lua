local config = {
    level = 5,
    startPositions = {
        {x = 3174, y = 2161, z = 7},
        {x = 3174, y = 2162, z = 7},
        {x = 3174, y = 2163, z = 7},
        {x = 3174, y = 2164, z = 7},
        {x = 3174, y = 2165, z = 7}
    },
    storageReward = 1 -- Quantidade de storage a ser concedida aos jogadores
}

function onUse(player, item, fromPosition, target, toPosition)
    local playersInCorrectPositions = {}
    
    for _, position in ipairs(config.startPositions) do
        local tile = Tile(position)
        local creature = tile:getTopCreature()
        
        if creature and creature:isPlayer() and creature:getLevel() >= config.level then
            table.insert(playersInCorrectPositions, creature)
        end
    end
    
    if #playersInCorrectPositions == #config.startPositions then
        for _, playerToReward in ipairs(playersInCorrectPositions) do
            playerToReward:setStorageValue(6652, playerToReward:getStorageValue(6652) + config.storageReward)
            playerToReward:sendTextMessage(MESSAGE_STATUS_SMALL, "Vocês Ganharao A Permissao Para Passar!")
        end
    else
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Esta Faltando Players!")
    end
    
    item:transform(item:getId() == 1945 and 1946 or 1945)
    return true
end
