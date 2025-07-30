local firstItems = {1987}

function onLogin(player)
    if player:getLastLoginSaved() == 0 then
        player:teleportTo(Position(2276, 2700, 5)) -- Teleporta o jogador para a posição desejada
        
        for i = 1, #firstItems do
            player:addItem(firstItems[i], 1)
        end
    end
    return true
end
