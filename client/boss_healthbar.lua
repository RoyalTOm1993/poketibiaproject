mainWindow, boss = nil, nil
bossActive = false
bosses = {}
local opcode_ = 67

function init()
  mainWindow = g_ui.loadUI("boss_healthbar", modules.game_interface.getRootPanel())
  ProtocolGame.registerExtendedJSONOpcode(opcode_, receiveOpcode)
  connect(Creature, {
    onHealthPercentChange = onHealthPercentChange,
	onAppear = onAppear,
	onDisappear = onDisappear,
  })
  
    connect(LocalPlayer, {
    onPositionChange = checkBoss
  })
  
  
end

function terminate()
    mainWindow:destroy()
	ProtocolGame.unregisterExtendedJSONOpcode(opcode_, receiveOpcode)
	
	disconnect(g_game, { onGameEnd = function()  mainWindow:hide() end} )
	disconnect(LocalPlayer, {onPositionChange = checkBoss})
	disconnect(Creature, {onHealthPercentChange = onCreatureHealthPercentChange, onAppear = onAppear, onDisappear = onDisappear, })
end

function checkBoss()
	local player = g_game.getLocalPlayer()
	if not player then return end
	if bossActive and boss:getPosition().z ~= player:getPosition().z then
		bossActive = false
		boss = nil
        updateBar(false)
    else
        local spectators = g_map.getSpectators(g_game.getLocalPlayer():getPosition())
        for k,v in pairs(spectators) do
            if v:isBoss() and not bossActive then
                bossActive = true
                boss = v
                updateBar(true)
            end
        end
    end
end

function getHealthColor(health)
  return (health < 35) and '#d72800' or
	     (health < 65) and '#e7c148' or '#5fda4c'
end

function onHealthPercentChange(creature, health)
    if creature:isBoss() and creature == boss then
		mainWindow.health:setPercent(health)
		mainWindow.health:setBackgroundColor(getHealthColor(health))
	elseif creature:isBoss() and not bossActive then
		bossActive = true
		boss = creature
		updateBar(true)
    end
end

function updateBar(bool)
	if bool then
		mainWindow:setVisible(true)
		g_effects.fadeIn(mainWindow, 400)
		mainWindow.boss:setOutfit(boss:getOutfit())
		mainWindow.name:setText(boss:getName())
	else
		mainWindow:setVisible(false)
	end
end

function onAppear(creature)
    local player = g_game.getLocalPlayer()
	if not player or not creature then return end
	if player == creature then
		return
	end

local function callback(creature)
	if not g_game.getLocalPlayer() or not creature then return end
	if not g_game.getLocalPlayer():getPosition() or not creature:getPosition() then
		return
	end
	if g_game.getLocalPlayer():getPosition().z ~= creature:getPosition().z then
		return
	end
	
	if bossActive and boss and boss:getPosition() and boss:getPosition().z ~= creature:getPosition().z then
		bossActive = false
		boss = nil
	end
	if creature:isBoss() and not bossActive then
		bossActive = true
		boss = creature
		updateBar(true)
	end
end

	scheduleEvent(function()
		callback(creature)
	end, 250)
end

function onDisappear(creature)
	if bossActive and creature:isBoss() and boss == creature then
		bossActive = false
		boss = nil
		updateBar(false)
	end
end

function Creature:isBoss()
	if not bosses then return false end
	for _, bossName in pairs(bosses) do
		if string.lower(bossName) == string.lower(self:getName()) then
			return true
		end
	end
	return false
end

function receiveOpcode(protocol, opcode, data)
	 bosses = data
end