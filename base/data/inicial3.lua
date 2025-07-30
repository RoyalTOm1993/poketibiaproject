local btype = "pokeball"
local pokemon = "Articuno"
local storage = 134 -- storage
local posteleporte = {x = 3099, y = 2906, z = 6}

function onUse(cid, item, frompos, item2, topos)
    if pokemon == "" then
        doPlayerSendCancel(cid, "Voc� precisa escolher um Pok�mon inicial antes de receber a recompensa.")
        return true
    end
    
    -- Verifica se o jogador est� online antes de conceder a recompensa
    if isPlayer(cid) then
        if getPlayerStorageValue(cid, storage) <= 0 then
            local pokeball = doAddPokeball(cid, pokemon)
            if pokeball then
                doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Parab�ns! Voc� recebeu seu Pok�mon inicial.")
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
                doPlayerSendCancel(cid, "Erro ao adicionar o Pok�mon. Contate um administrador.")
            end
        else
            doPlayerSendCancel(cid, "Voc� j� pegou sua recompensa.")
        end
    else
        doPlayerSendCancel(cid, "Voc� precisa estar online para receber a recompensa.")
    end
    return true
end
