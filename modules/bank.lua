local mainWindow, createdWindow = nil
local opcode = 75
local currentTime = os.time()

function init()
	mainWindow = g_ui.loadUI("bank", modules.game_interface.getRootPanel())
	ProtocolGame.registerExtendedOpcode(opcode, receiveOpcode)
	mainWindow:hide()
end

function terminate()
	mainWindow:hide()
    mainWindow:destroy()
	ProtocolGame.unregisterExtendedOpcode(opcode, receiveOpcode)
end

function toggle()
	if mainWindow:isVisible() then
		mainWindow:hide()
	else
		if os.time() > currentTime + 1 then
			currentTime = os.time()
			g_game.getProtocolGame():sendExtendedOpcode(opcode, "require")
		end
		mainWindow:show()
	end
end

local function createWindow(id, bufferType)
    if createdWindow then
        createdWindow:destroy()
        createdWindow = nil
    end
    createdWindow = g_ui.createWidget("WriteWindow", modules.game_interface.getRootPanel())
	createdWindow.buttonClose.onClick = function()
		if createdWindow then
			createdWindow:destroy()
			createdWindow = nil
		end
	end

	createdWindow.buttonOk.onClick = function()
		if #createdWindow.text:getText() == 0 then
			if createdWindow then
				createdWindow:destroy()
				createdWindow = nil
			end
		end
		local value = createdWindow.text:getText()
		value = tonumber(value)
		if type(value) == "number" and value == value then
			sendBuffer(id, bufferType, value)
		end
		if createdWindow then
			createdWindow:destroy()
			createdWindow = nil
		end
	end
end

function receiveOpcode(protocol, opcode, buffer)
	local data = json.decode(buffer)
	local panel = mainWindow.panelCurrencies
	panel:destroyChildren()

	for currencyName, value in pairs(data) do
		local widget = g_ui.createWidget('childCurrency', panel)
		widget.childItem:setItemId(value.itemId)
		widget.childItem:setVirtual(true)

		if value.itemId ~= 3031 then
			widget.childItem:setItemCount(value.quantidade)
		end

		if value.itemId == 3031 then
			widget.quantidade:setTooltip("Quantidade total : " .. convertNumberToString(tonumber(value.quantidade)))
		else
			widget.quantidade:setTooltip("Quantidade total : " .. tostring(value.quantidade))
		end

		widget.buttonWithdraw.onClick = function()
			createWindow(currencyName, "withdraw")
		end

		widget.buttonDeposit.onClick = function()
			createWindow(currencyName, "deposit")
		end
	end
end

function sendBuffer(id, bufferType, value)
    if createdWindow then
        createdWindow:destroy()
        createdWindow = nil
    end
    local buffer = {
        type = bufferType, 
		id = id,
		value = value
		--[[
			type = withdraw / deposit
			id = currencyId
			value = value
		]]
    }
    g_game.getProtocolGame():sendExtendedOpcode(opcode, json.encode(buffer))
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