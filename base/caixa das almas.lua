function onUse(player, item, fromPosition, target, toPosition)
    local randomNumber = math.random(1, 2) -- Gera um número aleatório entre 1 e 2

    if randomNumber == 1 then
        doAddPokeballFull(player, "Pikachu Modo Kurama")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você recebeu seu Pikachu Modo Kurama")
    else
        doAddPokeballFull(player, "Pikachu Modo Susanoo")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você recebeu seu Pikachu Modo Susanoo")
    end

    item:remove(1)
    return true 
end
