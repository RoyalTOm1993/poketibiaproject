-- Coloque este script no diretório onde você está mantendo seus scripts, como 'data/scripts/'

function onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor, onlyItem, fromActor)
    local player = Player(cid)
    if not player then
        return false
    end
    
    local waterTerrainIDs = {}  -- IDs dos terrenos de água
    
    local tile = Tile(position)
    if tile and tile:getGround() then
        local groundId = tile:getGround():getId()
        for _, waterId in ipairs(waterTerrainIDs) do
            if groundId == waterId then
                -- O jogador pisou em um tile de água, faça algo aqui
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You stepped into water!")
                break
            end
        end
    end
    
end
