-- @docclass
g_tooltip = {}
g_advancedTooltip = {}

-- private variables
local toolTipLabel
local advancedTooltipWindow
local advancedTooltipPokemon
local advancedTooltipPokemonMarket
local currentHoveredWidget
local currentAdvancedHoveredWidget
local evoEvent = nil
local evoCode = 0
local itemsAdvancedTooltip = true

-- private functions
local function moveToolTip(first)
	if not first and (not toolTipLabel:isVisible() or toolTipLabel:getOpacity() < 0.1) then return end

	local pos = g_window.getMousePosition()
	local windowSize = g_window.getSize()
	local labelSize = toolTipLabel:getSize()

	pos.x = pos.x + 1
	pos.y = pos.y + 1

	if windowSize.width - (pos.x + labelSize.width) < 10 then
		pos.x = pos.x - labelSize.width - 3
	else
		pos.x = pos.x + 10
	end

	if windowSize.height - (pos.y + labelSize.height) < 10 then
		pos.y = pos.y - labelSize.height - 3
	else
		pos.y = pos.y + 10
	end

	toolTipLabel:setPosition(pos)
end

local function advancedMoveToolTip(first)
	if not first and (not advancedTooltipWindow:isVisible() or advancedTooltipWindow:getOpacity() < 0.1) then return end
	local pos = g_window.getMousePosition()
	pos.x = g_window.getSize().width / 2 < pos.x and pos.x - advancedTooltipWindow:getWidth() - 5 or pos.x + 5
	pos.y = g_window.getSize().height / 2 < pos.y and pos.y - advancedTooltipWindow:getHeight() - 5 or pos.y + 5
	advancedTooltipWindow:setPosition(pos)
end

local function advancedMovePokeToolTip(first)
	if not first and (not advancedTooltipPokemon:isVisible() or advancedTooltipPokemon:getOpacity() < 0.1) then return end
	local pos = g_window.getMousePosition()
	pos.x = g_window.getSize().width / 2 < pos.x and pos.x - advancedTooltipPokemon:getWidth() - 5 or pos.x + 5
	pos.y = g_window.getSize().height / 2 < pos.y and pos.y - advancedTooltipPokemon:getHeight() - 5 or pos.y + 5
	advancedTooltipPokemon:setPosition(pos)
end

local function advancedMoveMarketToolTip(first)
	if not first and (not advancedTooltipPokemonMarket:isVisible() or advancedTooltipPokemonMarket:getOpacity() < 0.1) then return end
	local pos = g_window.getMousePosition()
	pos.x = g_window.getSize().width / 2 < pos.x and pos.x - advancedTooltipPokemonMarket:getWidth() - 5 or pos.x + 5
	pos.y = g_window.getSize().height / 2 < pos.y and pos.y - advancedTooltipPokemonMarket:getHeight() - 5 or pos.y + 5
	advancedTooltipPokemonMarket:setPosition(pos)
end

local function onWidgetHoverChange(widget, hovered)
	if hovered then
		if currentHoveredWidget ~= widget and widget.tooltip and not g_mouse.isPressed(MouseLeftButton) then
			currentHoveredWidget = widget
			g_tooltip.display(widget.tooltip)
		end
		if currentAdvancedHoveredWidget ~= widget and widget.advancedTooltip and not g_mouse.isPressed(MouseLeftButton) then
			currentAdvancedHoveredWidget = widget
			g_advancedTooltip.display()
		end
	else
		if widget == currentHoveredWidget then
			g_tooltip.hide()
			currentHoveredWidget = nil
		end
		if widget == currentAdvancedHoveredWidget then
			g_advancedTooltip.hide()
			currentAdvancedHoveredWidget = nil
		end
	end
end

function onItemHoverChange(item, hovered)
	onWidgetHoverChange(item, hovered)
end

function onButtonHoverChange(button, hovered)
	onWidgetHoverChange(button, hovered)
end

local function onWidgetStyleApply(widget, styleName, styleNode)
	if styleNode.tooltip then
		widget.tooltip = styleNode.tooltip
	end
end

-- public functions
function g_tooltip.init()
	connect(g_game, { changeHoverItem = onChangeHoverItem })
	connect(UIWidget, {
		onStyleApply = onWidgetStyleApply,
		onHoverChange = onWidgetHoverChange
	})
	addEvent(function()
		toolTipLabel = g_ui.createWidget('UILabel', rootWidget)
		toolTipLabel:setId('toolTip')
		toolTipLabel:setBackgroundColor('#111111cc')
		toolTipLabel:setTextAlign(AlignCenter)
		toolTipLabel:hide()
		toolTipLabel.onMouseMove = function() moveToolTip() end
	end)
end

function onChangeHoverItem(item, code)

end

function g_advancedTooltip.init()
	addEvent(function()
		advancedTooltipWindow = g_ui.createWidget('TooltipMainWindow', rootWidget)
		advancedTooltipWindow:setId('MainWindow')
		advancedTooltipWindow:setFocusable(false)
		advancedTooltipWindow:hide()
		advancedTooltipWindow.onMouseMove = function() advancedMoveToolTip() end

		advancedTooltipPokemon = g_ui.createWidget('TooltipPokeWindow', rootWidget)
		advancedTooltipPokemon:setId('MainWindow')
		advancedTooltipPokemon:setFocusable(false)
		advancedTooltipPokemon:hide()
		advancedTooltipPokemon.onMouseMove = function() advancedMovePokeToolTip() end

		advancedTooltipPokemonMarket = g_ui.createWidget('TooltipPokeMarket', rootWidget)
		advancedTooltipPokemonMarket:setId('MainWindow')
		advancedTooltipPokemonMarket:setFocusable(false)
		advancedTooltipPokemonMarket:hide()
		advancedTooltipPokemonMarket.onMouseMove = function() advancedMoveMarketToolTip() end
	end)
end

function g_tooltip.terminate()
	disconnect(g_game, { changeHoverItem = onChangeHoverItem })
	disconnect(UIWidget, {
		onStyleApply = onWidgetStyleApply,
		onHoverChange = onWidgetHoverChange
	})

	currentHoveredWidget = nil
	toolTipLabel:destroy()
	toolTipLabel = nil

	g_tooltip = nil
end

function g_advancedTooltip.terminate()
	currentAdvancedHoveredWidget = nil
	advancedTooltipWindow:destroy()
	advancedTooltipWindow = nil
	advancedTooltipPokemon:destroy()
	advancedTooltipPokemon = nil
	advancedTooltipPokemonMarket:destroy()
	advancedTooltipPokemonMarket= nil
	g_advancedTooltip = nil
end

function tooltipsTerminate()
	g_tooltip.terminate()
	g_advancedTooltip.terminate()
end

function g_tooltip.display(text)
	if text == nil or text:len() == 0 then return end
	if not toolTipLabel then return end

	toolTipLabel:setText(text)
	toolTipLabel:resizeToText()
	toolTipLabel:resize(toolTipLabel:getWidth() + 4, toolTipLabel:getHeight() + 4)
	toolTipLabel:show()
	toolTipLabel:raise()
	toolTipLabel:enable()
	g_effects.fadeIn(toolTipLabel, 100)
	moveToolTip(true)
end

function capitalize(str)
	return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2))
end

function g_advancedTooltip.display()
	if not advancedTooltipWindow then return end
	if not itemsAdvancedTooltip then return end

	if currentAdvancedHoveredWidget:getClassName() == "UIItem" then
		local item = currentAdvancedHoveredWidget:getItem()
		if not item then
			advancedTooltipWindow:hide()
			advancedTooltipPokemon:hide()
			advancedTooltipPokemonMarket:hide()
			currentAdvancedHoveredWidget = nil
			return
		end

		local itemInfo = item:getItemInfo()
		if item then
			if currentAdvancedHoveredWidget.pokeballsInfo then
				if not advancedTooltipPokemonMarket then return end

				advancedTooltipPokemonMarket:show()
				advancedTooltipPokemonMarket:raise()
				advancedTooltipPokemonMarket:enable()
				advancedTooltipPokemonMarket:setVisible(true)
				local infos = currentAdvancedHoveredWidget.pokeballsInfo
				-- dump(infos)
				local lowerPokeName = infos.name:lower()

				local isShiny = string.find(lowerPokeName, "shiny ")
				local isMega = string.find(lowerPokeName, "mega ")

				if isShiny then
					local getShinyName = string.match(lowerPokeName, "shiny" .. "%s*(.+)")
					advancedTooltipPokemonMarket.pokeName:setText(capitalize(getShinyName))
					advancedTooltipPokemonMarket.image:setImageSource("/pokemon/sprites/shiny/" .. getShinyName)
				elseif isMega then
					local getMegaName = string.match(lowerPokeName, "mega" .. "%s*(.+)")
					advancedTooltipPokemonMarket.pokeName:setText(capitalize(getMegaName))
					-- advancedTooltipPokemonMarket.image:setImageSource("/pokemon/sprites/" .. getMegaName.. "mega")
				else
					advancedTooltipPokemonMarket.pokeName:setText(capitalize(infos.name))
					advancedTooltipPokemonMarket.image:setImageSource("/pokemon/sprites/regular/" .. lowerPokeName)
				end
				local currentName = advancedTooltipPokemonMarket.pokeName:getText()
				advancedTooltipPokemonMarket.pokeName:setText(currentName .. " +" .. infos.boost)

				advancedMoveMarketToolTip(true)
			elseif not currentAdvancedHoveredWidget.itemTooltipInfo then
				local width = 150
				local height = 117
				advancedTooltipWindow:show()
				advancedTooltipWindow:raise()
				advancedTooltipWindow:enable()
				advancedTooltipWindow:setVisible(true)
				advancedTooltipWindow.item:setItemId(currentAdvancedHoveredWidget:getItemId())
				advancedTooltipWindow.name:setText(itemInfo.name)

				if itemInfo.desc then
					-- local textTab = tr(itemInfo.desc)
					local textTab = itemInfo.desc
					-- print(itemInfo.desc)

					advancedTooltipWindow.desc:setText(textTab)
					height = height + advancedTooltipWindow.desc:getHeight() + 3
				end

				advancedTooltipWindow:setHeight(height)
				advancedTooltipWindow:setWidth(width)
			elseif currentAdvancedHoveredWidget.pokemonTooltipInfo then
				if not advancedTooltipPokemon then return end

				local width = 164
				local height = 302
				advancedTooltipPokemon:show()
				advancedTooltipPokemon:raise()
				advancedTooltipPokemon:enable()
				advancedTooltipPokemon:setVisible(true)
				local data = itemInfo.pokeballInfo


				local pokeName = getBallSpecialAttribute("pokeName", data)
				local pokeOutfit = getBallSpecialAttribute("looktype", data)
				local regenOrb = getBallSpecialAttribute("regenOrb", data)
				local expOrb = getBallSpecialAttribute("expOrb", data)
				local maestria = getBallSpecialAttribute("maestria", data)
				local starFusion = getBallSpecialAttribute("starFusion", data)
				local pokeCard = getBallSpecialAttribute("pokeCard", data)
				local isShiny = string.find(pokeName, "Shiny")
				local getShinyName = string.match(pokeName, "Shiny" .. "%s*(.+)")

				if pokeCard then
					local cardId = cards_pokemons[pokeCard]
					advancedTooltipPokemon.card:setItemId(cardId)
				else
					advancedTooltipPokemon.card:setItemId(0)
				end

				if regenOrb then
					advancedTooltipPokemon.greenEnergy:setOpacity(1)
				else
					advancedTooltipPokemon.greenEnergy:setOpacity(0.2)
				end
				if expOrb then
					advancedTooltipPokemon.yellowEnergy:setOpacity(1)
				else
					advancedTooltipPokemon.yellowEnergy:setOpacity(0.2)
				end

				advancedTooltipPokemon.pokeName:setText(pokeName)

				advancedTooltipPokemon.image:setOutfit({ type = pokeOutfit })
				advancedTooltipPokemon.image:setOldScaling(true)

				if maestria then
					advancedTooltipPokemon.maestria:setImageSource("/images/ui/tooltip/" .. maestria .. "_maestria")
				else
					advancedTooltipPokemon.maestria:setImageSource("/images/ui/tooltip/0_maestria")
				end
				if starFusion then
					advancedTooltipPokemon.stars:setImageSource("/images/ui/tooltip/" .. starFusion .. "_star")
				else
					advancedTooltipPokemon.stars:setImageSource("/images/ui/tooltip/0_star")
				end

				advancedMovePokeToolTip(true)
			end
		end
	elseif tostring(currentAdvancedHoveredWidget.advancedTooltip) then
		local width = 14
		local height = 10
		advancedTooltipWindow:show()
		advancedTooltipWindow:raise()
		advancedTooltipWindow:enable()
		advancedTooltipWindow:setVisible(true)
		advancedTooltipWindow:setWidth(500)
		advancedTooltipName:setVisible(true)
		advancedTooltipName:setText(currentAdvancedHoveredWidget.advancedTooltip)
		advancedTooltipName:resizeToText()
		width = width + advancedTooltipName:getWidth()
		height = height + advancedTooltipName:getHeight()
		advancedTooltipWindow:setWidth(width)
		advancedTooltipWindow:setHeight(height)

		advancedTooltipHead:setVisible(false)
		aTdescription:setVisible(false)
		aTmoney:setVisible(false)
	end
	advancedTooltipWindow:setOpacity(0.95)
	advancedMoveToolTip(true)
end

function protectTranslate(text)
	local t = {}
	text:gsub(".", function(c) table.insert(t, c) end)
	for a = 1, #t do
		if t[a] == "%" or t[a] == "+" then return false end
	end
	return true
end

function getLockTableTime(s)
	local d = 0
	local h = 0
	local m = 0
	if s >= 86400 then
		while s >= 86400 do
			s = s - 86400
			d = d + 1
		end
	end
	if s >= 3600 then
		while s >= 3600 do
			s = s - 3600
			h = h + 1
		end
	end
	if s >= 60 then
		while s >= 60 do
			s = s - 60
			m = m + 1
		end
	end
	return { d = d, h = h, m = m, s = s }
end

function g_tooltip.hide()
	g_effects.fadeOut(toolTipLabel, 150)
end

function g_advancedTooltip.hide()
	advancedTooltipWindow:hide()
	advancedTooltipPokemon:hide()
	advancedTooltipPokemonMarket:hide()
end

-- @docclass UIWidget @{

-- UIWidget extensions
function UIWidget:setTooltip(text)
	self.tooltip = text
end

function UIWidget:removeTooltip()
	self.tooltip = nil
end

function UIWidget:getTooltip()
	return self.tooltip
end

function UIWidget:setAdvancedTooltip(text)
	if text then
		self.advancedTooltip = text
	else
		self.advancedTooltip = true
	end
end

function UIWidget:removeAdvancedTooltip()
	self.advancedTooltip = nil
end

function UIWidget:getAdvancedTooltip()
	return self.advancedTooltip
end

function g_tooltip.setHoveredWidget(widget)
	currentHoveredWidget = widget
end

function g_tooltip.getHoveredWidget()
	return currentHoveredWidget
end

function g_advancedTooltip.setHoveredWidget(widget)
	currentAdvancedHoveredWidget = widget
end

function g_advancedTooltip.getHoveredWidget()
	return currentAdvancedHoveredWidget
end

-- @}

g_tooltip.init()
g_advancedTooltip.init()
connect(g_app, { onTerminate = tooltipsTerminate })
