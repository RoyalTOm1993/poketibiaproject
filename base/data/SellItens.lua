local config, sellItem = {
    diamondId = 12237,
    items = {
        ["Kit Boost Stone"] = 500,
        ["Vip 30 Days"] = 1000,
        ["Scroll 300"] = 100,
        ["Scroll 500"] = 200,
        ["Experience Booster 50%"] = 50,
        ["Experience Booster 80%"] = 75,
        ["Experience Booster 100%"] = 100,
        ["Infernal Stone"] = 250,
        ["Ice Stone"] = 250,
        ["Ancient Stone"] = 350,
        ["Star Stone"] = 400,
        ["Legendary Stone"] = 550
    },
}, ""

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
player = Player(cid)
    if not npcHandler:isFocused(cid) then
        return false
    end

    local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

    if msgcontains(msg:lower(), "sell") or msgcontains(msg:lower(), "trade") then
        local str = ""
        for item, price in pairs(config.items) do
            local count = getPlayerItemCount(cid, getItemIdByName(item))
            local quantity = ""
            if item == "Black Stone" or item == "Shiny Stone" or item == "Mega Stone" or item == "Cell Stone" then
                quantity = " (x1)"
            elseif item == "Scroll 500" then
                quantity = " (x1)"
            end
            if str == "" then
                str = item .. quantity .. " - " .. price .. " Black Diamonds"
            else
                str = str .. "\n" .. item .. quantity .. " - " .. price .. " Black Diamonds"
            end
        end

        selfSay("Você deseja vender algo da lista? {yes}", cid)
        doPlayerPopupFYI(cid, "Compramos:\n" .. str)
        talkState[talkUser] = 1
        return true

    elseif msgcontains(msg:lower(), "yes") or msgcontains(msg:lower(), "sim") then
        if talkState[talkUser] == 1 then
            selfSay("Qual item você deseja vender? Digite o nome do item, exatamente como está na lista.", cid)
            talkState[talkUser] = 2
            return true

        elseif talkState[talkUser] == 3 then
            if sellItem ~= "" then
                local price = config.items[sellItem]
                local countItems = getPlayerItemCount(cid, getItemIdByName(sellItem)) -- Verificar quantos itens o jogador possui

                if countItems == 0 then -- Verificar se o jogador possui o item
                    selfSay("Você não possui nenhum item {" .. sellItem .. "}.", cid)
                    talkState[talkUser] = 0
                    return true
                end

                local totalPrice = countItems * price -- Calcular o preço total

                selfSay("Você tem {" .. countItems .. "} {" .. sellItem .. "}. Deseja vender tudo por {" .. totalPrice .. " Black Diamonds}? {yes} {no}", cid)
                talkState[talkUser] = 4
                return true
            end

        elseif talkState[talkUser] == 5 then
            if msgcontains(msg:lower(), "yes") or msgcontains(msg:lower(), "sim") then
                local price = config.items[sellItem]
                local countItems = getPlayerItemCount(cid, getItemIdByName(sellItem)) -- Verificar quantos itens o jogador possui
                local totalPrice = countItems * price -- Calcular o preço total

                if doPlayerRemoveItem(cid, getItemIdByName(sellItem), countItems) then -- Remover os itens do jogador
                    doPlayerAddItem(cid, config.diamondId, totalPrice) -- Adicionar as moedas ao jogador
					local file = io.open("data/logs/logitems.log", "a+")
					file:write("\n"..player:getName().." vendeu: "..countItems.."x "..getItemIdByName(sellItem).." "..os.date("Dia: %d Mês: %b Ano: %Y Hora: %X").." ")
					file:close()
                    selfSay("Você vendeu {" .. countItems .. "} {" .. sellItem .. "} por {" .. totalPrice .. "} Black Diamonds.", cid)
                    talkState[talkUser] = 0
                    return true
                else
                    selfSay("Houve um problema ao realizar a transação, tente novamente mais tarde.", cid)
                    talkState[talkUser] = 0
                    return true
                end
            elseif msgcontains(msg:lower(), "no") or msgcontains(msg:lower(), "não") then
                selfSay("Tudo bem, vou aguardar você escolher outro item para vender.", cid)
                talkState[talkUser] = 0
                return true
            end
        end

    elseif config.items[msg] and talkState[talkUser] == 2 then
        selfSay("Quantos {" .. msg .. "} você deseja vender? (Digite a quantidade)", cid)
        sellItem = msg
        talkState[talkUser] = 3
        return true

    elseif tonumber(msg) and talkState[talkUser] == 3 then
        local countItems = getPlayerItemCount(cid, getItemIdByName(sellItem)) -- Verificar quantos itens o jogador possui
        local quantity = tonumber(msg)
        
        if quantity > countItems then
            selfSay("Você não possui {" .. quantity .. "} {" .. sellItem .. "} no seu inventário.", cid)
            talkState[talkUser] = 0
            return true
        end
        
        local price = config.items[sellItem]
        local totalPrice = quantity * price -- Calcular o preço total

        selfSay("Você tem {" .. quantity .. "} {" .. sellItem .. "}. Deseja vender tudo por {" .. totalPrice .. " Black Diamonds}? {yes} {no}", cid)
        talkState[talkUser] = 5
        return true

    elseif msgcontains(msg:lower(), "no") then
        selfSay("Tudo bem, até mais!", cid)
        talkState[talkUser] = 0
        return true
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
