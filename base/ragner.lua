local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}
function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, message)
    local player = Player(cid)
    if(not npcHandler:isFocused(cid)) then
        return false
    end

    local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

    local storage = 4851201
    if player:getStorageValue(storage) == 1 then
        selfSay("Olá " .. player:getName() .. ", Você já recebeu seu pokémon, encontre Magna para prosseguir.", player)
        return true
    end
 
    if string.find(string.lower(message), "articuno") then
        doAddPokeball(player, "Articuno")
        player:setStorageValue(storage, 1)
        selfSay("Aqui está seu pokémon, boa sorte, " .. player:getName() .. "!!", player)
        selfSay("Siga a ponte a direita indicada para chegar ao local apropriado e começar a subir de nível para o seu primeiro reset.", player)
        player:addItem(3082, 10)
        player:addItem(13562, 10)
        player:addItem(12344, 100)
        player:addItem(2392, 500)
        player:teleportTo({x = 3082, y = 2906, z = 7})
        player:setTown(1)
    elseif string.find(string.lower(message), "moltres") then
        doAddPokeball(player, "Moltres")
        player:setStorageValue(storage, 1)
        selfSay("Aqui está seu pokémon, boa sorte, " .. player:getName() .. "!!", player)
        selfSay("Siga a ponte a direita indicada para chegar ao local apropriado e começar a subir de nível para o seu primeiro reset.", player)
        player:addItem(13562, 10)
        player:addItem(12344, 100)
        player:addItem(2392, 500)
        player:addItem(3082, 10)
        player:teleportTo({x = 3082, y = 2906, z = 7})
        player:setTown(1)
    elseif string.find(string.lower(message), "zapdos") then
        doAddPokeball(player, "Zapdos")
        player:setStorageValue(storage, 1)
        selfSay("Aqui está seu pokémon, boa sorte, " .. player:getName() .. "!!", player)
        selfSay("Siga a ponte a direita indicada para chegar ao local apropriado e começar a subir de nível para o seu primeiro reset.", player)
        player:addItem(13562, 10)
        player:addItem(12344, 100)
        player:addItem(2392, 500)
        player:addItem(3082, 10)
        player:teleportTo({x = 3082, y = 2906, z = 7})
        player:setTown(1)
    end

    return true
end

local function creatureGreetCallback(cid, message)
local player = Player(cid)


local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid


return true
end


npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, creatureGreetCallback)

npcHandler:addModule(FocusModule:new())             