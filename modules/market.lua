local mainWindow, buyWindow = nil, nil
local opcode = 94
local cache = {}
local page = 1
local pageSearch = { busca = "", categoria = 0, page = 1 }
local totalPages = 0
local realTime = 0
local currentCategory = 0
local mouseGrabberWidget = nil
local aba = 1
local MARKET_ITEM_SELECTED = {
	currency = nil,
	price = nil,
	selected = false,
	anonymous = false,
	qtd = 1,
	maxQtd = 1,
}

local timer = { minute = 60, hour = 3600, day = 86400, week = 604800 }
local itemDuration = timer.day * 2

local STYLE_ABAS = {
	[1] = "MarketRowItem",
	[2] = "MarketRowOwnItem",
}

local MAX_ROWS_ABAS = {
	[1] = 10,
	[2] = 10
}

local MARKET_CATEGORIES = {
	[0] = 'All',
	[1] = 'Helds',
	[2] = 'Potions',
	[3] = 'Pokeballs',
	[4] = 'Pokemon',
	[5] = 'Valuable Item'
}

-- change pages by category [buy, sell...]

function generatePageBuyChildren(page_id)
	local PANEL_ABAS = {
		[1] = mainWindow.panelOffers,
		[2] = mainWindow.panelOwnOffers
	}

	local MAX_ROWS = MAX_ROWS_ABAS[aba]

	local painel = PANEL_ABAS[aba]
	painel:destroyChildren()

	local startIndex
	local lastIndex

	for id = 1, MAX_ROWS do
		local MarketItem = cache[id]
		if not MarketItem then break end
		local widget = g_ui.createWidget(STYLE_ABAS[aba], painel)
		widget:setId(MarketItem.id)
		local isOdd = id % 2 == 0
		if isOdd then
			widget:setBackgroundColor('#252121')
		else
			widget:setBackgroundColor('#1f1f1f')
		end
		local isCurrencyMoney = MarketItem.currency == 0
		widget.number:setText(id)
		widget.item:setItemId(MarketItem.itemClientId)
		widget.item.pokeballsInfo = MarketItem.pokeballAttributes
		widget.name:setText(capitalizeFirstLetter(MarketItem.itemName))
		widget.realName = capitalizeFirstLetter(MarketItem.itemName)
		widget.amount:setText(MarketItem.amount)
		widget.amountReal = MarketItem.amount

		if aba == 1 then
			widget.seller:setText(MarketItem.playerName)
		end
		if aba == 2 then
			local remainingTime = MarketItem.created + itemDuration - realTime
			if MarketItem.expired == 0 or remainingTime > 1 then
				local tempo = convertTime(remainingTime)
				widget.time:setText(tempo)
				widget.remainingTime = remainingTime
				local function scheduleFunc(widget)
					if widget and widget.remainingTime then
						widget.remainingTime = widget.remainingTime - 1
						if widget.remainingTime <= 0 then
							widget.time:setText("Expirou")
							widget.scheduler = nil
							return
						end
						widget.time:setText(convertTime(widget.remainingTime))
						scheduleEvent(function() scheduleFunc(widget) end, 1000)
					end
				end
				widget.scheduler = scheduleFunc(widget)
			elseif MarketItem.expired == 1 or remainingTime < 1 then
				widget.time:setText("Expirou")
			end
		end
		

		if isCurrencyMoney then
			widget.price:setText(convertNumberToStringMarket(MarketItem.price))
			widget.currencyItem:setItemId(3043)
		else
			widget.price:setText(MarketItem.price)
			widget.currencyItem:setItemId(25218)
		end
		widget.realPrice = MarketItem.price

		if MarketItem.pokeballAttributes then
			widget.name:setText(MarketItem.pokeballAttributes.name)
		end
	end
end

local function updatePage(direction)
	local text = mainWindow.marketSearch:getText()

	if (direction == 1 and page >= totalPages) or (direction == -1 and page <= 1) then return end
	page = page + direction

	if text ~= "" or currentCategory ~= 0 then
		sendMarketBuffer(json.encode({
			type = "search",
			text = text,
			category = currentCategory,
			page = page,
			aba = aba
		}))
		return
	end

	sendMarketBuffer(json.encode({type = "loadPage", page = page, aba = aba}))
end

local eventList = {}

function addFuncToList(func)
	table.insert(eventList, func)
end

function clearEventList()
	eventList = {}
end

function checkEventList()
	local event = eventList[1]
	if event then
		event()
		table.remove(eventList, 1)
	end
	scheduleEvent(checkEventList, 200)
end

function nextPage()
	addFuncToList(function() updatePage(1) end)
end

function previousPage()
	addFuncToList(function() updatePage(-1) end)
end

function firstPage()
	clearEventList()
	addFuncToList(
	function()
		page = 1
		updatePage(0)
	end)
end

function lastPage()
	clearEventList()
	addFuncToList(function()
		page = totalPages
		updatePage(0)
	end)
end

function init()
	mainWindow = g_ui.loadUI("market", modules.game_interface.getRootPanel())
	mainWindow:hide()
	ProtocolGame.registerExtendedJSONOpcode(opcode, receiveOpcode)
	if modules.game_request then
		requestData()
	end
	panelItems = mainWindow.panelOffers
	panelOwnItems = mainWindow.panelOwnOffers

	configureButtons()
	connect(g_game, { onGameEnd = function()  mainWindow:hide() end, onGameStart = requestData})
	connect(LocalPlayer, {onPositionChange = onPositionChange})
	checkEventList()
end

function requestData()
	mainWindow.panelSellItem.boxCheckBox.diamondItem:setItemId(25218)
	mainWindow.panelSellItem.boxCheckBox.moneyItem:setItemId(25220)
end

function terminate()
    mainWindow:destroy()
	ProtocolGame.unregisterExtendedJSONOpcode(opcode, receiveOpcode)
    disconnect(g_game, { onGameEnd = function()  mainWindow:hide() end, onGameStart = requestData})
	disconnect(LocalPlayer, {onPositionChange = onPositionChange})
end

function onPositionChange()
	mainWindow:hide()
end

function toggle()
	if buyWindow then
		buyWindow:destroy()
	end
	if mainWindow:isVisible() then
		mainWindow:hide()
		modules.game_walking.enableWSAD()

	else
		mainWindow:show()
		modules.game_walking.disableWSAD()
	end
end

function sendMarketBuffer(buffer)
	local protocol = g_game.getProtocolGame()
	protocol:sendExtendedOpcode(opcode, buffer)
end

local updateTimeEvent = nil
local function updateRealTime()
	realTime = realTime + 1
	scheduleEvent(updateRealTime, 1000)
end

function receiveOpcode(protocol, opcode, buffer)
	local data = buffer.data
	local action = data.type
	if not action then
		return
	end
	if action == "loadPage" then
		if data.subType and data.subType == "loadedBySearch" then
			local receivePage = data.page
			local receivedCategory = data.category
			local text = data.text
			if pageSearch.busca ~= text or receivePage ~= page or receivedCategory ~= category then
				pageSearch.page = receivePage
			else
				pageSearch.page = 1
			end
			page = pageSearch.page
		else
			local receivePage = data.page
			if receivePage ~= 0 then
				page = receivePage
			end
			pageSearch = {busca = "", categoria = 0, page = 1}
		end

		local receivedData = data.MARKET_DATA
		configureCategories()
		if aba == 1 then
			cache = reverseArray(receivedData)
		else
			cache = receivedData
		end

		generatePageBuyChildren(page)
		removeEvent(updateTimeEvent)
		updateTimeEvent = nil
		realTime = data.realTime
		updateTimeEvent = scheduleEvent(updateRealTime, 1000)

		local size = data.abaSize

		totalPages = math.max(1, math.ceil(size / MAX_ROWS_ABAS[aba]))
		mainWindow.pages:setText(string.format("%d/%d", page, totalPages))
		return
	elseif action == "notify_item" then
		MARKET_ITEM_SELECTED.selected = true
		mainWindow.panelSellItem.itemSelected:setItemId(data.clientId)
		if data.pokeballsInfo then
			mainWindow.panelSellItem.itemSelected.pokeballsInfo = data.pokeballsInfo
		end
		MARKET_ITEM_SELECTED.maxQtd = data.maxQtd
	elseif action == "notify_success_post" then
		clearSellItemPanel()
		return
	elseif action == "toggle" then
		updateMarketCategory(0)
		mainWindow.marketSearch:clearText()
		hideAll()
		toggleOffers(true)
		toggle()
		return
	end
end

function clearSellItemPanel()
	local panel = mainWindow.panelSellItem
	panel.itemSelected:setItemId(0)
	panel.price:setText(0)
	panel.qtdItems:setText(0)
	panel.boxCheckBox.anonymous:setChecked(false)
	panel.boxCheckBox.money:setChecked(false)
	panel.boxCheckBox.diamond:setChecked(false)
	local BACKUP_MARKET_ITEM_SELECTED = {
		currency = nil,
		price = nil,
		selected = false,
		anonymous = false,
		qtd = 1,
		maxQtd = 1,
	}
	MARKET_ITEM_SELECTED = BACKUP_MARKET_ITEM_SELECTED
end

function hideAll()
	clearEventList()
	toggleOffers(false)
	toggleOwnOffers(false)
end

function toggleOffers(show)
	if show then
		mainWindow.panelOffers:show()
		mainWindow.rowHeaderOffers:show()
		mainWindow.categories:show()
		mainWindow.doSearch:show()
		mainWindow.marketSearch:show()
		mainWindow.BuyButton:show()
		mainWindow.offerButton:show()
		mainWindow.Refresh:show()
	else
		mainWindow.panelOffers:hide()
		mainWindow.rowHeaderOffers:hide()
		mainWindow.categories:hide()
		mainWindow.doSearch:hide()
		mainWindow.marketSearch:hide()
		mainWindow.BuyButton:hide()
		mainWindow.offerButton:hide()
		mainWindow.Refresh:hide()
	end
end

function toggleOwnOffers(show)
	if show then
		mainWindow.panelSellItem:show()
		mainWindow.panelOwnOffers:show()
		mainWindow.rowHeaderOwnOffers:show()
		mainWindow.cancelSell:show()
	else
		mainWindow.panelSellItem:hide()
		mainWindow.panelOwnOffers:hide()
		mainWindow.rowHeaderOwnOffers:hide()
		mainWindow.cancelSell:hide()
	end
end

function refresh()
	updateMarketCategory(0) 
	mainWindow.marketSearch:clearText() 
	sendMarketBuffer(json.encode({type = "refresh", page = 1, aba = 1}))
end

function sendSearch()
	local text = mainWindow.marketSearch:getText()

	if text == "" and currentCategory == 0 then
		return refresh()
	end

	local buffer = {
		type = "search",
		text = text,
		category = currentCategory,
		page = pageSearch.page,
		aba = aba

	}
	sendMarketBuffer(json.encode(buffer))
end

function setupGrabber()
	mouseGrabberWidget = g_ui.createWidget('UIWidget')
	mouseGrabberWidget:setVisible(false)
	mouseGrabberWidget:setFocusable(false)
	mouseGrabberWidget.onMouseRelease = onChooseItemMouseRelease
end

function configureButtons()
	if not mainWindow then return end
	hideAll()
	toggleOffers(true)
	mainWindow.Refresh.onClick = function() refresh() end
	mainWindow.mainList.onClick = function()
		aba = 1
		sendMarketBuffer(json.encode({type = "loadPage", page = 1, aba = 1}))
		hideAll()
		toggleOffers(true)
	end
	mainWindow.ownOffers.onClick = function()
		aba = 2
		hideAll()
		toggleOwnOffers(true)
		sendMarketBuffer(json.encode({type = "loadPage", page = 1, aba = 2}))
	end

	mainWindow.doSearch.onClick = function()
		sendSearch()
	end
	local panelSellItem = mainWindow.panelSellItem
	panelSellItem.select.onClick = startChooseItem

	setupGrabber()

	local checkBoxMoney = panelSellItem.boxCheckBox.money
	local checkBoxDiamond = panelSellItem.boxCheckBox.diamond

	checkBoxMoney.onCheckChange = function(widget, checked)
		if checked then
			checkBoxDiamond:setChecked(false)
			MARKET_ITEM_SELECTED.currency = 0
		else
			MARKET_ITEM_SELECTED.currency = nil
		end
	end

	checkBoxDiamond.onCheckChange = function(widget, checked)
		if checked then
			checkBoxMoney:setChecked(false)
			MARKET_ITEM_SELECTED.currency = 1
		else
			MARKET_ITEM_SELECTED.currency = nil
		end
	end

	panelSellItem.price.onTextChange = function(widget, text)
		local value = tonumber(text)
		if not value then return end
		if value < 0 then
			widget:setText(0)
		end
	end

	panelSellItem.qtdItems.onTextChange = function(widget, text)
		local value = tonumber(text)
		if not value or value < 1 then
			widget:setText(1)
			MARKET_ITEM_SELECTED.qtd = 1
			return
		end
		if value > MARKET_ITEM_SELECTED.maxQtd then
			widget:setText(MARKET_ITEM_SELECTED.maxQtd)
			MARKET_ITEM_SELECTED.qtd = MARKET_ITEM_SELECTED.maxQtd
			return
		end
		MARKET_ITEM_SELECTED.qtd = value
	end

	panelSellItem.trySellItem.onClick = function()
		if not MARKET_ITEM_SELECTED.selected or
				not MARKET_ITEM_SELECTED.currency or
					not tonumber(panelSellItem.price:getText()) or
						tonumber(panelSellItem.price:getText()) < 1 then
			return
		end

		local buffer = {
			type = "trySellItem",
			price = panelSellItem.price:getText(),
			currency = MARKET_ITEM_SELECTED.currency,
			page = page,
			qtd = MARKET_ITEM_SELECTED.qtd,
			anonymous = panelSellItem.boxCheckBox.anonymous:isChecked()
		}
		sendMarketBuffer(json.encode(buffer))
	end

	mainWindow.cancelSell.onClick = function()
		local focusedChildren = mainWindow.panelOwnOffers:getFocusedChild()
		if not focusedChildren then
			return
		end
		local buffer = {
			type = "cancelSell",
			page = page,
			offerId = focusedChildren:getId()
		}
		sendMarketBuffer(json.encode(buffer))
	end

	mainWindow.marketSearch.onTextChange = function(widget, text)
		if not text then return end
		if text == "" and currentCategory == 0 then
			sendMarketBuffer(json.encode({type = "loadPage", page = 1, aba = 1}))
			return
		end
	end

	mainWindow.BuyButton.onClick = function()
		local focusedChildren = mainWindow.panelOffers:getFocusedChild()
		if not focusedChildren then
			return
		end
		createBuyWindow(focusedChildren)
	end
end

function createBuyWindow(focusedChildren)
	if buyWindow then
		buyWindow:destroy()
	end
	buyWindow = g_ui.createWidget('BuyMarketItemWindow', mainWindow)
	connect(buyWindow, { onDestroy = function() buyWindow = nil end })
	buyWindow:raise()
	buyWindow:focus()
	buyWindow.itemName:setText(focusedChildren.realName)
	buyWindow.item:setItem(focusedChildren.item:getItem())
	buyWindow.item.pokeballsInfo = focusedChildren.item.pokeballsInfo
	buyWindow.currency:setItem(focusedChildren.currencyItem:getItem())
	local basePrice = tonumber(focusedChildren.realPrice)
	local priceToText = convertNumberToStringMarket(basePrice)
	buyWindow.price:setText("Preço: " .. priceToText)
	local maxItems = focusedChildren.amountReal
	local minItems = 1
	local selectedQtd = 1
	buyWindow.qtdItems:setText(1)

	local function onChangeQtd()
		buyWindow.qtdItems:setText(selectedQtd)
		buyWindow.item:setItemCount(selectedQtd)
		local totalPrice = basePrice * selectedQtd
		local priceToText = convertNumberToStringMarket(totalPrice)
		buyWindow.price:setText("Preço: " .. priceToText)
	end

	buyWindow.qtdItems.onTextChange = function(widget, text)
		local value = tonumber(text)
		if not value then
			return
		end
		if value < minItems then
			widget:setText(minItems)
			selectedQtd = minItems
			onChangeQtd()
			return
		end
		if value > maxItems then
			widget:setText(maxItems)
			selectedQtd = maxItems
			onChangeQtd()
			return
		end
		selectedQtd = value
		onChangeQtd()
	end

	buyWindow.BuyButton.onClick = function ()
		local buffer = {
			type = "tryBuyItem",
			offerId = focusedChildren:getId(),
			page = page,
			amount = selectedQtd
		}
		sendMarketBuffer(json.encode(buffer))
		buyWindow:destroy()
	end

end

function onChooseItemMouseRelease(self, mousePosition, mouseButton)
	local item = nil
	if mouseButton == MouseLeftButton then
	  local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
	  if clickedWidget then
		if clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
		  item = clickedWidget:getItem()
		end
	  end
	end

	if not item then
		g_mouse.popCursor('target')
		self:ungrabMouse()
		toggle()
		return true
	end

	local buffer = {
		itemData = {
			position = item:getPosition(),
			clientId = item:getId(),
			stackpos = item:getStackPos(),
		},
		type = "checkSelectedItem"
	}

	sendMarketBuffer(json.encode(buffer))

	g_mouse.popCursor('target')
	self:ungrabMouse()
	toggle()
	return true
end

function startChooseItem()
	if not mouseGrabberWidget then
		setupGrabber()
	end
	if g_ui.isMouseGrabbed() then return end
	mouseGrabberWidget:grabMouse()
	g_mouse.pushCursor('target')
	toggle()
end

function configureCategories()
	local widget = mainWindow.categories
    widget.onMouseRelease = function(widget, mousePos, mouseButton)
		if mouseButton == MouseRightButton or mouseButton == MouseLeftButton then
			local menu = g_ui.createWidget("PopupMenu")
			menu:setGameMenu(true)
			menu:addOption("All", function() updateMarketCategory(0) end)

			for id, cat in ipairs(MARKET_CATEGORIES) do
				menu:addOption(cat, function() updateMarketCategory(id) end)
			end

            menu:display(pos)
			return
		end
	end
end

function updateMarketCategory(catId)
	local cat = MARKET_CATEGORIES[catId]
	local widget = mainWindow.categories
	widget:setText(cat)
	currentCategory = catId
end

function capitalizeFirstLetter(word)
	word = string.lower(word)
    return word:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
end

function convertNumberToStringMarket(number)
	local suffixes = {"", "k", "kk", "kkk", "kkkk", "kkkkk", "kkkkkk", "kkkkkkk"}
	local suffixIndex = 1

	while number >= 1000 do
		number = number / 1000
		suffixIndex = suffixIndex + 1
	end

	return string.format("%d%s", number, suffixes[suffixIndex])
end

function convertTime(seconds)
	local seconds = tonumber(seconds)
	if not seconds or seconds <= 0 then
	  return "00:00:00";
	else
	  hours = string.format("%02.f", math.floor(seconds/3600));
	  mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
	  secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
	  return hours..":"..mins..":"..secs
	end
  end

function reverseArray(arr)
    local reversed = {}
    for i = #arr, 1, -1 do
        table.insert(reversed, arr[i])
    end
    return reversed
end
