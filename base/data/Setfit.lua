function onUse(cid, item, fromPosition, itemEx, toPosition)
    local playerId = cid -- Obtém o ID do jogador que está usando o item
    local outfitId = 1145 -- ID da outfit que você quer adicionar

    if player:addOutfit(outfitId) then
        doPlayerSendTextMessage(playerId, MESSAGE_INFO_DESCR, "Outfit adicionada com sucesso!")
    else
        doPlayerSendTextMessage(playerId, MESSAGE_STATUS_CONSOLE_BLUE, "Erro ao adicionar a outfit.")
    end

    return true
end
