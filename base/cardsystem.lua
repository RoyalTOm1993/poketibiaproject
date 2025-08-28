cardList = {
[16292] = "Arceus",
[16264] = "Articuno",
[16244] = "Dialga",
[16263] = "Moltres",
[16262] = "Zapdos",
[16272] = "Zygarde",
[16274] = "Regirock",
[16269] = "Registeel",
[16297] = "Regice",
[16281] = "Kyogre",
[16284] = "Groudon",
[16270] = "Rayquaza",
[16299] = "Palkia",
[16296] = "Yveltal",
[16289] = "Ho-oh",
[16288] = "Latias",
[16287] = "Latios",
[16283] = "Celebi",
[16280] = "Genesect",
[16286] = "Terrakion",
[16278] = "Deoxys",
[16277] = "Virizion",
[16275] = "Giratina",
[16273] = "Heatran",
[16268] = "Shaymin",
[16267] = "Xerneas",
[16266] = "Jirachi",
[16265] = "Phione",
[16290] = "Cresselia",
[16298] = "Mini Hoopa",
[16293] = "Lunala",
[21261] = "Halloween",
[22914] = "Rei do Trovao",
[23495] = "Exodia",
[21081] = "Supreme",
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target then
		return false
	end

	if type(target) ~= "userdata" then
		return true
	end

	if target:isCreature() then
		return false
	end

	if target:isItem() and not target:isPokeball() then
		player:sendCancelMessage("Sorry, not possible. You can only use on pokeballs.")
		return true
	end


	target:setSpecialAttribute("pokeCard", cardList[item.itemid])


	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	item:remove(1)
	return true
end
