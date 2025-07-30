-- local fishingPokemon = {
    -- ["Magikarp"] = {skill = 1, level = 1},
    -- ["Poliwag"] = {skill = 1, level = 1},
    -- ["Horsea"] = {skill = 1, level = 1},
    -- ["Goldeen"] = {skill = 1, level = 1},
    -- ["Remoraid"] = {skill = 1, level = 1},
    -- ["Sealeo"] = {skill = 1, level = 1},
    -- ["Chinchou"] = {skill = 1, level = 1},
    -- ["Staryu"] = {skill = 1, level = 1},
    -- ["Shellder"] = {skill = 1, level = 1},
    -- ["Krabby"] = {skill = 1, level = 1},
    -- ["Tentacool"] = {skill = 1, level = 1},
    -- ["Seel"] = {skill = 1, level = 1},


-- }

-- local Storage = {
    -- FishingCount = 50000, -- Substitua o valor pelo ID de Storage adequado
    -- -- Outros storages podem ser definidos aqui se necessário.
-- }

-- local function resetFishingCount(player)
    -- player:setStorageValue(Storage.FishingCount, 0)
    -- player:setStorageValue(Storage.LastFishingAttempt, 0)
-- end

-- function onUse(player, item, fromPosition, target, toPosition, isHotkey)
-- if item:getId() == 2580 and (target:getId() == 4821 or target:getId() == 4822 or target:getId() == 4823 or target:getId() == 4824 or target:getId() == 4825 or target:getId() == 4820) then
        -- toPosition:sendMagicEffect(2)

        -- local currentTime = os.time()
        -- local lastFishingAttempt = player:getStorageValue(Storage.LastFishingAttempt) or 0

        -- if currentTime - lastFishingAttempt < math.random(1, 3) then
            -- return true
        -- end

        -- local possibleFish = {}

        -- local skillLevel = player:getSkillLevel(SKILL_FISHING)
        
        -- for name, info in pairs(fishingPokemon) do
            -- if skillLevel >= info.skill then
                -- table.insert(possibleFish, name)
            -- end
        -- end

        -- local playerPokemon = player:getSummons()[1]
        -- if not playerPokemon then
            -- player:sendCancelMessage("Você precisa ter um Pokémon ativo para pescar.")
            -- return true
        -- end

        -- if #possibleFish > 0 then
            -- local fishName = possibleFish[math.random(#possibleFish)]

            -- local pokemonPos = playerPokemon:getPosition()
            
            -- local spawnPos = Position(pokemonPos.x + math.random(-1, 1), pokemonPos.y + math.random(-1, 1), pokemonPos.z)
            -- while Tile(spawnPos):getTopCreature() ~= nil do
                -- spawnPos = Position(spawnPos.x + math.random(-1, 1), spawnPos.y + math.random(-1, 1), spawnPos.z)
            -- end

            -- local monster = Game.createMonster(fishName, spawnPos)

            -- if monster then
                -- local xpReward = 100
                -- player:addSkillTries(SKILL_FISHING, 1)
                -- player:addExperience(SKILL_FISHING, xpReward)

                -- resetFishingCount(player)

                -- player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você pescou um " .. fishName .. "!")
                -- spawnPos:sendMagicEffect(CONST_ME_WATERSPLASH)

                -- -- Verifica a chance de aparecer um baú do tesouro
                -- if math.random(1, 500) == 1 then
                    -- local chestPosition = player:getPosition()
                    -- local chest = Game.createItem(22206, 1, chestPosition)
                    -- if chest then
                        -- Game.broadcastMessage(player:getName() .. " acabou de pescar um bau do tessouro!.", MESSAGE_EVENT_ADVANCE)
                        -- chestPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
                    -- end
                -- end
            -- else
                -- player:sendCancelMessage("Erro ao criar o Pokémon: " .. fishName)
            -- end
        -- else
            -- player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Nada parece morder o anzol desta vez.")
        -- end

        -- player:setStorageValue(Storage.LastFishingAttempt, currentTime)
    -- else
        -- player:sendCancelMessage("Você não está pescando na água!")
    -- end

    -- return true
-- end