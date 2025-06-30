local gameStart = 0

pokemonsID = {}
pokeballsID = {}
foodID = {}
MedicinesID = {27645}
lootID = {}
OthersID = {}

FILTER_BUTTONS = {
	{ name = "All", image = "/images/ui/miniwindowbtn/filter_icon/all", action = "all" },
	{ name = "Pokémons", image = "/images/ui/miniwindowbtn/filter_icon/pokemon", action = "pokemon" },
	{ name = "Pokeballs", image = "/images/ui/miniwindowbtn/filter_icon/pokeballs", action = "pokeballs" },
	{ name = "Loot", image = "/images/ui/miniwindowbtn/filter_icon/loot", action = "loot" },
	{ name = "Foods", image = "/images/ui/miniwindowbtn/filter_icon/food", action = "food" },
	{ name = "Medicines", image = "/images/ui/miniwindowbtn/filter_icon/medicine", action = "medicine" },
	{ name = "Others", image = "/images/ui/miniwindowbtn/filter_icon/others", action = "others" },
}

function init()
  g_ui.importStyle('container')
  connect(Container, { onOpen = onContainerOpen,
                       onClose = onContainerClose,
                       onSizeChange = onContainerChangeSize,
                       onUpdateItem = onContainerUpdateItem })
  connect(g_game, {
    onGameStart = markStart,
    onGameEnd = clean
  })

  reloadContainers()
end

function terminate()
  disconnect(Container, { onOpen = onContainerOpen,
                          onClose = onContainerClose,
                          onSizeChange = onContainerChangeSize,
                          onUpdateItem = onContainerUpdateItem })
  disconnect(g_game, { 
    onGameStart = markStart,
    onGameEnd = clean
  })
end

function reloadContainers()
  clean()
  for _, container in pairs(g_game.getContainers()) do
    onContainerOpen(container)
  end
end

function clean()
  for containerid,container in pairs(g_game.getContainers()) do
    destroy(container)
  end
end

function markStart()
  gameStart = g_clock.millis()
end

function destroy(container)
  if container.window then
    container.window:destroy()
    container.window = nil
    container.itemsPanel = nil
    if doCheckDepotStatus(container) then
      modules.game_walking.enableWSAD()
    end
  end
end

function refreshContainerItemsALL(container)
  local containerPanel = container.itemsPanel
  local containerWindow = container.window
  local depotBoll = container.depotBoll

  containerPanel:destroyChildren()
  for slot = 0, container:getCapacity()-1 do
    local itemWidget = g_ui.createWidget('Item', containerPanel)
    local itemId = container:getItem(slot)
    if itemId then
    	  itemWidget:setOpacity(1)
    else
     itemWidget:setOpacity(0.25)
    end
    itemWidget:setId('item' .. slot)
    itemWidget:setItem(container:getItem(slot))
    itemWidget:setMarginLeft(0)
    itemWidget.position = container:getSlotPosition(slot)
    if not container:isUnlocked() then
      itemWidget:setBorderColor('red')
    end
  end

  container.window = containerWindow
  container.itemsPanel = containerPanel

  toggleContainerPages(containerWindow, container:hasPages())
  refreshContainerPages(container)

  -- DEFINIR MAXIMUM
  local layout = containerPanel:getLayout()
  local cellSize = layout:getCellSize()
  containerWindow:setContentMinimumHeight(cellSize.height)
  containerWindow:setContentMaximumHeight(cellSize.height*layout:getNumLines()+(layout:getNumLines()*1))
end

function refreshContainerItems(container)
  local filterId = container.window.filter
  local filterTable
  container.window.editSearch:setText("")
       
  if filterId == "all" or filterId == nil then
	container.window.filter = "all"
	local panelFilter = container.window.filterPanel.buttonsPael
	doResetFilter(panelFilter, container)
	return refreshContainerItemsALL(container)
  elseif filterId == "pokemon" then
	filterTable = pokemonsID
  elseif filterId == "pokeballs" then
	filterTable = pokeballsID
  elseif filterId == "loot" then
	filterTable = lootID
  elseif filterId == "food" then
	filterTable = foodID
  elseif filterId == "medicine" then
	filterTable = MedicinesID
  elseif filterId == "others" then
	filterTable = OthersID
  end

  local containerPanel = container.itemsPanel
  local containerWindow = container.window
  
  if not itemExistsInContainer(container, filterTable) then
	container.window.filter = "all"
	local panelFilter = container.window.filterPanel.buttonsPael
	doResetFilter(panelFilter, container)
	return refreshContainerItemsALL(container)
  end

  containerPanel:destroyChildren()
  for slot, item in ipairs(container:getItems()) do
	local itemInfo = item:getItemInfo()
	
	if itemExistsInTable(itemInfo.ItemID, filterTable) then
      local itemWidget = g_ui.createWidget('Item', containerPanel)
	  itemWidget:setItem(item)
	  
	  if item then
	    itemWidget:setOpacity(1)
	  else
	    itemWidget:setOpacity(0.25)
	  end
	  
      itemWidget:setId('item' .. slot)
      itemWidget:setMarginLeft(0)
      itemWidget.position = container:getSlotPosition(slot)
	  
      if not container:isUnlocked() then
        itemWidget:setBorderColor('red')
      end
	end
  end

  container.window = containerWindow
  container.itemsPanel = containerPanel

  toggleContainerPages(containerWindow, container:hasPages())
  refreshContainerPages(container)

  -- DEFINIR MAXIMUM
  local layout = containerPanel:getLayout()
  local cellSize = layout:getCellSize()
  containerWindow:setContentMinimumHeight(cellSize.height)
  containerWindow:setContentMaximumHeight(cellSize.height*layout:getNumLines()+(layout:getNumLines()*1))
end

function toggleContainerPages(containerWindow, hasPages)
  if not depotBoll then
    if hasPages == containerWindow.pagePanel:isOn() then
      return
    end
    if hasPages then
      containerWindow.miniwindowScrollBar:setMarginTop(containerWindow.miniwindowScrollBar:getMarginTop() + containerWindow.pagePanel:getHeight())
      containerWindow.contentsPanel:setMarginTop(containerWindow.contentsPanel:getMarginTop() + containerWindow.pagePanel:getHeight())  
    else  
      containerWindow.miniwindowScrollBar:setMarginTop(containerWindow.miniwindowScrollBar:getMarginTop() - containerWindow.pagePanel:getHeight())
      containerWindow.contentsPanel:setMarginTop(containerWindow.contentsPanel:getMarginTop() - containerWindow.pagePanel:getHeight())
    end
  end
  containerWindow.pagePanel:setOn(hasPages)
end

function refreshContainerPages(container)
  if not container.window:recursiveGetChildById('pageLabel') then return false end
  local currentPage = 1 + math.floor(container:getFirstIndex() / container:getCapacity())
  local pages = 1 + math.floor(math.max(0, (container:getSize() - 1)) / container:getCapacity())
  container.window:recursiveGetChildById('pageLabel'):setText(string.format('Page %i of %i', currentPage, pages))

  local prevPageButton = container.window:recursiveGetChildById('prevPageButton')
  if currentPage == 1 then
    prevPageButton:setEnabled(false)
  else
    prevPageButton:setEnabled(true)
    prevPageButton.onClick = function() g_game.seekInContainer(container:getId(), container:getFirstIndex() - container:getCapacity()) end
  end

  local nextPageButton = container.window:recursiveGetChildById('nextPageButton')
  if currentPage >= pages then
    nextPageButton:setEnabled(false)
  else
    nextPageButton:setEnabled(true)
    nextPageButton.onClick = function() g_game.seekInContainer(container:getId(), container:getFirstIndex() + container:getCapacity()) end
  end
  
  local pagePanel = container.window:recursiveGetChildById('pagePanel')
  if pagePanel then
    pagePanel.onMouseWheel = function(widget, mousePos, mouseWheel)
      if pages == 1 then return end
      if mouseWheel == MouseWheelUp then
        return prevPageButton.onClick()
      else
        return nextPageButton.onClick()
      end
    end
  end
end

function formatDateTime(dateTime)
    local year, month, day, hour, min, sec = dateTime:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    local formattedDateTime = string.format("%04d-%02d-%02d\n%02d:%02d:%02d", year, month, day, hour, min, sec)
    return formattedDateTime
end
function capitalizeWords(str)
    return (str:gsub("(%w)([%w']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end))
end
function getColorByString(str)
	if str == "MARKET" or str == "SYSTEM" or str == "CATCH" then
		return "#b7b7b7"
	elseif str == "QUEST" or str == "NPC" then
		return "#fdff5d"
	elseif str == "ADMIN" then
		return "#ff7800"
	elseif str == "BOX 5" or str == "BOX 4" or str == "BOX 3" or str == "BOX 2" or str == "BOX 1" then
		return "#8986ff"
	elseif str == "DONATION" then
		return "#abff86"
	else
		return "#a5fffe"
	end
end


function doCheckIsPokeball(data)
	local newdata = json.decode(data.details)
	local attributes = newdata.itemAtribute
	if getBallSpecialAttribute("pokeName", attributes) then
		return true, attributes
	else
		return false, nil
	end
end

function onContainerOpen(container, previousContainer)
  local containerWindow
  local depotBoll
  if previousContainer then
    containerWindow = previousContainer.window
    previousContainer.window = nil
    previousContainer.itemsPanel = nil
  else
    containerWindow = g_ui.createWidget('ContainerWindow', modules.game_interface.getContainerPanel())
    containerWindow:getChildById('text'):setColor('#c9c9c9')
  end
  if doCheckDepotStatus(container) then
	depotBoll = true
  else
	depotBoll = false
  end
  if containerWindow:getChildById('InboxHistoryPanel') then
	containerWindow:getChildById('InboxHistoryPanel'):destroy()
  end

  local filterPanel = containerWindow.filterPanel.buttonsPael
  filterPanel:destroyChildren()
  for slot, button in ipairs(FILTER_BUTTONS) do
    ButtonFilter = g_ui.createWidget('ButtonSelectFilter', filterPanel)
	ButtonFilter:setImageSource(button.image)
	ButtonFilter:setTooltip(button.name)
	ButtonFilter:setId(button.action)
	ButtonFilter.onClick = function()
      onContainerFilter(containerWindow, container, button.action)
    end
  end
  
  containerWindow:setId('container'..container:getId())
  if gameStart + 1000 < g_clock.millis() then
    containerWindow:clearSettings()
  end
  
  local containerPanel = containerWindow:getChildById('contentsPanel')
  local containerItemWidget = containerWindow:getChildById('containerItemWidget')
  containerWindow.onClose = function()
    g_game.close(container)
    containerWindow:hide()
  end
  containerWindow.onDrop = function(container, widget, mousePos)
    if containerPanel:getChildByPos(mousePos) then
      return false
    end
    local child = containerPanel:getChildByIndex(-1)
    if child then
      child:onDrop(widget, mousePos, true)        
    end
  end
  
  if depotBoll == false then
    containerWindow.onMouseRelease = function(widget, mousePos, mouseButton)
      if mouseButton == MouseButton4 then
        if container:hasParent() then
          return g_game.openParent(container)
        end
      elseif mouseButton == MouseButton5 then
        for i, item in ipairs(container:getItems()) do
          if item:isContainer() then
            return g_game.open(item, container)
          end
        end
      end
    end
  end
  -- this disables scrollbar auto hiding
  local scrollbar = containerWindow:getChildById('miniwindowScrollBar')
  scrollbar:mergeStyle({ ['$!on'] = { }})

  local upButton = containerWindow:getChildById('upButton')
  local closeButton = containerWindow:getChildById('closeButton')
  local minimizeButton = containerWindow:getChildById('minimizeButton')
  local lockButton = containerWindow:getChildById('lockButton')
  local editSearch = containerWindow:getChildById('editSearch')
  upButton.onClick = function()
    g_game.openParent(container)
  end
  upButton:setVisible(container:hasParent())

  local name = container:getName()
  name = name:sub(1, 1):upper() .. name:sub(2)
  if #name > 10 then
	containerWindow:getChildById('text'):setText(name:sub(1, 7).."...")
  else
	containerWindow:getChildById('text'):setText(name)
  end
  containerItemWidget:setItem(container:getContainerItem())
  containerWindow:getChildById('text'):setTooltip(name)
  containerWindow:getChildById('item'):setItem(container:getContainerItem())

  -- tratamento dos itens dentro da bag
  if depotBoll then
    containerPanel:destroyChildren()
    local timeEvent = 10
    for slot = 0, container:getCapacity()-1 do
	  scheduleEvent(function() 
         local itemWidget = g_ui.createWidget('Item', containerPanel)
	     local itemId = container:getItem(slot)
	     if itemId then
	     	  itemWidget:setOpacity(1)
	     else
	  	  itemWidget:setOpacity(0.25)
	     end
         itemWidget:setId('item' .. slot)
         itemWidget:setItem(container:getItem(slot))
         itemWidget:setMarginLeft(0)
         itemWidget.position = container:getSlotPosition(slot)
         if not container:isUnlocked() then
           itemWidget:setBorderColor('red')
         end
	  end, timeEvent*slot)
    end
  else
    containerPanel:destroyChildren()
    for slot = 0, container:getCapacity()-1 do
      local itemWidget = g_ui.createWidget('Item', containerPanel)
	  local itemId = container:getItem(slot)
	  if itemId then
	  	  itemWidget:setOpacity(1)
	  else
	   itemWidget:setOpacity(0.25)
	  end
      itemWidget:setId('item' .. slot)
      itemWidget:setItem(container:getItem(slot))
      itemWidget:setMarginLeft(0)
      itemWidget.position = container:getSlotPosition(slot)
      if not container:isUnlocked() then
        itemWidget:setBorderColor('red')
      end
    end
  end

  container.window = containerWindow
  container.depotBoll = depotBoll
  container.itemsPanel = containerPanel

  toggleContainerPages(containerWindow, container:hasPages())
  refreshContainerPages(container)

  -- DEFINIR MAXIMUM
  local layout = containerPanel:getLayout()
  local cellSize = layout:getCellSize()
  scheduleEvent(function() 
     containerWindow:setContentMinimumHeight(cellSize.height)
     containerWindow:setContentMaximumHeight(cellSize.height*layout:getNumLines()+(layout:getNumLines()*1))
  end, 10 * (container:getCapacity()-1) )

  containerWindow.filter = "all"
  containerWindow:setup()

  if not doCheckDepotStatus(container) then
    if container:hasPages() then
      local height = containerWindow.miniwindowScrollBar:getMarginTop() + containerWindow.pagePanel:getHeight() + 32
      if containerWindow:getHeight() < height then
        containerWindow:setHeight(height)
      end
    end
    local hasHeightInSettings = containerWindow:getSettings("height")
    if not previousContainer and not hasHeightInSettings then
      local filledLines = math.max(math.ceil(container:getItemsCount() / layout:getNumColumns()), 1)
      containerWindow:setContentHeight(filledLines*cellSize.height)
    end
	containerWindow.backgroundTopTittle:setVisible(false)

  elseif doCheckDepotStatus(container) then
	-- 3497 -- POKÉMON CENTER MACHINE
	-- 3502 -- DEPOT 
	-- 3498 -- MAIL
	
	local slotItem = container:getContainerItem():getId()
	if slotItem == 3497 then
	  containerWindow.backgroundTopTittle.StatusName:setText("")
	elseif slotItem == 3502 then
      editSearch.onTextChange = function() onSearchItemInContainer(containerWindow, container, editSearch:getText()) end
	else
	  editSearch:setVisible(false)
      editSearch.onTextChange = function() end
	end
	
	if containerWindow:getChildById('return') then containerWindow:getChildById('return'):destroy() end
  
	containerWindow.backgroundTopTittle:setVisible(true)
    upButton:setVisible(false)
    closeButton:setVisible(false)
    minimizeButton:setVisible(false)
    lockButton:setVisible(false)
	containerWindow.pagePanel:setOn(false)
    modules.game_walking.disableWSAD()

    containerWindow:getChildById('text'):setVisible(false)
    containerWindow:getChildById('item'):setVisible(false)
	
	if not containerWindow:getChildById('InboxHistoryPanel') then
		InboxHistoryPanel = g_ui.createWidget('InboxHistoryPanel', containerWindow)
		InboxHistoryPanel:setVisible(false)
	end
  
    containerWindow:setParent(modules.game_interface.getRootPanel())
    containerWindow:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
    containerWindow:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
	containerWindow:setSize('545 400')
	containerWindow:setImageSource('/images/ui/container/background_container')
	
	containerWindow.contentsPanel:breakAnchors()
	containerWindow.contentsPanel:addAnchor(AnchorTop, 'parent', AnchorTop)
	containerWindow.contentsPanel:addAnchor(AnchorBottom, 'parent', AnchorBottom)
	containerWindow.contentsPanel:addAnchor(AnchorLeft, 'parent', AnchorLeft)
	containerWindow.contentsPanel:setSize('494 263')
	containerWindow.contentsPanel:setMarginTop(92)
	containerWindow.contentsPanel:setMarginBottom(11)
	containerWindow.contentsPanel:setMarginLeft(20)
	
	containerWindow.filterPanel:breakAnchors()
	containerWindow.filterPanel:addAnchor(AnchorBottom, 'contentsPanel', AnchorTop)
	containerWindow.filterPanel:addAnchor(AnchorLeft, 'contentsPanel', AnchorLeft)
	containerWindow.filterPanel:setSize('185 32')
	containerWindow.filterPanel:setImageSource('/images/ui/clear')
	containerWindow.filterPanel:setImageBorder(11)
	containerWindow.filterPanel:setMarginBottom(5)
	containerWindow.filterPanel:setMarginLeft(-2)
	
    CloseDepotButton = g_ui.createWidget('CloseDepotButton', containerWindow)
    CloseDepotButton.onClick = function()
      g_game.close(container)
      containerWindow:hide()
	  modules.game_walking.enableWSAD()
    end

	containerWindow.miniwindowScrollBar:breakAnchors()
	containerWindow.miniwindowScrollBar:addAnchor(AnchorTop, 'contentsPanel', AnchorTop)
	containerWindow.miniwindowScrollBar:addAnchor(AnchorBottom, 'contentsPanel', AnchorBottom)
	containerWindow.miniwindowScrollBar:addAnchor(AnchorLeft, 'contentsPanel', AnchorRight)
	containerWindow.miniwindowScrollBar:setMarginTop(0)
	containerWindow.miniwindowScrollBar:setMarginBottom(0)
	containerWindow.miniwindowScrollBar:setMarginLeft(9)

    if slotItem == 3502 or slotItem == 3498 then
	   containerWindow.pagePanel:setVisible(false)
       containerWindow.contentsPanel:setVisible(false)
       containerWindow.miniwindowScrollBar:setVisible(false)
       containerWindow.filterPanel:setVisible(false)
       containerWindow.editSearch:setVisible(false)
			
       LoadItensPanel = g_ui.createWidget('LoadItensPanel', containerWindow)
	   if slotItem == 3502 then
         LoadItensPanel.progress_back:setImageSource("/images/ui/container/depot_loading")
	   elseif slotItem == 3498 then
         LoadItensPanel.progress_back:setImageSource("/images/ui/container/inbox_loading")
		--  local playerName = g_game.getLocalPlayer():getName()
		--  getMailHistoryByAPI(InboxHistoryPanel.panelList, playerName)
	   end
       
       local numSlots = 8
       local realSlotItems = 0
       local SlotItems = 0
       local totalItems = #container:getItems()
       local reamingTime = 50
       
       local startPercentage = 0
       local endPercentage = 0
    
       for slot, item in ipairs(container:getItems()) do
           if item then
               realSlotItems = realSlotItems + 1
               startPercentage = realSlotItems / totalItems
               endPercentage = realSlotItems / totalItems * 100
               
               scheduleEvent(function()
                   SlotItems = SlotItems + 1
                   local slotIndex = (slot - 1) % numSlots + 1
                   LoadItensPanel.itens_panel["item_"..slotIndex]:setItem(item)
                   local percentage = startPercentage + (endPercentage - startPercentage) * (SlotItems / totalItems)
                   local progressPercentgb = math.floor(100 * percentage / 100)
                   local Yhppcgb = math.floor(281 * (1 - (progressPercentgb / 100)))
                   local rectgb = { x = 0, y = 0, width = 281 - Yhppcgb + 1, height = 11 }
                   LoadItensPanel.progressbar:setImageClip(rectgb)
                   LoadItensPanel.progressbar:setImageRect(rectgb)
               end, reamingTime * slot)
           end
       end
       
       scheduleEvent(function()
         scheduleEvent(function()
            containerWindow.contentsPanel:setVisible(true)
            containerWindow.miniwindowScrollBar:setVisible(true)
            containerWindow.filterPanel:setVisible(true)
			if slotItem == 3502 then
              containerWindow.editSearch:setVisible(true)
              g_effects.fadeIn(containerWindow.editSearch, 350)
              containerWindow.backgroundTopTittle.StatusName:setText("(DEPOT)")
			  InboxHistoryPanel:destroy()
			elseif slotItem == 3498 then
              containerWindow.backgroundTopTittle.StatusName:setText("(INBOX)")
			  containerWindow.pagePanel:setOn(true)
              containerWindow.miniwindowScrollBar:setVisible(false)
			  InboxHistoryPanel:setVisible(true)
			end
            g_effects.fadeIn(InboxHistoryPanel, 350)
            g_effects.fadeIn(containerWindow.contentsPanel, 350)
            g_effects.fadeIn(containerWindow.miniwindowScrollBar, 350)
            g_effects.fadeIn(containerWindow.filterPanel, 350)
			LoadItensPanel:setVisible(false)
			if slotItem == 3502 or slotItem == 3498 then
				ReturnDepotButton = g_ui.createWidget('ReturnDepotButton', containerWindow)
				ReturnDepotButton.onClick = function()
					g_game.openParent(container)
				end
			end
         end, 500)
         g_effects.fadeIn(containerWindow.backgroundTopTittle.StatusName, 350)
		 g_effects.fadeOut(LoadItensPanel, 350)

       end, reamingTime * (realSlotItems - 1))
    end

	if slotItem == 3497 then
		containerWindow.contentsPanel:setVisible(false)
		containerWindow.miniwindowScrollBar:setVisible(false)
		containerWindow.filterPanel:setVisible(false)

		DepotSelectionButtons = g_ui.createWidget('DepotSelectionButtons', containerWindow)
		
		DepotSelectionButtons.depotButton.onClick = function()
          for slot, item in ipairs(container:getItems()) do
		  	if item:getId() == 3502 then
				g_effects.fadeOut(DepotSelectionButtons, 350)
				scheduleEvent(function()
					DepotSelectionButtons:setVisible(false)
				end, 400)
				g_game.open(item, container)
				InboxHistoryPanel:setVisible(false)
		  	end
          end
		end
		DepotSelectionButtons.inboxButton.onClick = function()
          for slot, item in ipairs(container:getItems()) do
		  	if item:getId() == 3498 then
				g_effects.fadeOut(DepotSelectionButtons, 350)
				scheduleEvent(function()
					DepotSelectionButtons:setVisible(false)
				end, 400)
				g_game.open(item, container)
				InboxHistoryPanel:setVisible(false)
		  	end
          end
		end
	end
  end
end

function doResetFilter(panel, container)
    local children = panel:getChildren()
	local panelFilter = container.window.filter
	
    for i = 1, #children do
	  if children[i]:getId() == panelFilter then
		children[i]:focus()
	  end
    end
end

function onSearchItemInContainer(containerWindow, container, filterKey)
  local containerPanel = containerWindow:getChildById('contentsPanel')

  local filterTable
  local panelFilter = container.window.filterPanel.buttonsPael
  local depotBoll = container.depotBoll

  container.window.filter = "all"
  doResetFilter(panelFilter, container)
  
  if #filterKey == 0 or filterKey == nil then
	return refreshContainerItemsALL(container)
  end

  containerPanel:destroyChildren()
  for slot, item in ipairs(container:getItems()) do
	local itemInfo = item:getItemInfo()
	local itemInfoName = ""

	if item:isStackable() then
	  	itemInfoName = itemInfo.name
		
	elseif itemInfo.pokeballInfo ~= "" then
	  	itemInfoName = getBallSpecialAttribute("pokeName", itemInfo.pokeballInfo)
	
	elseif item then
	  local dataInfo = json.decode(itemInfo.name)
	  if dataInfo.tag then
	  	itemInfoName = dataInfo.tag
	  else
	  	itemInfoName = dataInfo.name
	  end

	else
      itemInfoName = ""
	end

	if string.find(string.lower(itemInfoName), string.lower(filterKey)) then
      local itemWidget = g_ui.createWidget('Item', containerPanel)
	  itemWidget:setItem(item)
	  if item then
	    itemWidget:setOpacity(1)
	  else
	    itemWidget:setOpacity(0.25)
	  end
      itemWidget:setId('item' .. slot)
      itemWidget:setMarginLeft(0)
      itemWidget.position = container:getSlotPosition(slot)
      if not container:isUnlocked() then
        itemWidget:setBorderColor('red')
      end
	end
  end

  container.window = containerWindow
  container.itemsPanel = containerPanel

  toggleContainerPages(containerWindow, container:hasPages())
  refreshContainerPages(container)

  -- DEFINIR MAXIMUM
  local layout = containerPanel:getLayout()
  local cellSize = layout:getCellSize()
  scheduleEvent(function() 
     containerWindow:setContentMinimumHeight(cellSize.height)
     containerWindow:setContentMaximumHeight(cellSize.height*layout:getNumLines()+(layout:getNumLines()*1))
  end, 10 * (container:getCapacity()-1) )
  
  containerWindow.filter = "all"
  containerWindow:setup()
end

function onContainerFilter(containerWindow, container, filterKey)
  local containerPanel = containerWindow:getChildById('contentsPanel')

  local filterTable
  local panelFilter = container.window.filterPanel.buttonsPael
  local depotBoll = container.depotBoll

  if filterKey == "all" or filterKey == nil then
	container.window.filter = "all"
	doResetFilter(panelFilter, container)
	return refreshContainerItemsALL(container)
  elseif filterKey == "pokemon" then
	filterTable = pokemonsID
  elseif filterKey == "pokeballs" then
	filterTable = pokeballsID
  elseif filterKey == "loot" then
	filterTable = lootID
  elseif filterKey == "food" then
	filterTable = foodID
  elseif filterKey == "medicine" then
	filterTable = MedicinesID
  elseif filterKey == "others" then
	filterTable = OthersID
  end
  
  containerWindow.editSearch:setText("")
  
  if not itemExistsInContainer(container, filterTable) then
	return doResetFilter(panelFilter, container)
  end
  
  containerPanel:destroyChildren()
  for slot, item in ipairs(container:getItems()) do
	local itemInfo = item:getItemInfo()
	if itemExistsInTable(itemInfo.ItemID, filterTable) then
      local itemWidget = g_ui.createWidget('Item', containerPanel)
	  itemWidget:setItem(item)
	  if item then
	    itemWidget:setOpacity(1)
	  else
	    itemWidget:setOpacity(0.25)
	  end
      itemWidget:setId('item' .. slot)
      itemWidget:setMarginLeft(0)
      itemWidget.position = container:getSlotPosition(slot)
      if not container:isUnlocked() then
        itemWidget:setBorderColor('red')
      end
	end
  end

  container.window = containerWindow
  container.itemsPanel = containerPanel

  toggleContainerPages(containerWindow, container:hasPages())
  refreshContainerPages(container)

  -- DEFINIR MAXIMUM
  local layout = containerPanel:getLayout()
  local cellSize = layout:getCellSize()
  containerWindow:setContentMinimumHeight(cellSize.height)
  containerWindow:setContentMaximumHeight(cellSize.height*layout:getNumLines()+(layout:getNumLines()*1))
  
  containerWindow.filter = filterKey
  containerWindow:setup()
end

function onContainerClose(container)
  destroy(container)
end

function onContainerChangeSize(container, size)
  if not container.window then return end
  refreshContainerItems(container)
end

function onContainerUpdateItem(container, slot, item, oldItem)
  if not container.window then return end
  if not itemWidget then
	refreshContainerItems(container)
  else
	local itemWidget = container.itemsPanel:getChildById('item' .. slot)
	itemWidget:setItem(item)
  end
end


function itemExistsInContainer(container, tableId)
  local items = container:getItems()

  for _, item in ipairs(items) do
    local itemInfo = item:getItemInfo() 
      for _, pokemonID in ipairs(tableId) do
          if itemInfo.ItemID == pokemonID then
              return true
          end
      end
  end

  return false
end
function itemExistsInTable(item, table)
  for _, value in ipairs(table) do
      if value == item then
          return true
      end
  end
  return false
end

isDepotTable = {3497,3498,3499,3500,3502,3497,3502}
function doCheckDepotStatus(container)
	local containerId = container:getContainerItem():getId()
	local containerIdState = container:getId()
	if itemExistsInTable(containerId, isDepotTable) then
		return true
	elseif itemExistsInTable(containerIdState, isDepotTable) then
		return true
	end
	return false
end

