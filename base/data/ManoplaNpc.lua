local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local requiredItems = {
    [23496] = 100,    -- ID do primeiro item necessário
}

local targetPosition = {x = 1503, y = 2405, z = 8} -- Posição para onde o jogador será teleportado
local mensagemPergunta = "Eu estava vasculhando o esgoto quando encontrei esta entrada misteriosa. Estou disposto a deixar você passar, mas isso vai te custar 100 moedas resets. Aceita a oferta? (sim/nao)"
local mensagemSucesso = "Prepare-se para a aventura!"
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

            -- Verifica se o jogador possui todos os itens necessários
            for itemId, amount in pairs(requiredItems) do
                if player:getItemCount(itemId) < amount then
                    hasAllItems = false
                    break
                end
            end

            if hasAllItems then
                -- Teleporta o jogador para a posição alvo
                player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
                player:teleportTo(targetPosition)
                
                -- Remove os itens necessários do jogador
                for itemId, amount in pairs(requiredItems) do
                    player:removeItem(itemId, amount)
                end
                
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
