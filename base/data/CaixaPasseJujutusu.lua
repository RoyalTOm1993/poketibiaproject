function onUse(player, item, fromPosition, target, toPosition)
        doAddPokeballSupreme(player, "Nue")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Voc� recebeu seu Nue")
    item:remove(1)
    return true 
end
