--[[
tabela dos itens a serem "sacrificados"
adicione novas linhas para checar por mais de 4 itens
configure a posição onde ele deve estar e o id
]]
local items = {
    {pos = {x = 1346, y = 1671, z = 9}, itemid = 14636},
    {pos = {x = 1447, y = 1670, z = 9}, itemid = 14636},
    {pos = {x = 1437, y = 1632, z = 9}, itemid = 14636},
    {pos = {x = 1402, y = 1586, z = 9}, itemid = 14636},
}
--[[
tabela dos monstros a serem criados após remover os itens
adicione novas linhas para criar mais monstros
configure a posição onde ele vai nascer o nome do monstro criado
]]
local monsters = {
    {pos = {x = 1366, y = 1599, z = 9}, name = "Espectral Arceus MVP"},
    {pos = {x = 1352, y = 1667, z = 9}, name = "Mew Ultra"},
}

local config = {
    onSpawnMonster = 29, -- constante para o efeito de criação de monstros no TFS 1.2
    onRemoveItem = 3, -- constante para o efeito de remoção de item no TFS 1.2
    missingItem = 2, -- constante para o efeito de item ausente no TFS 1.2
}

function onUse(player, item, fromPosition, target, toPosition)
    local missingItems, removeItems = false, {}

    for _, itemCheck in pairs(items) do
        local tile = Tile(itemCheck.pos)
        local itemOnTile = tile:getItemById(itemCheck.itemid)
        
        if not itemOnTile then
            missingItems = true
            if config.missingItem ~= 0 then
                player:getPosition():sendMagicEffect(config.missingItem)
            end
        else
            table.insert(removeItems, itemOnTile)
        end
    end

    if missingItems then
        player:sendCancelMessage("Está faltando algum item.")
    else
        for _, itemToRemove in pairs(removeItems) do
            if config.onRemoveItem ~= 0 then
                itemToRemove:getPosition():sendMagicEffect(config.onRemoveItem)
            end
            itemToRemove:remove(1) -- Remove 1 unidade do item
        end

        for _, monsterInfo in pairs(monsters) do
            local monster = Game.createMonster(monsterInfo.name, monsterInfo.pos)
            if monster then
                if config.onSpawnMonster ~= 0 then
                    monster:getPosition():sendMagicEffect(config.onSpawnMonster)
                end
                player:say("O Boss Ira Sumir Em 5 Minutos!", TALKTYPE_ORANGE_1)
            end
        end
    end
    return true
end
