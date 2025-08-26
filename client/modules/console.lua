SpeakTypesSettings = {
  none = {},
  say = { speakType = MessageModes.Say, color = '#FFFF00' },
  whisper = { speakType = MessageModes.Whisper, color = '#FFFF00' },
  yell = { speakType = MessageModes.Yell, color = '#FFFF00' },
  broadcast = { speakType = MessageModes.GamemasterBroadcast, color = '#F55E5E' },
  private = { speakType = MessageModes.PrivateTo, color = '#5FF7F7', private = true },
  privateRed = { speakType = MessageModes.GamemasterTo, color = '#F55E5E', private = true },
  privatePlayerToPlayer = { speakType = MessageModes.PrivateTo, color = '#9F9DFD', private = true },
  privatePlayerToNpc = { speakType = MessageModes.NpcTo, color = '#9F9DFD', private = true, npcChat = true },
  privateNpcToPlayer = { speakType = MessageModes.NpcFrom, color = '#5FF7F7', private = true, npcChat = true },
  channelYellow = { speakType = MessageModes.Channel, color = '#FFFF00' },
  channelWhite = { speakType = MessageModes.ChannelManagement, color = '#FFFFFF' },
  channelRed = { speakType = MessageModes.GamemasterChannel, color = '#F55E5E' },
  channelOrange = { speakType = MessageModes.ChannelHighlight, color = '#f36500' },
  monsterSay = { speakType = MessageModes.MonsterSay, color = '#FE6500', hideInConsole = true},
  monsterYell = { speakType = MessageModes.MonsterYell, color = '#FE6500', hideInConsole = true},
  spell = { speakType = MessageModes.Spell, color = '#F5A900', hideInConsole = true },
  rvrAnswerFrom = { speakType = MessageModes.RVRAnswer, color = '#FE6500' },
  rvrAnswerTo = { speakType = MessageModes.RVRAnswer, color = '#FE6500' },
  rvrContinue = { speakType = MessageModes.RVRContinue, color = '#FFFF00' },
}

SpeakTypes = {
  [MessageModes.Say] = SpeakTypesSettings.say,
  [MessageModes.Whisper] = SpeakTypesSettings.whisper,
  [MessageModes.Yell] = SpeakTypesSettings.yell,
  [MessageModes.GamemasterBroadcast] = SpeakTypesSettings.broadcast,
  [MessageModes.PrivateFrom] = SpeakTypesSettings.private,
  [MessageModes.GamemasterPrivateFrom] = SpeakTypesSettings.privateRed,
  [MessageModes.NpcTo] = SpeakTypesSettings.privatePlayerToNpc,
  [MessageModes.NpcFrom] = SpeakTypesSettings.privateNpcToPlayer,
  [MessageModes.Channel] = SpeakTypesSettings.channelYellow,
  [MessageModes.ChannelManagement] = SpeakTypesSettings.channelWhite,
  [MessageModes.GamemasterChannel] = SpeakTypesSettings.channelRed,
  [MessageModes.ChannelHighlight] = SpeakTypesSettings.channelOrange,
  [MessageModes.MonsterSay] = SpeakTypesSettings.monsterSay,
  [MessageModes.MonsterYell] = SpeakTypesSettings.monsterYell,
  [MessageModes.Spell] = SpeakTypesSettings.spell,
  [MessageModes.BarkLow] = SpeakTypesSettings.monsterSay,
  [MessageModes.BarkLoud] = SpeakTypesSettings.monsterYell,
  [MessageModes.RVRChannel] = SpeakTypesSettings.channelWhite,
  [MessageModes.RVRContinue] = SpeakTypesSettings.rvrContinue,
  [MessageModes.RVRAnswer] = SpeakTypesSettings.rvrAnswerFrom,
  [MessageModes.NpcFromStartBlock] = SpeakTypesSettings.privateNpcToPlayer,

  -- ignored types

}

SayModes = {
  [1] = { speakTypeDesc = 'whisper', icon = '/images/game/console/whisper' },
  [2] = { speakTypeDesc = 'say', icon = '/images/game/console/say' },
  [3] = { speakTypeDesc = 'yell', icon = '/images/game/console/yell' }
}

ChannelEventFormats = {
  [ChannelEvent.Join] = '%s joined the channel.',
  [ChannelEvent.Leave] = '%s left the channel.',
  [ChannelEvent.Invite] = '%s has been invited to the channel.',
  [ChannelEvent.Exclude] = '%s has been removed from the channel.',
}

MAX_HISTORY = 500
MAX_LINES = 100
HELP_CHANNEL = 9
FLOATING_MAX_LINES = 15

consolePanel = nil
consoleContentPanel = nil
consoleTabBar = nil
consoleTextEdit = nil
consoleToggleChat = nil
channels = nil
channelsWindow = nil
communicationWindow = nil
ownPrivateName = nil
messageHistory = {}
currentMessageIndex = 0
ignoreNpcMessages = false
defaultTab = nil
serverTab = nil
violationsChannelId = nil
violationWindow = nil
violationReportTab = nil
ignoredChannels = {}
filters = {}

floatingMode = false
floatingPos = nil
dragOffset = nil
topResizeBorder = nil
rightResizeBorder = nil
lastNpcName = nil
floatingConsolePanel = nil
floatingConsoleBuffer = nil

-- pinned tabs persistence
local pinsToRestore = nil
local pinsWantedSet = nil
-- cache de pins por personagem (lido do g_settings em load())
local pinsByCharCache = nil

local communicationSettings = {
  useIgnoreList = true,
  useWhiteList = true,
  privateMessages = false,
  yelling = false,
  allowVIPs = false,
  ignoredPlayers = {},
  whitelistedPlayers = {}
}

local sendMessage

-- ==========================
-- Helpers de g_settings (compat)
-- ==========================
local function settingsSetNumber(key, value)
  if g_settings.setNumber then
    g_settings.setNumber(key, value)
  else
    g_settings.set(key, value)
  end
end

local function settingsGetNumber(key, defaultValue)
  if g_settings.getNumber then
    local v = g_settings.getNumber(key)
    if v and v > 0 then return v end
  else
    local v = tonumber(g_settings.get(key))
    if v and v > 0 then return v end
  end
  return defaultValue
end

-- =========================================================
--                HELPERS / NOVA MECNICA ENTER
-- =========================================================
local function isBlank(s)
  return not s or s:match('^%s*$') ~= nil
end

-- Flag para impedir que o Enter global esconda o chat imediatamente
-- aps o envio de mensagem (mesmo frame).
local suppressGlobalEnter = false

-- Flag para travar o chat contra ocultar com Enter
local chatLocked = false

-- Nome do setting que guarda se o chat estava oculto
local chatHiddenSetting = 'chatHidden'

-- Detecta se existe OUTRO input focado (respeita Regra 4).
-- NO usa g_ui.getFocusedWidget (no existe nesse client).
local function isOtherTextInputFocused()
  if not rootWidget then return false end
  local w = rootWidget:getFocusedChild()
  if not w or w == consoleTextEdit then return false end

  local node = w
  while node do
    local cls = node.getClassName and node:getClassName() or ''
    cls = cls:lower()
    if cls:find('text') or cls:find('edit') or cls:find('input') or cls:find('number') or cls:find('secure') then
      return true
    end
    node = node.getParent and node:getParent() or nil
  end
  return false
end

-- Handler GLOBAL do ENTER (funciona em qualquer lugar)
local function handleGlobalEnter()
  if suppressGlobalEnter then return end
  if not g_game.isOnline() then return end
  if not consolePanel then return end

  -- se existe outro input focado (ex: donate/pix), ignora
  if isOtherTextInputFocused() then return end

  local chatHidden = not consolePanel:isVisible()
  if chatHidden then
    -- Regra 2: se chat oculto, mostrar
    lastSentWasMessage = true
    suppressGlobalEnter = true
    hideAndShowChat(false)
    addEvent(function()
      if consoleTextEdit then
        consoleTextEdit:setCursorVisible(true)
        consoleTextEdit:focus()
      end
    end)
    scheduleEvent(function()
      suppressGlobalEnter = false
    end, 50)
    return
  end

  -- chat visível
  if not consoleTextEdit then return end
  local txt = consoleTextEdit:getText()

  -- Regra 1: se não houver texto -> ocultar chat (se não estiver travado)
  if isBlank(txt) then
    if not chatLocked then
      hideAndShowChat(true)
    end
    return
  end

  -- Se houver texto, não fazemos nada aqui (não esconder!);
  -- o envio continua sendo feito pela lógica já existente quando o campo está focado.
  return
end

local lastSentWasMessage = false
local function sendCurrentMessage()
  if not consolePanel or not consolePanel:isVisible() then
    return
  end
  if suppressGlobalEnter then
    return
  end
  local message = consoleTextEdit:getText()
  if #message == 0 then
    if lastSentWasMessage then
      lastSentWasMessage = false
      return
    end
    if not chatLocked then
      hideAndShowChat(true)
    end
    return
  end
  if not isChatEnabled() then return end

  -- Evita que o Enter global esconda o chat no mesmo frame do envio
  suppressGlobalEnter = true
  scheduleEvent(function() suppressGlobalEnter = false end, 50)

  consoleTextEdit:clearText()

  -- send message
  sendMessage(message)
  lastSentWasMessage = true
end

function toggleChatLock(widget)
  chatLocked = not chatLocked
  local button = widget or (consolePanel and consolePanel:getChildById('chatButton'))
  if button then
    button:setOn(chatLocked)
  end
end


function init()
  connect(g_game, {
    onTalk = onTalk,
    onChannelList = onChannelList,
    onOpenChannel = onOpenChannel,
    onCloseChannel = onCloseChannel,
    onChannelEvent = onChannelEvent,
    onOpenPrivateChannel = onOpenPrivateChannel,
    onOpenOwnPrivateChannel = onOpenOwnPrivateChannel,
    onRuleViolationChannel = onRuleViolationChannel,
    onRuleViolationRemove = onRuleViolationRemove,
    onRuleViolationCancel = onRuleViolationCancel,
    onRuleViolationLock = onRuleViolationLock,
    onGameStart = online,
    onGameEnd = offline,
  })

  g_ui.importStyle('/data/styles/10-buttons.otui')
  g_ui.importStyle('/data/styles/20-tabbars.otui')
  g_ui.importStyle('/data/styles/40-console.otui')

  consolePanel = g_ui.loadUI('console', modules.game_interface.getBottomPanel())
  assert(consolePanel, 'Failed to load console.otui')
  consoleTextEdit = consolePanel:getChildById('consoleTextEdit')
  consoleContentPanel = consolePanel:getChildById('consoleContentPanel')
  consoleTabBar = consolePanel:getChildById('consoleTabBar')
  topResizeBorder = consolePanel:getChildById('topResizeBorder')
  rightResizeBorder = consolePanel:getChildById('rightResizeBorder')
  topResizeBorder.minimum = 122
  rightResizeBorder.minimum = 448
  consoleTabBar:setContentWidget(consoleContentPanel)
  floatingConsolePanel = g_ui.createWidget('FloatingConsolePanel', modules.game_interface.getRootPanel())
  floatingConsolePanel:setVisible(false)
  floatingConsolePanel:getChildById('consoleScrollBar'):hide()
  floatingConsoleBuffer = floatingConsolePanel:getChildById('consoleBuffer')
  connect(consoleTextEdit, {
    onFocusChange = function(_, focused)
      if not focused and consolePanel:isVisible() then
        scheduleEvent(function() consoleTextEdit:focus() end, 50)
      end
    end
  })

  connect(consolePanel, {
    onVisibilityChange = function(_, visible)
      if visible then
        scheduleEvent(function() consoleTextEdit:focus() end, 50)
      end
    end
  })

  consoleTextEdit.onFocusChange = function(_, focused)
    if not focused and consolePanel:isVisible() then
      scheduleEvent(function() consoleTextEdit:focus() end, 50)
    end
  end
  -- Remove the Ignore Players icon instance so the layout reflows
  do
    local ignoreBtn = nil
    if consolePanel then
      ignoreBtn = consolePanel:getChildById('ignoreButton')
                  or consolePanel:getChildById('ignoredPlayersButton')
                  or consolePanel:getChildById('ignoredButton')
    end
    if ignoreBtn then
      ignoreBtn:destroy()
    end
  end

  -- Remove the Close Channel icon instance so the layout reflows
  do
    local closeBtn = consolePanel and consolePanel:getChildById('closeChannelButton') or nil
    if closeBtn then
      closeBtn:destroy()
    end
  end

  channels = {}

  topResizeBorder.onMouseMove = function(self, mousePos, mouseMoved)
    if self:isPressed() then
      local parent = self:getParent()
      local bottom = parent:getY() + parent:getHeight()
      local newY = math.min(math.max(mousePos.y - self:getHeight()/2, bottom - self.maximum), bottom - self.minimum)
      local newHeight = bottom - newY
      parent:setY(newY)
      parent:setHeight(newHeight)
      self:checkBoundary(newHeight)
      return true
    end
  end

  consolePanel.onGeometryChange = function()
    if floatingMode then
      settingsSetNumber('consolePanelWidth', consolePanel:getWidth())
      settingsSetNumber('consolePanelHeight', consolePanel:getHeight())
    end
  end

  topResizeBorder:disable()
  topResizeBorder:hide()
  rightResizeBorder:disable()
  rightResizeBorder:hide()
    
  consolePanel.onDragEnter = onDragEnter
  consolePanel.onDragLeave = onDragLeave
  consolePanel.onDragMove = onDragMove
  consoleTabBar.onDragEnter = onDragEnter
  consoleTabBar.onDragLeave = onDragLeave
  consoleTabBar.onDragMove = onDragMove
  
  consolePanel.onKeyPress = function(self, keyCode, keyboardModifiers)
    if not (keyboardModifiers == KeyboardCtrlModifier and keyCode == KeyC) then return false end

    local tab = consoleTabBar:getCurrentTab()
    if not tab then return false end

    local selection = tab.tabPanel:getChildById('consoleBuffer').selectionText
    if not selection then return false end

    g_window.setClipboardText(selection)
    return true
  end

  g_keyboard.bindKeyPress('Shift+Up', function() navigateMessageHistory(1) end, consolePanel)
  g_keyboard.bindKeyPress('Shift+Down', function() navigateMessageHistory(-1) end, consolePanel)
  local function scrollTabsBy(direction)
    local step = consoleTabBar:getWidth() * 0.5
    consoleTabBar:scrollTabs(step * direction)
  end
  g_keyboard.bindKeyPress('Tab', function() scrollTabsBy(1) end, consolePanel)
  g_keyboard.bindKeyPress('Shift+Tab', function() scrollTabsBy(-1) end, consolePanel)
  g_keyboard.bindKeyDown('Enter', sendCurrentMessage, consolePanel)
  g_keyboard.bindKeyPress('Ctrl+A', function() consoleTextEdit:clearText() end, consolePanel)
  g_keyboard.bindKeyDown('Ctrl+Shift+F', function() switchMode(not floatingMode) end, modules.game_interface.getRootPanel())
  
  -- tibia like hotkeys
  local gameRootPanel = modules.game_interface.getRootPanel()
  g_keyboard.bindKeyDown('Ctrl+O', g_game.requestChannels, gameRootPanel)
  g_keyboard.bindKeyDown('Ctrl+H', openHelp, gameRootPanel)

  -- ENTER global (funciona em qualquer parte da tela)
  g_keyboard.bindKeyDown('Enter', handleGlobalEnter, gameRootPanel)

  consoleToggleChat = consolePanel:getChildById('toggleChat')
  load()

  if g_game.isOnline() then
    online()
  end
end

function clearSelection(consoleBuffer)
  for _,label in pairs(consoleBuffer:getChildren()) do
    label:clearSelection()
  end
  consoleBuffer.selectionText = nil
  consoleBuffer.selection = nil
end

function selectAll(consoleBuffer)
  clearSelection(consoleBuffer)
  if consoleBuffer:getChildCount() > 0 then
    local text = {}
    for _,label in pairs(consoleBuffer:getChildren()) do
      label:selectAll()
      table.insert(text, label:getSelection())
    end
    consoleBuffer.selectionText = table.concat(text, '\n')
    consoleBuffer.selection = { first = consoleBuffer:getChildIndex(consoleBuffer:getFirstChild()), last = consoleBuffer:getChildIndex(consoleBuffer:getLastChild()) }
  end
end

function toggleChat()
  if consoleToggleChat:isChecked() then
    disableChat()
  else
    enableChat()
  end
end

function enableChat(temporarily)
  if g_app.isMobile() then return end
  if consoleToggleChat:isChecked() then
    consoleToggleChat:setChecked(false)
  end
  if not temporarily then
    modules.client_options.setOption("wsadWalking", false)
  end

  modules.game_walking.disableWSAD()
  consoleTextEdit:setVisible(true)
  consoleTextEdit:clearText()
  consoleTextEdit:setCursorVisible(true)
  consoleTextEdit:focus()
  addEvent(function()
    if consoleTextEdit then consoleTextEdit:focus() end
  end)

  -- NÃO rebinda Enter aqui (para não conflitar com o handler global).
  if temporarily then
    local quickFunc = function()
      if not g_game.isOnline() then return end
      disableChat(temporarily)
    end
    g_keyboard.bindKeyDown("Escape", quickFunc, modules.game_interface.getRootPanel())
  end

  consoleToggleChat:setTooltip(tr("Disable chat mode, allow to walk using WASD."))
end

function disableChat(temporarily)
  if g_app.isMobile() then return end
  if not consoleToggleChat:isChecked() then
    return consoleToggleChat:setChecked(true)
  end
  if not temporarily then
    modules.client_options.setOption("wsadWalking", true)
  end

  consoleTextEdit:setVisible(false)
  consoleTextEdit:clearText()

  -- NÃO rebinda Enter aqui (handler global já cuida de reexibir)
  modules.game_walking.enableWSAD()

  consoleToggleChat:setTooltip(tr("Enable chat mode"))
end

function isChatEnabled()
  return consoleTextEdit:isVisible()
end

function terminate()
  save()
  disconnect(g_game, {
    onTalk = onTalk,
    onChannelList = onChannelList,
    onOpenChannel = onOpenChannel,
    onOpenPrivateChannel = onOpenPrivateChannel,
    onOpenOwnPrivateChannel = onOpenPrivateChannel,
    onCloseChannel = onCloseChannel,
    onRuleViolationChannel = onRuleViolationChannel,
    onRuleViolationRemove = onRuleViolationRemove,
    onRuleViolationCancel = onRuleViolationCancel,
    onRuleViolationLock = onRuleViolationLock,
    onGameStart = online,
    onGameEnd = offline,
    onChannelEvent = onChannelEvent,
  })

  if g_game.isOnline() then clear() end

  local gameRootPanel = modules.game_interface.getRootPanel()
  g_keyboard.unbindKeyDown('Ctrl+O', gameRootPanel)
  g_keyboard.unbindKeyDown('Ctrl+H', gameRootPanel)

  saveCommunicationSettings()

  if channelsWindow then
    channelsWindow:destroy()
  end

  if communicationWindow then
    communicationWindow:destroy()
  end

  if violationWindow then
    violationWindow:destroy()
  end

  consoleTabBar = nil
  consoleContentPanel = nil
  consoleToggleChat = nil
  consoleTextEdit = nil

  consolePanel:destroy()
  consolePanel = nil
  ownPrivateName = nil

  Console = nil
end

function save()
  -- Mesclar com o que ja existe para nao apagar outros chars
  local settings = g_settings.getNode('game_console') or {}

  -- manter os campos ja usados
  settings.messageHistory = messageHistory
  settings.floatingMode   = floatingMode
  if floatingPos then
    settings.floatingPos = floatingPos
  else
    settings.floatingPos = nil
  end

  -- Salvar pins do char atual (somente se houver nome)
  if consoleTabBar and consoleTabBar.getPinnedTabsText then
    local char = g_game.getCharacterName()
    if char and char ~= '' then
      settings.pinsByChar = settings.pinsByChar or {}
      settings.pinsByChar[char] = consoleTabBar:getPinnedTabsText()
      -- atualiza cache em memoria para consistencia
      pinsByCharCache = settings.pinsByChar
    end
  end

  g_settings.setNode('game_console', settings)
end

function load()
  local settings = g_settings.getNode('game_console')
  if settings then
    messageHistory = settings.messageHistory or {}
    floatingPos    = settings.floatingPos
    if settings.floatingMode then
      switchMode(true)
    end
    -- NOVO: apenas cachear o mapa completo; nao derive por char aqui
    pinsByCharCache = settings.pinsByChar or {}
  end
  loadCommunicationSettings()
end

local function applyPinsBulk()
  if not pinsToRestore or #pinsToRestore == 0 then return end
  if not consoleTabBar or not consoleTabBar.pinTab then return end

  for _, name in ipairs(pinsToRestore) do
    local t = consoleTabBar:getTab(name)
    if t and not consoleTabBar:isPinned(t) then
      consoleTabBar:pinTab(t, { append = true })
    end
  end

  local allApplied = true
  for _, name in ipairs(pinsToRestore) do
    local t = consoleTabBar:getTab(name)
    if not (t and consoleTabBar:isPinned(t)) then allApplied = false break end
  end
  if allApplied then
    pinsToRestore = nil
    pinsWantedSet = nil
  end
end

function onTabChange(tabBar, tab)
  -- Safe guard: close icon may not exist (icon removed from UI)
  local btn = consolePanel and consolePanel:getChildById('closeChannelButton') or nil
  if not btn then return end
  if tab == defaultTab or tab == serverTab then
    btn:disable()
  else
    btn:enable()
  end
end
function clear()
  -- save last open channels
  local lastChannelsOpen = g_settings.getNode('lastChannelsOpen') or {}
  local char = g_game.getCharacterName()
  local savedChannels = {}
  local set = false
  for channelId, channelName in pairs(channels) do
    if type(channelId) == 'number' then
      savedChannels[channelName] = channelId
      set = true
    end
  end
  if set then
    lastChannelsOpen[char] = savedChannels
  else
    lastChannelsOpen[char] = nil
  end
  g_settings.setNode('lastChannelsOpen', lastChannelsOpen)

  -- close channels
  for _, channelName in pairs(channels) do
    local tab = consoleTabBar:getTab(channelName)
    consoleTabBar:removeTab(tab)
  end
  channels = {}

  consoleTabBar:removeTab(defaultTab)
  defaultTab = nil
  consoleTabBar:removeTab(serverTab)
  serverTab = nil

  local npcTab = consoleTabBar:getTab('NPCs')
  if npcTab then
    consoleTabBar:removeTab(npcTab)
    npcTab = nil
    lastNpcName = nil
  end

  if violationReportTab then
    consoleTabBar:removeTab(violationReportTab)
    violationReportTab = nil
  end

  consoleTextEdit:clearText()

  if violationWindow then
    violationWindow:destroy()
    violationWindow = nil
  end

  if channelsWindow then
    channelsWindow:destroy()
    channelsWindow = nil
  end
end

function switchMode(floating)
  consolePanel:setDraggable(floating)
  consoleTabBar:setDraggable(floating)
  floatingMode = floating
  if floating then
    consolePanel:breakAnchors()
    local width = settingsGetNumber('consolePanelWidth', consolePanel:getWidth())
    local height = settingsGetNumber('consolePanelHeight', consolePanel:getHeight())
    consolePanel:setSize({ width = width, height = height })
    consolePanel:setPosition({ x = 0, y = g_window.getHeight() - height })
    topResizeBorder:enable()
    rightResizeBorder:enable()
    topResizeBorder:show()
    rightResizeBorder:show()
  else
    settingsSetNumber('consolePanelWidth', consolePanel:getWidth())
    settingsSetNumber('consolePanelHeight', consolePanel:getHeight())
    topResizeBorder:disable()
    rightResizeBorder:disable()
    topResizeBorder:hide()
    rightResizeBorder:hide()
    consolePanel:fill('parent')
  end
  if floating then
    consolePanel:setParent(modules.game_interface.getRootPanel())
    consolePanel:raise()
    if floatingPos then
      consolePanel:setPosition(floatingPos)
    end
  else
    floatingPos = consolePanel:getPosition()
    consolePanel:setParent(modules.game_interface.getBottomPanel())
    consolePanel:setPosition({x = 0, y = 0})
  end
end

function onDragEnter(widget, pos)
  if not floatingMode then
    return false
  end
  local panelPos = consolePanel:getPosition()
  dragOffset = { x = pos.x - panelPos.x, y = pos.y - panelPos.y }
  return true
end

function onDragMove(widget, pos, moved)
  if not floatingMode then
    return
  end
  local newPos = { x = pos.x - dragOffset.x, y = pos.y - dragOffset.y }
  consolePanel:setPosition(newPos)
  floatingPos = newPos
  return true
end

function onDragLeave(widget, pos)
  dragOffset = nil
  return floatingMode
end

function clearChannel(consoleTabBar)
  consoleTabBar:getCurrentTab().tabPanel:getChildById('consoleBuffer'):destroyChildren()
end

function setTextEditText(text)
  consoleTextEdit:setText(text)
  consoleTextEdit:setCursorPos(-1)
end

function openHelp()
  local helpChannel = 9
  if g_game.getClientVersion() <= 810 then
    helpChannel = 8
  end
  g_game.joinChannel(helpChannel)
end

function openPlayerReportRuleViolationWindow()
  if violationWindow or violationReportTab then return end
  violationWindow = g_ui.loadUI('violationwindow', rootWidget)
  violationWindow.onEscape = function()
    violationWindow:destroy()
    violationWindow = nil
  end
  violationWindow.onEnter = function()
    local text = violationWindow:getChildById('text'):getText()
    g_game.talkChannel(MessageModes.RVRChannel, 0, text)
    violationReportTab = addTab(tr('Report Rule') .. '...', true)
    addTabText(tr('Please wait patiently for a gamemaster to reply') .. '.', SpeakTypesSettings.privateRed, violationReportTab)
    addTabText(applyMessagePrefixies(g_game.getCharacterName(), 0, text),  SpeakTypesSettings.say, violationReportTab, g_game.getCharacterName())
    violationReportTab.locked = true
    violationWindow:destroy()
    violationWindow = nil
  end
end

function addTab(name, focus, skipScroll)
  local tab = getTab(name)
  if tab then -- is channel already open
    if not focus then focus = true end
  else
    tab = consoleTabBar:addTab(name, nil, processChannelTabMenu, skipScroll)
    if pinsWantedSet and pinsWantedSet[name] then
      applyPinsBulk()
    end
  end
  tab:setTooltip(name)
  if focus then
    consoleTabBar:selectTab(tab)
  end
  return tab
end

function removeTab(tab)
  if type(tab) == 'string' then
    tab = consoleTabBar:getTab(tab)
  end

  if tab == defaultTab or tab == serverTab then
    return
  end

  if tab == violationReportTab then
    g_game.cancelRuleViolation()
    violationReportTab = nil
  elseif tab.violationChatName then
    g_game.closeRuleViolation(tab.violationChatName)
  elseif tab.channelId then
    -- notificate the server that we are leaving the channel
    for k, v in pairs(channels) do
      if (k == tab.channelId) then channels[k] = nil end
    end
    g_game.leaveChannel(tab.channelId)
  elseif tab:getText() == "NPCs" then
    g_game.closeNpcChannel()
    lastNpcName = nil
  end

  if getCurrentTab() == tab then
    consoleTabBar:selectTab(defaultTab)
  end

  consoleTabBar:removeTab(tab)
  save()
end

function removeCurrentTab()
  removeTab(consoleTabBar:getCurrentTab())
end

function getTab(name)
  return consoleTabBar:getTab(name)
end

function getChannelTab(channelId)
  local channel = channels[channelId]
  if channel then
    return getTab(channel)
  end
  return nil
end

function getRuleViolationsTab()
  if violationsChannelId then
    return getChannelTab(violationsChannelId)
  end
  return nil
end

function getCurrentTab()
  return consoleTabBar:getCurrentTab()
end

function addChannel(name, id)
  channels[id] = name
  local focus = not table.find(ignoredChannels, id)
  local tab = addTab(name, focus, not focus)
  tab.channelId = id
  return tab
end

function addPrivateChannel(receiver)
  channels[receiver] = receiver
  return addTab(receiver, true)
end

function addPrivateText(text, speaktype, name, isPrivateCommand, creatureName)
  local focus = false
  if speaktype.npcChat then
    name = 'NPCs'
    focus = true
    if creatureName and creatureName ~= g_game.getCharacterName() then
      lastNpcName = creatureName
    end
  end

  local privateTab = getTab(name)
  if privateTab == nil then
    if (modules.client_options.getOption('showPrivateMessagesInConsole') and not focus) or (isPrivateCommand and not privateTab) then
      privateTab = defaultTab
    else
      privateTab = addTab(name, focus)
      channels[name] = name
    end
    privateTab.npcChat = speaktype.npcChat
  elseif focus then
    consoleTabBar:selectTab(privateTab)
  end
  addTabText(text, speaktype, privateTab, creatureName)
end

function addText(text, speaktype, tabName, creatureName)
  local tab = getTab(tabName)
  if not tab then
    g_logger.warning(string.format("Console: tab '%s' not found, using current tab", tostring(tabName)))
    tab = getCurrentTab()
  end
  if tab then
    addTabText(text, speaktype, tab, creatureName)
  end
end

-- Contains letter width for font "verdana-11px-antialised" as console is based on it
local letterWidth = {  -- New line (10) and Space (32) have width 1 because they are printed and not replaced with spacer
  [10] = 1, [32] = 1, [33] = 3, [34] = 6, [35] = 8, [36] = 7, [37] = 13, [38] = 9, [39] = 3, [40] = 5, [41] = 5, [42] = 6, [43] = 8, [44] = 4, [45] = 5, [46] = 3, [47] = 8,
  [48] = 7, [49] = 6, [50] = 7, [51] = 7, [52] = 7, [53] = 7, [54] = 7, [55] = 7, [56] = 7, [57] = 7, [58] = 3, [59] = 4, [60] = 8, [61] = 8, [62] = 8, [63] = 6,
  [64] = 10, [65] = 9, [66] = 7, [67] = 7, [68] = 8, [69] = 7, [70] = 7, [71] = 8, [72] = 8, [73] = 5, [74] = 5, [75] = 7, [76] = 7, [77] = 9, [78] = 8, [79] = 8,
  [80] = 7, [81] = 8, [82] = 8, [83] = 7, [84] = 8, [85] = 8, [86] = 8, [87] = 12, [88] = 8, [89] = 8, [90] = 7, [91] = 5, [92] = 8, [93] = 5, [94] = 9, [95] = 8,
  [96] = 5, [97] = 7, [98] = 7, [99] = 6, [100] = 7, [101] = 7, [102] = 5, [103] = 7, [104] = 7, [105] = 3, [106] = 4, [107] = 7, [108] = 3, [109] = 11, [110] = 7,
  [111] = 7, [112] = 7, [113] = 7, [114] = 6, [115] = 6, [116] = 5, [117] = 7, [118] = 8, [119] = 10, [120] = 8, [121] = 8, [122] = 6, [123] = 7, [124] = 4, [125] = 7, [126] = 8,
  [127] = 1, [128] = 7, [129] = 6, [130] = 3, [131] = 7, [132] = 6, [133] = 11, [134] = 7, [135] = 7, [136] = 7, [137] = 13, [138] = 7, [139] = 4, [140] = 11, [141] = 6, [142] = 6,
  [143] = 6, [144] = 6, [145] = 4, [146] = 3, [147] = 7, [148] = 6, [149] = 6, [150] = 7, [151] = 10, [152] = 7, [153] = 10, [154] = 6, [155] = 5, [156] = 11, [157] = 6, [158] = 6,
  [159] = 8, [160] = 4, [161] = 3, [162] = 7, [163] = 7, [164] = 7, [165] = 8, [166] = 4, [167] = 7, [168] = 6, [169] = 10, [170] = 6, [171] = 8, [172] = 8, [173] = 16, [174] = 10,
  [175] = 8, [176] = 5, [177] = 8, [178] = 5, [179] = 5, [180] = 6, [181] = 7, [182] = 7, [183] = 3, [184] = 5, [185] = 6, [186] = 6, [187] = 8, [188] = 12, [189] = 12, [190] = 12,
  [191] = 6, [192] = 9, [193] = 9, [194] = 9, [195] = 9, [196] = 9, [197] = 9, [198] = 11, [199] = 7, [200] = 7, [201] = 7, [202] = 7, [203] = 7, [204] = 5, [205] = 5, [206] = 6,
  [207] = 5, [208] = 8, [209] = 8, [210] = 8, [211] = 8, [212] = 8, [213] = 8, [214] = 8, [215] = 8, [216] = 8, [217] = 8, [218] = 8, [219] = 8, [220] = 8, [221] = 8, [222] = 7,
  [223] = 7, [224] = 7, [225] = 7, [226] = 7, [227] = 7, [228] = 7, [229] = 7, [230] = 11, [231] = 6, [232] = 7, [233] = 7, [234] = 7, [235] = 7, [236] = 3, [237] = 4, [238] = 4,
  [239] = 4, [240] = 7, [241] = 7, [242] = 7, [243] = 7, [244] = 7, [245] = 7, [246] = 7, [247] = 9, [248] = 7, [249] = 7, [250] = 7, [251] = 7, [252] = 7, [253] = 8, [254] = 7, [255] = 8
}

-- Return information about start, end in the string and the highlighted words
function getHighlightedText(text)
  local tmpData = {}

  repeat
    local tmp = {string.find(text, "{([^}]+)}", tmpData[#tmpData-1])}
    for _, v in pairs(tmp) do
      table.insert(tmpData, v)
    end
  until not(string.find(text, "{([^}]+)}", tmpData[#tmpData-1]))

  return tmpData
end

local function addFloatingText(tab, message, speaktype, highlightData)
  if not floatingConsolePanel or not floatingConsolePanel:isVisible() then return end
  local channelName = tab:getText()
  if speaktype.private and not tab.npcChat then
    channelName = tr('Privado')
  end
  local prefix = '[' .. channelName .. '] '

  local label = g_ui.createWidget('ConsoleLabel', floatingConsoleBuffer)
  label:setFont('manrope-semibold-14px')

  if highlightData and #highlightData > 2 then
    local pieces = { prefix, speaktype.color }
    for i = 1, #highlightData do
      table.insert(pieces, highlightData[i])
    end
    label:setColoredText(pieces)
  else
    label:setText(prefix .. message)
    label:setColor(speaktype.color)
  end

  scheduleEvent(function()
    if label and not label:isDestroyed() then
      label:destroy()
    end
  end, 10000)

  if floatingConsoleBuffer:getChildCount() > FLOATING_MAX_LINES then
    floatingConsoleBuffer:getFirstChild():destroy()
  end
end

function getNewHighlightedText(text, color, highlightColor)
  local tmpData = {}
  
  for i, part in ipairs(text:split("{")) do
    if i == 1 then
      table.insert(tmpData, part)
      table.insert(tmpData, color)
    else
      for j, part2 in ipairs(part:split("}")) do
        if j == 1 then
          table.insert(tmpData, part2)
          table.insert(tmpData, highlightColor)
        else
          table.insert(tmpData, part2)
          table.insert(tmpData, color)
        end
      end
    end
  end

  return tmpData
end

function addTabText(text, speaktype, tab, creatureName)
  if not tab or tab.locked or not text or #text == 0 then return end

  local showTimestamp = modules.client_options.getOption('showTimestampsInConsole')
  local timestampText
  local displayText = text
  if showTimestamp then
    timestampText = os.date('%H:%M')
    displayText = timestampText .. ' ' .. text
  end

  local panel = tab.tabPanel
  local consoleBuffer = panel:getChildById('consoleBuffer')

  local label = nil
  if consoleBuffer:getChildCount() > MAX_LINES then
    label = consoleBuffer:getFirstChild()
    consoleBuffer:moveChildToIndex(label, consoleBuffer:getChildCount())
  end

  if not label then
    label = g_ui.createWidget('ConsoleLabel', consoleBuffer)
  end
  label:setId('consoleLabel' .. consoleBuffer:getChildCount())
  if consoleTabBar:getCurrentTab() ~= tab and not tab.blinking then
    tab.blinking = true
    g_effects.startBlink(tab)
  end
  local highlightData

  if speaktype.npcChat and (g_game.getCharacterName() ~= creatureName or g_game.getCharacterName() == 'Account Manager') then
    highlightData = getNewHighlightedText(text, speaktype.color, "#1f9ffe")
  end

  if showTimestamp then
    local coloredText = { timestampText, '#b6b6b6', ' ', '#b6b6b6' }
    if highlightData and #highlightData > 2 then
      for i = 1, #highlightData do
        table.insert(coloredText, highlightData[i])
      end
    else
      table.insert(coloredText, text)
      table.insert(coloredText, speaktype.color)
    end
    label:setColoredText(coloredText)
  else
    label:setText(displayText)
    label:setColor(speaktype.color)
    if highlightData and #highlightData > 2 then
      label:setColoredText(highlightData)
    end
  end

  label.name = creatureName
  local consoleBufferRef = consoleBuffer
  consoleBuffer.onMouseRelease = function(self, mousePos, mouseButton)
    processMessageMenu(mousePos, mouseButton, nil, nil, nil, tab)
  end
  label.onMouseRelease = function(self, mousePos, mouseButton)
    processMessageMenu(mousePos, mouseButton, creatureName, displayText, self, tab)
  end
  label.onMousePress = function(self, mousePos, button)
    if button == MouseLeftButton then clearSelection(consoleBufferRef) end
  end
  label.onDragEnter = function(self, mousePos)
    clearSelection(consoleBufferRef)
    return true
  end
  label.onDragLeave = function(self, droppedWidget, mousePos)
    local text = {}
    for selectionChild = consoleBufferRef.selection.first, consoleBufferRef.selection.last do
      local label = self:getParent():getChildByIndex(selectionChild)
      table.insert(text, label:getSelection())
    end
    consoleBufferRef.selectionText = table.concat(text, '\n')
    return true
  end
  label.onDragMove = function(self, mousePos, mouseMoved)
    local parent = self:getParent()
    local parentRect = parent:getPaddingRect()
    local selfIndex = parent:getChildIndex(self)
    local child = parent:getChildByPos(mousePos)

    -- find bonding children
    if not child then
      if mousePos.y < self:getY() then
        for index = selfIndex - 1, 1, -1 do
          local label = parent:getChildByIndex(index)
          if label:getY() + label:getHeight() > parentRect.y then
            if (mousePos.y >= label:getY() and mousePos.y <= label:getY() + label:getHeight()) or index == 1 then
              child = label
              break
            end
          else
            child = parent:getChildByIndex(index + 1)
            break
          end
        end
      elseif mousePos.y > self:getY() + self:getHeight() then
        for index = selfIndex + 1, parent:getChildCount(), 1 do
          local label = parent:getChildByIndex(index)
          if label:getY() < parentRect.y + parentRect.height then
            if (mousePos.y >= label:getY() and mousePos.y <= label:getY() + label:getHeight()) or index == parent:getChildCount() then
              child = label
              break
            end
          else
            child = parent:getChildByIndex(index - 1)
            break
          end
        end
      else
        child = self
      end
    end

    if not child then return false end

    local childIndex = parent:getChildIndex(child)

    -- remove old selection
    clearSelection(consoleBufferRef)

    -- update self selection
    local textBegin = self:getTextPos(self:getLastClickPosition())
    local textPos = self:getTextPos(mousePos)
    self:setSelection(textBegin, textPos)

    consoleBufferRef.selection = { first = math.min(selfIndex, childIndex), last = math.max(selfIndex, childIndex) }

    -- update siblings selection
    if child ~= self then
      for selectionChild = consoleBufferRef.selection.first + 1, consoleBufferRef.selection.last - 1 do
        parent:getChildByIndex(selectionChild):selectAll()
      end

      local textPos = child:getTextPos(mousePos)
      if childIndex > selfIndex then
        child:setSelection(0, textPos)
      else
        child:setSelection(string.len(child:getText()), textPos)
      end
    end

    return true
  end
  addFloatingText(tab, text, speaktype, highlightData)
end

function removeTabLabelByName(tab, name)
  local panel = tab.tabPanel
  local consoleBuffer = panel:getChildById('consoleBuffer')
  for _,label in pairs(consoleBuffer:getChildren()) do
    if label.name == name then
      label:destroy()
    end
  end
end

function processChannelTabMenu(tab, mousePos, mouseButton)
  local menu = g_ui.createWidget('PopupMenu')
  menu:setGameMenu(true)

  local worldName = g_game.getWorldName()
  local characterName = g_game.getCharacterName()
  channelName = tab:getText()
  if tab ~= defaultTab and tab ~= serverTab then
    menu:addOption(tr('Close'), function() removeTab(channelName) end)
    --menu:addOption(tr('Show Server Messages'), function() --[[TODO]] end)
    menu:addSeparator()
  end

  if consoleTabBar:getCurrentTab() == tab then
    menu:addOption(tr('Clear Messages'), function() clearChannel(consoleTabBar) end)
    menu:addOption(tr('Save Messages'), function()
      local panel = tab.tabPanel
      local consoleBuffer = panel:getChildById('consoleBuffer')
      local lines = {}
      for _,label in pairs(consoleBuffer:getChildren()) do
        table.insert(lines, label:getText())
      end

      local filename = worldName .. ' - ' .. characterName .. ' - ' .. channelName .. '.txt'
      local filepath = '/user_dir/' .. filename

      -- extra information at the beginning
      table.insert(lines, 1, os.date('\nChannel saved at %a %b %d %H:%M:%S %Y'))

      if g_resources.fileExists(filepath) then
        table.insert(lines, 1, protectedcall(g_resources.readFileContents, filepath) or '')
      end

      g_resources.writeFileContents(filepath, table.concat(lines, '\n'))
      modules.game_textmessage.displayStatusMessage(tr('Channel appended to %s', filename))
    end)
  end

  local isPinned = consoleTabBar.isPinned and consoleTabBar:isPinned(tab)
  menu:addOption(tr(isPinned and 'Desafixar' or 'Fixar'), function()
    if isPinned then
      consoleTabBar:unpinTab(tab)
    else
      consoleTabBar:pinTab(tab)
    end
    consoleTabBar:selectTab(tab)
    save()
  end)

  menu:display(mousePos)
end

function processMessageMenu(mousePos, mouseButton, creatureName, text, label, tab)
  if mouseButton == MouseRightButton then
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    if creatureName and #creatureName > 0 then
      if creatureName ~= g_game.getCharacterName() then
        if modules.game_spectate.isHosting then
          menu:addOption(
            tr("Kick " .. creatureName),
            function()
              modules.game_spectate.kickPlayer(creatureName)
            end
          )
          menu:addOption(
            tr("Ban " .. creatureName),
            function()
              modules.game_spectate.banPlayer(creatureName)
            end
          )
          menu:addSeparator()
        end
        menu:addOption(tr('Message to ' .. creatureName), function () g_game.openPrivateChannel(creatureName) end)
        if not g_game.getLocalPlayer():hasVip(creatureName) then
          menu:addOption(tr('Add to VIP list'), function () g_game.addVip(creatureName) end)
        end
        if modules.game_console.getOwnPrivateTab() then
          menu:addSeparator()
          menu:addOption(tr('Invite to private chat'), function() g_game.inviteToOwnChannel(creatureName) end)
          menu:addOption(tr('Exclude from private chat'), function() g_game.excludeFromOwnChannel(creatureName) end)
        end
        if isIgnored(creatureName) then
          menu:addOption(tr('Unignore') .. ' ' .. creatureName, function() removeIgnoredPlayer(creatureName) end)
        else
          menu:addOption(tr('Ignore') .. ' ' .. creatureName, function() addIgnoredPlayer(creatureName) end)
        end
        menu:addSeparator()
      end
      if modules.game_ruleviolation.hasWindowAccess() then
        menu:addOption(tr('Rule Violation'), function() modules.game_ruleviolation.show(creatureName, text:match('.+%:%s(.+)')) end)
        menu:addSeparator()
      end

      menu:addOption(tr('Copy name'), function () g_window.setClipboardText(creatureName) end)
      if modules.game_guildmanagement.canInvite(creatureName) then
        menu:addOption(tr('Invite to guild'), function () modules.game_guildmanagement.invitePlayer(creatureName) end)
      elseif modules.game_guildmanagement.canKick(creatureName) then
        menu:addOption(tr('Kick from guild'), function () modules.game_guildmanagement.kickPlayer(creatureName) end)
      end
    end
    local selection = tab.tabPanel:getChildById('consoleBuffer').selectionText
    if selection and #selection > 0 then
      menu:addOption(tr('Copy'), function() g_window.setClipboardText(selection) end, '(Ctrl+C)')
    end
    if text then
      menu:addOption(tr('Copy message'), function() g_window.setClipboardText(text) end)
    end
    menu:addOption(tr('Select all'), function() selectAll(tab.tabPanel:getChildById('consoleBuffer')) end)
    if tab.violations and creatureName then
      menu:addSeparator()
      menu:addOption(tr('Process') .. ' ' .. creatureName, function() processViolation(creatureName, text) end)
      menu:addOption(tr('Remove') .. ' ' .. creatureName, function() g_game.closeRuleViolation(creatureName) end)
    end
    menu:display(mousePos)
  end
end

function addFilter(filter)
  if type(filter) ~= 'function' then
    return g_logger.error('console.addFilter expects a function')
  end
  table.insert(filters, filter)
end

function removeFilter(filter)
  table.removevalue(filters, filter)
end

sendMessage = function(message, tab)
  local tab = tab or getCurrentTab()
  if not tab then return end

  for _, func in pairs(filters) do
    local ok, blocked = pcall(func, message)
    if not ok then
      g_logger.error('error in console filter: ' .. blocked)
    elseif blocked then
      local info = debug.getinfo(func, 'S')
      local source = info and info.short_src or 'unknown'
      g_logger.debug(string.format('message "%s" blocked by filter (%s)', message, source))
      return true
    end
  end

  -- when talking on server log, the message goes to default channel
  local originalTab = tab
  local name = tab:getText()
  if tab == serverTab or tab == getRuleViolationsTab() then
    tab = defaultTab
    name = defaultTab and defaultTab:getText() or tr('Default')
  end

  -- handling chat commands
  local channel = tab and tab.channelId
  local originalMessage = message
  local chatCommandSayMode
  local chatCommandPrivate
  local chatCommandPrivateReady
  local chatCommandMessage

  -- player used yell command
  chatCommandMessage = message:match("^%#[y|Y] (.*)")
  if chatCommandMessage ~= nil then
    chatCommandSayMode = 'yell'
    channel = 0
    message = chatCommandMessage
  end

   -- player used whisper
  chatCommandMessage = message:match("^%#[w|W] (.*)")
  if chatCommandMessage ~= nil then
    chatCommandSayMode = 'whisper'
    message = chatCommandMessage
    channel = 0
  end

  -- player say
  chatCommandMessage = message:match("^%#[s|S] (.*)")
  if chatCommandMessage ~= nil then
    chatCommandSayMode = 'say'
    message = chatCommandMessage
    channel = 0
  end

  -- player red talk on channel
  chatCommandMessage = message:match("^%#[c|C] (.*)")
  if chatCommandMessage ~= nil then
    chatCommandSayMode = 'channelRed'
    message = chatCommandMessage
  end

  -- player broadcast
  chatCommandMessage = message:match("^%#[b|B] (.*)")
  if chatCommandMessage ~= nil then
    chatCommandSayMode = 'broadcast'
    message = chatCommandMessage
    channel = 0
  end

  local findIni, findEnd, chatCommandInitial, chatCommandPrivate, chatCommandEnd, chatCommandMessage = message:find("([%*%@])(.+)([%*%@])(.*)")
  if findIni ~= nil and findIni == 1 then -- player used private chat command
    if chatCommandInitial == chatCommandEnd then
      chatCommandPrivateRepeat = false
      if chatCommandInitial == "*" then
        setTextEditText('*'.. chatCommandPrivate .. '* ')
      end
      message = chatCommandMessage:trim()
      chatCommandPrivateReady = true
    end
  end

  message = message:gsub("^(%s*)(.*)","%2") -- remove space characters from message init
  if #message == 0 then return end

  -- add new command to history
  currentMessageIndex = 0
  if #messageHistory == 0 or messageHistory[#messageHistory] ~= originalMessage then
    table.insert(messageHistory, originalMessage)
    if #messageHistory > MAX_HISTORY then
      table.remove(messageHistory, 1)
    end
  end

  local speaktypedesc
  if (channel or tab == defaultTab or tab == serverTab) and not chatCommandPrivateReady then
    if tab == defaultTab or tab == serverTab then
      -- Obter modo atual com fallbacks seguros
      local sayBtn = consolePanel and consolePanel:getChildById('sayModeButton') or nil
      local modeIndex = (sayBtn and sayBtn.sayMode) or 2
      local mode = SayModes[modeIndex] or SayModes[2]
      speaktypedesc = chatCommandSayMode or mode.speakTypeDesc or 'say'
    else
      speaktypedesc = chatCommandSayMode or 'channelYellow'
    end

    local speakType = SpeakTypesSettings[speaktypedesc] or SpeakTypesSettings.say
    channel = channel or 0
    g_game.talkChannel(speakType.speakType, channel, message)
    return
  else
    local isPrivateCommand = false
    local priv = true
    local tabname = name
    local dontAdd = false
    if chatCommandPrivateReady then
      speaktypedesc = 'privatePlayerToPlayer'
      name = chatCommandPrivate
      isPrivateCommand = true
    elseif tab and tab.npcChat then
      speaktypedesc = 'privatePlayerToNpc'
      if lastNpcName then
        name = lastNpcName
      end
    elseif tab == violationReportTab then
      if violationReportTab.locked then
        modules.game_textmessage.displayFailureMessage('Wait for a gamemaster reply.')
        dontAdd = true
      else
        speaktypedesc = 'rvrContinue'
        tabname = tr('Report Rule') .. '...'
      end
    elseif tab and tab.violationChatName then
      speaktypedesc = 'rvrAnswerTo'
      name = tab.violationChatName
      tabname = tab.violationChatName .. '\'...'
    else
      speaktypedesc = 'privatePlayerToPlayer'
    end

    local speaktype = SpeakTypesSettings[speaktypedesc] or SpeakTypesSettings.privatePlayerToPlayer
    local player = g_game.getLocalPlayer()
    g_game.talkPrivate(speaktype.speakType, name, message)
    if not dontAdd then
      message = applyMessagePrefixies(g_game.getCharacterName(), player:getLevel(), message)
      addPrivateText(message, speaktype, tabname, isPrivateCommand, g_game.getCharacterName())
    end
  end
end

function sayModeChange(sayMode)
  local buttom = consolePanel:getChildById('sayModeButton')
  if sayMode == nil then
    sayMode = (buttom and buttom.sayMode or 1) + 1
  end

  if sayMode > #SayModes then sayMode = 1 end

  if buttom then
    buttom:setIcon(SayModes[sayMode].icon)
    buttom.sayMode = sayMode
  end
end

function getOwnPrivateTab()
  if not ownPrivateName then return end
  return getTab(ownPrivateName)
end

function setIgnoreNpcMessages(ignore)
  ignoreNpcMessages = ignore
end

function navigateMessageHistory(step)
  if not isChatEnabled() then
    return
  end

  local numCommands = #messageHistory
  if numCommands > 0 then
    currentMessageIndex = math.min(math.max(currentMessageIndex + step, 0), numCommands)
    if currentMessageIndex > 0 then
      local command = messageHistory[numCommands - currentMessageIndex + 1]
      setTextEditText(command)
    else
      consoleTextEdit:clearText()
    end
  end
  local player = g_game.getLocalPlayer()
  if player then
    player:lockWalk(200) -- lock walk for 200 ms to avoid walk during release of shift
  end
end

function applyMessagePrefixies(name, level, message)
  if name and #name > 0 then
    if modules.client_options.getOption('showLevelsInConsole') and level > 0 then
      message = name .. ' [' .. level .. ']: ' .. message
    else
      message = name .. ': ' .. message
    end
  end
  return message
end

function onTalk(name, level, mode, message, channelId, creaturePos)
  if mode == MessageModes.GamemasterBroadcast then
    modules.game_textmessage.displayBroadcastMessage(name .. ': ' .. message)
    return
  end

  local isNpcMode = (mode == MessageModes.NpcFromStartBlock or mode == MessageModes.NpcFrom)

  if ignoreNpcMessages and isNpcMode then return end

  speaktype = SpeakTypes[mode]

  if not speaktype then
    perror('unhandled onTalk message mode ' .. mode .. ': ' .. message)
    return
  end

  local localPlayer = g_game.getLocalPlayer()
  if name ~= g_game.getCharacterName() and (
      (isUsingIgnoreList() and not isUsingWhiteList()) or
      (isUsingWhiteList() and not isWhitelisted(name) and not (isAllowingVIPs() and localPlayer:hasVip(name)))
    ) then

    if mode == MessageModes.Yell and isIgnoringYelling() then
      return
    elseif speaktype.private and isIgnoringPrivate() and not isNpcMode then
      return
    elseif isIgnored(name) then
      return
    end
  end

  if mode == MessageModes.RVRChannel then
    channelId = violationsChannelId
  end

  if (mode == MessageModes.Say or mode == MessageModes.Whisper or mode == MessageModes.Yell or
      mode == MessageModes.Spell or mode == MessageModes.MonsterSay or mode == MessageModes.MonsterYell or
      mode == MessageModes.NpcFrom or mode == MessageModes.BarkLow or mode == MessageModes.BarkLoud or
      mode == MessageModes.NpcFromStartBlock) and creaturePos then
    local staticText = StaticText.create()
    -- Remove curly braces from screen message
    local staticMessage = message
    if isNpcMode then
      local highlightData = getNewHighlightedText(staticMessage, speaktype.color, "#1f9ffe")
      if #highlightData > 2 then
        staticText:addColoredMessage(name, mode, highlightData)
      else
        staticText:addMessage(name, mode, staticMessage)
      end
    else
      staticText:addMessage(name, mode, staticMessage)
    end

    local color = speaktype.color
    if mode == MessageModes.BarkLow or mode == MessageModes.BarkLoud then
      local tile = g_map.getTile(creaturePos)
      local creature = tile and tile:getTopCreature()
      if creature and creature:isPlayer() then
        color = SpeakTypesSettings.spell.color
      end
    end
    staticText:setColor(color)
    g_map.addThing(staticText, creaturePos, -1)
  end

  local defaultMessage = mode <= 3 and true or false

  if speaktype == SpeakTypesSettings.none then return end

  if speaktype.hideInConsole then return end

  local composedMessage = applyMessagePrefixies(name, level, message)

  if mode == MessageModes.RVRAnswer then
    violationReportTab.locked = false
    addTabText(composedMessage, speaktype, violationReportTab, name)
  elseif mode == MessageModes.RVRContinue then
    addText(composedMessage, speaktype, name .. '\'...', name)
  elseif speaktype.private then
    addPrivateText(composedMessage, speaktype, name, false, name)
    if modules.client_options.getOption('showPrivateMessagesOnScreen') and speaktype ~= SpeakTypesSettings.privateNpcToPlayer then
      modules.game_textmessage.displayPrivateMessage(name .. ':\n' .. message)
    end
  else
    if defaultMessage then
      addTabText(composedMessage, speaktype, defaultTab, name)
    else
      -- Mensagens de canais (Help/Trade/etc) continuam por nome do canal aberto
      local channel = channels[channelId]
      if channel then
        addText(composedMessage, speaktype, channel, name)
      else
        pwarning('message in channel id ' .. channelId .. ' which is unknown, this is a server bug, relogin if you want to see messages in this channel')
      end
    end
  end

end

function onOpenChannel(channelId, channelName)
  addChannel(channelName, channelId)
end

function onOpenPrivateChannel(receiver)
  addPrivateChannel(receiver)
end

function onOpenOwnPrivateChannel(channelId, channelName)
  local privateTab = getTab(channelName)
  if privateTab == nil then
    addChannel(channelName, channelId)
  end
  ownPrivateName = channelName
end

function onCloseChannel(channelId)
  local channel = channels[channelId]
  if channel then
    local tab = getTab(channel)
    if tab then
      consoleTabBar:removeTab(tab)
    end
    for k, v in pairs(channels) do
      if (k == tab.channelId) then channels[k] = nil end
    end
  end
end

function processViolation(name, text)
  local tabname = name .. '\'...'
  local tab = addTab(tabname, true)
  channels[tabname] = tabname
  tab.violationChatName = name
  g_game.openRuleViolation(name)
  addTabText(text, SpeakTypesSettings.say, tab, name)
end

function onRuleViolationChannel(channelId)
  violationsChannelId = channelId
  local tab = addChannel(tr('Rule Violations'), channelId)
  tab.violations = true
end

function onRuleViolationRemove(name)
  local tab = getRuleViolationsTab()
  if not tab then return end
  removeTabLabelByName(tab, name)
end

function onRuleViolationCancel(name)
  local tab = getTab(name .. '\'...')
  if not tab then return end
  addTabText(tr('%s has finished the request', name) .. '.', SpeakTypesSettings.privateRed, tab)
  tab.locked = true
end

function onRuleViolationLock()
  if not violationReportTab then return end
  violationReportTab.locked = false
  addTabText(tr('Your request has been closed') .. '.', SpeakTypesSettings.privateRed, violationReportTab)
  violationReportTab.locked = true
end

function doChannelListSubmit()
  local channelListPanel = channelsWindow:getChildById('channelList')
  local openPrivateChannelWith = channelsWindow:getChildById('openPrivateChannelWith'):getText()
  if openPrivateChannelWith ~= '' then
    if openPrivateChannelWith:lower() ~= g_game.getCharacterName():lower() then
      g_game.openPrivateChannel(openPrivateChannelWith)
    else
      modules.game_textmessage.displayFailureMessage('You cannot create a private chat channel with yourself.')
    end
  else
    local selectedChannelLabel = channelListPanel:getFocusedChild()
    if not selectedChannelLabel then return end
    if selectedChannelLabel.channelId == 0xFFFF then
      g_game.openOwnChannel()
    else
      g_game.leaveChannel(selectedChannelLabel.channelId)
      g_game.joinChannel(selectedChannelLabel.channelId)
    end
  end

  channelsWindow:destroy()
end

function onChannelList(channelList)
  if channelsWindow then channelsWindow:destroy() end
  channelsWindow = g_ui.displayUI('channelswindow')
  local channelListPanel = channelsWindow:getChildById('channelList')
  channelsWindow.onEnter = doChannelListSubmit
  channelsWindow.onDestroy = function() channelsWindow = nil end
  g_keyboard.bindKeyPress('Down', function() channelListPanel:focusNextChild(KeyboardFocusReason) end, channelsWindow)
  g_keyboard.bindKeyPress('Up', function() channelListPanel:focusPreviousChild(KeyboardFocusReason) end, channelsWindow)

  for k,v in pairs(channelList) do
    local channelId = v[1]
    local channelName = v[2]

    if #channelName > 0 then
      local label = g_ui.createWidget('ChannelListLabel', channelListPanel)
      label.channelId = channelId
      label:setText(channelName)

      label:setPhantom(false)
      label.onDoubleClick = doChannelListSubmit
    end
  end
end

function loadCommunicationSettings()
  communicationSettings.whitelistedPlayers = {}
  communicationSettings.ignoredPlayers = {}

  local ignoreNode = g_settings.getNode('IgnorePlayers')
  if ignoreNode then
    for _, player in pairs(ignoreNode) do
      table.insert(communicationSettings.ignoredPlayers, player)
    end
  end

  local whitelistNode = g_settings.getNode('WhitelistedPlayers')
  if whitelistNode then
    for _, player in pairs(whitelistNode) do
      table.insert(communicationSettings.whitelistedPlayers, player)
    end
  end

  communicationSettings.useIgnoreList = g_settings.getBoolean('UseIgnoreList')
  communicationSettings.useWhiteList = g_settings.getBoolean('UseWhiteList')
  communicationSettings.privateMessages = g_settings.getBoolean('IgnorePrivateMessages')
  communicationSettings.yelling = g_settings.getBoolean('IgnoreYelling')
  communicationSettings.allowVIPs = g_settings.getBoolean('AllowVIPs')
end

function saveCommunicationSettings()
  local tmpIgnoreList = {}
  local ignoredPlayers = getIgnoredPlayers()
  for i = 1, #ignoredPlayers do
    table.insert(tmpIgnoreList, ignoredPlayers[i])
  end

  local tmpWhiteList = {}
  local whitelistedPlayers = getWhitelistedPlayers()
  for i = 1, #whitelistedPlayers do
    table.insert(tmpWhiteList, whitelistedPlayers[i])
  end

  g_settings.set('UseIgnoreList', communicationSettings.useIgnoreList)
  g_settings.set('UseWhiteList', communicationSettings.useWhiteList)
  g_settings.set('IgnorePrivateMessages', communicationSettings.privateMessages)
  g_settings.set('IgnoreYelling', communicationSettings.yelling)
  g_settings.setNode('IgnorePlayers', tmpIgnoreList)
  g_settings.setNode('WhitelistedPlayers', tmpWhiteList)
end

function getIgnoredPlayers()
  return communicationSettings.ignoredPlayers
end

function getWhitelistedPlayers()
  return communicationSettings.whitelistedPlayers
end

function isUsingIgnoreList()
  return communicationSettings.useIgnoreList
end

function isUsingWhiteList()
  return communicationSettings.useWhiteList
end
function isIgnored(name)
  return table.find(communicationSettings.ignoredPlayers, name, true)
end

function addIgnoredPlayer(name)
  if isIgnored(name) then return end
  addIgnoreListPanel(name)
  table.insert(communicationSettings.ignoredPlayers, name)
  communicationSettings.useIgnoreList = true
end

function removeIgnoredPlayer(name)
  removeIgnoreListPanel(name)
  table.removevalue(communicationSettings.ignoredPlayers, name)
end

function isWhitelisted(name)
  return table.find(communicationSettings.whitelistedPlayers, name, true)
end

function addWhitelistedPlayer(name)
  if isWhitelisted(name) then return end
  table.insert(communicationSettings.whitelistedPlayers, name)
end

function removeWhitelistedPlayer(name)
  table.removevalue(communicationSettings.whitelistedPlayers, name)
end

function isIgnoringPrivate()
  return communicationSettings.privateMessages
end

function isIgnoringYelling()
  return communicationSettings.yelling
end

function isAllowingVIPs()
  return communicationSettings.allowVIPs
end

function onClickIgnoreButton()
  if communicationWindow then 
    communicationWindow:destroy() 
  else
    communicationWindow = g_ui.createWidget('CommunicationWindow', modules.game_interface.getRootPanel())
  
    local ignoreListPanel = communicationWindow:getChildById('ignoreList')
    local whiteListPanel = communicationWindow:getChildById('whiteList')
    communicationWindow.onDestroy = function() communicationWindow = nil end

    local useIgnoreListBox = communicationWindow:getChildById('checkboxUseIgnoreList')
    useIgnoreListBox:setChecked(communicationSettings.useIgnoreList)
    local useWhiteListBox = communicationWindow:getChildById('checkboxUseWhiteList')
    useWhiteListBox:setChecked(communicationSettings.useWhiteList)

    local removeWhitelistButton = communicationWindow:getChildById('buttonWhitelistRemove')
    removeWhitelistButton:disable()
    whiteListPanel.onChildFocusChange = function() removeWhitelistButton:enable() end
    removeWhitelistButton.onClick = function()
      local selection = whiteListPanel:getFocusedChild()
      if selection then
        whiteListPanel:removeChild(selection)
        selection:destroy()
      end
      removeWhitelistButton:disable()
    end

    local newlyIgnoredPlayers = {}
    local addIgnoreName = communicationWindow:getChildById('ignoreNameEdit')
    local addIgnoreButton = communicationWindow:getChildById('buttonIgnoreAdd')
    local addIgnoreFunction = function()
      local newEntry = addIgnoreName:getText()
      if newEntry == '' then return end
      if table.find(getIgnoredPlayers(), newEntry) then return end
      if table.find(newlyIgnoredPlayers, newEntry) then return end
      addIgnoreListPanel(newEntry)
      table.insert(newlyIgnoredPlayers, newEntry)
      addIgnoreName:setText('')
    end
    addIgnoreButton.onClick = addIgnoreFunction

    local newlyWhitelistedPlayers = {}
    local addWhitelistName = communicationWindow:getChildById('whitelistNameEdit')
    local addWhitelistButton = communicationWindow:getChildById('buttonWhitelistAdd')
    local addWhitelistFunction = function()
      local newEntry = addWhitelistName:getText()
      if newEntry == '' then return end
      if table.find(getWhitelistedPlayers(), newEntry) then return end
      if table.find(newlyWhitelistedPlayers, newEntry) then return end
      local label = g_ui.createWidget('WhiteListLabel', whiteListPanel)
      label:setText(newEntry)
      table.insert(newlyWhitelistedPlayers, newEntry)
      addWhitelistName:setText('')
    end
    addWhitelistButton.onClick = addWhitelistFunction

    communicationWindow.onEnter = function()
      if addWhitelistName:isFocused() then
        addWhitelistFunction()
      elseif addIgnoreName:isFocused() then
        addIgnoreFunction()
      end
    end

    local ignorePrivateMessageBox = communicationWindow:getChildById('checkboxIgnorePrivateMessages')
    ignorePrivateMessageBox:setChecked(communicationSettings.privateMessages)
    local ignoreYellingBox = communicationWindow:getChildById('checkboxIgnoreYelling')
    ignoreYellingBox:setChecked(communicationSettings.yelling)
    local allowVIPsBox = communicationWindow:getChildById('checkboxAllowVIPs')
    allowVIPsBox:setChecked(communicationSettings.allowVIPs)

    local saveButton = communicationWindow:recursiveGetChildById('buttonSave')
    saveButton.onClick = function()
      communicationSettings.ignoredPlayers = {}
      for i = 1, ignoreListPanel:getChildCount() do
        addIgnoredPlayer(ignoreListPanel:getChildByIndex(i):getText())
      end

      communicationSettings.whitelistedPlayers = {}
      for i = 1, whiteListPanel:getChildCount() do
        addWhitelistedPlayer(whiteListPanel:getChildByIndex(i):getText())
      end

      communicationSettings.useIgnoreList = useIgnoreListBox:isChecked()
      communicationSettings.useWhiteList = useWhiteListBox:isChecked()
      communicationSettings.yelling = ignoreYellingBox:isChecked()
      communicationSettings.privateMessages = ignorePrivateMessageBox:isChecked()
      communicationSettings.allowVIPs = allowVIPsBox:isChecked()
      -- communicationWindow:destroy()
    end

    local cancelButton = communicationWindow:recursiveGetChildById('buttonCancel')
    cancelButton.onClick = function()
      communicationWindow:destroy()
    end


    local removeIgnoreButton = communicationWindow:getChildById('buttonIgnoreRemove')
    removeIgnoreButton:disable()
    ignoreListPanel.onChildFocusChange = function() removeIgnoreButton:enable() end
    removeIgnoreButton.onClick = function()
      local selection = ignoreListPanel:getFocusedChild()
      if selection then
        ignoreListPanel:removeChild(selection)
        selection:destroy()
      end
      removeIgnoreButton:disable()
      saveButton.onClick()
    end
 
    local ignoredPlayers = getIgnoredPlayers()
    for i = 1, #ignoredPlayers do
      addIgnoreListPanel(ignoredPlayers[i])
    end

    local whitelistedPlayers = getWhitelistedPlayers()
    for i = 1, #whitelistedPlayers do
      local label = g_ui.createWidget('WhiteListLabel', whiteListPanel)
      label:setText(whitelistedPlayers[i])
    end
  end
end

function addIgnoreListPanel(name)
  if not communicationWindow then return end
  local label = g_ui.createWidget('IgnoreListLabel', communicationWindow.ignoreList)
  
  label:setId(name)
  label:setText(name)
end

function removeIgnoreListPanel(name)
  if not communicationWindow then return end
  local label = communicationWindow.ignoreList[name]
  if label then
    label:destroy()
  end  
end

function online()
  defaultTab = addTab(tr('Default'), true, true)
  serverTab = addTab(tr('Server Log'), false, true)
  -- Reidratar pins agora que ja temos o nome do personagem
  pinsToRestore = {}
  pinsWantedSet = nil
  if pinsByCharCache then
    local char = g_game.getCharacterName()
    if char and char ~= '' then
      pinsToRestore = pinsByCharCache[char] or {}
      if #pinsToRestore > 0 then
        pinsWantedSet = {}
        for _, name in ipairs(pinsToRestore) do pinsWantedSet[name] = true end
      end
    end
  end

  if pinsToRestore and #pinsToRestore > 0 then
    scheduleEvent(applyPinsBulk, 50)
    scheduleEvent(applyPinsBulk, 500)
    scheduleEvent(applyPinsBulk, 1500)
  end

  if g_game.getClientVersion() < 862 then
    local gameRootPanel = modules.game_interface.getRootPanel()
    g_keyboard.bindKeyDown('Ctrl+R', openPlayerReportRuleViolationWindow, gameRootPanel)
  end
  -- open last channels
  local lastChannelsOpen = g_settings.getNode('lastChannelsOpen')
  if lastChannelsOpen then
    local savedChannels = lastChannelsOpen[g_game.getCharacterName()]
    if savedChannels then
      for channelName, channelId in pairs(savedChannels) do
        channelId = tonumber(channelId)
        if channelId ~= -1 and channelId < 100 then
          if not table.find(channels, channelId) then
            g_game.joinChannel(channelId)
            table.insert(ignoredChannels, channelId)
          end
        end
      end
    end
  end
  local chatWasHidden = g_settings.getBoolean(chatHiddenSetting)
  hideAndShowChat(chatWasHidden)
  if not chatWasHidden then
    enableChat()
  end

  -- botões de navegação das tabs (prev/next)
  consoleTabBar:setNavigation(
    consolePanel:getChildById('prevChannelButton'),
    consolePanel:getChildById('nextChannelButton')
  )

  scheduleEvent(function() consoleTabBar:selectTab(defaultTab) end, 500)
  scheduleEvent(function() ignoredChannels = {} end, 3000)
end

function offline()
  if g_game.getClientVersion() < 862 then
    local gameRootPanel = modules.game_interface.getRootPanel()
    g_keyboard.unbindKeyDown('Ctrl+R', gameRootPanel)
  end
  clear()
end

function onChannelEvent(channelId, name, type)
  local fmt = ChannelEventFormats[type]
  if not fmt then
    print(('Unknown channel event type (%d).'):format(type))
    return
  end

  local channel = channels[channelId]
  if channel then
    local tab = getTab(channel)
    if tab then
      addTabText(fmt:format(name), SpeakTypesSettings.channelOrange, tab)
    end
  end
end

function isChatHidden()
  return not (consolePanel and consolePanel:isVisible())
end

function hideAndShowChat(visible)
  g_settings.set(chatHiddenSetting, visible)
  addEvent(function()
    if visible or consoleToggleChat:isChecked() then
      modules.game_walking.enableWSAD()
    else
      modules.game_walking.disableWSAD()
    end

    if not visible then
      consoleTextEdit:clearText()
    end
    consolePanel:setVisible(not visible)
    if visible then
      floatingConsolePanel:setSize(consolePanel:getSize())
      floatingConsolePanel:setPosition(consolePanel:getPosition())
      floatingConsolePanel:raise()
      floatingConsolePanel:setVisible(true)
    else
      floatingConsolePanel:setVisible(false)
      if floatingConsoleBuffer then
        floatingConsoleBuffer:destroyChildren()
      end
    end
    if not visible then
      enableChat()
      scheduleEvent(function()
        if consoleTextEdit then
          consoleTextEdit:setCursorVisible(true)
          consoleTextEdit:focus()
        end
      end, 50)
    else
      -- apenas oculta o console, preservando o estado do input
    end

  end)
end