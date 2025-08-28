local eventFromPos = {1814, 2258, 7}
local eventToPos = {1849, 2278, 7}
local prizes = {[1] = {item = "crystal coin", count = 10}, [2] = {item = "empty premierball", count = 50}}

local function arenaPvpEventStop(cid)
	print("WARNING! Encerrando evento pvp arena.")
	local winner = Player(cid)
	if winner then
		broadcastMessage("Evento pvp arena finalizado! O vencedor foi: " .. winner:getName() .. ". Parabens!", MESSAGE_STATUS_WARNING)
		winner:teleportTo(winner:getTown():getTemplePosition())
		winner:setStorageValue(storageArenaPvpEvent, -1)
		winner:setOutLeague()
		winner:unregisterEvent("PrepareDeathArenaPvp")
		for _,value in pairs(prizes) do
			winner:addItem(value.item, value.count)
		end
	else
		print("WARNING! pvp arena sem vencedor!")
	end
	return true
end

function arenaPvpEventTryStop()
	local playersRemaining = {}
	for x = eventFromPos[1], eventToPos[1] do
		for y = eventFromPos[2], eventToPos[2] do
			local tile = Tile(x, y, eventFromPos[3])
			if tile and tile:getCreatureCount() > 0 then
				for i = 1, tile:getCreatureCount() do
					if tile:getCreatures()[i]:isPlayer() and tile:getCreatures()[i]:getGroup():getId() <= 2 then
						table.insert(playersRemaining, tile:getCreatures()[i]:getId())
					end
				end
			end
		end
	end
	print("WARNING! Players ainda na arena do evento pvp arena: " .. #playersRemaining)
	if #playersRemaining == 1 then
		arenaPvpEventStop(playersRemaining[1])
	end
end

local function arenaPvpEventStart()
	broadcastMessage("Inscricoes para o envento arena PVP encerradas! Players sendo transportados para o evento.", MESSAGE_STATUS_WARNING)
	local players = Game.getPlayers()
	for i = 1, #players do
		local player = players[i]
		if player:getStorageValue(storageArenaPvpEvent) > 0 then
			local randomPosx = math.random(eventFromPos[1], eventToPos[1])
			local randomPosy = math.random(eventFromPos[2], eventToPos[2])
			local teleportPosition = Position(randomPosx, randomPosy, eventFromPos[3])
			player:teleportTo(teleportPosition)
			player:setStorageValue(storageArenaPvpEvent, 2)
			player:setOnLeague()
			player:registerEvent("PrepareDeathArenaPvp")
		end
	end
	arenaPvpEventIsOpen = false
end

function onTime(interval)
	local day = os.date("%A")
--	if day ~= "Saturday" then
--		return true
--	end
	ipsSub = {}
	for i = 0, 4 do
		msg = "Evento arena PVP daqui " 
		msg = msg .. (5 - i) * 2 .. " minutos. Para se inscrever, voce deve ter level 5 e deve dizer hi e depois pvp ao NPC Manager que se encontra no CP de Saffron."
		addEvent(broadcastMessage, i * 2 * 60 * 1000, msg, MESSAGE_STATUS_WARNING)
	end
	addEvent(arenaPvpEventStart, 10 * 60 * 1000)
	arenaPvpEventIsOpen = true
	return true
end
