function onTime(interval)

    -- if tonumber(os.date("%w")) ~= 3 then
        -- return true
    -- end

    local minPlayers = 15
    local playersOnline = #Game.getPlayers()

    if playersOnline < minPlayers then
        local playersNeeded = minPlayers - playersOnline
        Game.broadcastMessage("[EVENTO BAG] O evento do bag n�o iniciar� devido � falta de jogadores. Pelo menos " .. minPlayers .. " jogador(es) adicional(is) s�o necess�rios. Online no momento : " .. playersOnline)
        return true
    end
	
    Game.broadcastMessage("[EVENTO BAG] Evento bag iniciado!, Portal no cp!.")

    local portalPosFinal = Position(3211, 2833, 9)
    local portalPosInicial = Position(3078, 2904, 7)
    Game.createItem(1387, 1, portalPosInicial):setDestination(portalPosFinal)

    addEvent(function()
        Game.broadcastMessage("[EVENTO BAG] 3 minutos se passaram! O portal permanecer� aberto por mais 2 minutos!.")
    end, 120000)

local textTimer = 0
local textInterval = 1000

local function displayEventText()
    Game.sendAnimatedText(portalPosInicial, "[EVENTO BAG]", math.random(1, 255))
    textTimer = textTimer + textInterval
    if textTimer < 300000 then
        addEvent(displayEventText, textInterval)
    end
end

displayEventText()

    addEvent(function()
        Game.broadcastMessage("[EVENTO BAG] 5 minutos restantes! O portal ser� fechado em breve. Aproveite o tempo que resta!")

        local teleportPosition = Position(3209, 2839, 9)
        local teleportPositionCp = Position(3078, 2904, 7)
        local targetPosition = Position(3228, 2819, 9)
        local distanceThreshold = 30

        for _, player in ipairs(Game.getPlayers()) do
            local playerPos = player:getPosition()
            local distance = playerPos:getDistance(targetPosition)

            if distance <= distanceThreshold then
                player:teleportTo(teleportPositionCp)
                player:sendTextMessage(MESSAGE_INFO_DESCR, "[EVENTO BAG] FIM DO EVENTO ATE A PROXIMA")
            end
        end

        local portalTile = Tile(portalPosInicial):getItemById(1387)
        if portalTile then
            portalTile:remove()
            Game.broadcastMessage("[EVENTO BAG] O portal desapareceu! Ate a proxima semana!")
        end
    end, 300000)

    return true
end
