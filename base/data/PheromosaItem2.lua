-- Start Config --

local topos = {x=915, y=2268, z=9} -- Posição para onde o player será teleportado.

-- End Config --

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getPosition():isInRange(topos, 1, 1) then
        return false -- O jogador já está próximo da posição de destino, não é necessário teletransportar novamente.
    end

    player:teleportTo(topos)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você Acertou E Passou Para Proxima Fase!") -- Mude o NAME para o nome do local que o player será teleportado.
    return true
end
