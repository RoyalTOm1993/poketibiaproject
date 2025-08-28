local tps = {
    ["Jungle Celebi"] = {itemID = 1049, itemPosition = {x = 2558, y = 3019, z = 8}, respawnTime = 30},
    ["Sea Suicune"] = {itemID = 1049, itemPosition = {x = 2737, y = 3206, z = 8}, respawnTime = 30},
    ["Burned Moltres"] = {itemID = 1049, itemPosition = {x = 3171, y = 2630, z = 8}, respawnTime = 30},
    ["Mech Metapod M1"] = {itemID = 1304, itemPosition = {x = 4147, y = 2667, z = 8}, respawnTime = 30},
    ["Mech Metapod M2"] = {itemID = 1304, itemPosition = {x = 4132, y = 2644, z = 9}, respawnTime = 30},
    ["Mech Metapod M3"] = {itemID = 1304, itemPosition = {x = 4119, y = 2619, z = 9}, respawnTime = 30},
    ["Mech Metapod MVP"] = {itemID = 1304, itemPosition = {x = 100, y = 200, z = 7}, respawnTime = 30},
    ["Black Ursaring MVP"] = {itemID = 9175, itemPosition = {x = 3179, y = 2169, z = 7}, respawnTime = 30},
    ["Mew Super Ultra MVP"] = {itemID = 18102, itemPosition = {x = 3017, y = 3069, z = 11}, respawnTime = 30},
}

function onDeath(cid)
    local monster = Creature(cid)
    local pokemonData = tps[getCreatureName(monster:getId())]

    if pokemonData then
        -- Remove o item da posição especificada
        local item = getTileItemById(pokemonData.itemPosition, pokemonData.itemID)
        if item then
            doRemoveItem(item.uid)
        end

        -- Agendamento para adicionar o item de volta após o tempo especificado
        addEvent(addItemBack, pokemonData.respawnTime * 1000, pokemonData.itemID, pokemonData.itemPosition)
    end

    return TRUE
end

function addItemBack(itemID, position)
    local item = doCreateItem(itemID, 1, position)
    if item then
        doSendMagicEffect(position, CONST_ME_MAGIC_RED)
    end
end
