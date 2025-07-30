function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)  -- Equivalente TFS 1.2: Objeto Player para o ID do jogador
    
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você abriu um Presente de Natal e encontrou um item aleatório!")

    local prize1 = math.random(17343, 17373)
    local prize2 = math.random(17385, 17393)
    local prize3 = math.random(17399, 17404)
    local prize4 = math.random(16811, 16811)
    local prize5 = math.random(17315, 17315)
    local prize6 = math.random(13565, 13565)

    local a = math.random(1, 100)
    local prize

    if a > 0 and a < 33 then
        prize = prize1
    elseif a > 33 and a < 63 then 
        prize = prize2
    elseif a > 63 and a < 101 then 
        prize = prize3
    elseif a > 101 and a < 102 then 
        prize = prize4
    elseif a > 102 and a < 103 then 
        prize = prize5
    elseif a > 104 and a < 105 then 
        prize = prize6
    end

    player:addItem(prize, 1)  -- Equivalente TFS 1.2: Adicionando o prêmio ao inventário do jogador
    item:remove(1)  -- Equivalente TFS 1.2: Removendo o item usado do inventário do jogador

    return true 
end
