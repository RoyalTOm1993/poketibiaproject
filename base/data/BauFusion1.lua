local t = {
    storage = 7318, -- Apenas modifique se necessário.
    temp = 3000, -- Tempo em horas.
    count = {1}, -- Quantidades das recompensas a serem obtidas.
    reward = {20686} -- Itens a serem obtidos.
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    -- Verifique se um monstro chefe está próximo
    local monsters = {
        {pos = {x = 3337, y = 2270, z = 8}, name = "Fusion Zygarde"},
    }
    for _, monsterinfo in ipairs(monsters) do
        local creatures = Game.getSpectators(monsterinfo.pos, false, true, 5, 5)
        for _, v in ipairs(creatures) do
            local creature = Creature(v)
            if creature and creature:isMonster() and creature:getName() == monsterinfo.name then
                doPlayerSendCancel(cid, "Um chefe ainda está próximo. Você não pode pegar o item.")
                return true
            end
        end
    end

    if getPlayerStorageValue(cid, t.storage) < os.time() then
        for i = 1, #t.reward do
            local itemID = t.reward[i]
            local itemCount = t.count[i]

            -- Verifique se as variáveis não são nulas antes de usá-las
            if itemID and itemCount then
                doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você encontrou " .. itemCount .. "x " .. Item(itemID):getName() .. ".")
                doPlayerAddItem(cid, itemID, itemCount)
            else
                -- Lida com valores nulos ou não definidos aqui, se necessário
                doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Ocorreu um erro ao obter a recompensa.")
            end
        end
        setPlayerStorageValue(cid, t.storage, os.time() + (t.temp * 3600))
    else
        local remainingTime = math.ceil((getPlayerStorageValue(cid, t.storage) - os.time()) / 3600)
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você precisa esperar " .. remainingTime .. " hora(s) para pegar novamente.")
    end

    return true
end
