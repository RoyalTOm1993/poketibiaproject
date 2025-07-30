function onUse(cid, item, frompos, item2, topos)
    local antes = Player(cid):getStorageValue(2224)

    if antes == -1 then
        Game.broadcastMessage("O jogador " .. Player(cid):getName() .. " est� tentando fazer Ice/Infernal Stone Quest mas n�o deveria estar aqui!", MESSAGE_RED)
        Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� ainda n�o fez a Kyurem Quest....")
        return true
    end

    if item.uid == 1523 then
        if Player(cid):getStorageValue(2225) == -1 then
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� Completou Ice/Infernal Stone Quest!.")
            Player(cid):addItem(2160, 100)
            Player(cid):addItem(16238, 3)
            Player(cid):addItem(13215, 2)
            Player(cid):setStorageValue(2225, 1)
        else
            Player(cid):sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voc� j� concluiu a Quest.")
        end
    else
        return 0
    end

    return 1
end
