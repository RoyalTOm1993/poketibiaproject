function onUse(cid, item, frompos, item2, topos)
    local requiredItem = 12237 -- substitua ITEM_ID pelo ID do item necessário
    local requiredItemAmount = 1000 -- substitua QUANTIDADE pela quantidade necessária do item

    local player = Player(cid)
    local playerItem = player:getItemCount(requiredItem)
    local hasBoughtOutfit = player:getStorageValue(201066) == 1
    
    if hasBoughtOutfit then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Você já comprou a Outfit anteriormente.")
        return true
    end
    
    if player:getSex() == PLAYERSEX_MALE then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Desculpe, somente personagens femininos podem comprar esta Outfit.")
        return true
    end
    
    if playerItem >= requiredItemAmount then
        player:removeItem(requiredItem, requiredItemAmount)
        player:addOutfit(4299)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Parabéns " .. player:getName() .. "! Você habilitou uma Outfit!")
        Game.broadcastMessage("O jogador " .. player:getName() .. " acaba de habilitar uma Outfit da Black Diamond Shop!", MESSAGE_STATUS_WARNING)
        player:setStorageValue(201066, 1) -- Define a storage para indicar que o jogador comprou a outfit
    else
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Você precisa ter pelo menos " .. requiredItemAmount .. " " .. ItemType(requiredItem):getName() .. " para comprar esta caixa.")
    end
    
    return true
end
