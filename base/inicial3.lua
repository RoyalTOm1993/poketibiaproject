local btype = "pokeball"
local pokemon = "Articuno"
local storage = 134 -- storage
local posteleporte = {x = 3099, y = 2906, z = 6}

function onUse(cid, item, frompos, item2, topos)
    if pokemon == "" then
        doPlayerSendCancel(cid, "Você precisa escolher um Pokémon inicial antes de receber a recompensa.")
        return true
    end
    
    -- Verifica se o jogador está online antes de conceder a recompensa
    if isPlayer(cid) then
        if getPlayerStorageValue(cid, storage) <= 0 then
            local pokeball = doAddPokeball(cid, pokemon)
            if pokeball then
                doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Parabéns! Você recebeu seu Pokémon inicial.")
                doSendMagicEffect(getThingPos(cid), 29)
                doPlayerAddItem(cid, 12345, 50)
                doPlayerAddItem(cid, 12345, 50)
                doPlayerAddItem(cid, 13560, 10)
                doPlayerAddItem(cid, 17315, 7)
                doSendMagicEffect(getThingPos(cid), 27)
                doSendMagicEffect(getThingPos(cid), 29)
                doTeleportThing(cid, posteleporte)
                doPlayerSetTown(cid, 1)
                setPlayerStorageValue(cid, storage, 1) -- Define o valor da storage para 1 para indicar que a recompensa foi dada
            else
                doPlayerSendCancel(cid, "Erro ao adicionar o Pokémon. Contate um administrador.")
            end
        else
            doPlayerSendCancel(cid, "Você já pegou sua recompensa.")
        end
    else
        doPlayerSendCancel(cid, "Você precisa estar online para receber a recompensa.")
    end
    return true
end
