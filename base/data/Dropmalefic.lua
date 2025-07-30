function onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
    if not killer or not killer:isPlayer() then
        return true
    end

    local config = {
        ["Malefic Articuno"] = {itemId = 20410, count = 1},
        ["Malefic Zapdos"] = {itemId = 20410, count = 6},
        ["Malefic Moltres"] = {itemId = 20410, count = 5}
    }

    local reward = config[creature:getName()]
    if reward then
        killer:addItem(reward.itemId, reward.count)
    end

    return true
end
