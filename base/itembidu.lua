function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)  -- Cria um objeto Player com o ID do jogador
    
    -- Defina as constantes para os sexos (caso não estejam definidas em outro lugar)
    PLAYERSEX_FEMALE = 0
    PLAYERSEX_MALE = 1
    
    local COLOR_BLUE = 4
    local COLOR_RED = 180
    
    local table_mount = {
[22124] = {velocidade = 2000, female = 4373, male = 4373},
    }
    local mountInfo = table_mount[item:getId()]  -- Obtém as informações da bike usando o ID do item
    
    if not mountInfo then
        player:sendCancelMessage("Essa bike não está configurada corretamente.")
        return true
    end
    
    local busyStorageValues = {17001, 63215, 17000}
    for _, storageValue in ipairs(busyStorageValues) do
        if player:getStorageValue(storageValue) == 1 then
            player:sendCancelMessage("Você não pode usar enquanto está ocupado!")
            return true
        end
    end
    
    local playerPos = player:getPosition()
    
    local originalOutfitID = player:getStorageValue(128238)
    
    if originalOutfitID <= 0 then
        local originalOutfit = player:getOutfit()
        player:setStorageValue(128238, originalOutfit.lookType) -- Armazena o ID da outfit
        
        local outfit = player:getSex() == PLAYERSEX_MALE and mountInfo.male or mountInfo.female
        player:setOutfit({lookType = outfit, lookHead = 0, lookAddons = 0, lookLegs = 0, lookBody = 0, lookFeet = 0})
        
        local bikeText = "Bike ON"
        local textColor = COLOR_BLUE
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, bikeText)
        sendBikeMessage(playerPos, bikeText, textColor)
        playerPos:sendMagicEffect(CONST_ME_MAGIC_RED)
        
        -- Aplicar velocidade apenas se a bike estiver ativa
        local speedBoost = mountInfo.velocidade
        if speedBoost then
            local condition = Condition(CONDITION_HASTE)
            condition:setParameter(CONDITION_PARAM_SPEED, speedBoost)
            condition:setTicks(-1) -- Permanente até que a bike seja desativada
            player:addCondition(condition)
        end
        
    else
        player:setStorageValue(128238, 0)
        
        player:setOutfit({lookType = originalOutfitID, lookHead = 0, lookAddons = 0, lookLegs = 0, lookBody = 0, lookFeet = 0})
        
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Bike OFF")
        sendBikeMessage(playerPos, "Bike OFF", COLOR_RED)
        playerPos:sendMagicEffect(CONST_ME_MAGIC_GREEN)
        
        -- Remover a condição de velocidade ao desativar a bike
        player:removeCondition(CONDITION_HASTE)
    end

    return true
end

function sendBikeMessage(position, text, color)
    Game.sendAnimatedText(position, text, color)
end