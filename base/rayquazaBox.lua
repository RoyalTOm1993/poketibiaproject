function onUse(player, item, fromPosition, target, toPosition)

    doAddPokeball(player, "Rayquaza Do Tormenta")
    item:remove(1)
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você recebeu seu Rayquaza Do Tormenta")
    return true 
end