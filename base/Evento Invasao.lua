function onTime(interval)
    local monsters = {
        "Shadowoxys",
        "Xerneas Thundervine",
        "Mewtwo Psyfire Y",
        "Perfect Dialga",
        "Entei Galante",
        "Black Arcanine",
        "Miraidon",
        "Ceruledge",
        "Baby Palkia",
        "Baby Dialga",
        "Zacian",
        "Zamazenta",
        "Grizzbolt",
        "Jetragon",
        "Giant Lugia",
        "Giant Regigigas",
        -- Adicione mais nomes de monstros conforme necessário
    }

    local coordinates = {
        {x = 3088, y = 2928, z = 7}, 
        {x = 3113, y = 2919, z = 7}, 
        {x = 3065, y = 2914, z = 7}, 
        {x = 3077, y = 2945, z = 7}, 
        {x = 3077, y = 2965, z = 7}, 
        {x = 3069, y = 2982, z = 7}, 
        {x = 3114, y = 2965, z = 7}, 
        {x = 3128, y = 2902, z = 7}, 
        {x = 3137, y = 2919, z = 7}, 
        {x = 3142, y = 2956, z = 7}, 
        {x = 3126, y = 2971, z = 7}, 
        {x = 3106, y = 2983, z = 7}, 
        {x = 3095, y = 2939, z = 7}, 
    }

    local minMonsters = 3
    local maxMonsters = 5

    local timeLeft = 5

    local eventId

    local function sendMinuteWarning()
        if timeLeft > 0 then
    Game.broadcastMessage("[Evento] A Invasão Sera Iniciada Em " .. timeLeft .. " Minutos Na Cidade De Saffron!")
            timeLeft = timeLeft - 1
            eventId = addEvent(sendMinuteWarning, 60 * 1000)
        else
            for _, coord in ipairs(coordinates) do
                local monsterCount = math.random(minMonsters, maxMonsters)
                for i = 1, monsterCount do
                    local monsterName = monsters[math.random(1, #monsters)]
                    local creature = Game.createMonster(monsterName, coord)
                    if creature then
                        print("Spawned " .. monsterName .. " at (" .. coord.x .. ", " .. coord.y .. ", " .. coord.z .. ")")
                    else
                        print("Failed to spawn " .. monsterName .. " at (" .. coord.x .. ", " .. coord.y .. ", " .. coord.z .. ")")
                    end
                end
            end
        end
    end

    Game.broadcastMessage("[Evento] Invasão Foi Iniciado!")
    sendMinuteWarning()

    return true
end
