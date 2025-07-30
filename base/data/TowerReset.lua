function onStepIn(cid, item, position, fromPosition)
    if not isPlayer(cid) then 
        return true 
    end

    local minRequiredResets = 10 -- Quantidade mínima necessária de resets
    local maxRequiredResets = 1000 -- Quantidade máxima necessária de resets
    local maxStorageValue = 1000 -- Valor máximo da storage

    local playerResets = getPlayerStorageValue(cid, 102231)

    if playerResets < minRequiredResets or playerResets > maxRequiredResets or playerResets > maxStorageValue then
        doPlayerSendCancel(cid, "Você precisa ter entre 10 e 100 resets para passar por este local.")
        doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)

        -- Move o jogador de volta à posição anterior
        doTeleportThing(cid, fromPosition)
        return false -- Impede o jogador de passar pelo tile
    end

    return true -- Permite que o jogador passe pelo tile
end
