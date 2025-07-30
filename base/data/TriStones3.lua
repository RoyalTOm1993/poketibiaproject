function onUse(cid, item, fromPosition, itemEx, toPosition)
    local pedra01 = {
        pos = Position(666, 2776, 7),
        pedraID = 2739
    }

    local tempoMS = 1000 * 10 -- 10 seconds in milliseconds

    if item:getActionId() == 6320 then
        local tile = Tile(pedra01.pos)
        local itemOnTile = tile:getItemById(pedra01.pedraID)
        
        if itemOnTile then
            itemOnTile:remove(1)
           	Game.sendAnimatedText(getThingPos(cid), "O Selo foi removido. Você tem 10 segundos", math.random(1, 255))
            
            addEvent(function()
                local newTile = Tile(pedra01.pos)
                if not newTile:getItemById(pedra01.pedraID) then
                    Game.createItem(pedra01.pedraID, 1, pedra01.pos)
                end
            end, tempoMS)
        else
            	Game.sendAnimatedText(getThingPos(cid), "Já foi removido", math.random(1, 255))
        end
    end

    return true
end
