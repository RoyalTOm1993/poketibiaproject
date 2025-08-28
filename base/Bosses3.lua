local item_ = {pos = Position(3121, 2978, 8), itemid = 17311}
local monster = {pos = Position(3121, 2970, 8), name = "Boss Metagross"}


local config = {
    onSpawnMonster = CONST_ME_TELEPORT,
    onRemoveItem = CONST_ME_BLOCKHIT,
    missingItem = CONST_ME_POFF,
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    local missing_items, remove_items = false, {}


        local tile = Tile(item_.pos)
        local itemOnTile = tile and tile:getItemById(item_.itemid)

        if not itemOnTile then
            missing_items = true
            if config.missingItem ~= 255 then
                item_.pos:sendMagicEffect(config.missingItem)
            end
        else
            table.insert(remove_items, itemOnTile)
        end


    if missing_items then
         return player:sendCancelMessage("Jogue sua chave na plate.")
    else
        for _, itemToRemove in pairs(remove_items) do
            if config.onRemoveItem ~= 255 then
                itemToRemove:getPosition():sendMagicEffect(config.onRemoveItem)
            end
            itemToRemove:remove(1)
        end

   
            local monster = Game.createMonster(monster.name, monster.pos)
				
				local monstro = monster.uid
			
            if monster then
                addEvent(function()
				local monstrinho = Creature(monstro)
					if monstrinho then
						monstrinho:remove()
					end
                end, 300000)

                monster:getPosition():sendMagicEffect(config.onSpawnMonster)
                player:say("O Boss Ira Sumir Em 5 Minutos!", TALKTYPE_ORANGE_1)
            end
      
    end

    return true
end
