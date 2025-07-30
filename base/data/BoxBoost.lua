local itens =
{
    [1] = {id = 13563, count = 5},
    [2] = {id = 13564, count = 5},
    [3] = {id = 13565, count = 5},
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local jogador = Player(cid)  -- Equivalente TFS 1.2: Objeto Player para o ID do jogador

    local a = math.random(1, #itens)
    local itemSelecionado = itens[a]

    if type(itemSelecionado.id) == "number" then
        jogador:addItem(itemSelecionado.id, itemSelecionado.count)  -- Equivalente TFS 1.2: Adicionando itens ao inventário do jogador
    else
        jogador:addExperience(itemSelecionado.count)  -- Equivalente TFS 1.2: Adicionando pontos de experiência ao jogador
    end

    jogador:say("Você abriu uma caixa aleatória e recebeu " .. itemSelecionado.count .. "x " .. (ItemType(itemSelecionado.id) and ItemType(itemSelecionado.id):getName() or "nível" .. (itemSelecionado.count > 1 and "s" or "")) .. ".", TALKTYPE_MONSTER_SAY)  -- Equivalente TFS 1.2: Enviando uma mensagem ao jogador

    item:remove(1)  -- Equivalente TFS 1.2: Removendo o item da caixa aberta do inventário do jogador

    return true
end
