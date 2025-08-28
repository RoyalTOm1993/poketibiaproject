local config = {
    level = 20000,
    startPositions = {
        {x = 3924, y = 2176, z = 0}, -- Lugar onde o primeiro jogador vai estar
        {x = 4019, y = 2205, z = 0}, -- Lugar onde o segundo jogador vai estar
        {x = 4039, y = 2149, z = 0}, -- Lugar onde o terceiro jogador vai estar
        {x = 4158, y = 2148, z = 0}, -- Lugar onde o quarto jogador vai estar
        {x = 4154, y = 2207, z = 0}, -- Lugar onde o quinto jogador vai estar
        {x = 4240, y = 2222, z = 0}, -- Lugar onde o sexto jogador vai estar
        {x = 4281, y = 2186, z = 0}  -- Lugar onde o sétimo jogador vai estar
    },
    endPosition = {x = 3925, y = 2203, z = 5}
}

function onUse(player, item, fromPosition, target, toPosition)
    local players = {}
    
    for _, position in pairs(config.startPositions) do
        local tile = Tile(position)
        local creature = tile:getTopCreature()
        
        if not creature or not creature:isPlayer() or creature:getLevel() < config.level then
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "Alguém não cumpre os requisitos da quest!")
            item:transform(item:getId() == 1945 and 1946 or 1945)
            return true
        end
        
        table.insert(players, creature)
    end
    
    for _, playerToTeleport in pairs(players) do
        playerToTeleport:teleportTo(config.endPosition)
    end
    
    item:transform(item:getId() == 1945 and 1946 or 1945)
    return true
end
