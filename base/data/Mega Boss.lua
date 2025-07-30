local posS = {x = 3042, y = 2709, z = 8}
local posCenter = {x = 3042, y = 2709, z = 8}
local nameE = {"Mega Mewtwo MVP"}
local itemID = 1285  -- Coloque o ID do item que você deseja spawnar
local itemPos = {x = 3042, y = 2710, z = 8}  -- Posição do item

local monstro = "Mega Mewtwo MVP"

function table.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function monstersAlive(center, rangeX, rangeY, monsters)
    local area = Game.getSpectators(center, false, false, rangeX, rangeX, rangeY, rangeY)
    for i, k in ipairs(area) do
        if isMonster(k) and table.contains(monsters, getCreatureName(k)) then
            return true
        end
    end
    return false
end

function onUse(player, item, frompos, item2, topos)
    if monstersAlive(posCenter, 25, 25, nameE) then
        return Game.sendAnimatedText(player:getPosition(), "MATE O BOSS!", math.random(1, 255))
    end

    local monster = Game.createMonster(monstro, posS)
    local effectPosition = Position(posS)
    effectPosition:sendMagicEffect(CONST_ME_TELEPORT)

    local newItem = Game.createItem(itemID, 1, itemPos)
    if newItem then
        newItem:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Congratulations! You defeated the boss.")
    end

    return true
end
