UIMoveableTabBar = extends(UIWidget, "UIMoveableTabBar")

local TAB_MAX_WIDTH = 150
local TAB_MIN_WIDTH = 80

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
    tabBar.tabs[i]:setMarginLeft(currentMargin)
    currentMargin = currentMargin + tabBar.tabs[i]:getWidth() + tabBar.tabSpacing
  end
end

local function updateNavigation(tabBar)
  if tabBar.prevNavigation then
    if tabBar.scrollOffset > 0 then
      tabBar.prevNavigation:enable()
    else
      tabBar.prevNavigation:disable()
    end
  end

  if tabBar.nextNavigation then
    if tabBar.scrollOffset < tabBar.maxScrollOffset then
      tabBar.nextNavigation:enable()
    else
      tabBar.nextNavigation:disable()
    end
  end
end

local function updateIndexes(tabBar, tab, xoff)
  local tabs = tabBar.tabs
  local currentMargin = 0
  local prevIndex = table.find(tabs, tab)
  local newIndex = prevIndex
  local xmid = xoff + tab:getWidth()/2 + tabBar.scrollOffset
  for i = 1, #tabs do
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

  local maxMargin = 0
  for i = 1, #tabBar.tabs do
    if tabBar.tabs[i] ~= tab then
      maxMargin = maxMargin + tabBar.tabs[i]:getWidth()
    end
  end
  return maxMargin + tabBar.tabSpacing * (#tabBar.tabs - 1)
end

local function updateLayout(tabBar)
  if #tabBar.tabs == 0 then
    updateNavigation(tabBar)
    return
  end

  local parentWidth = tabBar:getWidth()
  local count = #tabBar.tabs
  local availableWidth = parentWidth - (count - 1) * tabBar.tabSpacing
  local tabWidth = clamp(math.floor(availableWidth / count), TAB_MIN_WIDTH, TAB_MAX_WIDTH)

  for i = 1, count do
    tabBar.tabs[i]:setWidth(tabWidth)
  end

  tabBar.totalWidth = tabWidth * count + (count - 1) * tabBar.tabSpacing
  tabBar.maxScrollOffset = math.max(0, tabBar.totalWidth - parentWidth)
  tabBar.scrollStep = tabWidth + tabBar.tabSpacing
  if tabBar.scrollOffset > tabBar.maxScrollOffset then
    tabBar.scrollOffset = tabBar.maxScrollOffset
  end

  updateMargins(tabBar)
  updateNavigation(tabBar)
  if not tabBar.currentTab and #tabBar.tabs > 0 then
    tabBar:selectTab(tabBar.tabs[1])
  end
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
    updateIndexes(tab.tabBar, tab, xoff)
    updateIndexes(tab.tabBar, tab, xoff)

    -- update margins
    updateMargins(tab.tabBar)
    xoff = math.max(xoff, -tab.tabBar.scrollOffset)
    xoff = math.min(xoff, getMaxMargin(tab.tabBar, tab) - tab.tabBar.scrollOffset)
    tab:setMarginLeft(xoff)
  end
end

local function tabBlink(tab, step)
  local step = step or 0
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
                              updateLayout(tabbar)
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
  updateLayout(self)
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

  updateLayout(self)
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
  if styleNode['movable'] then
    self.tabsMoveable = styleNode['movable']
  end
  if styleNode['tab-spacing'] then
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
  table.remove(self.tabs, index)
  if self.currentTab == tab then
    self:selectPrevTab()
    if #self.tabs == 0 then
      self.currentTab = nil
    end
  end
  if tab.blinkEvent then
    removeEvent(tab.blinkEvent)
  end
  updateLayout(self)
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

function UIMoveableTabBar:getCurrentTab()
  return self.currentTab
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