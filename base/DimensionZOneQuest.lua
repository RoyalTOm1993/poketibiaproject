function onStepIn(cid, item, position, fromPosition)
if not isPlayer(cid) then
return true
end

-- Verificar se o jogador tem os itens necessários
local item1 = getPlayerItemCount(cid, 13553)
local item2 = getPlayerItemCount(cid, 16278)

if item1 < 1 or item2 < 1 then
doPlayerSendCancel(cid, "Você precisa de certos itens dropados pelos pokemons deoxys e mewtwo!.")
doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
return true
end

local requiredLevel = 15000

if getPlayerLevel(cid) < requiredLevel then
doPlayerSendCancel(cid, "Você precisa ser level " .. requiredLevel .. " para entrar aqui.")
doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
return true
end

local teleportPosition = {x = 4216, y = 1631, z = 6} -- Substitua pelos valores da posição desejada

-- Remover os itens do inventário do jogador
doPlayerRemoveItem(cid, 13553, 1)
doPlayerRemoveItem(cid, 16278, 1)

doTeleportThing(cid, teleportPosition, true)
doSendMagicEffect(teleportPosition, CONST_ME_TELEPORT)
doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você foi teleportado!")

return true
end