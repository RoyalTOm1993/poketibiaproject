local teleportPosition = Position(203, 1702, 4)

function onStepIn(player, item, position, fromPosition)
	if not player:isPlayer() then return true end
	local reset = math.max(0, player:getStorageValue(CONST_RESET_POINTS))
	local megaReset = math.max(0, player:getStorageValue(CONST_MEGA_RESET_POINTS))
	
	local totalResets = (megaReset * 100) + reset
	if totalResets >= 500 then
		player:teleportTo(teleportPosition)
		player:popupFYI(" Seja bem-vindo(a) a Glacíria, a cidade flutuante onde o céu\n se une à eterna neve. É com grande alegria que os recebemos\n neste lugar único. Aqui, sob as estrelas cintilantes e os picos das\n montanhas celestiais, quatro lendários Pokémon ascenderam \npara criar seus domínios.")
	end
    return true
end