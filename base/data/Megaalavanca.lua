local cfg = {
    pos = Position(3068, 3397, 8),
    item = {16218, 2},
    level = 8000
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getLevel() >= cfg.level then
        if player:removeItem(cfg.item[1], cfg.item[2]) then
            player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
            player:teleportTo(cfg.pos)
        else
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você não tem a mega chave, consiga " .. cfg.item[2] .. " " .. ItemType(cfg.item[1]):getName() .. " para passar.")
        end
    else
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa ser level " .. cfg.level .. " para passar.")
    end
    return true
end
