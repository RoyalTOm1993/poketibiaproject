local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- Função para verificar se um número já foi escolhido pelo jogador
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

    npcHandler:say("Oi! Escolha dois números de 1 a 6 para o evento Bag.", player)
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
        npcHandler:say("Escolha o primeiro número (1-6):", player)
        player:setStorageValue(1001, 1)
    elseif player:getStorageValue(1001) == 1 then
        local firstNumber = tonumber(msg)

        if firstNumber and firstNumber >= 1 and firstNumber <= 6 then
            player:setStorageValue(1002, firstNumber)
            npcHandler:say("Agora escolha o segundo número (1-6):", player)
            player:setStorageValue(1001, 2)
        else
            npcHandler:say("Número inválido. Escolha novamente o primeiro número (1-6):", player)
        end
    elseif player:getStorageValue(1001) == 2 then
        local secondNumber = tonumber(msg)
        local firstNumber = player:getStorageValue(1002)

        if secondNumber and secondNumber >= 1 and secondNumber <= 6 then
            local random1 = math.random(1, 6)
            local random2 = math.random(1, 6)

            npcHandler:say("Você escolheu " .. firstNumber .. " e " .. secondNumber .. ". Os números sorteados são " .. random1 .. " e " .. random2 .. ".", player)

            local matchCount = 0
            if firstNumber == random1 or firstNumber == random2 then
                matchCount = matchCount + 1
            end

            if secondNumber == random1 or secondNumber == random2 then
                matchCount = matchCount + 1
            end

            if matchCount > 0 then
                local itemName = "Event Bag Box"  -- Substitua pelo nome real do item que o jogador ganhará.
                local itemID = 17116  -- Substitua pelo ID do item que o jogador ganhará por cada número acertado.

                if not isNumberChosen(player, secondNumber) then
                    player:addItem(itemID, matchCount)
                    itemName = ItemType(itemID):getName()

                    npcHandler:say("Parabéns! Você acertou " .. matchCount .. " número(s). Ganha " .. matchCount .. " " .. itemName .. "(s).", player)

                    local playerName = player:getName()
                    Game.broadcastMessage("[EventoBag] O jogador " .. playerName .. " acertou os números e ganhou " .. matchCount .. " " .. itemName .. "(s)!", MESSAGE_EVENT_ADVANCE)
                else
                    npcHandler:say("Você já escolheu esse número, mas ganha apenas 1 item. Parabéns!", player)
                end
            else
                npcHandler:say("Que pena! Você não acertou nenhum número. Tente novamente.", player)
            end

            player:setStorageValue(1001, 0)

            -- Teletransporte para as coordenadas [X: 1069] [Y: 1022] [Z: 15]
            player:teleportTo(Position(3211, 2833, 9))
        else
            npcHandler:say("Número inválido. Escolha novamente o segundo número (1-6):", player)
        end
    end
end

npcHandler:setCallback(CALLBACK_CREATURE_APPEAR, onCreatureAppear)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, onCreatureSay)
npcHandler:addModule(FocusModule:new())
