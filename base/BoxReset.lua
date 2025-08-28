function onUse(player, item, fromPosition, target, toPosition)
    if not player or not player:isPlayer() then
        return false
    end

    local playerId = player:getId()
    local onlinePlayers = Game.getPlayers()
    
    for _, onlinePlayer in ipairs(onlinePlayers) do
        if onlinePlayer:getId() == playerId then
            -- O jogador está online, continue com o código
            player:addItem(20652, 12)
            player:addItem(22664, 1)
            player:addItem(20708, 3)
            player:addItem(20658, 1)
            player:addItem(17313, 1)
            player:addItem(22662, 1)
            player:addItem(2145, 20)
            player:addItem(12237, 1500)
            item:remove(1)
            
            -- Mensagem global
            Game.broadcastMessage(player:getName() .. " obteve itens da reset box!", MESSAGE_STATUS_WARNING)
            return true
        end
    end

    return false
end
