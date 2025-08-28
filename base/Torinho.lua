local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()		npcHandler:onThink()		end

local woodItemId = 431241 -- ID da madeira
local toolItemId = 3122 -- ID da ferramenta

function onCreatureSay(cid, type, msg)
    if (type == TALKTYPE_SAY) then
        msg = string.lower(msg)
        if (msg == "hi") then
            npcHandler.talkState[cid] = "história"
            npcHandler:say("Olá, viajante! Quer ouvir uma história interessante?", cid)
        elseif (npcHandler.talkState[cid] == "história") then
            npcHandler:say("Há muito tempo atrás, um meteorito caiu perto da minha casa. Dizem que esse meteorito é repleto de pedras lendárias, algumas até mesmo mágicas! Eu tenho uma ferramenta que permite extrair essas pedras, mas preciso de madeira para terminar minha casa. Se você me trouxer 500 madeiras, eu trocarei minha ferramenta por elas.", cid)
            npcHandler.talkState[cid] = 0
        elseif (msg == "trade") then
            npcHandler.talkState[cid] = "troca"
            npcHandler:say("Você está pronto para trocar 500 madeiras pela minha ferramenta?", cid)
        elseif (npcHandler.talkState[cid] == "troca") then
            if (msg == "yes" or msg == "sim") then
                if (getPlayerItemCount(cid, woodItemId) >= 500) then
                    doPlayerRemoveItem(cid, woodItemId, 500)
                    doPlayerAddItem(cid, toolItemId, 1)
                    npcHandler:say("Aqui está a minha ferramenta! Aproveite!", cid)
                else
                    npcHandler:say("Você não tem 500 madeiras o suficiente.", cid)
                end
            else
                npcHandler:say("Tudo bem, volte quando estiver pronto.", cid)
            end
            npcHandler.talkState[cid] = 0
        end
    end
end