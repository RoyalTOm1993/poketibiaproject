local cfg = {
    pos = {x = 4153, y = 2518, z = 5}, -- Posição para teleportar
    level = 20000                       -- Requisito de nível
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid) -- Converte o cid em um objeto Player
    if player:getLevel() >= cfg.level then
        player:getPosition():sendMagicEffect(CONST_ME_TELEPORT) -- Envia o efeito de teletransporte
        player:teleportTo(cfg.pos) -- Teleporta o jogador para a posição especificada
    else
        itemEx:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED) -- Envia o efeito vermelho
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'Você precisa ser level ' .. cfg.level .. ' para passar.')
    end
    return true
end
