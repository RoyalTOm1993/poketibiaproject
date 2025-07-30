function onUse(player, item, fromPosition, target, toPosition)

    doAddPokeball(player, "Hooxray")
    item:remove(1)
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você recebeu seu Hooxray")
    return true 
end