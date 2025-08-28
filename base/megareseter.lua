local config = {
    price = 0,           --- preço inicial para resetar
    newlevel = 1000,     --- level após reset
    priceByReset = 0,    --- preço acrescentado por reset
    percent = 1,        ---- porcentagem da vida/mana que você terá ao resetar (em relação à sua antiga vida total)
    maxresets = 1000,
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
    for i = 1, 100 do
        self:setStorageValue(102131, -1)
    end
end

function creatureSayCallback(cid, type, msg)
    local player = Player(cid)

    if not npcHandler:isFocused(cid) then
        return false
    end

    local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

    local function addReseter(cid)
        if npcHandler:isFocused(cid) then
            npcHandler:releaseFocus(cid)
        end

        if player:getStorageValue(102131) == -1 then
            player:setStorageValue(102131, 0)
        end

        talkState[talkUser] = 0
        local resets = player:getStorageValue(102131)
        player:setStorageValue(102131, resets + 1)
        local posxx = {x = 3099, y = 2906, z = 6} -- Altere a posição desejada.
        player:teleportTo(posxx)
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

        player:resetStoragesPlayer()
        player:setStorageValue(32070, player:getStorageValue(32070) + 2)
        broadcastMessage("Boa, " .. player:getName() .. "! Completo reset level 45K+, e Recebeu +1 Reset Points...")
        player:remove()
        local description = resets + 1
        db.storeQuery("UPDATE `players` SET `description` = ' [Reset: " .. description .. "]' WHERE `players`.`id`= " .. playerid .. "")
        db.storeQuery("UPDATE `players` SET `level` = " .. config.newlevel .. ", `experience` = 0 WHERE `players`.`id`= " .. playerid .. "")
        return true
    end

    local newPrice = config.price + (player:getStorageValue(102131) * config.priceByReset)

    if msgcontains(msg, 'reset') then
        if player:getStorageValue(102131) < 100 then
            selfSay('Quer redefinir seu personagem?', cid)
            talkState[talkUser] = 1
        else
            selfSay('Você já atingiu o número máximo de resets!', cid)
        end
    elseif (msgcontains(msg, 'yes') and talkState[talkUser] == 1) then
        if player:getMoney() < newPrice then
            selfSay('É necessário ter pelo menos ' .. newPrice .. ' gps para resetar!', cid)
        else
            player:removeMoney(newPrice)
            playerid = player:getGuid()
            addEvent(function()
                if Player(cid) then
                    addReseter(cid)
                end
            end, 1000)
            local number = player:getStorageValue(102131) + 1
            local msg = "---[Reset: " .. number .. "]-- Você resetou! Você será desconectado em 1 segundo.."
            player:popupFYI(msg)
            talkState[talkUser] = 0
            npcHandler:releaseFocus(cid)
        end
        talkState[talkUser] = 0
    elseif (msgcontains(msg, 'no')) and isInArray({1}, talkState[talkUser]) == TRUE then
        talkState[talkUser] = 0
        npcHandler:releaseFocus(cid)
        selfSay('Ok.', cid)
    elseif msgcontains(msg, 'quantity') then
        selfSay('Você tem um total de ' .. player:getStorageValue(102131) .. ' resets.', cid)
        talkState[talkUser] = 0
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
