local fishingPokemon = {
    ["Fishing Articuno"] = {skill = 1, level = 20},
    ["Fishing Kyogre"] = {skill = 1, level = 20},
    ["Fishing Phione"] = {skill = 1, level = 20},
    ["Fishing Manaphy"] = {skill = 1, level = 20},
    ["Fishing Entei"] = {skill = 5, level = 40},
    ["Fishing Zapdos"] = {skill = 5, level = 40},
    ["Fishing Suicune"] = {skill = 5, level = 40},
    ["Fishing Blastoise"] = {skill = 5, level = 40},
    ["Fishing Shiny Blastoise"] = {skill = 10, level = 80},
    ["Fishing Swampert"] = {skill = 10, level = 80},
    ["Fishing Charmander"] = {skill = 10, level = 80},
    ["Fishing Squirtle"] = {skill = 10, level = 80},
    ["Fishing Corphish"] = {skill = 10, level = 80},
    ["Fishing Dewgong"] = {skill = 15, level = 160},
    ["Fishing Milotic"] = {skill = 15, level = 160},
    ["Fishing Kingdra"] = {skill = 15, level = 160},
    ["Fishing Lapras"] = {skill = 20, level = 320},
    ["Fishing Gyarados"] = {skill = 20, level = 320},
    ["Fishing Shiny Gyarados"] = {skill = 20, level = 320},
    ["Fishing Feraligatr Nv2"] = {skill = 20, level = 320},
    ["Fishing Kingdra Nv2"] = {skill = 25, level = 640},
    ["Fishing Lapras Nv2"] = {skill = 25, level = 640},
    ["Fishing Milotic Nv2"] = {skill = 25, level = 640},
    ["Fishing Poliwhirl Nv2"] = {skill = 25, level = 640},
    ["Fishing Swampert Nv2"] = {skill = 30, level = 1280},
    ["Fishing Lapras Nv3"] = {skill = 30, level = 1280},
    ["Fishing Poliwhirl Nv3"] = {skill = 30, level = 1280},
    ["Fishing Wailord Nv3"] = {skill = 30, level = 1280},
    ["Fishing Blastoise Nv4"] = {skill = 35, level = 2560},
    ["Fishing Swampert Nv4"] = {skill = 35, level = 2560},
    ["Fishing blastoise nv5"] = {skill = 50, level = 5120},
    ["Fishing kyogre nv5"] = {skill = 50, level = 5120},
    ["Fishing feraligatr nv5"] = {skill = 50, level = 5120},
    ["Fishing politoed nv6"] = {skill = 60, level = 10240},
    ["Fishing blastoise nv8"] = {skill = 75, level = 20480},
    ["Fishing kyogre nv8"] = {skill = 75, level = 20480},
    ["Fishing kyogre nv9"] = {skill = 90, level = 49600},
    ["Fishing kyogre nv10"] = {skill = 100, level = 99200},
    ["Fishing articuno nv10"] = {skill = 100, level = 99200},
    ["Fishing kyogre nv11"] = {skill = 100, level = 99200},
    ["PRO Kyogre"] = {skill = 100, level = 99200},
}

local Storage = {
    FishingCount = 50000, -- Substitua o valor pelo ID de Storage adequado
    -- Outros storages podem ser definidos aqui se necessário.
}

local function resetFishingCount(player)
    player:setStorageValue(Storage.FishingCount, 0)
    player:setStorageValue(Storage.LastFishingAttempt, 0)
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item:getId() == 16231 and (target:getId() == 4821 or target:getId() == 4822 or target:getId() == 4823 or target:getId() == 4824 or target:getId() == 4825 or target:getId() == 4820) then
        toPosition:sendMagicEffect(2)

        local currentTime = os.time()
        local lastFishingAttempt = player:getStorageValue(Storage.LastFishingAttempt) or 0

        if currentTime - lastFishingAttempt < math.random(1, 3) then
            return true
        end

        local possibleFish = {}

        local skillLevel = player:getSkillLevel(SKILL_FISHING)
        
        for name, info in pairs(fishingPokemon) do
            if skillLevel >= info.skill then
                table.insert(possibleFish, name)
            end
        end

        local playerPokemon = player:getSummons()[1]
        if not playerPokemon then
            player:sendCancelMessage("Você precisa ter um Pokémon ativo para pescar.")
            return true
        end

        local numFishToCatch = math.random(1, 2)
        local caughtFish = {}

        for i = 1, numFishToCatch do
            if #possibleFish > 0 then
                local fishName = possibleFish[math.random(#possibleFish)]

                local pokemonPos = playerPokemon:getPosition()
                local spawnPos = Position(pokemonPos.x + math.random(-1, 1), pokemonPos.y + math.random(-1, 1), pokemonPos.z)
                
                while Tile(spawnPos):getTopCreature() ~= nil do
                    spawnPos = Position(spawnPos.x + math.random(-1, 1), spawnPos.y + math.random(-1, 1), spawnPos.z)
                end

                local monster = Game.createMonster(fishName, spawnPos)

                if monster then
                    table.insert(caughtFish, fishName)
                    local xpReward = 100
                    player:addSkillTries(SKILL_FISHING, 1)
                    player:addExperience(SKILL_FISHING, xpReward)

                    resetFishingCount(player)

                    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você pescou um " .. fishName .. "!")
                    spawnPos:sendMagicEffect(CONST_ME_WATERSPLASH)

                    -- Verifica a chance de aparecer um baú do tesouro
                    if math.random(1, 500) == 1 then
                        local chestPosition = player:getPosition()
                        local chest = Game.createItem(22206, 1, chestPosition)
                        if chest then
                            Game.broadcastMessage(player:getName() .. " acabou de pescar um bau do tessouro!.", MESSAGE_EVENT_ADVANCE)
                            chestPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
                        end
                    end
                else
                end
            else
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Nada parece morder o anzol desta vez.")
            end
        end

        player:setStorageValue(Storage.LastFishingAttempt, currentTime)
    else
        player:sendCancelMessage("Você não está pescando na água!")
    end

    return true
end