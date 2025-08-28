------------------- By Notle -------------------
local keywordHandler = KeywordHandler:new()  
local waitingForConfirmation = {} -- Tabela para armazenar jogadores esperando confirmação                
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- Define a ID da storage e o item necessário para a troca
local storageID = 102231 -- ID da storage
local requiredAmount = 100 -- Quantidade necessária na storage
local itemToGiveID = 22644 -- ID do item que será dado após a troca

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
    
    if msgcontains(msg, 'laele') then
        waitingForConfirmation[cid] = true
        npcHandler:say("Você deseja trocar 100 resets por 1 ovo de Magikarp? (sim/nao)", cid)
    elseif waitingForConfirmation[cid] then
        if msgcontains(msg, 'sim') then
            local playerResets = player:getStorageValue(storageID)
            
            if playerResets >= requiredAmount then
                player:setStorageValue(storageID, playerResets - requiredAmount)
                player:addItem(itemToGiveID, 1)
                npcHandler:say("Você trocou 100 resets por 1 ovo de Magikarp. Aproveite!", cid)
            else
                npcHandler:say("Você não tem 100 resets suficientes para a troca.", cid)
            end
        elseif msgcontains(msg, 'nao') then
            npcHandler:say("Tudo bem, você não fez a troca.", cid)
        else
            npcHandler:say("Por favor, responda 'Sim' ou 'Não'.", cid)
        end
        waitingForConfirmation[cid] = nil
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
------------------- By Notle -------------------
