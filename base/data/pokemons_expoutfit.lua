function onKill(creature, target)
    local player = Player(creature)
    if not player then
        return true
    end
    
    if player:getStorageValue(868689) ~= '{"eventId":0,"mapId":0,"prizeRoomId":0,"state":0,"diff":0,"team":"","revives":0,"roomId":0,"potions":0}' then
        return true
    end
    
    if player:getStorageValue(32050) == -1 then 
        player:setStorageValue(32050, 1)
    end
    
    local targetName = target:getName()
    local killCount = player:getKillCount(targetName)
    
    if targetName == player:getStorageValue(241201) and player:getStorageValue(239939) <= killCount then
        player:setStorageValue(239939, player:getStorageValue(239939) + 1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você matou um " .. targetName .. "! Contagem: " .. player:getStorageValue(239939) .. "/" .. killCount)
    end
    
    -- TASK OUTFIT 01 --
    if targetName == "Jocker Outfit" and player:getStorageValue(32033) < 50 then
        player:setStorageValue(32033, player:getStorageValue(32033) + 1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você matou um " .. targetName .. "! Contagem: " .. player:getStorageValue(32033) .. "/50")
    end
    
    -- Continue para as outras tasks de outfit...
    
    -- TASK OUTFIT 11 --
    if targetName == "Boneco Sasori Outfit" and player:getStorageValue(32053) < 50 then
        player:setStorageValue(32053, player:getStorageValue(32053) + 1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você matou um " .. targetName .. "! Contagem: " .. player:getStorageValue(32053) .. "/50")
    end 
    
    if targetName == "Boss Dragon" then
        player:setStorageValue(32050, player:getStorageValue(32050) + 5)
        Game.broadcastMessage("World Boss: " .. targetName .. " matou o Boss!!!!", MESSAGE_EVENT_ADVANCE)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você possui " .. player:getStorageValue(32050) .. " pontos")
    end
    
    if targetName == "Boss Pascoa" then
        if player:getStorageValue(32081) == -1 then 
            player:setStorageValue(32081, 0)
        end
        player:setStorageValue(32081, player:getStorageValue(32081) + 1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você matou o Boss, você ganhou pontos e agora possui: " .. player:getStorageValue(32081) .. " pontos")
    end
    
    if targetName == "Wave Dragon" then
        player:setStorageValue(32050, player:getStorageValue(32050) + 1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você matou um wave dragon!")
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você possui " .. player:getStorageValue(32050) .. " pontos")
    end
    
    return true
end
