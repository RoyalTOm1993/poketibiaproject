local btype = "pokeball"
local storage = 22137 -- storage
local posteleporte = {x = 3099, y = 2906, z = 6}

local infernalPokes = {"Infernal Meloetta", "Infernal Jirachi", "Infernal Kyurem", "Infernal Celebi", "Infernal Entei", "Infernal Giratina", "Infernal Heatran", "Infernal Regigigas", "Infernal Victini"}


function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid)
    
    if not player then
        return true
    end
	 
    
    if player:getStorageValue(storage) <= 0 then
        local pokemonx = infernalPokes[math.random(#infernalPokes)]
        local pokeball = doAddPokeball(cid, pokemonx)
        if pokeball then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Parab�ns! Voc� completou a quest e recebeu o Pok�mon " .. pokemonx .. "!")
            player:getPosition():sendMagicEffect(29)
            player:getPosition():sendMagicEffect(27)
            player:getPosition():sendMagicEffect(29)
            player:teleportTo(posteleporte)
            player:setStorageValue(storage, 1) -- Define o valor da storage para 1 para indicar que a recompensa foi dada
        else
            player:sendCancelMessage("Erro ao adicionar o Pok�mon. Contate um administrador.")
        end
    else
        player:sendCancelMessage("Voc� j� pegou sua recompensa.")
    end
    
    return true
end
