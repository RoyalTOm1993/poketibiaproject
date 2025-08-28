local bossConfig3 = {
    bossName = "Boss Heatran",
    bossSpawnPositions = {
        Position(2559, 2893, 12),
        Position(2534, 3076, 12),
        Position(2677, 3075, 12)
    },
    isEventActive = false, -- Adicionando flag para verificar se o evento já está ativo
    eventInterval = 6 * 60 * 60 * 1000 -- Intervalo do evento em milissegundos (5 minutos)
}

function isCreatureNearby(pos, creatureName, radius)
    local spectators = getSpectators(pos, radius, radius, false)
    
    for _, spectator in ipairs(spectators) do
        if isCreature(spectator) and getCreatureName(spectator) == creatureName then
            return true
        end
    end
    
    return false
end

function bossEventStart()
    local bossPos = bossConfig3.bossPosition
    local bossName = bossConfig3.bossName
    local radius = 30

    if not isCreatureNearby(bossPos, bossName, radius) then
        local bossCreature = Game.createMonster(bossName, bossPos)

        if bossCreature then
            Game.broadcastMessage("[Boss Global] Um evento de boss começou! Prepare-se para enfrentar o " .. bossName .. "!")
            return true
        end
    else
        return false
    end
end

function onThink(interval, lastExecution, parameters, event)
    local bossPos = bossConfig3.bossPosition
    local bossName = bossConfig3.bossName
    local radius = 30

    if not isCreatureNearby(bossPos, bossName, radius) then
        local playersOnline = Game.getPlayers()

        if #playersOnline > 0 then
            local randomPlayer = playersOnline[math.random(#playersOnline)]
            bossEventStart()
        end
    else
        -- Se o boss já estiver presente, cancela o evento globalmente
        Game.broadcastMessage("[Boss Global] O evento de boss foi cancelado. Já existe um " .. bossName .. " no local.")
        event:stop()
    end
    return true
end

function onStartup()
    local bossEvent = Game.createEvent("BossEvent")
    bossEvent:setCallback("onThink")
    bossEvent:setParameter("bossConfig3", bossConfig3)
    bossEvent:start()
end
