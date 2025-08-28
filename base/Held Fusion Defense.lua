-- Configure a lista de fusões de "helds" aqui
local heldMerges = {
    {fromID = 16802, fromAmount = 2, toID = 22587, failureChance = 30},
    {fromID = 22587, fromAmount = 2, toID = 22588, failureChance = 34},
    {fromID = 22588, fromAmount = 2, toID = 22589, failureChance = 40},
    {fromID = 22589, fromAmount = 2, toID = 22590, failureChance = 45},
    {fromID = 22590, fromAmount = 2, toID = 22591, failureChance = 50},
    {fromID = 22591, fromAmount = 2, toID = 22592, failureChance = 55},
    {fromID = 22592, fromAmount = 2, toID = 22593, failureChance = 60},
    {fromID = 22593, fromAmount = 2, toID = 22594, failureChance = 70},
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
