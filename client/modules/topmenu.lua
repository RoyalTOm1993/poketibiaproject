-- private variables
local topMenu
local TopToggleButtonNew
local fpsUpdateEvent = nil
local statusUpdateEvent = nil
local animationEvent = nil

local menuHeight = 52
local animationStep = 5
local animationInterval = 15

-- Função necessária para criar os botões nos painéis
local function addButton(id, description, icon, callback, panel, toggle, front, index)
  local class = toggle and 'TopToggleButton' or 'TopButton'
  if topMenu.reverseButtons then front = not front end

  local button = panel:getChildById(id)
  if not button then
    button = g_ui.createWidget(class)
    if front then
      panel:insertChild(1, button)
    else
      panel:addChild(button)
    end
  end

  local function updateTopMenuButtonOrder()
  if not topMenu or not topMenu.gameButtonsPanel then
    return
  end

  local children = topMenu.gameButtonsPanel:getChildren()
  table.sort(children, function(a, b)
    return (a.index or math.huge) < (b.index or math.huge)
  end)
  topMenu.gameButtonsPanel:reorderChildren(children)
end

  local function updateTopMenuButtonOrder()
  if not topMenu or not topMenu.gameButtonsPanel then
    return
  end

  local children = topMenu.gameButtonsPanel:getChildren()
  table.sort(children, function(a, b)
    return (a.index or math.huge) < (b.index or math.huge)
  end)
  topMenu.gameButtonsPanel:reorderChildren(children)
end

  local function updateTopMenuButtonOrder()
  if not topMenu or not topMenu.gameButtonsPanel then
    return
  end

  local children = topMenu.gameButtonsPanel:getChildren()
  table.sort(children, function(a, b)
    return (a.index or math.huge) < (b.index or math.huge)
  end)
  topMenu.gameButtonsPanel:reorderChildren(children)
end

  button:setId(id)
  button:setTooltip(description)
  button:setIcon(resolvepath(icon, 3))

  button.onMouseRelease = function(widget, mousePos, mouseButton)
    if widget:containsPoint(mousePos) and mouseButton ~= MouseMidButton and mouseButton ~= MouseTouch then
      callback()
      return true
    end
  end
  button.onTouchRelease = button.onMouseRelease

  if not button.index and type(index) == 'number' then
    button.index = index
  end

  updateTopMenuButtonOrder()

  return button
end

-- private functions
local function stopAnimation()
  if animationEvent then
    removeEvent(animationEvent)
    animationEvent = nil
  end
end

local function animateHide()
  stopAnimation()
  local menuMargin = topMenu:getMarginTop() or 0
  local toggleMargin = TopToggleButtonNew:getMarginTop() or 50
  local function step()
    menuMargin = menuMargin - animationStep
    toggleMargin = toggleMargin - animationStep
    if menuMargin <= -menuHeight then
      menuMargin = -menuHeight
      toggleMargin = 0
      topMenu:setMarginTop(menuMargin)
      topMenu:hide()
      TopToggleButtonNew:setMarginTop(toggleMargin)
      TopToggleButtonNew:setOpacity(0.15)
      stopAnimation()
      updatePing()
      updateFps()
      return
    else
      topMenu:setMarginTop(menuMargin)
      TopToggleButtonNew:setMarginTop(toggleMargin)
      animationEvent = scheduleEvent(step, animationInterval)
    end
  end
  animationEvent = scheduleEvent(step, animationInterval)
end

local function animateShow()
  stopAnimation()
  topMenu:show()
  local menuMargin = topMenu:getMarginTop() or -menuHeight
  local toggleMargin = TopToggleButtonNew:getMarginTop() or 0
  if menuMargin > 0 then menuMargin = 0 end
  if toggleMargin > 50 then toggleMargin = 50 end

  local function step()
    menuMargin = menuMargin + animationStep
    toggleMargin = toggleMargin + animationStep
    if menuMargin >= 0 then
      menuMargin = 0
      toggleMargin = 50
      topMenu:setMarginTop(menuMargin)
      TopToggleButtonNew:setMarginTop(toggleMargin)
      TopToggleButtonNew:setOpacity(0.0)
      stopAnimation()
      updatePing()
      updateFps()
      return
    else
      topMenu:setMarginTop(menuMargin)
      TopToggleButtonNew:setMarginTop(toggleMargin)
      animationEvent = scheduleEvent(step, animationInterval)
    end
  end
  animationEvent = scheduleEvent(step, animationInterval)
end

-- public functions
function init()
  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
    onPingBack = updatePing
  })

  topMenu = g_ui.createWidget('TopMenu', g_ui.getRootWidget())
  topMenu:hide()

  TopToggleButtonNew = g_ui.createWidget('TopToggleButtonNew', g_ui.getRootWidget())
  TopToggleButtonNew:setMarginTop(50)
  TopToggleButtonNew:setOpacity(0.0)
  TopToggleButtonNew:hide()

  TopToggleButtonNew.onHoverChange = function(widget, hovered)
    if hovered then
      widget:setOpacity(1.0)
    else
      widget:setOpacity(topMenu:isVisible() and 0.0 or 0.15)
    end
  end

  TopToggleButtonNew.onMouseRelease = function(widget, mousePos, mouseButton)
    if widget:containsPoint(mousePos) and mouseButton ~= MouseMidButton and mouseButton ~= MouseTouch then
      toggleTopMenu()
      return true
    end
  end
  TopToggleButtonNew.onTouchRelease = TopToggleButtonNew.onMouseRelease

  g_keyboard.bindKeyDown('Ctrl+Shift+T', toggleTopMenu)

  if g_game.isOnline() then
    scheduleEvent(online, 10)
  end

  updateFps()
  updateStatus()
end

function terminate()
  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
    onPingBack = updatePing
  })

  removeEvent(fpsUpdateEvent)
  removeEvent(statusUpdateEvent)
  stopAnimation()

  g_keyboard.unbindKeyDown('Ctrl+Shift+T')
  if topMenu then topMenu:destroy() end
  if TopToggleButtonNew then TopToggleButtonNew:destroy() end
end

function online()
  topMenu:show()
  topMenu:setMarginTop(0)
  TopToggleButtonNew:setMarginTop(50)
  TopToggleButtonNew:setOpacity(0.0)
  TopToggleButtonNew:show()

  if topMenu.onlineLabel then topMenu.onlineLabel:hide() end
  showGameButtons()

  if topMenu.pingLabel then
    addEvent(function()
      if modules.client_options.getOption('showPing') and (g_game.getFeature(GameClientPing) or g_game.getFeature(GameExtendedClientPing)) then
        topMenu.pingLabel:show()
      else
        topMenu.pingLabel:hide()
      end
    end)
  end
end

function offline()
  topMenu:hide()
  TopToggleButtonNew:setOpacity(0.15)
  TopToggleButtonNew:hide()

  if topMenu.hideIngame then show() end
  if topMenu.onlineLabel then topMenu.onlineLabel:show() end

  hideGameButtons()
  if topMenu.pingLabel then topMenu.pingLabel:hide() end
  updateStatus()

  if topMenu.fpsLabel then topMenu.fpsLabel:hide() end
  updateFps()
end

function toggleTopMenu()
  if not topMenu or not TopToggleButtonNew then return end

  if topMenu:isVisible() and not animationEvent then
    animateHide()
  elseif not animationEvent then
    animateShow()
  end
end

function updateFps()
  if not topMenu.fpsLabel then return end
  fpsUpdateEvent = scheduleEvent(updateFps, 500)
  local text = 'FPS: ' .. g_app.getFps()
  topMenu.fpsLabel:setText(text)
end

function updatePing(ping)
  if not topMenu.pingLabel then return end
  if g_proxy and g_proxy.getPing() > 0 then
    ping = g_proxy.getPing()
  end

  local text = 'Ping: '
  local color
  if ping < 0 then
    text = text .. "??"
    color = 'yellow'
  else
    text = text .. ping .. ' ms'
    color = ping >= 500 and 'red' or ping >= 250 and 'yellow' or 'green'
  end

  topMenu.pingLabel:setColor(color)
  topMenu.pingLabel:setText(text)
end

function setPingVisible(enable)
  if not topMenu.pingLabel then return end
  topMenu.pingLabel:setVisible(enable)
end

function setFpsVisible(enable)
  if not topMenu.fpsLabel then return end
  topMenu.fpsLabel:setVisible(enable)
end

-- Botões do menu superior
function addLeftButton(id, description, icon, callback, front, index)
  return addButton(id, description, icon, callback, topMenu.gameButtonsPanel, false, front, index)
end

function addLeftToggleButton(id, description, icon, callback, front, index)
  return addButton(id, description, icon, callback, topMenu.gameButtonsPanel, true, front, index)
end

function addRightButton(id, description, icon, callback, front, index)
  return addButton(id, description, icon, callback, topMenu.gameButtonsPanel, false, front, index)
end

function addRightToggleButton(id, description, icon, callback, front, index)
  return addButton(id, description, icon, callback, topMenu.gameButtonsPanel, true, front, index)
end

-- Botões exclusivos do jogo
function addLeftGameButton(id, description, icon, callback, front, index)
  local button = addButton(id, description, icon, callback, topMenu.gameButtonsPanel, false, front, index)
  if modules.game_buttons then modules.game_buttons.takeButton(button) end
  return button
end

function addLeftGameToggleButton(id, description, icon, callback, front, index)
  local button = addButton(id, description, icon, callback, topMenu.gameButtonsPanel, true, front, index)
  if modules.game_buttons then modules.game_buttons.takeButton(button) end
  return button
end

function addRightGameButton(id, description, icon, callback, front, index)
  local button = addButton(id, description, icon, callback, topMenu.gameButtonsPanel, false, front, index)
  if modules.game_buttons then modules.game_buttons.takeButton(button) end
  return button
end

function addRightGameToggleButton(id, description, icon, callback, front, index)
  local button = addButton(id, description, icon, callback, topMenu.gameButtonsPanel, true, front, index)
  if modules.game_buttons then modules.game_buttons.takeButton(button) end
  return button
end

function showGameButtons()
  if not topMenu then return end
  topMenu.gameButtonsPanel:show()
  if modules.game_buttons then
    modules.game_buttons.takeButtons(topMenu.gameButtonsPanel:getChildren())
  end
end

function hideGameButtons()
  if not topMenu then return end
  topMenu.gameButtonsPanel:hide()
end

function getButton(id)
  return topMenu and topMenu:recursiveGetChildById(id)
end

function getTopMenu()
  return topMenu
end

function updateStatus()
  removeEvent(statusUpdateEvent)
  if not Services or not Services.status or Services.status:len() < 4 then return end
  if not topMenu or not topMenu.onlineLabel or g_game.isOnline() then return end

  HTTP.postJSON(Services.status, { type = "cacheinfo" }, function(data, err)
    if err then
      g_logger.warning("HTTP error for " .. Services.status .. ": " .. err)
      statusUpdateEvent = scheduleEvent(updateStatus, 5000)
      return
    end
    if data.online then
      topMenu.onlineLabel:setText(data.online)
    elseif data.playersonline then
      topMenu.onlineLabel:setText(data.playersonline .. " players online")
    end
    if data.discord_online and topMenu.discordLabel then
      topMenu.discordLabel:setText(data.discord_online)
    end
    if data.discord_link and topMenu.discordLabel and topMenu.discord then
      local onClick = function() g_platform.openUrl(data.discord_link) end
      topMenu.discordLabel.onClick = onClick
      topMenu.discord.onClick = onClick
    end
    statusUpdateEvent = scheduleEvent(updateStatus, 60000)
  end)
end
