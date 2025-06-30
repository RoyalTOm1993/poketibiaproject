
function Protocol_create(byte)
  local protocol      = {}
        protocol[1]   = {}
        protocol[2]   = 0
        protocol[3]   = byte
 
  return protocol
end

function Protocol_add(protocol, string)
  table.insert(protocol[1], string)
end

function Protocol_read(protocol)
  protocol[2] = protocol[2] + 1
  return protocol[1][protocol[2]]
end

function isInArray(table, value)
  for i = 1, #table do
    if table[i] == value then
      return true
    end

    return false
  end
end

local MainWindow, PassInfo, ItemsVip, ItemsPremium, PassLevels, MainButton, ImageShow, UIBlackWindow, UIBuyLevel, CollectButton, AlertCollect
local MissionWindow, MissionPanel, buyWindow
local Key = "Alt+P"
local Opcode = 20
local imagePath = "images/"

local PassVip = 1
local PassPremium = 2
local PassFirst = PassVip
local ItemsPanel = {}

local HasPremium = false
local PassLevel = 0
local MaxPassLevel = 100

lastTimeSearch = 0

function init()
  connect(g_game, {
    onGameStart = refresh,
    onGameEnd = refresh,
  })
  MainWindow = g_ui.displayUI('pass')
  PassInfo = MainWindow:getChildById('passInfo')
  ItemsVip = MainWindow:getChildById('itemsVip')
  ItemsPremium = MainWindow:getChildById('itemsPremium')
  -- ImageShow = MainWindow:getChildById('imageShow')
  UIBuyLevel = MainWindow:getChildById('UIBuyLevel')
  UIBlackWindow = MainWindow:getChildById('UIBlackWindow')
  CollectButton = MainWindow:getChildById('collectButton')
  AlertCollect = MainWindow:getChildById('alertCollect')
  PassLevels = MainWindow:getChildById('passLevels')
  
  MissionWindow = MainWindow:getChildById('missionPanel')
  MissionScrollbar = MainWindow:getChildById('missionScrollBar')
  MissionReturn = MainWindow:getChildById('returnMission')
  MissionPanel = MissionWindow
  
  -- MissionWindow:hide()
  
  ItemsPanel = {
    [PassVip] = ItemsVip,
    [PassPremium] = ItemsPremium,
  }
  
  -- g_keyboard.bindKeyDown(Key, toggle)
  
  MainButton = modules.client_topmenu.addRightGameToggleButton('MainButton', tr('Pass') .. ' ('..Key..')', '/images/topbuttons/pass', toggle)
  MainButton:setOn(false)
--   MainButton:setWidth(56)
  ProtocolGame.registerExtendedOpcode(Opcode, getPass)
  MainWindow:hide()
end

local function stopEvent(panel)
  if panel.event then
    removeEvent(panel.event)
    panel.event = nil
  end
end

function terminate()
  disconnect(g_game, {
    onGameStart = refresh,
    onGameEnd = refresh,
  })
  -- g_keyboard.unbindKeyDown(Key)
  
  ProtocolGame.unregisterExtendedOpcode(Opcode)
  MainWindow:destroy()
  MainWindow = nil
  MissionWindow:destroy()
  MissionWindow = nil
  stopEvent(PassInfo)
  -- MainButton:destroy()
  -- MainButton = nil
end

function toggle()
  if MainWindow:isVisible() then
    hide()
	hideMissions()
    stopEvent(PassInfo)
  else
	g_game.talk('/passopen')
    show()
	hideMissions()
    stopEvent(PassInfo)
  end
  -- if MainButton:isOn() then
    -- hide()
  -- else
    -- show()
  -- end
end

function refresh()
  MainWindow:hide()
  MissionWindow:hide()
  closeBuyWindow()
  stopEvent(PassInfo)
  -- MainButton:setOn(false)
end

function show()
  MainWindow:show()
  MainWindow:raise()
  MainWindow:focus()
  lastTimeSearch = os.time()+2
  stopEvent(PassInfo)
  -- MainButton:setOn(true)
end

function hide()
  MainWindow:hide()
  MissionWindow:hide()
  closeBuyWindow()
  stopEvent(PassInfo)
  -- MainButton:setOn(false)
end

function hideMissions() -- toggle mission
  MissionWindow:hide()
  MissionScrollbar:hide()
  MissionReturn:hide()

  PassInfo:show()
  ItemsVip:show()
  ItemsPremium:show()
  -- ImageShow:show()
  PassLevels:show()
  MainWindow:getChildById('windowList'):show()
  MainWindow:getChildById('SeparatorList'):show()
  MainWindow:getChildById('ItemsPremiumImageText'):show()
  MainWindow:getChildById('itemsPremium'):show()
  MainWindow:getChildById('itemsPremiumImage'):show()
  MainWindow:getChildById('itemsVipImage'):show()
  MainWindow:getChildById('ItemsVipImageText'):show()
  MainWindow:getChildById('itemsVip'):show()
  MainWindow:getChildById('itemsScrollBar'):show()
  MainWindow:getChildById('backgroundMissions'):hide()
  MainWindow:getChildById('tittleMissions'):hide()
  stopEvent(PassInfo)
end

function closeBuyWindow()
  if buyWindow then
    buyWindow:destroy()
    buyWindow = nil
  end
end

function getPass(protocol, opcode, buffer)
  -- print(protocol, opcode, buffer)
  -- local receive = json.decode(buffer)
  local receive = loadstring("return ".. buffer)()
  if receive[3] == 'Pass' then
    HasPremium = Protocol_read(receive)
    PassLevel = Protocol_read(receive)
    MaxPassLevel = Protocol_read(receive)
    local passStars = Protocol_read(receive)
    local passDaysLeft = Protocol_read(receive)
    local passTime = Protocol_read(receive)
	
    PassInfo:getChildById('level'):setText(PassLevel)
	if passDaysLeft >= 2 then
		PassInfo:getChildById('daysLeft'):setText((passDaysLeft >= 2 and passDaysLeft.." Dias" or ""))
	else
		PassInfo:getChildById('daysLeft'):setText((passDaysLeft == 1 and passDaysLeft.." Dia" or ""))
	end
	if passTime == 0 then 
		PassInfo:getChildById('TimeLeft'):hide() 
	else
		PassInfo:getChildById('TimeLeft'):show() 
	end

	if passTime > 0 then PassInfo:getChildById('TimeLeft'):setText("  "..convertTime2(passTime)) end
    seconds = passTime
    local function update()
      seconds = seconds - 1
      PassInfo:getChildById('TimeLeft'):setText("  "..convertTime2(seconds))
      PassInfo.event = scheduleEvent(update, 1000)
    end
	PassInfo.event = scheduleEvent(update, 1000)

    for star, child in ipairs(PassInfo:getChildById('stars'):getChildren()) do
      if passStars == 10 then
        child:setOn(star <= passStars)
        PassInfo:getChildById('levelLabel'):setText("Full")
      else
        child:setOn(star <= passStars)
        PassInfo:getChildById('levelLabel'):setText((passStars*10).."/100")
      end
    end
    if HasPremium then
      if PassLevel < MaxPassLevel then --- caso já tenha o passe executar isso
	    PassInfo:getChildById('atualPass'):setImageSource('images/info/elite')
		
	  end
    else --- caso não tenha o passe, executar isso aqui...
	    PassInfo:getChildById('atualPass'):setImageSource('images/info/basico')
    end
		-- ImageShow:getChildById('separator'):hide()
		-- ImageShow:getChildById('title'):setText("")
		-- ImageShow:getChildById('image'):setImageSource("")
		-- ImageShow:getChildById('desc'):setText("")
  elseif receive[3] == 'Items' then
    local first = Protocol_read(receive)
    local items = Protocol_read(receive)
    local collecteds = Protocol_read(receive)
	if first then
      for passType=PassFirst, PassPremium do
	    ItemsPanel[passType]:destroyChildren()
	  end
	  PassLevels:destroyChildren()
	end
	-- print(buffer)
	drawPassItems(items, collecteds)
  elseif receive[3] == 'Missions' then
    local first = Protocol_read(receive)
    local missions = Protocol_read(receive)
	if first then
	  MissionPanel:destroyChildren()
	end
	for num, mission in ipairs(missions) do
	if num ~= 1 then
	  local widget = g_ui.createWidget('MissionWidget', MissionPanel)
	  if mission.progress >= mission.max then
	    widget:getChildById('star'):setOn(true)
	    widget:getChildById('star'):setTooltip('Concluido')
	    widget:getChildById('xptext'):setText(mission.stars.."0")
	  else
	    widget:getChildById('xptext'):setText(mission.stars.."0")
	  end
	  widget:getChildById('itemIcon'):setOutfit({type = mission.lookType})
	  widget:getChildById('itemIcon'):setSize(mission.size)

	  widget:getChildById('itemIcon'):setMarginLeft(mission.position.x)
	  widget:getChildById('itemIcon'):setMarginTop(mission.position.y)
	  
	  widget:getChildById('progress'):setText(""..mission.progress.." de "..mission.max.."")
	  widget:getChildById('desc'):setText(mission.desc)
	end
   end
  elseif receive[3] == 'OffLinePlayer' then
	    MainWindow:getChildById('SendPassPlayer'):getChildById('TextAlert'):setImageSource('images/sendpass/alert_text/offline')
	    g_effects.fadeIn(MainWindow:getChildById('SendPassPlayer'):getChildById('TextAlert'), 250)
		scheduleEvent(function() g_effects.fadeOut(MainWindow:getChildById('SendPassPlayer'):getChildById('TextAlert'), 250) end, 10000)
  elseif receive[3] == 'NoDiamondsPass' then
	    MainWindow:getChildById('SendPassPlayer'):getChildById('TextAlert'):setImageSource('images/sendpass/alert_text/diamonds')
	    g_effects.fadeIn(MainWindow:getChildById('SendPassPlayer'):getChildById('TextAlert'), 250)
		scheduleEvent(function() g_effects.fadeOut(MainWindow:getChildById('SendPassPlayer'):getChildById('TextAlert'), 250) end, 10000)
  elseif receive[3] == 'SucessSendPass' then
	    MainWindow:getChildById('SendPassPlayer'):getChildById('TextAlert'):setImageSource('images/sendpass/alert_text/sucesso')
	    g_effects.fadeIn(MainWindow:getChildById('SendPassPlayer'):getChildById('TextAlert'), 250)
		scheduleEvent(function() g_effects.fadeOut(MainWindow:getChildById('SendPassPlayer'):getChildById('TextAlert'), 250) end, 10000)
        local SendPassPlayer = MainWindow:getChildById("SendPassPlayer")
	    SendPassPlayer:getChildById("search"):setText("")
  elseif receive[3] == 'Pass50Buyed' then
    Pass50Buyed()
  elseif receive[3] == 'Pass35Buyed' then
    Pass35Buyed()
  elseif receive[3] == 'NoDiamondsBuyPass' then
    NoDiamondsBuyPass()
  elseif receive[3] == 'NoDiamonds' then
    NoDiamonds()
  elseif receive[3] == 'NoPass' then
    NoPass()
  elseif receive[3] == "PassLevelUp" then
  PassLevelUp()
  elseif receive[3] == 'HassMission' then
    HassPremiumPass()
    PassInfo:getChildById('passLeveuUp'):show()
  elseif receive[3] == 'NoMission' then
    NoPremiumPass()
    PassInfo:getChildById('passLeveuUp'):hide()
  elseif receive[3] == 'NoVipCollect' then
	NoVipCollect()
  elseif receive[3] == 'UpdateReward' then
    local level = Protocol_read(receive)
    local passType = Protocol_read(receive)
	local widget = ItemsPanel[passType]:getChildById(level)
	if widget then
	  g_ui.createWidget('CollectedMask', widget)
	end
  end
end

function dump(tbl, indent)
    indent = indent or 0

    for k, v in pairs(tbl) do
        local formattedKey = tostring(k)
        local formattedValue = tostring(v)

        if type(v) == "table" then
            print(string.rep("  ", indent) .. formattedKey .. " =>")
            dump(v, indent + 1)
        else
            print(string.rep("  ", indent) .. formattedKey .. " => " .. formattedValue)
        end
    end
end

local function isInArray(array, element)
    for _, value in ipairs(array) do
        if value == element then
            return true
        end
    end
    return false
end

function drawPassItems(items, collecteds)
  for num, reward in ipairs(items) do
    local level = reward[PassPremium+1]
    for passType=PassFirst, PassPremium do
	  local widget = g_ui.createWidget(reward[passType].style , ItemsPanel[passType])
	  widget:setId(level)
	  if reward[passType].style == "UIPassItem" then
	    widget:getChildById('item'):setItemId(reward[passType].item.clientId)
	    widget:getChildById('item'):setItemCount(reward[passType].item.count)
	  elseif reward[passType].style == "UIPassSkin" then
	    widget:setOutfit({type = reward[passType].skin.lookType, head = 0, body = 0, legs = 0, feet = 0})
	  elseif reward[passType].style == "UIPassExperience" then
	    widget:setText(reward[passType].experience)
	  elseif reward[passType].style == "UIPassPremiumPoints" then
	    widget:setText(reward[passType].premiumPoints)
	  end
	  if isInArray(collecteds[passType], level) then
	    g_ui.createWidget('CollectedMask', widget)
	  end
	  widget:setTooltip(reward[passType].name)
	  if (passType == passPremium and not HasPremium) or PassLevel < level then
	    g_ui.createWidget("UIPassMask" , widget)
	  end
      widget.onClick = function()
			-- ImageShow:getChildById('separator'):hide()
			-- ImageShow:getChildById('title'):setText("")
			-- ImageShow:getChildById('image'):setImageSource("")
			-- ImageShow:getChildById('desc'):setText("")

	    if reward[passType].style == "UIPassItem" and reward[passType].item.id == 1 then
		  widget:getChildById('item'):setItemId(reward[passType].item.clientId)
		  return
		end
        if level <= PassLevel and not isInArray(collecteds[passType], level) then
      	    g_game.getProtocolGame():sendExtendedOpcode(Opcode, level..'#Collect#'..passType)
        end
      end
    end
	local widget = g_ui.createWidget('PassWidgetLevel', PassLevels)
	widget:setText(level)
  end
end

function showMissions()
  MissionWindow:show()
  MissionWindow:raise()
  MissionWindow:focus()
  MissionScrollbar:show()
  MissionReturn:show()

  PassInfo:hide()
  ItemsVip:hide()
  ItemsPremium:hide()
  -- ImageShow:hide()
  UIBuyLevel:hide()
  UIBlackWindow:hide()
  CollectButton:hide()
  AlertCollect:hide()
  PassLevels:hide()
  MainWindow:getChildById('windowList'):hide()
  MainWindow:getChildById('SeparatorList'):hide()
  MainWindow:getChildById('ItemsPremiumImageText'):hide()
  MainWindow:getChildById('itemsPremium'):hide()
  MainWindow:getChildById('itemsPremiumImage'):hide()
  MainWindow:getChildById('itemsVipImage'):hide()
  MainWindow:getChildById('ItemsVipImageText'):hide()
  MainWindow:getChildById('itemsVip'):hide()
  MainWindow:getChildById('itemsScrollBar'):hide()
  MainWindow:getChildById('backgroundMissions'):show()
  MainWindow:getChildById('tittleMissions'):show()
  stopEvent(PassInfo)
end

function hideUpWindow()
  UIBuyLevel:hide()
  UIBlackWindow:hide()
  stopEvent(PassInfo)
end

function showUpWindow()
  UIBlackWindow:show()
  UIBuyLevel:show()
  UIBuyLevel:getChildById('comprar').onClick = function()
	g_game.getProtocolGame():sendExtendedOpcode(Opcode, "BuyLevel")
	UIBuyLevel:hide()
	UIBlackWindow:hide()
  end
end

function hideAlertWindow()
  MainWindow:getChildById('AlertWindow'):hide()
  UIBlackWindow:hide()
  stopEvent(PassInfo)
end
function NoPremiumPass()
  PassInfo:getChildById('missions'):setImageSource("images/block_missoes")
  PassInfo:getChildById('missions').onClick = function() NoRequesits() end
  PassInfo:getChildById('passLeveuUp'):hide()
end
function HassPremiumPass()
  PassInfo:getChildById('missions'):setImageSource("images/missoes")
  PassInfo:getChildById('missions').onClick = function() showMissions() end
end
function AtualPass()
  local icone = "pass"
  local color = "#ffffff"
  local text = "activePass"

  UIBlackWindow:show()MainWindow:getChildById('AlertWindow'):show()MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageSource("images/AlertWindow/icon/"..icone)MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageColor(color)MainWindow:getChildById('AlertWindow'):getChildById('text'):setImageSource("images/AlertWindow/text/"..text)
  stopEvent(PassInfo)
end
function NoRequesits()
  local icone = "exclaming"
  local color = "#ffe400"
  local text = "novip_collect"

  UIBlackWindow:show()MainWindow:getChildById('AlertWindow'):show() MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageSource("images/AlertWindow/icon/"..icone)MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageColor(color)MainWindow:getChildById('AlertWindow'):getChildById('text'):setImageSource("images/AlertWindow/text/"..text)
  stopEvent(PassInfo)
end
function NoPass()
  local icone = "pass"
  local color = "#ffffff"
  local text = "nopass"

  UIBlackWindow:show()MainWindow:getChildById('AlertWindow'):show() MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageSource("images/AlertWindow/icon/"..icone)MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageColor(color)MainWindow:getChildById('AlertWindow'):getChildById('text'):setImageSource("images/AlertWindow/text/"..text)
  stopEvent(PassInfo)
end
function NoVipCollect()
  local icone = "vip"
  local color = "#ffffff"
  local text = "novip_colect"

  UIBlackWindow:show()MainWindow:getChildById('AlertWindow'):show() MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageSource("images/AlertWindow/icon/"..icone)MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageColor(color)MainWindow:getChildById('AlertWindow'):getChildById('text'):setImageSource("images/AlertWindow/text/"..text)
  stopEvent(PassInfo)
end
function NoDiamonds()
  local icone = "diamond"
  local color = "#ffffff"
  local text = "nodiamonds"

  UIBuyLevel:hide()UIBlackWindow:show()MainWindow:getChildById('AlertWindow'):show() MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageSource("images/AlertWindow/icon/"..icone)MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageColor(color)MainWindow:getChildById('AlertWindow'):getChildById('text'):setImageSource("images/AlertWindow/text/"..text)
  stopEvent(PassInfo)
end
function NoDiamondsBuyPass()
  local icone = "diamond"
  local color = "#ffffff"
  local text = "no_diamonds_passbuy"

  UIBuyLevel:hide()UIBlackWindow:show()MainWindow:getChildById('AlertWindow'):show() MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageSource("images/AlertWindow/icon/"..icone)MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageColor(color)MainWindow:getChildById('AlertWindow'):getChildById('text'):setImageSource("images/AlertWindow/text/"..text)
  stopEvent(PassInfo)
end
function Pass35Buyed()
  local icone = "pass"
  local color = "#ffffff"
  local text = "Pass_buyed"

  UIBuyLevel:hide()UIBlackWindow:show()MainWindow:getChildById('AlertWindow'):show() MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageSource("images/AlertWindow/icon/"..icone)MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageColor(color)MainWindow:getChildById('AlertWindow'):getChildById('text'):setImageSource("images/AlertWindow/text/"..text)
  PassInfo:getChildById('missions'):setImageSource("images/missoes")
  PassInfo:getChildById('missions').onClick = function() showMissions() end
  PassInfo:getChildById('passLeveuUp'):show()
  stopEvent(PassInfo)
end
function Pass50Buyed()
  local icone = "pass"
  local color = "#ffffff"
  local text = "passplus_buyed"

  UIBuyLevel:hide()UIBlackWindow:show()MainWindow:getChildById('AlertWindow'):show() MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageSource("images/AlertWindow/icon/"..icone)MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageColor(color)MainWindow:getChildById('AlertWindow'):getChildById('text'):setImageSource("images/AlertWindow/text/"..text)
  PassInfo:getChildById('missions'):setImageSource("images/missoes")
  PassInfo:getChildById('missions').onClick = function() showMissions() end
  PassInfo:getChildById('passLeveuUp'):show()
  stopEvent(PassInfo)
end
function PassLevelUp()
  local icone = "pass"
  local color = "#ffffff"
  local text = "pass_levelup"

  UIBuyLevel:hide()UIBlackWindow:show()MainWindow:getChildById('AlertWindow'):show() MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageSource("images/AlertWindow/icon/"..icone)MainWindow:getChildById('AlertWindow'):getChildById('icon'):setImageColor(color)MainWindow:getChildById('AlertWindow'):getChildById('text'):setImageSource("images/AlertWindow/text/"..text)

  stopEvent(PassInfo)
end


function convertTime2(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

function convertOsTime(seconds)
  local hours = 0
  local minutes = 0
  repeat
    if seconds >= 60 then
      minutes = minutes + 1; seconds = seconds - 60
    elseif minutes >= 60 then
      hours = hours + 1; minutes = minutes - 60
    end
  until seconds < 60 and minutes < 60
  return {hours = hours, seconds = seconds, minutes = minutes}
end
