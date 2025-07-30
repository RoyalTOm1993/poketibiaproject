local config = {
    currencyItemId = 12237, -- ID do item usado como moeda
    pokemons = { -- lista de Pokémons lendários e seus preços em item
        ["Legendary Caterpie"] = 9500,
        ["Rayquaza Natalino"] = 10000,
        ["Black Greninja"] = 6250,
        ["Black Sky Shaymin"] = 6250,
        ["Perfect Jirachi"] = 3500,
    },
}

local dailyPokemons = {}
local discounts = {}

local function updateDailyPokemons()
    dailyPokemons = {}
    discounts = {}

    local shuffledPokemons = {}
    for k, v in pairs(config.pokemons) do
        table.insert(shuffledPokemons, k)
    end
    math.randomseed(os.time())
    
    for i = 1, 5 do
        local index = math.random(#shuffledPokemons)
        local pokemon = shuffledPokemons[index]
        local originalPrice = config.pokemons[pokemon]
        local discount = math.random(1, 20) -- Desconto aleatório de 1 a 20%
        local discountedPrice = math.floor(originalPrice * (1 - discount / 100))
        
        discounts[pokemon] = discount
        config.pokemons[pokemon] = discountedPrice
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

    local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

    if msgcontains(msg:lower(), "buy") or msgcontains(msg:lower(), "trade") then
        local str = ""
        for _, pokemon in ipairs(dailyPokemons) do
            local price = config.pokemons[pokemon]
            if str == "" then
                str = pokemon .. " - " .. price .. " Black Diamonds (" .. discounts[pokemon] .. "% de desconto)"
            else
                str = str .. "\n" .. pokemon .. " - " .. price .. " Black Diamonds (" .. discounts[pokemon] .. "% de desconto)"
            end
        end
        selfSay("Olá, treinador! O que você gostaria de comprar? Aqui está a lista de Pokémons lendários disponíveis para hoje: {yes}", cid)
        doPlayerPopupFYI(cid, "Promoção De Hoje Temos:\n" .. str)
        talkState[talkUser] = 1
        return true
    elseif msgcontains(msg:lower(), "yes") or msgcontains(msg:lower(), "sim") then
        if talkState[talkUser] == 1 then
            selfSay("Qual Pokémon você gostaria de comprar? Digite o nome exatamente como está na lista.", cid)
            talkState[talkUser] = 2
            return true
        elseif talkState[talkUser] == 3 then
            if buyPokemon ~= "" then
                local price = config.pokemons[buyPokemon]
                local playerItemCount = getPlayerItemCount(cid, config.currencyItemId)
                if playerItemCount >= price then
                    if doPlayerRemoveItem(cid, config.currencyItemId, price) then
                        local btype = "pokeball"
                        local pokeball = doAddPokeball(cid, buyPokemon)
                        if pokeball then
                            selfSay("Aqui está o seu " .. buyPokemon .. " dentro de uma Pokébola!", cid)
                            talkState[talkUser] = 0
                            return true
                        else
                            selfSay("Desculpe, houve um problema ao criar a Pokébola com o Pokémon.", cid)
                        end
                    end
                else
                    selfSay("Você não tem {" .. price .. "} " .. getItemNameById(config.currencyItemId) .. " suficientes.", cid)
                    talkState[talkUser] = 0
                    return true
                end
            end
        end
    elseif config.pokemons[msg] and talkState[talkUser] == 2 then
        local itemName = msg
        local discountedPrice = config.pokemons[itemName]
        selfSay("Você quer comprar um {" .. itemName .. "} por {" .. discountedPrice .. " Black Diamonds (" .. discounts[itemName] .. "% de desconto)}?", cid)
        buyPokemon = itemName
        talkState[talkUser] = 3
        return true
    elseif msgcontains(msg:lower(), "no") then
        selfSay("Tudo bem, volte sempre!", cid)
        talkState[talkUser] = 0
        return true
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
