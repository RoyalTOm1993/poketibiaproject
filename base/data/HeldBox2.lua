local items =
    { --[numeração] = {id = ID DO ITEM, count = QUANTIDADE DO ITEM}
    [1] = {id = 13395, count = 1},
    [2] = {id = 13396, count = 1},
    [3] = {id = 13397, count = 1},
    [4] = {id = 16770, count = 1},
    [5] = {id = 16778, count = 1},
    [6] = {id = 16786, count = 1},
    [7] = {id = 16794, count = 1},
    [8] = {id = 16802, count = 1},
    [9] = {id = 16803, count = 1},
    [10] = {id = 16804, count = 1},
    [11] = {id = 16771, count = 1},
    [12] = {id = 16781, count = 1},
    [13] = {id = 16790, count = 1},
    [14] = {id = 16797, count = 1},
    [15] = {id = 16805, count = 1},
    [16] = {id = 13416, count = 1},
    [17] = {id = 13417, count = 1},
    [18] = {id = 13418, count = 1},
    [19] = {id = 16773, count = 1},
    [20] = {id = 16779, count = 1},
    [21] = {id = 16789, count = 1},
    [22] = {id = 16795, count = 1},
    [23] = {id = 16803, count = 1},
    [24] = {id = 13488, count = 1},
    [25] = {id = 13489, count = 1},
    [26] = {id = 13490, count = 1},
    [27] = {id = 16777, count = 1},
    [28] = {id = 16783, count = 1},
    [29] = {id = 16791, count = 1},
    [30] = {id = 16799, count = 1},
    [31] = {id = 16807, count = 1},
    [32] = {id = 13467, count = 1},
    [33] = {id = 13468, count = 1},
    [34] = {id = 13469, count = 1},
    [35] = {id = 16772, count = 1},
    [36] = {id = 16784, count = 1},
    [37] = {id = 16792, count = 1},
    [38] = {id = 16800, count = 1},
    [39] = {id = 16808, count = 1},
    [40] = {id = 16816, count = 1},
    [41] = {id = 16817, count = 1},
    [42] = {id = 16818, count = 1},
    [43] = {id = 16819, count = 1},
    [44] = {id = 16820, count = 1},
    [45] = {id = 16821, count = 1},
    [46] = {id = 16822, count = 1},
    [47] = {id = 16823, count = 1},
}

function doPlayerAddLevel(player, amount, round)
    local newExp = 0
    local currentLevel = player:getLevel()

    if amount > 0 then
        newExp = getExperienceForLevel(currentLevel + amount) - (round and player:getExperience() or getExperienceForLevel(currentLevel))
    else
        newExp = -((round and player:getExperience() or getExperienceForLevel(currentLevel)) - getExperienceForLevel(currentLevel + amount))
    end

    player:addExperience(newExp)
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    if not player then
        return false
    end

    local a = math.random(1, #items)
    if type(items[a].id) == "string" then
        doPlayerAddLevel(player, items[a].count)
    else
        player:addItem(items[a].id, items[a].count)
    end

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voce abriu uma box aleatoria e ganhou "..items[a].count.."x "..(tonumber(items[a].id) and getItemNameById(items[a].id) or "level"..(items[a].count > 1 and "s" or ""))..".")

    item:remove(1)
    return true
end