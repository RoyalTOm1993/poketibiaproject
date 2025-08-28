function onStepIn(player, item, position, fromPosition)
    local locations = {
        {x = 3093, y = 2907, z = 13}, -- Adicione mais coordenadas conforme necessário
    }

    local randomLocation = locations[math.random(#locations)]

    player:teleportTo(randomLocation)
    return true
end
