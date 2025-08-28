local maximumGoals = math.random(15, 20)
local prizes = {[1] = {item = "crystal coin", count = 5}, [2] = {item = "empty premierball", count = 50}}

local footballPosition = Position(683, 1185, 6)
local soccerArenaFromPos = {679, 1179, 6}
local soccerArenaToPos = {686, 1191, 6}

local teamRedFromPos = {673, 1190, 6}
local teamRedToPos = {677, 1191, 6}
local teamRedFieldFromPos = {679, 1179, 6}
local teamRedFieldToPos = {686, 1184, 6}

local teamBlueFromPos = {688, 1190, 6}
local teamBlueToPos = {692, 1191, 6}
local teamBlueFieldFromPos = {679, 1186, 6}
local teamBlueFieldToPos = {686, 1191, 6}

local observersFromPos = {673, 1193, 6}
local observersToPos = {692, 1195, 6}

local observersRedFieldFromPos = {675, 1179, 6}
local observersRedFieldToPos = {677, 1191, 6}

local observersBlueFieldFromPos = {688, 1179, 6}
local observersBlueFieldToPos = {690, 1191, 6}

local condition = Condition(CONDITION_OUTFIT)
condition:setTicks(-1)

local function soccerEventStop()
	print("WARNING! Encerrando evento soccer.")
	isEventRunning = false
	return true
end

local function distributePrizes(winners, winners2, loosers, loosers2)
	for i = 1, #winners do
		local player = Player(winners[i])
		if player then
			for _,value in pairs(prizes) do
				player:addItem(value.item, value.count)
			end
			player:teleportTo(player:getTown():getTemplePosition())
			player:setStorageValue(storageEvent, -1)
			player:removeCondition(CONDITION_OUTFIT)
			player:changeSpeed(player:getBaseSpeed() - player:getSpeed())
		end
	end	

	for i = 1, #winners2 do
		local player = Player(winners2[i])
		if player then
			for _,value in pairs(prizes) do
				player:addItem(value.item, value.count)
			end
			player:teleportTo(player:getTown():getTemplePosition())
			player:setStorageValue(storageEvent, -1)
			player:removeCondition(CONDITION_OUTFIT)
			player:changeSpeed(player:getBaseSpeed() - player:getSpeed())
		end
	end

	for i = 1, #loosers do
		local player = Player(loosers[i])
		if player then
			player:teleportTo(player:getTown():getTemplePosition())
			player:setStorageValue(storageEvent, -1)
			player:removeCondition(CONDITION_OUTFIT)
			player:changeSpeed(player:getBaseSpeed() - player:getSpeed())
		end
	end

	for i = 1, #loosers2 do
		local player = Player(loosers2[i])
		if player then
			player:teleportTo(player:getTown():getTemplePosition())
			player:setStorageValue(storageEvent, -1)
			player:removeCondition(CONDITION_OUTFIT)
			player:changeSpeed(player:getBaseSpeed() - player:getSpeed())
		end
	end
	soccerEventStop()
end

local function soccerEventReteleportPlayers()
	for i = 1, #teamRed do
		local player = Player(teamRed[i])
		if player then
			local randomPosx = math.random(teamRedFieldFromPos[1], teamRedFieldToPos[1])
			local randomPosy = math.random(teamRedFieldFromPos[2], teamRedFieldToPos[2])
			local teleportPosition = Position(randomPosx, randomPosy, teamRedFieldFromPos[3])
			player:teleportTo(teleportPosition)
		end
	end

	for i = 1, #teamBlue do
		local player = Player(teamBlue[i])
		if player then
			local randomPosx = math.random(teamBlueFieldFromPos[1], teamBlueFieldToPos[1])
			local randomPosy = math.random(teamBlueFieldFromPos[2], teamBlueFieldToPos[2])
			local teleportPosition = Position(randomPosx, randomPosy, teamBlueFieldFromPos[3])
			player:teleportTo(teleportPosition)
		end
	end
end

function soccerEventRestartMatch(scoredRed, scoredBlue)
	if scoredRed then
		scoreRed = scoreRed + 1
		broadcastMessage("Time vermelho marcou gol!. Placar " .. "Vermelho: " .. scoreRed .. ", azul: " .. scoreBlue, MESSAGE_STATUS_WARNING)
	elseif scoredBlue then
		scoreBlue = scoreBlue + 1
		broadcastMessage("Time azul marcou gol!. Placar " .. "Vermelho: " .. scoreRed .. ", azul: " .. scoreBlue, MESSAGE_STATUS_WARNING)
	else
		print("WARNING! Both teams scored in soccer event!")
	end
	if scoreRed >= maximumGoals or scoreBlue >= maximumGoals then
		if scoreRed > scoreBlue then
			broadcastMessage("Time vermelho ganhou, parabens!", MESSAGE_STATUS_WARNING)
			distributePrizes(teamRed, observersRed, teamBlue, observersBlue)
		else
			broadcastMessage("Time azul ganhou, parabens!", MESSAGE_STATUS_WARNING)
			distributePrizes(teamBlue, observersBlue, teamRed, observersRed)
		end
	else
		soccerEventCreateFootbal()
		soccerEventReteleportPlayers()
	end
end


function soccerEventCreateFootbal()
	Game.createItem("football", 1, footballPosition)
end

local function soccerEventTeleportPlayers(observers)
	for i = 1, #teamRed do
		local player = Player(teamRed[i])
		if player then
			local randomPosx = math.random(teamRedFieldFromPos[1], teamRedFieldToPos[1])
			local randomPosy = math.random(teamRedFieldFromPos[2], teamRedFieldToPos[2])
			local teleportPosition = Position(randomPosx, randomPosy, teamRedFieldFromPos[3])
			player:teleportTo(teleportPosition)
		end
	end

	for i = 1, #teamBlue do
		local player = Player(teamBlue[i])
		if player then
			local randomPosx = math.random(teamBlueFieldFromPos[1], teamBlueFieldToPos[1])
			local randomPosy = math.random(teamBlueFieldFromPos[2], teamBlueFieldToPos[2])
			local teleportPosition = Position(randomPosx, randomPosy, teamBlueFieldFromPos[3])
			player:teleportTo(teleportPosition)
		end
	end

	for i = 1, #observers do
		local player = Player(observers[i])
		if player then
			local position = player:getPosition()
			if position.x < observersFromPos[1] + (observersToPos[1] - observersFromPos[1]) / 2 then
				player:teleportTo(Position(math.random(observersRedFieldFromPos[1], observersRedFieldToPos[1]), math.random(observersRedFieldFromPos[2], observersRedFieldToPos[2]), observersRedFieldFromPos[3]))
				table.insert(observersRed, observers[i])
				condition:setOutfit({lookType = 128, lookBody = 94, lookFeet = 114, lookHead = 114, lookLegs = 94})
				player:addCondition(condition)
			else
				player:teleportTo(Position(math.random(observersBlueFieldFromPos[1], observersBlueFieldToPos[1]), math.random(observersBlueFieldFromPos[2], observersBlueFieldToPos[2]), observersRedFieldFromPos[3]))
				table.insert(observersBlue, observers[i])
				condition:setOutfit({lookType = 128, lookBody = 88, lookFeet = 114, lookHead = 114, lookLegs = 88})
				player:addCondition(condition)			
			end
		end
	end
	soccerEventCreateFootbal()
end

local function shuffle(tbl)
	size = #tbl
	for i = size, 1, -1 do
		local rand = math.random(size)
		tbl[i], tbl[rand] = tbl[rand], tbl[i]
	end
	return tbl
end

local function soccerEventStart()
	soccerEventIsOpen = false
	local players = Game.getPlayers()
	local playersSub = {}
	for i = 1, #players do
		local player = players[i]
		if player:getStorageValue(storageSoccerEvent) > 0 then
			playersSub[#playersSub + 1] = player
		end
	end

	if #playersSub >= 8 then
		broadcastMessage("Inscricoes para o envento de futebol encerradas! Players sendo transportados para o evento. Acaba quando o primeiro time fizer " .. maximumGoals .. " gols!", MESSAGE_STATUS_WARNING)
		local playersRandom = shuffle(playersSub)
		local observers = {}
		local randomPosx
		local randomPosy
		for i = 1, #playersRandom do
			local player = playersRandom[i]
			if (player:isOnRide() or player:isOnFly() or player:isOnSurf()) then
				player:say("Thanks, " .. player:getSummonNameFromBall() .. "!", TALKTYPE_SAY)
				player:removeCondition(CONDITION_OUTFIT)
				player:changeSpeed(player:getBaseSpeed() - player:getSpeed())
				player:setStorageValue(storageRide, -1)
				player:setStorageValue(storageFly, -1)
				player:setStorageValue(storageSurf, -1)
			end
			if player:isOnBike() then
				player:removeCondition(CONDITION_OUTFIT)
				player:changeSpeed(player:getBaseSpeed() - player:getSpeed())
				player:setStorageValue(storageBike, -1)
			end
			if i <= 4 then
				table.insert(teamRed, playersRandom[i]:getId())
				randomPosx = math.random(teamRedFromPos[1], teamRedToPos[1])
				randomPosy = math.random(teamRedFromPos[2], teamRedToPos[2])
				condition:setOutfit({lookType = 128, lookBody = 94, lookFeet = 114, lookHead = 114, lookLegs = 94})
				player:addCondition(condition)
				player:changeSpeed(500 - player:getSpeed())
			elseif i > 4 and i <= 8 then
				table.insert(teamBlue, playersRandom[i]:getId())
				randomPosx = math.random(teamBlueFromPos[1], teamBlueToPos[1])
				randomPosy = math.random(teamBlueFromPos[2], teamBlueToPos[2])
				condition:setOutfit({lookType = 128, lookBody = 88, lookFeet = 114, lookHead = 114, lookLegs = 88})
				player:addCondition(condition)
				player:changeSpeed(500 - player:getSpeed())
			else
				randomPosx = math.random(observersFromPos[1], observersToPos[1])
				randomPosy = math.random(observersFromPos[2], observersToPos[2])
				table.insert(observers, playersRandom[i]:getId())
			end
			local teleportPosition = Position(randomPosx, randomPosy, observersFromPos[3])
			player:teleportTo(teleportPosition)
			player:setStorageValue(storageSoccerEvent, -1)
			player:setStorageValue(storageEvent, 1)			

			if hasSummons(player) then
				local item = player:getUsingBall()
				if not item then return false end
				local ballKey = getBallKey(item:getId())		
				doRemoveSummon(player:getId(), balls[ballKey].effectRelease)
				item:transform(balls[ballKey].usedOn)
			end
		end
		addEvent(broadcastMessage, 5 * 1000, "Quem esta na torcida tem 30 segundos para escolher para qual time ira torcer. Basta ficar do lado correspondente", MESSAGE_STATUS_WARNING)
		addEvent(soccerEventTeleportPlayers, 35 * 1000, observers)
	else
		broadcastMessage("Evento de futebol cancelado pois nao alcancou um minimo de 8 inscritos.", MESSAGE_STATUS_WARNING)
		for i = 1, #players do
			local player = players[i]
			if player:getStorageValue(storageSoccerEvent) > 0 then
				player:setStorageValue(storageSoccerEvent, -1)
			end
		end
		soccerEventStop()
	end
end

function onTime(interval)
	local day = os.date("%A")
--	if day ~= "Saturday" then
--		return true
--	end
	local isEventRunning = true
	teamRed = {}
	teamBlue = {}
	observersRed = {}
	observersBlue = {}
	scoreRed = 0
	scoreBlue = 0
	ipsSub = {}
	local msg
	for i = 0, 4 do
		msg = "Evento de futebol daqui " 
		msg = msg .. (5 - i) * 2 .. " minutos. Para se inscrever, voce deve ter level 5 e deve dizer hi e depois futebol ao NPC Manager que se encontra no CP de Saffron."
		addEvent(broadcastMessage, i * 2 * 60 * 1000, msg, MESSAGE_STATUS_WARNING)
	end
	addEvent(soccerEventStart, 10 * 60 * 1000)
	soccerEventIsOpen = true

	return true
end
