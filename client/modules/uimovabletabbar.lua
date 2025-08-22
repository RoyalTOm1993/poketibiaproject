-- @docclass
UIMoveableTabBar = extends(UIWidget, "UIMoveableTabBar")

-- =====================
-- Pin icon defaults
-- =====================
local PIN_ICON_DEFAULTS = {
  path    = '/images/ui/tabpin',
  width   = 15,
  height  = 14,
  dx      = 4,
  dy      = -1,
  text_dx = 10
}

local function layoutPinIcon(tab)
  if not tab then return end
  local width  = (tab.tabBar.pinIconWidth or PIN_ICON_DEFAULTS.width)
  local height = (tab.tabBar.pinIconHeight or PIN_ICON_DEFAULTS.height)
  local dx     = (tab.tabBar.pinIconDx or PIN_ICON_DEFAULTS.dx)
  local dy     = (tab.tabBar.pinIconDy or PIN_ICON_DEFAULTS.dy)
  if tab.pinned then
    local y = math.floor((tab:getHeight() - height) / 2) + dy
    tab:setIcon(tab.tabBar.pinIconPath or PIN_ICON_DEFAULTS.path)
    tab:setIconOffsetX(dx)
    tab:setIconOffsetY(y)
    tab:setIconWidth(width)
    tab:setIconHeight(height)
  else
    tab:setIcon('')
    tab:setIconOffsetX(0)
    tab:setIconOffsetY(0)
    tab:setIconWidth(0)
    tab:setIconHeight(0)
  end
end

-- =====================
-- Internal helpers
-- =====================
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
    if tabBar.scrollOffset > 0 then tabBar.prevNavigation:enable() else tabBar.prevNavigation:disable() end
  end
  if tabBar.nextNavigation then
    if tabBar.scrollOffset + tabBar:getWidth() < tabBar.totalWidth then tabBar.nextNavigation:enable() else tabBar.nextNavigation:disable() end
  end
end

local function updateFade(tabBar)
  local fade = tabBar:getChildById('tabBarFade')
  if not fade then return end
  local needsFade = tabBar.scrollOffset + tabBar:getWidth() < tabBar.totalWidth
  fade:setVisible(needsFade)
end

local function getMaxMargin(tabBar, tab)
  if #tabBar.tabs == 0 then return 0 end
  return math.max(tabBar.totalWidth - (tab and tab:getWidth() or 0), 0)
end

local function updateIndexes(tabBar, tab, xoff, yoff)
  if not tabBar.tabsMoveable or not tab then return end
  local idx = table.find(tabBar.tabs, tab)
  if not idx then return end

  local pinnedCount = tabBar:getPinnedCount()
  if idx <= pinnedCount then return end

  local myLeft = tab:getMarginLeft()
  local myRight = myLeft + tab:getWidth()

  local targetIndex = idx
  for i = 1, #tabBar.tabs do
    if i ~= idx then
      local t = tabBar.tabs[i]
      local left = t:getMarginLeft()
      local right = left + t:getWidth()

      if i <= pinnedCount then
        -- nunca atravessa bloco fixo
      else
        if myLeft < left and myRight > left then
          targetIndex = math.min(targetIndex, i)
        elseif myLeft < right and myRight > right then
          targetIndex = math.max(targetIndex, i)
        end
      end
    end
  end

  if targetIndex ~= idx then
    table.remove(tabBar.tabs, idx)
    if targetIndex < 1 then targetIndex = 1 end
    if targetIndex > #tabBar.tabs + 1 then targetIndex = #tabBar.tabs + 1 end
    table.insert(tabBar.tabs, targetIndex, tab)
    updateMargins(tabBar)
  end
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

local function applyPinnedTextOffset(tab, enabled)
  if not tab or not tab.setTextOffset then return end
  tab._baseTextOffset = tab._baseTextOffset or { x = 0, y = 0 }
  local bx = tab._baseTextOffset.x or 0
  local by = tab._baseTextOffset.y or 0
  local textDx = (tab.tabBar and tab.tabBar.pinTextDx) or PIN_ICON_DEFAULTS.text_dx
  tab:setTextOffset({ x = enabled and (bx + textDx) or bx, y = by })
end

-- recálculo simples de largura (texto + paddings)
local function recalcTabWidth(tab)
  local w = tab:getTextSize().width + tab:getPaddingLeft() + tab:getPaddingRight()
  tab:setWidth(w)
end

-- mouse/drag
local function onTabMousePress(tab, mousePos, mouseButton)
  if mouseButton == MouseRightButton then
    if tab.menuCallback then tab.menuCallback(tab, mousePos, mouseButton) end
    return true
  end
  return false
end

local function onTabMouseRelease(tab, mousePos, mouseButton)
  if mouseButton == MouseRightButton then
    if tab.menuCallback then tab.menuCallback(tab, mousePos, mouseButton) end
    return true
  end
  return false
end

local function onTabDragEnter(tab, mousePos)
  if not tab.tabBar.tabsMoveable or tab.pinned then return false end
  tab.oldX = tab:getX()
  tab.oldY = tab:getY()
  tab.dragging = true
  return true
end

local function onTabDragLeave(tab, droppedWidget, mousePos)
  if not tab.dragging then return end
  tab.dragging = false
  tab:setOn(false)
  tab:setMarginLeft(getMaxMargin(tab.tabBar, tab))
  updateTabs(tab.tabBar)
end

local function onTabDragMove(tab, mousePos, mouseMoved)
  if not tab.dragging then return end
  tab:setOn(true)
  local xoff = mousePos.x - tab.oldX
  local yoff = mousePos.y - tab.oldY

  local index = table.find(tab.tabBar.tabs, tab)
  if index == nil then return end

  local pinnedCount = tab.tabBar:getPinnedCount()
  if index <= pinnedCount then return end

  local newMargin = math.max(0, math.min(tab:getMarginLeft() + xoff, getMaxMargin(tab.tabBar, tab)))
  tab:setMarginLeft(newMargin)
  tab.oldX = mousePos.x
  tab.oldY = mousePos.y
  updateIndexes(tab.tabBar, tab, xoff, yoff)
end

-- =====================
-- Public API
-- =====================
function UIMoveableTabBar.create()
  local tabbar = UIMoveableTabBar.internalCreate()
  tabbar:setFocusable(false)
  tabbar.tabs = {}
  tabbar.selected = nil
  tabbar.tabSpacing = 0
  tabbar.tabsMoveable = false
  tabbar.scrollOffset = 0
  tabbar.totalWidth = 0
  tabbar.prevNavigation = nil
  tabbar.nextNavigation = nil
  return tabbar
end

function UIMoveableTabBar:onDestroy()
  if self.prevNavigation then self.prevNavigation:disable() end
  if self.nextNavigation then self.nextNavigation:disable() end
  self.nextNavigation = nil
  self.prevNavigation = nil
end

function UIMoveableTabBar:getTab(text)
  for i = 1, #self.tabs do
    if self.tabs[i]:getText() == text then
      return self.tabs[i]
    end
  end
  return nil
end

function UIMoveableTabBar:getCurrentPanel()
  if self.currentTab then return self.currentTab.tabPanel end
end

function UIMoveableTabBar:getCurrentTab()
  return self.currentTab
end

function UIMoveableTabBar:getPinnedCount()
  local count = 0
  for i = 1, #self.tabs do
    if self.tabs[i].pinned then count = count + 1 end
  end
  return count
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

  -- baseline de offset de texto
  tab._baseTextOffset = (tab.getTextOffset and tab:getTextOffset()) or { x = 0, y = 0 }

  tab.onGeometryChange = function()
    layoutPinIcon(tab)
  end

  addEvent(function()
    if tab and not tab:isDestroyed() then
      recalcTabWidth(tab)
      updateTabs(self)
      layoutPinIcon(tab)
      self:scrollTabs(self.totalWidth)
    end
  end)

  tab.menuCallback   = menuCallback or nil
  tab.onClick        = onTabClick
  tab.onMousePress   = onTabMousePress
  tab.onMouseRelease = onTabMouseRelease
  tab.onDragEnter    = onTabDragEnter
  tab.onDragLeave    = onTabDragLeave
  tab.onDragMove     = onTabDragMove
  tab.onDestroy      = function()
    if tab.tabPanel and not tab.tabPanel:isDestroyed() then
      tab.tabPanel:destroy()
    end
  end

  table.insert(self.tabs, tab)
  if #self.tabs == 1 then self:selectTab(tab) end
  updateTabs(self)
  return tab
end

function UIMoveableTabBar:moveTab(tab, units)
  if not tab or tab.pinned then return end
  local idx = table.find(self.tabs, tab)
  if not idx then return end

  local newIndex = idx + units
  local pinnedCount = self:getPinnedCount()
  if newIndex <= pinnedCount then newIndex = pinnedCount + 1 end
  if newIndex > #self.tabs then newIndex = #self.tabs end
  table.remove(self.tabs, idx)
  table.insert(self.tabs, newIndex, tab)
  updateTabs(self)
end

function UIMoveableTabBar:onStyleApply(styleName, styleNode)
  if styleNode['movable'] then self.tabsMoveable = styleNode['movable'] end
  if styleNode['tab-spacing'] then self:setTabSpacing(styleNode['tab-spacing']) end
  if styleNode['pin-icon-dx'] then self.pinIconDx = tonumber(styleNode['pin-icon-dx']) end
  if styleNode['pin-icon-dy'] then self.pinIconDy = tonumber(styleNode['pin-icon-dy']) end
  if styleNode['pin-icon-width'] then self.pinIconWidth = tonumber(styleNode['pin-icon-width']) end
  if styleNode['pin-icon-height'] then self.pinIconHeight = tonumber(styleNode['pin-icon-height']) end
  if styleNode['pin-text-dx'] then self.pinTextDx = tonumber(styleNode['pin-text-dx']) end
  if styleNode['pin-icon-path'] then self.pinIconPath = tostring(styleNode['pin-icon-path']) end
end

function UIMoveableTabBar:removeTab(tab)
  local idx = table.find(self.tabs, tab)
  if not idx then return end

  local wasChecked = tab:isChecked()
  local newIndex = math.min(#self.tabs - 1, idx)
  if newIndex > 0 then self:selectTab(self.tabs[newIndex]) else self.currentTab = nil end

  table.remove(self.tabs, idx)
  tab:destroy()

  if wasChecked and self.currentTab then self.currentTab:setChecked(true) end
  updateTabs(self)
end

function UIMoveableTabBar:selectTab(tab)
  if self.currentTab == tab then return end
  if tab and not table.contains(self.tabs, tab) then return end
  if not tab then return end

  if self.contentWidget then
    local selectedWidget = self.contentWidget:getLastChild()
    if selectedWidget and selectedWidget.isTab then
      self.contentWidget:removeChild(selectedWidget)
    end
    self.contentWidget:addChild(tab.tabPanel)
    tab.tabPanel:fill('parent')
  end

  if self.currentTab then self.currentTab:setChecked(false) end
  signalcall(self.onTabChange, self, tab)
  self.currentTab = tab
  tab:setChecked(true)
  tab:setOn(false)
  tab.blinking = false

  if tab.blinkEvent then removeEvent(tab.blinkEvent) tab.blinkEvent = nil end

  recalcTabWidth(tab)
  updateTabs(self)
end

function UIMoveableTabBar:scrollTabs(delta)
  local maxOffset = math.max(0, self.totalWidth - self:getWidth())
  self.scrollOffset = math.floor(math.max(0, math.min(self.scrollOffset + delta, maxOffset)))
  updateTabs(self)
end

function UIMoveableTabBar:setTabsMoveable(tabsMoveable)
  self.tabsMoveable = tabsMoveable
  for i = 1, #self.tabs do
    self.tabs[i]:setDraggable(self.tabsMoveable and not self.tabs[i].pinned)
  end
end

function UIMoveableTabBar:setNavigation(prevButton, nextButton)
  self.prevNavigation = prevButton
  self.nextNavigation = nextButton
  if self.prevNavigation then self.prevNavigation.onClick = function() self:scrollTabs(-self:getWidth() * 0.5) end end
  if self.nextNavigation then self.nextNavigation.onClick = function() self:scrollTabs(self:getWidth() * 0.5) end end
  updateNavigation(self)
end

-- ============ Pin API ============
function UIMoveableTabBar:isPinned(tab)
  return tab and tab.pinned or false
end

function UIMoveableTabBar:pinTab(tab, opts)
  if not tab or tab.pinned then return end
  tab.pinned = true
  tab:setDraggable(false)

  applyPinnedTextOffset(tab, true)
  layoutPinIcon(tab)

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

  applyPinnedTextOffset(tab, false)
  layoutPinIcon(tab)

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
    if t.pinned then table.insert(out, t:getText()) else break end
  end
  return out
end
