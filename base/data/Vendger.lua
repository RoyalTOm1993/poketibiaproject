local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local requiredItems = {
    [21255] = 1,    -- ID do primeiro item necessário
    [21256] = 1,   -- ID do segundo item necessário
    [21257] = 1,     -- ID do terceiro item necessário
    [21258] = 1,     -- ID do terceiro item necessário
    [21259] = 1,     -- ID do terceiro item necessário
    [21260] = 1,     -- ID do terceiro item necessário
    [21261] = 1,     -- ID do terceiro item necessário
    [21262] = 1,     -- ID do terceiro item necessário
    [21263] = 1,     -- ID do terceiro item necessário
    [21264] = 1,     -- ID do terceiro item necessário
    [21265] = 1,     -- ID do terceiro item necessário
    [21266] = 1,     -- ID do terceiro item necessário
    [21267] = 1     -- ID do quarto item necessário
}

local storageValue = 87412 -- Valor do storage que será concedido
local mensagemPergunta = "Estou atrás de todas as plates deste continente. Posso trocá-las com você por 1 passagem para o meu pequeno castelo. Aceita? (sim/não)"
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
