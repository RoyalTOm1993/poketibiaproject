function onUse(player, item, fromPosition, itemEx, toPosition)
    local days = 2

    player:sendTextMessage(MESSAGE_INFO_DESCR, "Foram adicionados " .. days .. " dias de VIP no seu character.")
    player:addPremiumDays(2)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Voce tem " .. player:getPremiumDays() .. " dias de VIP restantes.")

    item:remove(1)
    return true
end
