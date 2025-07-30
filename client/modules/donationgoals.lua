local OPCODE = 8
local donateGoalWindow, data

function receiveOpcode(protocol, opcode, buffer)
    local data = json.decode(buffer)
    local goalRewards = data.goalRewards

    local listWidgets = {
        [1] = donateGoalWindow.firstGoal,
        [2] = donateGoalWindow.secondGoal,
        [3] = donateGoalWindow.thirdGoal,
    }

    local playerDonate = data.playerGoal
    local globalGoal = data.globalGoal

    local rewardsGlobal = {}
    for id, rewards in ipairs(goalRewards) do              -- tabela principal
        for idRecompensa, recompensa in ipairs(rewards) do -- tabela individual de cada global
            local mainWidget = listWidgets[id]
            if idRecompensa == 1 then
                table.insert(rewardsGlobal, {id = id, meta = recompensa.meta})
                local globalRewardWidget = mainWidget.backgroundGlobal
                globalRewardWidget:destroyChildren()
                if recompensa.type == "ITEM" then
                    local widget = g_ui.createWidget("globalItemGoal", globalRewardWidget)
                    widget.tooltip:setTooltip(recompensa.desc)
                    widget:setItemId(recompensa.reward.id)
                elseif recompensa.type == "POKEMON" or recompensa.type == "OUTFIT" then
                    local widget = g_ui.createWidget("globalOutfitGoal", globalRewardWidget)
                    widget.tooltip:setTooltip(recompensa.desc)
                    widget:setOutfit(recompensa.outfit)
                end
            else
                local widgetsChest = {
                    [2] = mainWidget.firstReward,
                    [3] = mainWidget.secondReward,
                    [4] = mainWidget.thirdReward,
                }
                local widget = widgetsChest[idRecompensa]
                widget:setTooltip("Meta: " .. recompensa.meta)
                local percent = math.floor((recompensa.meta/ goalRewards[id][4].meta) * 100)

                if percent >= 100 then
                    percent = 100
                end

                local distance = math.floor(201 * (percent / 100))

                widget:setMarginLeft(distance-16)
                widget:setTooltip("Meta: " .. recompensa.meta .. "\n" .. recompensa.desc)

                if playerDonate >= recompensa.meta then
                    widget:setImageSource("images/chest_on")
                else
                    widget:setImageSource("images/chest_off")
                end
                widget.onClick = function ()
                    g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode{type = "collect", rewardType = "pessoal", id = id, subId = idRecompensa})
                end
            end
        end
    end
    setGlobalMeta(goalRewards[3][1].meta, globalGoal)
    configureRewardsGlobalButton(rewardsGlobal, globalGoal)
    setPersonalMeta(playerDonate, goalRewards)
end

function setGlobalMeta(goal, atual)
    local globalPercent = math.floor((atual / goal) * 100)

    if globalPercent >= 100 then
        globalPercent = 100
    end
    local Yhppc = math.floor(808 * (1 - (globalPercent / 100)))
    local rect = { x = 0, y = 0, width = 808 - Yhppc + 1, height = 15 }

    donateGoalWindow.globalProgressFull:setImageClip(rect)
    donateGoalWindow.globalProgressFull:setImageRect(rect)
    donateGoalWindow.globalProgressFull:setTooltip(atual .. "/" .. goal)
end

function setPersonalMeta(playerDonate, data)
    local listWidgets = {
        [1] = donateGoalWindow.firstGoal,
        [2] = donateGoalWindow.secondGoal,
        [3] = donateGoalWindow.thirdGoal,
    }

    for i = 1, 3 do
        local widget = listWidgets[i].barraCheia
        local percent = math.floor((playerDonate / data[i][4].meta) * 100)

        if percent >= 100 then
            percent = 100
        end
        
        local Yhppc = math.floor(201 * (1 - (percent / 100)))
        local rect = { x = 0, y = 0, width = 201 - Yhppc + 1, height = 17 }
        widget:setImageClip(rect)
        widget:setImageRect(rect)
        widget:setTooltip(playerDonate .. "/" .. data[i][4].meta)
    end
end

function configureRewardsGlobalButton(rewardsGlobal, goalGlobalAtual)
    local totalWidth = 808 - 16
    local ordem = {
        [1] = donateGoalWindow.firstReward,
        [2] = donateGoalWindow.secondReward,
        [3] = donateGoalWindow.thirdReward
    }
    for _, reward in ipairs(rewardsGlobal) do
        local percent = math.floor((reward.meta / rewardsGlobal[3].meta) * 100)
        if percent > 100 then
            percent = 100
        end
        local distance = math.floor(totalWidth * (percent / 100))
        ordem[reward.id]:setMarginLeft(distance)
        ordem[reward.id]:setTooltip("Meta: " .. reward.meta)
        
        if goalGlobalAtual >= reward.meta then
            ordem[reward.id]:setImageSource("images/king_on")
        else
            ordem[reward.id]:setImageSource("images/king_off")
        end

        ordem[reward.id].onClick = function()
            g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode{type = "collect", rewardType = "global", id = reward.id})
        end
    end
end

function init()
    donateGoalWindow = g_ui.loadUI('donationgoals', modules.game_interface.getRootPanel())
    ProtocolGame.registerExtendedOpcode(OPCODE, receiveOpcode)
    connect(g_game, {
        onGameEnd = function()
            donateGoalWindow:hide()
        end
    })
    donateGoalWindow:hide()
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(OPCODE)
    donateGoalWindow:destroy()
    disconnect(g_game, {
        onGameEnd = function()
            donateGoalWindow:hide()
        end
    })
    if donateButton then
        donateButton:destroy()
    end
end

function toggle()
    if donateGoalWindow:isVisible() then
        g_effects.fadeOut(donateGoalWindow, 350)
        scheduleEvent(function()
            donateGoalWindow:hide()
        end, 400)
    else
        donateGoalWindow:show()
        g_effects.fadeIn(donateGoalWindow, 350)
    end
end

function getRemainingTime(startDate, endDate)
    startDate = formatDate(startDate)
    local start = os.time { year = tonumber(startDate:sub(1, 4)), month = tonumber(startDate:sub(6, 7)), day = tonumber(startDate:sub(9, 10)) }
    local finish = os.time { year = tonumber(endDate:sub(1, 4)), month = tonumber(endDate:sub(6, 7)), day = tonumber(endDate:sub(9, 10)) }
    local remainingDays = math.floor((finish - start) / (24 * 60 * 60))
    local phrase
    if remainingDays > 1 then
        phrase = "Ends in " .. remainingDays .. " days"
    elseif remainingDays == 1 then
        phrase = "Ends tomorrow"
    else
        phrase = "Ends today"
    end
    return phrase
end

function formatDate(date)
    local day, month, year = date:match("(%d+)-(%d+)-(%d+)")
    local formattedDate = year .. "-" .. month .. "-" .. day
    return formattedDate
end
