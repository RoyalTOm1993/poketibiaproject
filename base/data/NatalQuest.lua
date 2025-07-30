-- Tabela dos itens a serem "sacrificados"
-- Adicione novas entradas para verificar mais de 4 itens
-- Configure a posição onde eles devem estar e o id
local items = {
    {position = {x = 3440, y = 3477, z = 7}, itemId = 17971},
}

-- Tabela dos monstros a serem criados após remover os itens
-- Adicione novas entradas para criar mais monstros
-- Configure a posição onde eles vão nascer e o nome do monstro criado
local monsters = {
    {position = {x = 3442, y = 3476, z = 7}, name = "Papai Noel MVP"},
}

local config = {
    onSpawnMonster = 30,   -- Efeito lançado quando um monstro é criado (30 = confetti)
    onRemoveItem = 1,      -- Efeito lançado quando um item é removido (1 = red spark)
    missingItem = 1,       -- Efeito lançado quando não encontra o item para remover (1 = red spark)
}

function onUse(player, item, fromPosition, target, toPosition)
    local missingItems, removeItems = false, {}

    for _, itemCheck in pairs(items) do
        local tile = Tile(itemCheck.position)
        local itemOnTile = tile:getItemById(itemCheck.itemId)
        
        if not itemOnTile then
            missingItems = true
            if config.missingItem > 0 then
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Está faltando algum item.")
                tile:getPosition():sendMagicEffect(config.missingItem)
            end
        else
            table.insert(removeItems, itemOnTile)
        end
    end

    if not missingItems then
        for _, itemToRemove in pairs(removeItems) do
            local itemPosition = itemToRemove:getPosition()
            if config.onRemoveItem > 0 then
                itemPosition:sendMagicEffect(config.onRemoveItem)
            end
            itemToRemove:remove(1)  -- Remove 1 item do stack (se houver mais de 1)
        end

        for _, monsterInfo in pairs(monsters) do
            local monster = Game.createMonster(monsterInfo.name, monsterInfo.position)
            if monster then
                if config.onSpawnMonster > 0 then
                    monster:getPosition():sendMagicEffect(config.onSpawnMonster)
                end
                player:say("O Boss Ira Sumir Em 5 Minutos!", TALKTYPE_ORANGE_1)
                addEvent(function()
                    local spectators = Game.getSpectators(monsterInfo.position, false, true, 10, 10, 10, 10)
                    for _, spectator in ipairs(spectators) do
                        if spectator:isPlayer() and spectator:getName() == monsterInfo.name then
                            spectator:remove()
                        end
                    end
                end, 18000000)  -- 5 minutos em milissegundos
            end
        end
    end

    return true
end
