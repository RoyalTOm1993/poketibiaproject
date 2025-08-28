-- Script Made By: Sonkis (Gabriel Lisboa)
-- Start Config --

local topos = Position(1008, 2368, 4) -- Posição para onde o player será teleportado.

-- End Config --

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid) -- Create a Player object

    if player:teleportTo(topos) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você Acertou E Passou Para Próxima Fase!") -- Mude o NAME para o nome do local que o player será teleportado.
    end

    return true
end
