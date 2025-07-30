function onUse(cid, item, frompos, item2, topos)
    local queststatus = getPlayerStorageValue(cid, 10027) -- Verifica o status da SuperBox +5 Quest
    if queststatus ~= 1 then
        doBroadcastMessage("O jogador " .. getCreatureName(cid) .. " est� tentando fazer a SuperBox +6 mas n�o deveria estar aqui!", MESSAGE_STATUS_WARNING)
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc� ainda n�o fez a SuperBox +5....")
        return true
    end

    if item.uid == 17196 then
        queststatus = getPlayerStorageValue(cid, 10029) -- Verifica o status da SuperBox +6 Quest
        if queststatus == -1 then
            doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc� completou a SuperBox +6 Quest!")
            doPlayerAddItem(cid, 2160, 50) -- Adiciona 50 Crystal Coins (ajuste para os IDs corretos)
            doPlayerAddItem(cid, 16211, 1) -- Adiciona o item 16211 (ajuste para o ID correto)
            doPlayerAddItem(cid, 13215, 100) -- Adiciona 100 Soul Orbs (ajuste para os IDs corretos)
            setPlayerStorageValue(cid, 10029, 1) -- Define o status da SuperBox +6 Quest como conclu�do
        else
            doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc� j� concluiu a Quest.")
        end
    else
        return false
    end

    return true
end
