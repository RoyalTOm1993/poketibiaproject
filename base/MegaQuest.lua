local btype = "pokeball"
local storage = 2223 -- storage
local posteleporte = {x = 3099, y = 2906, z = 6}

local megaPokemons = {
    "Mega Alakazam", "Mega Metagross", "Mega Steelix", "Mega Gallade",
    "Mega Darkrai", "Mega Blastoise", "Mega Slowking", "Mega Gyarados",
    "Mega Lucario"
}

function getRandomPokemon()
    local randomIndex = math.random(1, #megaPokemons)
    return megaPokemons[randomIndex]
end

function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid)
    
    if not player then
        return true
    end
    
    if player:getStorageValue(storage) <= 0 then
        local selectedPokemon = getRandomPokemon()
        local pokeball = doAddPokeball(cid, selectedPokemon)
        if pokeball then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Parab�ns! Voc� completou a quest e recebeu o Pok�mon " .. selectedPokemon .. "!")
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
