function onUse(player, item, fromPosition, target, toPosition)
        player:addOutfit(5110)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você recebeu sua outfit do Megumi!.")

    item:remove(1)
    return true 
end
