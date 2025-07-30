function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid) -- Cria o objeto Player para o jogador que usou o item
    
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você abriu a Caixa de Halloween!")

    -- Defina as faixas de prêmios aleatórios
    local prize1 = math.random(17029, 17046)
    local prize2 = math.random(17050, 17115)
    local prize3 = math.random(17133, 17142)
    
    -- Novos IDs de itens
    local newPrizes = {22808, 22806, 22805, 22797, 22762, 22763, 22739, 22805, 22805}
    
    -- Adicione os novos IDs de itens à lista de prêmios aleatórios
    local allPrizes = {prize1, prize2, prize3}
    for _, newPrize in ipairs(newPrizes) do
        table.insert(allPrizes, newPrize)
    end

    -- Gere um número aleatório de 1 a 100
    local a = math.random(1, 100)
    local prize

    -- Determina qual faixa de prêmio o jogador receberá com base no número aleatório gerado
    if a >= 1 and a <= 32 then
        prize = allPrizes[1]
    elseif a >= 33 and a <= 62 then 
        prize = allPrizes[2]
    else
        prize = allPrizes[3]
    end

    -- Adiciona o prêmio ao inventário do jogador
    player:addItem(prize, 1)

    -- Remove o item usado do inventário do jogador
    item:remove(1)

    return true
end
