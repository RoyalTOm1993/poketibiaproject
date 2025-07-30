-- Script Made By: Sonkis (Gabriel Lisboa)
-- Start Config --

local topos = Position(915, 2268, 9) -- Position for where the player will be teleported.

-- End Config --

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:teleportTo(topos) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você Acertou E Passou Para Próxima Fase!") -- Replace the text as needed.
    end
    return true
end
