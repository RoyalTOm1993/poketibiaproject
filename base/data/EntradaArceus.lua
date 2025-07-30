local cfg = {
    pos = {x = 2782, y = 2691, z = 6},  -- Posi��o caso tenha todos os requerimentos.
    item = {17168, 2},                  -- ID/count do item necess�rio.
    level = 20000                       -- Level m�nimo necess�rio.
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    if player then
        if player:getLevel() >= cfg.level then
            if player:removeItem(cfg.item[1], cfg.item[2]) then
                player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
                player:teleportTo(cfg.pos)
            else
                player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Voc� n�o tem a chave de Arceus. Consiga " .. cfg.item[2] .. " " .. ItemType(cfg.item[1]):getName() .. " para passar.")
            end
        else
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Voc� precisa ser level " .. cfg.level .. " para passar.")
        end
    end
    return true
end
