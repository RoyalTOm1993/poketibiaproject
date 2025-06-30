minimapWidget = nil
minimapButton = nil
minimapWindow = nil
fullmapView = false
loaded = false
oldZoom = nil
oldPos = nil
local posLbl = nil

local listMembers = {
  [1] = {nome = "Nome", outfit = {}, position = {}}
}

function init()
  minimapWindow = g_ui.loadUI('minimap', modules.game_interface.getRightPanel())
  minimapWindow:setContentMinimumHeight(64)
  ProtocolGame.registerExtendedOpcode(76, receiveOpcode)
  minimapWidget = minimapWindow:recursiveGetChildById('minimap')
  posLbl = minimapWindow:recursiveGetChildById('playerPos')
  local gameRootPanel = modules.game_interface.getRootPanel()
  g_keyboard.bindKeyPress('Alt+Left', function() minimapWidget:move(1,0) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Right', function() minimapWidget:move(-1,0) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Up', function() minimapWidget:move(0,1) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Down', function() minimapWidget:move(0,-1) end, gameRootPanel)
  g_keyboard.bindKeyDown('Ctrl+M', toggle)
  g_keyboard.bindKeyDown('Ctrl+Tab', toggleFullMap)

  minimapWindow:setup()

  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
  })

  connect(LocalPlayer, {
    onPositionChange = updateCameraPosition
  })

  if g_game.isOnline() then
    online()
  end
end

function terminate()
  if g_game.isOnline() then
    saveMap()
  end
  ProtocolGame.unregisterExtendedOpcode(76, receiveOpcode)
  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
  })

  disconnect(LocalPlayer, {
    onPositionChange = updateCameraPosition
  })

  local gameRootPanel = modules.game_interface.getRootPanel()
  g_keyboard.unbindKeyPress('Alt+Left', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Right', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Up', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Down', gameRootPanel)
  g_keyboard.unbindKeyDown('Ctrl+M')
  g_keyboard.unbindKeyDown('Ctrl+Shift+M')

  minimapWindow:destroy()
  if minimapButton then
    minimapButton:destroy()
  end
end

function showMap()
  minimapWindow:open()
end

function hideMap()
  minimapWindow:close()
end

function toggle()
  if not minimapButton then return end
  if minimapButton:isOn() then
    minimapWindow:close()
    minimapButton:setOn(false)
  else
    minimapWindow:open()
    minimapButton:setOn(true)
  end
end

function onMiniWindowClose()
  if minimapButton then
    minimapButton:setOn(false)
  end
end

function online()
  loadMap()
  updateCameraPosition()
end

function offline()
  saveMap()
end

local imagesMap = {
  [0] =  "floors/minimap_",
  [1] =  "floors/minimap_",
  [2] =  "floors/minimap_",
  [3] =  "floors/minimap_",
  [4] =  "floors/minimap_",
  [5] =  "floors/minimap_",
  [6] =  "floors/minimap_",
  [7] =  "floors/minimap_",
  [8] =  "floors/minimap_",
  [9] =  "floors/minimap_",
  [10] = "floors/minimap_",
  [11] = "floors/minimap_",
  [12] = "floors/minimap_",
  [13] = "floors/minimap_",
  [14] = "floors/minimap_",
  [15] = "floors/minimap_",
}

function loadMap()
  local clientVersion = g_game.getClientVersion()
  g_minimap.clean()
  loaded = false

  local minimapFile = '/minimap.otmm'
  local dataMinimapFile = '/data' .. minimapFile
  local versionedMinimapFile = '/minimap' .. clientVersion .. '.otmm'
  if g_resources.fileExists(dataMinimapFile) then
    loaded = g_minimap.loadOtmm(dataMinimapFile)
  end
  if not loaded and g_resources.fileExists(versionedMinimapFile) then
    loaded = g_minimap.loadOtmm(versionedMinimapFile)
  end
  if not loaded and g_resources.fileExists(minimapFile) then
    loaded = g_minimap.loadOtmm(minimapFile)
  end
  if not loaded then
    print("Minimap couldn't be loaded, file missing?")
  end
  -- for z, image in pairs(imagesMap) do
  --   g_minimap.loadImage(image .. z, {x = 0, y = 0, z = z}, 0.5)
  -- end
  -- g_minimap.loadImage("floors/minimap_7", {x = 0, y = 0, z = 7}, 0.5)
  minimapWidget:load()
end

function saveMap()
  local clientVersion = g_game.getClientVersion()
  local minimapFile = '/minimap' .. clientVersion .. '.otmm' 
  g_minimap.saveOtmm(minimapFile)
  minimapWidget:save()
end



function updateCameraPosition()
  local player = g_game.getLocalPlayer()
  if not player then return end
  local pos = player:getPosition()
  if not pos then return end
  if not minimapWidget:isDragging() then
    if not fullmapView then
      minimapWidget:setCameraPosition(player:getPosition())
    end
    minimapWidget:setCrossPosition(player:getPosition())
  end
  posLbl:setText(string.format("X: %d Y: %d Z: %d", pos.x, pos.y, pos.z))
end

function toggleFullMap()
  if not fullmapView then
    fullmapView = true
    minimapWindow:hide()
    minimapWidget:setParent(modules.game_interface.getRootPanel())
    minimapWidget:fill('parent')
   minimapWidget:setAlternativeWidgetsVisible(true)
  else
    fullmapView = false
    minimapWidget:setParent(minimapWindow:getChildById('contentsPanel'))
    minimapWidget:fill('parent')
    minimapWindow:show()
    minimapWidget:setAlternativeWidgetsVisible(false)
  end

  local zoom = oldZoom or 0
  local pos = oldPos or minimapWidget:getCameraPosition()
  oldZoom = minimapWidget:getZoom()
  oldPos = minimapWidget:getCameraPosition()
  minimapWidget:setZoom(zoom)
  minimapWidget:setCameraPosition(pos)
end

local widgetsParty = {}

function receiveOpcode(protocol, opcode, buffer)
	local data = json.decode(buffer)
  local type = data.type
  if type == "join" then
    if not widgetsParty[data.name] then
      local playerData = {name = data.name, outfit = data.outfit, dir = data.dir, pos = data.pos}
      local widget = g_ui.createWidget("UIMiniMapCreature", minimapWidget)
      widget.name:setText(playerData.name)
      widget:setOutfit(playerData.outfit)
      widget:setId(playerData.name)
      widget:setDirection(playerData.dir)
      widget.pos = playerData.pos
      widgetsParty[playerData.name] = widget
      minimapWidget:centerInPosition(widget, widget.pos)
    end
  elseif type == "walk" then
    local playerData = {name = data.name, dir = data.dir, pos = data.pos, outfit = data.outfit}
    local widget = widgetsParty[playerData.name]
    if widget then
      widget:destroy()
    end
    widget = g_ui.createWidget("UIMiniMapCreature", minimapWidget)
    widget:setOutfit(playerData.outfit)
    widget:setId(playerData.name)
    widget:setDirection(playerData.dir)
    widget.name:setText(playerData.name)
    widget.pos = playerData.pos
    widgetsParty[playerData.name] = widget
    minimapWidget:centerInPosition(widget, widget.pos)
  elseif type == "leave" then
    local playerData = {name = data.name}
    local widget = widgetsParty[playerData.name]
    if widget then
      minimapWidget:removeChild(widget)
      widget:destroy()
    end
  elseif type == "disband" then
    for _, widget in pairs(widgetsParty) do
      if widget then
        widget:destroy()
      end
    end
  end
end
