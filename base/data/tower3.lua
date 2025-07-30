local t = {
storage = 35363, -- Soh mexa se necessario.
temp = 6, -- Tempo em horas.
count = 100, -- quantidade da reward que sera ganha
reward = 13198 -- Item que irá ganhar. -- por ser o ultimo item do array nao necessita virgula
}

function getItemNameById(itemId)
    local itemT = ItemType(itemId)
    return itemT:getName()
end

function onUse(cid, item, fromPos, itemEx, toPos)
    local player = Player(cid)
    if not player then
        return true
    end

    if player:getStorageValue(t.storage) < os.time() then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Você encontrou um " .. getItemNameById(t.reward) .. ".")
        player:addItem(t.reward, t.count)
        player:setStorageValue(t.storage, os.time() + (t.temp * 60 * 60))
    else
        local hoursRemaining = math.ceil((player:getStorageValue(t.storage) - os.time()) / 3600)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Você precisa esperar " .. hoursRemaining .. " hora(s) para Pegar Novamente.")
    end

    return true
end