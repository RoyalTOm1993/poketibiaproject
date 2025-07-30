ZONE_CEU = 12

function createRandomHeavenBoss()
	local id = math.random(1,4)
	if id == 1 then
		createRayquaza()
	elseif id == 2 then
		createXerneas()
	elseif id == 3 then
		createLugia()
	elseif id == 4 then
		createZeraora()
	end
end

function createRayquaza()
	local pos = Position(219, 1561, 5)

	local up = 46
	local down = 84
	local left = 52
	local right = 43
	
    pos.x = pos.x + math.random(-left, right)
    pos.y = pos.y + math.random(-down, up)

    local tile = Tile(pos)
    local isWalkable = tile and tile:isWalkable()

    if not isWalkable then
        repeat
			pos.x = pos.x + math.random(-left, right)
			pos.y = pos.y + math.random(-down, up)
            tile = Tile(pos)
            if tile then
                isWalkable = tile:isWalkable()
            end
        until isWalkable
    end
	local boss = Game.createMonster("Rayquaza Ascensao Divina", pos)
	if boss then
		boss:registerEvent("ceuBoss")
	else
		print("[ERROR-BOSSES-CEU] - Não foi possivel criar um boss! criando outro!")
		createRandomHeavenBoss()
	end
end

function createXerneas()
	local pos = Position(209, 1786, 5)
	--[ x = -esquerda +direita]
	--[ y = -baixo +cima]
	local up = 39
	local down = 44
	local left = 55
	local right = 41
	
    pos.x = pos.x + math.random(-left, right)
    pos.y = pos.y + math.random(-down, up)

    local tile = Tile(pos)
    local isWalkable = tile and tile:isWalkable()

    if not isWalkable then
        repeat
			pos.x = pos.x + math.random(-left, right)
			pos.y = pos.y + math.random(-down, up)
            tile = Tile(pos)
            if tile then
                isWalkable = tile:isWalkable()
            end
        until isWalkable
    end
	local boss = Game.createMonster("Xerneas Ascensao Divina", pos)
	if boss then
		boss:registerEvent("ceuBoss")
	else
		print("[ERROR-BOSSES-CEU] - Não foi possivel criar um boss! criando outro!")
		createRandomHeavenBoss()
	end
end

function createLugia()
	local pos = Position(328, 1682, 5)

	local up = 57
	local down = 72
	local left = 62
	local right = 60
	
    pos.x = pos.x + math.random(-left, right)
    pos.y = pos.y + math.random(-down, up)

    local tile = Tile(pos)
    local isWalkable = tile and tile:isWalkable()

    if not isWalkable then
        repeat
			pos.x = pos.x + math.random(-left, right)
			pos.y = pos.y + math.random(-down, up)
            tile = Tile(pos)
            if tile then
                isWalkable = tile:isWalkable()
            end
        until isWalkable
    end
	local boss = Game.createMonster("Lugia Ascensao Divina", pos)
	if boss then
		boss:registerEvent("ceuBoss")
	else
		print("[ERROR-BOSSES-CEU] - Não foi possivel criar um boss! criando outro!")
		createRandomHeavenBoss()
	end
end

function createZeraora()
	local pos = Position(95, 1701, 5)
	
	local up = 60
	local down = 160
	local left = 59
	local right = 55
	
    pos.x = pos.x + math.random(-left, right)
    pos.y = pos.y + math.random(-down, up)

    local tile = Tile(pos)
    local isWalkable = tile and tile:isWalkable()

    if not isWalkable then
        repeat
			pos.x = pos.x + math.random(-left, right)
			pos.y = pos.y + math.random(-down, up)
            tile = Tile(pos)
            if tile then
                isWalkable = tile:isWalkable()
            end
        until isWalkable
    end
	local boss = Game.createMonster("Zeraora Ascensao Divina", pos)
	if boss then
		boss:registerEvent("ceuBoss")
	else
		print("[ERROR-BOSSES-CEU] - Não foi possivel criar um boss! criando outro!")
		createRandomHeavenBoss()
	end
end