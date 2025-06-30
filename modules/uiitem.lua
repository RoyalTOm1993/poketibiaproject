local itemHover = nil

function UIItem:onDragEnter(mousePos)
  if self:isVirtual() then return false end

  local item = self:getItem()
  if not item then return false end

  self:setBorderWidth(1)
  self.currentDragThing = item
  g_mouse.pushCursor('target')
  return true
end

function UIItem:onDragLeave(droppedWidget, mousePos)
  if self:isVirtual() then return false end
  self.currentDragThing = nil
  g_mouse.popCursor('target')
  self:setBorderWidth(0)
  self.hoveredWho = nil
  return true
end

function UIItem:onDrop(widget, mousePos, forced)

-- print(1)
  if not self:canAcceptDrop(widget, mousePos) and not forced then return false end

  local item = widget.currentDragThing
  if not item or not item:isItem() then return false end
  
  if self.selectable then
    if item:isPickupable() then
      self:setItem(Item.create(item:getId(), item:getCountOrSubType()))
      return true
    end
    return false
  end

  local toPos = self.position

  local itemPos = item:getPosition()
  if itemPos.x == toPos.x and itemPos.y == toPos.y and itemPos.z == toPos.z then return false end

  if item:getCount() > 1 then
    modules.game_interface.moveStackableItem(item, toPos)
  else
    g_game.move(item, toPos, 1)
  end

  self:setBorderWidth(0)
  return true
end

function UIItem:onDestroy()
  if self == g_ui.getDraggingWidget() and self.hoveredWho then
    self.hoveredWho:setBorderWidth(0)
  end
  
  if g_advancedTooltip and self == g_advancedTooltip.getHoveredWidget() then
   g_advancedTooltip.hide()
   g_advancedTooltip.setHoveredWidget(nil)
  end

  if self.hoveredWho then
    self.hoveredWho = nil
  end
end

function UIItem:onHoverChange(hovered)
if self:isVirtual() and not self.isTradeItem and not self.advancedTooltip then return end

	local shader = false

	if itemHover then
		itemHover:setBorderWidth(0)
		itemHover:setBorderColor("alpha")
		if itemHover:getItem() and shader then 
			itemHover:getItem():setShader("none")
		end
	end

	self:setBorderWidth(1)
	self:setBorderColor("red")

	if self:getItem() and shader then 
		self:getItem():setShader("map_grayscale")
	end
	
	itemHover = self

	if not hovered then
		itemHover:setBorderWidth(0)
		itemHover:setBorderColor("alpha")
		if itemHover:getItem() and shader then 
			itemHover:getItem():setShader("none")
		end
	end

    if hovered then
      if g_advancedTooltip.getHoveredWidget() ~= self and not g_mouse.isPressed(MouseLeftButton) then
	    g_advancedTooltip.setHoveredWidget(self)
        g_advancedTooltip.display()
      end
    else
      if self == g_tooltip.getHoveredWidget() then
        g_tooltip.hide()
	    g_tooltip.setHoveredWidget(nil)
      end
      if self == g_advancedTooltip.getHoveredWidget() then
        g_advancedTooltip.hide()
		local item = self:getItem()
		-- item:setShader("map_default")

	    g_advancedTooltip.setHoveredWidget(nil)
      end
    end
	if self.containerWindow or self:getId() == 'slot8' or self:getId() == 'slot10' then
		if hovered then
			if self.containerWindow then 
				if not self.containerWindow:isOn() and self.containerWindow:getChildById('background'):getOpacity() < 1 then g_effects.fadeIn(self.containerWindow:getChildById('background'), 200, 200*0.7) end
				self.containerWindow:setOn(true) 
			end
		else
			if self.containerWindow then 
				self.containerWindow:setOn(false) 
				scheduleEvent(function() if self.containerWindow then if not self.containerWindow:isOn() then g_effects.fadeOut(self.containerWindow:getChildById('background'), 300, 0, 300*0.3) end end end,200)
			end
		end
	end

  if not self:isDraggable() then return end

  local draggingWidget = g_ui.getDraggingWidget()
  if draggingWidget and self ~= draggingWidget then
    local gotMap = draggingWidget:getClassName() == 'UIGameMap'
    local gotItem = draggingWidget:getClassName() == 'UIItem' and not draggingWidget:isVirtual()
    if hovered and (gotItem or gotMap) then
      draggingWidget.hoveredWho = self
    else
      draggingWidget.hoveredWho = nil
    end
  end
end

function UIItem:onMouseRelease(mousePosition, mouseButton)
  if self.cancelNextRelease then
    self.cancelNextRelease = false
    return true
  end

  if self:isVirtual() then return false end

  local item = self:getItem()
  if not item or not self:containsPoint(mousePosition) then return false end

  if modules.client_options.getOption('classicControl') and not g_app.isMobile() and
     ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton) or
      (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
    g_game.look(item)
    self.cancelNextRelease = true
    return true
  elseif modules.game_interface.processMouseAction(mousePosition, mouseButton, nil, item, item, nil, nil) then
    return true
  end
  return false
end

function UIItem:canAcceptDrop(widget, mousePos)
  if not self.selectable and (self:isVirtual() or not self:isDraggable()) then return false end
  if not widget or not widget.currentDragThing then return false end

  local children = rootWidget:recursiveGetChildrenByPos(mousePos)
  for i=1,#children do
    local child = children[i]
    if child == self then
      return true
    elseif not child:isPhantom() then
      return false
    end
  end

  error('Widget ' .. self:getId() .. ' not in drop list.')
  return false
end

function UIItem:onClick(mousePos)

  if not self.selectable or not self.editable then
    return
  end



  if modules.game_itemselector then
    modules.game_itemselector.show(self)
  end
end

function UIItem:onItemChange()
 
  local tooltip = nil

  -- if self:getItemId() == 3043 then -- seta shader ao entrar na bag
	-- self:getItem():setShader("outfit_red")
  -- end
	
	
  if self:getItem() and self:getItem():getTooltip():len() > 0 then
  
    tooltip = self:getItem():getTooltip()
  end
  self:setTooltip(tooltip)
end