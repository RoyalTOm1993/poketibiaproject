local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local requiredItems = {
    [22906] = 1,    -- ID do primeiro item necessário
    [23035] = 50,   -- ID do segundo item necessário
}

local storageValue = 53476 -- Valor do storage que será concedido
local mensagemPergunta = "Me Traga 50 Essescias Rosas E 1 Joia Da Alma Que Te Passo Uma Gloria Magica, Que Faz Nascer Um Zerark Fusao Entre Zoroark E Zeraora, Mais Voce Precisa Derrotalos E Tentar Capturar? (sim/não)"
local mensagemSucesso = "Aproveite!"
local mensagemFalha = "Você não possui todos os itens necessários para a troca."
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

            -- Check if the player has all required items
            for itemId, amount in pairs(requiredItems) do
                if player:getItemCount(itemId) < amount then
                    hasAllItems = false
                    break
                end
            end

            if hasAllItems then
                -- Remove required items and set storage value
                for itemId, amount in pairs(requiredItems) do
                    player:removeItem(itemId, amount)
                end
                player:setStorageValue(storageValue, 1)
                player:popupFYI(mensagemSucesso)
            else
                player:popupFYI(mensagemFalha)
            end
        else
            player:popupFYI("A troca foi cancelada.")
        end
        esperaResposta[player:getId()] = nil
        return false
    end

    if msgcontains(msg, 'sim') then
        player:popupFYI(mensagemPergunta)
        esperaResposta[player:getId()] = true
        return true
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
