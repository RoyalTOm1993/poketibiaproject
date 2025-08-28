local fishingPokemon = {
    ["Infernal Celebi"] = true,
    ["Infernal Entei"] = true,
    ["Infernal Giratina"] = true,
    ["Infernal Heatran"] = true,
    ["Infernal Jirachi"] = true,
    ["Infernal Kyurem"] = true,
    ["Infernal Meloetta"] = true,
    ["Infernal Mewtwo"] = true,
    ["Infernal Regigigas"] = true,
    ["Infernal Victini"] = true,
    ["Infernal Volcanion"] = true,
    -- Adicione todos os outros Pokémon de pesca aqui
}

local Storage = {
    FishingCount = 50003, -- Substitua o valor pelo ID de Storage adequado
    -- Outros storages podem ser definidos aqui, se necessário.
    LastFishingAttempt = 50004, -- Adicione o Storage para o último momento de pesca
}

local function resetFishingCount(player)
    player:setStorageValue(Storage.FishingCount, 0)
    player:setStorageValue(Storage.LastFishingAttempt, 0)
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item:getId() == 10223 and (target:getId() >= 598 and target:getId() <= 601) then
        toPosition:sendMagicEffect(16)

        local currentTime = os.time()
        local lastFishingAttempt = player:getStorageValue(Storage.LastFishingAttempt) or 0

        if currentTime - lastFishingAttempt < math.random(2, 15) then
            return true
        end

        local possibleFish = {}

        for name, _ in pairs(fishingPokemon) do
            table.insert(possibleFish, name)
        end

        local playerPokemon = player:getSummons()[1]
        if not playerPokemon then
            player:sendCancelMessage("Você precisa ter um Pokémon ativo para pescar.")
            return true
        end

        if #possibleFish > 0 then
            local fishName = possibleFish[math.random(#possibleFish)]

            local pokemonPos = playerPokemon:getPosition()

            local spawnPos = Position(pokemonPos.x + math.random(-1, 1), pokemonPos.y + math.random(-1, 1), pokemonPos.z)
            while Tile(spawnPos):getTopCreature() ~= nil do
                spawnPos = Position(spawnPos.x + math.random(-1, 1), spawnPos.y + math.random(-1, 1), spawnPos.z)
            end

            local monster = Game.createMonster(fishName, spawnPos)

            if monster then
                resetFishingCount(player)

                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você pescou um " .. fishName .. "!")
                spawnPos:sendMagicEffect(20)

                -- Verifique a chance de aparecer um baú do tesouro
                if math.random(1, 1000) == 1 then
                    local chestPosition = player:getPosition()
                    local chest = Game.createItem(22206, 1, chestPosition)
                    if chest then
                        Game.broadcastMessage(player:getName() .. " acabou de pescar um baú do tesouro!", MESSAGE_EVENT_ADVANCE)
                        chestPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
                        end
                    end
            else
                player:sendCancelMessage("Erro ao criar o Pokémon: " .. fishName)
            end
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Nada parece morder o anzol desta vez.")
        end

        player:setStorageValue(Storage.LastFishingAttempt, currentTime)
    else
        player:sendCancelMessage("Você não está pescando na água!")
    end

    return true
end
