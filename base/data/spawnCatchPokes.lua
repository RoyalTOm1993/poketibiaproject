function onKill(player, target)
    local targetName = target:getName()
    local listInfo = LIST_CATCHES_SPAWN[targetName]
	local quantidadeKills = 0

	
    if listInfo then
		if player:getStorageValue(296582) - os.time() > 0 then
			quantidadeKills = listInfo.quantidade * 0.7
		else
			quantidadeKills = listInfo.quantidade
		end

        local index = listInfo.index
        local storageCounter = CONST_STORAGE_SPAWN + index
        local storageOld = math.max(0, player:getStorageValue(storageCounter))
        player:setStorageValue(storageCounter, storageOld + 1)
        local storageUpdated = math.max(0, player:getStorageValue(storageCounter))
        if storageUpdated >= quantidadeKills then
            player:setStorageValue(storageCounter, 0)
            local position = target:getPosition()
            local spawnSeconds = listInfo.timer/1000
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("O Pokémon lendário: %s, ira spawnar em %.2f segundos.", listInfo.spawn, spawnSeconds))
            local totalSeconds = math.floor(spawnSeconds)
            for i = 1, totalSeconds do
                for j = 1, 3 do
                    addEvent(function()
                        position:sendMagicEffect(CONST_EFFECT_SPAWN)
                    end, (j*300*i))
                end
            end
            addEvent(function()
                local monster = Game.createMonster(listInfo.spawn, position, false, false, 0, 0)
                monster:sendFirstTitle("ESPECIAL", "proximanova-bold-16", "#A020F0")
            end, listInfo.timer)
        else
            local quantidade = (quantidadeKills - storageUpdated)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Faltam %d kills, para spawnar o pokémon lendário: %s", quantidade, listInfo.spawn))
        end
    end
    return true
end

