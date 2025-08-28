local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

NpcSystem.parseParameters(npcHandler)

local talkState = {}


function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end

function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end

function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end

function onThink() npcHandler:onThink() end




function creatureSayCallback(cid, type, msg)
local storageMission = 32035
local verifyMission = 32036


if(not npcHandler:isFocused(cid)) then

return false

end


 
local talkUser = NPCHANDLER_CONVbehavior == CONVERSATION_DEFAULT and 0 or cid


if getPlayerStorageValue(cid,verifyMission) == 1 then selfSay("Estou Ocupado!", cid) return true end

if(msgcontains(msg, 'task') or msgcontains(msg, 'Task'))  then
selfSay("Olá você gostaria de fazer uma task? Eu recompenso treinadores com uma outfit após finalizada!", cid)


elseif msgcontains(msg, "yes") or msgcontains(msg, "sim")  then 
selfSay("Você agora está participando da missão, mate 50 Tobi Outfit", cid)
setPlayerStorageValue(cid,storageMission,0)
setPlayerStorageValue(cid,verifyMission,1)





end






return TRUE

end


npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new())

