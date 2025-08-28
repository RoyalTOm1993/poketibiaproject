-- Configure a lista de fusões de "helds" aqui
local heldMerges = {
    {fromID = 16803, fromAmount = 2, toID = 22603, failureChance = 30},
    {fromID = 22603, fromAmount = 2, toID = 22604, failureChance = 35},
    {fromID = 22604, fromAmount = 2, toID = 22605, failureChance = 40},
    {fromID = 22605, fromAmount = 2, toID = 22606, failureChance = 45},
    {fromID = 22606, fromAmount = 2, toID = 22607, failureChance = 50},
    {fromID = 22607, fromAmount = 2, toID = 22608, failureChance = 55},
    {fromID = 22608, fromAmount = 2, toID = 22609, failureChance = 60},
    {fromID = 22609, fromAmount = 2, toID = 22610, failureChance = 70},
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    
    if not player then
        return false
    end
    
    for _, merge in ipairs(heldMerges) do
        local fromID = merge.fromID
        local fromAmount = merge.fromAmount
        local toID = merge.toID
        local failureChance = merge.failureChance
        
        local itemCount = player:getItemCount(fromID)
        
        if itemCount >= fromAmount then
            local pairsToFusion = math.floor(itemCount / fromAmount)
            local totalItemsToRemove = pairsToFusion * fromAmount
            
            if player:removeItem(fromID, totalItemsToRemove) then
                local success = true
                for i = 1, pairsToFusion do
                    if math.random(1000) <= failureChance then
                        success = false
                        break
                    end
                end
                
                local fromItemName = ItemType(fromID):getName()
                local toItemName = ItemType(toID):getName()
                
                if success then
                    player:addItem(toID, pairsToFusion)
                    player:sendTextMessage(MESSAGE_INFO_DESCR, "Você fundiu " .. pairsToFusion .. " pares de " .. fromItemName .. " e obteve " .. pairsToFusion .. " " .. toItemName .. "!")
                    Game.broadcastMessage(player:getName() .. " acabou de forjar " .. pairsToFusion .. "x " .. toItemName .. " usando " .. totalItemsToRemove .. "x " .. fromItemName .. "!", MESSAGE_EVENT_ADVANCE)

                else
                    player:sendTextMessage(MESSAGE_STATUS_WARNING, "A fusão de " .. pairsToFusion .. " pares de " .. fromItemName .. " para " .. toItemName .. " falhou!")
                end
                
                return true -- Sair do loop assim que a primeira fusão for tentada
            else
                player:sendTextMessage(MESSAGE_STATUS_WARNING, "Algo deu errado ao remover os itens. Verifique se você tem a quantidade correta de " .. fromItemName .. ".")
                return true -- Sair do loop em caso de erro
            end
        end
    end
    
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "Você não tem itens suficientes para fundir.")
    return true
end
