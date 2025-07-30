local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end
function onCreatureSay(cid, type, msg)        npcHandler:onCreatureSay(cid, type, msg)        end
function onThink()        npcHandler:onThink()        end

local voices = { {text = 'Procuro treinadores capazes de realizar tarefas!'} }
npcHandler:addModule(VoiceModule:new(voices))

-- getNpcCid() npcHandler.topic[cid] = 0
local function creatureGreetCallback(cid, message)
    local player = Player(cid)
    local dialog = "Olá, treinador! Estou em busca de treinadores capazes de realizar tarefas! Você aceita?"
    local buttons = {
        {
            type = "Text",
            text = "<color=#008000>Sim, aceito a tarefa.<color/>",
            response = "afirmativo"
        },
        {
            type = "Text",
            text = "<color=#c70000>Não, obrigado.<color/>",
            response = "negativo"
        },
    }
    doSendCallForNpc(getNpcCid(), player, START_CONVERSATION, COLORS.white, nil, dialog, buttons, closeTime)
    npcHandler.topic[cid] = 0
    return false
end


local function creatureSayCallback(cid, type, msg)
    local player = Player(cid)
    local playerTopic = npcHandler.topic[cid]

    local function confirm()
        local dialog = "Ótimo! Vou te passar a tarefa."
        local buttons = {
            {
                type = "Text",
                text = "<color=#008000>Continuar<color/>",
                response = "continuar"
            },
        }
        doSendCallForNpc(getNpcCid(), player, CONVERSATION, COLORS.white, nil, dialog, buttons, closeTime)
        npcHandler.topic[cid] = 1
    end

    local function cancel()
        local dialog = "Que pena! Se mudar de ideia, estarei por aqui."
        doSendCallForNpc(getNpcCid(), player, CONVERSATION, COLORS.white, nil, dialog, nil, 2)
        npcHandler.topic[cid] = 1
    end

    local actions = {
        ["afirmativo"] = {func = confirm, topic = 0},
        ["negativo"] = {func = cancel, topic = 0},
    }

    if actions[msg] and actions[msg].topic == playerTopic then
        actions[msg].func()
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, creatureGreetCallback)
npcHandler:addModule(FocusModule:new())