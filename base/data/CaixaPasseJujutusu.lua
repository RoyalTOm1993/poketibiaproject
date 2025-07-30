function onUse(player, item, fromPosition, target, toPosition)
        doAddPokeballSupreme(player, "Nue")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você recebeu seu Nue")
    item:remove(1)
    return true 
end
