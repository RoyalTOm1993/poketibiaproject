local OPCODE = 99

local NETWORK_ACTION = {}

local TOTAL_EMBLEMS = 23
local BUFFS_ROWS = 9

local VocationIcon = {
  [1] = "sorc",
  [2] = "druid",
  [3] = "paladin",
  [4] = "knight",
  [5] = "sorc",
  [6] = "druid",
  [7] = "paladin",
  [8] = "knight"
}

local MESSAGE_STYLES = {}

local LANGUAGES = {
  "English",
  "Polish",
  "Portuguese",
  "German",
  "Dutch",
  "Spanish"
}

local JOIN_STATUS = {
  "Public",
  "Invite Only"
}

local Buffs = {
  level = {5, 5, 5, 10, 10, 10, 15, 15, 15}
}

local window = nil
local windowButton = nil
local settings = nil

local generalPanel = nil
local generalPanelBtn = nil

local buffsPanel = nil
local buffsPanelBtn = nil
local buffsGroups = {}

local membersPanel = nil
local membersPanelBtn = nil

local ranksPanel = nil
local ranksPanelBtn = nil

local warsPanel = nil
local warsPanelBtn = nil

local inboxPanel = nil
local inboxPanelBtn = nil
local lastInbox = 0
local maxInbox = 0
local fetchingInbox = false

local topGuildsPanel = nil
local topGuildsPanelBtn = nil
local topGuilds = {}
local guildIdToTop = {}
local lastTop = 0
local maxTop = 0
local fetchingTop = false

local titleEdit = nil
local createEmblem = 0

local GUILDS_CFG = {}
local myGuild = nil
local permissions = 0

function init()
  connect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )

  ProtocolGame.registerExtendedOpcode(OPCODE, onExtendedOpcode)
  ProtocolGame.registerOpcode(GameServerOpcodes.GameServerGuildWarKills, onWarsKills)

  if g_game.isOnline() then
    create()
  end

  NETWORK_ACTION = {
    ["config"] = onGuildsConfig,
    ["general"] = onGeneralGuildData,
    ["members"] = onGuildMembersData,
    ["ranks"] = onGuildRanksData,
    ["inbox"] = onGuildInboxData,
    ["top"] = onTopGuildsData,
    ["message"] = onGuildInboxMessage,
    ["perms"] = onGuildPermissionsUpdate,
    ["memberRank"] = onGuildMemberRankUpdate,
    ["gold"] = onGuildGoldUpdate,
    ["contribution"] = onContributionUpdate,
    ["level"] = onGuildLevelUpdate,
    ["settings"] = onGuildSettingsUpdate,
    ["topUpdate"] = onTopGuildUpdate,
    ["online"] = onGuildMemberOnline,
    ["offline"] = onGuildMemberOffline,
    ["joined"] = onGuildMemberJoined,
    ["kicked"] = onGuildMemberKicked,
    ["left"] = onLeftGuild,
    ["removeEmblem"] = onRemoveEmblem,
    ["emblems"] = onUpdateEmblems,
    ["disbanded"] = onGuildDisbanded,
    ["finished"] = onMessageFinished,
    ["buffs"] = onGuildBuffs,
    ["pacifism"] = onPacifismStatus,
    ["pacifismUp"] = onPacifismUpdate,
    ["wars"] = onGuildWars,
    ["newWar"] = onNewGuildWar,
    ["warPrepare"] = onWarPreparation,
    ["warStart"] = onWarStart,
    ["warEnd"] = onWarEnd,
    ["warKill"] = onWarKill,
    ["warRevoked"] = onWarRevoked,
    ["newLeader"] = onNewLeader,
    ["error"] = function(data)
      displayErrorBox("Error", data)
    end
  }
end

function terminate()
  disconnect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )

  ProtocolGame.unregisterExtendedOpcode(OPCODE)
  ProtocolGame.unregisterOpcode(GameServerOpcodes.GameServerGuildWarKills)

  destroy()
end

function create()
  window = g_ui.displayUI("guild_management")
  windowButton = modules.client_topmenu.addRightGameToggleButton("guildManagement", tr("Guild Management"), "images/topbuttons/guild.png", toggle)
  window:hide()

  window.tabBar:setContentWidget(window.content)

  generalPanel = g_ui.loadUI("general")
  generalPanelBtn = window.tabBar:addTab("General", generalPanel)

  local status = generalPanel.noGuild:recursiveGetChildById("status")
  for i = 1, #JOIN_STATUS do
    status:addOption(JOIN_STATUS[i], i)
  end

  local language = generalPanel.noGuild:recursiveGetChildById("language")
  for i = 1, #LANGUAGES do
    language:addOption(LANGUAGES[i], i)
  end

  buffsPanel = g_ui.loadUI("buffs")
  buffsPanelBtn = window.tabBar:addTab("Buffs", buffsPanel)

  for row = 1, BUFFS_ROWS do
    local rowPanel = buffsPanel.buffs:recursiveGetChildById("row" .. row)
    local buff1 = rowPanel:getChildByIndex(1)
    local buff2 = rowPanel:getChildByIndex(2)

    local group = UIRadioGroup.create()
    group:addWidget(buff1)
    group:addWidget(buff2)
    table.insert(buffsGroups, group)
  end
  buffsPanel.save.onClick = saveBuffs

  membersPanel = g_ui.loadUI("members")
  membersPanelBtn = window.tabBar:addTab("Members", membersPanel)

  ranksPanel = g_ui.loadUI("ranks")
  ranksPanelBtn = window.tabBar:addTab("Ranks", ranksPanel)

  warsPanel = g_ui.loadUI("wars")
  warsPanelBtn = window.tabBar:addTab("Wars", warsPanel)

  inboxPanel = g_ui.loadUI("inbox")
  inboxPanelBtn = window.tabBar:addTab("Inbox", inboxPanel)

  topGuildsPanel = g_ui.loadUI("topguilds")
  topGuildsPanelBtn = window.tabBar:addTab("Top Guilds", topGuildsPanel)

  topGuildsPanel.list.onScrollChange = onTopGuildsScroll
  warsPanel.selection.guildsData.onScrollChange = onTopGuildsScroll
  inboxPanel.list.onScrollChange = onGuildInboxScroll

  warsPanel.declaration.conditions:recursiveGetChildById("forceWar").onCheckChange = onForceWarChanged
  warsPanel.war.options.selection.onOptionChange = onWarSelected

  settings = g_ui.displayUI("settings")
  settings:hide()

  sendPacket("fetch")
end

function destroy()
  lastTop = 0
  maxTop = 0
  fetchingTop = false
  topGuilds = {}

  lastInbox = 0
  maxInbox = 0
  fetchingInbox = false

  permissions = 0
  myGuild = nil

  createEmblem = 0

  for _, group in ipairs(buffsGroups) do
    group:destroy()
  end
  buffsGroups = {}

  if titleEdit then
    titleEdit:destroy()
    titleEdit = nil
  end

  if window then
    window:destroy()
    window = nil
  end
  if windowButton then
    windowButton:destroy()
    windowButton = nil
  end
  if settings then
    settings:destroy()
    settings = nil
  end
end

function onExtendedOpcode(protocol, code, buffer)
  local json_status, json_data =
    pcall(
    function()
      return json.decode(buffer)
    end
  )

  if not json_status then
    g_logger.error("[Guild Management] JSON error: " .. json_data)
    return false
  end

  local action = json_data.action
  local data = json_data.data
  if NETWORK_ACTION[action] then
    NETWORK_ACTION[action](data)
  end
end

function sendPacket(action, data)
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(OPCODE, json.encode({action = action, data = data}))
  end
end

function onGuildsConfig(data)
  GUILDS_CFG = data

  MESSAGE_STYLES = {
    [GUILDS_CFG.MESSAGE_TYPES.JOIN_INVITATION] = "InviteInbox",
    [GUILDS_CFG.MESSAGE_TYPES.KICKED_OUT] = "KickedInbox",
    [GUILDS_CFG.MESSAGE_TYPES.JOIN_REQUEST] = "RequestInbox",
    [GUILDS_CFG.MESSAGE_TYPES.MEMBER_JOINED] = "JoinedInbox",
    [GUILDS_CFG.MESSAGE_TYPES.MEMBER_LEFT] = "LeftInbox",
    [GUILDS_CFG.MESSAGE_TYPES.GOLD_DEPOSIT] = "DepositInbox",
    [GUILDS_CFG.MESSAGE_TYPES.WAR_DECLARATION] = "WarInbox"
  }
end

function onGeneralGuildData(data)
  if not data then
    buffsPanelBtn:disable()
    membersPanelBtn:disable()
    ranksPanelBtn:disable()
    warsPanelBtn:disable()

    generalPanel.noGuild:show()
    generalPanel.general:hide()
    window.leaveBtn:hide()
    window.settingsBtn:hide()
  else
    buffsPanelBtn:enable()
    membersPanelBtn:enable()
    ranksPanelBtn:enable()
    warsPanelBtn:enable()

    generalPanel.noGuild:hide()
    generalPanel.general:show()

    permissions = data.permissions
    myGuild = data

    ranksPanelBtn:setEnabled(hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_ROLES))
    window.settingsBtn:setVisible(hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS))
    window.leaveBtn:setText(myGuild.leader == g_game.getCharacterName() and "Disband" or "Leave")
    window.leaveBtn:show()

    generalPanel.general.stats:setText(data.name)

    for key, value in pairs(data) do
      if not table.contains({"emblem", "permissions", "exp", "buffs", "pacifism", "pacifismStatus"}, key) then
        local w = generalPanel.general:recursiveGetChildById(key)
        if w then
          if key == "members" then
            w:setText(value[1] .. " / " .. value[2])
          elseif key == "language" then
            w:setText(LANGUAGES[value])
          elseif key == "joinStatus" then
            w:setText(JOIN_STATUS[value])
          elseif key == "reqLevel" then
            w:setText((value > 0 and value or "None"))
          else
            w:setText(value)
          end
        end
      end
    end

    setGuildEmblem(generalPanel.general:recursiveGetChildById("emblem"), data.emblem)

    local guildExp = generalPanel.general.stats.guildExp
    -- 1: current gold
    -- 2: gold for next level
    guildExp:setValue(data.exp[1], 0, data.exp[2])
    local need = math.max(0, data.exp[2] - data.exp[1])
    if need == 0 then
      guildExp:setBackgroundColor("#00FFAA")
      guildExp:setTooltip("Guild has enough gold to level up.")
      if hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_GOLD) then
        generalPanel.general.stats.levelUp:enable()
      end
    else
      guildExp:setBackgroundColor("#FFAA00")
      guildExp:setTooltip("Deposit at least " .. data.exp[2] - data.exp[1] .. " gold to level up.")
      generalPanel.general.stats.levelUp:disable()
    end

    generalPanel.general.stats:recursiveGetChildById("nextLevel"):setText(data.exp[2])

    for row = 1, BUFFS_ROWS do
      local buff = data.buffs[row]
      local rowPanel = buffsPanel.buffs:recursiveGetChildById("row" .. row)
      local buff1 = rowPanel:getChildByIndex(1)
      local buff2 = rowPanel:getChildByIndex(2)
      local lock = rowPanel:getChildByIndex(3)
      local hasLevel = data.level >= Buffs.level[row]
      buff1:setEnabled(hasLevel)
      buff2:setEnabled(hasLevel)
      local buff1Selected = buff == 1
      local buff2Selected = buff == 2
      buff1:setOn(buff1Selected)
      buff2:setOn(buff2Selected)
      buffsGroups[row]:selectWidget(buff1Selected and buff1 or (buff2Selected and buff2 or nil))
      buffsGroups[row].onSelectionChange = onBuffSelected
      buffsGroups[row]:setEnabled(hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_BUFFS))
      lock:setVisible(not hasLevel)
    end

    buffsPanel.delay:setText("Buffs can be saved once every " .. toTime(getBuffsDelayDuration()))

    onPacifismStatus(data)

    warsPanel.declaration.conditions.duration:setRange(GUILDS_CFG.WARS.DURATION.MIN, GUILDS_CFG.WARS.DURATION.MAX)
    warsPanel.declaration.conditions.duration:setStep(math.floor(GUILDS_CFG.WARS.DURATION.MAX / GUILDS_CFG.WARS.DURATION.MIN))
    warsPanel.declaration.conditions.duration:setValue(0)
    warsPanel.declaration.conditions.duration:onGeometryChange()

    warsPanel.declaration.conditions.kills:setRange(GUILDS_CFG.WARS.KILLS.MIN, GUILDS_CFG.WARS.KILLS.MAX)
    warsPanel.declaration.conditions.kills:setStep(math.floor(GUILDS_CFG.WARS.KILLS.MAX / GUILDS_CFG.WARS.KILLS.MIN))
    warsPanel.declaration.conditions.kills:setValue(0)
    warsPanel.declaration.conditions.kills:onGeometryChange()

    warsPanel.declaration.conditions.goldBet:setRange(GUILDS_CFG.WARS.GOLD_BET.MIN, GUILDS_CFG.WARS.GOLD_BET.MAX)
    warsPanel.declaration.conditions.goldBet:setStep(math.floor(GUILDS_CFG.WARS.GOLD_BET.MAX / GUILDS_CFG.WARS.GOLD_BET.MIN))
    warsPanel.declaration.conditions.goldBet:setValue(0)
    warsPanel.declaration.conditions.goldBet:onGeometryChange()

    for i = 1, #topGuilds do
      local guild = topGuilds[i]
      local entry = topGuildsPanel.list[tostring(guild.id)]
      local requestBtn = entry.info:recursiveGetChildById("request")
      requestBtn:setVisible(false)
    end
  end
end

function onGuildMembersData(data)
  myGuild.membersList = data
  for i, member in ipairs(data) do
    local entry = g_ui.createWidget("EntryPanel", membersPanel.list)
    entry:setId(member.name)
    if member.name == g_game.getCharacterName() then
      entry:setOn(true)
    end
    entry.position:setText(i .. ".")
    entry.vocation:setImageSource("images/guild_management/" .. (VocationIcon[member.voc] or "unknown"))
    entry.name:setText(member.name)
    entry.options.chat:setVisible(member.name ~= g_game.getCharacterName() and member.online)
    entry.options.chat.onClick = function()
      g_game.openPrivateChannel(member.name)
    end
    entry.rank:setText(member.rank)
    entry.level:setText(member.level)
    entry.status:setImageSource("images/game/skulls/skull_" .. (member.online and "green" or "red"))
    entry.status.online = member.online
    entry.status.last = member.last
    entry.status:setTooltip(member.online and "Online" or ("Offline for " .. getOfflineTime(member.last)))
    connect(
      entry.status,
      "onHoverChange",
      function(w, hover)
        if hover then
          w:setTooltip(w.online and "Online" or ("Offline for " .. getOfflineTime(w.last)))
        end
      end
    )
    entry.options.menu.onClick = function()
      createMemberMenu(i)
    end

    local chatVisible = entry.options.chat:isVisible()
    entry.options:setPaddingLeft(chatVisible and 11 or 25)
    entry.options:setPaddingRight(chatVisible and 11 or 25)
  end
end

function onGuildRanksData(data)
  myGuild.ranks = {}
  myGuild.tempRanks = {}
  for k, v in pairs(data) do
    myGuild.ranks[k] = v
    myGuild.tempRanks[k] = v
  end

  for _, rank in ipairs(myGuild.ranks) do
    if type(rank.leader) == "number" then
      rank.leader = rank.leader == 1
    end
    if type(rank.default) == "number" then
      rank.default = rank.default == 1
    end
    if type(rank.removed) == "number" then
      rank.removed = rank.removed == 1
    end
  end

  for _, rank in ipairs(myGuild.tempRanks) do
    if type(rank.leader) == "number" then
      rank.leader = rank.leader == 1
    end
    if type(rank.default) == "number" then
      rank.default = rank.default == 1
    end
    if type(rank.removed) == "number" then
      rank.removed = rank.removed == 1
    end
  end

  ranksPanel.ranksTable:clearData()
  if not ranksPanel.ranksTable.dataSpace then
    ranksPanel.ranksTable:setTableData(ranksPanel.ranksTableData)
  end
  for _, rank in ipairs(data) do
    local row = ranksPanel.ranksTable:addRow(
      {
        {style = "RankTitleColumn", text = rank.name},
        {
          checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS),
          imageOffset = "28 3",
          permission = GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS
        },
        {
          checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS),
          imageOffset = "26 3",
          permission = GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS
        },
        {checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.EDIT_ROLES), permission = GUILDS_CFG.PERMISSIONS.EDIT_ROLES},
        {
          checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS),
          imageOffset = "23 3",
          permission = GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS
        },
        {checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.MANAGE_GOLD), permission = GUILDS_CFG.PERMISSIONS.MANAGE_GOLD},
        {
          checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.MANAGE_WARS),
          imageOffset = "24 3",
          permission = GUILDS_CFG.PERMISSIONS.MANAGE_WARS
        },
        {
          checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.MANAGE_BUFFS),
          imageOffset = "24 3",
          permission = GUILDS_CFG.PERMISSIONS.MANAGE_BUFFS
        }
      },
      nil,
      {
        rankId = rank.id
      }
    )

    local isLeader = false
    if rank.leader then
      isLeader = true
      row:getChildByIndex(1):setColor("green")

      for i = GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS + 1, GUILDS_CFG.PERMISSIONS.LAST do
        row:getChildByIndex(i):disable()
      end
    elseif rank.default then
      row:getChildByIndex(1):setColor("orange")
    end

    row:getChildByIndex(1):setPhantom(false)
    row:getChildByIndex(1):setTooltip("Double click to edit title")
    row:getChildByIndex(1).onDoubleClick = editRankTitle
    if not isLeader then
      for i = GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS + 1, GUILDS_CFG.PERMISSIONS.LAST do
        row:getChildByIndex(i).onCheckChange = onRankPermissionCheck
      end
    end
  end

  ranksPanel.ranksTable.onSelectionChange = onRankRowSelected
end

function onTopGuildsData(data)
  fetchingTop = false
  if data.new then
    topGuildsPanel.list.onScrollChange = nil
    warsPanel.selection.guildsData.onScrollChange = nil
    topGuildsPanel.list:destroyChildren()
    lastTop = 0
    topGuilds = {}
  end

  for i = 1, #data.top do
    local guild = data.top[i]
    table.insert(topGuilds, guild)
    guildIdToTop[guild.id] = i + lastTop
    local entry = g_ui.createWidget("GuildEntry", topGuildsPanel.list)
    entry:setId(guild.id)
    entry:setText(guild.name)
    setGuildEmblem(entry.logo, guild.emblem)
    entry.position:setText(i + lastTop)
    entry.info:recursiveGetChildById("leader"):setText(guild.leader)
    entry.info:recursiveGetChildById("level"):setText(guild.level)
    entry.info:recursiveGetChildById("members"):setText(guild.members[1] .. " / " .. guild.members[2])
    entry.info:recursiveGetChildById("avgLevel"):setText(guild.avgLevel)
    entry.info:recursiveGetChildById("wars"):setText(guild.won)
    entry.info:recursiveGetChildById("levels"):setText(guild.total)
    entry.info:recursiveGetChildById("language"):setText(LANGUAGES[guild.language])
    entry.info:recursiveGetChildById("status"):setText(JOIN_STATUS[guild.status])
    entry.info:recursiveGetChildById("reqLevel"):setText(guild.reqLevel)
    local requestBtn = entry.info:recursiveGetChildById("request")
    requestBtn:setVisible(not myGuild and guild.status == 1)
    if guild.status == 1 then
      requestBtn.onClick = requestJoin
      requestBtn.guild = guild.id
    end
  end

  lastTop = lastTop + #data.top
  maxTop = data.last

  updateWarsTable(lastTop - #data.top)

  if data.new then
    topGuildsPanel.list.onScrollChange = onTopGuildsScroll
    warsPanel.selection.guildsData.onScrollChange = onTopGuildsScroll
  end
end

function requestJoin(btn)
  local guildId = btn.guild
  sendPacket("request", guildId)
end

function onTopGuildsScroll(scrollarea, virtualOffset)
  if lastTop < maxTop then
    local maximum = scrollarea.verticalScrollBar:getMaximum()
    local value = virtualOffset.y
    if value + 120 >= maximum and not fetchingTop then
      fetchingTop = true
      sendPacket("top", lastTop)
    end
  end
end

function onGuildInboxData(data)
  fetchingInbox = false
  lastInbox = lastInbox + data.size
  maxInbox = data.last
  for i = 1, #data.inbox do
    inboxPanel.list:addChild(createMessageWidget(data.inbox[i]))
  end
end

function onGuildInboxScroll(scrollarea, virtualOffset)
  if lastInbox < maxInbox then
    local maximum = scrollarea.verticalScrollBar:getMaximum()
    local value = virtualOffset.y
    if value + 120 >= maximum and not fetchingInbox then
      fetchingInbox = true
      sendPacket("inbox", lastInbox)
    end
  end
end

function onGuildInboxMessage(message)
  inboxPanel.list:insertChild(1, createMessageWidget(message))
  maxInbox = maxInbox + 1
end

function createMessageWidget(message)
  local inboxEntry = g_ui.createWidget(MESSAGE_STYLES[message.type])
  inboxEntry:setId("msg" .. message.id)
  inboxEntry.date:setText(os.date("%X %x", message.date))
  inboxEntry.msgId = message.id
  inboxEntry.type = message.type
  inboxEntry.targetId = message.targetId
  inboxEntry.guildId = message.guildId
  inboxEntry.date = message.date
  if
    message.type == GUILDS_CFG.MESSAGE_TYPES.JOIN_INVITATION or message.type == GUILDS_CFG.MESSAGE_TYPES.JOIN_REQUEST or
      message.type == GUILDS_CFG.MESSAGE_TYPES.WAR_DECLARATION
   then
    if message.finished == 1 then
      inboxEntry.acceptBtn:disable()
      inboxEntry.rejectBtn:disable()
      inboxEntry:setHeight(95)
    else
      inboxEntry.acceptBtn.onClick = acceptMessage
      inboxEntry.rejectBtn.onClick = rejectMessage
      inboxEntry:setHeight(116)
    end
  end
  inboxEntry.panel.text:setColoredText(generateInboxText(message.text, "#FFFFFF", "#FFAA00"))
  return inboxEntry
end

function acceptMessage(button)
  local parent = button:getParent()
  local targetId = parent.targetId -- this is warId if war declaration
  local guildId = parent.guildId -- this is target guild id if war declaration
  sendPacket("accept", {id = parent.msgId, type = parent.type, targetId = targetId, guildId = guildId})
end

function rejectMessage(button)
  local parent = button:getParent()
  local targetId = parent.targetId -- this is warId if war declaration
  local guildId = parent.guildId -- this is target guild id if war declaration
  sendPacket("reject", {id = parent.msgId, type = parent.type, targetId = targetId, guildId = guildId})
end

function onGuildGoldUpdate(data)
  updateGoldInfo(data)
end

function onContributionUpdate(data)
  if type(data) == "number" then
    myGuild.gold = data
    generalPanel.general.stats:recursiveGetChildById("contribution"):setText(data)
  else
    if not myGuild or not myGuild.membersList then
      return
    end

    for _, m in ipairs(myGuild.membersList) do
      if m.name == data.name then
        m.contribution = data.contribution
        break
      end
    end
  end
end

function onGuildLevelUpdate(data)
  myGuild.level = data.level
  myGuild.members = data.members
  myGuild.gold = data.gold
  myGuild.next = data.next
  generalPanel.general.stats:recursiveGetChildById("level"):setText(data.level)
  generalPanel.general:recursiveGetChildById("members"):setText(data.members[1] .. " / " .. data.members[2])
  updateGoldInfo(data)

  for row = 1, BUFFS_ROWS do
    local rowPanel = buffsPanel.buffs:recursiveGetChildById("row" .. row)
    local buff1 = rowPanel:getChildByIndex(1)
    local buff2 = rowPanel:getChildByIndex(2)
    local lock = rowPanel:getChildByIndex(3)
    local hasLevel = data.level >= Buffs.level[row]
    buff1:setEnabled(hasLevel)
    buff2:setEnabled(hasLevel)
    lock:setVisible(not hasLevel)
  end
end

function updateGoldInfo(data)
  generalPanel.general.stats:recursiveGetChildById("gold"):setText(data.gold)
  local guildExp = generalPanel.general.stats.guildExp
  guildExp:setValue(data.gold, 0, data.next)
  local need = math.max(0, data.next - data.gold)
  if need == 0 then
    guildExp:setBackgroundColor("#00FFAA")
    guildExp:setTooltip("Guild has enough gold to level up.")
    if hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_GOLD) then
      generalPanel.general.stats.levelUp:enable()
    end
  else
    guildExp:setBackgroundColor("#FFAA00")
    guildExp:setTooltip("Deposit at least " .. data.next - data.gold .. " gold to level up.")
    generalPanel.general.stats.levelUp:disable()
  end
  generalPanel.general.stats:recursiveGetChildById("nextLevel"):setText(data.next)
end

function onGuildSettingsUpdate(data)
  generalPanel.general:recursiveGetChildById("joinStatus"):setText(JOIN_STATUS[data.status])
  generalPanel.general:recursiveGetChildById("language"):setText(LANGUAGES[data.language])
  generalPanel.general:recursiveGetChildById("reqLevel"):setText(data.reqLevel)
  generalPanel.general:recursiveGetChildById("motd"):setText(data.motd)

  setGuildEmblem(generalPanel.general:recursiveGetChildById("emblem"), data.emblem)

  if warsPanel.war:isVisible() then
    setGuildEmblem(warsPanel.war.current.emblem1, data.emblem)
  end

  myGuild.joinStatus = data.status
  myGuild.language = data.language
  myGuild.reqLevel = data.reqLevel
  myGuild.motd = data.motd
  myGuild.emblem = data.emblem
  myGuild.tempEmblem = data.emblem
end

function getTopGuildByGID(guildId)
  return topGuilds[guildIdToTop[guildId]]
end

function onTopGuildUpdate(data)
  local widget = topGuildsPanel.list[tostring(data.id)]
  if not widget then
    return
  end

  local guild = getTopGuildByGID(data.id)
  if guild then
    for k, v in pairs(data) do
      guild[k] = v
    end
  end

  if data.members then
    widget.info:recursiveGetChildById("members"):setText(data.members[1] .. " / " .. data.members[2])
    local requestBtn = widget.info:recursiveGetChildById("request")
    if requestBtn:isVisible() and data.members[1] < data.members[2] then
      if guild then
        requestBtn:setVisible(not myGuild and guild.status == 1)
      end
    elseif data.members[1] >= data.members[2] then
      requestBtn:setVisible(false)
    end
  end

  if data.emblem then
    setGuildEmblem(widget.logo, data.emblem)

    if guild then
      local war = getWarByGuildId(data.id)
      if war then
        war.emblem = data.emblem
      end
      if warsPanel.war:isVisible() and warsPanel.war.current.name2:getText() == guild.name then
        setGuildEmblem(warsPanel.war.current.emblem2, data.emblem)
      end
    end

    widget.info:recursiveGetChildById("language"):setText(LANGUAGES[data.language])
    widget.info:recursiveGetChildById("status"):setText(JOIN_STATUS[data.status])
    widget.info:recursiveGetChildById("request"):setVisible(not myGuild and data.status == 1)
    widget.info:recursiveGetChildById("reqLevel"):setText(data.reqLevel)
  end

  if data.level then
    widget.info:recursiveGetChildById("level"):setText(data.level)
  end

  if data.avgLevel then
    widget.info:recursiveGetChildById("avgLevel"):setText(data.avgLevel)
    widget.info:recursiveGetChildById("levels"):setText(data.levels)
  end

  if data.won then
    widget.info:recursiveGetChildById("wars"):setText(data.won)
  end
end

function onGuildMemberOnline(name)
  local widget = membersPanel.list[name]
  if not widget then
    return
  end

  widget.options.chat:show()
  widget.options.chat.onClick = function()
    g_game.openPrivateChannel(name)
  end
  widget.status:setImageSource("images/game/skulls/skull_green")
  widget.status.online = true
  widget.status.last = os.time()
  widget.status:setTooltip("Online")

  widget.options:setPaddingLeft(11)
  widget.options:setPaddingRight(11)
end

function onGuildMemberOffline(name)
  local widget = membersPanel.list[name]
  if not widget then
    return
  end

  widget.options.chat:hide()
  widget.options.chat.onClick = nil
  widget.status:setImageSource("images/game/skulls/skull_red")
  widget.status.online = false
  widget.status.last = os.time()
  widget.status:setTooltip("Offline for " .. getOfflineTime(os.time()))

  widget.options:setPaddingLeft(25)
  widget.options:setPaddingRight(25)
end

function invitePlayer(name)
  if not hasPermission(GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS) then
    return
  end

  sendPacket("invite", name)
end

function kickPlayer(name)
  if not hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS) then
    return
  end

  sendPacket("kick", name)
end

function onGuildMemberKicked(data)
  local widget = membersPanel.list[data.name]
  if not widget then
    return
  end

  for i = 1, #myGuild.membersList do
    if myGuild.membersList[i].name == data.name then
      table.remove(myGuild.membersList, i)
      break
    end
  end

  myGuild.total = data.levels
  myGuild.members = data.members

  generalPanel.general:recursiveGetChildById("total"):setText(data.levels)
  generalPanel.general:recursiveGetChildById("members"):setText(data.members[1] .. " / " .. data.members[2])

  membersPanel.list:destroyChildren()
  onGuildMembersData(myGuild.membersList)
end

function onGuildMemberJoined(data)
  table.insert(myGuild.membersList, data.member)

  myGuild.total = data.levels
  myGuild.members = data.members

  generalPanel.general:recursiveGetChildById("total"):setText(data.levels)
  generalPanel.general:recursiveGetChildById("members"):setText(data.members[1] .. " / " .. data.members[2])

  membersPanel.list:destroyChildren()
  onGuildMembersData(myGuild.membersList)
end

function onLeftGuild()
  myGuild = nil
  permissions = 0

  membersPanel.list:destroyChildren()
  membersPanelBtn:disable()
  ranksPanelBtn:disable()
  warsPanelBtn:disable()
  buffsPanelBtn:disable()

  generalPanel.noGuild:show()
  generalPanel.general:hide()

  window.leaveBtn:hide()
  window.settingsBtn:hide()
  window.tabBar:selectTab(generalPanelBtn)

  for i = 1, #topGuilds do
    local guild = topGuilds[i]
    local entry = topGuildsPanel.list[tostring(guild.id)]
    local requestBtn = entry.info:recursiveGetChildById("request")
    requestBtn:setVisible(guild.status == 1)
  end
end

function onGuildDisbanded()
  onLeftGuild()
end

function onMessageFinished(data)
  local widget = inboxPanel.list:getChildById("msg" .. data)
  if not widget then
    return
  end

  widget.acceptBtn.onClick = nil
  widget.rejectBtn.onClick = nil

  widget.acceptBtn:disable()
  widget.rejectBtn:disable()

  widget.acceptBtn:setVisible(false)
  widget.rejectBtn:setVisible(false)
  widget:setHeight(95)
end

function onRemoveEmblem(data)
  if type(data) == "table" then
    for _, pid in ipairs(data) do
      local player = g_map.getCreatureById(pid)
      if player then
        player:setEmblem(EmblemNone)
      end
    end
  else
    local player = g_map.getCreatureById(data)
    if player then
      player:setEmblem(EmblemNone)
    end
  end
end

function onUpdateEmblems(data)
  for _, pid in ipairs(data.players) do
    local player = g_map.getCreatureById(pid)
    if player then
      player:setEmblem(data.emblem)
    end
  end
end

function onGuildPermissionsUpdate(perms)
  permissions = perms
  local hasRankPerms = hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_ROLES)
  ranksPanelBtn:setEnabled(hasRankPerms)
  if not hasRankPerms then
    if window.tabBar:getCurrentTab() == ranksPanelBtn then
      window.tabBar:selectPrevTab()
    end
  end
  for row = 1, BUFFS_ROWS do
    buffsGroups[row]:setEnabled(hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_BUFFS))
  end
  window.settingsBtn:setVisible(hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS))
  window.leaveBtn:setText(myGuild.leader == g_game.getCharacterName() and "Disband" or "Leave")
end

function onGuildMemberRankUpdate(data)
  local widget = membersPanel.list[data.name]
  if not widget then
    return
  end

  widget.rank:setText(data.rank)
end

function onRankRowSelected(widget, selectedRow, oldSelectedRow)
  ranksPanel.default:setEnabled(selectedRow ~= nil)
  ranksPanel.delete:setEnabled(selectedRow ~= nil)
end

function onRankPermissionCheck(widget, checked)
  if widget.oldCheck == nil then
    widget.oldCheck = not checked
    widget:setImageColor("red")
  else
    if widget.oldCheck ~= checked then
      widget:setImageColor("red")
    else
      widget:setImageColor("white")
    end
  end
  ranksPanel.save:enable()
  ranksPanel.reset:enable()
end

function editRankTitle(widget)
  if titleEdit then
    titleEdit:destroy()
    titleEdit = nil
  end

  local rankId = widget:getParent().rankId
  for _, rank in ipairs(myGuild.tempRanks) do
    if rank.id == rankId then
      titleEdit =
        modules.client_textedit.show(
        widget:getText(),
        {title = "Edit rank title", description = "Use a-z, A-Z, 0-9 and space. Min 3, max 12 characters."},
        function(newTitle)
          newTitle = newTitle:trim()
          if newTitle:len() < 3 then
            displayErrorBox("Error", "Rank title needs at least 3 characters.")
            titleEdit = nil
            return
          end

          if newTitle:len() > 12 then
            displayErrorBox("Error", "Rank title is too long, max 12 characters.")
            titleEdit = nil
            return
          end

          if not newTitle:find("^[A-Za-z0-9 ]+$") then
            displayErrorBox("Error", "Rank title contains invalid characters.")
            titleEdit = nil
            return
          end

          if not widget.oldTitle then
            widget.oldTitle = widget:getText()
          end

          if widget.oldTitle == newTitle then
            if rank.leader then
              widget:setColor("green")
            elseif rank.default then
              widget:setColor("orange")
            else
              widget:setColor("#dfdfdf")
            end
          else
            widget:setColor("red")
          end

          widget:setText(newTitle)
          rank.name = newTitle
          ranksPanel.save:enable()
          ranksPanel.reset:enable()
          titleEdit = nil
        end
      )

      addEvent(
        function()
          titleEdit:focus()
          titleEdit:raise()
        end
      )
      break
    end
  end
end

function createRank()
  if titleEdit then
    titleEdit:destroy()
    titleEdit = nil
  end

  local newRank = ranksPanel.newRank:getText():trim()
  if newRank:len() < 3 then
    displayErrorBox("Error", "Rank title needs at least 3 characters.")
    return
  end

  if newRank:len() > 12 then
    displayErrorBox("Error", "Rank title is too long, max 12 characters.")
    return
  end

  if not newRank:find("^[A-Za-z0-9 ]+$") then
    displayErrorBox("Error", "Rank title contains invalid characters.")
    return
  end

  for _, rank in ipairs(myGuild.tempRanks) do
    if rank.name == newRank then
      displayErrorBox("Error", "Rank title in use.")
      return
    end
  end

  local row =
    ranksPanel.ranksTable:addRow(
    {
      {style = "RankTitleColumn", text = newRank, rankId = 0},
      {checked = false, imageOffset = "28 3", permission = GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS},
      {checked = false, imageOffset = "26 3", permission = GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS},
      {checked = false, permission = GUILDS_CFG.PERMISSIONS.EDIT_ROLES},
      {checked = false, imageOffset = "23 3", permission = GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS},
      {checked = false, permission = GUILDS_CFG.PERMISSIONS.MANAGE_GOLD},
      {checked = false, imageOffset = "24 3", permission = GUILDS_CFG.PERMISSIONS.MANAGE_WARS},
      {checked = false, imageOffset = "24 3", permission = GUILDS_CFG.PERMISSIONS.MANAGE_BUFFS}
    }
  )

  row:getChildByIndex(1):setPhantom(false)
  row:getChildByIndex(1):setTooltip("Double click to edit title")
  row:getChildByIndex(1).onDoubleClick = editRankTitle
  for i = GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS + 1, GUILDS_CFG.PERMISSIONS.LAST do
    row:getChildByIndex(i).onCheckChange = onRankPermissionCheck
  end

  table.insert(myGuild.tempRanks, {new = true, id = 0, name = newRank, permissions = 0, default = false})
  ranksPanel.newRank:setText("")
  ranksPanel.save:enable()
  ranksPanel.reset:enable()
end

function makeDefault()
  local row = ranksPanel.ranksTable.selectedRow
  for _, rank in ipairs(myGuild.tempRanks) do
    if (rank.id == 0 and rank.name == row:getChildByIndex(1):getText()) or rank.id == row.rankId then
      if rank.leader then
        displayErrorBox("Error", "You can't make Leader rank as Default.")
        return
      end

      if rank.default then
        return
      end
    end
  end

  for _, oldRow in ipairs(ranksPanel.ranksTable.rows) do
    for _, rank in ipairs(myGuild.tempRanks) do
      if rank.id == oldRow.rankId then
        if rank.default then
          oldRow:getChildByIndex(1):setColor("#dfdfdf")
          rank.default = false
        end
      end
    end
  end

  for _, rank in ipairs(myGuild.tempRanks) do
    if (rank.id == 0 and rank.name == row:getChildByIndex(1):getText()) or rank.id == row.rankId then
      row:getChildByIndex(1):setColor("orange")
      rank.default = true
    end
  end

  ranksPanel.save:enable()
  ranksPanel.reset:enable()
end

function deleteRank()
  if #myGuild.tempRanks == 2 then
    displayErrorBox("Error", "You need at least 2 ranks, Leader and Default.")
    return
  end

  local row = ranksPanel.ranksTable.selectedRow
  for _, rank in ipairs(myGuild.tempRanks) do
    if rank.id == row.rankId then
      if rank.leader then
        displayErrorBox("Error", "You can't delete Leader rank.")
        return
      end

      if rank.default then
        displayErrorBox("Error", "You can't delete Default rank.")
        return
      end

      rank.removed = true
      ranksPanel.delete:disable()
      ranksPanel.reset:enable()
      ranksPanel.save:enable()
      break
    end
  end

  row:disable()
  ranksPanel.ranksTableData:focusChild(nil)
  ranksPanel.ranksTable:selectRow(nil)

  if titleEdit then
    titleEdit:destroy()
    titleEdit = nil
  end
end

function resetRanks()
  local tempData = {}
  for k, v in pairs(myGuild.ranks) do
    tempData[k] = v
  end
  onGuildRanksData(tempData)

  ranksPanel.default:disable()
  ranksPanel.reset:disable()
  ranksPanel.delete:disable()
  ranksPanel.save:disable()
end

function saveRanks()
  if not hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_ROLES) then
    return
  end

  for _, row in ipairs(ranksPanel.ranksTable.rows) do
    for _, rank in ipairs(myGuild.tempRanks) do
      if (rank.id == 0 and rank.name == row:getChildByIndex(1):getText()) or rank.id == row.rankId then
        if rank.leader or rank.removed then
          break
        end

        rank.permissions = 0
        local all = true
        for i = GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS + 1, GUILDS_CFG.PERMISSIONS.LAST do
          local checked = row:getChildByIndex(i):isChecked()
          rank.permissions = rank.permissions + (checked and math.pow(2, i - 1) or 0)
          if not checked then
            all = false
          end
        end
        if all then
          rank.permissions = GUILDS_CFG.PERMISSIONS.ALL
        end
      end
    end

    if titleEdit then
      titleEdit:destroy()
      titleEdit = nil
    end
  end

  ranksPanel.delete:disable()
  ranksPanel.save:disable()
  ranksPanel.reset:disable()
  ranksPanel.default:disable()
  sendPacket("saveRanks", myGuild.tempRanks)
end

function openRankMenu(pos, name)
  local menu = g_ui.createWidget("PopupMenu")
  menu:setGameMenu(true)
  for _, rank in ipairs(myGuild.ranks) do
    if not rank.leader then
      menu:addOption(
        rank.name,
        function()
          sendPacket("setRank", {name = name, rankId = rank.id})
        end
      )
    end
  end
  menu:display(pos)
end

function createGuild()
  local status = tonumber(generalPanel.noGuild.general:recursiveGetChildById("status"):getCurrentOption().data)
  local reqLevel = tonumber(generalPanel.noGuild.general:recursiveGetChildById("reqLevel"):getText())
  local language = tonumber(generalPanel.noGuild.general:recursiveGetChildById("language"):getCurrentOption().data)
  local name = generalPanel.noGuild.info:recursiveGetChildById("name"):getText()

  local data = {
    name = name,
    status = status,
    reqLevel = reqLevel,
    lang = language,
    emblem = createEmblem
  }

  sendPacket("create", data)
end

function leave()
  if not myGuild then
    return
  end

  local msgBox = nil
  local onConfirm = function()
    confirmLeave()
    msgBox:destroy()
  end
  local onCancel = function()
    msgBox:destroy()
  end
  local title = ""
  local text = ""
  if myGuild.leader == g_game.getCharacterName() then
    title = "Disband your guild?"
    text = "Are you sure you want to disband your guild?\nDeposited gold will be lost and all active wars lost, there is no coming back."
  else
    title = "Leave your guild?"
    text = "Are you sure you want to leave your guild?"
  end
  msgBox = displayGeneralBox(title, text, {{text = "No", callback = onCancel}, {text = "Yes", imageColor = "red", callback = onConfirm}}, onConfirm, onCancel)
end

function confirmLeave()
  if not myGuild then
    return
  end

  sendPacket("leave")
end

function saveBuffs()
  if not hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_BUFFS) then
    return
  end

  if (myGuild.lastBuffSave / 1000) + getBuffsDelayDuration() > os.time() then
    return
  end

  local buffs = {}
  for row = 1, BUFFS_ROWS do
    local selected = buffsGroups[row]:getSelectedWidget()
    if selected then
      buffs[row] = tonumber(selected:getId())
    else
      buffs[row] = 0
    end
  end
  sendPacket("buffs", buffs)
  buffsPanel.save:disable()
end

function onBuffSelected(group, selected, previous)
  if (myGuild.lastBuffSave / 1000) + getBuffsDelayDuration() > os.time() then
    return
  end

  buffsPanel.save:enable()
end

function onGuildBuffs(data)
  for row = 1, BUFFS_ROWS do
    local buff = data.buffs[row]
    local rowPanel = buffsPanel.buffs:recursiveGetChildById("row" .. row)
    local buff1 = rowPanel:getChildByIndex(1)
    local buff2 = rowPanel:getChildByIndex(2)
    local buff1Selected = buff == 1
    local buff2Selected = buff == 2
    buff1:setOn(buff1Selected)
    buff2:setOn(buff2Selected)
    local enabled = hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_BUFFS)
    buffsGroups[row].onSelectionChange = nil
    buffsGroups[row]:enable()
    buffsGroups[row]:selectWidget(buff1Selected and buff1 or (buff2Selected and buff2 or nil))
    buffsGroups[row]:setEnabled(enabled)
    buffsGroups[row].onSelectionChange = onBuffSelected
  end
  buffsPanel.save:disable()
  buffsPanel.delay:setText("Buffs can be saved once every " .. toTime(getBuffsDelayDuration()))
  myGuild.lastBuffSave = data.lastSave
end

function showSettings()
  settings:show()
  settings:raise()
  settings:focus()

  local status = settings:recursiveGetChildById("status")
  status:clear()
  for i = 1, #JOIN_STATUS do
    status:addOption(JOIN_STATUS[i], i)
  end
  status:setCurrentOption(JOIN_STATUS[myGuild.joinStatus])

  local reqLevel = settings:recursiveGetChildById("reqLevel")
  reqLevel:setValidCharacters("0123456789")
  reqLevel:setText(myGuild.reqLevel)

  local language = settings:recursiveGetChildById("language")
  language:clear()
  for i = 1, #LANGUAGES do
    language:addOption(LANGUAGES[i], i)
  end
  language:setCurrentOption(LANGUAGES[myGuild.language])

  local widget = settings:recursiveGetChildById("emblem")
  setGuildEmblem(widget, myGuild.emblem)
  myGuild.tempEmblem = myGuild.emblem

  local motd = settings:recursiveGetChildById("motd")
  motd:setText(myGuild.motd)
end

function closeSettings()
  settings:hide()
end

function saveSettings()
  local data = {
    status = settings:recursiveGetChildById("status"):getCurrentOption().data,
    reqLevel = tonumber(settings:recursiveGetChildById("reqLevel"):getText()),
    language = settings:recursiveGetChildById("language"):getCurrentOption().data,
    emblem = myGuild.tempEmblem,
    motd = settings:recursiveGetChildById("motd"):getText()
  }

  sendPacket("settings", data)
  settings:hide()
end

function settingsNextEmblem()
  local widget = settings:recursiveGetChildById("emblem")
  myGuild.tempEmblem = myGuild.tempEmblem + 1
  if myGuild.tempEmblem > TOTAL_EMBLEMS - 1 then
    myGuild.tempEmblem = 0
  end
  local logoX = 128 * (myGuild.tempEmblem % 5)
  local logoY = 128 * math.floor(myGuild.tempEmblem / 5)
  widget:setImageClip({x = logoX, y = logoY, width = 128, height = 128})
end

function settingsPrevEmblem()
  local widget = settings:recursiveGetChildById("emblem")
  myGuild.tempEmblem = myGuild.tempEmblem - 1
  if myGuild.tempEmblem < 0 then
    myGuild.tempEmblem = TOTAL_EMBLEMS - 1
  end
  local logoX = 128 * (myGuild.tempEmblem % 5)
  local logoY = 128 * math.floor(myGuild.tempEmblem / 5)
  widget:setImageClip({x = logoX, y = logoY, width = 128, height = 128})
end

function createNextEmblem()
  local widget = generalPanel.noGuild.emblem:recursiveGetChildById("emblem")
  createEmblem = createEmblem + 1
  if createEmblem > TOTAL_EMBLEMS - 1 then
    createEmblem = 0
  end
  setGuildEmblem(widget, createEmblem)
end

function createPrevEmblem()
  local widget = generalPanel.noGuild.emblem:recursiveGetChildById("emblem")
  createEmblem = createEmblem - 1
  if createEmblem < 0 then
    createEmblem = TOTAL_EMBLEMS - 1
  end
  setGuildEmblem(widget, createEmblem)
end

function showDeposit()
  generalPanel.general.deposit.crystal:setValue(0)
  generalPanel.general.deposit.plat:setValue(0)
  generalPanel.general.deposit.gold:setValue(0)
  generalPanel.general.deposit:show()
end

function deposit()
  local crystal = generalPanel.general.deposit.crystal:getValue()
  local plat = generalPanel.general.deposit.plat:getValue()
  local gold = generalPanel.general.deposit.gold:getValue()

  local total = (crystal * 10000) + (plat * 100) + gold
  sendPacket("donate", total)
  generalPanel.general.deposit:hide()
end

function levelUp()
  sendPacket("levelUp")
end

function updateWarsTable(last)
  local selection = warsPanel.selection
  selection.guilds.onRowDoubleClick = onWarsGuildSelection

  if not selection.guilds.dataSpace then
    selection.guilds:setTableData(selection.guildsData)
  end

  if last == 0 then
    selection.guilds:toggleSorting(false)
    selection.guilds:clearData()
  end

  local index = last > 0 and last - 1 or 0
  for i = last + 1, #topGuilds do
    local guild = topGuilds[i]
    if guild.pacifismStatus ~= GUILDS_CFG.PACIFISM.ACTIVE then
      index = index + 1
      local row =
        selection.guilds:addRow(
        {
          {text = index, sortvalue = i},
          {text = guild.name},
          {text = guild.level, sortvalue = guild.level},
          {text = guild.members[1], sortvalue = guild.members[1]},
          {text = guild.total, sortvalue = guild.total},
          {text = guild.avgLevel, sortvalue = guild.avgLevel}
        },
        nil,
        {
          topGuildId = i
        }
      )

      if myGuild and guild.name == myGuild.name then
        row:disable()
      end
    end
  end

  if last == 0 then
    selection.guilds:setSorting(1, TABLE_SORTING_ASC)
  end

  selection.guilds:sort()
end

function showDeclaration()
  warsPanel.peace:hide()
  warsPanel.war:hide()
  warsPanel.selection:show()
  warsPanel.declaration:hide()
end

function backToMainWars()
  if myGuild.wars and #myGuild.wars > 0 then
    warsPanel.peace:hide()
    warsPanel.war:show()
  else
    warsPanel.peace:show()
    warsPanel.war:hide()
  end
  warsPanel.selection:hide()
  warsPanel.declaration:hide()
end

function backToList()
  warsPanel.selection:show()
  warsPanel.declaration:hide()
  warsPanel.war:hide()
end

function onWarsGuildSelection(table, selected)
  if selected then
    local topGuildId = selected.topGuildId
    local guild = topGuilds[topGuildId]

    if not guild then
      displayErrorBox("Guild Wars", "Guild not found, try again.")
      return true
    end

    if guild.name == myGuild.name then
      displayErrorBox("Guild Wars", "You can't declare war upon your own guild.")
      return true
    end

    if guild.pacifismStatus == GUILDS_CFG.PACIFISM.ACTIVE then
      displayErrorBox("Guild Wars", "Guild has Pacifism Mode.")
      return true
    end

    warsPanel.selection:hide()
    local declaration = warsPanel.declaration
    declaration.guildId = topGuildId
    declaration:show()

    setGuildEmblem(declaration.emblem, guild.emblem)
    declaration.stats:setText(guild.name)

    for key, value in pairs(guild) do
      if key ~= "emblem" then
        local widget = declaration:recursiveGetChildById(key)
        if widget then
          if key == "members" then
            widget:setText(value[1])
          else
            widget:setText(value)
          end
        end
      end
    end
  end
  return true
end

function onForceWarChanged(widget, checked)
  warsPanel.declaration.conditions.goldBet:setEnabled(not checked)
end

function declareWar()
  local declaration = warsPanel.declaration
  local guildId = declaration.guildId

  local guild = topGuilds[guildId]
  if not guild then
    displayErrorBox("Guild Wars", "Guild not found, try again.")
    return
  end

  local forced = declaration:recursiveGetChildById("forceWar"):isChecked()
  local duration = declaration.conditions.duration:getValue() * 24 * 60 * 60
  local kills = declaration.conditions.kills:getValue()
  local goldBet = declaration.conditions.goldBet:getValue()

  local messageBox = nil
  local function start()
    sendPacket("declaration", {guildId = guild.id, forced = forced, duration = duration, kills = kills, goldBet = goldBet})
    messageBox:ok()
  end
  local function cancel()
    messageBox:cancel()
  end

  local txt = string.format('You are about to declare war with guild "%s".\n', guild.name)

  if forced then
    txt = txt.format("%sCost: %d gold\nWar will start after %s.", txt, getForcedWarCost(), toTime(getWarPrepTime()))
  else
    txt =
      txt.format(
      "%sWar will start after %s from declaration approvement.\nAmount of Gold Bet will be withdrawn from your guild immediately and returned if declaration is rejected",
      txt,
      toTime(getWarPrepTime())
    )
  end

  messageBox =
    displayGeneralBox(
    "Guild War",
    txt,
    {
      {text = "Cancel", callback = cancel},
      {text = "Declare War", imageColor = "red", callback = start}
    },
    start,
    cancel
  )
end

function startPacifist()
  if not myGuild then
    return
  end

  if not hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_WARS) then
    return
  end

  local cost = getPacifismCost()

  if myGuild.gold < cost then
    displayErrorBox("Pacifism Mode", string.format("Missing %d gold from guild's account", cost - myGuild.gold))
    return
  end

  local messageBox = nil
  local function start()
    sendPacket("pacifist")
    messageBox:ok()
  end
  local function cancel()
    messageBox:cancel()
  end

  messageBox =
    displayGeneralBox(
    "Pacifism Mode",
    string.format(
      "Enabling Pacifism Mode will end all of your guild wars as the losing side.\nRquired amount of %d (%.1f%%) gold will be deducted from guild's account.",
      cost,
      (cost * 100 / myGuild.gold)
    ),
    {
      {text = "Cancel", callback = cancel},
      {text = "Start", imageColor = "green", callback = start}
    },
    start,
    cancel
  )
end

function onPacifismStatus(data)
  myGuild.pacifismStatus = data.pacifismStatus
  myGuild.pacifism = data.pacifism
  myGuild.serverTime = data.serverTime

  local pacifismStatus = getPacifismStatus()
  local pacifismDate = getPacifismDate()
  warsPanel.peace.pacifismStatus:setColoredText(
    {
      "Pacifist Mode: ",
      "#dfdfdf",
      pacifismStatus .. " ",
      "#FFAA00",
      "(" .. pacifismDate .. ")",
      "#FFDC96"
    }
  )
end

function onPacifismUpdate(data)
  local guild = getTopGuildByGID(data.guildId)
  if not guild then
    return
  end

  guild.pacifismStatus = data.pacifismStatus
end

function onGuildWars(data)
  if not myGuild then
    return
  end

  myGuild.wars = data

  warsPanel.war.options.selection:clearOptions()
  for _, war in ipairs(data) do
    warsPanel.war.options.selection:addOption(war.name, war.warId)
  end

  if myGuild.wars and #myGuild.wars > 0 then
    warsPanel.peace:hide()
    warsPanel.war:show()
  end
end

function onWarsKills(protocol, msg)
  if not myGuild then
    return
  end

  myGuild.warKills = {}
  local count = msg:getU32()

  for i = 1, count do
    local warId = msg:getU16()
    local killer = msg:getString()
    local victim = msg:getString()
    local ally = msg:getU8() == 1

    if not myGuild.warKills[warId] then
      myGuild.warKills[warId] = {}
    end

    table.insert(
      myGuild.warKills[warId],
      {
        killer = killer,
        victim = victim,
        ally = ally
      }
    )
  end
end

function onNewGuildWar(war)
  if not myGuild then
    return
  end

  if not myGuild.wars then
    myGuild.wars = {}
  end

  if not myGuild.warKills then
    myGuild.warKills = {}
  end

  myGuild.warKills[war.warId] = {}

  table.insert(myGuild.wars, war)

  warsPanel.war.options.selection:addOption(war.name, war.warId)

  if #myGuild.wars > 0 and not warsPanel.war:isVisible() then
    warsPanel.peace:hide()
    warsPanel.selection:hide()
    warsPanel.declaration:hide()
    warsPanel.war:show()
  end
end

function onWarPreparation(warId)
  if not myGuild then
    return
  end

  for _, war in ipairs(myGuild.wars) do
    if war.warId == warId then
      war.status = GUILDS_CFG.WARS.STATUS.PREPARING

      if warsPanel.war.warId == warId then
        warsPanel.war.current.details.preStatus:setText("Starts On")
        warsPanel.war.current.details.status:setText(os.date("%d/%m/%Y %H:%M", war.started + getWarPrepTime()))
        warsPanel.war.options.surrender:setText("Surrender")
      end
      break
    end
  end
end

function onWarStart(warId)
  if not myGuild then
    return
  end

  for _, war in ipairs(myGuild.wars) do
    if war.warId == warId then
      war.status = GUILDS_CFG.WARS.STATUS.STARTED

      if warsPanel.war.warId == warId then
        warsPanel.war.current.details.preStatus:setText("Status")
        warsPanel.war.current.details.status:setText("Started")
        warsPanel.war.options.surrender:setText("Surrender")
      end
      break
    end
  end
end

function onWarEnd(warId)
  if not myGuild then
    return
  end

  for _, war in ipairs(myGuild.wars) do
    if war.warId == warId then
      war.status = GUILDS_CFG.WARS.STATUS.ENDED
      break
    end
  end

  onWarRevoked(warId)
end

function onWarKill(data)
  local war = getWarById(data.warId)
  if not war then
    return
  end

  if warsPanel.war.warId ~= data.warId then
    return
  end

  insertWarKill(data)

  if not myGuild.warKills[data.warId] then
    myGuild.warKills[data.warId] = {}
  end
  table.insert(myGuild.warKills[data.warId], data)

  local alliedKills = 0
  local enemyKills = 0
  for _, kill in ipairs(myGuild.warKills[data.warId]) do
    if kill.ally then
      alliedKills = alliedKills + 1
    else
      enemyKills = enemyKills + 1
    end
  end
  warsPanel.war.current.details.kills.ally:setText(alliedKills)
  warsPanel.war.current.details.kills.enemy:setText(enemyKills)
end

function onWarSelected(widget, text, warId)
  local war = getWarById(warId)
  if not war then
    return
  end

  warsPanel.war.warId = warId

  setGuildEmblem(warsPanel.war.current.emblem1, myGuild.emblem)
  setGuildEmblem(warsPanel.war.current.emblem2, war.emblem)
  warsPanel.war.current.name1:setText(myGuild.name)
  warsPanel.war.current.name2:setText(war.name)

  local alliedKills = 0
  local enemyKills = 0
  if myGuild.warKills[warId] then
    for _, kill in ipairs(myGuild.warKills[warId]) do
      if kill.ally then
        alliedKills = alliedKills + 1
      else
        enemyKills = enemyKills + 1
      end
    end
  end
  warsPanel.war.current.details.kills.ally:setText(alliedKills)
  warsPanel.war.current.details.kills.enemy:setText(enemyKills)

  warsPanel.war.current.details.ends:setText(os.date("%d/%m/%Y %H:%M", war.started + war.duration))
  warsPanel.war.current.details.killsLimit:setText(war.killsMax)
  if war.forced == 1 then
    warsPanel.war.current.details.goldBet:setText("None")
  else
    warsPanel.war.current.details.goldBet:setText(comma_value(war.goldBet))
  end

  if war.status == GUILDS_CFG.WARS.STATUS.DECLARATION then
    warsPanel.war.current.details.preStatus:setText("Status")
    warsPanel.war.current.details.status:setText("Declaration Sent")
    warsPanel.war.options.surrender:setText("Revoke")
  elseif war.status == GUILDS_CFG.WARS.STATUS.PREPARING then
    warsPanel.war.current.details.preStatus:setText("Starts On")
    warsPanel.war.current.details.status:setText(os.date("%d/%m/%Y %H:%M", war.started + getWarPrepTime()))
    warsPanel.war.options.surrender:setText("Surrender")
  elseif war.status == GUILDS_CFG.WARS.STATUS.STARTED then
    warsPanel.war.current.details.preStatus:setText("Status")
    warsPanel.war.current.details.status:setText("Started")
    warsPanel.war.options.surrender:setText("Surrender")
  end

  warsPanel.war.kills.list:destroyChildren()
  if myGuild.warKills[warId] then
    for _, kill in ipairs(myGuild.warKills[warId]) do
      insertWarKill(kill)
    end
  end
end

function surrender()
  local war = getWarById(warsPanel.war.warId)
  if not war then
    return
  end

  local messageBox = nil
  local function surr()
    sendPacket("surrender", war.guildId)
    messageBox:ok()
  end
  local function revoke()
    sendPacket("revoke", war.guildId)
    messageBox:ok()
  end
  local function cancel()
    messageBox:cancel()
  end
  if war.status == GUILDS_CFG.WARS.STATUS.DECLARATION then
    messageBox =
      displayGeneralBox(
      "Revoke War Declaration",
      string.format("Are you sure you want to revoke war declaration with guild %s?", war.name),
      {
        {text = "Cancel", callback = cancel},
        {text = "Revoke", imageColor = "#E72222", callback = revoke}
      },
      revoke,
      cancel
    )
  elseif war.status == GUILDS_CFG.WARS.STATUS.PREPARING or war.status == GUILDS_CFG.WARS.STATUS.STARTED then
    messageBox =
      displayGeneralBox(
      "Surrender War",
      string.format("Are you sure you want to surrender war with %s?", war.name),
      {
        {text = "Cancel", callback = cancel},
        {text = "Surrender", imageColor = "#E72222", callback = surr}
      },
      surr,
      cancel
    )
  end
end

function onWarRevoked(warId)
  for id, war in ipairs(myGuild.wars) do
    if war.warId == warId then
      table.remove(myGuild.wars, id)
      break
    end
  end

  if myGuild.wars and #myGuild.wars == 0 and warsPanel.war:isVisible() then
    warsPanel.peace:show()
    warsPanel.war:hide()
  end

  warsPanel.war.options.selection:clearOptions()
  for _, war in ipairs(myGuild.wars) do
    warsPanel.war.options.selection:addOption(war.name, war.warId)
  end
end

function insertWarKill(kill)
  local entry = g_ui.createWidget("LatestKillEntry", warsPanel.war.kills.list)
  entry.killer:setText(kill.killer)
  entry.killer:setColor(kill.ally == 1 and "#E72222" or "#2FA02F")
  entry.victim:setText(kill.victim)
  entry.victim:setColor(kill.ally == 1 and "#2FA02F" or "#E72222")
end

function createMemberMenu(index)
  if not myGuild or not myGuild.membersList then
    return
  end

  local member = myGuild.membersList[index]
  if not member then
    return
  end

  local myName = g_game.getCharacterName()
  local memberLeader = myGuild.leader == member.name
  local pos = g_window.getMousePosition()
  local menu = g_ui.createWidget("PopupMenu")
  menu:setGameMenu(true)

  menu:addText("Contribution: " .. member.contribution)
  if hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS) then
    local added = false
    if not memberLeader then
      menu:addSeparator()
      added = true
      menu:addOption(
        "Set Rank",
        function()
          openRankMenu(pos, member.name)
        end
      )
    end
    if member.name ~= myName then
      if not added then
        menu:addSeparator()
        added = true
      end
      menu:addOption(
        "Kick",
        function()
          kickPlayer(member.name)
        end
      )
    end
  end

  if myGuild.leader == myName and not memberLeader then
    menu:addSeparator()
    menu:addOption(
      "Pass Leader",
      function()
        passLeader(member.name)
      end
    )
  end

  menu:display(pos)
end

function passLeader(name)
  if permissions ~= -1 or myGuild.leader ~= g_game.getCharacterName() then
    return
  end

  sendPacket("passLeader", name)
end

function onNewLeader(data)
  do
    local widget = membersPanel.list[data.newLeader]
    if not widget then
      return
    end

    widget.rank:setText(data.newLeaderRank)
  end

  do
    local widget = membersPanel.list[data.oldLeader]
    if not widget then
      return
    end

    widget.rank:setText(data.oldLeaderRank)
  end

  myGuild.leader = data.newLeader
end

-- Utility functions
function getWarById(warId)
  for _, war in ipairs(myGuild.wars) do
    if war.warId == warId then
      return war
    end
  end

  return nil
end
function getWarByGuildId(guildId)
  for _, war in ipairs(myGuild.wars) do
    if war.guildId == guildId then
      return war
    end
  end

  return nil
end

function setGuildEmblem(widget, emblem)
  local logoX = 128 * (emblem % 5)
  local logoY = 128 * math.floor(emblem / 5)
  widget:setImageClip({x = logoX, y = logoY, width = 128, height = 128})
end

function canInvite(name)
  if not myGuild then
    return false
  end

  if not hasPermission(GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS) then
    return false
  end

  for _, member in ipairs(myGuild.membersList) do
    if member.name == name then
      return false
    end
  end

  return true
end

function canKick(name)
  if not myGuild then
    return false
  end

  if not hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS) then
    return false
  end

  for _, member in ipairs(myGuild.membersList) do
    if member.name == name then
      return true
    end
  end

  return false
end

function toggle()
  if windowButton:isOn() then
    hide()
    windowButton:setOn(false)
  else
    show()
    windowButton:setOn(true)
  end
end

function show()
  if not window then
    return
  end
  window:show()
  window:raise()
  window:focus()
end

function hide()
  if not window then
    return
  end
  window:hide()
end

function hasPermission(value)
  if permissions == -1 then
    return true
  end

  return bit.band(permissions, math.pow(2, value)) ~= 0
end

function rankHasPermission(perms, value)
  if perms == -1 then
    return true
  end

  return bit.band(perms, math.pow(2, value)) ~= 0
end

function toTime(time)
  local weeks = math.floor(time / 604800)
  local days = math.floor(math.fmod(time, 604800) / 86400)
  local hours = math.floor(math.fmod(time, 86400) / 3600)
  local minutes = math.floor(math.fmod(time, 3600) / 60)
  local seconds = math.floor(math.fmod(time, 60))

  local space = false
  local str = ""
  if weeks > 0 then
    str = string.format("%d week%s", weeks, (weeks > 1 and "s" or ""))
    space = true
  end
  if days > 0 then
    if space then
      str = string.format("%s ", str)
      space = false
    end
    str = string.format("%s%d day%s", str, days, (days > 1 and "s" or ""))
    space = true
  end
  if hours > 0 then
    if space then
      str = string.format("%s ", str)
      space = false
    end
    str = string.format("%s%d hour%s", str, hours, (hours > 1 and "s" or ""))
    space = true
  end
  if minutes > 0 then
    if space then
      str = string.format("%s ", str)
      space = false
    end
    str = string.format("%s%d minute%s", str, minutes, (minutes > 1 and "s" or ""))
    space = true
  end
  if seconds > 0 then
    if space then
      str = string.format("%s ", str)
      space = false
    end
    str = string.format("%s%d second%s", str, seconds, (seconds > 1 and "s" or ""))
  end
  return str
end

function getOfflineTime(last)
  last = os.time() - last
  local days = math.floor((last / (24 * 60 * 60)) + 0.5)
  local hours = math.floor((last / (60 * 60)) + 0.5)
  local minutes = math.floor((last / 60) + 0.5)
  local seconds = last
  if seconds < 60 then
    return seconds .. " second" .. (seconds > 1 and "s." or ".")
  end
  if minutes < 60 then
    return minutes .. " minute" .. (minutes > 1 and "s." or ".")
  end
  if hours < 24 then
    return hours .. " hour" .. (hours > 1 and "s." or ".")
  end

  return days .. " day" .. (days > 1 and "s." or ".")
end

function generateInboxText(text, color, highlightColor)
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

function getForcedWarCost()
  local gold = 0

  gold = gold + GUILDS_CFG.WARS.FORCED_COST.CRYSTAL * 10000
  gold = gold + GUILDS_CFG.WARS.FORCED_COST.PLATINUM * 100
  gold = gold + GUILDS_CFG.WARS.FORCED_COST.GOLD

  return gold
end

function getWarPrepTime()
  return parseTimeTable(GUILDS_CFG.WARS.PREP_TIME)
end

function getPacifismStatus()
  if myGuild.pacifismStatus == GUILDS_CFG.PACIFISM.INACTIVE then
    return "Inactive"
  elseif myGuild.pacifismStatus == GUILDS_CFG.PACIFISM.ACTIVE then
    return "Active"
  elseif myGuild.pacifismStatus == GUILDS_CFG.PACIFISM.EXHAUSTED then
    return "Exhausted"
  end

  return ""
end

function getPacifismDate()
  if myGuild.pacifismStatus == GUILDS_CFG.PACIFISM.INACTIVE then
    return "Available"
  end

  return os.date("%X %x", os.time() + math.round((myGuild.pacifism - myGuild.serverTime) / 1000))
end

function getPacifismCost()
  local gold = 0

  gold = gold + GUILDS_CFG.PACIFISM.COST.CRYSTAL * 10000
  gold = gold + GUILDS_CFG.PACIFISM.COST.PLATINUM * 100
  gold = gold + GUILDS_CFG.PACIFISM.COST.GOLD

  return gold
end

function getBuffsDelayDuration()
  return parseTimeTable(GUILDS_CFG.BUFFS_SAVE_DELAY)
end

function parseTimeTable(time)
  local duration = 0

  duration = duration + time.WEEKS * 7 * 24 * 60 * 60
  duration = duration + time.DAYS * 24 * 60 * 60
  duration = duration + time.HOURS * 60 * 60
  duration = duration + time.MINUTES * 60
  duration = duration + time.SECONDS

  return duration
end

function comma_value(n)
  local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
  return left .. (num:reverse():gsub("(%d%d%d)", "%1."):reverse()) .. right
end
