function onStepIn(cid, item, position, fromPosition)
if not isPlayer(cid) then return true end
level = 15000
if getPlayerLevel(cid) < level then
doTeleportThing(cid, fromPosition, true)
doSendMagicEffect(getThingPos(cid), CONST_ME_MAGIC_RED)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Voce precisa ser Level 20K Para Upar Aqui!")
end
return TRUE
end