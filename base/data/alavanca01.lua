function onUse(cid, item, frompos, item2, topos)
    local pedra01 = {
        pos = Position(1504, 2155, 12),
        pedraID = 1353
    }

    local pedra02 = {
        pos = Position(1505, 2155, 12),
        pedraID = 1354
    }

    local pedra03 = {
        pos = Position(1506, 2155, 12),
        pedraID = 1355
    }

    -- 1000 = 1 segundo
    local tempoMS = 1000 * 40 -- 40 segundos

    if item:getActionId() == 6316 then
        local tile = Tile(pedra01.pos)
        local pedraItem = tile:getItemById(pedra01.pedraID)
        
        if pedraItem then
            pedraItem:remove(1)
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "O Selo foi removido. Você tem 40 segundos.")
            addEvent(function()
                Game.createItem(pedra01.pedraID, 1, pedra01.pos)
            end, tempoMS)
        else
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "Já foi removido.")
        end
        return true
    end

    if item:getActionId() == 6317 then
        local tile = Tile(pedra02.pos)
        local pedraItem = tile:getItemById(pedra02.pedraID)
        
        if pedraItem then
            pedraItem:remove(1)
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "O Selo foi removido. Você tem 40 segundos.")
            addEvent(function()
                Game.createItem(pedra02.pedraID, 1, pedra02.pos)
            end, tempoMS)
        else
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "Já foi removido.")
        end
        return true
    end

    if item:getActionId() == 6318 then
        local tile = Tile(pedra03.pos)
        local pedraItem = tile:getItemById(pedra03.pedraID)
        
        if pedraItem then
            pedraItem:remove(1)
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "O Selo foi removido. Você tem 40 segundos.")
            addEvent(function()
                Game.createItem(pedra03.pedraID, 1, pedra03.pos)
            end, tempoMS)
        else
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "Já foi removido.")
        end
        return true
    end

    return true
end
