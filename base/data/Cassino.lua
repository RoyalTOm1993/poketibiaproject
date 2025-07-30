function onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)
    local destination = {x = 3625, y = 3904, z = 7} -- As coordenadas para onde você quer teleportar o jogador
    if isPlayer(cid) then -- Verifica se o que entrou é um jogador
        doTeleportThing(cid, destination) -- Teleporta o jogador para a coordenada especificada
        doSendMagicEffect(destination, CONST_ME_TELEPORT) -- Efeito de teleport para o jogador
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você foi teleportado para uma nova área!") -- Mensagem para o jogador
    end
    return true
end
