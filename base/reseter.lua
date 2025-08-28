local config = {
    minlevel = 45000, --- level inicial para resetar
    price = 0, --- preço inicial para resetar
    newlevel = 1000, --- level após reset
    priceByReset = 0, --- preço acrescentado por reset
    percent = 1, ---- porcentagem da vida/mana que você terá ao resetar (em relação à sua antiga vida total)
    maxresets = 550,
    levelbyreset = 0 --- quanto de level vai precisar a mais no próximo reset
}
--- end config

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function Player:resetStoragesPlayer()
    local todos_storages_quests = {53409, 2202, 2222, 2214, 2215, 2230, 2239, 2238, 2237, 2217, 2213, 2240, 2212, 2208, 10028, 10027, 10026, 10025, 10024, 10023, 10022, 2203, 10021, 135, 10021, 2242, 2210, 2218, 21244, 2226, 2221, 2219, 2223, 2241, 2228, 2229, 22136, 2224, 2225, 22137, 2231, 2211, 2201, 2207, 2216, 10022, 10021, 10020, 10019, 10018, 10017, 10016, 10015, 10019, 1014, 1013, 1012, 1011, 1010, 1009, 1008, 1007, 1006, 1005, 1004, 1003, 1002, 1001, 2220}

    for i = 1, #todos_storages_quests do
        self:setStorageValue(todos_storages_quests[i], -1)
    end
end

local posTown1 = {x = 3099, y = 2906, z = 6} -- Substitua as coordenadas com as da cidade desejada

function addReseter(cid)
    if(npcHandler:isFocused(cid)) then
        npcHandler:releaseFocus(cid)
    end

    if player:getStorageValue(102231) == -1 then player:setStorageValue(102231, 0) end
    talkState[talkUser] = 0
    resets = player:getStorageValue(102231)
    player:setStorageValue(102231, resets + 1)

    -- Define a cidade para Town1
    doPlayerSetTown(cid, 1)

    -- Teleporta o jogador para a cidade definida
    doTeleportThing(cid, posTown1)

    local hp = player:getMaxHealth()
    local resethp = hp * (config.percent)
    player:setMaxHealth(resethp)
    local differencehp = (hp - resethp)
    player:addHealth(-differencehp)
    local msg = "Reseti Online Bonussss!"
    MAESTRIAID = 16361

    for i = 1, 30 do
        if resets == ((25 * i) - 1) then
            player:addItem(MAESTRIAID, 1)
        end
    end

    for i = 1, 10 do
        if resets == ((100 * i) - 1) then
            player:addItem(16826, 1)
        end
    end

    -- player:resetStoragesPlayer()
    --- código do prêmio
    player:setStorageValue(32070, player:getStorageValue(32070) + 2)
    broadcastMessage("Boa, " .. player:getName() .. "! Completo reset level 45K+, e Recebeu +1 Reset Points...")
    local namePlayer = player:getName()
    player:remove()
    db.query("UPDATE `players` SET `level` = 1000,`experience` = 0 WHERE `name` = '" .. namePlayer .. "'")
    return true
end

function creatureSayCallback(cid, type, msg)
    local player = Player(cid)

    if not npcHandler:isFocused(cid) then
        return false
    end
    local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

    local function addReseter(cid)
        if(npcHandler:isFocused(cid)) then
            npcHandler:releaseFocus(cid)
        end

        if player:getStorageValue(102231) == -1 then player:setStorageValue(102231, 0) end
        talkState[talkUser] = 0
        resets = player:getStorageValue(102231)
        player:setStorageValue(102231, resets + 1)

        -- Define a cidade para Town1
        doPlayerSetTown(cid, 1)

        -- Teleporta o jogador para a cidade definida
        doTeleportThing(cid, posTown1)

        local hp = player:getMaxHealth()
        local resethp = hp * (config.percent)
        player:setMaxHealth(resethp)
        local differencehp = (hp - resethp)
        player:addHealth(-differencehp)
        local msg = "Reseti Online Bonussss!"
        MAESTRIAID = 16361

        for i = 1, 30 do
            if resets == ((25 * i) - 1) then
                player:addItem(MAESTRIAID, 1)
            end
        end

        for i = 1, 10 do
            if resets == ((100 * i) - 1) then
                player:addItem(16826, 1)
            end
        end

        -- player:resetStoragesPlayer()
        --- código do prêmio
        player:setStorageValue(32070, player:getStorageValue(32070) + 2)
        broadcastMessage("Boa, " .. player:getName() .. "! Completo reset level 45K+, e Recebeu +1 Reset Points...")
        local namePlayer = player:getName()
        player:remove()
        db.query("UPDATE `players` SET `level` = 1000,`experience` = 0 WHERE `name` = '" .. namePlayer .. "'")
        return true
    end

    local newPrice = config.price + (player:getStorageValue(102231) * config.priceByReset)
    local newminlevel = config.minlevel + (player:getStorageValue(102231) * config.levelbyreset)

    if msgcontains(msg, 'reset') then
        if player:getStorageValue(102231) < config.maxresets then
            selfSay('Quer redefinir seu personagem?', cid)
            talkState[talkUser] = 1
        else
            selfSay('Você já atingiu o nível máximo de reset de 100!', cid)
        end

    elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 1) then
        if player:getMoney() < newPrice then
            selfSay('It\'s necessary to have at least ' .. newPrice .. ' gp\'s for resetting!', cid)
        elseif player:getLevel() < newminlevel then
            selfSay('The minimum level for resetting is ' .. newminlevel .. '!', cid)
        else
            player:removeMoney(newPrice)
            playerid = player:getGuid()
            addEvent(function()
                if Player(cid) then
                    addReseter(cid)
                end
            end, 1000)
            local number = player:getStorageValue(102231) + 1
            local msg = "---[Reset: " .. number .. "]-- Você Resetou!  Você será desconectado em 1 segundo.."
            player:popupFYI(msg)
            talkState[talkUser] = 0
            npcHandler:releaseFocus(cid)
        end
        talkState[talkUser] = 0
    elseif(msgcontains(msg, 'no')) and isInArray({1}, talkState[talkUser]) == TRUE then
        talkState[talkUser] = 0
        npcHandler:releaseFocus(cid)
        selfSay('Ok.', cid)
    elseif msgcontains(msg, 'quantity') then
        selfSay('Você tem um total de ' .. player:getStorageValue(102231) .. ' reset(s).', cid)
        talkState[talkUser] = 0
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
