function onUse(cid, item, fromPosition, itemEx, toPosition)
    local requiredItemID = 22868 -- ID do item necess�rio para teleportar
    local requiredStorageValue = 532126 -- Valor da storage necess�ria para teleportar sem o item
    local teleportPositionComItem = {
        {x = 2462, y = 2931, z = 12}
    } -- Posi��es para teleportar com o item
    local teleportPositionComStorage = {
       {x = 2462, y = 2931, z = 12}
    } -- Posi��es para teleportar com o valor da storage

    if getPlayerItemCount(cid, requiredItemID) > 0 then
        doPlayerRemoveItem(cid, requiredItemID, 1) -- Remove o item do invent�rio do jogador
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc� usou o Monster Ticket e foi teleportado.") -- Mensagem para o jogador que usou o item
        doTeleportThing(cid, Position(1493, 2898, 12)) -- Teleporta o jogador para uma posi��o aleat�ria com o item
        return true
    elseif getPlayerStorageValue(cid, requiredStorageValue) == 1 then
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc� foi teleportado.") -- Mensagem para o jogador com o valor da storage necess�rio
        doTeleportThing(cid, Position(1493, 2898, 12)) -- Teleporta o jogador para uma posi��o aleat�ria com o valor da storage
        return true
    else
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc� n�o tem o Monster Ticket, mas voc� pode comprar o Kit Inicial Monster e ter passe livre para essa hunt!") -- Mensagem de erro
        return true
    end
end
