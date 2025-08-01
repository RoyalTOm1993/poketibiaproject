local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local requiredItems = {
    [5901] = 2500,    -- ID do primeiro item necess�rio
}

local itemToGive = 7437 -- ID do item a ser dado ao jogador
local mensagemPergunta = "Ah, que bom que voc� aceitou ouvir minha hist�ria! Havia uma vez um homem que morava perto de uma grande cratera, onde um meteorito havia ca�do h� muitos anos. Eu sou esse homem! E eu possu�a uma ferramenta especial que permitia extrair pedras lend�rias do local do meteorito. No entanto, eu precisava de madeira para terminar minha casa. Estou disposto a trocar essa ferramenta por 2500 madeiras. Aceita a oferta? (sim/nao)"
local mensagemSucesso = "Aproveite!"
local mensagemFalha = "Voc� n�o possui todos os itens necess�rios para a troca."
local esperaResposta = {}

function onCreatureAppear(creature)
    npcHandler:onCreatureAppear(creature)
end

function onCreatureDisappear(creature)
    npcHandler:onCreatureDisappear(creature)
end

function onCreatureSay(creature, type, msg)
    npcHandler:onCreatureSay(creature, type, msg)
end

function onThink()
    npcHandler:onThink()
end

function creatureSayCallback(creature, type, msg)
    local player = Player(creature)
    if not player then
        return true
    end

    if esperaResposta[player:getId()] then
        if msg:lower() == "sim" then
            local hasAllItems = true

            -- Verifica se o jogador possui todos os itens necess�rios
            for itemId, amount in pairs(requiredItems) do
                if player:getItemCount(itemId) < amount then
                    hasAllItems = false
                    break
                end
            end

            if hasAllItems then
                -- Remove os itens necess�rios e d� o item ao jogador
                for itemId, amount in pairs(requiredItems) do
                    player:removeItem(itemId, amount)
                end
                player:addItem(itemToGive, 1)
                npcHandler:say(mensagemSucesso, player)
            else
                npcHandler:say(mensagemFalha, player)
            end
        else
            npcHandler:say("A troca foi cancelada.", player)
        end
        esperaResposta[player:getId()] = nil
        return false
    end

    if msgcontains(msg, 'sim') then
        npcHandler:say(mensagemPergunta, player)
        esperaResposta[player:getId()] = true
        return true
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
