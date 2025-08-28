function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid)
    
    if player:getStorageValue(8721) == 1 then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Você já pegou a Outfit anteriormente.")
        return true
    end
    
    player:addOutfit(4468)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Parabéns " .. player:getName() .. "! Você habilitou uma Outfit!")
    Game.broadcastMessage("O jogador " .. player:getName() .. " acaba de completar a mega trainer e ganhou a outfit Mega Trainer!.", MESSAGE_STATUS_WARNING)
    
    player:setStorageValue(8721, 1) -- Define a storage para indicar que o jogador pegou a outfit
    
    return true
end
