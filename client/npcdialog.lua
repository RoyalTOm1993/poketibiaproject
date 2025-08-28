local OPCODE_NPC = 54
local closeButton = true
local isAnimating = false
local currentAnimation = nil
local PanelSize = 0
local gameInterface = modules.game_interface

local speedDialog = {
	[1] = 20, -- Muito Lento
	[2] = 50, -- Lento
	[3] = 100, -- Médio
	[4] = 200, -- Rápido
	[5] = 400, -- Muito Rápido
	[6] = 800, -- Super Rápido
	[7] = 1600, -- Instantâneo
}

function getOpCode(protocol, opcode, buffer)
	local status, json_data =
		pcall(
			function()
				return json.decode(buffer)
			end
		)
	if not status or not json_data then
		return false
	end

	print("ola")

	doStartNpcDialog(json_data)
end

function init()
	NpcWindow = g_ui.loadUI('npcdialog', modules.game_interface.getRootPanel())

	npcOutfit = NpcWindow.baseOutfit.NpcOutfit
	npcName = NpcWindow.NpcName
	npcImage = NpcWindow.baseOutfit.image
	baseNpc = NpcWindow.baseOutfit.base
	PanelDialog = NpcWindow.PanelDialog
	PanelSelections = NpcWindow.PanelSelections
	description = PanelDialog.description

	mainPanel = NpcWindow.mainPanel

	NpcWindow:hide()
	ProtocolGame.registerExtendedOpcode(OPCODE_NPC, getOpCode)

	-- g_game.talk('/test')
end

function doStartNpcDialog(data)
	local outfit = data.npcInfo.outfit
	outfit.type = data.npcInfo.outfit.lookType
	local name = data.npcInfo.NpcName.name
	local color = data.npcInfo.NpcName.color
	local image = data.npcInfo.image
	local dialogs = data.dialog
	local buttons = data.Buttons
	local closeTime = data.closeTime
	local speedOption = speedDialog[modules.client_options.getOption('speedNpcChatLevel')]
	local typeCall = data.npcInfo.type

	npcName:setText(name)
	local defaultColor = "#ffffff"
	local color = color or defaultColor

	npcName:setColor(color)

	local imagePath = image and ("/images/npcdialog/" .. image) or "/images/ui/clear"

	if not image then
		outfit = npcOutfit:setOutfit(outfit)
	end

	npcImage:setVisible(image)
	npcOutfit:setVisible(not image)
	baseNpc:setVisible(not image)

	if image then
		npcImage:setImageSource(imagePath)
	end

	PanelSelections:destroyChildren()
	PanelSize = 10

	if buttons then
		for i, button in ipairs(buttons) do
			if button.type == "Text" then
				local textSize = calculateDialogHeight(button.text)
				local buttonWidget = g_ui.createWidget('SelectionsWindowText', PanelSelections)
				if button.response then
					buttonWidget.onClick = function()
						g_game.talkChannel(MessageModes.NpcTo, 0, button.response)
						print(button.response)
					end
				end
				-- doSetColoredColor(buttonWidget.text, tr(button.text), "#ffffff")
				local coloredText = parseColoredText(tr(button.text))
				buttonWidget.text:setColoredText(coloredText)

				buttonWidget.text:setHeight(textSize + 33)
				buttonWidget:setHeight(textSize + 18)

				PanelSize = textSize + PanelSize + 37
			elseif button.type == "PokeSelect" then
				local function calculateDialogHeight(text)
					local maxCharsPerLine = 40
					local lineHeight = 16
					local numLines = math.ceil(string.len(text) / maxCharsPerLine)
					local height = numLines * lineHeight

					return height
				end

				local textSize = calculateDialogHeight(button.text)
				local realpokename, isShiny, isMega = removeShinyAndMega(button.poke)
				local buttonWidget = g_ui.createWidget('SelectionsWindowPokeSelect', PanelSelections)
				if button.response then
					buttonWidget.onClick = function()
						g_game.talkChannel(MessageModes.NpcTo, 0, button.response)
						print(button.response)
					end
				end


				if isShiny then
					buttonWidget.poke:setImageSource("/pokemon/shiny/" .. string.lower(realpokename))
				else
					buttonWidget.poke:setImageSource("/pokemon/regular/" .. string.lower(button.poke))
				end

				-- doSetColoredColor(buttonWidget.title, tr("Choose").." ["..color.."]"..button.poke.."["..color.."/]", "#ffffff")
				buttonWidget.title:setText(tr("Choose") .. " " .. button.poke)

				-- doSetColoredColor(buttonWidget.text, tr(button.text), "#ffffff")
				local coloredText = parseColoredText(tr(button.text))
				buttonWidget.text:setColoredText(coloredText)
				-- buttonWidget.text:setText(tr(button.text))
				
				buttonWidget.text:setHeight(textSize + 33)
				buttonWidget:setHeight(textSize + 18)

				PanelSize = textSize + PanelSize + 22
			elseif button.type == "ItemList" then
				local buttonWidget = g_ui.createWidget('SelectionsWindowItemList', PanelSelections)
				if button.response then
					buttonWidget.onClick = function()
						g_game.talkChannel(MessageModes.NpcTo, 0, button.response)
						print(button.response)
					end
				end

				for i, item in ipairs(button.items) do
					local slot = g_ui.createWidget('itemForList', buttonWidget.panel)
					slot.item:setItemId(item.id)
					slot.item:setItemCount(item.count)
					slot.count:setText("x" .. item.count)
					slot.tooltip:setTooltip(item.name)
				end

				-- doSetColoredColor(buttonWidget.title, tr(button.title), "#ffffff")
				local coloredText = parseColoredText(tr(button.title))
				buttonWidget.title:setColoredText(coloredText)
				-- buttonWidget.title:setText(tr(button.title))
				PanelSize = PanelSize + 79
			elseif button.type == "PokeList" then
				local buttonWidget = g_ui.createWidget('SelectionsWindowPokeList', PanelSelections)

				if button.response then
					buttonWidget.onClick = function()
						g_game.talkChannel(MessageModes.NpcTo, 0, button.response)
						print(button.response)
					end
				end
				for i, pokemon in ipairs(button.pokes) do
					local slot = g_ui.createWidget('pokeForList', buttonWidget.panel)

					local pokemonOutfit = { type = pokemon.outfit, body = 0, legs = 0, feet = 0, head = 0 }
					slot.creature:setOutfit(pokemonOutfit)
					slot.creature:setOldScaling(true)
					slot.creature:setTooltip(pokemon.name)

					slot.count:setText("x" .. pokemon.count)
				end

				-- doSetColoredColor(buttonWidget.title, tr(button.title), "#ffffff")
				local coloredText = parseColoredText(tr(button.title))
				buttonWidget.title:setColoredText(coloredText)
				-- buttonWidget.title:setText(tr(button.title))

				PanelSize = PanelSize + 89
			elseif button.type == "TextEdit" then
				local buttonWidget = g_ui.createWidget('SelectionsWindowTextEdit', PanelSelections)

				if button.response then
					buttonWidget.onClick = function()
						g_game.talkChannel(MessageModes.NpcTo, 0, button.response)
						print(button.response)
					end
				end
				buttonWidget.textEdit:setMaxLength(button.maxStg)
				buttonWidget.textEdit:setValidCharacters(button.validStg)
				buttonWidget.textEdit:setPlaceholder(button.placeHolder)
				buttonWidget:setHeight(64)

				gameInterface.unbindWalkKey("W")
				gameInterface.unbindWalkKey("D")
				gameInterface.unbindWalkKey("S")
				gameInterface.unbindWalkKey("A")

				-- doSetColoredColor(buttonWidget.title, tr(button.title), "#ffffff")
				local coloredText = parseColoredText(tr(button.title))
				buttonWidget.title:setColoredText(coloredText)
				-- buttonWidget.title:setText(tr(button.title))

				PanelSize = PanelSize + 68
			end
		end
	end

	if closeButton then
		local buttonWidget = g_ui.createWidget('SelectionsWindowClose', PanelSelections)
		buttonWidget:setId("CloseButton")
		buttonWidget:setHeight(33)

		buttonWidget.onClick = close
		PanelSize = PanelSize + 37
	end

	local action = function()
		close()
	end

	local button = PanelSelections:getChildById("CloseButton")
	if closeTime then
		doStartAcreaseForCloseWindow(button, 444, 33, closeTime, action)
	else
		button.decrease:setVisible(false)
	end

	if dialogs then
		doSetDescriptionForNpc(dialogs, 350, speedOption)
	end

	if typeCall == "HiNpc" then
		show()
	end
end

local progressCloseEvent
function doStartAcreaseForCloseWindow(self, width, height, seconds, callback)
	removeEvent(progressCloseEvent)

	local interval = 15 -- 150ms = 0.15 segundos
	local totalTicks = seconds * 1000 / interval
	local tick = 1

	local function doCheckSlide()
		local button = PanelSelections:getChildById("CloseButton")
		if not button then
			removeEvent(progressCloseEvent)
			return false
		end
		local percent = math.ceil((tick / totalTicks) * 100)

		local progresspercent = math.floor(100 * percent / 100)
		local Yhppc = math.floor(width * (1 - (progresspercent / 100)))
		local rect = { x = 0, y = 0, width = width - Yhppc + 1, height = height }
		self.decrease:setImageClip(rect)
		self.decrease:setImageRect(rect)

		tick = tick + 1
		if tick <= totalTicks then
			progressCloseEvent = scheduleEvent(doCheckSlide, interval)
		else
			callback()
			removeEvent(progressCloseEvent)
		end
	end

	progressCloseEvent = scheduleEvent(doCheckSlide, interval)
end

function updateText(description, text, speed, startTime, index)
	local currentTime = os.clock()
	if currentTime - startTime >= 1 / speed then
		local currentText = string.sub(text, 1, index)
		-- doSetColoredColor(description, currentText, "#ffffff")
		description:setText(currentText)

		-- local coloredText = parseColoredText(currentText)
		-- description:setColoredText(coloredText)

		index = index + 1
		startTime = currentTime
	end
	if index <= #text then
		currentAnimation = scheduleEvent(function()
			updateText(description, text, speed, startTime, index)
		end)
	else
		isAnimating = false
		currentAnimation = nil
	end
end

function doSetDescriptionForNpc(text, delay, speed)
	if isAnimating then
		if currentAnimation then
			currentAnimation:cancel()
		end
	else
		isAnimating = true
	end
	local textSize = calculateDialogHeight(text) + 20
	description:setHeight(textSize)
	PanelDialog:setHeight(textSize)

	mainPanel:setHeight(30 + textSize)

	local MainWindowSize = 55 + textSize + PanelSize

	NpcWindow:setHeight(MainWindowSize)
	PanelSelections:setHeight(PanelSize)

	currentAnimation = scheduleEvent(function()
		updateText(description, text, speed, os.clock(), 1)
	end, delay)
end

function calculateDialogHeight(text)
	local maxCharsPerLine = 70
	local lineHeight = 16
	local numLines = math.ceil(string.len(text) / maxCharsPerLine)
	local height = numLines * lineHeight

	return height
end

function countLetters(text)
	local letterCount = 0
	for i = 1, #text do
		local c = string.sub(text, i, i)
		if c ~= " " then -- conta apenas letras (ignora espaços em branco)
			letterCount = letterCount + 1
		end
	end
	return letterCount * 9
end

function show()
	NpcWindow:show()
	g_effects.fadeIn(NpcWindow, 350)
end

function close()
	if NpcWindow:isVisible() then
		g_effects.fadeOut(NpcWindow, 350)
		scheduleEvent(function()
			NpcWindow:hide()
			description:clearText()
			PanelSelections:destroyChildren()
		end, 400)

		removeEvent(progressCloseEvent)

		gameInterface.bindWalkKey("W", North)
		gameInterface.bindWalkKey("D", East)
		gameInterface.bindWalkKey("S", South)
		gameInterface.bindWalkKey("A", West)
	end
end

function terminate()
	ProtocolGame.unregisterExtendedOpcode(OPCODE_NPC)
	NpcWindow:destroy()
	disconnect(g_game, { onGameEnd = function() NpcWindow:hide() end })

	removeEvent(progressCloseEvent)
end

function removeShinyAndMega(nomePokemon)
	local isShiny = false
	local isMega = false

	local getShiny = string.match(nomePokemon, "^[Ss]hiny ")
	if getShiny then
		nomePokemon = string.sub(nomePokemon, #getShiny + 1)
		isShiny = true
	end
	local getMega = string.match(nomePokemon, "^[Mm]ega ")
	if getMega then
		nomePokemon = string.sub(nomePokemon, #getMega + 1)
		isMega = true
	end

	nomePokemon = string.upper(string.sub(nomePokemon, 1, 1)) .. string.sub(nomePokemon, 2)
	return nomePokemon, isShiny, isMega
end


function parseColoredText(input)
	local result = {}
	local pattern = "<color=([#%w]+)>(.-)<color/>"
	local lastEnd = 1
  
	for color, text, start in input:gmatch(pattern) do
		start = input:find("<color=", lastEnd)
  
		if start > lastEnd then
			local precedingText = input:sub(lastEnd, start - 1):gsub("^%s+", "")
			if precedingText ~= "" then
				table.insert(result, precedingText)
				table.insert(result, "#ffffff")
			end
		end
  
		table.insert(result, text)
		table.insert(result, color)
  
		lastEnd = start + #text + #color + 17
	end
  
	if lastEnd <= #input then
		local remainingText = input:sub(lastEnd):gsub("^%s+", "")
		if remainingText ~= "" then
			table.insert(result, remainingText)
			table.insert(result, "#ffffff")
		end
	end
  
	return result
  end