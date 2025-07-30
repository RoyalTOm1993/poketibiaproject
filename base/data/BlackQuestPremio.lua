local btype = "pokeball"
local storage = 8753 -- storage
local posteleporte = {x = 3099, y = 2906, z = 6}

local blacktype = {"Black Ursaring", "Black Raichu", "Black Roserade", "Black Salamence", "Black Vileplume", "Black Blaziken"}


function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid)
    
    if not player then
        return true
    end
	 

    if player:getStorageValue(storage) <= 0 then
        local pokemonx = blacktype[math.random(#blacktype)]
        local pokeball = doAddPokeball(cid, pokemonx)
        if pokeball then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Parabéns! Você completou a quest e recebeu o Pokémon " .. pokemonx .. "!")
            player:getPosition():sendMagicEffect(29)
            player:getPosition():sendMagicEffect(27)
            player:getPosition():sendMagicEffect(29)
            player:teleportTo(posteleporte)
            player:setStorageValue(storage, 1) -- Define o valor da storage para 1 para indicar que a recompensa foi dada
        else
            player:sendCancelMessage("Erro ao adicionar o Pokémon. Contate um administrador.")
        end
    else
        player:sendCancelMessage("Você já pegou sua recompensa.")
    end
    
    return true
end

