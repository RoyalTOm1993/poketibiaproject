local boxes = 
{
    [16185] = {boxName= "Box +5", balltype = "ultra", pokemons = {"Suicune", "Raikou", "Entei"}},
    [16186] = {boxName= "Box +6", balltype = "ultra", pokemons = {"Regice", "Regirock", "Registeel"}},
    [16187] = {boxName= "Box +7", balltype = "ultra", pokemons = {"Groudon", "Kyogre", "Rayquaza"}},
    [16188] = {boxName= "Box +8", balltype = "ultra", pokemons = {"Azelf", "Mesprit", "Uxie"}},
    [16189] = {boxName= "Box +9", balltype = "ultra", pokemons = {"Deoxys"}},
    [16190] = {boxName= "Box +10", balltype = "ultra", pokemons = {"Regigigas", "Shiny Regigigas"}},
    [16191] = {boxName= "Box +11", balltype = "ultra", pokemons = {"Zekrom", "Reshiram"}},
    [16192] = {boxName= "Box +12", balltype = "ultra", pokemons = {"Palkia", "Dialga"}},
    [16193] = {boxName= "Box +13", balltype = "ultra", pokemons = {"Celebi"}},
    [16194] = {boxName= "Box +14", balltype = "ultra", pokemons = {"Phione"}},
    [16195] = {boxName= "Box +15", balltype = "ultra", pokemons = {"Green Dialga"}},
    [16196] = {boxName= "Box +16", balltype = "ultra", pokemons = {"Giratina"}},
    [16197] = {boxName= "Box +17", balltype = "ultra", pokemons = {"Mew", "Mewtwo"}},
    [16198] = {boxName= "Box +18", balltype = "ultra", pokemons = {"Lugia"}},
    [16199] = {boxName= "Box +19", balltype = "ultra", pokemons = {"Ho-oh"}},
    [16200] = {boxName= "Box +20", balltype = "ultra", pokemons = {"Genesect"}},
    [16201] = {boxName= "Box +21", balltype = "ultra", pokemons = {"Jirachi"}},
    [16202] = {boxName= "Box +22", balltype = "ultra", pokemons = {"Victini"}},
    [16203] = {boxName= "Box +23", balltype = "ultra", pokemons = {"Darkrai"}},
    [16204] = {boxName= "Box +24", balltype = "ultra", pokemons = {"Heatran"}},
    [16205] = {boxName= "Box +25", balltype = "ultra", pokemons = {"Mini Hoopa"}},
    [16206] = {boxName= "SuperBox +1", balltype = "ultra", pokemons = {"Mega Lucario", "Shiny Lucario", "Lucario"}},
    [16207] = {boxName= "SuperBox +2", balltype = "ultra", pokemons = {"Hydreigon", "Shiny Hydreigon"}},
    [16208] = {boxName= "SuperBox +3", balltype = "ultra", pokemons = {"Cresselia"}},
    [16209] = {boxName= "SuperBox +4", balltype = "ultra", pokemons = {"Terrakion"}},
    [16210] = {boxName= "SuperBox +5", balltype = "ultra", pokemons = {"Virizion"}},
    [16211] = {boxName= "SuperBox +6", balltype = "ultra", pokemons = {"Solgaleo"}},
}


function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local itemId = item:getId()
	for key, value in pairs(boxes) do
		if value.itemid == itemId then
			local random = math.random(1, #boxes[key].pokes)
			local pokeName = boxes[key].pokes[random]
			local monsterType = MonsterType(pokeName)
			if not monsterType then
				print("WARNING! Pokemon " .. pokeName .. " not valid for box.")
				return true
			end
			doAddPokeball(player:getId(), pokeName)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Congratulations! You have found a " .. pokeName .. ".")
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			break
		end
	end
	item:remove(1)
	return true
end
