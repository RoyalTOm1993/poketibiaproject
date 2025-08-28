local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- Fun��o para verificar se um n�mero j� foi escolhido pelo jogador
local function isNumberChosen(player, number)
    return player:getStorageValue(1002) == number
end

function onCreatureAppear(creature)
    local player = creature:getMaster() or creature
    if not player:isPlayer() then
        return
    end

    local playerPosition = player:getPosition()
    local allowedCoordinates1 = Position(3227, 2823, 9)

    if playerPosition ~= allowedCoordinates1 then
        return
    end

    npcHandler:say("Oi! Escolha dois n�meros de 1 a 6 para o evento Bag.", player)
end

function onCreatureSay(creature, type, msg)
    local player = creature:getMaster() or creature
    if not player:isPlayer() then
        return
    end

    local playerPosition = player:getPosition()
    local allowedCoordinates1 = Position(3227, 2823, 9)

    if playerPosition ~= allowedCoordinates1 then
        return
    end

    if msg == "hi" then
        npcHandler:say("Escolha o primeiro n�mero (1-6):", player)
        player:setStorageValue(1001, 1)
    elseif player:getStorageValue(1001) == 1 then
        local firstNumber = tonumber(msg)

        if firstNumber and firstNumber >= 1 and firstNumber <= 6 then
            player:setStorageValue(1002, firstNumber)
            npcHandler:say("Agora escolha o segundo n�mero (1-6):", player)
            player:setStorageValue(1001, 2)
        else
            npcHandler:say("N�mero inv�lido. Escolha novamente o primeiro n�mero (1-6):", player)
        end
    elseif player:getStorageValue(1001) == 2 then
        local secondNumber = tonumber(msg)
        local firstNumber = player:getStorageValue(1002)

        if secondNumber and secondNumber >= 1 and secondNumber <= 6 then
            local random1 = math.random(1, 6)
            local random2 = math.random(1, 6)

            npcHandler:say("Voc� escolheu " .. firstNumber .. " e " .. secondNumber .. ". Os n�meros sorteados s�o " .. random1 .. " e " .. random2 .. ".", player)

            local matchCount = 0
            if firstNumber == random1 or firstNumber == random2 then
                matchCount = matchCount + 1
            end

            if secondNumber == random1 or secondNumber == random2 then
                matchCount = matchCount + 1
            end

            if matchCount > 0 then
                local itemName = "Event Bag Box"  -- Substitua pelo nome real do item que o jogador ganhar�.
                local itemID = 17116  -- Substitua pelo ID do item que o jogador ganhar� por cada n�mero acertado.

                if not isNumberChosen(player, secondNumber) then
                    player:addItem(itemID, matchCount)
                    itemName = ItemType(itemID):getName()

                    npcHandler:say("Parab�ns! Voc� acertou " .. matchCount .. " n�mero(s). Ganha " .. matchCount .. " " .. itemName .. "(s).", player)

                    local playerName = player:getName()
                    Game.broadcastMessage("[EventoBag] O jogador " .. playerName .. " acertou os n�meros e ganhou " .. matchCount .. " " .. itemName .. "(s)!", MESSAGE_EVENT_ADVANCE)
                else
                    npcHandler:say("Voc� j� escolheu esse n�mero, mas ganha apenas 1 item. Parab�ns!", player)
                end
            else
                npcHandler:say("Que pena! Voc� n�o acertou nenhum n�mero. Tente novamente.", player)
            end

            player:setStorageValue(1001, 0)

            -- Teletransporte para as coordenadas [X: 1069] [Y: 1022] [Z: 15]
            player:teleportTo(Position(3211, 2833, 9))
        else
            npcHandler:say("N�mero inv�lido. Escolha novamente o segundo n�mero (1-6):", player)
        end
    end
end

npcHandler:setCallback(CALLBACK_CREATURE_APPEAR, onCreatureAppear)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, onCreatureSay)
npcHandler:addModule(FocusModule:new())
