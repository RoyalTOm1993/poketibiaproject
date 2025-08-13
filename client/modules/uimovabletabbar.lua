UIMoveableTabBar = extends(UIWidget, "UIMoveableTabBar")

local TAB_MAX_WIDTH = 150

local function clamp(v, min, max)
  return math.max(min, math.min(max, v))
end

-- private functions
local function onTabClick(tab)
  tab.tabBar:selectTab(tab)
end

local function updateMargins(tabBar)
  if #tabBar.tabs == 0 then return end

  local currentMargin = -tabBar.scrollOffset
  for i = 1, #tabBar.tabs do
    local tab = tabBar.tabs[i]
    if tab:isVisible() then
      tab:setMarginLeft(currentMargin)
      currentMargin = currentMargin + tab:getWidth() + tabBar.tabSpacing
    end
  end

local function updateNavigation(tabBar)
  if tabBar.prevNavigation then
    if tabBar.scrollOffset > 0 then
      tabBar.prevNavigation:enable()
    else
    local function updateIndexes(tabBar, tab, xoff)
    local nextTab = tabs[i]
    if xmid >= currentMargin + nextTab:getWidth()/2 then
      newIndex = table.find(tabs, nextTab)
    end
    currentMargin = currentMargin + tabBar.tabs[i]:getWidth() + tabBar.tabSpacing
  end
  if newIndex ~= prevIndex then
    table.remove(tabs, table.find(tabs, tab))
    table.insert(tabs, newIndex, tab)
  end
  updateNavigation(tabBar)
end

local function getMaxMargin(tabBar, tab)
  if #tabBar.tabs == 0 then return 0 end

  local count = 0
  for i = 1, #tabBar.tabs do
    local t = tabBar.tabs[i]
    if t ~= tab and t:isVisible() then
      maxMargin = maxMargin + t:getWidth()
      count = count + 1
    end
  end
  return maxMargin + tabBar.tabSpacing * math.max(count - 1, 0)
end

function UIMoveableTabBar:updateTabs()
  if #self.tabs == 0 then
    updateNavigation(self)
    return
  end

  local parentWidth = self:getWidth()
  local count = #self.tabs
  local availableWidth = parentWidth - (count - 1) * self.tabSpacing
  local tabWidth = math.min(math.floor(availableWidth / count), TAB_MAX_WIDTH)

  for i = 1, count do
    local tab = self.tabs[i]
    tab:setWidth(tabWidth)
  end

  self.totalWidth = tabWidth * count + (count - 1) * self.tabSpacing
  self.maxScrollOffset = 0
  self.scrollOffset = 0
  self.scrollStep = tabWidth + self.tabSpacing

  updateMargins(self)
  updateNavigation(self)
  if not self.currentTab and #self.tabs > 0 then
    self:selectTab(self.tabs[1])
  end
end

function UIMoveableTabBar:hideTabs()
  -- tabs remain visible; recompute widths and rely on clipping to truncate
  self:updateTabs()
end

local function onTabMousePress(tab, mousePos, mouseButton)
  if mouseButton == MouseRightButton then
    if tab.menuCallback then tab.menuCallback(tab, mousePos, mouseButton) end
    return true
  end
end

local function onTabDragEnter(tab, mousePos)
  tab:raise()
  tab.hotSpot = mousePos.x - tab:getMarginLeft()
  tab.tabBar.selected = tab
  return true
end

local function onTabDragLeave(tab)
  updateMargins(tab.tabBar)
  tab.tabBar.selected = nil
  return true
end

local function onTabDragMove(tab, mousePos, mouseMoved)
  if tab == tab.tabBar.selected then
    local xoff = mousePos.x - tab.hotSpot

    -- update indexes
local function tabBlink(tab, step)
  tab:setOn(not tab:isOn())

  removeEvent(tab.blinkEvent)
  if step < 4 then
    tab.blinkEvent = scheduleEvent(function() tabBlink(tab, step+1) end, 500)
  else
    tab:setOn(true)
    tab.blinkEvent = nil
  end
end

-- public functions
function UIMoveableTabBar.create()
  local tabbar = UIMoveableTabBar.internalCreate()
  tabbar:setFocusable(false)
  tabbar.tabs = {}
  tabbar.selected = nil  -- dragged tab
  tabbar.tabSpacing = 0
  tabbar.tabsMoveable = false
  tabbar.prevNavigation = nil
  tabbar.nextNavigation = nil
  tabbar.scrollOffset = 0
  tabbar.maxScrollOffset = 0
  tabbar.scrollStep = 0
  tabbar.onGeometryChange = function()
                              tabbar:updateTabs()
                            end
  return tabbar
end

function UIMoveableTabBar:onDestroy()
  if self.prevNavigation then
    self.prevNavigation:disable()
  end

  if self.nextNavigation then
    self.nextNavigation:disable()
  end

  self.nextNavigation = nil
  self.prevNavigation = nil
end

function UIMoveableTabBar:setContentWidget(widget)
  self.contentWidget = widget
  if #self.tabs > 0 then
    self.contentWidget:addChild(self.tabs[1].tabPanel)
  end
end

function UIMoveableTabBar:setTabSpacing(tabSpacing)
  self.tabSpacing = tabSpacing
  self:updateTabs()
end

function UIMoveableTabBar:addTab(text, panel, menuCallback)
  if panel == nil then
    panel = g_ui.createWidget(self:getStyleName() .. 'Panel')
    panel:setId('tabPanel')
  end

  local tab = g_ui.createWidget(self:getStyleName() .. 'Button', self)
  panel.isTab = true
  tab.tabPanel = panel
  tab.tabBar = self
  tab:setId('tab')
  tab:setDraggable(self.tabsMoveable)
  tab:setText(text)
  tab:setClipping(true)
  tab:setWidth(tab:getTextSize().width + tab:getPaddingLeft() + tab:getPaddingRight())
  tab.menuCallback = menuCallback or nil
  tab.onClick = onTabClick
  tab.onMousePress = onTabMousePress
  tab.onDragEnter = onTabDragEnter
  tab.onDragLeave = onTabDragLeave
  tab.onDragMove = onTabDragMove
  tab.onDestroy = function() tab.tabPanel:destroy() end

  table.insert(self.tabs, tab)
  if #self.tabs == 1 then
    self:selectTab(tab)
  end

  self:updateTabs()
  return tab
end

-- Additional function to move the tab by lua
function UIMoveableTabBar:moveTab(tab, units)
  local index = table.find(self.tabs, tab)
  if index == nil then return end

  local focus = false
  if self.currentTab == tab then
    self:selectPrevTab()
    focus = true
  end

  table.remove(self.tabs, index)

  local newIndex = math.min(#self.tabs+1, math.max(index + units, 1))
  table.insert(self.tabs, newIndex, tab)
  if focus then self:selectTab(tab) end
  updateMargins(self)
  updateNavigation(self)
  return newIndex
end

function UIMoveableTabBar:onStyleApply(styleName, styleNode)
    self:setTabSpacing(styleNode['tab-spacing'])
  end
end

function UIMoveableTabBar:clearTabs()
  while #self.tabs > 0 do
    self:removeTab(self.tabs[#self.tabs])
  end
end

function UIMoveableTabBar:removeTab(tab)
  local index = table.find(self.tabs, tab)
  if not index then
    return
  end

  local wasCurrent = (self.currentTab == tab)
  table.remove(self.tabs, index)
  if wasCurrent then
    if #self.tabs > 0 then
      local newIndex = math.min(index, #self.tabs)
      self:selectTab(self.tabs[newIndex])
    else
      self.currentTab = nil
    end
  end

  if tab.blinkEvent then
    removeEvent(tab.blinkEvent)

  end
  self:updateTabs()
  tab:destroy()
end

function UIMoveableTabBar:getTab(text)
  for _, tab in pairs(self.tabs) do
    if tab:getText():lower() == text:lower() then
      return tab
    end
  end
end

function UIMoveableTabBar:selectTab(tab)
  if self.currentTab == tab then return end
  if self.contentWidget then
    local selectedWidget = self.contentWidget:getLastChild()
    if selectedWidget and selectedWidget.isTab then
      self.contentWidget:removeChild(selectedWidget)
    end
    self.contentWidget:addChild(tab.tabPanel)
    tab.tabPanel:fill('parent')
  end

  if self.currentTab then
    self.currentTab:setChecked(false)
  end
  signalcall(self.onTabChange, self, tab)
  self.currentTab = tab
  tab:setChecked(true)
  tab:setOn(false)
  tab.blinking = false

  if tab.blinkEvent then
    removeEvent(tab.blinkEvent)
    tab.blinkEvent = nil
  end

  local parent = tab:getParent()
  parent:focusChild(tab, MouseFocusReason)
  self:ensureVisible(tab)
  updateNavigation(self)
end

function UIMoveableTabBar:selectNextTab()
  if self.currentTab == nil then
    return
  end

  local index = table.find(self.tabs, self.currentTab)
  if index == nil then
    return
  end

  local newIndex = index + 1
  if newIndex > #self.tabs then
    newIndex = 1
  end
  local nextTab = self.tabs[newIndex]
  if nextTab then
    self:selectTab(nextTab)
  end
end

function UIMoveableTabBar:selectPrevTab()
  if self.currentTab == nil then
    return
  end

  local index = table.find(self.tabs, self.currentTab)
  if index == nil then
    return
  end

  local newIndex = index - 1
  if newIndex <= 0 then
    newIndex = #self.tabs
  end
  local prevTab = self.tabs[newIndex]
  if prevTab then
    self:selectTab(prevTab)
  end
end

function UIMoveableTabBar:setScrollOffset(offset)
  self.scrollOffset = math.max(0, math.min(offset, self.maxScrollOffset))
  updateMargins(self)
  updateNavigation(self)
  signalcall(self.onScroll, self, self.scrollOffset)
end

function UIMoveableTabBar:scroll(delta)
  self:setScrollOffset(self.scrollOffset + delta)
end

function UIMoveableTabBar:ensureVisible(tab)
  local left = tab:getMarginLeft()
  local right = left + tab:getWidth()
  if left < 0 then
    self:scroll(left)
  elseif right > self:getWidth() then
    self:scroll(right - self:getWidth())
  end
end

function UIMoveableTabBar:blinkTab(tab)
  if tab:isChecked() then return end
  tab.blinking = true
  tabBlink(tab)
end

function UIMoveableTabBar:getTabPanel(tab)
  return tab.tabPanel
end

function UIMoveableTabBar:getCurrentTabPanel()
  if self.currentTab then
    return self.currentTab.tabPanel
  end
end

function UIMoveableTabBar:setNavigation(prevButton, nextButton)
  self.prevNavigation = prevButton
  self.nextNavigation = nextButton

  if self.prevNavigation then
     self.prevNavigation.onClick = function() self:scroll(-self.scrollStep) end
  end
  if self.nextNavigation then
     self.nextNavigation.onClick = function() self:scroll(self.scrollStep) end
  end
  updateNavigation(self)
end
