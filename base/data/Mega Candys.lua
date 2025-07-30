function onUse(player, item, fromPosition, target, toPosition)
	if not target or type(target) ~= "userdata" or not Item(target.uid) then
		return player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Use em uma pokebola!.")
	end
	if not target:isPokeball() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Use em uma pokebola!.")
		return true
	end
player = Player(player)
 
local cfg = {
    qnt = 1,       --Quantos boosts o pok�mon ir� receber.
    max = 500,      --Boost m�ximo do seu servidor.
    chance = 5,   --Chance de acertar, em %
    boost_fail = 100,  --A partir de quantos boosts poder� falhar.
}
 


	
	if #getCreatureSummons(player:getId()) >= 1 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Chame seu pok�mon para dentro da pokebola para usar!")
	return true
	end

local boost = target:getSpecialAttribute("pokeLevel") or 0

	if boost >= cfg.max then
        return player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Seu pok�mon j� se encontra no n�vel m�ximo!")
    end
    
    if boost >= cfg.boost_fail then
	local chanceFail = math.random(1, 100)
        if chanceFail <= cfg.chance then
            target:setSpecialAttribute("pokeLevel", (boost + cfg.qnt))
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Seu pok�mon avan�ou do n�vel [+"..tonumber(boost).."] para o n�vel [+"..tonumber(boost + 1).."].")
			player:getPosition():sendMagicEffect(896)
            item:remove(1)
        else
           player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Sua mega candy falhou!")
           item:remove(1)
		   player:getPosition():sendMagicEffect(897)
        end
    else
        target:setSpecialAttribute("pokeLevel", (boost + cfg.qnt))
		player:getPosition():sendMagicEffect(896)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Seu pok�mon avan�ou do n�vel [+"..tonumber(boost).."] para o n�vel [+"..tonumber(boost + 1).."].")
        item:remove(1)
    end
    return true
end