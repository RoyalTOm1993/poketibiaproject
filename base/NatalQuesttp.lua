-- Script Made By: Sonkis (Gabriel Lisboa)
-- Start Config --

local topos = Position(3483, 3610, 8) -- Posição para onde o player será teleportado.

-- End Config --

function onUse(player)
    if player:teleportTo(topos) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você Acertou E Passou Para a Próxima Fase!") -- Mude a mensagem conforme necessário.
    end
end
