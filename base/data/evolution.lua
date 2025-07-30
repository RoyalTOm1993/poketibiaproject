-- local CONDITIONID_CUSTOM = 1000  -- Defina um valor apropriado que não conflite com outras condições

-- -- Tabela de evolução dos Pokémon
-- local evolutionTable = {
    -- ["Abra"] = {evolution = "Kadabra", level = 16, stones = 1, stoneId = 26727},
    -- ["Wartortle"] = {evolution = "Blastoise", level = 36, stones = 2, stoneId = 9101}
-- }

-- function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- print("Script onUse iniciado")  -- Mensagem de depuração

    -- if not player or not target or not target:isCreature() then
        -- print("Parâmetros inválidos")
        -- return false
    -- end

    -- local summonName = target:getName()
    -- local evolutionData = evolutionTable[summonName]
    
    -- if not evolutionData then
        -- print("Nenhuma evolução disponível para: " .. summonName)
        -- player:sendCancelMessage("Sorry, not possible. You cannot evolve this monster.")
        -- return true
    -- end
    
    -- if target:isPlayer() or target:getMaster() ~= player then
        -- print("Alvo não é um Pokémon invocado pelo jogador")
        -- player:sendCancelMessage("Sorry, not possible. You can only evolve your own summon.")
        -- return true
    -- end

    -- if player:getLevel() < evolutionData.level then
        -- print("Nível insuficiente para evoluir " .. summonName)
        -- player:sendCancelMessage("You need to be at least level " .. evolutionData.level .. " to evolve this Pokémon.")
        -- return true
    -- end

    -- if player:getItemCount(evolutionData.stoneId) < evolutionData.stones then
        -- print("Jogador não possui as stones necessárias")
        -- player:sendCancelMessage("You need " .. evolutionData.stones .. " evolution stones (ID: " .. evolutionData.stoneId .. ") to evolve this Pokémon.")
        -- return true
    -- end
    
    -- player:removeItem(evolutionData.stoneId, evolutionData.stones)
    -- print("Evoluindo " .. summonName .. " para " .. evolutionData.evolution)
    -- doEvolveSummon(target:getId(), evolutionData.evolution, false, player, summonName)
    -- return true
-- end

-- function doEvolveSummon(targetId, evolutionName, isAncient, player, previousName)
    -- local target = Creature(targetId)
    -- if not target then return false end

    -- local master = target:getMaster()
    -- if not master then return false end

    -- -- Criar a nova criatura evoluída
    -- local evolvedSummon = Game.createMonster(evolutionName, target:getPosition(), false, true)
    -- if not evolvedSummon then return false end

    -- evolvedSummon:setMaster(master) -- Definir o dono correto
    -- target:remove() -- Remover o Pokémon original

    -- -- Atualizar a Pokébola
    -- local function updatePokeball(player, previousName, evolutionName)
        -- print("Iniciando a atualização da Pokébola...")  -- Mensagem de depuração
        -- -- Percorrer os slots de 1 a 100
        -- for i = 1, 100 do  -- Limite máximo arbitrário de 100 slots
            -- local item = player:getSlotItem(i)  -- Acessa o slot
            -- if item then
                -- print("Verificando item no slot " .. i)  -- Mensagem de depuração
                -- local itemDescription = item:getAttribute(ITEM_ATTRIBUTE_DESCRIPTION)
                -- print("Descrição do item no slot " .. i .. ": " .. (itemDescription or "Sem descrição"))  -- Imprimir a descrição do item
                -- if itemDescription then
                    -- if itemDescription:lower():find(previousName:lower()) then
                        -- -- Atualiza a descrição para refletir a evolução
                        -- item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "This Pokéball contains a " .. evolutionName .. ".")
                        -- -- Atualiza o nome do item para o novo Pokémon
                        -- item:setAttribute(ITEM_ATTRIBUTE_NAME, evolutionName)
                        -- -- Atualiza o ID único da Pokébola para o novo Pokémon evoluído
                        -- item:setAttribute(ITEM_ATTRIBUTE_UNIQUEID, evolvedSummon:getId())
                        -- -- Salva as alterações feitas na Pokébola
                        -- item:save()
                        -- print("Pokébola atualizada para " .. evolutionName)
                        -- return true
                    -- end
                -- end
            -- end
        -- end
        -- print("Não foi possível encontrar a Pokébola para atualizar.")
        -- return false
    -- end

    -- updatePokeball(player, previousName, evolutionName)  -- Chama a função para atualizar a Pokébola após a evolução

    -- return true
-- end
