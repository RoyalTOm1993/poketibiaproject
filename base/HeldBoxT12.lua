local items =
{
    [1] = {id = 16802, count = 1},
    [2] = {id = 16805, count = 1},
    [3] = {id = 16803, count = 1},
    [4] = {id = 16809, count = 1},
    [5] = {id = 16807, count = 1},
    [6] = {id = 16808, count = 1},
    [7] = {id = 16823, count = 1},
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

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Voce abriu uma held box t12 e ganhou "..items[a].count.."x "..(tonumber(items[a].id) and getItemNameById(items[a].id) or "level"..(items[a].count > 1 and "s" or ""))..".")

    item:remove(1)
    return true
end