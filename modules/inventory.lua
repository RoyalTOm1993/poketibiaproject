Icons = {}
Icons[PlayerStates.Poison] = { tooltip = tr('You are poisoned'), path = '/images/game/states/poisoned', id = 'condition_poisoned' }
Icons[PlayerStates.Burn] = { tooltip = tr('You are burning'), path = '/images/game/states/burning', id = 'condition_burning' }
Icons[PlayerStates.Energy] = { tooltip = tr('You are electrified'), path = '/images/game/states/electrified', id = 'condition_electrified' }
Icons[PlayerStates.Drunk] = { tooltip = tr('You are drunk'), path = '/images/game/states/drunk', id = 'condition_drunk' }
Icons[PlayerStates.ManaShield] = { tooltip = tr('You are protected by a magic shield'), path = '/images/game/states/magic_shield', id = 'condition_magic_shield' }
Icons[PlayerStates.Paralyze] = { tooltip = tr('You are paralysed'), path = '/images/game/states/slowed', id = 'condition_slowed' }
Icons[PlayerStates.Haste] = { tooltip = tr('You are hasted'), path = '/images/game/states/haste', id = 'condition_haste' }
Icons[PlayerStates.Swords] = { tooltip = tr('You may not logout during a fight'), path = '/images/game/states/logout_block', id = 'condition_logout_block' }
Icons[PlayerStates.Drowning] = { tooltip = tr('You are drowning'), path = '/images/game/states/drowning', id = 'condition_drowning' }
Icons[PlayerStates.Freezing] = { tooltip = tr('You are freezing'), path = '/images/game/states/freezing', id = 'condition_freezing' }
Icons[PlayerStates.Dazzled] = { tooltip = tr('You are dazzled'), path = '/images/game/states/dazzled', id = 'condition_dazzled' }
Icons[PlayerStates.Cursed] = { tooltip = tr('You are cursed'), path = '/images/game/states/cursed', id = 'condition_cursed' }
Icons[PlayerStates.PartyBuff] = { tooltip = tr('You are strengthened'), path = '/images/game/states/strengthened', id = 'condition_strengthened' }
Icons[PlayerStates.PzBlock] = { tooltip = tr('You may not logout or enter a protection zone'), path = '/images/game/states/protection_zone_block', id = 'condition_protection_zone_block' }
Icons[PlayerStates.Pz] = { tooltip = tr('You are within a protection zone'), path = '/images/game/states/protection_zone', id = 'condition_protection_zone' }
Icons[PlayerStates.Bleeding] = { tooltip = tr('You are bleeding'), path = '/images/game/states/bleeding', id = 'condition_bleeding' }
Icons[PlayerStates.Hungry] = { tooltip = tr('You are hungry'), path = '/images/game/states/hungry', id = 'condition_hungry' }

InventorySlotStyles = {
  [InventorySlotHead] = "HeadSlot",
  [InventorySlotNeck] = "NeckSlot",
  [InventorySlotBack] = "BackSlot",
  [InventorySlotBody] = "BodySlot",
  [InventorySlotRight] = "RightSlot",
  [InventorySlotLeft] = "LeftSlot",
  [InventorySlotLeg] = "LegSlot",
  [InventorySlotFeet] = "FeetSlot",
  [InventorySlotFinger] = "FingerSlot",
  [InventorySlotAmmo] = "AmmoSlot",
  [InventorySlotExt2] = "OrderSlot",
  [InventorySlotExt3] = "InfoSlot",
  [InventorySlotPurse] = "PurseSlot"
}

inventoryWindow = nil
inventoryPanel = nil
inventoryButton = nil
purseButton = nil
local updateHealthEvent
local pokemon = nil
local OUTFIT_REPOSITION = {
	[2106] = {top = -30, left = -10},
}

conditionPanel = nil

function init()
  connect(LocalPlayer, {
    onInventoryChange = onInventoryChange,
    onBlessingsChange = onBlessingsChange,
    onStatesChange = onStatesChange,
  })
  connect(g_game, { onGameStart = refresh })

  g_keyboard.bindKeyDown('Ctrl+I', toggle)

  inventoryButton = modules.client_topmenu.addRightGameToggleButton('inventoryButton', tr('Inventory') .. ' (Ctrl+I)', '/images/topbuttons/inventory', toggle)
  inventoryButton:setOn(true)

  inventoryWindow = g_ui.loadUI('inventory', modules.game_interface.getRightPanel())
  inventoryWindow:disableResize()
  inventoryPanel = inventoryWindow:getChildById('contentsPanel')
  
  inventoryWindow:getChildById('icon'):setImageSource('/images/ui/inventory/icon')
  inventoryWindow:getChildById('text'):setText('Inventory')
  conditionPanel = inventoryWindow:recursiveGetChildById('conditionPanel')
  


  --purseButton = inventoryPanel:getChildById('purseButton')
  local function purseFunction()
    local purse = g_game.getLocalPlayer():getInventoryItem(InventorySlotPurse)
    if purse then
      g_game.use(purse)
    end
  end
  
  ProtocolGame.registerExtendedOpcode(17, getOpCode)

  refresh()
  inventoryWindow:setup()
  inventoryWindow:getChildById('miniwindowScrollBar'):hide()
  updateHealthEvent = cycleEvent(checkCreaturesAround, 100)
end

function getOpCode(protocol, opcode, buffer)
    local status, json_data =
        pcall(
            function()
                return json.decode(buffer)
            end
        )
    if not status then
        return false
    end
	
	if json_data.action == "release" then
	    local creature = g_map.getCreatureById(json_data.creature)
		local creatureOutfit = creature:getOutfit().type
		pokemon = creature
		inventoryWindow.name:setText(creature:getName())
		inventoryWindow.pokeOutfit:setOutfit(creature:getOutfit())
		inventoryWindow.pokeOutfit:setVisible(true)
		inventoryWindow.pokeOutfit:setAnimate(true)
    inventoryWindow.pokeOutfit:setOldScaling(true)
		if OUTFIT_REPOSITION[creatureOutfit] then
			local pos = OUTFIT_REPOSITION[creatureOutfit]
			inventoryWindow.pokeOutfit:setMarginLeft(pos.left)
			inventoryWindow.pokeOutfit:setMarginTop(pos.top)
		end
		
		inventoryWindow.progressBar:setVisible(true)
		inventoryWindow.removeOutfit:setVisible(false)
        inventoryWindow.progressBar:setImageClip({ x = 0, y = 0, width = 112, height = 7 })
        inventoryWindow.progressBar:setImageRect({ x = 0, y = 0, width = 112, height = 7 })
	elseif json_data.action == "remove" then
		pokemon = nil
		inventoryWindow.name:setText("")
		inventoryWindow.progressBar:setVisible(false)
		inventoryWindow.pokeOutfit:setVisible(false)
		inventoryWindow.removeOutfit:setVisible(true)
	end
end

function checkCreaturesAround()
    if not g_game.isOnline() then
        return
    end
    if hasPokemonActive == 0 then
        return
    end

    local player = g_game.getLocalPlayer()
    if not player then
        return
    end

	if pokemon ~= nil then
      local progressPercent = math.floor(100 * pokemon:getHealthPercent() / 100)
      local Yhppc = math.floor(112 * (1 - (progressPercent / 100)))
      local rect = { x = 0, y = 0, width = 112 - Yhppc + 1, height = 7 }
      inventoryWindow.progressBar:setImageClip(rect)
      inventoryWindow.progressBar:setImageRect(rect)
    else
      inventoryWindow.progressBar:setImageClip({ x = 0, y = 0, width = 112, height = 7 })
      inventoryWindow.progressBar:setImageRect({ x = 0, y = 0, width = 112, height = 7 })
	end
end

function terminate()
  disconnect(LocalPlayer, {
    onInventoryChange = onInventoryChange,
    onBlessingsChange = onBlessingsChange,
    onStatesChange = onStatesChange
  })
  disconnect(g_game, { onGameStart = refresh })

  if g_game.isOnline() then
    offline()
  end

  g_keyboard.unbindKeyDown('Ctrl+I')

  ProtocolGame.unregisterExtendedOpcode(17)

  inventoryWindow:destroy()
  inventoryButton:destroy()
  removeEvent(updateHealthEvent)
end

function toggleAdventurerStyle(hasBlessing)
  for slot = InventorySlotFirst, InventorySlotLast do
    local itemWidget = inventoryPanel:getChildById('slot' .. slot)
    if itemWidget then
      itemWidget:setOn(hasBlessing)
    end
  end
end

function refresh()
  local player = g_game.getLocalPlayer()
  for i = InventorySlotFirst, InventorySlotLast do
    if g_game.isOnline() then
      onInventoryChange(player, i, player:getInventoryItem(i))
    else
      onInventoryChange(player, i, nil)
    end
    toggleAdventurerStyle(player and Bit.hasBit(player:getBlessings(), Blessings.Adventurer) or false)
  end

  inventoryWindow.name:setText("")
  inventoryWindow.progressBar:setVisible(false)
  inventoryWindow.pokeOutfit:setVisible(false)
  inventoryWindow.removeOutfit:setVisible(true)
  inventoryWindow.progressBar:setImageClip({ x = 0, y = 0, width = 112, height = 7 })
  inventoryWindow.progressBar:setImageRect({ x = 0, y = 0, width = 112, height = 7 })
--  purseButton:setVisible(g_game.getFeature(GamePurseSlot))
  if player then
    onStatesChange(player, player:getStates(), 0)
  end
end

function toggle()
  if inventoryButton:isOn() then
    inventoryWindow:close()
    inventoryButton:setOn(false)
  else
    inventoryWindow:open()
    inventoryButton:setOn(true)
  end
end

function onMiniWindowClose()
  inventoryButton:setOn(false)
end

-- hooked events
function onInventoryChange(player, slot, item, oldItem)
  if slot > InventorySlotLast then return end

  if slot == InventorySlotPurse then
    if g_game.getFeature(GamePurseSlot) then
--      purseButton:setEnabled(item and true or false)
    end
    return
  end
  
 -- local itemx = g_game.getLocalPlayer():getInventoryItem(item)
-- local data = itemx:getItemInfo()
  
  -- if data.pokeballInfo ~= "" then
	-- itemx:setShader("outfit_red")
  -- end

  local itemWidget = inventoryPanel:getChildById('slot' .. slot)
  if item then
    itemWidget:setStyle('InventoryItem')
    itemWidget:setItem(item)
	-- local itemX = itemWidget:getItem()
	 -- local data = itemX:getItemInfo()

		-- itemX:setShader("outfit_red")

  else
    itemWidget:setStyle(InventorySlotStyles[slot])
    itemWidget:setItem(nil)
  end
end

function onBlessingsChange(player, blessings, oldBlessings)
  local hasAdventurerBlessing = Bit.hasBit(blessings, Blessings.Adventurer)
  if hasAdventurerBlessing ~= Bit.hasBit(oldBlessings, Blessings.Adventurer) then
    toggleAdventurerStyle(hasAdventurerBlessing)
  end
end

-- status
function toggleIcon(bitChanged)
  print(bitChanged)
  local icon = conditionPanel:getChildById(Icons[bitChanged].id)
  if icon then
    icon:destroy()
  else
    icon = loadIcon(bitChanged)
    icon:setParent(conditionPanel)
  end
end

function loadIcon(bitChanged)
  local icon = g_ui.createWidget('ConditionWidget', conditionPanel)
  icon:setId(Icons[bitChanged].id)
  icon:setImageSource(Icons[bitChanged].path)
  icon:setTooltip(Icons[bitChanged].tooltip)
  return icon
end


function onStatesChange(localPlayer, now, old)
  if now == old then return end
  local bitsChanged = bit32.bxor(now, old)
  for i = 1, 32 do
    local pow = math.pow(2, i-1)
    if pow > bitsChanged then break end
    local bitChanged = bit32.band(bitsChanged, pow)
    if bitChanged ~= 0 then
      toggleIcon(bitChanged)
    end
  end
end

function offline()
  local lastCombatControls = g_settings.getNode('LastCombatControls')
  if not lastCombatControls then
    lastCombatControls = {}
  end

  conditionPanel:destroyChildren()

  local player = g_game.getLocalPlayer()
  if player then
    local char = g_game.getCharacterName()
    lastCombatControls[char] = {
      fightMode = g_game.getFightMode(),
      chaseMode = g_game.getChaseMode(),
      safeFight = g_game.isSafeFight()
    }

    if g_game.getFeature(GamePVPMode) then
      lastCombatControls[char].pvpMode = g_game.getPVPMode()
    end

    -- save last combat control settings
    g_settings.setNode('LastCombatControls', lastCombatControls)
  end
end