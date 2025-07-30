local config = {
    storageId = 32070, -- ID da storage usada como moeda
    pokemons = { -- lista de Pokémons lendários e seus preços em storage
        ["Black Gardevoir"] = 30,
        ["Black Blastoise"] = 30,
        ["Black Scizor"] = 90,
        ["Black Vileplume"] = 90,
        ["Ultra Zygarde"] = 180,
        ["Zaytios"] = 1600,
        ["Pluss Ho-oh"] = 300,
        ["Pluss Solgaleo"] = 360,
        ["Lunala Necromante"] = 210,
        ["Pluss Yveltal"] = 210,
        ["Black Abosmanow"] = 210,
        ["Pluss Regigigas"] = 150,
        ["Pluss Giratina"] = 150,
        ["Toxic Mulk"] = 60,
        ["Green Heatran"] = 60,
        ["Magmortar Robotic"] = 30,
        ["Crobat Robotic"] = 30,
        ["Crawdaunt Robotic"] = 30,
        ["Dark Ash Greninja"] = 15,
        ["White Zeraora"] = 15,
        ["Prime Lugia"] = 15,
        ["Feraligatr Robotic"] = 15,
    },
}

local dailyPokemons = {}
local function updateDailyPokemons()
    dailyPokemons = {}
    local shuffledPokemons = {}
    for k, v in pairs(config.pokemons) do
        table.insert(shuffledPokemons, k)
    end
    math.randomseed(os.time())
    for i = 1, 7 do
        local index = math.random(#shuffledPokemons)
        local pokemon = shuffledPokemons[index]
        table.remove(shuffledPokemons, index)
        table.insert(dailyPokemons, pokemon)
    end
end

updateDailyPokemons()

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

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
    if not npcHandler:isFocused(cid) then
        return false
    end

    local talkUser = getPlayerByName(cid) -- Substitua por algo equivalente para obter o jogador pelo nome ou ID

    if msgcontains(msg:lower(), "buy") or msgcontains(msg:lower(), "trade") then
        local str = ""
        for _, pokemon in ipairs(dailyPokemons) do
            local price = config.pokemons[pokemon]
            if str == "" then
                str = pokemon.." - "..price.." Reset Points"
            else
                str = str.."\n"..pokemon.." - "..price.." Reset Points"
            end
        end
        npcHandler:say("Olá, treinador! O que você gostaria de comprar? Aqui está a lista de Pokémons lendários disponíveis para hoje: {yes}", talkUser)
        doPlayerPopupFYI(talkUser, "Promoção De Hoje Temos:\n"..str)
        talkState[talkUser] = 1
        return true
    elseif msgcontains(msg:lower(), "yes") or msgcontains(msg:lower(), "sim") then
        if talkState[talkUser] == 1 then
            npcHandler:say("Qual Pokémon você gostaria de comprar? Digite o nome exatamente como está na lista.", talkUser)
            talkState[talkUser] = 2
            return true
        elseif talkState[talkUser] == 3 then
            if buyPokemon ~= "" then
                local price = config.pokemons[buyPokemon]
                local playerStorage = getPlayerStorageValue(talkUser, config.storageId) -- Substitua pelo equivalente para obter o valor do storage do jogador
                if playerStorage >= price then
                    if setPlayerStorageValue(talkUser, config.storageId, playerStorage - price) then
					    local btype = "pokeball"
                        local pokeball = doAddPokeball(cid, buyPokemon)
                        npcHandler:say("Aqui está o seu "..buyPokemon.."!", talkUser)
                        -- Substitua por algo equivalente para adicionar o Pokémon ao jogador
                        talkState[talkUser] = 0
                        return true
                    end
                else
                    npcHandler:say("Você não tem {"..price.."} Reset Points suficientes.", talkUser)
                    talkState[talkUser] = 0
                    return true
                end
            end
        end
    elseif config.pokemons[msg] and talkState[talkUser] == 2 then
        npcHandler:say("Você quer comprar um {"..msg.."} por {"..config.pokemons[msg].." Reset Points}?", talkUser)
        buyPokemon = msg
        talkState[talkUser] = 3
        return true
    elseif msgcontains(msg:lower(), "no") then
        npcHandler:say("Tudo bem, volte sempre!", talkUser)
        talkState[talkUser] = 0
        return true
    end

    return true
end
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())