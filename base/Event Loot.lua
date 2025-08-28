function onTime(interval)
    local doubleLootEventActive = getGlobalStorageValue(1)

    if doubleLootEventActive == -1 or doubleLootEventActive == 0 then
        setGlobalStorageValue(1, 1)  -- Ativar o evento de double loot
        broadcastMessage("[Evento Double Loot]: O evento de double loot foi ativado automaticamente! Aproveite!")

        addEvent(function()
            setGlobalStorageValue(1, 0)  -- Desativar o evento de double loot após 2 horas
            broadcastMessage("[Evento Double Loot]: O evento de double loot terminou.")
        end, 7200000)  -- O evento dura 7200000 milissegundos, o que equivale a 2 horas
    end

    return true
end
