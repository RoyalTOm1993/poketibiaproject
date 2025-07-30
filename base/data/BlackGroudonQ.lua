local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local trocaItemId = 14435 -- ID do item que será trocado
local quantidadeTroca = 5000 -- Quantidade do item que será trocado
local storageValue = 98752 -- Valor do storage que será concedido
local mensagemPergunta = "Deseja Trocar " .. quantidadeTroca .. " Black Stones Para Poder Entrar Na Black Groudon? (sim/não)"
local mensagemSucesso = "Você Trocou " .. quantidadeTroca .. " Black Stones Pelo Acesso A Black Groudon!"
local mensagemFalha = "Você Não Possui A Quantidade Necessária Do Black Stones."
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
            local requiredItemId = trocaItemId
            local requiredItemAmount = quantidadeTroca

            local itemCount = player:getItemCount(requiredItemId)
            if itemCount >= requiredItemAmount then
                player:removeItem(requiredItemId, requiredItemAmount)
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

    if msgcontains(msg, 'trocaitem') then
        player:popupFYI(mensagemPergunta)
        esperaResposta[player:getId()] = true
        return true
    end

    return true
end


npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
