function onUse(cid, item, fromPosition, itemEx, toPosition)
    local itemID = 8978 -- Substitua pelo ID do item que você deseja verificar
    local requiredAmount = 1 -- Substitua pela quantidade requerida do item

    if (getPlayerItemCount(cid, itemID) >= requiredAmount) then
        local teleportPosition = {x = 3029, y = 2187, z = 5} -- Substitua pela posição de teleport desejada
        doTeleportThing(cid, teleportPosition)
        doSendMagicEffect(toPosition, CONST_ME_TELEPORT)
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você foi teleportado!")
		        doPlayerRemoveItem(cid, itemID, requiredAmount)
    else
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você não tem o item necessário para ser teleportado.")
    end

    return true
end
