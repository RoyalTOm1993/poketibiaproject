local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local storageValue = 6651 -- Valor da storage que será concedida
local mensagemPergunta = "Você só pode passar se sacrificar um dos seus amigos na quest. Deseja fazer isso? (sim/não)"
local mensagemSucesso = "Você fez a escolha correta, nunca abandone seus amigos!"
local mensagemFalha = "O teletransporte foi cancelado."
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
            player:teleportTo({x = 3099, y = 2906, z = 6})
            player:popupFYI(mensagemSucesso)
        elseif msg:lower() == "nao" then
            -- Aqui definimos o valor do storage 6651 como 1
            player:teleportTo({x = 3003, y = 2202, z = 2})
            player:popupFYI("Parabéns! Você é um bom amigo e pode passar!")
        else
            player:popupFYI(mensagemFalha)
        end
        esperaResposta[player:getId()] = nil
        return false
    end

    if msgcontains(msg, 'quest') then
        player:popupFYI(mensagemPergunta)
        esperaResposta[player:getId()] = true
        return true
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
