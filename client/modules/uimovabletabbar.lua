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
    tab:setMarginLeft(math.floor(currentMargin - tabBar.scrollOffset))
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
  local pinnedCount = tabBar:getPinnedCount()
  if not tab.pinned and newIndex <= pinnedCount then
    newIndex = pinnedCount + 1
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
  if tab.pinned then return false end
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
  return true
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

-- space reserved for the pin icon
local PIN_ICON_W   = 15
local PIN_ICON_H   = 15
local PIN_ICON_GAP = 3   -- respiro entre ícone e texto
local PIN_ICON_ML  = 6   -- margem interna da borda até o ícone
local PIN_TEXT_NUDGE = 3   -- empurrãozinho visual no texto

local function recalcTabWidth(tab)
  -- largura = texto + paddings. Ícone não entra aqui!
  local w = tab:getTextSize().width + tab:getPaddingLeft() + tab:getPaddingRight()
  tab:setWidth(w)
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
      -- removido: hideTabs(self, ...) pois não existe; basta atualizar tudo
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
  -- store original padding and prepare pin icon
  tab._basePaddingLeft = tab:getPaddingLeft()
  tab.pinIcon = g_ui.createWidget('TabPinIcon', tab)
  tab.pinIcon:hide()
  tab.pinIcon:setPhantom(true)
  tab.pinIcon:setSize({ width = PIN_ICON_W, height = PIN_ICON_H })
  tab.pinIcon:addAnchor(AnchorLeft, 'parent', AnchorLeft)
  tab.pinIcon:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
  tab.pinIcon:setMarginLeft(PIN_ICON_ML)
  addEvent(function()
    if tab and not tab:isDestroyed() then
      recalcTabWidth(tab)

      updateTabs(self)
    end
  end)
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
  if not tab or tab.pinned then
    return
  end
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
  local left = tab:getMarginLeft()
  local right = left + tab:getWidth()
  if left < 0 then
    self:scrollTabs(left)
  elseif right > self:getWidth() then
    self:scrollTabs(right - self:getWidth())
  else
    updateFade(self)
    updateNavigation(self)
  end
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

function UIMoveableTabBar:getPinnedCount()
  local count = 0
  for i = 1, #self.tabs do
    if self.tabs[i].pinned then
      count = count + 1
    end
  end
  return count
end

function UIMoveableTabBar:isPinned(tab)
  return tab and tab.pinned or false
end

local function ensurePinPadding(tab)
  -- o mínimo necessário para caber ícone (ML + W + GAP)
  local need = PIN_ICON_ML + PIN_ICON_W + PIN_ICON_GAP
  local base = tab._basePaddingLeft or tab:getPaddingLeft()

  -- se o padding original já comporta o ícone, só fazemos o "empurrão" visual
  local target = base
  if base < need then
    target = need
  end
  tab:setPaddingLeft(target + PIN_TEXT_NUDGE)
end

-- opts.append: when true, insert at end of pinned block; otherwise go to index 1
function UIMoveableTabBar:pinTab(tab, opts)
  if not tab or tab.pinned then return end
  tab.pinned = true
  tab:setDraggable(false)
  if not tab._basePaddingLeft then
    tab._basePaddingLeft = tab:getPaddingLeft()
  end
  ensurePinPadding(tab)
  if tab.pinIcon then tab.pinIcon:show() end
  
  local tabs = self.tabs
  local prev = table.find(tabs, tab)
  if prev then table.remove(tabs, prev) end

  local pinnedCount = self:getPinnedCount()
  local newIndex = (opts and opts.append) and (pinnedCount + 1) or 1
  table.insert(tabs, newIndex, tab)

  recalcTabWidth(tab)
  updateTabs(self)
end

function UIMoveableTabBar:unpinTab(tab)
  if not tab or not tab.pinned then return end
  tab.pinned = false
  tab:setDraggable(self.tabsMoveable)
  if tab._basePaddingLeft then
    tab:setPaddingLeft(tab._basePaddingLeft)
  end
  if tab.pinIcon then tab.pinIcon:hide() end
  
  local tabs = self.tabs
  local prev = table.find(tabs, tab)
  if prev then
    table.remove(tabs, prev)
    table.insert(tabs, #tabs + 1, tab)
  end

  recalcTabWidth(tab)
  updateTabs(self)
end

function UIMoveableTabBar:getPinnedTabsText()
  local out = {}
  for i = 1, #self.tabs do
    local t = self.tabs[i]
    if t.pinned then
      table.insert(out, t:getText())
    else
      break
    end
  end
  return out
end

function UIMoveableTabBar:scrollTabs(delta)
  local maxOffset = math.max(0, self.totalWidth - self:getWidth())
  self.scrollOffset = math.floor(math.max(0, math.min(self.scrollOffset + delta, maxOffset)))
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
