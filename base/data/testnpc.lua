local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local trocas = {
    {keyword = 'heldboxt12', trocaItemId = 5901, rewardItemId = 20652, trocaItemQuantidade = 100, mensagem = "Troca de 100x Madeiras por 1x Held Box T12"},
    {keyword = 'boost750', trocaItemId = 2674, rewardItemId = 20709, trocaItemQuantidade = 50, mensagem = "Troca de 50x Macas por 1x Boost + 750"},
    {keyword = 'boost1000', trocaItemId = 2674, rewardItemId = 20708, trocaItemQuantidade = 100, mensagem = "Troca de 100x Macas por 1x Boost + 1000"},
    {keyword = 'rareapple', trocaItemId = 22661, rewardItemId = 2674, trocaItemQuantidade = 50, mensagem = "Troca de 50x Folhas por 1x Rare Apple"},
    {keyword = 'ervapokemon', trocaItemId = 22661, rewardItemId = 22662, trocaItemQuantidade = 750, mensagem = "Troca de 750x Folhas por 1x Erva Pokemon"},
    -- Adicione mais trocas aqui
}

local trocaEmAndamento = {}  -- Armazena informações sobre a troca em andamento.

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

function getItemNameById(itemId)
    -- Implemente a lógica real para obter o nome do item com base no ID
    -- Exemplo:
    local itemNames = {
        [5901] = "Madeira",   -- Substitua com os nomes reais dos itens
        [20652] = "Held Box T12",
        [2674] = "Rare Apple",
        [20709] = "Boost Orb 750",
        [22661] = "Folha",
        [22662] = "Erva Pokemon",
        [20708] = "Boost Orb 1000"
    }
    return itemNames[itemId] or "Item Desconhecido"
end

function creatureSayCallback(cid, type, msg)
    local player = Player(cid)
    if not player then
        return false
    end

    if trocaEmAndamento[cid] then
        local troca = trocaEmAndamento[cid]
        local trocaItemName = getItemNameById(troca.trocaItemId)
        local rewardItemName = getItemNameById(troca.rewardItemId)
        local quantidadeSelecionada = tonumber(msg)

        if quantidadeSelecionada and quantidadeSelecionada > 0 then
            local quantidadeNecessaria = troca.trocaItemQuantidade * quantidadeSelecionada
            local playerItemCount = player:getItemCount(troca.trocaItemId)

            if playerItemCount >= quantidadeNecessaria then
                if player:removeItem(troca.trocaItemId, quantidadeNecessaria) then
                    player:addItem(troca.rewardItemId, quantidadeSelecionada)
                    pnpcHandler:say("Troca realizada com sucesso! Você recebeu " .. quantidadeSelecionada .. "x " .. rewardItemName, cid)
                else
                    player:sendCancelMessage("Ocorreu um erro ao remover os itens de troca.")
                end
            else
                npcHandler:say("Você não tem a quantidade necessária de itens para a troca.", cid)
            end
        else
            npcHandler:say("Quantidade inválida. Troca cancelada.", cid)
        end

        trocaEmAndamento[cid] = nil  -- Limpa a variável de controle.
    else
        for _, troca in ipairs(trocas) do
            if msgcontains(msg, troca.keyword) then
                local trocaItemName = getItemNameById(troca.trocaItemId)
                local rewardItemName = getItemNameById(troca.rewardItemId)
                npcHandler:say(string.format("Quantas %s você gostaria de trocar por %s? Digite a quantidade desejada.", trocaItemName, rewardItemName), cid)
                trocaEmAndamento[cid] = troca
                return true
            end
        end

        if msgcontains(msg, 'trocaitem') then
            local str = "Lista de Trocas Disponíveis:\n\n"
            for _, troca in ipairs(trocas) do
                local trocaItemName = getItemNameById(troca.trocaItemId)
                local rewardItemName = getItemNameById(troca.rewardItemId)
                local mensagem = string.format("Para trocar, digite: '%s'. Troca de %dx %s por 1x %s", troca.keyword, troca.trocaItemQuantidade, trocaItemName, rewardItemName)
                str = str .. mensagem .. "\n"
            end
            doPlayerPopupFYI(cid, str) -- Exibe a lista em um pop-up FYI na tela do jogador
            return true
        end
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
