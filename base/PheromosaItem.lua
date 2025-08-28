-- Script Made By: Sonkis (Gabriel Lisboa)
-- Start Config --

local topos = {x=847, y=2302, z=9} -- Posição para onde o player será teleportado.

-- End Config --

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local playerPos = player:getPosition()

    -- Verifica se o jogador já está próximo da posição de destino.
    if playerPos.x == topos.x and playerPos.y == topos.y and playerPos.z == topos.z then
        return false -- O jogador já está na posição de destino, não é necessário teletransportar novamente.
    end

    player:teleportTo(topos)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você Acertou E Passou Para Proxima Fase!") -- Mude o NAME para o nome do local que o player será teleportado.
    return true
end
