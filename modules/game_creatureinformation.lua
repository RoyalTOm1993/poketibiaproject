local OPCODE_LOOT = 58

function doGetLootByCorpses(data)
  local creature = g_map.getCreatureById(data.lootedBy)
  if (creature) then
	local ItemUi = g_ui.createWidget('ItemAnimated')
	if ItemUi then
		creature:addTopWidget(ItemUi)
		ItemUi.itemID:setItemId(data.id)
		ItemUi.itemID.count:setText(data.count)

        local index = 55
        local function setNextTimer()
          index = index - 1
        end
        local function startTimerUpdate()
          LastTimer = scheduleEvent(function()
            if index == 1 then
              return true
            end
            if index == 10 then
			  g_effects.fadeOut(ItemUi, 250)
            end
		    ItemUi.itemID:setMarginTop(index)
            setNextTimer()
            startTimerUpdate()
		  end, 20)
        end
		g_effects.fadeIn(ItemUi, 250)
        startTimerUpdate()
	end
  end
end

function testeLaele()
	local player = g_game.getLocalPlayer()
	local tile = player:getTile()
	
	local ItemUi = g_ui.createWidget('ItemAnimated')
	ItemUi.itemID:setItemId(2160)
	ItemUi.itemID:setSize('48 48')
	ItemUi.itemID.count:setText(2)
	local index = 55
       local function setNextTimer()
         index = index - 1
       end
       local function startTimerUpdate()
         LastTimer = scheduleEvent(function()
           if index == 1 then
             return true
           end
           if index == 10 then
		  g_effects.fadeOut(ItemUi, 250)
           end
	    ItemUi.itemID:setMarginTop(index)
           setNextTimer()
           startTimerUpdate()
	  end, 20)
       end
	g_effects.fadeIn(ItemUi, 250)
    startTimerUpdate()

	tile:setWidget(ItemUi)
end

function getLootColected(protocol, opcode, buffer)
    local status, json_data = pcall(function()
        return json.decode(buffer)
    end)
    if not status then
        return false
    end
    local tableValue = #json_data.tabela
    local index = 1
    local function sendNextData()
        if index <= tableValue then
            doGetLootByCorpses(json_data.tabela[index])
            index = index + 1
            if index <= tableValue then
                scheduleEvent(sendNextData, 350)
            end
        end
    end
    sendNextData()
end

function init()
  ProtocolGame.registerExtendedOpcode(OPCODE_LOOT, getLootColected)
end

function terminate()
  ProtocolGame.unregisterExtendedOpcode(OPCODE_LOOT)
end