function onUse(player, item, fromPosition, target, toPosition)
    player = Player(player)
	if not target or type(target) ~= "userdata" or not Item(target.uid) then
		return player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Use em uma pokebola!.")
	end
	if not target:isPokeball() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Use em uma pokebola!.")
		return true
	end
    
    local cfg = {
        -- Additional Boost Stones
        {id = 13215, qnt = 10, max = 100, minBoost = 0, chance = 0},     -- Boost Stone 2
        {id = 13559, qnt = 70, max = 300, minBoost = 300, chance = 0},     -- Boost Stone 2
        {id = 13560, qnt = 80, max = 1250, minBoost = 1000, chance = 20},   -- Boost Stone 80
        {id = 13561, qnt = 85, max = 2500, minBoost = 1250, chance = 30},   -- Boost Stone 85
        {id = 13562, qnt = 100, max = 3500, minBoost = 2500, chance = 40},  -- Boost Stone 100
        {id = 13563, qnt = 200, max = 5000, minBoost = 3500, chance = 50},  -- Boost Stone 200
        {id = 13564, qnt = 300, max = 10000, minBoost = 5000, chance = 60},  -- Boost Stone 300
        {id = 13565, qnt = 400, max = 15000, minBoost = 10000, chance = 70},  -- Boost Stone 400
        {id = 20679, qnt = 500, max = 20000, minBoost = 15000, chance = 80}, -- Boost Stone 500
        {id = 20709, qnt = 750, max = 30000, minBoost = 20000, chance = 0}, -- Boost Stone 500
        {id = 20708, qnt = 1000, max = 50000, minBoost = 30000, chance = 0} -- Boost Stone 500
    }


    local boost = target:getSpecialAttribute("pokeBoost") or 0
    if #getCreatureSummons(player:getId()) >= 1 then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Chame seu pokémon para dentro da pokebola para usar!")
        return true
    end

    for _, stone in ipairs(cfg) do
        if item:getId() == stone.id then
            if boost >= stone.max then
                return player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Seu pokémon já se encontra no nível máximo de boost para essa Boost Stone!")
            end

            local failChance = 0

            if boost >= stone.minBoost then
                failChance = stone.chance
            end

            local chanceFail = math.random(1, 100)
            if chanceFail <= failChance then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Sua boost stone falhou!")
                item:remove(1)
                player:getPosition():sendMagicEffect(897)
            else
                target:setSpecialAttribute("pokeBoost", (boost + stone.qnt))
                player:getPosition():sendMagicEffect(896)
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Seu pokémon avançou do nível [+" .. tonumber(boost) .. "] de boost para o nível [+" .. tonumber(boost + stone.qnt) .. "].")
                item:remove(1)
            end

            return true
        end
    end

    -- If the item ID doesn't match any Boost Stone ID, return false.
    return false
end
