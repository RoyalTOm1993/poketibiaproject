local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

local YUGI_TROCAS = {
    ["exodia"] = {
        {23464, 23463, 23459, 23458, 23457}
    },
    ["mago"] = {
        {23462}
    },
    ["dragao"] = {
        {23460}
    }
}

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
    if talkState[cid] == 1 then
        selfSay(string.format("Olá treinador, qual card você gostaria de trocar? exodia, dragao ou mago?"), cid)
        talkState[cid] = 2
        return true
    elseif talkState[cid] == 2 then
        local info = YUGI_TROCAS[msg]
        if info then
            local haveItem = true
            for _, id in pairs(info[1]) do
                if player:getItemCount(id) < 1 then
                    haveItem = false
                end
            end

            if haveItem then
                for _, id in pairs(info[1]) do
                    player:removeItem(id, 1)
                end
                local pokes = {
                    ["exodia"] = "Exodia",
                    ["dragao"] = "Dragao Branco Dos Olhos Azuis",
                    ["mago"] = "Mago do Tempo"
                }
                local pokeName = pokes[msg]
                doAddPokeball(cid, pokeName, 23456)
                talkState[cid] = nil
                selfSay("Você recebeu seu " .. pokeName, cid)
                return true
            else
                talkState[cid] = nil
                selfSay("Itens Insuficientes", cid)
                return true
            end

            talkState[cid] = nil
            return true
        end
        selfSay("Nome Inválido", cid)
		talkState[cid] = 1
		return true
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())