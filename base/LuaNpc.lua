local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function onCreatureAppear(cid)
    npcHandler:onCreatureAppear(cid)
end

function onCreatureDisappear(cid)
    npcHandler:onCreatureDisappear(cid)
end

function onCreatureSay(cid, type, msg)
    npcHandler:onCreatureSay(cid, type, msg)
end

function onThink()
    npcHandler:onThink()
end

function creatureSayCallback(cid, type, msg)
    local player = Player(cid)
    if not npcHandler:isFocused(cid) then
        return false
    end
    if not talkState[cid] then
        talkState[cid] = 1
    end

    local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid
    if (string.find(string.lower(msg), "yes") or string.find(string.lower(msg), "sim")) and talkState[cid] == 1 then
        if not isTournamentRegistrationTime() then
            selfSay(string.format("No momento o torneio não está aceitando registros, volte em: %dh:%dmin:%ds",timeUntilTournamentStart()), cid)
            talkState[cid] = nil
            return true
        else
            selfSay("Você deseja fazer o registro?", cid)
            talkState[cid] = 2
            return true
        end
    elseif (string.find(string.lower(msg), "yes") or string.find(string.lower(msg), "sim")) and talkState[cid] == 2 then
        selfSay("Inscrição realizada, você agora deve aguardar o inicio do torneio.", cid)
        player:sendPlayerToWaitingZone()
		talkState[cid] = nil
		return true
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())