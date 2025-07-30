local btype = "pokeball"
local pokemon = "Galactic Mewtwo"
local storage = 53409 -- storage

function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid)
    
    if not player then
        return true
    end
    
    -- Verificar se o jogador já pegou a recompensa
    if player:getStorageValue(storage) == 1 then
        player:sendCancelMessage("Você já pegou sua recompensa.")
        return true
    end
    
    local chance = math.random(1, 3) -- Gerar um número aleatório entre 1 e 4
    
    if chance == 1 then
        local pokeball = doAddPokeball(player, pokemon)
        if pokeball then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Parabéns! Você completou a quest e recebeu o Pokémon " .. pokemon .. "!")
            player:getPosition():sendMagicEffect(29)
            player:getPosition():sendMagicEffect(27)
            player:getPosition():sendMagicEffect(29)
            player:setStorageValue(storage, 1) -- Define o valor da storage para 1 para indicar que a recompensa foi dada
            
            -- Mensagem global com o nome do jogador e o Pokémon ganho
            local playerName = player:getName()
            local message = playerName .. " pegou um " .. pokemon .. " na quest Galactic Mewtwo!"
            Game.broadcastMessage(message, MESSAGE_EVENT_ADVANCE)
        else
            player:sendCancelMessage("Erro ao adicionar o Pokémon. Contate um administrador.")
        end
    else
        player:sendCancelMessage("Infelizmente você não conseguiu pegar o Pokémon. Você só tem uma chance.")
        player:setStorageValue(storage, 1) -- Define a storage para 1 para indicar que a chance foi usada
    end
    
    return true
end
