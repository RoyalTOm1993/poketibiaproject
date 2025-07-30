local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

local shopWindow = {}
local items = {
    [15242] = {price = 100, qtd = 1, poke = true, pokemon = "Malefic Articuno", name = "Malefic Articuno"},
    [15240] = {price = 250, qtd = 1, poke = true, pokemon = "Malefic Moltres", name = "Malefic Moltres"},
    [15241] = {price = 500, qtd = 1, poke = true, pokemon = "Malefic Zapdos", name = "Malefic Zapdos"},
    -- Adicione mais itens à lista, se necessário, seguindo o mesmo formato.
}

local halloweenCoinID = 20410  -- ID do item de moeda de Halloween

local function getPlayerHalloweenCoins(cid)
    return getPlayerItemCount(cid, halloweenCoinID)
end

local function removePlayerHalloweenCoins(cid, amount)
    doPlayerRemoveItem(cid, halloweenCoinID, amount)
end

-- Função para verificar se o jogador tem moedas de Halloween suficientes
local function hasEnoughHalloweenCoins(cid, itemID, amount)
    local playerCoins = getPlayerHalloweenCoins(cid)
    return playerCoins >= amount
end

local function onBuy(cid, item, subType, amount, ignoreCap, inBackpacks)
    if items[item] and hasEnoughHalloweenCoins(cid, halloweenCoinID, items[item].price * amount) then
        removePlayerHalloweenCoins(cid, items[item].price * amount)

        if items[item].poke then
            local pokeball = doAddPokeball(cid, items[item].pokemon)

            if pokeball then
                selfSay("Voce recebeu um Pokémon " .. items[item].pokemon .. " na sua Pokébola!", cid)
            else
                selfSay("Houve um erro ao receber o Pokémon.", cid)
            end
        else
            doPlayerAddItem(cid, item, amount * items[item].qtd)
        end

        selfSay("Obrigado por comprar " .. items[item].name, cid)
    else
        selfSay("Voce não tem Ovos suficientes para comprar " .. items[item].name, cid)
    end
end

local pokemonItems = {} -- Inicializa a tabela de Pokémon
local itemItems = {}    -- Inicializa a tabela de itens

for var, ret in pairs(items) do
    if ret.poke then
        table.insert(pokemonItems, {
            id = var,
            subType = 0,
            buy = ret.price,
            sell = 0,
            name = ret.name,
            pokemon = ret.pokemon
        })
    else
        table.insert(itemItems, {
            id = var,
            subType = 0,
            buy = ret.price,
            sell = 0,
            name = ret.name,
        })
    end
end

-- Ordenar as tabelas por preço
table.sort(pokemonItems, function(a, b) return a.buy < b.buy end)
table.sort(itemItems, function(a, b) return a.buy < b.buy end)

-- Mesclar as tabelas de Pokémon e itens em uma única tabela
for _, entry in ipairs(pokemonItems) do
    table.insert(shopWindow, entry)
end
for _, entry in ipairs(itemItems) do
    table.insert(shopWindow, entry)
end

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

    local playerCoins = getPlayerHalloweenCoins(cid)

    selfSay("Voce tem " .. playerCoins .. " Ovos.", cid)

    if msgcontains(msg, 'trade') or msgcontains(msg, 'TRADE') then
        openShopWindow(cid, shopWindow, onBuy, onSell)
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())