local cfg = {
    pos = {x = 3335, y = 2840, z = 8},  -- Posição caso tenha todos os requerimentos.
    level = 20000                       -- Level mínimo necessário.
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    if player then
        if player:getLevel() >= cfg.level then
            player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
            player:teleportTo(cfg.pos)
			player:setStorageValue(storageSurf, -1)
			doReleaseSummon(player:getId(), player:getPosition(), false, false)
        else
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa ser level " .. cfg.level .. " para passar.")
        end
    end
    return true
end
