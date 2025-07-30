function Player:tutorialBoost()
local check = false
local summons = self:getSummons()
	if #summons > 0 then
		local summon = summons[1]
		local boost = summon:getBoost() or 0
		if boost >= 999 then
			check = true
		else
			check = false
		end
	else
		check = false
	end	
return check
end

function onStepIn(cid, item, position, fromPosition)
local player = Player(cid)
    local playerStorageValue = getPlayerStorageValue(cid, 44301) -- Substitua 50001 pelo valor da storage que você deseja verificar.
	
    if playerStorageValue >= 1 then
		if not player:tutorialBoost() then doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa estar com o pokemon solto, e precisa ter usado a boost nele.") return true end
        -- O jogador possui a storage necessária.
        doTeleportThing(cid, {x = 497, y = 575, z = 5})
        doSendMagicEffect(position, CONST_ME_TELEPORT)
    else
        -- O jogador não possui a storage necessária.
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você não pode ser teleportado sem completar aa missao da magna.")
    end

    return true
end
