-- Script Made By: Sonkis (Gabriel Lisboa)
-- Start Config --

local topos = Position(3483, 3610, 8) -- Posi��o para onde o player ser� teleportado.

-- End Config --

function onUse(player)
    if player:teleportTo(topos) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� Acertou E Passou Para a Pr�xima Fase!") -- Mude a mensagem conforme necess�rio.
    end
end
