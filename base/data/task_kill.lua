STORAGE_MAIN_TASKS = 99500
STORAGE_POINTS = STORAGE_MAIN_TASKS - 1
STORAGE_ACTIVE_TASK = STORAGE_MAIN_TASKS - 2
OPCODE_TASKS_KILL = 95

STORAGE_DONE_TASK = STORAGE_MAIN_TASKS + 20000

local TASKS_KILL = {
    [1] = {
        name = "Kill 30 Bellsprout",
        -- missionRequeriment = {storage = 10001, value = 1, desc = "Complete a miss�o de jorge em saffron."},
        killRequeriment = 30,
        pokemon = "bellsprout",
        taskPoints = 1,
        rewardExp = 5000,
        itemRewardList = { -- max items = 10
            {itemid = 2152, count = 10},
            {itemid = 26662, count = 50},
            {itemid = 27645, count = 10},
        }
    },
    [2] = {
        name = "Kill 30 Oddish",
        -- missionRequeriment = {storage = 10001, value = 1, desc = "Complete a miss�o de jorge em saffron."},
        killRequeriment = 30,
        pokemon = "oddish",
        taskPoints = 1,
        rewardExp = 10000,
        itemRewardList = { -- max items = 10
            {itemid = 2152, count = 10},
            {itemid = 26662, count = 50},
            {itemid = 27645, count = 10},
        }
    },
    [3] = {
        name = "Kill 30 Pidgeotto",
     --   missionRequeriment = {storage = 10002, value = 1, desc = "Alcance o nivel 1000"},
        killRequeriment = 30,
        pokemon = "pidgeotto",
        taskPoints = 2,
        rewardExp = 25000,
        itemRewardList = { -- max items = 10
            {itemid = 2152, count = 30},
            {itemid = 26663, count = 30},
            {itemid = 27645, count = 15},
        }
    },
    [4] = {
        name = "Kill 50 Dugtrio",
        -- missionRequeriment = {storage = 10001, value = 1, desc = "Complete a miss�o de jorge em saffron."},
        killRequeriment = 50,
        pokemon = "dugtrio",
        taskPoints = 1,
        rewardExp = 10000,
        itemRewardList = { -- max items = 10
            {itemid = 26688, count = 30},
            {itemid = 27645, count = 10},
        }
    },
    [5] = {
        name = "Kill 100 sandslash",
        -- missionRequeriment = {storage = 10001, value = 1, desc = "Complete a miss�o de jorge em saffron."},
        killRequeriment = 100,
        pokemon = "sandslash",
        taskPoints = 3,
        rewardExp = 50000,
        itemRewardList = { -- max items = 10
            {itemid = 26688, count = 50},
            {itemid = 27645, count = 25},
        }
    },
    [6] = {
        name = "Kill 100 Abra",
        -- missionRequeriment = {storage = 10003, value = 1, desc = "Fa�a a miss�o secreta psiquica."},
        killRequeriment = 100,
        pokemon = "abra",
        taskPoints = 3,
        rewardExp = 30000,
        itemRewardList = { -- max items = 10
            {itemid = 2152, count = 50},
            {itemid = 26660, count = 20},
            {itemid = 26688, count = 100},
            {itemid = 27645, count = 25},
        }
    },
    [7] = {
        name = "Kill 300 Charizard",
        -- missionRequeriment = {storage = 10004, value = 1, desc = "Fale com o rei do vale do charizard!"},
        killRequeriment = 300,
        pokemon = "charizard",
        taskPoints = 5,
        rewardExp = 200000,
        itemRewardList = { -- max items = 10
            {itemid = 2160, count = 1},
            {itemid = 26688, count = 100},
            {itemid = 27645, count = 50},
        }
    },
    [8] = {
        name = "Kill 300 Blastoise",
        -- missionRequeriment = {storage = 10004, value = 1, desc = "Fale com o rei do vale do charizard!"},
        killRequeriment = 300,
        pokemon = "blastoise",
        taskPoints = 5,
        rewardExp = 200000,
        itemRewardList = { -- max items = 10
            {itemid = 2160, count = 1},
            {itemid = 26688, count = 100},
            {itemid = 27645, count = 50},
        }
    },
    [9] = {
        name = "Kill 300 Venusaur",
        -- missionRequeriment = {storage = 10004, value = 1, desc = "Fale com o rei do vale do charizard!"},
        killRequeriment = 300,
        pokemon = "venusaur",
        taskPoints = 5,
        rewardExp = 200000,
        itemRewardList = { -- max items = 10
            {itemid = 2160, count = 1},
            {itemid = 26688, count = 100},
            {itemid = 27645, count = 50},
        }
    },
	[10] = {
        name = "Kill 200 Jynx",
        killRequeriment = 200,
        pokemon = "jynx",
        taskPoints = 4,
        rewardExp = 150000,
        itemRewardList = { -- max items = 10
            {itemid = 26688, count = 100},
            {itemid = 27645, count = 25},
        }
    }
}

function Player.setMissionActive(self, id)
    if id == -1 then
        local task = self:getActiveTask() -- reset kills
        self:setStorageValue(STORAGE_MAIN_TASKS+task, -1)
    end
    self:setStorageValue(STORAGE_ACTIVE_TASK, id)
end

function Player.getActiveTask(self)
    return math.max(0, self:getStorageValue(STORAGE_ACTIVE_TASK))
end

function Player.hasDoneTask(self, id)
    return self:getStorageValue(STORAGE_DONE_TASK+id) == 1
end

function Player.completeTask(self)
    local activeTask = self:getActiveTask()
    if self:hasDoneTask(activeTask) then
        return
    end
    self:setStorageValue(STORAGE_ACTIVE_TASK, -1)
    self:setStorageValue(STORAGE_DONE_TASK+activeTask, 1)
    self:addTaskPoints(TASKS_KILL[activeTask].taskPoints)
    self:addExperience(TASKS_KILL[activeTask].rewardExp)
    for i, item in ipairs(TASKS_KILL[activeTask].itemRewardList) do
        self:addItem(item.itemid, item.count)
    end
end
-- compat func monster
MonsterType.getOutfit = MonsterType.outfit

function Player.ParseTaskTable(self, originalTable)
    local parsedTable = {}
    for i, task in ipairs(originalTable) do
        local monsterType = MonsterType(task.pokemon)
        parsedTable[i] = {}
        parsedTable[i].name = task.name
        parsedTable[i].background = monsterType and monsterType:getRaceName():lower() or "normal"
        parsedTable[i].access = not task.missionRequeriment and true or self:getStorageValue(task.missionRequeriment.storage) == task.missionRequeriment.value
        parsedTable[i].descRequeriment = task.missionRequeriment and task.missionRequeriment.desc or ""
        parsedTable[i].killRequeriment = task.killRequeriment
        parsedTable[i].kills = math.max(0, self:getStorageValue(STORAGE_MAIN_TASKS + i))
        parsedTable[i].pokemon = task.pokemon
        parsedTable[i].taskPoints = task.taskPoints
        parsedTable[i].type = monsterType and monsterType:getRaceName() or "none"
        parsedTable[i].type2 = monsterType and monsterType:getRace2Name() or "none"
        parsedTable[i].outfit = {type = monsterType:getOutfit().lookType or 0}
        parsedTable[i].rewardExp = task.rewardExp
        parsedTable[i].itemRewardList = {}
        for j, item in ipairs(task.itemRewardList) do
            local itemType = ItemType(item.itemid)
            if not itemType then
               return error("[TASK_KILL ERROR]: Item not found: " .. item.itemid) and {}
            end
            parsedTable[i].itemRewardList[j] = {}
            parsedTable[i].itemRewardList[j].name = itemType:getName()
            parsedTable[i].itemRewardList[j].itemid = itemType:getClientId()
            parsedTable[i].itemRewardList[j].count = item.count
        end
    end
    return parsedTable
end

function Player.getTaskPoints(self)
    return  math.max(0, self:getStorageValue(STORAGE_POINTS))
end

function Player.addTaskPoints(self, points)
    local currentPoints = self:getTaskPoints()
    self:setStorageValue(STORAGE_POINTS, currentPoints + points)
    self:sendTaskData()
end

function Player.removeTaskPoints(self, points)
    local currentPoints = self:getTaskPoints()
    self:setStorageValue(STORAGE_POINTS, currentPoints - points)
    self:sendTaskData()
end


function Player.sendTaskData(self)
    local buffer = {
        type = "parseTasks",
        tasks = self:ParseTaskTable(TASKS_KILL),
        points = self:getTaskPoints(),
        activeTask = self:getActiveTask()
    }
    self:sendExtendedOpcode(OPCODE_TASKS_KILL, json.encode(buffer))
end

function Player.sendKillTask(self)
    local buffer = {
        type = "killTask",
        kills = self:getStorageValue(STORAGE_MAIN_TASKS + self:getActiveTask())
    }
    self:sendExtendedOpcode(OPCODE_TASKS_KILL, json.encode(buffer))
end

function Player.handleTasksKill(self, buffer)
    local data = json.decode(buffer)
    local data_type = data.type
    if data_type == "parseTasks" then
        self:sendTaskData()
    elseif data_type == "acceptTask" then
        local task = TASKS_KILL[data.taskId]
        if not task then
            self:popupFYI("Missao nao encontrada.")
            return
        end
        if self:getActiveTask() > 0 then
            self:popupFYI("Voce ja possui uma missao ativa.")
            return
        end
        if task.missionRequeriment and task.access and not self:getStorageValue(task.missionRequeriment.storage) == task.missionRequeriment.value then
            self:popupFYI("Missao bloqueada: " .. task.descRequeriment)
            return
        end
        self:setMissionActive(data.taskId)
        self:sendTaskData()
    elseif data_type == "cancelTask" then
        self:setMissionActive(-1)
        self:sendTaskData()
    end
end

local creatureevent = CreatureEvent("onKillPokemon")
function creatureevent.onKill(creature, target)
    if not creature:isPlayer() then
        return true
    end
    local activeTask = creature:getActiveTask()
    if activeTask <= 0 then
        return true
    end
    local targetName = target:getName():lower()
    local task = TASKS_KILL[activeTask]
    if targetName ~= task.pokemon then
        return true
    end
    creature:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Voce matou um " .. targetName)
    local kills = math.max(0, creature:getStorageValue(STORAGE_MAIN_TASKS + activeTask))
    kills = kills + 1
    creature:setStorageValue(STORAGE_MAIN_TASKS + activeTask, kills)
    if kills >= task.killRequeriment then
        creature:completeTask()
    end
    creature:sendKillTask()
	return true
end
creatureevent:register()

local creatureevent = CreatureEvent("onLoginKillPokemon")

function creatureevent.onLogin(player)
	player:registerEvent("onKillPokemon")
	return true
end

creatureevent:register()