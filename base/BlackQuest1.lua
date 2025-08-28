local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local trocaItemId = 14435 -- ID do item que será trocado

-- Crie uma lista de itens necessários e suas quantidades
local itensNecessarios = {
    {itemID = trocaItemId, quantidade = 10000}, -- ID e quantidade do primeiro item necessário
    {itemID = 14434, quantidade = 10000}, -- ID e quantidade do segundo item necessário
    {itemID = 14434, quantidade = 10000} -- ID e quantidade do terceiro item necessário
}

local mensagemPergunta = "Deseja Trocar " .. itensNecessarios[1].quantidade .. " Black Stones, " .. itensNecessarios[2].quantidade .. " Mega Stones e " .. itensNecessarios[3].quantidade .. " Cells Stones Para Poder Entrar Na Black Groudon? (sim/não)"
local mensagemSucesso = "Você Trocou " .. itensNecessarios[1].quantidade .. " Black Stones, " .. itensNecessarios[2].quantidade .. " Mega Stones e " .. itensNecessarios[3].quantidade .. " Cells Stones e foi Teleportado para a Black Groudon!"
local mensagemFalha = "Você Não Possui A Quantidade Necessária Dos Itens."
local esperaResposta = {}

-- Defina as coordenadas do destino do teleport
local teleportDestination = {x = 3131, y = 2200, z = 5} -- Substitua com as coordenadas reais do destino


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
            local hasRequiredItems = true

            for _, item in ipairs(itensNecessarios) do
                local itemCount = player:getItemCount(item.itemID)
                if itemCount < item.quantidade then
                    hasRequiredItems = false
                    break
                end
            end

            if hasRequiredItems then
                for _, item in ipairs(itensNecessarios) do
                    player:removeItem(item.itemID, item.quantidade) -- Remove todas as quantidades necessárias dos itens
                end
                player:teleportTo(teleportDestination) -- Teleporta o jogador para o destino
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
        local hasAllRequiredItems = true

        for _, item in ipairs(itensNecessarios) do
            local itemCount = player:getItemCount(item.itemID)
            if itemCount < item.quantidade then
                hasAllRequiredItems = false
                break
            end
        end

        if hasAllRequiredItems then
            player:popupFYI(mensagemPergunta)
            esperaResposta[player:getId()] = true
        else
            player:popupFYI(mensagemFalha)
        end

        return true
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())