local mainWindow = nil
local opcode = 95
local activeTask = 0
local btn = nil
local received = false

function init()
	mainWindow = g_ui.loadUI("task_kill", modules.game_interface.getRootPanel())
	mainWindow:hide()
	btn = modules.client_topmenu.addRightGameToggleButton('task_kill', tr('Task Kill'), 'icon', toggle)
	ProtocolGame.registerExtendedOpcode(opcode, receiveOpcode)
end

function terminate()
    mainWindow:destroy()
	ProtocolGame.unregisterExtendedOpcode(opcode, receiveOpcode)
	if btn then
		btn:destroy()
	end
    disconnect(g_game, { onGameEnd = function()  mainWindow:hide() end})
end

function toggle()
	if mainWindow:isVisible() then
		mainWindow:hide()
	else
		mainWindow:show()
		-- if not received then
			sendTaskBuffer(json.encode({type = "parseTasks"}))
		-- end
	end
end

function convertNumberToString(number)
	local suffixes = {"", "k", "kk"}
	local suffixIndex = 1

	while number >= 1000 do
		number = number / 1000
		suffixIndex = suffixIndex + 1
	end

	return string.format("%d%s", number, suffixes[suffixIndex])
end

function sendTaskBuffer(buffer)
	local protocol = g_game.getProtocolGame()
	protocol:sendExtendedOpcode(opcode, buffer)
end

function receiveOpcode(protocol, opcode, buffer)
	local data = json.decode(buffer)
	local data_type = data.type
	if data_type == "parseTasks" then
		received = true
		mainWindow.labelPoints:setText(("Task Points: %s"):format(data.points))
		activeTask = data.activeTask
		mainWindow.panelPTask.panelPTaskList:destroyChildren()
		local tasks = data.tasks
		for i, task in ipairs(tasks) do
			local widget = g_ui.createWidget('TaskButton', mainWindow.panelPTask.panelPTaskList)
			widget:setId(i)
			widget:setImageSource("images/window_list/type/" .. task.background)
			if task.type and task.type ~= "none" then
				widget.type1:setImageSource("images/window_list/type/type_ball/" .. task.type)
			end
			if task.type2 and task.type2 ~= "none" then
				widget.type2:setImageSource("images/window_list/type/type_ball/" .. task.type2)
			end

			widget.CreatureUIPanel:setOutfit(task.outfit)
			widget.NamePoke:setText(capitalizeFirstLetter(task.pokemon))
			widget.killRequeriment = task.killRequeriment

			if task.kills > task.killRequeriment then
				task.kills = task.killRequeriment
			end

			widget.labelKill:setText(string.format("%s / %s", task.kills, task.killRequeriment))
			widget.labelReward:setText(("Experiência: %s"):format(convertNumberToString(task.rewardExp)))
			widget.labelPoint:setText(("Task Points: %s"):format(task.taskPoints))
			local done = false

			for j, item in ipairs(task.itemRewardList) do
				local itemWidget = widget:getChildById("itemSlot" .. j)
				itemWidget:setItemId(item.itemid)
				itemWidget:setTooltip(item.name)
				itemWidget:setItemCount(item.count or 1)
			end
			if i == activeTask then
				widget.taskButtons = g_ui.createWidget('TaskDoneCancel', widget)
				widget.BackgroudType:setImageSource('images/window_list/border_on')
				widget.taskButtons.onClick = function()
					sendTaskBuffer(json.encode({type = "cancelTask", taskId = i}))
				end
			else
				widget.taskButtons = g_ui.createWidget('TaskAccept', widget)
				widget.BackgroudType:setImageSource('images/window_list/border_off')
				widget.taskButtons.onClick = function()
					sendTaskBuffer(json.encode({type = "acceptTask", taskId = i}))
				end
			end

			if task.kills >= widget.killRequeriment then
				done = true
				widget.sobrepor:setVisible(true)
				widget.sobrepor:raise()
				widget.sobrepor.requisitoText:setText("Missão concluída!")
				widget.sobrepor.requisito:setImageSource("images/window_list/done")
				widget.sobrepor.requisito:setSize('64 64')
			end

			if not task.access and not done then
				widget.sobrepor:setVisible(true)
				widget.sobrepor:raise()
				widget.sobrepor.requisitoText:setText("Para liberar a missão: " .. task.descRequeriment)
			end

		end
	elseif data_type == "killTask" then
		if not received then
			sendTaskBuffer(json.encode({type = "parseTasks"}))
			return
		end
		local widget = mainWindow.panelPTask.panelPTaskList:getChildById(activeTask)
		widget.labelKill:setText(string.format("%s / %s", data.kills, widget.killRequeriment))
		if data.kills >= widget.killRequeriment then
			widget.sobrepor:setVisible(true)
			widget.sobrepor:raise()
			widget.sobrepor.requisitoText:setText("Missão concluída!")
			widget.sobrepor.requisito:setImageSource("images/window_list/done")
			widget.sobrepor.requisito:setSize('64 64')
		end
	end
end


function capitalizeFirstLetter(word)
	word = string.lower(word)
    return word:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
end