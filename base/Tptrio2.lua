-- Script Made By: Sonkis (Gabriel Lisboa)
-- Start Config --

local topos = Position(1008, 2368, 4) -- Posi��o para onde o player ser� teleportado.

-- End Config --

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid) -- Create a Player object

    if player:teleportTo(topos) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� Acertou E Passou Para Pr�xima Fase!") -- Mude o NAME para o nome do local que o player ser� teleportado.
    end

    return true
end
