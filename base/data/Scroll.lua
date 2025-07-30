local function getSkillId(skillName)
    -- ... (existing code)
end

local function getExpForLevel(level)
    level = level - 1
    return ((50 * level * level * level) - (150 * level * level) + (400 * level)) / 3
end

function onUse(player, item, fromPosition, target, toPosition)
    local playerLevel = player:getLevel()

    local scrollData = {
        [13572] = {levelsToAdd = 300},
        [13214] = {levelsToAdd = 500},
        [20680] = {levelsToAdd = 750},
        [20681] = {levelsToAdd = 1000},
        [20682] = {levelsToAdd = 1250}
    }

    local scroll = scrollData[item.itemid]
    if not scroll then
        return false
    end

    local successRate = math.max(30, 50 - playerLevel) -- decreases the chance of success to 30%

    if math.random(100) > successRate then -- rolls the dice to check if the operation is successful
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Seu Scroll falhou ao adicionar níveis.")
        item:remove(1) -- removes the item in case of failure
        return true
    end

    local experienceNeeded = getExpForLevel(playerLevel + scroll.levelsToAdd)
    local currentExperience = player:getExperience()
    local experienceToAdd = experienceNeeded - currentExperience
    
    -- Make sure experienceToAdd is positive to prevent negative experience changes
    if experienceToAdd > 0 then
        player:addExperience(experienceToAdd)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você adicionou " .. scroll.levelsToAdd .. " níveis ao seu personagem!")
        item:remove(1) -- removes the item after a successful use
    else
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Seu Scroll falhou ao adicionar níveis.")
        item:remove(1) -- removes the item in case of failure (additional check)
    end

    return true
end
