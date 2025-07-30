local mainWindow, cachedData, buttonShop, CATEGORY_FOCUSED, createdWindow, itemPrice = nil
local quantidade_items = 1
local searchCurrency = 0
local acceptWindow = {}

local loaded = false

local OPCODE = 87

function init()
  mainWindow = g_ui.loadUI("game_shop", modules.game_interface.getRootPanel())
  categoryPanel = mainWindow.panelCategorias
  categoryVerticalPanel = mainWindow.verticalPanel
  -- categoryHorizontalPanel = mainWindow.horizontalPanel
  ProtocolGame.registerExtendedOpcode(OPCODE, receiveOpcode)
  buttonShop = modules.client_topmenu.addRightGameToggleButton("buttonShop", tr("Loja"), "/images/topbuttons/diamond", toggleShop, true)
  mainWindow:hide()
  connect(g_game, { onGameStart = function()  mainWindow:hide() end, onGameEnd = function()  mainWindow:hide() end} )
end

function terminate()
	mainWindow:hide()
    mainWindow:destroy()
	ProtocolGame.unregisterExtendedOpcode(OPCODE, receiveOpcode)
    if buttonShop then
        buttonShop:destroy()
        buttonShop = nil
    end
	disconnect(g_game, { onGameStart = function()  mainWindow:hide() end, onGameEnd = function()  mainWindow:hide() end} )
end

function receiveOpcode(protocol, opcode, data)
    local data = json.decode(data)
    cachedData = data
    loaded = true
    generateShop()
end

function showVertical()
    hideClube()
    categoryVerticalPanel:setVisible(true)
    mainWindow.verticalBar:setVisible(true)

    -- categoryHorizontalPanel:setVisible(false)
    -- mainWindow.horiBar:setVisible(false)
end

function showHorizontal()
    hideClube()
    categoryVerticalPanel:setVisible(false)
    mainWindow.verticalBar:setVisible(false)

    -- categoryHorizontalPanel:setVisible(true)
    -- mainWindow.horiBar:setVisible(true)
end

function hideBoth()
    hideClube()
    -- categoryHorizontalPanel:setVisible(false)
    -- mainWindow.horiBar:setVisible(false)

    categoryVerticalPanel:setVisible(false)
    mainWindow.verticalBar:setVisible(false)
end

function showClube()
    hideBoth()
    mainWindow.vipImage:setVisible(true)
    mainWindow.clubBeneficiosTopText:setVisible(true)
    mainWindow.verticalTextBar:setVisible(true)
    mainWindow.backgroundClubText:setVisible(true)
    mainWindow.VIP_BUY:setVisible(true)
    mainWindow.vip_info:setVisible(true)
    mainWindow.searchTextEdit:setVisible(false)
    mainWindow.searchImage:setVisible(false)
    mainWindow.typeMoeda:setVisible(false)
    mainWindow.typeItem:setVisible(false)

end

function hideClube()
    mainWindow.vipImage:setVisible(false)
    mainWindow.clubBeneficiosTopText:setVisible(false)
    mainWindow.verticalTextBar:setVisible(false)
    mainWindow.backgroundClubText:setVisible(false)
    mainWindow.VIP_BUY:setVisible(false)
    mainWindow.vip_info:setVisible(false)
    mainWindow.searchTextEdit:setVisible(true)
    mainWindow.searchImage:setVisible(true)
    mainWindow.typeMoeda:setVisible(true)
    mainWindow.typeItem:setVisible(true)
end


function generateShop()
    categoryPanel:destroyChildren()
    local categories = cachedData.CATEGORY
    local categoriesOrdem = cachedData.ORDEM
    local categoriesInfo = cachedData.CATEGORYINFO
    CATEGORY_FOCUSED = categoriesOrdem[1]

    for id, category in pairs(categoriesOrdem) do
        local widget = g_ui.createWidget("baseCategoria", categoryPanel)
        widget:setId(category)
        widget.onClick = function() generateShopCategory(category) end
        local infos = categoriesInfo[category]
        widget:setIcon(infos.icon)
        widget:setIconSize(infos.size)
        widget:setIconOffsetX(infos.iconOffet.x)
        widget:setIconOffsetY(infos.iconOffet.y)
        widget:setText(category)
    end
    generateShopCategory(CATEGORY_FOCUSED)
end

function generateShopCategory(categoryName)
    CATEGORY_FOCUSED = categoryName
    mainWindow.searchTextEdit:clearText()
    mainWindow.typeMoeda:setText("Moeda: Todas") 
    categoryVerticalPanel:destroyChildren()

    mainWindow.typeMoeda.onMouseRelease = function(widget, mousePos, mouseButton)
		if mouseButton == MouseRightButton or mouseButton == MouseLeftButton then
			local menu = g_ui.createWidget("PopupMenu")
			menu:setGameMenu(true)
			
			menu:addOption("Todas", function() mainWindow.typeMoeda:setText("Moeda: Todas") onSearchCurrency(0) end)
			menu:addOption("Small Diamond", function() mainWindow.typeMoeda:setText("Moeda: SD") onSearchCurrency(3028) end)
			menu:addOption("Black Diamond", function() mainWindow.typeMoeda:setText("Moeda: BD") onSearchCurrency(11304) end)
			menu:addOption("Space Coin",    function() mainWindow.typeMoeda:setText("Moeda: Space") onSearchCurrency(22298) end)
			menu:addOption("Torneio Coin",    function() mainWindow.typeMoeda:setText("Moeda: Torneio") onSearchCurrency(22300) end)
			menu:addOption("Online Coin",    function() mainWindow.typeMoeda:setText("Moeda: Online") onSearchCurrency(22297) end)
			menu:addOption("Reset Coin",    function() mainWindow.typeMoeda:setText("Moeda: Reset") onSearchCurrency(22296) end)

            menu:display(pos)
			return
		end
	end

    local list = cachedData.CATEGORY[categoryName]
    if not list then return error("Category " .. categoryName .. " doesnt exists") end
    for id, itemInfo in ipairs(list) do
        local type = itemInfo.type
        if categoryName == "ASSINATURA" and type == "clube" then
            showClube()
            mainWindow.vip_info:setTooltip(itemInfo.info)
            local textBox = mainWindow.backgroundClubText.text
            textBox:setText(itemInfo.beneficios)
            textBox:setSize('170 ' .. #itemInfo.beneficios + 100)
            return
        end

        local style = cachedData.STYLES[type]
        local widget = g_ui.createWidget(style, categoryVerticalPanel)
        widget:setId(id)
        widget:setImageSource("assets/backgrounds/" .. itemInfo.backgroundImage)
        widget.preco:setText(itemInfo.valor)
        widget.icon_currency:setItemId(itemInfo.moeda)
        widget.icon_currency:setVirtual(true)
        if type == "item" then
            showVertical()
            widget.item:setItemId(itemInfo.item.id)
            widget.item:setMarginLeft(itemInfo .offset.x)
            widget.item:setMarginTop(itemInfo.offset.y)
            widget.item:setSize(itemInfo.size)
            widget.item:setItemCount(itemInfo.item.qtd)
            widget.item:setVirtual(true)
            local itemName = itemInfo.item.name
            widget.tooltipName:setTooltip(itemName)
            if #itemName > 9 then
                itemName = string.sub(itemName, 1, 9) .. ".."
            end
            widget.name:setText(itemName)
        elseif type == "outfit" then
            showVertical()
            widget.outfit:setOutfit(itemInfo.lookType)
            widget.outfit:setMarginLeft(itemInfo.offset.x)
            widget.outfit:setMarginTop(itemInfo.offset.y)
            widget.outfit:setOldScaling(true)
            widget.outfit:setSize(itemInfo.size)
			if itemInfo.animated == true then
				widget.outfit:setAnimate(true)
			end
            local itemName = itemInfo.name
            widget.tooltipName:setTooltip(itemName)
            if #itemName > 13 then
                itemName = string.sub(itemName, 1, 13) .. ".."
            end
            widget.name:setText(itemName)
        elseif type == "pokemon" then
            showVertical()
            widget.outfit:setOutfit(itemInfo.lookType)
            widget.outfit:setMarginLeft(itemInfo.offset.x)
            widget.outfit:setMarginTop(itemInfo.offset.y)
            widget.outfit:setOldScaling(true)
            widget.outfit:setSize(itemInfo.size)
			if not itemInfo.rank then itemInfo.rank = "A" end
			widget.iconRank:setImageSource("/images/customIcons/" .. itemInfo.rank .. "special")
			widget.iconRank:setMarginBottom(widget.iconRank:getHeight() * 1.5)
			widget.iconRank:setMarginRight(widget.iconRank:getWidth() / 2)
            local pokeName = itemInfo.pokeName
            widget.tooltipName:setTooltip(pokeName)
            if #pokeName > 13 then
                pokeName = string.sub(pokeName, 1, 13) .. ".."
            end
            widget.name:setText(pokeName)
        else
            hideBoth()
        end
    end
end

function toggleShop()
    if not loaded then
        modules.game_request.sendRequest("shop")
    end
    if mainWindow:isVisible() then
        mainWindow:hide()
    else
        mainWindow:show()
    end
end

function sendBuffer(id)
    local cancelFunc = function()
      acceptWindow[#acceptWindow]:destroy()
      acceptWindow = {}
    end

    local acceptFunc = function()
      acceptWindow[#acceptWindow]:destroy()
      acceptWindow = {}
      sendBuyAttempt(CATEGORY_FOCUSED, id)
    end
	
    if #acceptWindow > 0 then
      acceptWindow[#acceptWindow]:destroy()
    end
	local text = "Você deseja comprar?"
	acceptWindow[#acceptWindow + 1] =
		displayGeneralBox("CONFIRMAR", text,
		{
			{text = tr("Buy"), callback = acceptFunc},
            {text = tr("Cancel"), callback = cancelFunc},
       anchor = AnchorHorizontalCenter
		}, acceptFunc, cancelFunc)
end

function onSearch()
    local searchWidget = mainWindow.searchTextEdit
    local text = searchWidget:getText()
    if text:len() >= 1 then
      local children = categoryVerticalPanel:getChildCount()
      for i = 1, children do
        local child = categoryVerticalPanel:getChildByIndex(i)
        local offerName = child.tooltipName:getTooltip():lower()
        if offerName:find(text:lower()) and (searchCurrency == 0 or child.icon_currency:getItemId() == searchCurrency) then
          child:show()
        else
          child:hide()
        end
      end
    else
      local children = categoryVerticalPanel:getChildCount()
      for i = 1, children do
        local child = categoryVerticalPanel:getChildByIndex(i)
        if searchCurrency == 0 or child.icon_currency:getItemId() == searchCurrency then
          child:show()
        else
          child:hide()
        end
      end
    end
end


function onSearchCurrency(ID)
    searchCurrency = ID
    if ID > 0 then
      local children = categoryVerticalPanel:getChildCount()
      for i = 1, children do
        local child = categoryVerticalPanel:getChildByIndex(i)
        local offer = child.icon_currency:getItemId()
        if offer == ID then
          child:show()
        else
          child:hide()
        end
      end
    else
      local children = categoryVerticalPanel:getChildCount()
      for i = 1, children do
        local child = categoryVerticalPanel:getChildByIndex(i)
        child:show()
      end
    end
    onSearch()
end


function sendBuyAttempt(category, id)
    if createdWindow then
        createdWindow:destroy()
        createdWindow = nil
    end
    local buffer = {
        type = "buy",
        info = {
            category = category,
            id = id,
			quantity = quantidade_items or 1
        }
    }
    g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode(buffer))
end

function createWindow(id, widget)
    quantidade_items = 1
    if createdWindow then
        createdWindow:destroy()
        createdWindow = nil
    end
    createdWindow = g_ui.createWidget("quantityWindow", modules.game_interface.getRootPanel())
    createdWindow.quantidadeLabel:setText(quantidade_items .. " x")
    createdWindow.quantidadeBuy:setValue(quantidade_items)
	itemPrice = tonumber(widget.preco:getText())
	createdWindow.precoItem:setText("Preco:" .. itemPrice)
	createdWindow.buyButton.onClick = function()
		sendBuyAttempt(CATEGORY_FOCUSED, id)
	end

	createdWindow.plusButton.onClick = function()
		if quantidade_items < 10000 then
			changeQuantidade(quantidade_items + 1)
			createdWindow.quantidadeBuy:setValue(quantidade_items)
		end
	end
	
	createdWindow.minusButton.onClick = function()
		if quantidade_items > 1 then
			changeQuantidade(quantidade_items - 1)
			createdWindow.quantidadeBuy:setValue(quantidade_items)
		end
	end	
	
    createdWindow:show()
    createdWindow:focus()
    createdWindow:raise()
end


function destroyWindow()
    if createdWindow then
        createdWindow:destroy()
        createdWindow = nil
        quantidade_items = 1
    end
end

function changeQuantidade(value)
    quantidade_items = value
	local newItemPrice = itemPrice * quantidade_items
    createdWindow.quantidadeLabel:setText(value .. " x")
	createdWindow.precoItem:setText("Preco:" .. newItemPrice)
end