local secondsBetweenRaids = 15
local eventFromPos = {646, 1198, 6}
local eventToPos = {670, 1208, 6}
local raids = {"ArenaRaticate", "ArenaOnix", "ArenaVileplume", "ArenaCharizard", "ArenaLendarios", "ArenaLendarios2", "ArenaLendarios4", "ArenaLendarios3", "ArenaLendarios3"}
local prizes = {[1] = {item = "crystal coin", count = 10}, [2] = {item = "empty premierball", count = 50}}

local function cleanArena()
	for x = eventFromPos[1], eventToPos[1] do
		for y = eventFromPos[2], eventToPos[2] do
			local tile = Tile(x, y, eventFromPos[3])
			if tile and tile:getCreatureCount() > 0 then
				for i = 1, tile:getCreatureCount() do
					if tile:getCreatures()[i]:isMonster() and not tile:getCreatures()[i]:isPokemon() then
						tile:getCreatures()[i]:remove()
					end
				end
			end
		end
	end
	return true
end

local function arenaEventStop()
	print("WARNING! Encerrando evento gold arena.")
	isArenaEventRunning = false
	local winner = Player(arenaLastPlayerId)
	if winner then
		broadcastMessage("Evento gold arena finalizado! O vencedor foi: " .. winner:getName() .. ". Parabens!", MESSAGE_STATUS_WARNING)
		for _,value in pairs(prizes) do
			winner:addItem(value.item, value.count)
		end
	else
		print("WARNING! gold arena sem vencedor!")
	end
	cleanArena()
	Game.startRaid("Christmas Saffron")
	return true
end

function arenaEventTryStop()
	local playersRemaining = 0
	for x = eventFromPos[1], eventToPos[1] do
		for y = eventFromPos[2], eventToPos[2] do
			local tile = Tile(x, y, eventFromPos[3])
			if tile and tile:getCreatureCount() > 0 then
				for i = 1, tile:getCreatureCount() do
					if tile:getCreatures()[i]:isPlayer() and tile:getCreatures()[i]:getAccountType() < ACCOUNT_TYPE_GAMEMASTER then
						playersRemaining = playersRemaining + 1
					end
				end
			end
		end
	end
	print("WARNING! Players ainda na arena do evento gold arena: " .. playersRemaining)
	if playersRemaining == 0 then
		arenaEventStop()
	end
end

local function getCreatureCountArena()
	local creaturesRemaining = 0
	for x = eventFromPos[1], eventToPos[1] do
		for y = eventFromPos[2], eventToPos[2] do
			local tile = Tile(x, y, eventFromPos[3])
			if tile and tile:getCreatureCount() > 0 then
				for i = 1, tile:getCreatureCount() do
					if tile:getCreatures()[i]:isMonster() and not tile:getCreatures()[i]:isPokemon() then
						creaturesRemaining = creaturesRemaining + 1
					end
				end
			end
		end
	end
	return creaturesRemaining
end

local function tryStartRaid(actualRaid)
	if isArenaEventRunning then
		local creaturesRemaining = getCreatureCountArena()
		if creaturesRemaining <= 0 and activeRaidsArena[actualRaid] == nil then
			activeRaidsArena[actualRaid] = 1
			Game.startRaid(raids[actualRaid])
			addEvent(tryStartRaid, secondsBetweenRaids * 1000, actualRaid + 1)
		else		
			addEvent(tryStartRaid, secondsBetweenRaids * 1000, actualRaid)
		end
	end
end

local function arenaEventStart()
	broadcastMessage("Inscricoes para o envento gold arena encerradas! Players sendo transportados para o evento.", MESSAGE_STATUS_WARNING)
	local players = Game.getPlayers()
	for i = 1, #players do
		local player = players[i]
		if player:getStorageValue(storageArenaEvent) > 0 then
			local randomPosx = math.random(eventFromPos[1], eventToPos[1])
			local randomPosy = math.random(eventFromPos[2], eventToPos[2])
			local teleportPosition = Position(randomPosx, randomPosy, eventFromPos[3])
			player:teleportTo(teleportPosition)
			player:setStorageValue(storageArenaEvent, 2)
			player:registerEvent("PrepareDeathArena")
		end
	end
	arenaEventIsOpen = false
	tryStartRaid(1)	
end

local function fifthArenaEventWarning()
	broadcastMessage("Evento gold arena vai ser iniciado daqui 1 minuto. Para se inscrever, voce deve ter level 5 e deve dizer hi e depois arena ao NPC Manager que se encontra em frente ao CP de Saffron. As inscricoes serao encerradas daqui 1 minuto.", MESSAGE_STATUS_WARNING)
	addEvent(arenaEventStart, 1 * 60 * 1000)
end

local function fourthArenaEventWarning()
	broadcastMessage("Evento gold arena vai ser iniciado daqui 2 minutos. Para se inscrever, voce deve ter level 5 e deve dizer hi e depois arena ao NPC Manager que se encontra em frente ao CP de Saffron.", MESSAGE_STATUS_WARNING)
	addEvent(fifthArenaEventWarning, 1 * 60 * 1000)
end

local function thirdArenaEventWarning()
	broadcastMessage("Evento gold arena vai ser iniciado daqui 4 minutos. Para se inscrever, voce deve ter level 5 e deve dizer hi e depois arena ao NPC Manager que se encontra em frente ao CP de Saffron.", MESSAGE_STATUS_WARNING)
	addEvent(fourthArenaEventWarning, 2 * 60 * 1000)
end

local function secondArenaEventWarning()
	broadcastMessage("Evento gold arena vai ser iniciado daqui 6 minutos. Para se inscrever, voce deve ter level 5 e deve dizer hi e depois arena ao NPC Manager que se encontra em frente ao CP de Saffron.", MESSAGE_STATUS_WARNING)
	addEvent(thirdArenaEventWarning, 2 * 60 * 1000)
end

local function firstArenaEventWarning()
	broadcastMessage("Evento gold arena vai ser iniciado daqui 8 minutos. Para se inscrever, voce deve ter level 5 e deve dizer hi e depois arena ao NPC Manager que se encontra em frente ao CP de Saffron.", MESSAGE_STATUS_WARNING)
	addEvent(secondArenaEventWarning, 2 * 60 * 1000)
end

function onTime(interval)
	local day = os.date("%A")
	if day ~= "Saturday" then
		return true
	end
	ipsSub = {}
	activeRaidsArena = {}
	isArenaEventRunning = true
	broadcastMessage("Evento gold arena vai ser iniciado daqui 10 minutos. Para se inscrever, voce deve ter level 5 e deve dizer hi e depois arena ao NPC Manager que se encontra em frente ao CP de Saffron.", MESSAGE_STATUS_WARNING)
	arenaEventIsOpen = true
	addEvent(firstArenaEventWarning, 2 * 60 * 1000)
	return true
end
