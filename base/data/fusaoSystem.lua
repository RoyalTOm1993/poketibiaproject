local firstFusion = {
	["mewtwo water"] = {required = "mewtwo fire", fusion  = "Mewtwo Water Fire"},
	["mewtwo fire"] = {required = "mewtwo water", fusion  = "Mewtwo Water Fire"},
	
	["miraidon"] = {required = "koraidon", fusion  = "Koramidon"},
	["koraidon"] = {required = "miraidon", fusion  = "Koramidon"},
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local basePos = item:getPosition()
	
	local firstContainerPosition = Position(basePos.x - 1, basePos.y, basePos.z)
	local secondContainerPosition = Position(basePos.x + 1, basePos.y, basePos.z)
	
	local firstTile = Tile(firstContainerPosition)
	local secondTile = Tile(secondContainerPosition)
	
	if firstTile and secondTile then
		local firstContainer = firstTile:getItemById(20664)
		local secondContainer = secondTile:getItemById(20664)
		if firstContainer and secondContainer then
			local firstPoke = firstContainer:getItem(0)
			local secondPoke = secondContainer:getItem(0)
			if firstPoke and secondPoke then
				local isPokeballBoth = firstPoke:isPokeball() and secondPoke:isPokeball()
				if isPokeballBoth then
					local firstPokeName = string.lower(firstPoke:getSpecialAttribute("pokeName"))
					local secondPokeName = string.lower(secondPoke:getSpecialAttribute("pokeName"))
					
					local first = firstFusion[firstPokeName]
					
					if first then
						if secondPokeName == first.required then
							firstPoke:remove()
							secondPoke:remove()
							doAddPokeball(player, first.fusion)
							player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Você acabou de fusionar um %s! parabens!", first.fusion))
							return true
						end
					end
					
				end
			end
		end
	end
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Houve um erro na sua fusão! tente novamente!")
    return true
end