local posS = {x = 4273, y = 2361, z = 2}
local posCenter = {x = 4259, y = 2362, z = 2}
local nameE = {"Marshadow MVP"}

local monstro = "Marshadow MVP"

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
      -- print("OK")
      local effectPosition = Position(posS)
      effectPosition:sendMagicEffect(CONST_ME_TELEPORT)




 return true
end
