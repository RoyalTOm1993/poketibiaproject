function onUse(cid, item, fromPosition, itemEx, toPosition)
    local itemToRemove = 13561 -- ID do item a ser removido
    local itemToAdd = 13562 -- ID do item a ser adicionado

    local player = Player(cid)
    local playerItemCount = player:getItemCount(itemToRemove)
    local amountToAdd = math.floor(playerItemCount / 10) -- Quantidade de itemToAdd a ser adicionada (calculada a partir do itemToRemove)
    local amountToRemove = amountToAdd * 10 -- Quantidade de itemToRemove a ser removida

    if amountToAdd > 0 then
        if player:removeItem(itemToRemove, amountToRemove) then
            player:addItem(itemToAdd, amountToAdd)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você forjou " .. amountToAdd .. "x " .. ItemType(itemToAdd):getName() .. "!")
            Game.broadcastMessage(player:getName() .. " acabou de forjar " .. amountToAdd .. "x " .. ItemType(itemToAdd):getName() .. " usando " .. amountToRemove .. "x " .. ItemType(itemToRemove):getName() .. "!", MESSAGE_EVENT_ADVANCE)
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você não tem itens suficientes para forjar.")
        end
    else
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você não tem itens suficientes para forjar.")
    end

    return true
end
