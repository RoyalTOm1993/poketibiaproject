function onUse(cid, item, fromPosition, itemEx, toPosition)
    local pedra01 = {
        pos = Position(581, 1923, 5),
        pedraID = 1356
    }

    local tempoMS = 1000 * 60 -- 1 minute in milliseconds

    if item:getActionId() == 6319 then
        local tile = Tile(pedra01.pos)
        local itemOnTile = tile:getItemById(pedra01.pedraID)
        
        if itemOnTile then
            itemOnTile:remove(1)
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "O Selo foi removido. Você tem 60 segundos")
            
            addEvent(function()
                local newTile = Tile(pedra01.pos)
                if not newTile:getItemById(pedra01.pedraID) then
                    Game.createItem(pedra01.pedraID, 1, pedra01.pos)
                end
            end, tempoMS)
        else
            Player(cid):sendCancelMessage("Já foi removido")
        end
    end

    return true
end
