-- Script Made By: Sonkis (Gabriel Lisboa)
-- Start Config --

local topos = {x=443, y=370, z=14} -- Posição para onde o player será teleportado.

-- End Config --

 

function onUse(cid)

if doTeleportThing(cid, topos) then

doPlayerSendTextMessage(cid,20,"Você Acertou E Passou Para Proxima Fase!.") -- Mude o NAME para o nome do local que o player será teleportado.

end

end