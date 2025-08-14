-- @docclass
UIMoveableTabBar = extends(UIWidget, "UIMoveableTabBar")

-- private functions
local function onTabClick(tab)
  tab.tabBar:selectTab(tab)
end

local function updateMargins(tabBar)

  local currentMargin = 0
  for i = 1, #tabBar.tabs do
    local tab = tabBar.tabs[i]
    tab:setMarginLeft(currentMargin - tabBar.scrollOffset)
    currentMargin = currentMargin + tabBar.tabSpacing + tab:getWidth()
  end
  tabBar.totalWidth = currentMargin > 0 and currentMargin - tabBar.tabSpacing or 0
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
    if tabBar.scrollOffset + tabBar:getWidth() < tabBar.totalWidth then
      tabBar.nextNavigation:enable()
    else
      tabBar.nextNavigation:disable()
    end
  end
end

local function updateFade(tabBar)
  local fade = tabBar:getChildById('tabBarFade')
  if not fade then return end
  local needsFade = tabBar.scrollOffset + tabBar:getWidth() < tabBar.totalWidth
  fade:setVisible(needsFade)
end

local function updateIndexes(tabBar, tab, xoff)
  local tabs = tabBar.tabs
  local currentMargin = 0
  local prevIndex = table.find(tabs, tab)
  local newIndex = prevIndex
  local xmid = xoff + tab:getWidth() / 2
  for i = 1, #tabs do
    local nextTab = tabs[i]
    if xmid >= currentMargin + nextTab:getWidth() / 2 then
      newIndex = i
    end
    currentMargin = currentMargin + tabBar.tabSpacing + nextTab:getWidth()
  end
  if newIndex ~= prevIndex then
    table.remove(tabs, prevIndex)
    table.insert(tabs, newIndex, tab)
  end
end

local function getMaxMargin(tabBar, tab)
  if #tabBar.tabs == 0 then return 0 end
  return math.max(tabBar.totalWidth - (tab and tab:getWidth() or 0), 0)
end

local function updateTabs(tabBar)
  updateMargins(tabBar)
  local maxOffset = math.max(0, tabBar.totalWidth - tabBar:getWidth())
  if tabBar.scrollOffset > maxOffset then
    tabBar.scrollOffset = maxOffset
    updateMargins(tabBar)
  end
  if not tabBar.currentTab and #tabBar.tabs > 0 then
    tabBar:selectTab(tabBar.tabs[1])
  end
  updateFade(tabBar)
  updateNavigation(tabBar)
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
  updateTabs(tab.tabBar)
  tab.tabBar.selected = nil
  return true
end

local function onTabDragMove(tab, mousePos, mouseMoved)
  if tab == tab.tabBar.selected then
    local xoff = mousePos.x - tab.hotSpot + tab.tabBar.scrollOffset

    -- update indexes
    updateIndexes(tab.tabBar, tab, xoff)

    -- update margins
    updateMargins(tab.tabBar)
    xoff = math.max(xoff, 0)
    xoff = math.min(xoff, getMaxMargin(tab.tabBar, tab))
    tab:setMarginLeft(xoff - tab.tabBar.scrollOffset)
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
  tabbar.scrollOffset = 0
  tabbar.totalWidth = 0
  tabbar.prevNavigation = nil
  tabbar.nextNavigation = nil
  tabbar.onGeometryChange = function(self, oldRect, newRect)
    if oldRect.width ~= newRect.width then
      hideTabs(self, true, self.postTabs, 0)
      updateTabs(self)
    end
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
  updateMargins(self)
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
  updateTabs(self)
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
  updateTabs(self)
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
  if not tab then return end
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
  updateTabs(self)
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
  if newIndex < 1 then
    newIndex = #self.tabs
  end

  local prevTab = self.tabs[newIndex]
  if prevTab then
    self:selectTab(prevTab)
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

function UIMoveableTabBar:scrollTabs(delta)
  local maxOffset = math.max(0, self.totalWidth - self:getWidth())
  self.scrollOffset = math.max(0, math.min(self.scrollOffset + delta, maxOffset))
  updateMargins(self)
  updateFade(self)
  updateNavigation(self)
end

function UIMoveableTabBar:setNavigation(prevButton, nextButton)
  self.prevNavigation = prevButton
  self.nextNavigation = nextButton

  if self.prevNavigation then
    self.prevNavigation.onClick = function() self:scrollTabs(-self:getWidth() * 0.5) end
  end
  if self.nextNavigation then
    self.nextNavigation.onClick = function() self:scrollTabs(self:getWidth() * 0.5) end
  end
  updateNavigation(self)
end
