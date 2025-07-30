function onUse(cid, item, fromPosition, itemEx, toPosition)
    local requiredItemID = 22868 -- ID do item necessário para teleportar
    local requiredStorageValue = 532126 -- Valor da storage necessária para teleportar sem o item
    local teleportPositionComItem = {
        {x = 2462, y = 2931, z = 12}
    } -- Posições para teleportar com o item
    local teleportPositionComStorage = {
       {x = 2462, y = 2931, z = 12}
    } -- Posições para teleportar com o valor da storage

    if getPlayerItemCount(cid, requiredItemID) > 0 then
        doPlayerRemoveItem(cid, requiredItemID, 1) -- Remove o item do inventário do jogador
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você usou o Monster Ticket e foi teleportado.") -- Mensagem para o jogador que usou o item
        doTeleportThing(cid, Position(1493, 2898, 12)) -- Teleporta o jogador para uma posição aleatória com o item
        return true
    elseif getPlayerStorageValue(cid, requiredStorageValue) == 1 then
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você foi teleportado.") -- Mensagem para o jogador com o valor da storage necessário
        doTeleportThing(cid, Position(1493, 2898, 12)) -- Teleporta o jogador para uma posição aleatória com o valor da storage
        return true
    else
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você não tem o Monster Ticket, mas você pode comprar o Kit Inicial Monster e ter passe livre para essa hunt!") -- Mensagem de erro
        return true
    end
end
